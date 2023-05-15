require "booking_repository"
require "availability_repository"
require "booking"

def reset_bookings_table
  seed_sql = File.read('spec/seeds/bookings_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test', password: "a"})
  connection.exec(seed_sql)
end
  
describe BookingRepository do
  before(:each) do 
    reset_bookings_table
  end
  after { reset_table }

  context "#all method" do 
    it "All method functions " do 
      bookings = subject.all
      expect(bookings.length).to eq 5
      expect(bookings[0].id).to eq 1
      expect(bookings[0].status).to eq "Pending"
      expect(bookings[0].owner_id).to eq 1
      expect(bookings[0].room_id).to eq 1
      expect(bookings[0].availability_id).to eq 1
      expect(bookings[0].user_id).to eq 4
    end 
  end

  context "#all_request_received" do
    it "should return all request an owner has received" do
      result = subject.all_received(1)
      expect(result.length).to eq 3
      expect(result.first.id).to eq 1
      expect(result[1].id).to eq 2
      expect(result.last.id).to eq 3
    end
  end

  context "#all_request_sent" do
    it "should returns all request the user has received" do
      result = subject.all_sent(2)
      expect(result.length).to eq 2
      expect(result.first.id).to eq 2
      expect(result.last.id).to eq 5
    end
  end

  context "#find method" do 
    it "should return a single booking given an id" do 
      result = subject.find(5)
      expect(result.id).to eq 5
      expect(result.status).to eq "Pending"
      expect(result.owner_id).to eq 3
      expect(result.room_id).to eq 3
      expect(result.availability_id).to eq 5
      expect(result.user_id).to eq 2
    end 
    it "should return a not found message if request was not found" do 
      result = subject.find(6)
      expect(result).to eq "The request could not be found"
    end 
  end 

  context "#add method" do
    it "should add a new booking request to the database" do
      booking = Booking.new
      booking.owner_id = 5
      booking.room_id = 5
      booking.availability_id = 4
      booking.user_id = 1
      subject.add(booking)
      result = subject.find(6)
      expect(result.id).to eq 6
      expect(result.status).to eq "Pending"
    end
  end

  context "#update method" do
    it "should update a booking request" do
      booking = subject.find(1)
      booking.availability_id = 5
      subject.update(booking)
      result = subject.find(1)
      expect(result.id).to eq 1
      expect(result.availability_id).to eq 5
    end
  end

  context "#request_booking method" do
    it "should add a booking to the database if it's a new one" do
      booking = Booking.new
      booking.owner_id = 5
      booking.room_id = 5
      booking.availability_id = 4
      booking.user_id = 1
      subject.request_booking(booking)
      result = subject.find(6)
      expect(result.id).to eq 6
      expect(result.status).to eq "Pending"
    end
  end
  context "#request_booking method" do
    it "should update a booking to the database if already exist" do
      booking = Booking.new
      booking.owner_id = 5
      booking.room_id = 5
      booking.availability_id = 4
      booking.user_id = 1
      subject.request_booking(booking)
      result = subject.find(6)
      expect(result.id).to eq 6
      expect(result.status).to eq "Pending"
    end
  end

  context "#confirm method" do 
    it "should confirm a booking given an id & reject the rest" do 
      subject.confirm_booking(3)
      expect(subject.find(3).status).to eq "Confirmed"
      expect(subject.find(2).status).to eq "Denied"
      expect(subject.find(1).status).to eq "Denied"
    end 
    it "should delete the availability for the confirmed room" do 
      subject.confirm_booking(3)
      repo = AvailabilityRepository.new
      result = repo.find("2023-05-01")
      result.rooms.each do | room |
        expect(room.id).not_to eq 1
      end
    end 
  end

  context "#deny_request method" do 
    it "should deny a single request" do 
      subject.deny_request(1)
      expect(subject.find(1).status).to eq "Denied"
      expect(subject.find(2).status).to eq "Pending"
      expect(subject.find(3).status).to eq "Pending"
    end 
  end 
end 