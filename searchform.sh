#! /bin/sh

SCRIPTDIR=/home/artem/src/antology/
TAGCOLL=${SCRIPTDIR}/sample.coll

cd $SCRIPTDIR

makelistfield() {
    local id="$1"
    local list="$2"
    local label="$3"
    local multiple="$4"
    local andall="<input type=\"radio\" name=\"$id:mode\" checked value=\"all\"> ��� \
        <input type=\"radio\" name=\"$id:mode\" value=\"any\"> ����� ��"
    echo "<tr><td>$label: <td>${multiple:+$andall}<select ${multiple:+multiple} name=\"$id\">"
    if [ -z "$multiple" ]; then
        echo "<option selected value=\"\">*</option>"
    fi
    tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | awk '{ 
    sub(/^'"$list"'::/, ""); 
    val = $0;
    gsub(/@/, "\\&"); print "<option value=\"" val "\">" $0 "</option>";
    }'
    echo "</select>"
}

makecomplexlistfield() {
    local id="$1"
    local label="$2"
    local category
    local catlabel
    shift
    shift
    echo "<tr><td>$label: <td><select name=\"$id\">"
    echo "<option selected value=\"\">*</option>"
    for category; do
        catlabel="${category#* }"
        category="${category%% *}"       
        echo "<optgroup label=\"$catlabel\">"
        tagcoll reverse --remove-tags="!$category::*" -i $TAGCOLL | awk '{ 
    sub(/^'"$category"'::/, ""); 
    val = $0;
    gsub(/@/, "\\&"); print "<option value=\"'"$category"'::" val "\">" $0 "</option>";
    }'        
    done
}

maketextfield() {
    local id="$1"
    local label="$2"
    echo "<tr><td>$label: <td><input type=\"text\" name=\"$id\">"
}

echo "Content-Type: text/html"
echo "Status: 200 OK"
echo 
echo "<html>"
echo "<head>"
echo "<title>����� �������</title>"
echo "</head>"
echo "<body>"

echo "<form action=\"/cgi-bin/results.sh\" method=\"GET\">"
echo "<table>"

makelistfield author author �����
makelistfield title title  ��������
makelistfield firstline firstline "������ ������"
makelistfield kind category::kind "������������ ���"
maketextfield written "��� ���������"
maketextfield published "��� ������ ����������/����������"
makelistfield theme annotation::theme "����" multiple
makelistfield metric metric::part "����/������" multiple
makelistfield mscheme metric::scheme "����������� �����"
makelistfield rhyme rhyme "��������"
makelistfield place name::place "�������������� ��������"
makecomplexlistfield name "����� �����������" "name::person ������������" "name::mythologic ��������������" "name::biblical ����������" "name::character ���������"

echo "<tr><td><input type=\"submit\"><td><input type=\"reset\">"
echo "</table>"
echo "</form>"
echo "</body>"
echo "</html>"