<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:dcmitype="http://purl.org/dc/dcmitype/"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:svc="http://antology-xviii.spb.ru/schema/service.rdf#"
                xmlns:ant="http://antology-xviii.spb.ru/schema/antology.rdf#">
  <xsl:output method="xml" media-type="application/rdf+xml" />
  <xsl:param name="textname"/>
  
  <xsl:template match="TEI.2">
    <rdf:RDF>
      <ant:PublishedText rdf:about="{$textname}">
      </ant:PublishedText>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="text()"/>
</xsl:stylesheet>