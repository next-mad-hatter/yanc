#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

YANC_DIR=${0%/*}/../
TESTS_DIR=${YANC_DIR}/test/

if [[ $# == 0 ]]; then
  echo "Usage: `basename ${0}` test_type(s)"
  exit 1
fi

trap "exit 1" INT QUIT TERM

for t in $@; do
  for f in "${TESTS_DIR}/$t"/*.sh; do
    echo
    echo "==========================================================="
    echo
    echo "Running " "$f"
    echo
    echo "==========================================================="
    time "$f"
  done
done
