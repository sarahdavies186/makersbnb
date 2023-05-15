require_relative 'room'

class RoomRepository
  def initializes
  end

  def all
    @rooms = []

    sql = "SELECT * FROM rooms;"
    result_set = DatabaseConnection.exec_params(sql, [])

    result_set.each do |row|
      room = Room.new

      room.id = row['id'].to_i
      room.name = row['name']
      room.description = row['description']
      room.price = row['price'].to_i
      room.available_from = row['available_from']
      room.available_to = row['available_to']
      room.user_id = row['user_id'].to_i

      @rooms << room
    end

    return @rooms
  end

  def create(room)
    sql =
      "INSERT INTO rooms (name, description, price, available_from, available_to, user_id) VALUES ($1, $2, $3, $4, $5, $6);"
    result_set =
      DatabaseConnection.exec_params(
        sql,
        [room.name, room.description, room.price, room.available_from, room.available_to, room.user_id]
      )

    return room
  end

  def find(id)
    sql = "SELECT * FROM rooms WHERE id = $1;"
    result_set = DatabaseConnection.exec_params(sql, [id])

    room = Room.new
    room.id = result_set[0]['id'].to_i
    room.name = result_set[0]['name']
    room.description = result_set[0]['description']
    room.price = result_set[0]['price'].to_i
    room.available_from = result_set[0]['available_from']
    room.available_to = result_set[0]['available_to']
    room.user_id = result_set[0]['user_id'].to_i

    return room
  end
end
