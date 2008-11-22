#! /bin/sh

TAGCOLL="$1"

IFS="&;" read -a parameters
  
HILITE="'()"
PASSPORT="#t"
SHOW_SPEAKER="#f"

if ! [ -f ".$2" ]; then
    echo "<html>"
    echo "<!-- -head -->"
    echo "<!-- +middle -->"
    echo "<body>"
    echo "<!-- -middle -->"
    echo "<h1>����������� ���� �������� �� ����������</h1>"
    echo "<!-- +foot -->"
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
            HILITE="'($value)"
            ;;
        passport)
            if [ "$value" = "no" ]; then
                PASSPORT="#f"
            fi
            ;;
        show-speaker-only)
            if [ -n "$value" ]; then
                SHOW_SPEAKER="\"$value\""
            fi
    esac
done



LEADING_PICTURES="$(psql -A -t -q -c "select '(\"' || url || '\" . \"' || description || '\")' from text_pictures where kind = 'leading';")"
INLINE_PICTURES="$(psql -A -t -q -c "select '(\"' || url || '\" . \"' || description || '\")' from text_pictures where kind = 'inline';")"
TRAILING_PICTURES="$(psql -A -t -q -c "select '(\"' || url || '\" . \"' || description || '\")' from text_pictures where kind = 'trailing';")"

SP_ENCODING=KOI8-R openjade -t sgml -bKOI8-R \
    -V"(define use-passport $PASSPORT)" -V"(define hilite-names $HILITE)" \
    -V"(define show-speaker-only $SHOW_SPEAKER)" \
    -V"(define leading-pictures '($LEADING_PICTURES))" \
    -V"(define inline-pictures '($INLINE_PICTURES))" \
    -V"(define trailing-pictures '($TRAILING_PICTURES))" \
    -Vcurrent-file="${2#/}" \
    -d mainconv.dssl ".$2"
