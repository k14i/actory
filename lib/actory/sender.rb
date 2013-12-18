module Actory
  module Sender
  end
end

require 'progressbar'
Dir[File.join(File.dirname(__FILE__), "sender/*.rb")].each { |f| require_relative f }
SENDER = YAML.load_file(File.expand_path("../../../config/sender.yml", __FILE__))
