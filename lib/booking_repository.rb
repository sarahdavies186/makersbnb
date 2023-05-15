# require_relative "./database_connection"
require_relative "./booking"

class BookingRepository

  def all
    sql = 'SELECT * FROM bookings;'
    result = DatabaseConnection.exec_params(sql, [])
    bookings = []
    result.each do |record|
      bookings << _record_to_booking(record)
    end
    return bookings
  end

  def all_received(owner_id)
    sql = 'SELECT * FROM bookings WHERE owner_id = $1'
    return _selected_requests(sql, owner_id)
  end

  def all_sent(user_id)
    sql = 'SELECT * FROM bookings WHERE user_id = $1'
    return _selected_requests(sql, user_id)
  end
  
  def find(id)
    sql = 'SELECT * FROM bookings WHERE id = $1;'
    result = DatabaseConnection.exec_params(sql, [id])
    return "The request could not be found" if result.ntuples.zero?
    return _record_to_booking(result[0])
  end

  def request_booking(booking)
    booking.id.nil? ? add(booking) : update(booking)
  end

  def add(booking)
    sql = "INSERT INTO bookings (status, owner_id, room_id, availability_id, user_id)
           VALUES($1, $2, $3, $4, $5);"
    params = ["Pending", booking.owner_id, booking.room_id, booking.availability_id, booking.user_id]
    DatabaseConnection.exec_params(sql, params)
  end

  def update(booking)
    sql = "UPDATE bookings SET availability_id = $1 WHERE id = $2;"
    params = [booking.availability_id, booking.id]
    DatabaseConnection.exec_params(sql, params)
  end

  def confirm_booking(id)
    booking = find(id)
    params = [booking.availability_id,booking.room_id]
    _give_status_denied(params)
    _give_status_confirmed(id)
    _remove_availability_to_room(params)
  end

  def deny_request(id)
    sql = "UPDATE bookings SET status = 'Denied' WHERE id = $1"
    DatabaseConnection.exec_params(sql, [id])
  end

  private

  def _record_to_booking(record)
    booking = Booking.new
    booking.id = record["id"].to_i
    booking.status = record["status"]
    booking.owner_id = record["owner_id"].to_i
    booking.room_id = record["room_id"].to_i
    booking.availability_id = record["availability_id"].to_i
    booking.user_id = record["user_id"].to_i
    return booking
  end

  def _selected_requests(sql, id)
    result = DatabaseConnection.exec_params(sql, [id])
    bookings = []
    result.each do |record|
      bookings << _record_to_booking(record)
    end
    return bookings
  end

  def _give_status_denied(params)
    sql = "UPDATE bookings SET status = 'Denied' WHERE availability_id = $1 AND room_id = $2;" 
    DatabaseConnection.exec_params(sql, params) 
  end

  def _give_status_confirmed(id)
    sql = "UPDATE bookings set status = 'Confirmed' WHERE id = $1;"
    DatabaseConnection.exec_params(sql, [id])
  end

  def _remove_availability_to_room(params)
    sql = "DELETE FROM availabilities_rooms WHERE availability_id = $1 AND room_id = $2;"
    DatabaseConnection.exec_params(sql, params) 
  end
end 