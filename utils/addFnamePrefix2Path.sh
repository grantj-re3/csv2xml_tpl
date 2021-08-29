#!/bin/sh
# Usage: addFnamePrefix2Path.sh
#
# BEWARE: This script makes changes to *all* files:
# - within the current folder, and
# - recursively, within all subfolders of the current folder.
# It does so without prompting the user.
# Use it at your own risk!
##############################################################################

prefix="al2-"

echo "Add the filename-prefix '$prefix'"
echo "---------------------------------"

find . -type f |
  sort |
  while read fpath; do
    echo
    echo "### $fpath"
    dirpath=`dirname "$fpath"`
    basename=`basename "$fpath"`

    if echo "$basename" |egrep -q "^$prefix"; then
      echo "WARNING: Not processing! Filename prefix '$prefix' already at path '$fpath'"
      continue
    fi

    destpath="$dirpath/$prefix$basename"
    cmd="mv -vi \"$fpath\"  \"$destpath\""
    echo "CMD: $cmd"
    eval $cmd

    res=$?
    if [ "$res" != 0 ]; then
      echo "Error: $res"
    fi
  done

