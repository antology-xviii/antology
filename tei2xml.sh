#! /bin/sh

OSX=osx
XSLTPROC=xsltproc

echo "processing $1" >&2
SP_FIXED_CHARSET=1 SP_ENCODING=utf-8 SP_BCTF=utf-8 osx -D. -Dwww -xid -xndata -xlower -xsdata-as-pis "$1" | \
    xsltproc normalize.xslt - >tmp.xml
jing -c ../tei5/xml/tei/custom/schema/relaxng/tei_all.rnc tmp.xml || exit 1
mkdir -p "$(dirname "xml/${1#texts/}")"
output="xml/${1#texts/}"
output="${output%.tei}.xml"
mv tmp.xml "$output"
