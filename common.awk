function encode_tag_val(value)
{
    sub(/^(\\n)+/, "", value);
    sub(/(\\n)+$/, "", value);
    gsub(/[[:space:]]+/, " ", value);
    sub(/^ /, "", value);
    sub(/ $/, "", value);
    gsub(/\\n/, "\n ", value);
    gsub(/'/, "''", value);
    return value;
}

function unline(value)
{
    gsub(/\\n/, " ", value);
    return value;
}

function escape_regops(value)
{
    gsub(/[][\\.+*{}()^$|]/, "\\\\&", value);
    return value;
}

function attribute(name, tagname)
{
    return SGML_ATTRS[name, tagname ? tagname : SGML_CURRENT, SGML_LEVELS[tagname ? tagname : SGML_CURRENT]];
}

function has_attribute(name, tagname)
{
    return (name, tagname ? tagname : SGML_CURRENT, SGML_LEVELS[tagname ? tagname : SGML_CURRENT]) in SGML_ATTRS;
}


function body(name)
{
    return attribute("", name);
}

function eliminate_body()
{
    SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] = "";
}

function parent(  p)
{
    p = SGML_PATH;
    sub(/^[^ ]+( |$)/, "", p);
    sub(/ .*$/, "", p);    
    return p;
}

/^A/ {
    attrname = substr($1, 2);
    if ($2 != "IMPLIED")
    {
        $1 = "";
        $2 = "";
        sub(/^[[:space:]]*/, "");
        following_attrs[attrname] = $0;
    }
    next
}

/^\(/ {
    gi = substr($1, 2);
    SGML_PATH =  gi (SGML_PATH ? " " : "") SGML_PATH;
    SGML_LEVELS[gi]++;
    for (attr in following_attrs)
    {
        SGML_ATTRS[attr, gi, SGML_LEVELS[gi]] = following_attrs[attr];
    }
    delete following_attrs;
    SGML_CURRENT = gi;
    preindexer();
    next
}

/^-/ {
    SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] = \
        SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] substr($0, 2) " ";
    next
}

/^\)/ {
    indexer();
    b = SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]]
    for (i in SGML_ATTRS)
    {
        split(i, tmp, SUBSEP);
        if (tmp[2] == SGML_CURRENT && tmp[3] == SGML_LEVELS[SGML_CURRENT])
            delete SGML_ATTRS[i];
    }
    sub(/^[^ ]+( |$)/, "", SGML_PATH);
    SGML_LEVELS[SGML_CURRENT]--;
    SGML_CURRENT = SGML_PATH;
    sub(/ .*$/, "", SGML_CURRENT);
    SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] = \
        SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] b " ";
    next
}

/^L/ {
    if (NF > 1)
        SGML_FILE = $2;
    next
}


