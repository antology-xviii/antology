#! /bin/bash

TAGCOLL="$1"
PEOPLECOLL="$3"

tagcoll grep "class::author" "$PEOPLECOLL" | awk -vPEOPLECOLL="$PEOPLECOLL" -vTAGCOLL="$TAGCOLL" -f urlencode.awk -f contents.awk