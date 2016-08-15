#!/usr/bin/ruby

require 'json'

myfile = ARGV[0]

classname = ''
File.read('manifests/init.pp').each_line do |l|
  begin
    classname = l.match(/^class (.*) /).captures[0]
  rescue
  end
end

json = JSON.parse(File.read(myfile))
json.delete_if { |h| h != 'resources' }
json['resources'].delete_if do |h|
  h['type'] == 'Stage' or
  h['type'] == 'Class' or
  h['type'] == 'Anchor' or
  h['type'] == 'Notify' or
  h['type'] =~ /::/
end

printf "require 'spec_helper'\n"
printf "\n"
printf "describe '#{classname}' do\n"
  json['resources'].each do |r|
printf "  it {\n"
printf "    is_expected.to contain_%s('%s').with({\n", r['type'].downcase, r['title']
    r['parameters'].each do |k, v|
      unless r['type'] == 'File' and k == 'content'
printf "      '%s' => '%s',\n", k, v
      end
    end
printf "    })\n"
printf "  }\n"
printf "\n"
    if r['type'] == 'File' and
      (r['parameters']['ensure'] == 'file' or r['parameters']['ensure'] == 'present')

      if r['parameters'].has_key?('content')
        r['parameters']['content'].gsub!(/"/, '\"')
      end
printf "  [\n"
printf "\n"
printf '"%s', r['parameters']['content']
printf "\",\n"
printf "\n"
printf "  ].map{|k| k.split(\"\\n\")}.each do |text|\n"
printf "\n"
printf "    it {\n"
printf "      verify_contents(catalogue, '%s', text)\n", r['title']
printf "    }\n"
printf "  end\n"
printf "\n"
    end
  end
printf "  it {\n"
printf "    File.write(\n"
printf "      'catalogs/%s.json',\n", classname
printf "      PSON.pretty_generate(catalogue)\n"
printf "    )\n"
printf "  }\n"
printf "end\n"
