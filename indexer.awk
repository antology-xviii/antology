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

function indexer() {
    if (SGML_PATH ~ /^TITLE TITLESTMT FILEDESC\>/)
    {
        print SGML_FILE ":", "+title::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^DATE PUBLICATIONSTMT BIBLFULL SOURCEDESC BIBLFULL SOURCEDESC\>/)
    {
        print SGML_FILE ":", "+date::published::" encode_tag_val(body())
    }
    else if (SGML_PATH ~ /^AUTHOR TITLESTMT FILEDESC\>/)
    {
        print SGML_FILE ":", "+author::" encode_tag_val(body())
    }
    else if (SGML_CURRENT == "NAME")
    {
        nameref = encode_tag_val(has_attribute("REG") ? attribute("REG") : body());
        print SGML_FILE ":", "+name::" attribute("TYPE") "::" nameref;
        print SGML_FILE "#name" ++nameidx ":", "+name::" attribute("TYPE") "::" nameref;
        if (SGML_PATH ~ /\<SALUTE\>/)
            print SGML_FILE ":", "+annotation::addressee::" nameref;
        else if (SGML_PATH ~ /\<CREATION\>/ || SGML_PATH ~ /\<DATELINE\>/)
        {
            if (attribute("TYPE") == "place")
            {
                print SGML_FILE ":", "+place::written::" nameref;
            }
        }
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
        print SGML_FILE ":", "+name::character::" encode_tag_val(body());
    }
    else if (SGML_CURRENT == "L")
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
        print SGML_FILE ":", "+annotation::" attribute("TYPE") "::" encode_tag_val(attribute("VALUE"));
    }
    if (has_attribute("MET"))
    {
        print SGML_FILE ":", "+metric::scheme::" encode_tag_val(attribute("MET"));
        decompose_metric(attribute("MET"))
    }
    if (has_attribute("RHYME"))
        print SGML_FILE ":", "+rhyme::" encode_tag_val(attribute("RHYME"));
}
