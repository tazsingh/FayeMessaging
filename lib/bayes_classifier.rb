require 'eventmachine'
require 'faye'
require 'classifier'
require 'madeleine'
require 'yaml'

config = YAML.load_file("../config/faye.yml")
puts config

client = Faye::Client.new("#{config['server_ip']}/faye")
maddie = SnapshotMadeleine.new("bayes_data") {
  Classifier::Bayes.new "Love", "Joy", "Sadness", "Fear", "Anger", "Surprise"
}

EM.run do
  client.subscribe('/classifier/new') do |message|
    puts message.inspect
    client.publish('/messages/new', message.merge("classification" => maddie.system.classify(message["text"]) ) )
  end

  maddie.take_snapshot
end
