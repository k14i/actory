#!/usr/bin/env ruby

require_relative '../lib/actory/receiver/plugin/example_fibonacci'
require_relative './lib/benchmark'

res = []

ret, time = Benchmark.measure do
  begin
    plugin = Actory::Receiver::Plugin.new
    args = (1..34).to_a
    res << args.map do |arg|
      print "."
      plugin.fibonacci(arg)
    end
    res.each do |r|
      r.each do |v|
        puts "returned #{v}"
      end
    end
  rescue => e
    @num == nil ? @num = 0 : @num += 1
    puts e
    puts $@
    sleep 1
    retry if @num < 2
  end
end

puts " => #{ret}"
puts " => time = #{time} sec"
