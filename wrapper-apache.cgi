#! /bin/bash

SCRIPTDIR=/home/artem/src/antology
export LC_CTYPE=ru_RU.koi8-r
export LC_COLLATE=ru_RU.koi8-r
export LANG=en_US
[ -z "$QUERY_STRING"] && QUERY_STRING=
export QUERY_STRING

cd $SCRIPTDIR

runscript="${SCRIPT_NAME##*/}"
runscript="${runscript%.cgi}.pl"

if ! [ -x "$runscript" ]; then
    echo "Status: 404 Not Found" 
    echo ""
    exit 1
fi

exec ./$runscript 
