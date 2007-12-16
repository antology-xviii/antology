#! /bin/sh -f

PEOPLECOLL="$3"

cat <<'EOF'
<html>
<head>
<!-- -head -->
  <title>����������� ��������� ������� ���������� XVIII ����. ���������.</title>
<!-- +middle -->
</head>
<body>
<!-- -middle -->
<H2 align=left>��������� �������</h2>
<p>
EOF

tagcoll grep class::participant "$PEOPLECOLL" | iconv -f koi8-r -t utf-8 | msort -q -l -w -cr | iconv -f utf-8 -t koi8-r | gawk -f people.awk

echo "<!-- +foot -->"
echo "</body>"
echo "</html>"