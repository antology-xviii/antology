#! /usr/bin/gawk -f

BEGIN { FS="::[[:space:]]*"; 

print "<html>"
print "<head>"
print "<!-- -head -->"
}

$1 == "author" { AUTHOR = $2; 
	print "<meta name=\"DC.author\" content=\"" $2 "\">"
}

$1 == "title" { TITLE = $2;
	print "<title>" $2 "</title>"
}

$1 == "item" {
	if (itemid == 0)
	{
		print "<!-- +middle -->"
		print "</head>"
		print "</body>"
		print "<!-- -middle -->"
		if (AUTHOR)
		{
			print "<p>"
			print "<em>" AUTHOR "</em>"
		}
		if (TITLE)
		{
			print "<p>"
			print "<h1>" TITLE "</h1>"
		}
		print "<p>"
		print "<form action=\"/cgi-bin/dotest.cgi/" substr(FILENAME, 3) "\" method=\"POST\">"
		print "<table>"
	}
	print "<tr><td>" ++itemid ". <td colspan>" $2
	optionid = 1;
}

$1 == "option" {
	print "<tr><td><input type=\"checkbox\" name=\"item" itemid "." optionid++ "\"> "
    sub(/\*/, "", $2);
	print "<td>" $2;
}

END {
	print "<tr><td colspan=\"2\"><input type=\"submit\" value=\"Проверить результаты\">"
	print "<input type=\"reset\" value=\"Очистить\">"
	print "</table>"
	print "</form>"
	print "<!-- +foot -->"
	print "</body>"
	print "</html>"
}
