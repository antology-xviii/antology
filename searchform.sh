#! /bin/sh

TAGCOLL="$1"

makelistfield() {
    local id="$1"
    local list="$2"
    local label="$3"
    local multiple="$4"
    local andall="<input type=\"radio\" name=\"$id:mode\" checked value=\"all\"> ��� \
        <input type=\"radio\" name=\"$id:mode\" value=\"any\"> ����� �� <br>"

    echo "<tr><td valign=\"top\">$label: <td valign=\"top\">"
    if [ -n "$multiple" ]; then
        echo "$andall"
        echo "<div class=\"scrolled\">"
        tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | awk -vNAME="$id" '{ 
            sub(/^'"$list"'::/, ""); 
            val = $0;
                gsub(/@/, "\\&"); print "<input type=\"checkbox\" name=\"" NAME "\" value=\"" val "\">" $0 "<br>";
                }'
        echo "</div>"
    else
        echo "<select name=\"$id\" class=\"searchlist\">"
        echo "<option selected value=\"\">*</option>"
        tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | awk '{ 
            sub(/^'"$list"'::/, ""); 
            val = $0;
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
    local catexpr=""
    local catre=""
    shift
    shift
    echo "<tr><td valign=\"top\">$label: <td valign=\"top\"><select name=\"$id\">"
    echo "<option selected value=\"\">*</option>"
    for category; do
        category="${category%% *}"
        catexpr="${catexpr}${catexpr:+ && }!$category::*"
        catre="${catre}${catre:+|}${category}"
    done    
    tagcoll reverse --remove-tags="$catexpr" -i $TAGCOLL | awk -vCATRE="^($catre)::" '{ 
    val = $0;
    sub(CATRE, ""); 
    gsub(/@/, "\\&"); print "<option value=\"" val "\">" $0 "</option>";
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
