require_relative "./availability"
require_relative "./room"
require "date"

class AvailabilityRepository

  def all
    sql = 'SELECT * FROM availabilities;'
    result = DatabaseConnection.exec_params(sql, [])
    sorted_array = _array_of_availabilities(result).sort_by {|availability| availability.date }

    return sorted_array
  end

  def find(date)
    sql = 'SELECT * FROM availabilities WHERE date = $1;'
    result = DatabaseConnection.exec_params(sql, [date])

    return "no rooms available for that date" if result.ntuples.zero?
    return _record_to_date(result[0])
  end

  def find_by_id(id)
    sql = 'SELECT * FROM availabilities WHERE id = $1;'
    result = DatabaseConnection.exec_params(sql, [id])

    return "no availabality for that date" if result.ntuples.zero?
    record = result[0]
    availability = Availability.new
    availability.id = record["id"].to_i
    availability.date = record["date"]

    return availability
  end 

  def find_by_room(id)
    sql = _SQL_query_for_find_by_rooms
    result = DatabaseConnection.exec_params(sql, [id])

    return "this room has no availabilities" if result.ntuples.zero?
    return _array_of_availabilities(result)
  end

  def find_rooms_within_range(from, to)
    start_date, end_date = Date.parse(from), Date.parse(to)

    range_of_availabilities = _get_availabilities(start_date, end_date)
    
    return "Sorry, there is no rooms available within the range selected." if range_of_availabilities.empty?
    return _rooms_for_range(range_of_availabilities)
  end

  def create(availability)
    sql = 'INSERT INTO availabilities (date) VALUES($1)'
    sql_params = [availability.date]
    DatabaseConnection.exec_params(sql, sql_params)
  end

  def add_room(room)
    start_date, end_date = Date.parse(room.available_from), Date.parse(room.available_to)

    (start_date..end_date).each do |date|
      search_result = find(date)
      if search_result == "no rooms available for that date"
        new_date = Date.new(date.year, date.month, date.day)
        _create_new_availability_with(new_date)
        _add_room_to_new_availability(new_date, room)

      else
        search_result.rooms << room
        _update_join_table_for_add_room(search_result.id, room.id)
      end
    end
  end

  private 

  # --------------
  # SQL QUERIES
  # --------------

  def _SQL_query_for_get_rooms
    return 'SELECT rooms.id AS "roomsid" , rooms.name, rooms.description, rooms.price,
                   rooms.available_from, rooms.available_to, rooms.user_id,
                   availabilities.id, availabilities.date
              FROM rooms 
              JOIN availabilities_rooms 
                ON room_id = rooms.id
              JOIN availabilities 
                ON availability_id = availabilities.id
             WHERE availabilities.id = $1;'
  end

  def _SQL_query_for_find_by_rooms
    return 'SELECT availabilities.id, availabilities.date, rooms.id AS "roomsid" , rooms.name, rooms.description, rooms.price,
                   rooms.available_from, rooms.available_to, rooms.user_id
              FROM availabilities 
              JOIN availabilities_rooms 
                ON availability_id = availabilities.id
              JOIN rooms 
                ON room_id = rooms.id
             WHERE rooms.id = $1;'
  end

  # --------------
  # SHARED METHODS
  # --------------

  def _array_of_availabilities(sql_result)
    availabilities = []
    sql_result.each do |record|
      availabilities << _record_to_date(record)
    end
    return availabilities
  end

  def _record_to_date(record)
    availability = Availability.new
    availability.id = record["id"].to_i
    availability.date = record["date"]
    availability.rooms = _get_rooms_for(availability.id)
    return availability
  end

  def _get_rooms_for(availability_id)
    sql = _SQL_query_for_get_rooms
    result = DatabaseConnection.exec_params(sql, [availability_id])
    
    rooms = []
    result.each do |record|
      rooms << _record_to_room(record)
    end
    return rooms
  end

  def _record_to_room(record)
    room = Room.new
    room.id = record["roomsid"]
    room.name = record["name"]
    room.description = record["description"]
    room.price = record["price"]
    room.available_from = record["available_from"]
    room.available_to = record["available_to"]
    room.user_id = record["user_id"]
    return room
  end

  # --------------------------------------
  # FIND_ROOMS_WITHIN_RANGE METHOD METHODS
  # --------------------------------------

  def _get_availabilities(from, to)
    range_of_availabilities = []
    (from..to).each do |date|
      availability = find(date)
      unless availability ==  "no rooms available for that date"
        range_of_availabilities << availability
      end
    end
    return range_of_availabilities
  end

  def _rooms_for_range(range)
    rooms = []
    range.each do |availability|
      rooms << availability.rooms
    end
    return rooms.flatten.uniq  { |room| room.id  }
  end

  # ---------------------
  # CREATES METHOD METHODS
  # ---------------------

  def _update_join_table_for_add_room(availability_id, room_id)
    sql = 'INSERT INTO availabilities_rooms (availability_id, room_id) VALUES($1, $2)'
    sql_params = [availability_id, room_id]
    DatabaseConnection.exec_params(sql, sql_params)
  end

  # -----------------------
  # ADD_ROOM METHOD METHODS
  # -----------------------

  def _create_new_availability_with(new_date)
    availability = Availability.new
    availability.date = new_date
    create(availability)
  end

  def _add_room_to_new_availability(date, room)
    new_availability = find(date)
    new_availability.rooms << room
    _update_join_table_for_add_room(new_availability.id, room.id)
  end

end