module Actory
module Receiver

  class Base < Actory::Base
    RECEIVER = YAML.load_file(File.expand_path("../../../config/receiver.yml", __FILE__))
    @@logger = Logger.new(get_logger_output(RECEIVER['log']['type'], RECEIVER['log']['target']))
    @@logger.level = get_logger_level(RECEIVER['log']['level'])
  end

end #Receiver
end #Actory

require 'msgpack/rpc/transport/udp'
require 'facter'
Dir[File.join(File.dirname(__FILE__), "receiver/*.rb")].each { |f| require_relative f }
Dir[File.join(File.dirname(__FILE__), "receiver/plugin/*.rb")].each { |f| require_relative f }

