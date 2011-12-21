#! /bin/bash

SCRIPTDIR=/home/antology/data/
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

echo "At $PATH_INO $QUERY_STRING" >>/var/log/lighttpd/cgi.log
exec ./$runscript 2>>/var/log/lighttpd/cgi.log
