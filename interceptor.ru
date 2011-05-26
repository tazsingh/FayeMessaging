require './lib/interceptor.rb'
require 'thin'
require 'faye'

Thin::Server.start('0.0.0.0', 9292) do
	run Rack::Interceptor.new
end