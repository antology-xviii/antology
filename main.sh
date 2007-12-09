#! /bin/bash

TAGCOLL="$1"
CONCEPTFILE="www/concept.html"

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Электронная антология русской литературы XVIII века</title>"
echo "<!-- -middle -->"
echo "</head>"
echo "<body>"
echo "<table>"
echo "<tr><td valign=\"top\">"
echo "<H2 align=left>Оглавление</H2>"
./contents.sh "$TAGCOLL"

echo "<td valign=\"top\">"
echo "<h2 align=right>Концепция</h2>"

sed '/<!-- +headline -->/,/<!-- -headline -->/!d' $CONCEPTFILE
echo "..."
echo "<div align=right><a href=\"/cgi-bin/static.cgi/" $CONCEPTFILE "\">Читать текст концепции целиком &gt;&gt;</a></div>"

echo "</table>"
echo "<!-- +foot -->"
echo "</html>"