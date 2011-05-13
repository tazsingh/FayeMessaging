module Rack
  class Interceptor
    def call(env)
      @req = Rack::Request.new(env)
      
      # EventMachine used here for subscription to faye
      
      [200, {'Content-type' => 'text'}, "Hello World!"]
    end
  end
end
