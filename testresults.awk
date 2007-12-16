#! /usr/bin/gawk -f
BEGIN { FS="::[[:space:]]*"; }


$1 == "author" { AUTHOR = $2; }

$1 == "title" { TITLE = $2; }


$1 == "question" {
	if (qid != 0)
        print "</ol>"
    else
	{
        print "<html>"
        print "<head>"
        print "<!-- -head -->"
        if (TITLE)
            print "<title>" TITLE "</title>";
        if (AUTHOR)
            print "<meta name=\"DC.author\" content=\"" AUTHOR "\">";
        print "<!-- +middle -->"
        print "</head>"
        print "<body>"
        print "<!-- -middle -->"
        if (AUTHOR)
            print "<p><em>" AUTHOR "</em>"
        print "<p><h1>" TITLE ". ���������� �����</h1>"
        print "<p>"
        print "<ol>"
	}
    qid++;

    print "<li>" $2
    print "<ol>"
    aname = FILENAME;
    sub(/\/[\/]*$/. "", aname);
    aname = aname "/a" qid;
    getline answerline < aname;
    split(answerline, words, " ");
    delete ANSWERS;
    for (i = 1; i in words; i++)
        ANSWERS[words[i]] = 1;
    answerid = 1;
}

$1 == "answer" {
    print "<li>"
    if (ANSWERS[answerid])
    {
        if ($2 ~ /\*$/)
        {
            print "<strong><span class=\"correct\">" substr($2, 1, length($2) - 1) "</span></strong> +"
            right++;
        }
        else
        {
            print "<span class=\"incorrect\">" $2 "</span> -"
        }
    }
    else
    {
        if ($2 !~ /\*$/)
        {
            print $2
            right++;
        }
        else
        {
            print "<span class=\"incorrect\">" substr($2, 1, length($2) - 1) "</span> -"
        }
    }
    total++;
}

END {
    print "</ol>"
    print "</ol>"
    print "<p>"
    print "<hr>"
    print "<p>"
    print "<strong>�� ������� " right " ����� �� " total "</strong>"
}