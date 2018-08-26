def usage
  puts "Usage: $0 FILE.md"
  exit 1
end

usage unless ARGV.length == 1
source_file = ARGV[0]

def header_to_string(s)
  s.gsub(/ /, '-').downcase.gsub(/[\.\/,&\()<>-]+/, '-').gsub(/-$/,'')
end

c = 1 ; File.open(source_file).each_line do |line|
  if line =~ /^#/
    level, header = line.match(/^(#+) (.*)/).captures
    ref = header_to_string(header)
    case level
    when '#'
      next
    when '##'
      start = "#{c}. "
      c += 1
    when '###'
      start = "    - "
    when '####'
      start = "        * "
    end
    puts "#{start}[#{header}][#{ref}]"
  end
end

# require 'pry' ; binding.pry
