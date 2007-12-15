#! /bin/sh

IFS="&;" | read -a parameters

SESSIONDIR="${TMPDIR:-/tmp}/.tests-${2#/}"

ANSWERS=

if [ -d "$SESSIONDIR" ]; then
    for i in ${!parameters[*]}; do
        name="${parameters[$i]}%%=*}"
        value="${parameters[$i]}#*=}"
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
    
    if [ -n "$QID" -a -f "$SESSIONDIR/q$QID" ]; then
        echo "$QID: $ANSWERS" >>"$SESSIONDIR/answers"
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
    ./showtest.awk -vDESTDIR="$SESSIONDIR" -vSESSION="${SESSIONDIR#/tmp/.tests-}" ".$2"
    echo "/cgi-bin/showtest.cgi/${SESSIONDIR#/tmp/.tests-}"
    exit 2
else
    echo "<html>"
    echo "<!-- -head -->"
    echo "<!-- +middle -->"
    echo "<body>"
    echo "<!-- -middle -->"
    echo "<h1>������ ����� �� ����������</h1>"
    echo "<!-- +foot -->"
    echo "</html>"
    exit 4
fi

