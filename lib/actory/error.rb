module Actory
  module Errors
  end
end

require 'json'
Dir[File.join(File.dirname(__FILE__), "errors/*.rb")].each { |f| require_relative f }
