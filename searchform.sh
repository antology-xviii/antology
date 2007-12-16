#! /bin/sh

TAGCOLL="$1"

makelistfield() {
    local id="$1"
    local list="$2"
    local label="$3"
    local multiple="$4"
    local andall="<input type=\"radio\" name=\"$id:mode\" checked value=\"all\"> ��� \
        <input type=\"radio\" name=\"$id:mode\" value=\"any\"> ����� �� <br>"

    if [ -n "$multiple" ]; then
        echo "<div class=\"scrolled\">"
        echo "$andall"
        tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | awk -vNAME="$id" '{ 
            sub(/^'"$list"'::/, ""); 
            val = $0;
            if (length($0) > 80)
                $0 = substr($0, 1, 80) "...";
                gsub(/@/, "\\&"); print "<input type=\"checkbox\" name=\"" NAME "\" value=\"" val "\">" $0 "<br>";
                }'
        echo "</div>"
    else
        echo "<tr><td valign=\"top\">$label: <td valign=\"top\"><select name=\"$id\">"
        echo "<option selected value=\"\">*</option>"
        tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | awk '{ 
            sub(/^'"$list"'::/, ""); 
            val = $0;
            if (length($0) > 80)
                $0 = substr($0, 1, 80) "...";
                gsub(/@/, "\\&"); print "<option value=\"" val "\">" $0 "</option>";
                }'
        echo "</select>"
    fi
}

makecomplexlistfield() {
    local id="$1"
    local label="$2"
    local category
    local catlabel
    shift
    shift
    echo "<tr><td valign=\"top\">$label: <td valign=\"top\"><select name=\"$id\">"
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
    echo "<tr><td valign=\"top\">$label: <td valign=\"top\"><input type=\"text\" name=\"$id\">"
}

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>����� �������</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"

echo "<!-- -middle -->"
echo "<h2 align=\"left\">����� �������</h2>"
echo "<form action=\"/cgi-bin/results.cgi\" method=\"GET\">"
echo "<table>"

makelistfield author author �����
makelistfield title title  ��������
makelistfield origtitle origtitle  "�������� ��� ������ ����������"
makelistfield firstline firstline "������ ������"
makelistfield kind category::kind "������������ ���"
maketextfield written "��� ���������"
maketextfield published "��� ������ ����������/����������"
makelistfield publisher publisher "����� ������ ����������"
makelistfield theme annotation::theme "����" multiple
makelistfield metric metric::part "����/������" multiple
makelistfield mscheme metric::scheme "����������� �����"
makelistfield rhyme rhyme "��������"
makelistfield place name::place "�������������� ��������"
makecomplexlistfield name "����� �����������" "name::person ������������" "name::mythologic ��������������" "name::biblical ����������" "name::character ���������"
makelistfield addressee annotation::addressee �������

echo "<tr><td><input type=\"submit\" value=\"�����\"><td><input type=\"reset\" value=\"��������\">"
echo "</table>"
echo "</form>"
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
