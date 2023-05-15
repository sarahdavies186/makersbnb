TRUNCATE TABLE users RESTART IDENTITY CASCADE; -- not sure it would go here.

INSERT INTO users (name, email, password) VALUES ('chang', 'chang@gmail.com', '$2a$12$tGQfiCGpemmxpUmC6fTzNud1bhLaLdHM7hO75Z6dWVzU5gra.Wlgq');
INSERT INTO users (name, email, password) VALUES ('Sarah', 'sarah@gmail.com', '$2a$12$tGQfiCGpemmxpUmC6fTzNud1bhLaLdHM7hO75Z6dWVzU5gra.Wlgq');
INSERT INTO users (name, email, password) VALUES ('Konrad', 'konrad@gmail.com', '$2a$12$tGQfiCGpemmxpUmC6fTzNud1bhLaLdHM7hO75Z6dWVzU5gra.Wlgq');
INSERT INTO users (name, email, password) VALUES ('Monica', 'monmons@gmail.com', '$2a$12$tGQfiCGpemmxpUmC6fTzNud1bhLaLdHM7hO75Z6dWVzU5gra.Wlgq');
INSERT INTO users (name, email, password) VALUES ('Destin', 'destin@gmail.com', '$2a$12$tGQfiCGpemmxpUmC6fTzNud1bhLaLdHM7hO75Z6dWVzU5gra.Wlgq');
-- INSERT INTO users (name, email, password) VALUES ('David', 'david02@example.com', '123');
-- INSERT INTO users (name, email, password) VALUES ('Anna', 'ann_a@example.com', 'abc@xyz');
-- INSERT INTO users (name, email, password) VALUES ('John', 'johnwick@example.com', 'jk123');
-- INSERT INTO users (name, email, password) VALUES ('Buzz', 'lightning@example.com', 'toystory1');
-- INSERT INTO users (name, email, password) VALUES ('McFly', 'martymcfly@example.com', 'back2future');




TRUNCATE TABLE rooms RESTART IDENTITY CASCADE;

INSERT INTO rooms ("name", "description", "price", "available_from", "available_to", "user_id") VALUES
('Changs Palace', 'A modern apartment in the heart of the city', '300', '2023-05-01', '2023-05-03', 1), -- id=1
('Sarahs Sunset Side', 'A beautiful house with ocean views', '200', '2023-05-02', '2023-05-03', 2), -- id=2
('Kons Gaff', 'Studio apartment, no toilet, naked cat included', '20', '2023-05-02', '2023-05-05', 3), --id=3
('Monmons Cozy Castle', 'A charming castle in the countryside', '250', '2023-05-04', '2023-05-05', 4), --id=4
('Destins Polski Sklep', 'You can stay here and put a little shift in, stock some shelves too', '250', '2023-05-01', '2023-05-04', 5); --id=5


TRUNCATE TABLE availabilities RESTART IDENTITY CASCADE;
                                                    -- in case you need to come check:
INSERT INTO availabilities (date) VALUES('2023-05-01'); -- 2 rooms available
INSERT INTO availabilities (date) VALUES('2023-05-02'); -- 4 rooms available
INSERT INTO availabilities (date) VALUES('2023-05-03'); -- 4 rooms available
INSERT INTO availabilities (date) VALUES('2023-05-04'); -- 3 rooms available
INSERT INTO availabilities (date) VALUES('2023-05-05'); -- 2 rooms available


TRUNCATE TABLE availabilities_rooms RESTART IDENTITY;

INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (1, 1);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (2, 1);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (3, 1);

INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (2, 2);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (3, 2);

INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (2, 3);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (3, 3);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (4, 3);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (5, 3);

INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (4, 4);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (5, 4);

INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (1, 5);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (2, 5);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (3, 5);
INSERT INTO availabilities_rooms (availability_id, room_id) VALUES (4, 5);