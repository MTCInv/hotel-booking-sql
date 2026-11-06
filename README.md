# Hotel Booking SQL

MySQL solutions for a hotel database assignment (COMP207). The single file `hotel.sql` creates the schema, inserts sample rows, and defines the views asked for in questions 1–8.

## Schema

| Table | Purpose |
|-------|---------|
| Guests | guest id, name, date of birth |
| Employees | staff id, name, date of birth |
| Rooms | room id, type, capacity |
| Bookings | stay window, cancelled flag, guest/employee/room FKs |
| GuestsInBookings | many-to-many guests on a booking |
| RoomNights | nightly price for a booking |

## Questions covered

1. **Create tables** with primary and foreign keys.
2. **Insert** one guest, employee, room, booking, guest-in-booking and room-night rows.
3. **SeptemberArrivalsByDavid** — count of non-cancelled September check-ins handled by employee 4.
4. **GuestsOn12September** — guests staying on 2026-09-12.
5. **AvailableRooms** — rooms with capacity ≥ 2 free for 12–15 Sep 2026.
6. **RoomTurnovers** — dates in September where one booking checks out and another checks in on the same room.
7. **SeptemberGuestActivity** — per guest: booking count, nights, and whether they also appear as an employee.
8. **RoomOccupiedPeriods** — continuous occupied stretches in September (with helper views `ClippedSeptemberBookings` and `SeptemberPeriodStarts`).

## Run it

Needs MySQL 8 (uses `GREATEST` / `LEAST` / `DATEDIFF` / `EXISTS`).

```bash
mysql -u root -p < hotel.sql
```

If you have the public test dataset separately, load that first, then run this file (or run only the view definitions after the schema is already present).

## Notes

- Assessed coursework. Prefer a **private** GitHub repo unless the module allows public solutions.
- Dates in the sample inserts use 2026 to match the assignment year.
