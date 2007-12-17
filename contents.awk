BEGIN { FS="[:,][[:space:]]+" }

function findfield (start,  i) {
    for (i = 2; i <= NF; i++)
    {
        if (index($i, start) == 1)
        {
            return substr($i, length(start) + 1);
        }
    }
    return ""
}

{ 
    authortag = "author::" $1;
    gsub(/@/, "\\&", $1);

    picture = findfield("picture::");
    sortkey = findfield("sortkey::");

    if (sortkey)
    {
        split(sortkey, captions, /%/);
        gsub(/%/, "::\" -o l -t\"", sortkey);
        sortkey = "-t\"" sortkey "::\" -o l";
    }

    an = split($1, authornames, /&#32;/);
    authornames[an] = toupper(authornames[an]);
    $1 = "";
    for (i = 1; i <= an; i++)
    {
       $1 = $1 ($1 ? " " : "") authornames[i];
    }
    

    if (FNR == 1)
       print "<table id=masterdiv>";
    print "<tr><td valign=\"top\">";
    if (picture)
        print "<img src=\"/images/" picture "\" width=\"100\" height=\"121\" alt=\"" $1 "\" border=\"0\">";
    print "<td valign=\"top\" width=\"85%\">"
    print "<span class=\"menutitle\" onClick=\"SwitchMenu('sub" FNR "')\">" $1 "</span>";

    
    print "<ul class=\"submenu\" id=\"sub" FNR "\">"

    titlelist = "tagcoll grep --implications-from=implications --redundant \"" authortag "\" " TAGCOLL \
		" | iconv -f koi8-r -t utf-8 | msort -l " sortkey " -q 2>/dev/null | iconv -f utf-8 -t koi8-r";
    while ((titlelist | getline) > 0)
    {
        for (i = 1; i in captions; i++)
        {
            curcaption = findfield("caption::" captions[i] "::");
            if (prevcaption[i] != curcaption)
            {
                if (prevcaption[i])
                    print "</ul>"
                prevcaption[i] = curcaption;
                for (j = i + 1; j in captions; j++)
                {
                    if (prevcaption[j])
                        print "</ul>";
                    prevcaption[j] = findfield("caption::" captions[j] "::");
                }
                for (; i in captions; i++)
                {
                    if (prevcaption[i])
                    {
                        curcaption = prevcaption[i];
                        gsub(/@/, "\\&", curcaption);
                        print "<li><span class=\"menutitle\" onClick=\"SwitchMenu('subsub" ++globalidx "')\">" curcaption "</span>";
                        print "<ul class=\"submenu\" id=\"subsub" globalidx "\">";
                    }
                }
            }
            
        }

        title = findfield("title::")
        gsub(/@/, "\\&", title);
        sub(/^title::/, "", title);
        print "<li><a href=\"/cgi-bin/gettext.cgi/" urlencode_path($1) "\">" title "</a>"
    }
    close(titlelist);
    for (i = 1; i in captions; i++)
    {
        if (prevcaption[i])
            print "</ul>";
    }
    delete prevcaption;
    print "</ul>"
}
END {
    print "</table>"
}
