#! /bin/bash

SESSIONDIR="${TMPDIR:-/tmp}/.tests-${2#/}"

if ! [ -d "$SESSIONDIR" ]; then
    echo "<html>"
    echo "<!-- -head -->"
    echo "<!-- +middle -->"
    echo "<body>"
    echo "<!-- -middle -->"
    echo "<h1>Такого теста не существует</h1>"
    echo "<!-- +foot -->"
    echo "</html>"

    exit 4
fi

unanswered="`echo $SESSIONDIR/q*`"
if [ "$unanswered" != "$SESSIONDIR/q*" ]; then
    unanswered="${unanswered%% *}"
    echo "/cgi-bin/showtest.cgi${2}?qid=${unanswered#$SESSIONDIR/q}"   
    exit 2
fi

awk -f ./testresults.awk "$SESSIONDIR/test"
rc=$?

rm -rf "$SESSIONDIR"

exit $rc
