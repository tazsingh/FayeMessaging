require 'faye'
require 'eventmachine'
require 'em-http'
require './lib/faye_messaging'
require 'pp'
require 'nokogiri'

# Handles connection when client wants to submit book ISBN and have book title
# published to their Faye feed
class  InterceptorConnection < EM::Connection
  API_KEY = "CDABR9CX" # max 500 per day
  ISBNDB_URL = "http://isbndb.com/api/books.xml?access_key=#{API_KEY}&results=details&index1=isbn&value1=%s"
  
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
    data.split(' ')[1]
  end
  
  # Asynchronously fetch book data given the ISBN
  def send_amazon_title(isbn)
    url = InterceptorConnection::ISBNDB_URL % isbn
    async_fetch_and_publish(url) { |data| librarything_response_parser(data) }
  end
  
  def async_fetch_and_publish(url, &block)
    puts "requesting #{url}"
    http = EventMachine::HttpRequest.new(url).get(:timeout => FayeMessaging::HTTP_TIMEOUT_IN_SEC)
    http.errback do
      puts "HTTP Error: Status #{http.response_header.status}"
      send_data("") # empty string signals error
    end
    http.callback do
      book_title = block.call(http.response)
      @client.publish(FayeMessaging::PUBLISH_CLEAN_URI, :text => book_title)
      send_data("Book title published successfully!")
    end
  end
  
  # Returns book title given XML response back from isbndb.com
  # Returns empty string if title not found
  def librarything_response_parser(data)
    pp data
    begin
      doc = Nokogiri::XML.parse(data)
      pp doc.xpath('//Title').first.content
    rescue Exception => e
      ""
    end
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