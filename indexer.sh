#! /bin/bash

COLLNAME="$1"

shift

[ -f "$COLLNAME" ] || touch "$COLLNAME"
for file; do
    echo "processing $file"
    onsgmls -oline "$file" | awk -f indexer.awk -f common.awk >"$COLLNAME".patch
    tagcoll copy -g -p "$COLLNAME".patch "$COLLNAME" >"$COLLNAME".new || exit 1
    mv -f "$COLLNAME".new "$COLLNAME"
    rm -f "$COLLNAME".patch
done