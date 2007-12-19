BEGIN { print "<pre>" }

/^L/ {
    if (!$2 && !skipping)
        printf "\n%s", INDENT;
    else if (!mainfile)
    {
        mainfile = $2;
    }
    else if (skipping)
    {
        if ($2 == mainfile)
        {
            skipping = 0;
            printf "\n%s", INDENT;
        }
    }
    else
    {
        skipping = 1;
    }
    next;
}

/^o/ {
    omit_next = 1;
    next
}

/^A/ {
    if (omit_next || $2 == "IMPLIED")
        omit_next = 0;
    else
    {
        aname = substr($1, 2);
        $1 = "";
        $2 = "";
        sub(/^[[:space:]]*/, "");
        gsub(/&/, "\\&amp;");
        gsub(/"/, "\\&quot;");
        gsub(/\\%/, "\\&#");
        $0 = gensub(/\\\|\[([^[:space:]]+)[[:space:]]*\]\\\|/, "\\&amp;\\1;", "g");
        gsub(/\\\\/, "\\\\");
        ATTRIBUTES[aname] = $0
    }
    next
}

skipping { next }

/^\(/ {
    INDENT = INDENT "  ";
    if (omit_next)
        omit_next = 0;
    else
    {
        printf "<span class=\"structag\">&lt;%s", substr($1, 2);
        for (a in ATTRIBUTES)
        {
            printf " %s=&quot;<span class=\"structattr\">%s</span>&quot;", a, ATTRIBUTES[a];
        }
        printf "&gt;</span>";
        delete ATTRIBUTES;
    }
    next
}

/^\)/ {
    INDENT = substr(INDENT, 3);
    if (omit_next)
        omit_next = 0;
    else
    {
        printf "<span class=\"structag\">&lt;/%s&gt;</span>", substr($1, 2);
    }
    next
}

/^-/ {
    $1 = substr($1, 2);
    sub(/^[[:space:]]*/, "");
    gsub(/&/, "\\&amp;");
    gsub(/</, "\\&lt;");
    gsub(/>/, "\\&gt;");
    gsub(/"/, "\\&quot;");
    gsub(/\\%/, "\\&amp;#");
    gsub(/\\n/, "\n" INDENT);
    $0 = gensub(/\\\|\[([^[:space:]]+)[[:space:]]*\]\\\|/, "<span class=\"structent\">\\&amp;\\1;</span>", "g");
    gsub(/\\\\/, "\\\\");
    printf "%s", $0
}


/^&/ { printf "<class %s;", $0; next; }

END { print "</pre>"; }

    
