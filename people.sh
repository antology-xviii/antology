#! /bin/sh -f

PEOPLECOLL="$3"

cat <<'EOF'
<html>
<head>
<!-- -head -->
  <title>Электронная антология русской литературы XVIII века. Участники.</title>
<!-- +middle -->
</head>
<body>
<!-- -middle -->
<H2 align=left>Участники проекта</h2>
<p>
EOF

tagcoll grep class::participant "$PEOPLECOLL" | msort -l -w -cr | gawk -f people.awk

echo "<!-- +foot -->"
echo "</body>"
echo "</html>"