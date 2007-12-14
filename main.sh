#! /bin/bash

TAGCOLL="$1"
PEOPLECOLL="$3"
CONCEPTFILE="www/concept.html"

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>����������� ��������� ������� ���������� XVIII ����</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
echo "<table>"
echo "<tr><td valign=\"top\" width=\"50%\">"
echo "<H2 align=left>����������</H2>"
./contents.sh "$TAGCOLL" "$2" "$PEOPLECOLL"

echo "<td valign=\"top\">"
echo "<h2 align=right>���������</h2>"

sed ' /<!-- +headline -->/,/<!-- -headline \([^<]*<[^>]*>\)\? -->/!d
s/<!-- -headline \([^<]*<[^>]*[^>]*>\) -->/\1/' $CONCEPTFILE
echo "<div align=right><a href=\"/cgi-bin/static.cgi/$CONCEPTFILE\">������ ����� ��������� ������� &gt;&gt;</a></div>"

cat <<'EOF'
<br><br><hr width=100% align=left>

 <h2 align=right>��������� �������</h2>


 <table width=100% border=0>
 <tr>
 <td><b>���� ���������� ��������</b><br>
  �. �. �., ��������� ������� ������� ������� ���������� ��������������� ���������� �����

 </td>

   <td>
  <img src="images/portrait/buharkin-sm.jpg" width="100" alt="��������" border="0"><br><br>
 </td>
   </tr>
   <tr>
 <td> <b>������ ���������� ����������</b><br>
 ������� ������������� ������� ������� ������� ���������� ���������� ��������� � ��������
�����

 </td>

  <td>
  <img src="images/portrait/ponomareva-sm.jpg" width="100" alt="����������" border="0"><br><br>
 </td>

 </tr>

 </table>

   <div align=right><a href="about.html>� ������� ������ ���������� &gt;&gt;</a></div>
EOF

echo "</td></tr>"
echo "</table>"
echo "<!-- +foot -->"
echo "</html>"
