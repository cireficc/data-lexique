#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require 'sequel'
require 'trollop'
require 'tempfile'
require 'sqlite3'

# ruby 1.8 FasterCSV compatibility
if CSV.const_defined? :Reader
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
end

OPTIONS = Trollop::options do
  banner <<-EOS
Usage:
	csv2sqlite [options] FILE_TO_IMPORT.csv TABLENAME [...]

where [options] are:
EOS
  opt :output,  "FILENAME.db where to save the sqlite database", :type => :string
end

def getDatabase(filename)
  puts "Connecting to sqlite://#{filename}"
  database = Sequel.sqlite(filename)
  return database
end

def populateTableFromCSV(database, file, tablename)
  options = { :headers    => true,
              :header_converters => :symbol,
              :converters => :all,
			  :col_sep => "\t" }
  data = CSV.table(file, options)
  puts "CSV table is now in memory"
  headers = data.headers

  puts "Dropping and re-creating table: #{tablename}"
  DB.drop_table? tablename
  DB.create_table tablename do
    # see http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
    # primary_key :id
    # Float :price
	puts "Processing column classes for table: #{tablename}"
    data.by_col!.each do |columnName, rows|
	  puts "Getting common class for #{columnName}"
      columnType = getCommonClass(rows) || String
      column columnName, columnType
    end
  end
  puts "Inserting data into table: #{tablename}; #{data.length} rows"
  data.by_row!.each_with_index do |row, i|
	if (i % 1000 == 0)
	  percent_complete = ((i.to_f / data.length) * 100).round(2)
	  puts "#{percent_complete}% completed"
	end
    database[tablename].insert(row.to_hash)
  end
  puts "Dtaa import complete"
end

# 
# :call-seq:
#   getCommonClass([1,2,3])         => FixNum
#   getCommonClass([1,"bob",3])     => String
#
# Returns the class of each element in +rows+ if same for all elements, otherwise returns nil
#
def getCommonClass(rows)
  return rows.inject(rows[0].class) { |klass, el| break if klass != el.class ; klass }
end

if OPTIONS[:output]
  DB_PATH = OPTIONS[:output]
else
  DB_TMP = Tempfile.new(['csv2sqlite','.sqlite3'])
  DB_PATH = DB_TMP.path
end

DB = getDatabase(DB_PATH)

Trollop.die "Missing CSV file and table name arguments" unless ARGV.count > 1
until ARGV.empty? do 
  file = ARGV.shift
  File.exists?(file) or Trollop.die "Invalid file: #{file}"
  tablename = ARGV.shift.to_sym
  puts "Parsing file #{file} into table #{tablename}"
  populateTableFromCSV(DB, file, tablename)
end
