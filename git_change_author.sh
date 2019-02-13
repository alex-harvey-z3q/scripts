#!/bin/sh

usage() {
  echo "Usage: $0 [-h] [OLD_EMAIL] NEW_EMAIL"
  exit 1
}
[ "$1" == "-h" ] && usage
[ -z "$1" ] && usage

new_email='alexharv074@gmail.com'

if [ -z "$2" ] ; then
  old_email=$1
else
  old_email=$1
  new_email=$2
fi

git filter-branch --env-filter '

OLD_EMAIL="'$old_email'"
CORRECT_NAME="Alex Harvey"
CORRECT_EMAIL="'$new_email'"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
