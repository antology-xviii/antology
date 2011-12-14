#! /bin/bash

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Структура $2</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
SP_ENCODING=KOI8-R onsgmls -oline -oomitted ".$2" | awk -f structure.awk
rc=$?
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
exit $rc