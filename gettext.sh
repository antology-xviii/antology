#! /bin/sh

SCRIPTDIR=/home/artem/src/antology

cd $SCRIPTDIR

echo "Status: 200 OK"
echo "Content-Type: text/html"
echo ""
SP_ENCODING=KOI8-R openjade -t sgml -bKOI8-R -d mainconv.dssl ".$PATH_INFO"