function decompose_metric(met,  len, sym) {
    while (met != "")
    {
        for (len = metric_symbol_maxlen; len > 0; len--)
        {
            sym = substr(met, 1, len);
            if (sym in metric_symbol)
            {
                met = substr(met, len + 1);
                print SGML_FILE ":", "+metric::part::" metric_symbol[sym];
                break;
            }
        }
        if (len == 0)
            met = substr(met, 2);
    }
}

function calc_refstr() {
    reference = "";
    for (i = 1; i <= refdepth; i++)
        reference = reference refcount[i] ".";
}

function preindexer() {
    if (SGML_PATH ~ /^DIV[1-9]?\>/)
    {
        refdepth++;
        refcount[refdepth]++;
        calc_refstr();
        print "entering", reference >"/dev/stderr"
    }
    elemid = attribute("ID");
    if (elemid)
    {
        IDREF[elemid] = reference;
    }
}


function indexer() {
    if (SGML_PATH ~ /^(TITLE|HEAD|ITEM|Q|L|P|QUOTE|CELL)\>/)
    {
        if (searchre)
        {
            split(body(), sentences, /[.!?]\.*/);
            for (f in fragments)
            {
                split(fragments[f], indices, " ");
                x = 1;
                for (s = 1; s in sentences && x in indices; s++)
                {
                    workspace = sentences[s];
                    nsub = gsub(searchre, "<strong>&</strong>", workspace);
                    if (nsub > 0)
                    {
                        print SGML_FILE "#NAME" indices[x] ":", "+fragment::" encode_tag_val(workspace)
                        x += nsub;
                    }
                }
            }
            delete fragments;
            searchre = "";
        }
    }
    if (SGML_PATH ~ /^DIV[1-9]?\>/)
    {
        for (i = refdepth + 1; i in refcount; i++)
            delete refcount[i];
        refdepth--;
        calc_refstr();
    }

    if (SGML_PATH ~/^HEAD\>/)
    {
        if (!(reference in DIVHEAD))
            DIVHEAD[reference] = body();
    }
    else if ((SGML_PATH ~ /^TITLE TITLE\>/ && attribute("TYPE") == "subordinate") ||
             (SGML_PATH ~ /^NOTE TITLE\>/))
    {
        eliminate_body();
    }
    else if (SGML_PATH ~ /^TITLE TITLESTMT FILEDESC\>/)
    {
        print SGML_FILE ":", "+title::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^TITLE TITLESTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        print SGML_FILE ":", "+origtitle::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^PUBLISHER PUBLICATIONSTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        print SGML_FILE ":", "+publisher::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^DATE PUBLICATIONSTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        print SGML_FILE ":", "+date::published::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^AUTHOR TITLESTMT FILEDESC\>/)
    {
        print SGML_FILE ":", "+author::" encode_tag_val(body())
    }
    else if (SGML_CURRENT == "ABBR")
    {
        SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] = attribute("EXPAN");
    }
    else if (SGML_CURRENT == "NAME")
    {
        nameref = encode_tag_val(has_attribute("REG") ? attribute("REG") : body());
        print SGML_FILE ":", "+name::" attribute("TYPE") "::" nameref;
        print SGML_FILE "#NAME" ++nameidx ":", "+name::" attribute("TYPE") "::" nameref;
        if (reference)
            print SGML_FILE "#NAME" nameidx ":", "+ref::" reference;
        if (SGML_PATH ~ /\<SALUTE\>/)
            print SGML_FILE ":", "+annotation::addressee::" nameref;
        else if (SGML_PATH ~ /\<CREATION\>/ || SGML_PATH ~ /\<DATELINE\>/)
        {
            if (attribute("TYPE") == "place")
            {
                print SGML_FILE ":", "+place::written::" nameref;
            }
        }
        fragments[nameref] = fragments[nameref] " " nameidx;
        searchre = (searchre ? searchre "|" : "") escape_regops(body());
    }
    else if (SGML_PATH ~ /^DATE .+ PERFORMANCE\>/)
    {
        print SGML_FILE ":", "+date::performed::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^DATE CREATION/)
    {
        print SGML_FILE ":", "+date::written::" encode_tag_val(body());
    }
    else if (SGML_CURRENT == "ROLE")
    {
        role = body();
        sub(/^[[:space:]]+/, "", role);
        sub(/\.?[[:space:]]+$/, "", role);        
        print SGML_FILE ":", "+name::character::" encode_tag_val(role));
    }
    else if (SGML_CURRENT == "L" && SGML_CURRENT !~ /\<QUOTE\>/)
    {
        if (!not_first_line)
        {
            print SGML_FILE ":", "+firstline::" encode_tag_val(body());
            not_first_line = 1;
        }
    }
    else if (SGML_PATH ~ /^CATDESC CATEGORY TAXONOMY CLASSDECL\>/)
    {
        taxonomy[attribute("ID", "TAXONOMY"), attribute("ID", "CATEGORY")] = encode_tag_val(body());
    }
    else if (SGML_PATH ~ /^SYMBOL METDECL\>/ && attribute("TYPE", "METDECL") == "met")
    {
        symlen = length(attribute("VALUE"));
        metric_symbol[attribute("VALUE")] = encode_tag_val(body());
        if (symlen > metric_symbol_maxlen)
            metric_symbol_maxlen = symlen;
    }
    else if (SGML_CURRENT == "CATREF")
    {
        print SGML_FILE ":", "+category::" tolower(attribute("SCHEME")) "::" taxonomy[attribute("SCHEME"), \
                                                                                      attribute("TARGET")];
    }
    else if (SGML_CURRENT == "SPAN")
    {
        annoval = "+annotation::" attribute("TYPE") "::" encode_tag_val(attribute("VALUE"));
        print SGML_FILE ":", annoval;
        spandest = attribute("FROM");
        REFERENCED[spandest] = annoval
    }
    if (has_attribute("MET"))
    {
        print SGML_FILE ":", "+metric::scheme::" encode_tag_val(attribute("MET"));
        decompose_metric(attribute("MET"))
    }
    if (has_attribute("RHYME"))
        print SGML_FILE ":", "+rhyme::" encode_tag_val(attribute("RHYME"));
}

END {
    for (i in REFERENCED)
    {
        if (IDREF[i])
        {
            frag = DIVHEAD[IDREF[i]];
            if (frag)
                frag = ", +fragment::" encode_tag_val(frag);
            print SGML_FILE "#id." i ":", REFERENCED[i] ",", "+ref::" IDREF[i] frag
        }
    }
}
