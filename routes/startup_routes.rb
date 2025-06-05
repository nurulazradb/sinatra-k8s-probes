# routes/startup_routes.rb
module StartupRoutes
  def self.included(base)
    base.class_eval do
      # --- Startup Probe Endpoint ---
      get '/startup' do
        if $startup_complete
          status 200
          { status: 'UP', message: 'Startup complete' }.to_json
        else
          status 503 # Service Unavailable
          { status: 'DOWN', message: 'Still starting up...' }.to_json
        end
      rescue => e
        status 500
        { status: 'DOWN', error: e.message }.to_json
      end
    end
  end
end

