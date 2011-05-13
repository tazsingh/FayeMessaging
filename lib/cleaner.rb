require 'eventmachine'
require 'faye'

module CleanerConnection
  def receive_data data
    @faye_client = Faye::Client.new('http://192.168.1.149:9292')

    @faye_client.subscribe('/messages/dirty') do |message|
      # TODO: CLEAN!!!!

      %w[text username timestamp].each do |key|

      end

      puts 'gets here'

      @faye_client.publish('/messages/clean', :text => message.text, :username => message.username,
                           :timestamp => message.timestamp)
    end
  end
end

EM::run do
  EM::start_server '0.0.0.0', 9294, CleanerConnection
end