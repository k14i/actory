#!/usr/bin/env ruby

require_relative '../lib/actory'
require_relative './lib/benchmark'

METHOD = "prime"
ARGS   = (1..1000).to_a

ret, time = Benchmark.measure do
  begin
    dispatcher = Actory::Sender::Dispatcher.new
    res = dispatcher.message(METHOD, ARGS)
    res.each do |r|
      r.each do |k,v|
        puts "#{k} returned #{v}"
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
