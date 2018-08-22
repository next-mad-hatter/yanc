#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

YANC_DIR=${0%/*}/../
YANC_JRUBY_JAR=${YANC_JRUBY_JAR:-${YANC_DIR}/lib/vendor/jruby-complete.jar}

echo -n "Building native extensions:"
$("${YANC_DIR}"/lib/ext/build.sh)
if [ $? == 0 ]; then
  echo " ok."
else
  exit 1
fi

if [ -z "${YANC_FORCE_JRUBY+x}" ]; then
  echo -n "Checking for ruby installation: "
  $( ruby -e "if RUBY_VERSION >= \"1.9.3\" then print \"OK\" else exit(1) end" > /dev/null 2>&1 )
  if [ $? == 0 ]; then
    echo " ok."
    exit 0
  fi
  echo " not found."
fi

echo -n "Checking for jruby jar: "
if [ -f ${YANC_JRUBY_JAR} ]; then
  echo "ok."
  exit 0
fi
echo "not found."

echo "Trying to get jruby jar."
trap 'rm "${YANC_JRUBY_JAR}"' INT QUIT TERM
wget https://s3.amazonaws.com/jruby.org/downloads/1.7.16.1/jruby-complete-1.7.16.1.jar -O "${YANC_JRUBY_JAR}" && exit 0
rm -f "${YANC_JRUBY_JAR}"

