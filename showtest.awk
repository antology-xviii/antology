#! /usr/bin/gawk -f

BEGIN { FS="::[[:space:]]*"; }

$1 == "author" { AUTHOR = $2; }

$1 == "title" { TITLE = $2; }

function endquestion(qid, f) {
    print "<tr><td><input type=\"hidden\" name=\"qid\" value=\"" qid "\">" > f
	print "<input type=\"submit\" value=\"Дальше\">" > f
	print "<td><input type=\"reset\" value=\"Очистить\">" > f
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
    print "<tr><td colspan=\"2\" align=\"left\"><em>Вопрос " qid "</em>" >qfile
    print "<tr><td colspan=\"2\" align=\"center\"><h2>" $2 "</h2>" >qfile
}

$1 == "picture" {
    print "<tr><td colspan=\"2\" align=\"center\"><img src=\"/images/" $2 "\">" >qfile
}


$1 == "answer" {
	print "<tr><td><input type=\"checkbox\" name=\"answer" answerid++ "\"> " >qfile
    sub(/\*/, "", $2);
	print "<td>" $2 >qfile;
}

{
    print >DESTDIR "/test"
}

END {
}
