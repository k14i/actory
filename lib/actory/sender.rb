module Actory
  module Sender
  end
end

require_relative 'sender/runner'
SENDER = YAML.load_file(File.expand_path("../../../config/sender.yml", __FILE__))
