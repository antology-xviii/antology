BEGIN { FS="#"; 
  CMD="SP_ENCODING=KOI8-R openjade -tsgml -b KOI8-R -Vself-reference=\"%s\" -V\"(define subreferences '(%s))\" -dlisting.dsssl \"%s\""
}
NF == 1 { 
    if (previous)
    {
        system(sprintf(CMD, previous, labels, previous));
        labels = ""
    }
    previous = $1
    next;
}
{ labels = labels (labels ? "" : " ") "\\\"" $2 "\\\""; }

END {
    if (previous)
    {
        system(sprintf(CMD, previous, labels, previous));
        labels = ""
    }
}
