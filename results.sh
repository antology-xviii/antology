#! /bin/sh

TAGCOLL="$1"

SEARCH_author="author::@"
SEARCH_title="title::@"
SEARCH_origtitle="origtitle::@"
SEARCH_firstline="firstline::@"
SEARCH_kind="category::kind::@"
SEARCH_written="date::written::@"
SEARCH_published="(date::published::@ || date::performed::@)"
SEARCH_publisher="publisher::@"
SEARCH_theme="annotation::theme::@"
SEARCH_place="name::place::@"
SEARCH_name="@"
SEARCH_rhyme="rhyme::@"
SEARCH_metric="metric::part::@"
SEARCH_mscheme="metric::scheme::@"
SEARCH_addressee="annotation::addressee::@"

PARMNAME_author="�����"
PARMNAME_title="��������"
PARMNAME_origtitle="�������� ��� ������ ����������"
PARMNAME_firstline="������ ������"
PARMNAME_kind="������������ ���"
PARMNAME_written="���� ���������"
PARMNAME_published="���� ����������/����������"
PARMNAME_publisher="����� ����������"
PARMNAME_theme="����"
PARMNAME_place="�������������� ��������"
PARMNAME_name="��� �����������"
PARMNAME_rhyme="����� ��������"
PARMNAME_metric="����/������"
PARMNAME_mscheme="����������� �����"
PARMNAME_addressee="�������"


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
            value="${value// /@#32;}"
            searchvar="SEARCH_$name"   
            searchterm="${!searchvar//@/$value}"
            qvar="Q_$name"
            if [ -n "$searchterm" ]; then
                declare "$qvar"="${!qvar:-(}${!qvar:+ && }$searchterm"
            fi
        fi
    fi
done
tagexpr=""
for var in ${!Q_*}; do
    if [ -n "${!var}" ]; then
        modevar="${var#Q_}_mode"
        if [ "${!modevar}" = "any" ]; then
            declare "$var"="${!var//&&/||}"
        fi
        tagexpr+="${tagexpr:+ && }${!var})"
    fi
done
echo "<html>"
echo "<head>"
echo "<!-- -head -->"
echo "<title>���������� ������</title>"
echo "<!-- +middle -->"
echo "</head>"
echo "<body>"
echo "<!-- -middle -->"
echo "<h2 align=\"left\">���������� ������</h2>"
echo "<table align=\"center\" width=\"500\" cellpadding=\"10\">"
echo "<tr>"
echo "<td><strong>�������� ������:</strong>"
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
echo "<td><strong>�� ������:</strong>"
for idx in ${!parameters[*]}; do
    name="${parameters[$idx]%%=*}"
    value="${parameters[$idx]#*=}"
    if [ -n "$value" ]; then
        name="PARMNAME_$name"
        if [ -n "${!name}" ]; then
            value="${value//+/ }"
            value="`eval echo "$'${value//\%/\x}'"`"
            value="${value//@/&}"
            echo "<td>${value}"
        fi
    fi
done
echo "</table>"
echo "<!-- split -->"
tagcoll grep "$tagexpr" $TAGCOLL | awk -f results.awk
rc=$?
echo "<!-- +foot -->"
echo "</body>"
echo "</html>"
exit $rc