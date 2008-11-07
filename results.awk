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
		printf "<li>%s <a href='%s'>%s</a>\n", $2, urlencode_path($1), $3;
		first_fragment = 1;
		current_url = $1;
	}
	if ($4)
	{
		if (first_fragment)
		{
			print "<ul>";
			first_fragment = "";
		}
		printf "<li><a href='%s%s'>%s</a>\n", $5, urlencode_path($1), $6 ? "#" $6 : "";
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
