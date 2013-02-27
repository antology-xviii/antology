<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:variable name="uriencoding" select="document('uriencoding.xml')"/>
  <xsl:key name="map_char" match="mapping" use="@char"/>

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

  <xsl:template name="abbreviate">
    <xsl:param name="name" select="."/>
    <xsl:value-of select="$name/surname"/>
    <xsl:for-each select="$name/foreName">
      <xsl:text> </xsl:text>
      <xsl:value-of select="substring(., 1, 1)"/>
      <xsl:text>.</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="bibl" mode="mkbibquery">
    <xsl:apply-templates select="title" mode="mkbibquery"/>
    <xsl:apply-templates select="author" mode="mkbibquery"/>
    <xsl:apply-templates select="editor" mode="mkbibquery"/>
    <xsl:apply-templates select="date" mode="mkbibquery"/>
    <xsl:apply-templates select="publisher" mode="mkbibquery"/>
    <xsl:apply-templates select="pubPlace" mode="mkbibquery"/>
    <xsl:apply-templates select="biblScope" mode="mkbibquery"/>
    <xsl:apply-templates select="series" mode="mkbibquery"/>
  </xsl:template>

  <xsl:template match="biblFull" mode="mkbibquery">
    <xsl:apply-templates select="titleStmt/title" mode="mkbibquery"/>
    <xsl:apply-templates select="titleStmt/author" mode="mkbibquery"/>
    <xsl:apply-templates select="titleStmt/editor" mode="mkbibquery"/>
    <xsl:apply-templates select="publicationStmt/date" mode="mkbibquery"/>
    <xsl:apply-templates select="publicationStmt/publisher" mode="mkbibquery"/>
    <xsl:apply-templates select="publicationStmt/pubPlace" mode="mkbibquery"/>
    <xsl:apply-templates select="seriesStmt" mode="mkbibquery"/>
  </xsl:template>

  <xsl:template match="title|publisher|biblScope" mode="mkbibquery">
    <xsl:text>&amp;</xsl:text><xsl:value-of select="local-name()"/><xsl:text>=</xsl:text>
    <xsl:call-template name="encode">
      <xsl:with-param name="uri" select="normalize-space(orig/@reg|.)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="pubPlace" mode="mkbibquery">
    <xsl:text>&amp;</xsl:text><xsl:value-of select="local-name()"/><xsl:text>=</xsl:text>   
    <xsl:call-template name="encode">
      <xsl:with-param name="uri" select="normalize-space(name/@reg|self::*[not(name)])"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="date" mode="mkbibquery">
    <xsl:text>&amp;</xsl:text><xsl:value-of select="local-name()"/><xsl:text>=</xsl:text>   
    <xsl:call-template name="encode">
      <xsl:with-param name="uri" select="normalize-space(@value|self::*[not(@value)])"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="author[persName]|editor[persName]" mode="mkbibquery">
    <xsl:text>&amp;</xsl:text><xsl:value-of select="local-name()"/><xsl:text>=</xsl:text>
    <xsl:call-template name="encode">
      <xsl:with-param name="uri">
        <xsl:call-template name="abbreviate">
          <xsl:with-param name="name" select="persName"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="author[name]|editor[name]" mode="mkbibquery">
    <xsl:text>&amp;</xsl:text><xsl:value-of select="local-name()"/><xsl:text>=</xsl:text>
    <xsl:call-template name="encode">
      <xsl:with-param name="uri" select="name/@reg"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="seriesStmt|series" mode="mkbibquery">
    <xsl:text>&amp;</xsl:text><xsl:text>series=</xsl:text>   
    <xsl:call-template name="encode">
      <xsl:with-param name="uri" select="normalize-space(title/orig/@reg|title[not(orig)])"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*" mode="mkbibquery"/>


  <xsl:template name="mkbibquery">
    <xsl:param name="ref" select="."/>
    <xsl:apply-templates select="$ref" mode="mkbibquery"/>
  </xsl:template>

  <xsl:template name="print-tag">
    <xsl:param name="tag" select="." />
    &lt;<xsl:value-of select="name($tag)"/>
    <xsl:for-each select="$tag/@*"><xsl:text> </xsl:text><xsl:value-of select="name()"/>=<xsl:value-of select="."/></xsl:for-each>&gt;
  </xsl:template>

  <xsl:template name="unknown-tag">
    <xsl:param name="tag" select="." />
    <xsl:message terminate="yes">
      I don't know what to do with 
      <xsl:call-template name="print-tag"/>
      <xsl:for-each select="ancestor::*">
        <xsl:sort select="position()" order="descending"/>
        in <xsl:call-template name="print-tag"/>
      </xsl:for-each>
    </xsl:message>
  </xsl:template>
</xsl:stylesheet>