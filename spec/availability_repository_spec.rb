require "availability_repository"
require "shared_context_spec"
require "room_repository"
require "availability"

def reset_table
  seed_sql = File.read('spec/makersbnb_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe AvailabilityRepository do
  
  before { reset_table }
  after { reset_table }

  include_context "doubles setup"

  context ".all method" do
    it "should return a list of all date with available rooms" do
      result = subject.all
      expect(result.length).to eq 5
    end
    it "should return correct the correct data" do
      result = subject.all
      expect(result.first.id).to eq 1
      expect(result.first.date).to eq '2023-05-01'
    end
    it "should return correct the correct data" do
      result = subject.all
      expect(result.last.id).to eq 5
      expect(result.last.date).to eq '2023-05-05'
    end
  end

  context ".find method" do
    it "should return a single availability object - test with 2023-05-01" do
      result = subject.find("2023-05-01")
      expect(result.id).to eq 1
      expect(result.date).to eq "2023-05-01"
      expect(result.rooms.first.name).to eq 'Changs Palace'
      expect(result.rooms.last.name).to eq 'Destans Polski Sklep'
    end
    it "should return a single availability object  - test with 2023-05-03" do
      result = subject.find("2023-05-04")
      expect(result.id).to eq 4
      expect(result.date).to eq "2023-05-04"
      expect(result.rooms.first.name).to eq 'Kons Gaff'
      expect(result.rooms.last.name).to eq 'Destans Polski Sklep'
    end
    it "should return 'no rooms available for that date' if availibilty does not exist" do
      result = subject.find("2023-05-06")
      expect(result).to eq 'no rooms available for that date'
    end
  end

  context ".find_by_id method" do
    it "should return a single availability object - test with 2023-05-01" do
      result = subject.find_by_id(1)
      expect(result.id).to eq 1
      expect(result.date).to eq "2023-05-01"
    end
  end

  context ".find_by_room method" do
    it "should find all the availibilities for a specific room - test with id = 1" do
      result = subject.find_by_room(room1.id)
      expect(result.first.date).to eq '2023-05-01'
      expect(result[1].date).to eq '2023-05-02'
      expect(result.last.date).to eq '2023-05-03'
      expect(result[3]).to be_nil
    end
    it "should find all the availibilities for a specific room - test with id = 2" do
      result = subject.find_by_room(room2.id)
      expect(result.first.date).to eq '2023-05-02'
      expect(result.last.date).to eq '2023-05-03'
      expect(result[2]).to be_nil
    end
  end

  context ".find_rooms_within_range" do
    it "should find all the rooms that are available within a range of dates" do
      result = subject.find_rooms_within_range("2023-05-01", "2023-05-02")
      expect(result.length).to eq 4
      expect(result.first.name).to eq 'Changs Palace'
      expect(result[1].name).to eq 'Destans Polski Sklep'
      expect(result[2].name).to eq 'Sarahs Sunset Side'
      expect(result.last.name).to eq 'Kons Gaff'
    end
    it "should return a 'no rooms available' message if no rooms were found" do
      result = subject.find_rooms_within_range("2023-05-06", "2023-05-08")
      expect(result).to eq "Sorry, there is no rooms available within the range selected."
    end
  end

  context ".create method" do
    it "should add a new availability" do
      new_availability = Availability.new
      new_availability.date = "2023-05-06"
      subject.create(new_availability)
      result = subject.find("2023-05-06")
      expect(result.id).to eq 6
      expect(result.date).to eq "2023-05-06"
    end
  end

  context ".add_rooms" do
    it "should update the rooms list of an availibility object" do
      roomRepo = RoomRepository.new
      roomRepo.create(room6)
      new_room = roomRepo.find(6)
      subject.add_room(new_room)
      result = subject.find('2023-05-01')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
    end
    it "should update the rooms list of an availability object" do
      roomRepo = RoomRepository.new
      roomRepo.create(room6)
      new_room = roomRepo.find(6)
      subject.add_room(new_room)
      result = subject.find('2023-05-01')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
      result = subject.find('2023-05-02')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
      result = subject.find('2023-05-03')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
    end
    it "should add new availabilities object when they don't already exist" do
      roomRepo = RoomRepository.new
      roomRepo.create(room7)
      new_room = roomRepo.find(6)
      subject.add_room(new_room)
      result = subject.find('2023-05-05')
      expect(result.rooms.last.name).to eq 'Monmons Cozy Castle'
      result = subject.find('2023-05-06')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
      result = subject.find('2023-05-07')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
      result = subject.find('2023-05-08')
      expect(result.rooms.last.name).to eq 'Manhattan Appartment'
      result = subject.find('2023-05-09')
      expect(result).to eq "no rooms available for that date"
    end
    it "should allow " do
      roomRepo = RoomRepository.new
      roomRepo.create(room7)
      new_room = roomRepo.find(6)
      subject.add_room(new_room)
      new_room.available_from = "2023-04-05"
      new_room.available_to = "2023-04-10"
      # allow(new_room).to receive(:available_from) { "2023-04-05" }
      # allow(new_room).to receive(:available_to) { "2023-04-10" }
      subject.add_room(new_room)
      result = subject.find_rooms_within_range("2023-04-05", "2023-04-10")
      expect(result.length).to eq 1
      subject.all
    end
  end
end