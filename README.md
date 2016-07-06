# bibliow

This is a small learning project (go web development). 
Its purpose is to administer the items borrowed from library. The backend is SQLite3 database.

The DB has only one table called "items". The operations on this table are standard: add, edit and remove.
There's also import functionality where multiple items can be added by parsing the specially formatted 
CSV files.

The application is started as "bibliow $sqlite-file-name". 

If $sqlite-file-name does not exist, it is created and database is initialized (tabled is created,
triggers and indexes also).

The admin web interface is started in browser as "http://localhost:5000".
