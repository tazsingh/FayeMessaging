require 'faye'

module Rack
  class Cleaner
    def initialize app
      @faye_client = Faye::Client.new('http://192.168.1.149:9292')
    end

    def call env
      EM::next_tick do
        @faye_client.subscribe('/messages/dirty') do |message|
          # TODO: CLEAN!!!!

          %w[text username timestamp].each do |key|

          end

          @faye_client.publish('/messages/clean', :text => message.inspect, :username => 'TESTING!!!', :timestamp => 0)
        end
      end
    end
  end
end