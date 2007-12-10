#! /bin/sh

IFS="&;" read -a parameters
   
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"        
    value="${parameters[$idx]#*=}"
    value="${value//+/ }"
    value="`eval echo "$'${value//\%/\x}'"`"
    case "$name" in
        hilite) 
            HILITE="-V(define hilite-names '($value))"
            ;;
        passport)
            if [ "$value" = "no" ]; then
                PASSPORT="-V(define use-passport #f)"
            fi
            ;;
    esac
done

SP_ENCODING=KOI8-R openjade -t sgml -bKOI8-R "$PASSPORT" "$HILITE" -d mainconv.dssl ".$2"