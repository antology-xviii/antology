#! /usr/bin/gawk -f
BEGIN { FS="::[[:space:]]*"; right = 0 }


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
        print "<p><h1>" TITLE ". Результаты теста</h1>"
        print "<p>"
        print "<form action=\"/illegal\" method=\"GET\">"
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
        print "<input type=\"checkbox\" checked disabled>"
        if ($2 ~ /\*$/)
        {
            print "<span class=\"correct\">" substr($2, 1, length($2) - 1) "</span> <big><big>+</big></big>"
            right++;
        }
        else
        {
            print "<span class=\"incorrect\">" $2 "</span> -"
        }
    }
    else
    {
        print "<input type=\"checkbox\" disabled>"
        if ($2 !~ /\*$/)
        {
            print $2
        }
        else
        {
            print "<span class=\"incorrect\">" substr($2, 1, length($2) - 1) "</span> <big><big>-</big></big>"
        }
    }
    answerid++;
    total++;
}

END {
    print "</ol>"
    print "</ol>"
    print "</form>
    print "<p>"
    print "<hr>"
    print "<p>"
    inflexion = "ов"
    if (right < 11 || right > 19)
    {
        if (right % 10 == 1)
            inflexion = "о";
        else if (right % 10 < 5)
            inflexion = "а";
    }
    print "<strong>Вы набрали " right " очк" inflexion " из " total "</strong>"
}
