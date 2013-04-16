#! /bin/bash

DBNAME="$1"

makelistfield() {
    local id="$1"
    local query="$2"
    local label="$3"
    local multiple="$4"
    local andall="<input type=\"radio\" name=\"${id}_mode\" checked value=\"all\"> все \
        <input type=\"radio\" name=\"${id}_mode\" value=\"any\"> любая из <br>"

    echo "<tr><td valign=\"top\">$label: <td valign=\"top\">"
    if [ -n "$multiple" ]; then
        echo "$andall"
        echo "<div class=\"scrolled\">"
        psql -A -t -q antology -c "$query" | gawk -F\| -vNAME="$id" '{ 
                 gsub(/&/, "\\&amp;"); gsub(/"/, "\\&quot;"); gsub(/</, "\\&lt;"); gsub(/>/, "\\&gt;"); 
                 print "<input type=\"checkbox\" name=\"" NAME "\" value=\"" ($1 ? $1 : $2) "\">" ($2 ? $2 : $1) "<br>";
                }'
        echo "</div>"
    else
        echo "<select name=\"$id\" class=\"searchlist\">"
        echo "<option selected value=\"\">*</option>"
        psql -A -t -q antology -c "$query" | gawk -F\| '{ 
                gsub(/&/, "\\&amp;"); gsub(/"/, "\\&quot;"); gsub(/</, "\\&lt;"); gsub(/>/, "\\&gt;"); 
                print "<option value=\"" ($1 ? $1 : $2) "\">" ($2 ? $2 : $1) "</option>";
                }'
        echo "</select>"
    fi
}

makecomplexlistfield() {
    local id="$1"
    local query="$2"
    local label="$3"

    echo "<tr><td valign=\"top\">$label: <td valign=\"top\"><select name=\"$id\">"
    echo "<option selected value=\"\">*</option>"

    psql -A -t -q antology -c "$query" | gawk -F\| '{
        gsub(/&/, "\\&amp;"); gsub(/"/, "\\&quot;"); gsub(/</, "\\&lt;"); gsub(/>/, "\\&gt;");
        if ($1 != oldgroup) { if (oldgroup) print "</optgroup>"; printf "<optgroup label=\"%s\">\n", $5; oldgroup = $1 }
        printf "<option value=\"%s\"> %s %s</option>\n", $1 "=" $2, $3, $4 ? "(" $4 ")" : "";
    }
    END { if (oldgroup) print "</optgroup>" }'
} 

maketextfield() {
    local id="$1"
    local label="$2"
    echo "<tr><td valign=\"top\">$label: <td valign=\"top\"><input type=\"text\" name=\"$id\">"
}

makesql() {
    echo "select $1 from $2 ${3:+where }$3 order by ${4:-${1#distinct}};"
}

echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Поиск текстов</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"

echo "<!-- -middle -->"
echo "<h2 align=\"left\">Поиск текстов</h2>"
echo "<form action=\"/cgi-bin/results.cgi\" method=\"GET\">"
echo "<input type=\"hidden\" name=\"encoding\" value=\"koi8-r\">"
echo "<table>"

makelistfield author "`makesql 'uid, given_name || $$ $$ || patronymic || $$ $$ || surname' authors '' 'surname, given_name, patronymic'`"  Автор
makelistfield title "`makesql 'distinct title' texts`"   Заглавие
makelistfield origtitle "`makesql 'distinct original_title' texts`"  "Заглавие при первой публикации"
makelistfield firstline "`makesql 'distinct first_line' texts 'first_line is not null'`" "Первая строка"
makelistfield kind "`makesql 'id, description' categories 'taxonomy = $$kind$$' description`" "Литературный род"
makelistfield genre "`makesql 'id, description' categories 'taxonomy = $$genre$$' description`" "Жанр"
maketextfield written "Год написания"
maketextfield published "Год первой публикации/постановки"
makelistfield publisher "`makesql 'distinct publisher' texts`" "Место первой публикации"
makelistfield theme "`makesql 'distinct annotation' text_annotations 'kind = $$theme$$'`" "Темы" multiple
makelistfield metric "`makesql 'id, interpretation' metric_elements 'sys_id = $$met$$' interpretation`" "Метр/размер" multiple
makelistfield mscheme "`makesql 'distinct characteristic' text_metric 'sys_id = $$met$$'`" "Метрическая схема"
makelistfield rhyme "`makesql 'distinct characteristic' text_metric 'sys_id = $$rhyme$$'`" "Рифмовка"
makecomplexlistfield place "`makesql 'distinct nc.name_class, tn.proper_name, tn.proper_name, nc.abbreviated, nc.description' 'text_names as tn, name_classes as nc' 'nc.name_class = tn.name_class and lower(nc.name_class) like $$%place$$' 'nc.description, nc.name_class, tn.proper_name, nc.abbreviated'`" "Географические названия"
makecomplexlistfield name "`makesql 'distinct nc.name_class, tn.proper_name, tn.proper_name, nc.abbreviated, nc.description' 'text_names as tn, name_classes as nc' 'nc.name_class = tn.name_class and lower(nc.name_class) not like $$%place$$' 'nc.description, nc.name_class, tn.proper_name, nc.abbreviated'`" "Имена собственные" 
makelistfield addressee "`makesql 'distinct annotation' text_annotations 'kind = $$addressee$$'`" Адресат

echo "<tr><td><input type=\"submit\" value=\"Поиск\"><td><input type=\"reset\" value=\"Очистить\">"
echo "</table>"
echo "</form>"
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
