package main

import (
	 "bytes"
	"fmt"
	 "golang.org/x/text/encoding/unicode"
	 "golang.org/x/text/transform"
	 "io/ioutil"
    "io"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// Item represents a single library item.
type Item struct {
	// ID is a unique ID of the library item
	ID string
	// Title is of course title of the item
	Title string
	// Author is of course the string identifying one or more authors of the library item
	Author string
	// Library is a string that identified the library
	Library string
	// Type represents the short code for type of item: book, audio, video...
	Type string
	// Language represents short language code
	Language string
	// Year represents the year of publishing
	Year int
	// Signature is a description string
	Signature string
	// InvNumber is unique inventory number
	InvNumber string
	// Date is the just a date string when item has been borrowed
	Date string
	// Publisher is a string containing data about book's publisher
	Publisher string
	// ISBN is book's ISBN number
	ISBN string
	// Translator holds the name of the book's translator to Slovene (when applicable)
	Translator string
	// OrigTitle is book's original title, when book's been translated
	OrigTitle string
	// Notes are just user's random notes
	Notes string
	// Created & Modified are normal created and last modified DB timestamp strings
	Created, Modified string
	//Created, Modified Timestamp
}

// NewItem creates a new empty instance of the Item.
func NewItem() *Item {
	t := NewTimestamp()
	return &Item{
		ID:         "000",
		Title:      "new title",
		Author:     "new author",
		Library:    "a library",
		Type:       "UNK",
		Year:       9999,
		Language:   "LNG",
		Signature:  "a signature",
		InvNumber:  "666",
		Date:       "01.01.1001",
		Publisher:  "",
		ISBN:       "",
		Translator: "",
		OrigTitle:  "",
		Notes:      "",
		Created:    t,
		Modified:   t,
	}
}

// String returns a string representation of the Item.
func (i *Item) String() string {
	s := fmt.Sprintf("%s: %s [%s %d %s]\n  %s LIB:%q SIGN:%q INV#: %s", i.Author, i.Title, i.Type,
		i.Year, i.Language, i.Date, i.Library, i.Signature, i.InvNumber)
	return s
}

// helper function that parses a single line for author, year and language.
func parseInvNumber(line string, item *Item) string {
	start := strings.Index(line, "Inventarna")
	if start >= 0 {
		item.InvNumber = strings.TrimSpace(line[start+16 : start+30])
		return line[start+29:]
	}
	return line
}

// helper function that parses a single line for author, year and language.
func parseSignature(line string, item *Item) string {

	item.Signature = ""
	if strings.HasPrefix(line, "Signatura:") {
		end := strings.Index(line, "Inventarna")
		item.Signature = strings.TrimSpace(line[10:end])
		return line[end:]
	}
	return line
}

// helper function that parses a single line for author, year and language.
func parseAuthorYearAndLang(line string, item *Item) string {
	// NOTE: sometimes author is not specified...
	item.Author = "Unknown Author"
	item.Language = "UNK"
	end := strings.Index(line, "Signatura:")
	if end < 0 {
		end = len(line) // Sometimes even signature is missing...
	}
	a := line[:end]
	// parse year, use regex
	yearIndex := strings.Index(a, "leto:")
	if yearIndex > 0 {
		re, _ := regexp.Compile("[\\d]{4}") //neglect the error; what could go wrong with such a regex?
		if year := re.Find([]byte(a[yearIndex+5:])); year != nil {
			item.Year, _ = strconv.Atoi(string(year))
		}
		a = a[:yearIndex] // shorten line
	}
	// parse language
	langIndex := strings.Index(a, "jezik:")
	if langIndex > 0 {
		item.Language = strings.ToUpper(strings.TrimSpace(a[langIndex+6 : langIndex+10]))
		a = a[:langIndex] // shorten line
	}
	// and finally, extract author
	if strings.HasPrefix(line, "Avtor:") {
		item.Author = strings.TrimSpace(a[6:])
	}
	return line[end:]
}

// helper function that parses a single line for title and type.
func parseTitleAndType(line string, item *Item) string {
	//
	item.Title = ""
	item.Type = "BOOK"
	if strings.HasPrefix(line, "Naslov:") {
		// we parse the line until the "Avtor:" string
		final := strings.Index(line, "Avtor:")
		if final < 0 {
			// Sometimes the "Avtor:" string is missing...
			final = strings.Index(line, "jezik:")
		}
		title := strings.TrimSpace(line[7:final])
		// parse type and update title...
		end := strings.Index(title, "[Video")
		if end > 0 {
			item.Type = "VIDEO"
			item.Title = strings.TrimSpace(title[:end])
			return line[final:]
		}
		end = strings.Index(title, "[Zvo")
		if end > 0 {
			item.Type = "AUDIO"
			item.Title = strings.TrimSpace(title[:end])
			return line[final:]
		}
		item.Title = title
		return line[final:]
	}
	return line
}

// reformat the date string from slovenian type date to more international style. 
func formatDate(d string) string {
    l := strings.Split(strings.TrimSpace(d), ".")
    var newd string
    if len(l) == 3 {
        newd = fmt.Sprintf("%s-%s-%s", l[2], l[1], l[0])
    } else {
        newd = "2121-12-31" // invalid value, put it in future
    }
    return newd
}

// helper function that parses a single line and updates the Item object with proper data.
func parseLine(line string, item *Item) {
	// parse date
	final := len(line)
	datestr := line[final-10:]
	item.Date = formatDate(datestr)
	//
	line = parseTitleAndType(line[:final-10], item)
	line = parseAuthorYearAndLang(line, item)
	line = parseSignature(line, item)
	line = parseInvNumber(line, item)
	// and finally, the extract library
	item.Library = strings.TrimSpace(line)
}

// Parse parses the list of lines and creates a list of Item objects that can be manipulated further.
func Parse(lines []string) []*Item {
	//
	var line string
	var items []*Item
	for _, l := range lines {
		line = strings.TrimSpace(l)
		// omit some special lines: empty lines, commented lines and the usual first line...
		if line == "" || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "Gradivo") {
			continue
		}
		item := NewItem()
		parseLine(line, item)
		items = append(items, item)
	}
	return items
}

// ParseFile is a shortcut function that reads a COBISS/OPAC export file (it is UTF-16 encoded!) and
// parsed. It returns the list of library items.
func ParseUploadedFile(r io.Reader) ([]*Item, error) {

	lines, err := ReadLinesUTF16(r)
	if err != nil {
		fmt.Println(err.Error())
        return nil, fmt.Errorf("ERROR parsing uploaded file: %q\n", err.Error())
	}
	return Parse(lines), nil

}

// ReadLines reads an UTF16-encoded io.Reader (in this case uploaded file) and returns it as a list of lines.
func ReadLinesUTF16(r io.Reader) ([]string, error) {

	// we read from a reader 
	data, err := ReadUTF16(r)
	// if there's an error reading a file, we return a list with single empty
	// string and error
	if err != nil {
		return []string{""}, err
	}
	// now we convert the text into an array of lines
	lines := strings.Split(string(data), "\n")
	return lines, err
}

// ReadFileUTF16 is similar to ioutil.ReadFile() but decodes UTF-16. Useful when reading data from MS-Windows
// systems that generate UTF-16BE files, but will do the right thing if other BOMs are found.
//
// source: http://stackoverflow.com/questions/15783830/how-to-read-utf16-text-file-to-string-in-golang by TomOnTime
func ReadUTF16(r io.Reader) ([]byte, error) {

	// Read the file into a []byte:
	raw, err := ioutil.ReadAll(r)
	if err != nil {
		return nil, err
	}

	// Make an tranformer that converts MS-Win default to UTF8:
	win16be := unicode.UTF16(unicode.BigEndian, unicode.IgnoreBOM)
	// Make a transformer that is like win16be, but abides by BOM:
	utf16bom := unicode.BOMOverride(win16be.NewDecoder())

	// Make a Reader that uses utf16bom:
	unicodeReader := transform.NewReader(bytes.NewReader(raw), utf16bom)

	// decode
	decoded, err := ioutil.ReadAll(unicodeReader)
	return decoded, err
}

// NewTimestamp creates a properly formatted new instance of Timestamp.
func NewTimestamp() string { return time.Now().Format(time.RFC850) }
