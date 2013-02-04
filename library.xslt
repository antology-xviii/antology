<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="encode">
    <xsl:param name="uri"/>
    <xsl:if test="$uri">
      <xsl:variable name="head" select="substring($uri, 1, 1)"/>
      <xsl:for-each select="$uriencoding">
        <xsl:variable name="mapping" select="key('map_char', $head)"/>
        <xsl:if test="not($mapping)">
          <xsl:message terminate="yes">
            Unmappable character '<xsl:value-of select="$head"/>'
          </xsl:message>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$mapping/@value">
            <xsl:value-of select="$mapping/@value"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$mapping/@char"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:call-template name="encode">
        <xsl:with-param name="uri" select="substring($uri, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>