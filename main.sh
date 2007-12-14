#! /bin/bash

TAGCOLL="$1"
PEOPLECOLL="$3"
CONCEPTFILE="www/concept.html"

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Электронная антология русской литературы XVIII века</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
echo "<table>"
echo "<tr><td valign=\"top\" width=\"50%\">"
echo "<H2 align=left>Оглавление</H2>"
./contents.sh "$TAGCOLL" "$2" "$PEOPLECOLL"

echo "<td valign=\"top\">"
echo "<h2 align=right>Концепция</h2>"

sed ' /<!-- +headline -->/,/<!-- -headline \([^<]*<[^>]*>\)\? -->/!d
s/<!-- -headline \([^<]*<[^>]*[^>]*>\) -->/\1/' $CONCEPTFILE
echo "<div align=right><a href=\"/cgi-bin/static.cgi/$CONCEPTFILE\">Читать текст концепции целиком &gt;&gt;</a></div>"

cat <<'EOF'
<br><br><hr width=100% align=left>

 <h2 align=right>Участники проекта</h2>


 <table width=100% border=0>
 <tr>
 <td><b>Петр Евгеньевич БУХАРКИН</b><br>
  д. ф. н., профессор кафедры истории русской литературы филологического факультета СПбГУ

 </td>

   <td>
  <img src="images/portrait/buharkin-sm.jpg" width="100" alt="Бухаркин" border="0"><br><br>
 </td>
   </tr>
   <tr>
 <td> <b>Марина Валерьевна ПОНОМАРЕВА</b><br>
 старший преподаватель кафедры истории русской литературы факультета филологии и искусств
СПбГУ

 </td>

  <td>
  <img src="images/portrait/ponomareva-sm.jpg" width="100" alt="Пономарева" border="0"><br><br>
 </td>

 </tr>

 </table>

   <div align=right><a href="about.html>К полному списку участников &gt;&gt;</a></div>
EOF

echo "</td></tr>"
echo "</table>"
echo "<!-- +foot -->"
echo "</html>"
