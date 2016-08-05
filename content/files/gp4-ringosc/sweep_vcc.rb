#!/usr/bin/env ruby
require './measure'

class Array
  def mean; reduce(:+) / length; end
end

puts("Vcc\tfosc")
(33..55).map { |v| v/10.0 }.each do |vcc|
  system("gp4prog -q -v #{vcc}")
  freq = to_enum(:acquire).take(5).mean
  puts("#{vcc}\t#{freq}")
end
