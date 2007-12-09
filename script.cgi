#! /bin/bash

SCRIPTDIR=/home/antology/data/
TAGCOLL=${SCRIPTDIR}/sample.coll
PEOPLECOLL=${SCRIPTDIR}/people.coll
export LC_CTYPE=ru_RU.koi8-r
export LC_COLLATE=ru_RU.koi8-r

cd $SCRIPTDIR

runscript="${SCRIPT_NAME##*/}"
runscript="${runscript%.cgi}.sh"

if ! [ -x "$runscript" ]; then
    echo "Status: 505 Internal Server Error" 
    echo ""
    exit 1
fi

echo "Status: 200 OK"
echo "Content-Type: text/html"
echo ""

fragment()
{
    sed -e '$!s/$/\\/' "$1"
}

echo "$QUERY_STRING" | "./$runscript" "$TAGCOLL" "$PATH_INFO" "$PEOPLECOLL" 2>&1 | sed -e \
"1,/<!-- -head -->/c\\
`fragment www/head.html`

/<!-- +middle -->/,/<!-- -middle -->/c\\
`fragment www/middle.html`

/<!-- +foot -->/,\$c\\
`fragment www/foot.html`

/<!-- split -->/c\\
`fragment www/split.html`

"
