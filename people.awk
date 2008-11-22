#! /usr/bin/gawk -f

BEGIN { 
    FS = "|";
    print "<table>"
}

{
    
    print "<tr>"
    print "<td>"
    print "<a href=\"javascript: Opn('" $12 "', 500, 750)\">";
    if ($11)
        width = "width=\"" $11 "\" ";
    else
        width = "";
    print "<img src=\"" $10 "\" border=\"0\" alt=\"" \
            $13 "\" align=\"right\" vspace=\"4\" hspace=\"8\"" width ">"
    print "</a>";
    print "<td><strong>" $1 " " $2 " " toupper($3)"</strong><br>"
    if ($9) print $9 "<br>";
    if ($7) print $7 "<br>";
    if ($8) print $8 "<br>";
    print $4 "<br>";
    if ($5) print $5 "<br>";
    print $6
}

END {
    print "</table>";
}
