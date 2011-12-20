BEGIN { 
    FS="|";   
    print "<table id=masterdiv>"; 
}

{ 
    print "<tr><td valign=\"top\">";
    if ($3)
        print "<img src=\"" $3 "\" width=\"100\" height=\"121\" alt=\"" $2  "\" border=\"0\">";
    print "<td valign=\"top\" width=\"85%\">"
    print "<a class=\"menutitle\" href=\"/cgi-bin/results.cgi?author=" urlencode($1) "\">" $2 "</a>";
}
END {
    print "</table>"
}
