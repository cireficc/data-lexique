# data-lexique
Data source for Lexique interfaces

## Dependencies
- **Required**:
	- [Ruby](https://www.ruby-lang.org/en/downloads) v1.8+
- *Optional*:
	- [Bundler](http://bundler.io) v1.9+ (Ruby Gem management)
	- if you don't use Bundler to install Gem dependencies, you must install them directly. The dependencies are in the `Gemfile`.
	- [Sqliteman](http://sqliteman.com) to manage the SQLite database(s)

## Organization
Top-level files include dependency management (`Gemfile`), conversion scripts (`csv2sqlite`), and the README.
#### lexique.org
Contains all of the original releases from Lexique, their documentation, and their CSV conversion. Sub-folders are organized by release version (e.g. `lexique.org/3.80` for Lexique 3.80).
#### sqlite
Contains the SQLite database files for each version; this directory is not organized by version.

## Lexique format(s)
Lexique is distributed as an Excel file (.xlsb). In order to use it effectively in any environment, it must be converted to a more usable format. CSV (comma-separated value) is a good intermediary, but becomes inefficient and is not very functional. Thus, we convert Lexique into a SQLite database.

## Converting Lexique
1. Convert the Excel file to CSV
	- Open the file with Excel or LibreOffice Calc, and save as CSV with ***tab* delimeters** (**the `csv2sqlite` script expects CSVs to be delimited with `'\t'`**)
2. Rename the CSV column headings
	- Remove the column number from the heading (e.g. rename `1_ortho` to `ortho`)
	- Clean up anything else extraneous for sane column names (e.g. rename `freqlemfilms2` to `freqlemfilms`)
	- Ensure that `-` is converted to `_`, because the `csv2sqlite` script will throw away `-` during conversion (Ruby's `to_sym` method ignores `-`)
3. Use `csv2sqlite.rb` to convert the CSV with the following command:

    `ruby csv2sqlite.rb -o Lexique380.db ./lexique.org/3.80/Lexique380.csv words`
	- For help with `csv2sqlite`, run:

  `ruby csv2sqlite.rb -h` or `ruby csv2sqlite.rb --help`
4. Move the `Lexique_VERSION.db` file from the root directory to the `sqlite` directory

## Use in other projects
The Lexique SQLite file can be used with other languages/frameworks, e.g.:
	- **Java**: 
		- [OrmLite](http://ormlite.com) - an object-relational mapping library (preferred)
		- [JDBC](https://docs.oracle.com/javase/tutorial/jdbc/basics) - a direct adapter
	- **Ruby**:
		- [Sequel](http://sequel.jeremyevans.net/index.html) - an object-relational mapping library (preferred)
		- [Sqlite3](https://rubygems.org/gems/sqlite3) - a direct adapter

## Modifying the database
Depending on its use, the database may need to be modified, such as indexing fields that are often used (such as `ortho`). In order to do so, [Sqliteman](http://sqliteman.com) is a good tool to use.
