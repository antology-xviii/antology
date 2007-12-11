BEGIN { FS="[:,][[:space:]]+" }
{ 
    authortag = "author::" $1;
    gsub(/@/, "\\&", $1);

    for (i = 2; i <= NF; i++)
    {
        if (index($i, "picture::") == 1)
        {
            picture = substr($i, length("picture::") + 1);
            break;
        }
    }

    if (FNR == 1)
       print "<table id=masterdiv>";
    print "<tr><td valign=\"top\" width=\"85%\">"
    print "<span class=\"menutitle\" onClick=\"SwitchMenu('sub" FNR "')\">" $1 "</span>";

    
    print "<ul class=\"submenu\" id=\"sub" FNR "\">"

    titlelist = "tagcoll grep  -g --remove-tags=\"!title::* && !date::written::* && !author::*\" \"" authortag "\" " TAGCOLL \
		" | iconv -f koi8-r -t utf-8 | msort -l -tdate::written:: -q 2>/dev/null | iconv -f utf-8 -t koi8-r"
    while ((titlelist | getline) > 0)
    {
        # $4 shall always hold tiltle tag
        gsub(/@/, "\\&", $4);
        sub(/^title::/, "", $4);
	sub(/^date::written::/, "", $3);
        print "<li><a href=\"/cgi-bin/gettext.cgi/" $1 "\">" $4 "</a>"
    }
    close(titlelist)
    print "</ul>"
    print "<td valign=\"top\">"
    #if (picture)
        print "<img src=\"/images/" picture "\" width=\"100\" height=\"121\" alt=\"" $1 "\" border=\"0\">";
}
END {
    print "</table>"
}
