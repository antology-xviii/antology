BEGIN { FS="|"; first_fragment = 1; }

{
	if (!anything_found)
	{
		anything_found = 1;
		print "<ul>"
	}
	if ($1 != current_url)
	{
		if (!first_fragment) print "</ul>";
		printf "<li>%s <a href='/cgi-bin/gettext.cgi/%s'>%s</a>\n", $2, urlencode_path($1), $3;
		first_fragment = 1;
		current_url = $1;
	}
	if ($6)
	{
        print "<ul>";
        subst_frag = $5;
        if ($11)
            gsub($11, "<strong>" $11 "</strong>", subst_frag);
        if ($8)
            gsub($8, "<strong>" $8 "</strong>", subst_frag);
        printf "<li><a href='/cgi-bin/gettext.cgi/%s%s%s'>%s</a>\n", 
            urlencode_path($1), $10 ? "#" $10 : ($7 ? "#" $7 : ""), 
            $9 ? "?hilite=" urlencode_path($9) : ($6 ? "?hilite=" urlencode_path($6) : ""),
            subst_frag;
	}
}

END {
    if (anything_found)
	{
        print "</ul>";
	}
    else
    {
        print "<p>К сожалению, по Вашему запросу ничего не найдено"
        exit 4
    }
}
