#!/bin/bash

# A script to brute-force discover the list of
# library files required for a working jail on
# Mac OS X.

# Usage: bash shunit2/jail.sh

FAKE_ROOT=./fake_root

copy_to_jail() {
  d=$(dirname $1)
  mkdir -p $FAKE_ROOT/$d
  cp -p $1 $FAKE_ROOT/$d
}

initial_files=$(otool -L /bin/sh | awk 'NR > 1 {print $1}')

for f in /bin/sh /usr/lib/dyld $initial_files
do
  copy_to_jail $f
done

who_i_am=$(whoami)

set -o pipefail
while true
do
  missing_file=$(sudo chroot -u $who_i_am $FAKE_ROOT /bin/sh -c echo 2>&1 | \
      awk '/dyld: Library not loaded:/ {print $5}')
  [ "$?" -eq 0 ] && break
  copy_to_jail $missing_file
done

find $FAKE_ROOT -type f -and \! -name sh | sed -e "s~^$FAKE_ROOT~~" | sort -u
rm -rf $FAKE_ROOT
