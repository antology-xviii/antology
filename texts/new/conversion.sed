1i\
<!DOCTYPE TEI.2 PUBLIC "-//TEI P4//DTD Main Document Type//EN" [\
	<!ENTITY % ISOcyr1 PUBLIC "ISO 8879:1986//ENTITIES Russian Cyrillic//EN">\
	<!ENTITY % ISOlat1 PUBLIC "ISO 8879:1986//ENTITIES Added Latin 1//EN">\
	<!ENTITY % ISOlat2 PUBLIC "ISO 8879:1986//ENTITIES Added Latin 2//EN">\
	<!ENTITY % ISOpub PUBLIC "ISO 8879:1986//ENTITIES Publishing//EN">\
    <!ENTITY % ISOnum PUBLIC "ISO 8879:1986//ENTITIES Numeric and Special Graphic//EN">\
	<!NOTATION html PUBLIC "-//W3C//NOTATION HTML 4.01//EN">\
	%ISOnum;\
	%ISOpub;\
	%ISOcyr1;\
	%ISOlat1;\
	%ISOlat2;\
	<!ENTITY % TEI.verse "INCLUDE" >\
	<!ENTITY % TEI.names.dates "INCLUDE" >\
	<!ENTITY % TEI.analysis "INCLUDE">\
	<!ENTITY % TEI.linking "INCLUDE">\
	<!ENTITY Encoding SYSTEM "encoding.tei">\
	<!ENTITY rvb SYSTEM "<url>http://rvb.ru" NDATA HTML>\
]>
/&Encoding;/d
/<profileDesc>/i\
&Encoding;
s/sourceDescr/sourceDesc/
s/<availability[^>]*>/&<p>/
s/\(<catRef[^>]*>\)[[:space:]]*<\/>/\1/
s/''/"/g
s/\(<body.*\) \(met=['"][^'"]*['"][[:space:]]*rhyme=['"][^'"]*['"]\)[[:space:]]*>/\1><div0 \2>/
