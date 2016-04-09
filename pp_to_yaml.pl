#!/usr/bin/perl

use strict;
use warnings;

# indentation string.
my $ind = '  ';

for (; <>; my $m=0) {
  s/^[^ ]+ +{ +([^ ]*)$/$1/
    and ++$m;
  s/^ +([^ ]+) +=> +(.*),$/  $1: $2/
    and ++$m;
  /^}/
    and ++$m;
  if ($m) {
    s/^/$ind/;
    print $_ unless /$ind}/;
  } else {
    print "WARN: $.: failed to match $_";
  }
}
