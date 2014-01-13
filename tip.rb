#!/usr/bin/ruby
def usage
  puts "#{$0} <check> [<percent>]"
  puts "e.g. $ #{$0} 10.31 0.25 # calculate 25% tip on 10.31"
  exit 1
end
default_tip = 0.2
check = ARGV[0]
usage if !check
percent = ARGV[1] || default_tip
total = (check.to_f * (percent.to_f + 1)).ceil
tip = (total - check.to_f).round(2)
puts "tip = #{tip}"
puts "total = #{total}"
