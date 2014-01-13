#!/usr/bin/ruby
default_tip = 0.2
check = ARGV[0]
percent = ARGV[1] || default_tip
total = (check.to_f * (percent.to_f + 1)).ceil.round(2)
tip = (total - check.to_f).round(2)
puts "tip = #{tip}"
puts "total = #{total}"
