#!/usr/bin/env ruby

require_relative '../lib/actory'

begin
  Actory::Receiver::Runner.new
rescue
  retry
end

