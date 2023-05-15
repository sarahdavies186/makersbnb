require 'room_repository'
require 'room'

def reset_rooms_table
  seed_sql = File.read("spec/seeds/makersbnb_seeds.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test" })
  connection.exec(seed_sql)
end

describe RoomRepository do
  before(:each) { reset_rooms_table }

  context '#all' do
    it 'returns correct amount of rooms in the database' do
      result = subject.all
      expect(result.length).to eq(5)
    end

    it 'returns correct room data' do
      repo = RoomRepository.new
      rooms = repo.all
   
      expect(rooms[0].id).to eq(1)
      expect(rooms[0].name).to eq('Changs Palace')
      expect(rooms[0].description).to eq('A modern apartment in the heart of the city')
      expect(rooms[0].price).to eq(300)
      expect(rooms[0].available_from).to eq('2023-05-01')
      expect(rooms[0].available_to).to eq('2023-05-03')
      expect(rooms[0].user_id).to eq(1)
    end

    it 'returns correct room data' do
      repo = RoomRepository.new
      rooms = repo.all
      
      expect(rooms[3].id).to eq(4)
      expect(rooms[3].name).to eq('Monmons Cozy Castle')
      expect(rooms[3].description).to eq('A charming castle in the countryside')
      expect(rooms[3].price).to eq(250)
      expect(rooms[3].available_from).to eq('2023-05-04')
      expect(rooms[3].available_to).to eq('2023-05-05')
      expect(rooms[3].user_id).to eq(4)
    end
  end

  context '#create' do
    it 'creates a new room' do
      repo = RoomRepository.new
      room = Room.new
      room.name = "Leos Beach House"
      room.description = "A small beach house right next to the ocean"
      room.price = 100
      room.available_from = "2023-04-11"
      room.available_to = "2023-04-13"
      room.user_id = 1
      repo.create(room)

      rooms = repo.all

      expect(rooms.length).to eq(6)
      expect(rooms.last.name).to eq('Leos Beach House')
      expect(rooms.last.description).to eq('A small beach house right next to the ocean')
      expect(rooms.last.price).to eq(100)
      expect(rooms.last.available_from).to eq('2023-04-11')
      expect(rooms.last.available_to).to eq('2023-04-13')
      expect(rooms.last.user_id).to eq(1)
    end
  end

  context '#find' do
    it 'returns data for correct room' do
      repo = RoomRepository.new
      room = repo.find(1)

      expect(room.id).to eq(1)
      expect(room.name).to eq('Changs Palace')
    end
  end
  
end
