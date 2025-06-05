# lib/startup_manager.rb

# Global variable to simulate a long startup time
$startup_complete = false

Thread.new do
  puts "Simulating long startup..."
  sleep 10 # Simulate a long initialization process (e.g., loading large models, data)
  $startup_complete = true
  puts "Startup process complete!"
end

