require 'faye'

run Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)