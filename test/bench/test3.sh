#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

YANC_DIR=${0%/*}/../../
RULES_DIR=${YANC_DIR}/data/rules/

"${YANC_DIR}"/bin/yanc.sh -d -m 100 "${RULES_DIR}"/test.3 > /dev/null
