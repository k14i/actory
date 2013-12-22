#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/actory'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: receiver.rb [options]"

  opts.on("-d", "--daemon", "Run as daemon") do |o|
    options[:daemon] = o
  end
end.parse!

begin
  puts "Starting Actory Receiver (PID = #{Process.pid}, PGROUP = #{Process.getpgrp})"
  Process.daemon if options[:daemon]
  Actory::Receiver::Worker.new
rescue
  retry
end

