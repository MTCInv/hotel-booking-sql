-- COMP207 hotel assignment
-- Question 1
CREATE TABLE Guests (birth_day DATE, first_name VARCHAR(20), last_name VARCHAR(20), g_id INT, PRIMARY KEY (g_id));
CREATE TABLE Employees (birth_day DATE, first_name VARCHAR(20), last_name VARCHAR(20), e_id INT, PRIMARY KEY (e_id));
CREATE TABLE Rooms (room_type VARCHAR(20), capacity INT, r_id INT, PRIMARY KEY (r_id));
CREATE TABLE Bookings (check_in DATE, check_out DATE, cancelled BOOL, g_id INT, e_id INT, r_id INT, b_id INT, PRIMARY KEY (b_id), FOREIGN KEY (g_id) REFERENCES Guests(g_id), FOREIGN KEY (e_id) REFERENCES Employees(e_id), FOREIGN KEY (r_id) REFERENCES Rooms(r_id));
CREATE TABLE GuestsInBookings (g_id INT, b_id INT, PRIMARY KEY (g_id, b_id), FOREIGN KEY (g_id) REFERENCES Guests(g_id), FOREIGN KEY (b_id) REFERENCES Bookings(b_id));
CREATE TABLE RoomNights (stay_date DATE, price INT, b_id INT, PRIMARY KEY (stay_date, b_id), FOREIGN KEY (b_id) REFERENCES Bookings(b_id));
-- Question 2
INSERT INTO Guests (birth_day, first_name, last_name, g_id) VALUES ('1994-04-18', 'Grace', 'Patel', 6);
INSERT INTO Employees (birth_day, first_name, last_name, e_id) VALUES ('1993-10-07', 'Rita', 'Davies', 5);
INSERT INTO Rooms (room_type, capacity, r_id) VALUES ('Single', 1, 301);
INSERT INTO Bookings (check_in, check_out, cancelled, g_id, e_id, r_id, b_id) VALUES ('2026-11-20', '2026-11-23', FALSE, 6, 5, 301, 20);
INSERT INTO GuestsInBookings (g_id, b_id) VALUES (6, 20);
INSERT INTO RoomNights (stay_date, price, b_id) VALUES ('2026-11-20', 6000, 20), ('2026-11-21', 7000, 20), ('2026-11-22', 6000, 20);
-- Question 3
CREATE VIEW SeptemberArrivalsByDavid (number_of_bookings) AS
SELECT COUNT(*) FROM Bookings
WHERE e_id = 4 AND cancelled = FALSE AND check_in >= '2026-09-01' AND check_in < '2026-10-01';
-- Question 4
CREATE VIEW GuestsOn12September (g_id, first_name, last_name) AS
SELECT DISTINCT G.g_id, G.first_name, G.last_name
FROM Guests G JOIN GuestsInBookings GB ON G.g_id = GB.g_id JOIN Bookings B ON GB.b_id = B.b_id
WHERE B.cancelled = FALSE AND B.check_in <= '2026-09-12' AND B.check_out > '2026-09-12';
-- Question 5
CREATE VIEW AvailableRooms (r_id, room_type, capacity) AS
SELECT R.r_id, R.room_type, R.capacity FROM Rooms R
WHERE R.capacity >= 2 AND NOT EXISTS (
  SELECT * FROM Bookings B WHERE B.r_id = R.r_id AND B.cancelled = FALSE
  AND B.check_in < '2026-09-15' AND B.check_out > '2026-09-12');
-- Question 6
CREATE VIEW RoomTurnovers (r_id, turnover_date) AS
SELECT DISTINCT B1.r_id, B1.check_out
FROM Bookings B1 JOIN Bookings B2 ON B1.r_id = B2.r_id AND B1.check_out = B2.check_in AND B1.b_id <> B2.b_id
WHERE B1.cancelled = FALSE AND B2.cancelled = FALSE
AND B1.check_out >= '2026-09-01' AND B1.check_out <= '2026-09-30';
-- Question 7
CREATE VIEW SeptemberGuestActivity (g_id, number_of_bookings, number_of_nights, is_employee) AS
SELECT B.g_id, COUNT(*), SUM(DATEDIFF(B.check_out, B.check_in)),
  EXISTS (SELECT * FROM Guests G JOIN Employees E ON G.birth_day = E.birth_day AND G.first_name = E.first_name AND G.last_name = E.last_name WHERE G.g_id = B.g_id)
FROM Bookings B
WHERE B.cancelled = FALSE AND B.check_in >= '2026-09-01' AND B.check_in < '2026-10-01'
GROUP BY B.g_id;
-- Question 8
-- helper: non-cancelled bookings clipped to [2026-09-01, 2026-10-01]
CREATE VIEW ClippedSeptemberBookings (r_id, clip_from, clip_until) AS
SELECT r_id, GREATEST(check_in, '2026-09-01'), LEAST(check_out, '2026-10-01')
FROM Bookings
WHERE cancelled = FALSE AND check_in < '2026-10-01' AND check_out > '2026-09-01';
-- helper: dates where an occupied period begins (no booking of the room ends on or spans that date)
CREATE VIEW SeptemberPeriodStarts (r_id, occupied_from) AS
SELECT DISTINCT C.r_id, C.clip_from FROM ClippedSeptemberBookings C
WHERE NOT EXISTS (SELECT * FROM ClippedSeptemberBookings C2
  WHERE C2.r_id = C.r_id AND C2.clip_from < C.clip_from AND C2.clip_until >= C.clip_from);
CREATE VIEW RoomOccupiedPeriods (r_id, occupied_from, occupied_until, occupied_nights) AS
SELECT S.r_id, S.occupied_from, MIN(C.clip_until), DATEDIFF(MIN(C.clip_until), S.occupied_from)
FROM SeptemberPeriodStarts S JOIN ClippedSeptemberBookings C ON C.r_id = S.r_id AND C.clip_until > S.occupied_from
WHERE NOT EXISTS (SELECT * FROM ClippedSeptemberBookings C3
  WHERE C3.r_id = C.r_id AND C3.clip_from <= C.clip_until AND C3.clip_until > C.clip_until)
GROUP BY S.r_id, S.occupied_from;
