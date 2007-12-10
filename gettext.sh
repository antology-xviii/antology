#! /bin/sh

IFS="&;" read -a parameters
  
HILITE="'()"
PASSPORT="#t"
 
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
    esac
done

SP_ENCODING=KOI8-R openjade -t sgml -bKOI8-R -V"(define use-passport $PASSPORT)" -V"(define hilite-names $HILITE)" -d mainconv.dssl ".$2"
