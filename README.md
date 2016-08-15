# Scripts

A miscellaneous collection of scripts.

## pp_to_yaml.pl

Convert the output of puppet resource into YAML data suitable for use in Hiera + `create_resources()`.

```
puppet resource yumrepo | pp_to_yaml.pp > yumrepos.yaml
```

Note that this is useful in Puppet 3.x whereas in Puppet 4.x the `--to_yaml` option has been added to `puppet resource`. [ref](https://docs.puppet.com/puppet/latest/reference/man/resource.html)

## create_my_spec.rb

To use this:

1)  Create `spec/classes/init_spec.rb` with the following content:

```ruby
require 'spec_helper'

describe 'myclass' do
  let(:params) do
    {
      :foo => 'bar',
    }
  end
  it {
    File.write('myclass.json',
    PSON.pretty_generate(catalogue))
  }
end
```

Then:

```
$ create_my_spec.rb myclass.json > spec/classes/init_spec.rb
```

