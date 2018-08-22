#!/bin/sh
#
# $File$
# $Author$
# $Date$
# $Revision$
#

cd "${0%/*}/../"

ripper-tags -R
ctags -Ra
