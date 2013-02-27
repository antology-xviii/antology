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
  <xsl:import href="./library.xslt"/>
  <xsl:output method="xml" media-type="application/rdf+xml" />
  <xsl:param name="textname"/>
  <xsl:param name="peoplebase"/>
  <xsl:param name="citebase"/>
  <xsl:param name="classbase"/>
  <xsl:param name="process-encoding" select="1"/>
  
  <xsl:template match="TEI.2">
    <rdf:RDF>
      <ant:PublishedWork rdf:about="{$textname}">
        <xsl:apply-templates select="teiHeader"/>
      </ant:PublishedWork>
      <xsl:apply-templates select="body"/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="teiHeader">
    <xsl:apply-templates select="fileDesc"/>
    <xsl:apply-templates select="encodingDesc"/>
    <xsl:apply-templates select="profileDesc"/>
  </xsl:template>

  <xsl:template match="fileDesc">
    <xsl:apply-templates select="titleStmt"/>
    <xsl:apply-templates select="sourceDesc"/>
    <xsl:apply-templates select="sourceDesc//sourceDesc[not(biblFull/sourceDesc)]"/>
  </xsl:template>

  <xsl:template match="titleStmt">
    <xsl:apply-templates select="title|author|editor|principal"/>
  </xsl:template>

  <xsl:template match="sourceDesc[biblFull/sourceDesc]">
    <ant:source>
      <xsl:apply-templates select="biblFull"/>
    </ant:source>
  </xsl:template>

  <xsl:template match="sourceDesc[not(biblFull/sourceDesc)]">
    <ant:original>
      <xsl:apply-templates select="biblFull"/>
    </ant:original>
  </xsl:template>

  <xsl:template match="encodingDesc">
    <xsl:if test="$process-encoding">
      <xsl:apply-templates select="classDecl|metDecl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="classDecl">
    <xsl:apply-templates select="taxonomy"/>
  </xsl:template>

  <xsl:template match="taxonomy">
    <svc:Classification rdf:about="{$classbase}{@id}"/>
    <xsl:apply-templates select="category"/>
  </xsl:template>

  <xsl:template match="category">
    <xsl:element name="{@id}" namespace="{$classbase}{ancestor::taxonomy[1]/@id}">
    </xsl:element>
    <xsl:apply-templates select="category"/>
  </xsl:template>

  <xsl:template match="biblFull">
    <ant:PublishedWork>
      <xsl:attribute name="rdf:about">
        <xsl:value-of select="$citebase"/>?op=search<xsl:call-template name="mkbibquery"/>
      </xsl:attribute>
    </ant:PublishedWork>
  </xsl:template>

  <xsl:template match="title">
    <ant:title><xsl:value-of select="normalize-space()"/></ant:title>
  </xsl:template>

  <xsl:template match="author[persName/surname = 'аноним']">
    <ant:author rdf:resource="http://antology-xviii.spb.ru/schema/antology.rdf#anonymous"/>
  </xsl:template>

  <xsl:template match="author">
    <ant:author>
      <xsl:apply-templates select="persName"/>
    </ant:author>
  </xsl:template>

  <xsl:template match="editor[persName]">
    <ant:editor>
      <xsl:apply-templates select="persName"/>
    </ant:editor>
  </xsl:template>

  <xsl:template match="editor[not(persName)]|principal">
    <ant:editor>
      <ant:RealPerson>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$peoplebase"/>
          <xsl:call-template name="encode">
            <xsl:with-param name="uri" select="normalize-space(name/@reg|self::*[not(name)])"/>
          </xsl:call-template>
        </xsl:attribute>
      </ant:RealPerson>
    </ant:editor>
  </xsl:template>

  <xsl:template match="publisher">
    <ant:publisher>
      <ant:Publisher rdfs:label="{normalize-space()}"/>
    </ant:publisher>
  </xsl:template>

  <xsl:template match="persName">
    <ant:RealPerson>
      <xsl:attribute name="rdf:about">
        <xsl:value-of select="$peoplebase"/>
        <xsl:call-template name="encode">
          <xsl:with-param name="uri">
            <xsl:call-template name="abbreviate"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="surname|foreName"/>
    </ant:RealPerson>   
  </xsl:template>

  <xsl:template match="persName/surname">
    <xsl:attribute name="foaf:familyName"><xsl:value-of select="normalize-space()"></xsl:value-of></xsl:attribute>
  </xsl:template>
  <xsl:template match="persName/foreName">
    <xsl:attribute name="foaf:givenName"><xsl:value-of select="normalize-space()"></xsl:value-of></xsl:attribute>
  </xsl:template>
  
  <xsl:template match="text()"/>

  <xsl:template match="*">
    <xsl:call-template name="unknown-tag"/>
  </xsl:template>
</xsl:stylesheet>