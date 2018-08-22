#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

YANC_DIR=${0%/*}/../../
RULES_DIR=${YANC_DIR}/data/rules/
POS_DIR=${YANC_DIR}/data/positions/

${YANC_DIR}/bin/yanc.sh -m 20 -v -e "${RULES_DIR}"/laskers_nim "${POS_DIR}/readln_first"

