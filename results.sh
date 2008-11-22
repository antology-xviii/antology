#! /bin/sh

DBNAME="$1"

SEARCH_author='author_id = $$@$$'
SEARCH_title='title = $$@$$'
SEARCH_origtitle='original_title = $$@$$'
SEARCH_firstline='first_line = $$@$$'
JOIN_kind=' left join (select * from text_classification where taxonomy = $$kind$$) as kinds on kinds.text_id = url'
SEARCH_kind='kinds.category = $$@$$'
JOIN_genre=' left join (select * from text_classification where taxonomy = $$genre$$) as genres on genres.text_id = url'
SEARCH_genre='genres.category = $$@$$'
SEARCH_written='written = $$@$$'
SEARCH_published='(published = $$@$$ or performed = $$@$$)'
SEARCH_publisher='publisher = $$@$$'
JOIN_place=' left join text_names as places on places.text_id = url and places.frag_id = tf.label'
FIELDS_place=',places.proper_name, places.refid'
SEARCH_place='(places.name_class = split_part($$@$$, $$=$$, 1) and places.proper_name = split_part($$@$$, $$=$$, 2))'
JOIN_name=' left join text_names as names on names.text_id = url and names.frag_id = tf.label'
FIELDS_name=',names.proper_name, names.refid'
SEARCH_name='(names.name_class = split_part($$@$$, $$=$$, 1) and names.proper_name = split_part($$@$$, $$=$$, 2))'
JOIN_rhyme=' left join (select * from text_metric where sys_id = $$rhyme$$) as rhymes on rhymes.text_id = url and rhymes.frag_id = tf.label'
SEARCH_rhyme='rhymes.characteristic = $$@$$'
JOIN_metric=' left join (select * from text_metric where sys_id = $$met$$) as metrics on metrics.text_id = url and metrics.frag_id = tf.label'
SEARCH_metric='metrics.characteristic like $$%@%$$'
JOIN_mscheme=' left join (select * from text_metric where sys_id = $$met$$) as mschemes on mschemes.text_id = url and mschemes.frag_id = tf.label'
SEARCH_mscheme='mschemes.characteristic = $$@$$'
JOIN_addressee=' left join (select * from text_annotations where kind = $$addressee$$) as addressees on addressees.text_id = url and addressees.frag_id = tf.label'
SEARCH_addressee='addressees.annotation = $$@$$'
JOIN_theme=' left join (select * from text_annotations where kind = $$theme$$) as themes on themes.text_id = url and themes.frag_id = tf.label'
SEARCH_theme='themes.annotation = $$@$$'

PARMNAME_author="автор"
PARMNAME_title="название"
PARMNAME_origtitle="название при первой публикации"
PARMNAME_firstline="первая строка"
PARMNAME_kind="литературный род"
PARMNAME_genre="жанр"
PARMNAME_written="дата написания"
PARMNAME_published="дата публикации/постановки"
PARMNAME_publisher="место публикации"
PARMNAME_theme="тема"
PARMNAME_place="географическое название"
PARMNAME_name="имя собственное"
PARMNAME_rhyme="схема рифмовки"
PARMNAME_metric="метр/размер"
PARMNAME_mscheme="метрическая схема"
PARMNAME_addressee="адресат"


IFS="&;" read -a parameters
 
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"        
    value="${parameters[$idx]#*=}"
    if [ -n "$value" ]; then
        if [ "$name" != "${name%_mode}" ]; then
            name="${name/[^[:alnum:]]/_}"
            declare "$name"="$value"
        else
            value="${value//+/ }"
            value="$(eval echo "$'${value//\%/\x}'")"
            value="${value//[\$@]/}"
            searchvar="SEARCH_$name"   
            searchterm="${!searchvar//@/$value}"
            qvar="Q_$name"
            if [ -n "$searchterm" ]; then
                declare "$qvar"="${!qvar}${!qvar:+ @+@ }@(@$searchterm@)@"
            fi
        fi
    fi
done
sqlexpr="select url, auth.given_name || ' ' || auth.patronymic || ' ' || auth.surname, title, tf.label, tf.fragment"
isqlexpr="select url "
for var in ${!Q_*}; do
    if [ -n "${!var}" ]; then
        fname="FIELDS_${var#Q_}"
        sqlexpr="$sqlexpr${!fname}"
    fi
done
basicfrom=" from texts left join authors as auth on author_id = auth.uid left join text_structure as tf on tf.text_id = 
url "
sqlexpr="$sqlexpr $basicfrom "
isqlexpr="$isqlexpr $basicfrom "
for var in ${!Q_*}; do
    if [ -n "${!var}" ]; then
        jname="JOIN_${var#Q_}"
        sqlexpr="$sqlexpr${!jname}"
        isqlexpr="$isqlexpr${!jname}"
    fi
done
isqlexpr="$isqlexpr where true "
for var in ${!Q_*}; do
    if [ -n "${!var}" ]; then
        name="${var#Q_}"
        value="${!var}"
        modevar="${name}_mode"
        mode="${!modevar}"
        case "$mode" in
            any)
                value="${value//@(@/(}"
                value="${value//@)@/)}"
                value="${value//@+@/or}"
                isqlexpr="$isqlexpr and ($value)"
                ;;
            all)
                value="${value//@+@/intersect}"
                value="${value//@)@/}"
                isqlexpr="${value//@(@/$isqlexpr and }"
                ;;
            *)
                value="${value//@+@/}"
                value="${value//@(@/(}"
                value="${value//@)@/)}"
                isqlexpr="$isqlexpr and $value"
                ;;
        esac
    fi
done
echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>Результаты поиска</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
echo "<h2 align=\"left\">Результаты поиска</h2>"
echo "<table align=\"center\" width=\"500\" cellpadding=\"10\">"
echo "<tr>"
echo "<td><strong>Параметр поиска:</strong>"
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"
    value="${parameters[$idx]#*=}"
    if [ -n "$value" ]; then
        name="PARMNAME_$name"
        if [ -n "${!name}" ]; then
            echo "<td>${!name}"           
        fi
    fi
done
echo "<tr>"
echo "<td><strong>Вы искали:</strong>"
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"
    value="${parameters[$idx]#*=}"
    if [ -n "$value" ]; then
        name="PARMNAME_$name"
        if [ -n "${!name}" ]; then
            value="${value//+/ }"
            value="$(eval echo "$'${value//\%/\x}'")"
            echo "<td>${value}"
        fi
    fi
done
echo "</table>"
echo "<!-- split -->"
sqlexpr="$sqlexpr where url in ($isqlexpr) order by author_id, title, url, tf.label"
echo "<!-- SQL query was: $sqlexpr -->"
psql -A -t -q antology -c "$sqlexpr" | awk -f urlencode.awk -f results.awk
rc=$?
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
exit $rc
