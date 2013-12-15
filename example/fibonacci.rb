#!/usr/bin/env ruby

require_relative '../lib/actory'

begin
  runner = Actory::Sender::Runner.new
  args = (1..37).to_a
  res = runner.message("fibonacci", args)
  res.each do |r|
    r.each do |k,v|
      puts "#{k} returned #{v}"
    end
  end
rescue
  retry
end

