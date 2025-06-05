# config/database.rb
require 'active_record'
require 'sqlite3' # Or 'pg'

# --- Database Configuration ---
DB_CONFIG = {
  adapter: 'sqlite3',
  # Use RACK_ENV to determine database name, place it in the 'db' subdirectory
  database: "db/#{ENV['RACK_ENV'] || 'development'}.sqlite3",
  pool: 5
}

# --- Establish a connection to the database ---
# This will run when `config/database.rb` is required by app.rb
begin
  ActiveRecord::Base.establish_connection(DB_CONFIG)
  ActiveRecord::Base.connection.execute('SELECT 1') # Test connection immediately
  puts "SQLite database connection established successfully at: #{DB_CONFIG[:database]}"
rescue ActiveRecord::ConnectionNotEstablished => e
  puts "Failed to establish SQLite database connection on startup: #{e.message}"
rescue SQLite3::CantOpenException => e
  puts "Failed to open SQLite database file (permissions/path issue): #{e.message}"
rescue StandardError => e # Catch any other unexpected errors
  puts "An unexpected error occurred during SQLite connection setup: #{e.message}"
end
