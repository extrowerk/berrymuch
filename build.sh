#!/usr/bin/env bash

# This code Copyright 2012 Todd Mortimer <todd.mortimer@gmail.com>
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.

set -e

source lib.sh

TASK=build_all

init "$@"

if [ "$TASK" == "build" ]
then
  build_all
fi

if [ "$TASK" == "bundle" ]
then
  ./base/bundle.sh
fi

