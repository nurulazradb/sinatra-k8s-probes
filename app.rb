# app.rb
require 'sinatra'
require 'json'
require 'active_record'

# Require database configuration
require_relative 'config/database'

# Require startup manager (to handle the global $startup_complete flag)
require_relative 'lib/startup_manager'

# Require all route files
require_relative 'routes/health_routes'
require_relative 'routes/readiness_routes'
require_relative 'routes/startup_routes'

# --- Global variable to simulate a long startup time (for Startup Probe) ---
$startup_complete = false
Thread.new do
  puts 'Simulating long startup...'
  sleep 10
  $startup_complete = true
  puts 'Startup process complete!'
end

# --- Global variable to control the /health endpoint status ---
$health_status_ok = true # Initially, the health endpoint is UP

class MySinatraApp < Sinatra::Base
  # Set content type for JSON responses for all routes
  before do
    content_type :json
  end

  # Mount the routes defined in separate files
  # Sinatra::Base.use / register syntax is used for more complex apps,
  # but for simple routes defined in modules like we'll do,
  # directly including them in the main app is common.

  # Alternatively, you can explicitly register them if they were Sinatra::Base subclasses:
  # register HealthRoutes
  # register ReadinessRoutes
  # register StartupRoutes

  # For the simple module approach below, the routes are just loaded.
  
  # --- Example of a normal application endpoint ---
  get '/' do
    status 200
    { message: 'Hello from Sinatra Microservice!' }.to_json
  end

  # --- Include the route modules into MySinatraApp ---
  # When these modules are included, their 'self.included' method is called,
  # which then defines the routes within this class's context.
  include HealthRoutes
  include ReadinessRoutes
  include StartupRoutes
end

# --- IMPORTANT: Add this line to run the application ---
# This tells Sinatra to start the web server with MySinatraApp
# The 'if __FILE__ == $0' condition ensures it only runs when this file is executed directly.
MySinatraApp.run! if __FILE__ == $0
