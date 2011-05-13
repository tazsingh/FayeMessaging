require 'faye'
require 'eventmachine'
require 'em-http'
require './lib/faye_messaging'

# Handles connection when client wants to submit book ISBN and have book title
# published to their Faye feed
class  InterceptorConnection < EM::Connection
  def post_init
    @client = Faye::Client.new(FayeMessaging::FAYE_SERVER)
  end
  
  def receive_data(data)
    if data.upcase[0..4] == '/ISBN'
      send_amazon_title(get_isbn(data))
    else
      # No pre-processing so just publish what was given
      @client.publish(FayeMessaging::PUBLISH_CLEAN_URI, :text => data)
    end
  end
  
private

  def get_isbn(data)
    "9780735619678" # can you guess which book this is??
  end
  
  # Asynchronously fetch book data given the ISBN
  def send_amazon_title(isbn)
    url = "http://www.librarything.com/api/thingISBN/" + isbn
    async_fetch_and_publish(url) { |data| librarything_response_parser(data) }
  end
  
  def async_fetch_and_publish(url, &block)
    http = EventMachine::HttpRequest.new(url).get(:timeout => FayeMessaging::HTTP_TIMEOUT_IN_SEC)
    http.errback do
      err_message = "HTTP Error: Status #{http.response_header.status}"
      send_data(err_message)
    end
    http.callback do
      title = block.call(http.response)
      @client.publish(FayeMessaging::PUBLISH_CLEAN_URI, :text => title)
      send_data("Book title published successfully!")
    end
  end
  
  # Returns book title given XML response back from www.librarything.com REST API
  def librarything_response_parser(data)
    "The Rails 3 Way"
  end
end

if $0 == __FILE__
  EM::run {
    host = '0.0.0.0'
    port = 9292
    EM::start_server host, port, InterceptorConnection
    puts "Interceptor server STARTED on host #{host} and port #{port}"
  }
end