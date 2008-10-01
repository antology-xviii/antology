#! /bin/sh -f

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

(cat people.query; echo "select * from results order by random();" ) | psql -A -t -q antology | gawk -f people.awk

echo "<!-- +foot -->"
echo "</body>"
echo "</html>"