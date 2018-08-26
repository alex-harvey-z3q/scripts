#!/usr/bin/env ruby

def usage
  puts "Usage: #{$0} FILE.md"
  exit 1
end

def header_to_ref(string)
  string
    .gsub(/ /, "-")
    .gsub(/[\.\/,&\()<>-]+/, "-")
    .gsub(/-$/, "")
    .downcase
end

usage unless ARGV.length == 1
source_file = ARGV[0]

puts "#### Table of contents\n\n"

c=1; File.open(source_file).each_line do |line|
  next unless line.match(/^#/)

  level, header = line.match(/^(#+) (.*)/).captures
  next if header == "Table of contents"

  # I have assumed only 2nd, 3rd & 4th level headers
  # belong in the generated ToC.
  #
  next unless ["##", "###", "####"].include?(level)

  ref = header_to_ref(header)

  case level
  when "##"
    start = "#{c}."
    c += 1
  when "###"
    start = "    -"
  when "####"
    start = "        *"
  end

  puts "#{start} [#{header}](##{ref})"
end
