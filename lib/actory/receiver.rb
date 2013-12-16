module Actory
  module Receiver
  end
end

require 'msgpack/rpc/transport/udp'
require 'facter'
Dir[File.join(File.dirname(__FILE__), "receiver/*.rb")].each { |f| require_relative f }
Dir[File.join(File.dirname(__FILE__), "receiver/plugin/*.rb")].each { |f| require_relative f }
RECEIVER = YAML.load_file(File.expand_path("../../../config/receiver.yml", __FILE__))
