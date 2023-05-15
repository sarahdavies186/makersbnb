DROP TABLE IF EXISTS availabilities;

CREATE TABLE availabilities (
id SERIAL PRIMARY KEY,
date DATE
);

DROP TABLE IF EXISTS users;

CREATE TABLE users (
id SERIAL PRIMARY KEY,
name TEXT,
email VARCHAR(255),
password TEXT
);

DROP TABLE IF EXISTS rooms;

CREATE TABLE rooms (
id SERIAL PRIMARY KEY,
name TEXT,
description TEXT,
price INT,
available_from DATE,
available_to DATE,
user_id INT,
CONSTRAINT fk_user FOREIGN KEY(user_id)
REFERENCES users(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS availabilities_rooms;

CREATE TABLE availabilities_rooms (
  availability_id INT,
  room_id INT,
  CONSTRAINT fk_availability FOREIGN KEY(availability_id) REFERENCES availabilities(id) ON DELETE CASCADE,
  CONSTRAINT fk_room FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  PRIMARY KEY (availability_id, room_id)
);
