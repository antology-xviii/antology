BEGIN { FS="[:,][[:space:]]+" }
{ 
    authortag = $1;
    sub(/^author::/, "", $1);
    picref = "picture::" $1;
    gsub(/@/, "\\&", $1);

    piccmd = "tagcoll grep -i \"" picref "\" " TAGCOLL
    piccmd | getline picture;
    close(piccmd);

    if (FNR == 1)
       print "<table id=masterdiv>";
    print "<tr><td valign=\"top\""
    print "<span class=\"menutitle\" onClick=\"SwitchMenu('sub" FNR "')\">" $1 "</span>";

    
    print "<ul class=\"submenu\" id=\"sub" FNR "\">"

    titlelist = "tagcoll grep  -g --remove-tags=\"!title::* && !author::*\" \"" authortag "\" " TAGCOLL
    while ((titlelist | getline) > 0)
    {
        # $3 shall always hold tiltle tag
        gsub(/@/, "\\&", $3);
        sub(/^title::/, "", $3);
        print "<li><a href=\"/cgi-bin/gettext.cgi/" $1 "\">" $3 "</a>"
    }
    close(titlelist)
    print "</ul>"
    print "<td valign=\"top\">"
    #if (picture)
        print "<img src=\"" picture "\" width=\"100\" height=\"121\" alt=\"" $1 "\" border=\"0\">";
}
END {
    print "</table>"
}
