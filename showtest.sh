#! /bin/bash

IFS="&;" read -a parameters

SESSIONDIR="${TMPDIR:-/tmp}/.tests-${2#/}"

ANSWERS=

if [ -d "$SESSIONDIR" ]; then
    for i in ${!parameters[*]}; do
        name="${parameters[$i]%%=*}"
        value="${parameters[$i]#*=}"
        echo "processing $name := $value" >&2
        case "$name" in
            qid)
                QID="$value"
                ;;
            answer*)
                if [ "$value" = "on" ]; then
                    name="${name#answer}"
                    ANSWERS="$ANSWERS $name"
                fi
                ;;
        esac
    done

    if [ -z "$QID" ]; then
        QID=1
    elif [ "$REQUEST_METHOD" = "GET" -o -z "$ANSWERS" ]; then
        true
    elif [ -f "$SESSIONDIR/q$QID" ]; then
        echo "$ANSWERS" >"$SESSIONDIR/a$QID"
        rm -f "$SESSIONDIR/q$QID"
        QID=$((QID + 1))       
    fi
    if [ -f "$SESSIONDIR/q$QID" ]; then
        cat "$SESSIONDIR/q$QID"
    else
        echo "/cgi-bin/dotest.cgi$2"
        exit 2
    fi

elif [ -f ".$2" ]; then
    SESSIONDIR="`mktemp -d -t .tests-XXXXXXXXXX`"
    chmod g+rx "$SESSIONDIR"
    ./showtest.awk -vDESTDIR="$SESSIONDIR" -vSESSION="${SESSIONDIR#/tmp/.tests-}" ".$2"
    echo "/cgi-bin/showtest.cgi/${SESSIONDIR#/tmp/.tests-}"
    exit 2
else
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

