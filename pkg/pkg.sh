#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

SUBMISSION=${SUBMISSION:-ktdcw2_grp13_`date -u +%F_%H%M`}

if [ -z "${BUNDLE+x}" ]; then
  JRUBY_EXCLUDE="-x*/vendor/jruby*"
else
  JRUBY_EXCLUDE=""
fi

echo ${JRUBY_EXCLUDE}

cd "${0%/*}"
mkdir -p ../tmp/
ln -sf ../../src ./"${SUBMISSION}" || exit 1
zip -r "../tmp/${SUBMISSION}.zip" "${SUBMISSION}"/ -x"*/pkg/${SUBMISSION}/*" "$JRUBY_EXCLUDE" -x@./EXCLUDES
rm "${SUBMISSION}"

