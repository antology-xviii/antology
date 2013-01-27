<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" media-type="application/tei+xml" />
    <xsl:variable name="entity_mapping" select="document('mapping.xml')"/>
    <xsl:key name="map_entity" match="mapping" use="@entity"/>
    <xsl:template match="div0|div1|div2|div3|div4|div5|div6|div7" priority="1">
      <xsl:call-template name="recursive">
        <xsl:with-param name="tag" select="'div'"/>
      </xsl:call-template>
    </xsl:template>
    <xsl:template match="lg1|lg2|lg3|lg4|lg5" priority="1">
      <xsl:call-template name="recursive">
        <xsl:with-param name="tag" select="'lg'"/>
      </xsl:call-template>
    </xsl:template>
    <xsl:template match="processing-instruction('sdataEntity')">
      <xsl:variable name="entity" select="substring-before(normalize-space(), ' ')"/>
      <xsl:for-each select="$entity_mapping">
        <xsl:variable name="value" select="key('map_entity', $entity)"/>
        <xsl:if test="not($value)">
          <xsl:message terminate="yes">
            Unknown entity <xsl:value-of select="$entity"/>
          </xsl:message>
        </xsl:if>
        <xsl:value-of select="$value/@data"/>
      </xsl:for-each>
    </xsl:template>
    <xsl:template match="processing-instruction()">
      <xsl:message terminate="yes">
        Unknown processing instruction <xsl:value-of select="local-name()"/>
      </xsl:message>
    </xsl:template>
    <xsl:template match="*[@teiform]">
      <xsl:call-template name="recursive">
        <xsl:with-param name="tag" select="@teiform"/>
      </xsl:call-template>
    </xsl:template>
    <xsl:template match="*">
      <xsl:call-template name="recursive">
        <xsl:with-param name="tag" select="local-name()"/>
      </xsl:call-template>
    </xsl:template>
    <xsl:template match="@teiform"/>
    <xsl:template match="@*">
      <xsl:copy/>
    </xsl:template>
    
    <xsl:template name="recursive">
      <xsl:param name="tag"/>
      <xsl:element name="{$tag}">
        <xsl:apply-templates select="current()" mode="generate_id"/>
        <xsl:apply-templates select="current()" mode="regularize"/>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </xsl:template>

    <xsl:template match="div|div0|div1|div2|div3|div4|div5|div6|div7|lg|lg1|lg2|lg3|lg4|lg5|
                         bibl/title|quote/title|cell|
                         head|ab|p|q|quote|cit|epigraph|salute|dateline|signed|argument|byline|l|sp|
                         name|rs|bibl|date|item" mode="generate_id">
      <xsl:if test="not(@id)">
        <xsl:attribute name="id">_id<xsl:number level="any" 
        count="div|div0|div1|div2|div3|div4|div5|div6|div7|lg|lg1|lg2|lg3|lg4|lg5|
        bibl/title|quote/title|cell|
        head|ab|p|q|quote|cit|epigraph|salute|dateline|signed|argument|byline|l|sp|
        name|rs|bibl|date|dateRange|item"/></xsl:attribute>
      </xsl:if>
    </xsl:template>
    <xsl:template match="*" mode="generate_id"/>

    <xsl:template match="name|rs|orig" mode="regularize">
      <xsl:if test="not(@reg)">
        <xsl:attribute name="reg"><xsl:value-of select="normalize-space()"/></xsl:attribute>
      </xsl:if>
    </xsl:template>
    <xsl:template match="*" mode="regularize"/>
</xsl:stylesheet>