# Scripts

A miscellaneous collection of scripts.

## pp_to_yaml.pl

Convert the output of puppet resource into YAML data suitable for use in Hiera + `create_resources()`.

```
puppet resource yumrepo | pp_to_yaml.pp > yumrepos.yaml
```
