require 'faye'
require 'eventmachine'
require './lib/faye_messaging'
require 'nokogiri'
require 'em-synchrony'
require 'em-synchrony/em-http'

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
    isbns = data.split(' ')
    isbns.shift
    isbns
  end
  
  # Asynchronously fetch book data given the ISBNs
  def send_amazon_title(isbns)
    EM.synchrony do
      multi = EventMachine::Synchrony::Multi.new
      
      isbns.each_with_index do |isbn, index|
        multi.add "page#{index}".to_sym, EventMachine::HttpRequest.new(InterceptorConnection::ISBNDB_URL % isbn).aget
      end
    
      titles = multi.perform.responses[:callback].values.map { |h| response_parser(h.response) }
      @client.publish(FayeMessaging::PUBLISH_CLEAN_URI, :text => titles.inspect)
      send_data("Book title published successfully!")
    end
  end
  
  # Returns book title given XML response back from isbndb.com
  # Returns empty string if title not found
  def response_parser(data)
    begin
      doc = Nokogiri::XML.parse(data)
      doc.xpath('//Title').first.content
    rescue Exception => e
      ""
    end
  end
end

if $0 == __FILE__
  EM.synchrony do
    host = '0.0.0.0'
    port = 9292
    EM::start_server host, port, InterceptorConnection
    puts "Interceptor server STARTED on host #{host} and port #{port}"
  end
end