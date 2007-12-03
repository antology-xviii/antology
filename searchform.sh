#! /bin/sh

SCRIPTDIR=/home/artem/src/antology/
TAGCOLL=${SCRIPTDIR}/sample.coll

cd $SCRIPTDIR

makelistfield() {
    local id="$1"
    local list="$2"
    local label="$3"
    local multiple="$4"
    local andall="<input type=\"radio\" name=\"$id:mode\" checked value=\"all\"> все \
        <input type=\"radio\" name=\"$id:mode\" value=\"any\"> любая из"
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
echo "<title>Поиск текстов</title>"
echo "</head>"
echo "<body>"

echo "<form action=\"/cgi-bin/results.sh\" method=\"GET\">"
echo "<table>"

makelistfield author author Автор
makelistfield title title  Заглавие
makelistfield firstline firstline "Первая строка"
makelistfield kind category::kind "Литературный род"
maketextfield written "Год написания"
maketextfield published "Год первой публикации/постановки"
makelistfield theme annotation::theme "Темы" multiple
makelistfield metric metric::part "Метр/размер" multiple
makelistfield mscheme metric::scheme "Метрическая схема"
makelistfield rhyme rhyme "Рифмовка"
makelistfield place name::place "Географические названия"
makecomplexlistfield name "Имена собственные" "name::person исторические" "name::mythologic мифологические" "name::biblical библейские" "name::character персонажи"

echo "<tr><td><input type=\"submit\"><td><input type=\"reset\">"
echo "</table>"
echo "</form>"
echo "</body>"
echo "</html>"