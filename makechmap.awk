/^<U/ {
    sub(/<U/, "#\\U-", $1);
    sub(/>/, "", $1);
    sub(/\//, "#", $2);
    print "(add-char-properties external-code:", $2, $1, ")"
}

    
