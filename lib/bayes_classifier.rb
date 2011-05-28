require 'eventmachine'
require 'faye'
require 'classifier'
require 'madeleine'

client = Faye::Client.new('http://192.168.1.149:9292/faye')
maddie = SnapshotMadeleine.new("bayes_data") do
  Classifier::Bayes.new "Love", "Joy", "Sadness", "Fear", "Anger", "Surprise"
end

EM.run do
  client.subscribe('/classifier/new') do |message|
#    puts message.inspect
    client.publish('/messages/new', message.merge("classification" => maddie.system.classify(message["text"]) ) )
  end
end

#EM.run do
#  client.subscribe('/classifer/wrong') do |message|
#    client.publish('/messages/new', message )
#  end
#end