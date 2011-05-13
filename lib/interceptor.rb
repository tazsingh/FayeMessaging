module Rack
  class Interceptor
    def initialize(app)
      @app = app
    end
    def call(env)
      @req = Rack::Request.new(env)
      
      # EventMachine used here for subscription to faye
      
      @app.call(env)
    end
  end
end
