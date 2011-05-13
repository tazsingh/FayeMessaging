require 'faye'
require './lib/interceptor'

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
use Rack::CommonLogger
use Rack::Interceptor
run faye_server