#!/usr/bin/env ruby

require 'rubygems'
require 'sequel'
require 'trollop'
require 'sqlite3'
require 'i18n'

I18n.config.enforce_available_locales = false

OPTIONS = Trollop::options do
  banner <<-EOS
Usage:
	transliterate PATH_TO_DATABASE TABLENAME [COLUMN_TO_TRANSLITERATE NEW_TRANSLITERATED_COLUMN]
EOS
end

def transliterate(database, tablename, from_column, to_column)
  words = database.from(tablename)

  DB.transaction do

	words.each_with_index do |word, i|
	  new = I18n.transliterate(word[from_column])
	  words.where(:id => word[:id]).update(to_column => new)
      if (i % 1000 == 0)
	    percent_complete = ((i.to_f / words.count) * 100).round(2)
	    print "\r#{"%.2f" % percent_complete}% completed"
	  end
	end
  end

  puts "\rDone. #{words.count} words transliterated"
end

Trollop.die "Missing database file and table name arguments" unless ARGV.count > 1

DB_PATH = ARGV.shift
TABLENAME = ARGV.shift.to_sym

puts "Connecting to sqlite://#{DB_PATH}"
DB = Sequel.sqlite(DB_PATH)

until ARGV.empty? do
  from_column = ARGV.shift.to_sym
  to_column = ARGV.shift.to_sym
  begin
	puts "Adding column #{to_column} to table #{TABLENAME}"
	DB.add_column TABLENAME, to_column, :string
  rescue Sequel::DatabaseError
	puts "Column (#{to_column}) already exists, continuing"
  end
  puts "Transliterating #{from_column} to #{to_column} in table #{TABLENAME}"
  transliterate(DB, TABLENAME, from_column, to_column)
end
