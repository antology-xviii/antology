#! /bin/bash

psql -A -t -q antology -c "select uid, given_name || ' ' || patronymic || ' ' || upper(surname), portrait, sort_order from authors order by surname, given_name, patronymic;" | \
    awk -f urlencode.awk -f contents.awk