#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

YANC_DIR=${0%/*}/../
YANC_JRUBY_JAR=${YANC_JRUBY_JAR:-${YANC_DIR}/lib/vendor/jruby-complete.jar}

if [ -z "${YANC_FORCE_JRUBY+x}" ]; then
  $( ruby -e "if RUBY_VERSION >= \"1.9.3\" then print \"OK\" else exit(1) end" > /dev/null 2>&1 )
  if [ $? == 0 ]; then
    exec "${YANC_DIR}/lib/yanc.rb" "$@"
  fi
fi

if [ -e ${YANC_JRUBY_JAR} ]; then
  JRUBY_OPTS="${JRUBY_OPTS} --1.9" exec java -jar "${YANC_JRUBY_JAR}" --1.9 "${YANC_DIR}"/lib/yanc.rb "$@"
fi

