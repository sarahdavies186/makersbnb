TRUNCATE TABLE bookings RESTART IDENTITY; 

INSERT INTO bookings (status, owner_id, room_id, availability_id, user_id) VALUES ('Pending', 1, 1, 1, 4);

INSERT INTO bookings (status, owner_id, room_id, availability_id, user_id) VALUES ('Pending', 1, 1, 1, 2);

INSERT INTO bookings (status, owner_id, room_id, availability_id, user_id) VALUES ('Pending', 1, 1, 1, 3);

INSERT INTO bookings (status, owner_id, room_id, availability_id, user_id) VALUES ('Pending', 2, 2, 2, 1);

INSERT INTO bookings (status, owner_id, room_id, availability_id, user_id) VALUES ('Pending', 3, 3, 5, 2);