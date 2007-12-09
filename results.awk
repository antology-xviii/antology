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

$1 ~ /#/ {
    frag = findfield("fragment::");
    if (frag)
    {
        gsub(/@/, "\\&", frag);
        basefile = $1;
        sub(/#[^#]*$/, "", basefile);
        chunk = $1;
        sub(/^.*#/, "", chunk);
        ref = findfield("ref::");
        print "<li>" ref;
        printf "<a href=\"/cgi-bin/gettext.cgi/%s#%s\">...%s...</a>\n", basefile, chunk, frag;
    }
    next
}


{
    author = findfield("author::");
    title = findfield("title::");
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
    gsub(/@/, "\\&", title);
    gsub(/@/, "\\&", author);
    author = gensub(/^(.)[^&]*&32;(.)[^&]*&32;/, "\\1. \\2. ", 1, author);
    printf "<li>%s. <a href=\"/cgi-bin/gettext.cgi/%s\">%s</a>\n", author, $1, title;
    print "<ul>"
}

END {
    if (anything_found)
        print "</ul>";
    else
    {
        print "<p>К сожалению, по Вашему запросу ничего не найдено"
    }
}
