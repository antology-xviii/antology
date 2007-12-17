BEGIN { FS="[:,][[:space:]]+"; }

function findfield (start) {
    for (i = 2; i <= NF; i++)
    {
        if (index($i, start) == 1)
        {
            return substr($i, length(start) + 1);
        }
    }
    return ""
}

function dump() {
    if (!anything_found)
    {
        print "<strong>Найденные тексты:</strong>";
        print "<p>"
        print "<ul>";
        anything_found = 1;
    }
    else
    {
        print "</ul>"
    }
    hilite = "";
    for (f in FRAGS)
    {
        sub(/^NAME/, "", f);
        hilite = hilite (hilite ? "+" : "") f;
    }
    if (hilite)
        hilite = "?hilite=" hilite
    printf "<li>%s. <a href=\"/cgi-bin/gettext.cgi/%s%s\">%s</a>\n", AUTHOR, BASEFILE, hilite, TITLE;
    print "<ul>";
    for (f in REFS) {
        print "<li>";
        if (FRAGS[f])
        {
            print REFS[f];        
            printf "<a href=\"/cgi-bin/gettext.cgi/%s%s#%s\">...%s...</a>\n", BASEFILE, hilite, f, FRAGS[f];
        }
        else
        {
            printf "<a href=\"/cgi-bin/gettext.cgi/%s%s#%s\">%s</a>\n", BASEFILE, hilite, f, REFS[f];
        }
    }
    
    delete REFS;
    delete FRAGS;
}



$1 ~ /#/ {
    frag = findfield("fragment::");
    ref = findfield("ref::");
    if (frag || ref)
    {
        gsub(/@/, "\\&", frag);
        sub(/^.*#/, "", $1);
        REFS[$1] = ref;
        FRAGS[$1] = frag;
    }
    next
}


{
    if (AUTHOR) dump();
    AUTHOR = findfield("author::");
    TITLE = findfield("title::");
    gsub(/@/, "\\&", TITLE);
    gsub(/@/, "\\&", AUTHOR);
    AUTHOR = gensub(/^(.)[^&]*&32;(.)[^&]*&32;/, "\\1. \\2. ", 1, AUTHOR);
    BASEFILE = $1;
}

END {
    if (AUTHOR) dump();
    if (anything_found)
        print "</ul>";
    else
    {
        print "<p>К сожалению, по Вашему запросу ничего не найдено"
        exit 4
    }
}
