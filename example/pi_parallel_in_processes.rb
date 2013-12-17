#!/usr/bin/env ruby

require_relative '../lib/actory/receiver/plugin/example_pi'
require_relative './lib/benchmark'
require 'parallel'

res = []

ret, time = Benchmark.measure do
  begin
    plugin = Actory::Receiver::Plugin.new
    args = (1..1000).to_a
    res << Parallel.map(args, :in_processes => Parallel.processor_count) do |arg|
      print "."
      plugin.pi(arg)
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
