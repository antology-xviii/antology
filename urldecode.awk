#! /usr/bin/gawk -f
BEGIN { FS = "[;&]"; }
{
    for (i = 1; i <= NF; i++)
    {
        nf = split($i, escapes, "%");
        result = escapes[1];
        for (k = 2; k <= nf; k++)
        {
            result = sprintf("%s%c%s", result, 
                             strtonum("0x" substr(escapes[k], 1, 2)), 
                             substr(escapes[k], 3))
        }
        if (result !~ /^[[:alnum:]_]+=/)
            continue;
        gsub(/[$`\\"]/, "\\\\&", result);
        sub(/=/, "=\"", result); result = result "\""
        print result
    }
}
