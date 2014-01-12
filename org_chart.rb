#!/usr/bin/ruby

# Install RGL:
#  sudo gem install rgl

# Install Graphviz from:
#  http://www.graphviz.org/Download_macos.php

# To download new copy of the Org Chart:
#  File -> Download As -> Plain Text

require 'rgl/adjacency'
require 'rgl/dot'

INPUT_FILE = 'org_charts/Org Chart 01-08-2014 - Sheet1.tsv'
CEO = 'Kanies, Luke A'

def filter(name)
  name.sub!(/ *$/, '')
  name.sub!(/Spence, Chris$/, 'Spence, Christopher')
  name.sub!(/Campbell, Scott$/, 'Campbell, Scott K')
  name.sub!(/Stahnke, Mike/, 'Stahnke, Michael')
  name.sub!(/Stanke, Mike/, 'Stahnke, Michael')
  name.sub!(/Margalia, Dominic/, 'Maraglia, Dominic')
  name.sub!(/Martin, Max/, 'Martin, Charles (Max)')
  name
end

dg = RGL::DirectedAdjacencyGraph.new

File.foreach(INPUT_FILE) do |line|

  (employee, b, c, d, e, supervisor, g) = line.split("\t", 7)

  next if employee == 'NAME'
  next if employee == CEO

  break unless employee.match(/.*,.*/)  # handle summaries etc at the end of spreadsheet

  employee = filter(employee)
  supervisor = filter(supervisor)

  dg.add_edge(employee, supervisor)
end

dg.write_to_graphic_file('jpg')

%x(dot -Tjpg graph.dot -o graph.jpg)
%x(open graph.jpg)
puts 'output file is graph.jpg'

# the end
