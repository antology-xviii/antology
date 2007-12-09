#! /bin/bash

TAGCOLL="$1"

tagcoll reverse --remove-tags=!author::* "$TAGCOLL" | awk -vTAGCOLL="$TAGCOLL" -f contents.awk