#! /bin/bash

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Структура $2</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
recoded="`echo "$2" | iconv -f utf8 -t koi8-r`"
SP_ENCODING=KOI8-R onsgmls -oline -oomitted ".$recoded" | awk -f structure.awk
rc=$?
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
exit $rc