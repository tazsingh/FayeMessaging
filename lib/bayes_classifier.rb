require 'eventmachine'

client = Faye::Client.new('http://192.168.1.149:9292/faye')

EM.run do
  client.subscribe('/classifier/new') do |message|
    puts message.inspect
  end

  client.publish('/messages/new', 'text' => 'Hello world')
end