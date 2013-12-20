module Actory
module Sender

  class Base < Actory::Base
    SENDER = YAML.load_file(File.expand_path("../../../config/sender.yml", __FILE__))
    @@logger = Logger.new(get_logger_output(SENDER['log']['type'], SENDER['log']['target']))
    @@logger.level = get_logger_level(SENDER['log']['level'])
  end

end #Sender
end #Actory

require 'progressbar'
Dir[File.join(File.dirname(__FILE__), "sender/*.rb")].each { |f| require_relative f }
