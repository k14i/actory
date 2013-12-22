require 'yaml'

module Actory

  class Base
    GLOBAL = YAML.load_file(File.expand_path("../../config/global.yml", __FILE__))

    def self.get_logger_output(type="stdout", target=nil)
      return nil unless type
      out = nil
      file = File.open(target, "a") if %w[file both].include?(type)
      case type.downcase
      when "stdout"
        out = STDOUT
      when "file"
        out = file if target
      when "both"
        out = MultiIO.new(STDOUT, file) if file
      else
        out = STDOUT
      end
      out
    end

    def self.get_logger_level(level="fatal")
      return nil unless level
      logger_level = nil
      case level.downcase
      when "fatal"
        logger_level = Logger::FATAL
      when "error"
        logger_level = Logger::ERROR
      when "warn"
        logger_level = Logger::WARN
      when "info"
        logger_level = Logger::INFO
      when "debug"
        logger_level = Logger::DEBUG
      else
        logger_level = Logger::FATAL
      end
      logger_level
    end
  end

  class MultiIO
    def initialize(*targets)
      @targets = targets
    end

    def write(*args)
      @targets.each {|t| t.write(*args)}
    end

    def close
      @targets.each(&:close)
    end
  end

end #Actory

require 'rubygems'
require 'msgpack/rpc'
require 'parallel'
require 'logger'
Dir[File.join(File.dirname(__FILE__), "actory/*.rb")].each { |f| require_relative f }
