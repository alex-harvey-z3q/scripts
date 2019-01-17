#!/usr/bin/env bash

usage() {
  echo "Usage: $0 SHA1 DATE"
  exit 1
}
[ $# -ne 2 ] && usage

read -r sha1 date <<< "$@"

git filter-branch -f --env-filter \
  "if [ \$GIT_COMMIT = $sha1 ]
   then
     export GIT_AUTHOR_DATE='$date'
     export GIT_COMMITTER_DATE='$date'
   fi"
