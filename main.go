package main

import (
	"database/sql"
	"fmt"
	"github.com/gorilla/context"
	"github.com/gorilla/mux"
	"html/template"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

const (
	// DefWebRoot defines the root path for web-related stuff: templates, static contents...
	DefWebRoot string = "."
)

func main() {

	if len(os.Args) < 2 {
		usage()
		return
	}
	dbFname := os.Args[1]

	var err error

	// init app configuration
	cfg := &Cfg{
		DBConn:    nil,
		templates: nil,
        ErrMsg: "",
	}
	// Open DB
	if cfg.DBConn, err = SQLiteOpen(dbFname); err != nil {
		fmt.Printf("FATAL: %q\n", err.Error())
		return
	}
	defer SQLiteClose(cfg.DBConn)
	fmt.Printf("Database (SQLite) opened: %q.\n", dbFname)

	if err = initDB(cfg.DBConn); err != nil {
		fmt.Printf("FATAL: %q\n", err.Error())
		return
	}
	fmt.Println("Database initialized.")

	// now start the web server
    fmt.Println("Serving on 'http://localhost:5000'...")
	if err = webStart(cfg, DefWebRoot); err != nil {
		fmt.Printf("FATAL: web server cannot be started: %s\n", err.Error())
		return
	}
}

// Cfg is application global configuration struct.
type Cfg struct {

	// DB connection
	DBConn *sql.DB
	//
	templates *template.Template
	//
	//log *Logger
    // error message (when needed...)
    ErrMsg string
}

//
func initDB(conn *sql.DB) error {
	//
	if err := SQLiteCreateTable(conn); err != nil {
		return err
	}
	return nil
}

//
func usage() {
	fmt.Println("Usage:")
	fmt.Println()
	fmt.Println("\tbiblio  <SQLite_DB_name> <COBISS_CSV_fname>")
	fmt.Println()
	fmt.Println("  <SQLite_DB_name>   - a path to SQLite database (it's just a file...)")
	fmt.Println("  Parameter is mandatory.")
}

// The webStart function actually starts the web application.
func webStart(cfg *Cfg, wwwpath string) (err error) {

	// register handler functions
	registerHandlers(cfg)

	// handle static files
	path := filepath.Join(wwwpath, "static")
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir(path))))

	//web page templates, with defined additional functions
	funcs := template.FuncMap{
		"add":     func(x, y int) int { return x + y },
		"length":  func(list []string) int { return len(list) },
		"totitle": func(s string) string { return strings.Title(s) },
		"toupper": func(s string) string { return strings.ToUpper(s) },
		"tolower": func(s string) string { return strings.ToLower(s) }}
	t := filepath.Join(wwwpath, "templates", "*.tpl")
	cfg.templates = template.Must(template.New("").Funcs(funcs).ParseGlob(t))

	// finally, start web server, we're using HTTP
	http.ListenAndServe(":5000", context.ClearHandler(http.DefaultServeMux))
	fmt.Println("INFO Web server up & running")
	return nil
}

func registerHandlers(cfg *Cfg) {

	r := mux.NewRouter()
	r.Handle("/", biblioHandler(cfg))
	r.Handle("/index", biblioHandler(cfg))
	r.Handle("/biblio", biblioHandler(cfg))
	r.Handle("/biblio/{id}/{cmd}", biblioHandler(cfg))
	r.Handle("/search", searchHandler(cfg))
	r.Handle("/import", importHandler(cfg))
	r.Handle("/error", errorHandler(cfg))
	/*
		r.Handle("/license", licHandler(cfg))
	*/
	r.Handle("/err404", err404Handler(cfg))
	r.NotFoundHandler = err404Handler(cfg)
	http.Handle("/", r) // this must be the last line in func...
}

// Aux function that renders the page (template!) with given (template) name.
// Input parameters are:
// - name - name of the template to render
// - web  - ptr to ad-hoc web struct that is used by template to fill in the data on page
// - aa   - pointer to appinfo instance
// - w    - the ResponseWriter instance
// - r    - ptr to the (HTTP) Request instance
func renderPage(name string, web interface{}, cfg *Cfg, w http.ResponseWriter, r *http.Request) error {

	var err error
	if err = cfg.templates.ExecuteTemplate(w, name, web); err != nil {
		//Errorf(cfg.log, "Cannot display %q page, redirecting to 404", name)
		http.Redirect(w, r, "/err404", http.StatusFound)
	}
	//Infof(cfg.log, "Displaying %q page, everything OK", name)
	return err
}

// This is the main page handler function.
func biblioHandler(cfg *Cfg) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		var err error
        cfg.ErrMsg = "" // reset the page error message

		switch r.Method {

		case "GET":
			if err = biblioGetHandler("", w, r, cfg); err != nil {
				fmt.Printf("ERROR Biblio HTTP GET %q\n", err.Error())
			}

		case "POST":
			if err = biblioPostHandler(w, r, cfg); err != nil {
				fmt.Printf("ERROR Biblio HTTP POST %q\n", err.Error())
			}
			// unconditionally reroute to main test cases page
			http.Redirect(w, r, "/biblio", http.StatusSeeOther)

		case "DELETE":
			fmt.Println("INFO HTTP DELETE request received. Redirecting to main page.")
			// unconditionally reroute to main test cases pag, namee
			// Use HTTP 303 (see other) to force GET to redirect as DELETE request is normally followed by another DELETE
			http.Redirect(w, r, "/biblio", http.StatusSeeOther)

		case "PUT":
			fmt.Println("INFO HTTP PUT request received. Redirecting to main page.")
			// unconditionally reroute to main test cases page
			// Use HTTP 303 (see other) to force GET to redirect as PUT request is normally followed by another PUT
			http.Redirect(w, r, "/biblio", http.StatusSeeOther)

		default:
			if err := renderPage("main", nil, cfg, w, r); err != nil {
				fmt.Printf("ERROR Biblio HTTP GET %q\n", err.Error())
				return
			}
		}
	})
}

// This is HTTP POST handler.
func biblioPostHandler(w http.ResponseWriter, r *http.Request, cfg *Cfg) error {

	id := mux.Vars(r)["id"]
	cmd := mux.Vars(r)["cmd"]

	var err error
	switch strings.ToLower(cmd) {

	case "":
		if i := parseFormValues(r); i != nil {
			err = SQLiteInsert(cfg.DBConn, i)
		}

	case "delete":
		if id == "" {
			return fmt.Errorf("Delete test case: test case ID is empty")
		}
		//title := mux.Vars(r)["title"]
        title := strings.TrimSpace(r.FormValue("title"))
		if err = SQLiteDelete(cfg.DBConn, id); err == nil {
			fmt.Printf("INFO Item %q successfully deleted\n", title)
		}

	case "put":
		if id == "" {
			return fmt.Errorf("Modify item: test case ID is empty")
		}
		if i := parseFormValues(r); i != nil {
			if err = SQLiteUpdate(cfg.DBConn, i); err == nil {
				fmt.Printf("INFO Item '%s[%s]' successfully updated\n", i.Title, i.ID)
			}
		}

	default:
		err = fmt.Errorf("Illegal POST request")
	}
	return err
}

// Helper function that parses the '/case' POST request values and creates a new instance of Case.
func parseFormValues(r *http.Request) *Item {

	i := NewItem()
	i.ID = strings.TrimSpace(r.FormValue("id"))
	i.Title = strings.TrimSpace(r.FormValue("title"))
	i.Author = strings.TrimSpace(r.FormValue("author"))
	i.OrigTitle = strings.TrimSpace(r.FormValue("origtitle"))
	i.Translator = strings.TrimSpace(r.FormValue("translator"))
	i.ISBN = strings.TrimSpace(r.FormValue("isbn"))
	i.Publisher = strings.TrimSpace(r.FormValue("publisher"))
	i.Notes = strings.TrimSpace(r.FormValue("notes"))
	i.Year, _ = strconv.Atoi(strings.TrimSpace(r.FormValue("year")))
	i.Language = strings.TrimSpace(r.FormValue("language"))
	i.Type = strings.TrimSpace(r.FormValue("type"))
	i.Library = strings.TrimSpace(r.FormValue("library"))
	i.InvNumber = strings.TrimSpace(r.FormValue("invnumber"))
	i.Signature = strings.TrimSpace(r.FormValue("signature"))
	i.Date = strings.TrimSpace(r.FormValue("dateb"))
	i.Created = strings.TrimSpace(r.FormValue("created"))
	i.Modified = strings.TrimSpace(r.FormValue("modified"))
	return i
}

// This is HTTP GET handler.
func biblioGetHandler(qry string, w http.ResponseWriter, r *http.Request, cfg *Cfg) error {

    var items []*Item
    var err error
    ptitle := "All Items" // web page title; different for normal and filtered display 
    if qry == "" {
	    items, err = SQLiteFetchAll(cfg.DBConn)
    } else {
        key, val := parseSearchQuery(qry)
        if key == "" {
	        items, err = SQLiteFetchAny(cfg.DBConn, val)
        } else {
	        items, err = SQLiteFetchFiltered(cfg.DBConn, key, val)
        }
        ptitle = fmt.Sprintf("Items Filtered by %q", qry)
    }
	if err != nil {
        cfg.ErrMsg = fmt.Sprintf("Trying to get items from database: %s", err.Error())
		http.Redirect(w, r, "/error", http.StatusFound)
		return fmt.Errorf("Problem getting data from DB: %s", err.Error())
	}

	// create ad-hoc struct to be sent to page template
	var web = struct {
		Items []*Item
        PageTitle string
	}{items, ptitle}

	return renderPage("main", web, cfg, w, r)
}

// Helper function that parses the query string from user (from navbar search) and returns the key and value.
// The search query string should be the following format "key:value".
func parseSearchQuery(qry string) (string, string) {

    tokens := strings.Split(qry, ":")
    switch len(tokens) {
        case 0: return "", "page "
        case 1: return "", tokens[0]
    }
    return strings.TrimSpace(tokens[0]), strings.TrimSpace(tokens[1])
}

// This is a handler for import data from uploaded CSV files.
func importHandler(cfg *Cfg) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		switch r.Method {

		case "POST":
            var err error
			r.ParseMultipartForm(32 << 20) // = 32MB
			//file, handler, err := r.FormFile("importfile") // orig, leave it here, as an example...
            file, _, err := r.FormFile("importfile")
			if err != nil {
				fmt.Println(err)
				return
			}
			defer file.Close()

            items, err := ParseUploadedFile(file)
            if err != nil {
				fmt.Println(err)
				return
            }

            // only if there are actual items to insert into db...
            var inserted []*Item
            if len(items) > 0 {
                if inserted, err = SQLiteInsertMany(cfg.DBConn, items); err != nil {
                    fmt.Printf("ERROR importing into DB: %q\n", err.Error())
                    return
                }
            }
            fmt.Printf("INFO Import: %d item(s) were imported\n", len(inserted))

            // create ad-hoc struct to be sent to web page template
	        var web = struct {
		        Items []*Item
                NumAll int
                NumImported int
	        }{ inserted, len(items), len(inserted) }
	        renderPage("imported", web, cfg, w, r)
            return

		default: // Nothing for now
		}

		http.Redirect(w, r, "/biblio", http.StatusFound)
		return
	})
}

// This is a handler for filters in navbar
func searchHandler(cfg *Cfg) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

        var err error
        switch r.Method {

        case "POST":
            qry := strings.TrimSpace(r.FormValue("search-string"))
            if err = biblioGetHandler(qry, w, r, cfg); err != nil {
                fmt.Printf("ERROR Search POST request: %q\n", err.Error())
            }

        default:
		    renderPage("main", nil, cfg, w, r)
        }
	})
}

// This is the Error page handler function.
func errorHandler(cfg *Cfg) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		if err := renderPage("error", cfg.ErrMsg, cfg, w, r); err != nil {
            fmt.Printf("ERROR Error page: %s\n", err.Error()) 
			return
		}
	})
}
// This is the Error404 page handler function.
func err404Handler(cfg *Cfg) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if err := renderPage("err404", nil, cfg, w, r); err != nil {
			//Error(cfg.log, err.Error())
			fmt.Println(err.Error()) // DEBUG
			return
		}
	})
}
