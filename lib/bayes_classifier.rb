require 'eventmachine'
require 'faye'
require 'classifier'
require 'madeleine'
require 'yaml'

config = YAML.load_file("../config/faye.yml")
puts config

client = Faye::Client.new("#{config['server_ip']}/faye")
maddie = SnapshotMadeleine.new("bayes_data") do
  Classifier::Bayes.new "Love", "Joy", "Sadness", "Fear", "Anger", "Surprise"
end

EM.run do
  client.subscribe('/classifier/new') do |message|
#    puts message.inspect
    client.publish('/messages/new', message.merge("classification" => maddie.system.classify(message["text"]) ) )
  end
  maddie.take_snapshot
end

#EM.run do
#  client.subscribe('/classifer/wrong') do |message|
#    client.publish('/messages/new', message )
#  end
#end

