#! /bin/sh

RDFPROC=rdfproc
RDFSTORE=rdf
RAPPER=rapper
AWK=awk

RDFS_SCHEMA=rdfs.rdfs
SUPPORT_SCHEMAS="dcterms.rdf dctype.rdf dcam.rdf foaf.rdf"
ANTOLOGY_SCHEMAS="service.rdf antology.rdf"

set -e
$RDFPROC -n $RDFSTORE parse $RDFS_SCHEMA
for sch in $SUPPORT_SCHEMAS; do
    $RDFPROC $RDFSTORE parse $sch
done

for sch in $ANTOLOGY_SCHEMAS; do
    $RAPPER $sch | $AWK -f inference.awk $RDFSTORE
done