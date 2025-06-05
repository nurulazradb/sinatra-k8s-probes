# routes/health_routes.rb
module HealthRoutes
  def self.included(base)
    # The 'base' argument here will be MySinatraApp when this module is included.
    base.class_eval do
      # --- Liveness Probe Endpoint ---
      get '/health' do
        if $health_status_ok
          status 200
          { status: 'UP' }.to_json
        else
          status 503 # Service Unavailable
          { status: 'DOWN' }.to_json
        end
      rescue => e
        status 500
        { status: 'DOWN', error: e.message }.to_json
      end

      # --- Endpoint to toggle the /health status ---
      # To toggle the /health status, send a PUT request with a JSON body.
      # Example: PUT /health_status with body {"status": "up"} or {"status": "down"}
      put '/health_status' do
        request.body.rewind # In case it's been read already
        payload = JSON.parse(request.body.read) rescue nil

        if payload && payload['status'] == 'up'
          $health_status_ok = true
          status 200
          { message: 'Health status set to UP' }.to_json
        elsif payload && payload['status'] == 'down'
          $health_status_ok = false
          status 503
          { message: 'Health status set to DOWN' }.to_json
        else
          status 400 # Bad Request
          { error: 'Invalid status provided. Use {"status": "up"} or {"status": "down"}' }.to_json
        end
      end
    end
  end
end
