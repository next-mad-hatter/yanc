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

cat "${POS_DIR}"/voex | ${YANC_DIR}/bin/yanc.sh -v "${RULES_DIR}"/voex

