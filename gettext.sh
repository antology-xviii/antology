#! /bin/bash

RDFSTORE="$1"
CACHEDIR=cache

IFS="&;" read -a parameters
  
HILITE=""
COLOPHON="1"
ONLY_SPEAKER=""

if ! [ -f "cache/$2" ]; then
    echo "<html>"
    echo "<head></head>"
    echo "<body>"
    echo "<h1>Запрошенный вами документ не существует</h1>"
    echo "</body>"
    echo "</html>"
    exit 4
fi
 
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"        
    value="${parameters[$idx]#*=}"
    value="${value//+/ }"
    value="$(eval echo "$'${value//\%/\x}'")"
    case "$name" in
        hilite) 
            HILITE="$value"
            ;;
        colophon)
            if [ "$value" = "no" ]; then
                COLOPHON="0"
            fi
            ;;
        only-speaker)
            if [ -n "$value" ]; then
                ONLY_SPEAKER="$value"
            fi
    esac
done

$XSLTPROC --stringparam path_info "$PATH_INFO" \
    --stringparam basepath $(dirname "$SCRIPT_NAME") \
    --stringparam hilite "$HILITE" \
    --param colophon "$COLOPHON" \
    --stringparam only-speaker "$ONLY_SPEAKER" \
    --stringparam base-uri "$PATH_INFO" \
    formatter.xslt "cache/$2"

