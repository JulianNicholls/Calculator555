#!/usr/bin/env ruby -I. -w

require 'calculator'
require 'term/ansicolor'

def decode_cap_entry(entry)
  parts = /(?<value>\d+)\s*(?<unit>[µupn][fF])/.match entry

  [parts[:value].to_i, parts[:unit]]
end

puts "555 Timer Calculator\n====================\n"

print 'Capacitor: (22µF)? '
entered_cap = $stdin.gets.chomp

cap = entered_cap == '' ? [22, 'µF'] : decode_cap_entry(entered_cap)

calc = Calculator555.new(*cap)

print '(p)eriod or (f)requency? '
