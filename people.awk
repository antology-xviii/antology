#! /usr/bin/gawk -f

BEGIN { FS="[:,][[:space:]]+"; print "<table>"; }

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
    print "<tr>"
    print "<td>"
    largepic = findfield("largepicture::");
    if (largepic)
        print "<a href=\"javascript: Opn('/images/" largepic "', 500, 750)\">";
    picture = findfield("picture::");
    if (!picture)
        picture = largepic;
    gsub(/@#32;/, " ", $1);
    width = findfield("picturewidth::");
    if (width)
        width = "width=\"" width "\" ";
    print "<img src=\"/images/" picture "\" border=\"0\" alt=\"" $1 "\" align=\"right\" vspace=\"4\" hspace=\"8\"" width ">"
    if (largepic)
        print "</a>"
    print "<td><strong>"
    nc = split($1, names, " ");
    names[nc] = toupper(names[nc]);
    for (i = 1; i <= nc; i++)
        print names[i];
    print "</strong><br>"
    about = findfield("about::");
    gsub(/@/, "\\&", about);
    gsub(/&#32;/, " ", about);
    gsub(/&#44;/, ",", about);
    gsub(/&#40;/, "(", about);
    gsub(/&#41;/, ")", about);
    print about;
}

END {
    print "</table>"
}
