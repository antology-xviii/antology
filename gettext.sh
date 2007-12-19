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
    echo "<h1>Запрошенный вами документ не существует</h1>"
    echo "<!-- +foot -->"
    echo "</html>"
    exit 4
fi
 
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"        
    value="${parameters[$idx]#*=}"
    value="${value//+/ }"
    value="`eval echo "$'${value//\%/\x}'"`"
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

LEADING_PICTURES=""
INLINE_PICTURES=""
TRAILING_PICTURES=""
for p in `tagcoll reverse --remove-tags='!picture::*' sample.coll | tagcoll grep -i "${2#/}"`; do
    case "$p" in
        picture::leading::*)
        p="${p#picture::leading::}"
        name="${p%%::*}"
        descr="${p#*::}"
        descr="${descr//@/&}"
        descr="${descr//&#32;/ }"
        descr="${descr//&#44;/,}"
        descr="${descr//&#40;/(}"
        descr="${descr//&#41;/)}"
        descr="${descr//&#13;/\\carriage-return;}"
        LEADING_PICTURES="$LEADING_PICTURES (\"$name\" . \"$descr\")"
        ;;
        picture::inline::*)
        p="${p#picture::inline::}"
        name="${p%%::*}"
        descr="${p#*::}"
        descr="${descr//@/&}"
        descr="${descr//&#32;/ }"
        descr="${descr//&#44;/,}"
        descr="${descr//&#40;/(}"
        descr="${descr//&#41;/)}"
        descr="${descr//&#13;/\\carriage-return;}"
        INLINE_PICTURES="$INLINE_PICTURES (\"$name\" . \"$descr\")"
        ;;
        picture::trailing::*)
        p="${p#picture::trailing::}"
        name="${p%%::*}"
        descr="${p#*::}"
        descr="${descr//@/&}"
        descr="${descr//&#32;/ }"
        descr="${descr//&#44;/,}"
        descr="${descr//&#40;/(}"
        descr="${descr//&#41;/)}"
        descr="${descr//&#13;/\\carriage-return;}"
        TRAILING_PICTURES="$TRAILING_PICTURES (\"$name\" . \"$descr\")"
        ;;
    esac
done

SP_ENCODING=KOI8-R openjade -t sgml -bKOI8-R \
    -V"(define use-passport $PASSPORT)" -V"(define hilite-names $HILITE)" \
    -V"(define show-speaker-only $SHOW_SPEAKER)" \
    -V"(define leading-pictures '($LEADING_PICTURES))" \
    -V"(define inline-pictures '($INLINE_PICTURES))" \
    -V"(define trailing-pictures '($TRAILING_PICTURES))" \
    -Vcurrent-file="${2#/}" \
    -d mainconv.dssl ".$2"
