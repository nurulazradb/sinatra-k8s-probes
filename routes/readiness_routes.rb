# routes/readiness_routes.rb
module ReadinessRoutes
  def self.included(base)
    base.class_eval do
      # --- Readiness Probe Endpoint ---
      get '/ready' do
        begin
          ActiveRecord::Base.connection.execute('SELECT 1')
          status 200
          { status: 'UP', database: 'CONNECTED' }.to_json
        rescue ActiveRecord::ConnectionNotEstablished => e
          status 503 # Service Unavailable
          { status: 'DOWN', database: 'DISCONNECTED', error: e.message }.to_json
        rescue SQLite3::CantOpenException => e # Specific SQLite error for file access issues
          status 503
          { status: 'DOWN', database: 'DISCONNECTED', error: e.message }.to_json
        rescue => e
          status 503
          { status: 'DOWN', reason: 'Readiness check failed', error: e.message }.to_json
        end
      end
    end
  end
end

