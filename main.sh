#! /bin/bash

TAGCOLL="$1"
PEOPLECOLL="$3"
CONCEPTFILE="www/concept.html"
ABOUTFILE="www/about.html"

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Электронная антология русской литературы XVIII века</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
echo "<table>"
echo "<tr>"
echo "<td valign=\"top\">"
echo "<h2 align=left>Концепция</h2>"

sed ' /<!-- +headline -->/,/<!-- -headline \([^<]*<[^>]*>\)\? -->/!d
s/<!-- -headline \([^<]*<[^>]*[^>]*>\) -->/\1/' $CONCEPTFILE
echo "<div align=right><a href=\"/cgi-bin/static.cgi/$CONCEPTFILE\">Читать текст концепции целиком &gt;&gt;</a></div>"
echo "<br><br><hr width=100% align=left>"
echo "<h2 align=right>Участники проекта</h2>"

tagcoll grep class::participant "$PEOPLECOLL" | iconv -f koi8-r -t utf-8 | msort -q -l -w -cr | iconv -f utf-8 -t koi8-r | head -n2 | gawk -f people.awk

echo "<div align=right><a href=\"/cgi-bin/people.cgi\">К полному списку участников &gt;&gt;</a></div>"

echo "<td width=\"20\">&nbsp;"

echo "<td valign=\"top\" width=\"50%\">"
echo "<H2 align=left>Оглавление</H2>"
./contents.sh "$TAGCOLL" "$2" "$PEOPLECOLL"

echo "</td></tr>"
echo "</table>"
echo "<!-- +foot -->"
echo "</html>"
