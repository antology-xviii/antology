#! /usr/bin/gawk -f

BEGIN { FS="::[[:space:]]*"; has_picture = 1; }

{
    print >DESTDIR "/test"
}


function escape(str) {
    gsub(/&/, "\\&amp;", str);
    gsub(/</, "\\&lt;", str);
    gsub(/>/, "\\&gt;", str);
    gsub(/"/, "\\&quot;", str);
    return str;
}

$1 == "author" { AUTHOR = escape($2); }

$1 == "title" { TITLE = escape($2); }

function endquestion(qid, f) {
    print "<tr><td><input type=\"hidden\" name=\"qid\" value=\"" qid "\">" > f
	print "<input type=\"submit\" value=\"Дальше\">" > f
	print "<td><input type=\"reset\" value=\"Очистить\">" > f
    print "<td>&nbsp;" >f
	print "</table>" > f
	print "</form>" > f
	print "<!-- +foot -->" > f
	print "</body>" > f
	print "</html>" > f
    close(f);
}

$1 == "question" {
	if (qid != 0)
	{
        if (!has_picture)
            print "<td>&nbsp;" > qfile;
        endquestion(qid, qfile)
	}
    qid++;
    qfile = DESTDIR "/q" qid;
	answerid = 1;

    print "<html>" >qfile;
    print "<head>" >qfile;
    print "<!-- -head -->" >qfile;

    if (AUTHOR)
        print "<meta name=\"DC.author\" content=\"" AUTHOR "\">" >qfile;

    if (TITLE)
        print "<title>" TITLE "</title>" >qfile;

    print "<!-- +middle -->" >qfile
    print "</head>" >qfile
    print "</body>" >qfile
    print "<!-- -middle -->" >qfile
    if (AUTHOR)
    { 
        print "<p>" >qfile
        print "<em>" AUTHOR "</em>" >qfile
    }
    if (TITLE)
    {
        print "<p>" >qfile
        print TITLE >qfile
    }
    print "<p>" >qfile
    print "<form action=\"/cgi-bin/showtest.cgi/" SESSION "\" method=\"POST\">" >qfile
    print "<table>" >qfile
    print "<tr><td colspan=\"3\" align=\"left\"><em>Вопрос " qid "</em>" >qfile
    print "<tr><td colspan=\"3\" align=\"center\"><h2>" escape($2) "</h2>" >qfile
    has_picture = 1;
}

$1 == "picture" {
    if (answerid == 1)
        print "<tr><td colspan=\"3\" align=\"center\"><img alt=\"" escape($3) "\" src=\"/images/" $2 "\">" >qfile
    else
    {
        print "<td><img alt=\"" escape($3) "\" src=\"/images/" $2 "\">" >qfile
        has_picture = 1;
    }
    print "<br>" escape($3)
}


$1 == "answer" {
    if (!has_picture)
        print "<td>&nbsp;"
	print "<tr><td><input type=\"checkbox\" name=\"answer" answerid++ "\"> " >qfile
    sub(/\*/, "", $2);
	print "<td>" escape($2) >qfile;
    has_picture = 0;
}

END {
    endquestion(qid, qfile)
}
