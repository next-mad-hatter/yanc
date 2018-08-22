#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

DIR=${0%/*}

trap "exit 1" INT QUIT TERM

#MLTON=~/opt/multiMLton/trunk/build/bin/mlton
MLTON=${MLTON:-mlton}

"${MLTON}" "${DIR}"/yields.mlb || exit 1
     strip "${DIR}"/yields
"${MLTON}" "${DIR}"/nims.mlb   || exit 1
     strip "${DIR}"/nims

