BEGIN { FS="[:,][[:space:]]+" }
{ 
    authortag = $1;
    sub(/^author::/, "", $1);
    aboutref = "about::" $1;
    gsub(/@/, "\\&", $1);
    print "<DIV id=masterdiv>";
    print "<div class=\"menutitle\" onClick=\"SwitchMenu('sub" FNR "')\">";
    print "<span class=\"menutitle\">" $1 "</span>";
    aboutcmd = "tagcoll grep -i \"" aboutref "\" " TAGCOLL
    aboutcmd | getline lecture;
    close(aboutcmd);
    print "[<a href=\"/cgi-bin/gettext.cgi/" lecture "\">������</a>]"
    print "</div>"
    print "<span class=\"submenu\" id=\"sub" FNR "\">"

    titlelist = "tagcoll grep  -g --remove-tags=\"!title::* && !author::*\" \"" authortag "\" " TAGCOLL
    while ((titlelist | getline) > 0)
    {
        # $3 shall always hold tiltle tag
        gsub(/@/, "\\&", $3);
        sub(/^title::/, "", $3);
        print "<a href=\"/cgi-bin/gettext.cgi/" $1 "\">" $3 "</a><br>"
    }
    close(titlelist)
    print "</span>"
    print "</div>"
}
