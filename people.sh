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

tagcoll grep class::participant "$PEOPLECOLL" | msort -l -w -cr | gawk -f people.awk

echo "<!-- +foot -->"
echo "</body>"
echo "</html>"