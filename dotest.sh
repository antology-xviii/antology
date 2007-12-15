#! /bin/sh

SESSIONDIR="${TMPDIR:-/tmp}/.tests-${2#/}"

if ! [ -d "$SESSIONDIR" ]; then
    echo "<html>"
    echo "<!-- -head -->"
    echo "<!-- +middle -->"
    echo "<body>"
    echo "<!-- -middle -->"
    echo "<h1>������ ����� �� ����������</h1>"
    echo "<!-- +foot -->"
    echo "</html>"

    exit 4
fi


remaining_questions=`

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>���������� �����</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"

read
echo "$REPLY"

echo "<!-- +foot -->"

