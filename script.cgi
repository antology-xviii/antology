#! /bin/bash

SCRIPTDIR=/home/artem/src/antology/
TAGCOLL=${SCRIPTDIR}/sample.coll
PEOPLECOLL=${SCRIPTDIR}/people.coll
export LC_CTYPE=ru_RU.koi8-r
export LC_COLLATE=ru_RU.koi8-r

cd $SCRIPTDIR

runscript="${SCRIPT_NAME##*/}"
runscript="${runscript%.cgi}.sh"

if ! [ -x "$runscript" ]; then
    echo "Status: 404 Not Found" 
    echo ""
    exit 1
fi

fragment()
{
    sed -e '$!s/$/\\/' "$1"
}

if [ "$REQUEST_METHOD" = "POST" ]; then
  got_bytes="`head -c"$CONTENT_LENGTH"`"
  QUERY_STRING="${QUERY_STRING}${QUERY_STRING:+&}${got_bytes}" 
fi

OUTFILE="`mktemp -t`"
ERRFILE="`mktemp -t`"

trap "rm -f $OUTFILE $ERRFILE" EXIT

echo "$QUERY_STRING" | "./$runscript" "$TAGCOLL" "$PATH_INFO" "$PEOPLECOLL" >$OUTFILE 2>$ERRFILE 

case "$?" in
    0)
        echo "Status: 200 OK"
        echo "Content-Type: text/html"
        echo ""
        ;;
    1)
        echo "Status: 500 Internal Server Error"
        echo "Content-Type: text/html"
        echo ""

        ;;
    2)
        echo "Location: $(< $OUTFILE)"
        echo ""
        cat $ERRFILE >&2
        exit 0
        ;;
    4)
        echo "Status: 404 Not Found"
        echo "Content-Type: text/html"
        echo ""
        ;;
    *)
        rc="$?"
        echo "Status: 500 Internal Server Error"
        echo "Content-Type: text/plain"
        echo ""
        echo "Script exit code is $rc"
        cat $ERRFILE
        echo "Script exit code is $rc" >&2
        cat $ERRFILE >&2
        exit 1
        ;;
esac

sed -e \
"1,/<!-- -head -->/c\\
`fragment www/head.html`

/<!-- +middle -->/,/<!-- -middle -->/c\\
`fragment www/middle.html`

/<!-- +foot -->/,\$c\\
`fragment www/foot.html`

/<!-- split -->/c\\
`fragment www/split.html`

" $OUTFILE
cat $ERRFILE >&2
exit 0