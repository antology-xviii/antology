BEGIN {
    for (i = 0; i < 256; i++)
        CHARCODES[sprintf("%c", i)] = i;
}

function urlencode(str, addsyms,  addre, result)
{
    result = "";
    addre = "^[" addsyms "]"
    for (; str; str = substr(str, 2))
    {
        if (str ~ /^[-a-zA-Z0-9._~]/ || (addsyms && str ~ addre))
            result = result substr(str, 1, 1);
        else
        {
            result = result "%" toupper(sprintf("%x", CHARCODES[substr(str, 1, 1)]));
        }
    }
    return result;
}

function urlencode_path(str)
{
    return urlencode(str, ":/@");
}

function urlencode_utf8(str,  iconv)
{
    iconv = sprintf("echo -n \"%s\" | iconv -f koi8-r -t utf-8", str);
    iconv | getline str;
    close(iconv);
    return urlencode_path(str);
}

