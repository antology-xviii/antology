#! /bin/sh

OSX=osx
XSLTPROC=xsltproc

SP_FIXED_CHARSET=1 SP_ENCODING=utf-8 SP_BCTF=utf-8 osx -D. -Dwww -xid -xndata -xlower -xsdata-as-pis "$1" | \
    xsltproc normalize.xslt -