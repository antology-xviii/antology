BEGIN { 
    FS="|";   
    print "<table id=masterdiv>"; 
}

function print_caption(caption) {
    if (caption)
    {
        print "<li><span class=\"menutitle\" onClick=\"SwitchMenu('subsub" ++globalidx "')\">" caption "</span>";
        print "<ul class=\"submenu\" id=\"subsub" globalidx "\">";
    }
}


{ 
    print "<tr><td valign=\"top\">";
    if ($3)
        print "<img src=\"/images/" $3 "\" width=\"100\" height=\"121\" alt=\"" $2  "\" border=\"0\">";
    print "<td valign=\"top\" width=\"85%\">"
    print "<span class=\"menutitle\" onClick=\"SwitchMenu('sub" FNR "')\">" $2 "</span>";

    
    print "<ul class=\"submenu\" id=\"sub" FNR "\">"

    sqlquery = sprintf("\"select url, title, kinds.caption, addressees.caption, addressees.annotation from texts \
left join text_classification as tc on tc.taxonomy = 'kind' and tc.text_id = url \
left join categories as kinds on kinds.taxonomy = 'kind' and tc.category = kinds.id \
left join text_annotations as addressees on addressees.kind = 'addressee' and \
addressees.frag_id = '' and addressees.text_id = url where author_id = '%s' order by %s\"",
                       $1, $4);
    titlelist = "psql -A -t -q antology -c " sqlquery
    caption1 = "";
    caption2 = "";
    while ((titlelist | getline) > 0)
    {
        if ($3 != caption1)
        {
            if (caption1)
            {
                if (caption2)
                    print "</ul>";
                print "</ul>";
            }
            caption1 = $3;
            caption2 = "";
            print_caption(caption1);
        }
        if ($4 != caption2)
        {
            if (caption2)
                print "</ul>";
            caption2 = $4;
            print_caption(caption2);
        }

        print "<li><a href=\"/cgi-bin/gettext.cgi/" urlencode_path($1) "\">" $2 "</a>"
    }
    close(titlelist);

    if (caption2)
        print "</ul>";
    if (caption1)
        print "</ul>";

    print "</ul>"
}
END {
    print "</table>"
}
