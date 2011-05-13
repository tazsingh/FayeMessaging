module Rack
  class Interceptor
    def initialize(app)
      @app = app
    end
    def call(env)
      @req = Rack::Request.new(env)
      
      if @req.post?
        user_message = @req.params['text']
        return amazon_book_title  if user_message.upcase.start_with?("/ISBN")
      end
      
      @app.call(env)
    end
    
    def amazon_book_title
      [200, {'Content-type' => 'text'}, @req.params]
    end
  end
end
