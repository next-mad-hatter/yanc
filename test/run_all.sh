#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

YANC_DIR=${0%/*}/../
LOG_DIR=${YANC_DIR}/log

trap "exit 1" INT QUIT TERM

mkdir -p "${LOG_DIR}" || { echo "Could not create log directory" && exit 1; }

echo -n "Computing nimbers samples"
"${YANC_DIR}"/test/run_tests.sh nimbers > "${LOG_DIR}"/nimbers.new 2>&1
echo .
echo -n "Running benchmarks"
"${YANC_DIR}"/test/run_tests.sh bench > "${LOG_DIR}"/bench.new 2>&1
echo .
echo -n "Producing interaction logs"
"${YANC_DIR}"/test/run_tests.sh interact > "${LOG_DIR}"/interact.new 2>&1
echo .
echo -n "Running strange tests"
"${YANC_DIR}"/test/run_tests.sh strange > "${LOG_DIR}"/strange.new 2>&1
echo .
echo -n "Running mean tests"
"${YANC_DIR}"/test/run_tests.sh mean > "${LOG_DIR}"/mean.new 2>&1
echo .
echo "Done."

