#! /bin/sh

TAGCOLL="$1"

makelistfield() {
    local id="$1"
    local list="$2"
    local label="$3"
    local multiple="$4"
    local andall="<input type=\"radio\" name=\"${id}_mode\" checked value=\"all\"> ��� \
        <input type=\"radio\" name=\"${id}_mode\" value=\"any\"> ����� �� <br>"

    echo "<tr><td valign=\"top\">$label: <td valign=\"top\">"
    if [ -n "$multiple" ]; then
        echo "$andall"
        echo "<div class=\"scrolled\">"
        tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | sort -f | awk -vNAME="$id" '{ 
            sub(/^'"$list"'::/, ""); 
            val = $0;
                gsub(/@/, "\\&"); print "<input type=\"checkbox\" name=\"" NAME "\" value=\"" val "\">" $0 "<br>";
                }'
        echo "</div>"
    else
        echo "<select name=\"$id\" class=\"searchlist\">"
        echo "<option selected value=\"\">*</option>"
        tagcoll reverse --remove-tags="!$list::*" -i $TAGCOLL | sort -f | awk '{ 
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
    done    
    tagcoll reverse --remove-tags="$catexpr" -i $TAGCOLL | awk -vCATLIST="$*" 'BEGIN { 
            split(CATLIST, categories);
    }
    {
        val = $0;
        for (i = 1; i in categories; i += 2)
        {
            if (index($0, categories[i] "::") == 1)
            {
                label = categories[i + 1];
                $0 = substr($0, length(categories[i] "::") + 1);
                break;
            }
        }
        gsub(/@/, "\\&"); printf "<option value=\"%s\"> %s (%s)</option>\n", val, $0, label;
    }' | sort -f -k3
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
makecomplexlistfield name "����� �����������" "name::person ���." "name::mythologic ���." "name::biblical ����." "name::character ��������"
makelistfield addressee annotation::addressee �������

echo "<tr><td><input type=\"submit\" value=\"�����\"><td><input type=\"reset\" value=\"��������\">"
echo "</table>"
echo "</form>"
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
