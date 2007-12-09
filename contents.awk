BEGIN { FS="[:,][[:space:]]+" }
{ 
    authortag = $1;
    sub(/^author::/, "", $1);
    aboutref = "about::" $1;
    picref = "picture::" $1;
    gsub(/@/, "\\&", $1);
    aboutcmd = "tagcoll grep -i \"" aboutref "\" " TAGCOLL
    aboutcmd | getline lecture;
    close(aboutcmd);

    piccmd = "tagcoll grep -i \"" picref "\" " TAGCOLL
    piccmd | getline picture;
    close(piccmd);

    print "<DIV id=masterdiv>";
    print "<div class=\"menutitle\" onClick=\"SwitchMenu('sub" FNR "')\">";
    print "<span class=\"menutitle\">" $1 "</span>";

    print "[<a href=\"/cgi-bin/gettext.cgi/" lecture "\">лекция</a>]";
    if (picture)
        print "<img src=\"" picture "\" width=\"100\" height=\"121\" alt=\"" $1 "\" border=\"0\">";
    
    print "</div>"
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
    print "</span>"
    print "</div>"
}
