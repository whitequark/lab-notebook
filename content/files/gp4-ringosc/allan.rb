#!/usr/bin/env ruby

class Array
  def mean; reduce(:+) / length; end
end

samples = File.read(ARGV[0]).split.map(&:to_f)
puts("n\t%d" % samples.count)

nominal_freq = samples.mean
puts("f\t%f" % nominal_freq)

puts("τ\tσ(τ)")
freq_diff =
  samples.map do |sample|
    sample / nominal_freq - 1
  end
(0..8).map { |n| 2**n }.each do |tau|
  variance =
    freq_diff
      .each_slice(tau).map { |slice| slice.mean }
      .each_cons(2).map do |y_n, y_np1|
        (y_np1 - y_n) ** 2
      end.mean / 2
  puts("#{tau}\t%.2g" % Math.sqrt(variance))
end
