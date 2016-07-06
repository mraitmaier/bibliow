package main

import (
	"fmt"
	"database/sql"
	_ "github.com/mattn/go-sqlite3"
)

const (
	sqlite_create_tbl_qry = `CREATE TABLE IF NOT EXISTS items (
        title TEXT NOT NULL, 
        author TEXT DEFAULT "",
        language TEXT DEFAULT "UNK",
        year TEXT DEFAULT "XXXX",
        signature TEXT DEFAULT "",
        type TEXT DEFAULT "UNK",
        library TEXT DEFAULT "unknown library",
        invnum TEXT NOT NULL UNIQUE, -- check unque constraint!
        date TEXT NOT NULL,
        publisher TEXT DEFAULT "",
        isbn TEXT DEFAULT "",
        translator TEXT DEFAULT "",
        origtitle TEXT DEFAULT "",
        notes TEXT DEFAULT "",
        created TEXT DEFAULT CURRENT_TIMESTAMP,
        modified TEXT DEFAULT CURRENT_TIMESTAMP ); 

    CREATE TRIGGER IF NOT EXISTS update_modified_trigger AFTER UPDATE ON items FOR EACH ROW
        BEGIN 
            UPDATE items SET modified = current_timestamp WHERE rowid = old.rowid;
        END;

    CREATE INDEX IF NOT EXISTS lang_index ON items(language);
    CREATE INDEX IF NOT EXISTS year_index ON items(year);
    CREATE INDEX IF NOT EXISTS type_index ON items(type); `

	sqlite_insert_qry = `INSERT OR IGNORE INTO 
                items (title, author, type, year, date, language, signature, library, invnum, 
                    publisher, isbn, translator, origtitle, notes)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);`

	sqlite_select_all_qry = "SELECT rowid, * FROM items;"

	sqlite_update_qry = `UPDATE items
    SET title=?, author=?, type=?, year=?, date=?, language=?, signature=?, library=?, invnum=?,
        publisher=?, isbn=?, translator=?, origtitle=?, notes=? WHERE rowid=?;`

	sqlite_remove_qry = `DELETE FROM items WHERE rowid=?;`
)

// SQLiteOpen opens the SQLite database file.
func SQLiteOpen(fname string) (*sql.DB, error) { return sql.Open("sqlite3", fname) }

// SQLiteClose simply closes the DB connection..
func SQLiteClose(conn *sql.DB) {
	if conn != nil {
		conn.Close()
	}
}

// SQLiteInsert inserts a new library item into DB.
func SQLiteInsert(conn *sql.DB, i *Item) error {

	tx, err := conn.Begin()
	if err != nil {
		return err
	}

	s, err := tx.Prepare(sqlite_insert_qry)
	if err != nil {
		return err
	}
	defer s.Close()

	_, err = s.Exec(i.Title, i.Author, i.Type, i.Year, i.Date, i.Language, i.Signature, i.Library, i.InvNumber,
		i.Publisher, i.ISBN, i.Translator, i.OrigTitle, i.Notes)
	if err != nil {
		return err
	}
	return tx.Commit()
}

// SQLiteInsertMany inserts a bunch of new library items into DB. Returns the list of actually inserted items 
// error status
func SQLiteInsertMany(conn *sql.DB, items []*Item)  ([]*Item, error) {

	tx, err := conn.Begin()
	if err != nil {
		return  nil, err
	}

	s, err := tx.Prepare(sqlite_insert_qry)
	if err != nil {
		return nil, err
	}
	defer s.Close()

    var inserted []*Item // a list of actually inserted items
	for _, i := range items {
        result, err := s.Exec(i.Title, i.Author, i.Type, i.Year, i.Date, i.Language, i.Signature, i.Library, i.InvNumber,
			i.Publisher, i.ISBN, i.Translator, i.OrigTitle, i.Notes)
        if err != nil {
			return  nil, err
		}
        // examine if any DB rows were affected
        affected, _ := result.RowsAffected()
        if affected > 0 {
            inserted = append(inserted, i)
        }
	}
	return inserted, tx.Commit()
}

// SQLiteCount returns the number of records in the DB.
func SQLiteCount(conn *sql.DB) (num int, err error) {

	tx, err := conn.Begin()
    err = tx.QueryRow("SELECT Count(*) FROM items;").Scan(&num)
	if err != nil {
		return -1, err
	}
	return
}

// SQLiteFetchAll retrieves all library items from DB.
func SQLiteFetchAll(conn *sql.DB) (items []*Item, err error) {
	return SQLiteFetchMany(conn, sqlite_select_all_qry)
}

// SQLiteFetchAny retrieves all library items from DB that matches a query string.
func SQLiteFetchAny(conn *sql.DB, qry string) (items []*Item, err error) {

    // this is a bit ugly, but it'll do for now...
    sql := fmt.Sprintf(`SELECT rowid, * FROM items WHERE title LIKE '%%%s%%' OR
                        author LIKE '%%%s%%' OR language LIKE '%%%s%%' OR year LIKE '%%%s%%' OR
                        signature LIKE '%%%s%%' OR type LIKE '%%%s%%' OR library LIKE '%%%s%%' OR
                        invnum LIKE '%%%s%%' OR publisher LIKE '%%%s%%' OR isbn LIKE '%%%s%%' OR
                        translator LIKE '%%%s%%' OR origtitle LIKE '%%%s%%' OR notes LIKE '%%%s%%';`,
                        qry, qry, qry, qry, qry, qry, qry, qry, qry, qry, qry, qry, qry)
    rows, err := conn.Query(sql)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

	for rows.Next() {
		i := NewItem()
		rows.Scan(&i.ID, &i.Title, &i.Author, &i.Language, &i.Year, &i.Signature, &i.Type,
			&i.Library, &i.InvNumber, &i.Date, &i.Publisher, &i.ISBN, &i.Translator, &i.OrigTitle,
			&i.Notes, &i.Created, &i.Modified)
		items = append(items, i)
	}
	return items, nil
}

// SQLiteFetchFiltered retrieves all library items from DB that matches a query string.
func SQLiteFetchFiltered(conn *sql.DB, key, val string) (items []*Item, err error) {

    rows, err := conn.Query(fmt.Sprintf(`SELECT rowid, * FROM items WHERE %s LIKE '%%%s%%' ;`, key, val))
    if err != nil {
        return nil, err
    }
    defer rows.Close()

	for rows.Next() {
		i := NewItem()
		rows.Scan(&i.ID, &i.Title, &i.Author, &i.Language, &i.Year, &i.Signature, &i.Type,
			&i.Library, &i.InvNumber, &i.Date, &i.Publisher, &i.ISBN, &i.Translator, &i.OrigTitle,
			&i.Notes, &i.Created, &i.Modified)
		items = append(items, i)
	}
	return items, nil

}
// SQLiteFetchMany is a general GET function that fetches and returns the list of found items.
func SQLiteFetchMany(conn *sql.DB, qry string) (items []*Item, err error) {
	//
	rows, err := conn.Query(qry)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		i := NewItem()
		rows.Scan(&i.ID, &i.Title, &i.Author, &i.Language, &i.Year, &i.Signature, &i.Type,
			&i.Library, &i.InvNumber, &i.Date, &i.Publisher, &i.ISBN, &i.Translator, &i.OrigTitle,
			&i.Notes, &i.Created, &i.Modified)
		items = append(items, i)
	}
	return items, nil
}

// SQLiteFetchOne is a general GET function that fetches and returns exactly one item.
func SQLiteFetchOne(conn *sql.DB, qry string) (i *Item, err error) {

	i = NewItem()
	err = conn.QueryRow(qry).Scan(&i.ID, &i.Title, &i.Author, &i.Language, &i.Year, &i.Signature, &i.Type,
		&i.Library, &i.InvNumber, &i.Date, &i.Publisher, &i.ISBN, &i.Translator, &i.OrigTitle,
		&i.Notes, &i.Created, &i.Modified)
	return
}

// SQLiteUpdate modifies an existing library item in DB.
func SQLiteUpdate(conn *sql.DB, i *Item) error {

	tx, err := conn.Begin()
	if err != nil {
		return err
	}

	s, err := tx.Prepare(sqlite_update_qry)
	if err != nil {
		return err
	}
	defer s.Close()

	_, err = s.Exec(i.Title, i.Author, i.Type, i.Year, i.Date, i.Language, i.Signature, i.Library, i.InvNumber,
		i.Publisher, i.ISBN, i.Translator, i.OrigTitle, i.Notes, i.ID)
	if err != nil {
		return err
	}
	return tx.Commit()
}

// SQLiteUpdateMany modifies a bunch of library items in DB. Returns a list of actually updated DB rows and
// and an error status. Note that existing duplicate items are simply ignored.
func SQLiteUpdateMany(conn *sql.DB, items []*Item) ([]*Item, error) {

	tx, err := conn.Begin()
	if err != nil {
		return nil, err
	}

	s, err := tx.Prepare(sqlite_update_qry)
	if err != nil {
		return nil, err
	}
	defer s.Close()

    var inserted []*Item // a list of actually updated items
	for _, i := range items {

        result, err := s.Exec(i.Title, i.Author, i.Type, i.Year, i.Date, i.Language, i.Signature, i.Library, i.InvNumber,
			i.Publisher, i.ISBN, i.Translator, i.OrigTitle, i.Notes, i.ID)
		if err != nil {
			return nil, err
		}
        // examine if any DB rows were affected
        affected, _ := result.RowsAffected()
        if affected > 0 {
            inserted = append(inserted, i)
        }
	}
	return inserted, tx.Commit()
}

// SQLiteDelete removes an existing library item from DB.
func SQLiteDelete(conn *sql.DB, id string) error {

	tx, err := conn.Begin()
	if err != nil {
		return err
	}

	s, err := tx.Prepare(sqlite_remove_qry)
	if err != nil {
		return err
	}
	defer s.Close()

	_, err = s.Exec(id)
	if err != nil {
		return err
	}
	return tx.Commit()
}

// SQLiteCreateTable creates the basic DB table when app is started (if it does not exist, of course...)
func SQLiteCreateTable(conn *sql.DB) error {
	//
	if _, err := conn.Exec(sqlite_create_tbl_qry); err != nil {
		return err
	}

	tx, err := conn.Begin()
	if err != nil {
		return err
	}
	return tx.Commit()
}
