#! /bin/sh

SCRIPTDIR=/home/artem/src/antology/
TAGCOLL=${SCRIPTDIR}/sample.coll

cd $SCRIPTDIR

SEARCH_author="author::@"
SEARCH_title="title::@"
SEARCH_firstline="firstline::@"
SEARCH_kind="category::kind::@"
SEARCH_written="date::written::@"
SEARCH_published="(date::published::@ || date::performed::@)"
SEARCH_theme="annotation::theme::@"
SEARCH_place="name::place::@"
SEARCH_name="@"
SEARCH_rhyme="rhyme::@"
SEARCH_metric="metric::part::@"
SEARCH_mscheme="metric::scheme::@"

echo "$QUERY_STRING" | {
    IFS="&;" read -a parameters
   
    for idx in ${!parameters[*]}; do
        name="${parameters[$idx]%%=*}"        
        value="${parameters[$idx]#*=}"
        if [ -n "$value" ]; then
            if [ "$name" != "${name%:mode}" ]; then
                name="${name/[^[:alnum:]]/_}"
                typeset "$name"="$value"
            else
                value="${value//+/ }"
                value="`eval echo "$'${value//\%/\x}'"`"
                value="${value// /@#32;}"
                searchvar="SEARCH_$name"   
                searchterm="${!searchvar//@/$value}"
                qvar="Q_$name"
                if [ -n "$searchterm" ]; then
                    typeset "$qvar"="${!qvar:-(}${!qvar:+ && }$searchterm"
                fi
            fi
        fi
    done
    tagexpr=""
    for var in ${!Q_*}; do
        if [ -n "${!var}" ]; then
            modevar="${var#Q_}_mode"
            if [ "${!modevar}" = "any" ]; then
                typeset "$var"="${!var/ && / || }"
            fi
            tagexpr+="${tagexpr:+ && }${!var})"
        fi
    done
    echo "Status: 200 OK"
    echo "Content-Type: text/html"
    echo ""
    echo "<html>"
    echo "<head>"
    echo "<title>Результаты поиска</title>"
    echo "</head>"
    echo "<body>"
    tagcoll grep -i "$tagexpr" $TAGCOLL | awk -f jade.awk
    echo "</body>"
    echo "</html>"
}