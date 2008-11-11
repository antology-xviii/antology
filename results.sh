#! /bin/sh

DBNAME="$1"

SEARCH_author='author_id = $$@$$'
SEARCH_title='title = $$@$$'
SEARCH_origtitle='original_title = $$@$$'
SEARCH_firstline='first_line = $$@$$'
subquery_class_all_common='select tc.category from text_classification as tc where'
subquery_class_common="$subquery_class_all_common tc.text_id = url"
SEARCH_kind='tc.category = $$@$$'
subquery_kind_common="tc.taxonomy = 'kind' and (@)"
SUBQUERY_kind_any="$subquery_class_common and $subquery_kind_common"
SUBQUERY_kind_all="$subquery_class_common intersect $subquery_class_all_common $subquery_kind_common"
SEARCH_genre='tc.category = $$@$$'
subquery_genre_common="tc.taxonomy = 'genre' and (@)"
SUBQUERY_genre_any="$subquery_class_common and $subquery_genre_common"
SUBQUERY_genre_all="$subquery_class_common intersect $subquery_class_all_common $subquery_genre_common"
SEARCH_written='written = $$@$$'
SEARCH_published='(published = $$@$$ or performed = $$@$$)'
SEARCH_publisher='publisher = $$@$$'
SEARCH_place='(n.name_class = split_part($$@$$, $$=$$, 1) and n.proper_name = split_part($$@$$, $$=$$, 2))'
subquery_place_common="select n.name_class || '=' || n.proper_name from text_names as n where "
subquery_place_text="$subquery_place_common n.text_id = url and n.frag_id = tf.label"
SUBQUERY_place_any="$subquery_place_text and (@)"
SUBQUERY_place_all="$subquery_place_text intersect $subquery_place_common (@)"
SEARCH_name="$SEARCH_place"
JOIN_name_fields=", jn.refid, jn.occurrence"
JOIN_name_from=", text_names as jn"
JOIN_name_join="and jn.text_id = url and jn.frag_id = tf.label"
JOIN_place_fields="$JOIN_name_fields"
JOIN_place_from="$JOIN_name_from"
JOIN_place_join="$JOIN_name_join"
SUBQUERY_name_any="$SUBQUERY_place_any"
SUBQUERY_name_all="$SUBQUERY_place_all"
subquery_metric_all_common='select m.characteristic from text_metric as m where'
subquery_metric_common="$subquery_metric_all_common m.text_id = url and m.frag_id = tf.label"
SEARCH_rhyme='m.characteristic = $$@$$'
subquery_rhyme_common='m.sys_id = $$rhyme$$ and (@)'
SUBQUERY_rhyme_any="$subquery_metric_common and $subquery_rhyme_common"
SUBQUERY_rhyme_all="$subquery_metric_common intersect $subquery_metric_all_common $subquery_rhyme_common"
SEARCH_metric='m.characteristic like $$%@%$$'
subquery_msys_common='m.sys_id = $$met$$ and (@)'
SUBQUERY_metric_any="$subquery_metric_common and $subquery_msys_common"
SUBQUERY_metric_all="$subquery_metric_common intersect $subquery_metric_all_common $subquery_msys_common"
SEARCH_mscheme='m.characteristic = $$@$$'
SUBQUERY_mscheme_any="$SUBQUERY_metic_any"
SUBQUERY_mscheme_all="$SUBQUERY_metic_all"
SEARCH_addressee='ta.annotation = $$@$$'
subquery_anno_all_common='select ta.annotation from text_annotations as ta where'
subquery_anno_common="$subquery_anno_all_common ta.text_id = url and ta.frag_id = tf.label"
subquery_addressee_common='ta.kind = $$addressee$$ and (@)'
SUBQUERY_addressee_any="$subquery_anno_common and $subquery_addressee_common"
SUBQUERY_addressee_all="$subquery_anno_common intersect $subquery_anno_all_common $subquery_addressee_common"
SEARCH_theme="$SEARCH_addressee"
subquery_theme_common='ta.kind = $$theme$$ and (@)'
SUBQUERY_theme_any="$subquery_anno_common and $subquery_theme_common"
SUBQUERY_theme_all="$subquery_anno_common intersect $subquery_anno_all_common $subquery_theme_common"

PARMNAME_author="автор"
PARMNAME_title="название"
PARMNAME_origtitle="название при первой публикации"
PARMNAME_firstline="первая строка"
PARMNAME_kind="литературный род"
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
            value="`eval echo "$'${value//\%/\x}'"`"
            value="${value//\$/}"
            searchvar="SEARCH_$name"   
            searchterm="${!searchvar//@/$value}"
            qvar="Q_$name"
            if [ -n "$searchterm" ]; then
                declare "$qvar"="${!qvar:+ or }$searchterm"
            fi
        fi
    fi
done
sqlexpr=""
addfields=""
addjoin=""
addfrom=""
for var in ${!Q_*}; do
    if [ -n "${!var}" ]; then
        value="${!var}"
        modevar="${var#Q_}_mode"
        subq="SUBQUERY_${var#Q_}_${!modevar:-any}"       
	echo "$subq ($modevar) -> ${!subq}" >&2 
        if [ -n "${!subq}" ]; then
            value="exists(${!subq//@/$value})"
        fi
        sqlexpr+=" and (${value})"
		jf="JOIN_${var#Q_}_fields"
		addfields+="${!jf}"
		jf="JOIN_${var#Q_}_from"
		addfrom+="${!jf}"
		jn="JOIN_${var#Q_}_join"
		addjoin+="${!jn}"
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
            value="`eval echo "$'${value//\%/\x}'"`"
            echo "<td>${value}"
        fi
    fi
done
echo "</table>"
echo "<!-- split -->"
sqlexpr="select url, auth.given_name || ' ' || auth.patronymic || ' ' || auth.surname, title, tf.label, tf.fragment $addfields from texts, authors as auth, text_structure as tf $addfrom where auth.uid = author_id and tf.text_id = url $sqlexpr $addjoin order by author_id, title, url, tf.label"
echo "<!-- SQL query was: $sqlexpr -->"
psql -A -t -q antology -c "$sqlexpr" | awk -f urlencode.awk -f results.awk
rc=$?
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
exit $rc
