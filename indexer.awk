function decompose_metric(met,  len, sym) {
    while (met != "")
    {
        for (len = metric_symbol_maxlen; len > 0; len--)
        {
            sym = substr(met, 1, len);
            if (sym in metric_symbol)
            {
                met = substr(met, len + 1);
                print "ou:", "metric:part:" metric_symbol[sym];
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
    if (SGML_PATH ~ /^TEI.2\>/)
    {
    }
    else if (SGML_PATH ~ /^(TITLE|HEAD|ITEM|Q|L|P|QUOTE|CELL)\>/)
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
                        NAMEFRAG[indices[x]] = encode_tag_val(workspace);
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
        SQLATTR["title"] = encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^TITLE TITLESTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        SQLATTR["original_title"] = encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^PUBLISHER PUBLICATIONSTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        SQLATTR["publisher"] = encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^DATE PUBLICATIONSTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        SQLATTR["published"] = encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^FORENAME PERSNAME AUTHOR TITLESTMT FILEDESC\>/)
    {
        SQLATTR[attribute("TYPE") == "patronymic" ? "patronymic" : "given_name"] = encode_tag_val(body());
    }
    else if (SGML_PATH ~ /^SURNAME PERSNAME AUTHOR TITLESTMT FILEDESC\>/)
    {
        SQLATTR["surname"] = encode_tag_val(body());
    }
    else if (SGML_CURRENT == "ABBR")
    {
        SGML_ATTRS["", SGML_CURRENT, SGML_LEVELS[SGML_CURRENT]] = attribute("EXPAN");
    }
    else if (SGML_CURRENT == "NAME")
    {
        nameref = encode_tag_val(has_attribute("REG") ? attribute("REG") : body());
        print "cn:", attribute("TYPE") ":" nameref;
        MENTIONED[++nameidx] = attribute("TYPE") ":" nameref;
        if (reference)
            NAMEREF[nameidx] = reference;
        if (SGML_PATH ~ /\<SALUTE\>/)
            print "cn:", "addressee:" nameref;
        else if (SGML_PATH ~ /\<CREATION\>/ || SGML_PATH ~ /\<DATELINE\>/)
        {
            if (attribute("TYPE") == "place")
            {
                print "l:", "written:" nameref;
            }
        }
        fragments[nameref] = fragments[nameref] " " nameidx;
        searchre = (searchre ? searchre "|" : "") escape_regops(body());
    }
    else if (SGML_PATH ~ /^DATE .+ PERFORMANCE\>/)
    {
        print "documentVersion:",  "performed:" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^DATE CREATION/)
    {
        print "documentVersion:", "written:" encode_tag_val(body());
    }
    else if (SGML_CURRENT == "ROLE")
    {
        role = body();
        sub(/^[[:space:]]+/, "", role);
        sub(/\.?[[:space:]]+$/, "", role);        
        print "cn:", "character:" encode_tag_val(role);
    }
    else if (SGML_CURRENT == "L" && SGML_CURRENT !~ /\<QUOTE\>/)
    {
        if (!not_first_line)
        {
            print "description:", encode_tag_val(body());
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
        print "ou:", "category:" tolower(attribute("SCHEME")) ":" taxonomy[attribute("SCHEME"), \
                                                                           attribute("TARGET")];
    }
    else if (SGML_CURRENT == "SPAN")
    {
        annoval = attribute("TYPE") ":" encode_tag_val(attribute("VALUE"));
        print "ou:", annoval;
        spandest = attribute("FROM");
        REFERENCED[spandest] = annoval
    }
    if (has_attribute("MET"))
    {
        print "ou:", "metric:scheme:" encode_tag_val(attribute("MET"));
        decompose_metric(attribute("MET"))
    }
    if (has_attribute("RHYME"))
        print "ou:", "rhyme:" encode_tag_val(attribute("RHYME"));
}

END {
    print "";
    for (i in REFERENCED)
    {
        if (IDREF[i])
        {
            print "dn:", "documentIdentifier=id." i ",documentIdentifier=" SGML_FILE "," DOCUMENT_TREE;
            print "objectClass: document"
            print "documentIdentifier:", "id." i;
            print "documentLocation:", "text:" SGML_FILE "#id." i;
            print "documentTitle:", "ref:" IDREF[i];
            frag = DIVHEAD[IDREF[i]];
            if (frag)
                print "description:",  encode_tag_val(frag);
            print "ou:", REFERENCED[i];
        }
        print "";
    }
    for (i in MENTIONED)
    {
        print "dn:", "documentIdentifier=NAME" i ",documentIdentifier=" SGML_FILE "," DOCUMENT_TREE;
        print "objectClass: document"
        print "documentIdentifier:", "NAME" i;
        print "documentLocation:", "text:" SGML_FILE "#NAME" i;
        print "cn:", MENTIONED[i];
        if (NAMEREF[i])
            print "documentTitle:", "ref:" NAMEREF[i];
        if (NAMEFRAG[i])
            print "description:", NAMEFRAG[i];
        print "";
    }
}
