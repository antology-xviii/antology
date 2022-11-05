#! /bin/bash

MODE="$1"
shift

(for file; do
    echo "processing $file" >&2
    SP_ENCODING=KOI8-R osx -D. -xid -bkoi8-r "$file" | \
        xsltproc --stringparam docid "`echo "$file" | iconv -f koi8-r -t utf-8`" --stringparam operation "$MODE" indexer.xslt -
done)  | psql --quiet -f - antology
