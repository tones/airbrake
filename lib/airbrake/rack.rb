module Airbrake
  # Middleware for Rack applications. Any errors raised by the upstream
  # application will be delivered to Airbrake and re-raised.
  #
  # Synopsis:
  #
  #   require 'rack'
  #   require 'airbrake'
  #
  #   Airbrake.configure do |config|
  #     config.api_key = 'my_api_key'
  #   end
  #
  #   app = Rack::Builder.app do
  #     use Airbrake::Rack
  #     run lambda { |env| raise "Rack down" }
  #   end
  #
  # Use a standard Airbrake.configure call to configure your api key.
  class Rack
    def initialize(app)
      puts "INIT"
      @app = app
    end

    def call(env)
      puts "CALL"
      puts env.inspect
      begin
        response = @app.call(env)
      rescue Exception => raised
        puts "EXCEPTION"
        error_id = Airbrake.notify_or_ignore(raised, :rack_env => env)
        env['airbrake.error_id'] = error_id
        raise
      end

      if env['rack.exception']
        error_id = Airbrake.notify_or_ignore(env['rack.exception'], :rack_env => env)
        env['airbrake.error_id'] = error_id
      end

      response
    end
  end
end
