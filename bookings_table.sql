CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  status text,
  owner_id int,
  room_id int,
  availability_id int,
  user_id int,
  constraint fk_user foreign key(user_id)
  references users(id)
  on delete cascade,
      
  constraint fk_room foreign key(room_id)
  references rooms(id)
  on delete cascade,

  constraint fk_availability foreign key(availability_id)
  references availabilities(id)
  on delete cascade,

  constraint fk_owner foreign key(owner_id)
  references users(id)
  on delete cascade
);