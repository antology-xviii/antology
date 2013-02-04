<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="./library.xslt"/>
  <xsl:param name="path_info"/>
  <xsl:param name="basepath"/>
  <xsl:param name="hilite"/>
  <xsl:param name="colophon" select="1" />
  <xsl:param name="only-speaker" />
  <xsl:output method="xml" encoding="utf-8" />
  <xsl:variable name="uriencoding" select="document('uriencoding.xml')"/>
  <xsl:key name="map_char" match="mapping" use="@char"/>

  <xsl:template match="TEI.2">
    <html>
      <head>
        <meta http-equiv="content-type" content="text/html;charset=utf-8" />
        <link rel="stylesheet" href="{$basepath}/../css/navigation.css" type="text/css" />
        <link rel="stylesheet" href="{$basepath}/../css/tei.css" type="text/css" />
        <link rel="alternate" href="{$basepath}/../cache{$path_info}" type="application/tei+xml" />
        <link rel="alternate" href="{$basepath}/../cache{substring-before($path_info, '.tei')}.rdf" type="application/rdf+xml" />
        <meta name="title" content="{normalize-space(teiHeader/fileDesc/titleStmt/title[@type = 'main' or not(@type)])}" />
        <meta name="DC.author">
          <xsl:attribute name="content">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/author/persName/forename">
              <xsl:value-of select="substring(., 1, 1)"/>
              <xsl:text>. </xsl:text>
            </xsl:for-each>
            <xsl:value-of select="teiHeader/fileDesc/titleStmt/author/persName/surname"/>
          </xsl:attribute>
        </meta>
        <meta name="DC.creator" content="{normalize-space(teiHeader/fileDesc/titleStmt/principal)}"/>
        <meta name="DC.publisher" content="{normalize-space(teiHeader/fileDesc/publicationStmt/publisher)}" />
        <meta name="DC.rights" content="{normalize-space(teiHeader/fileDesc/publicationStmt/availability)}"/>
        <meta name="DC.keywords">
          <xsl:attribute name="content">
            <xsl:for-each select="//span[@type = 'theme']/@value" >
              <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
              <xsl:value-of select="normalize-space()"/>
            </xsl:for-each>
          </xsl:attribute>
        </meta>
      </head>
      <xsl:apply-templates select="text"/>
    </html>
  </xsl:template>
  <xsl:template match="text">
    <body>
      <xsl:if test="$colophon">
        <xsl:apply-templates select="/TEI.2/teiHeader" mode="metadata"/>
      </xsl:if>
      <xsl:apply-templates select="*"/>
      <hr/>
      <xsl:apply-templates select=".//note[@place != 'inline']" mode="footnotes" />
      <hr/>
      <div class="footer">
        <a href="">Логическая разметка текста:</a>
        <a>
          <xsl:attribute name="href"><xsl:value-of select="$basepath"/>/search.cgi?principal=<xsl:call-template name="encode">
          <xsl:with-param name="uri" 
                          select="normalize-space(/TEI.2/teiHeader/fileDesc/titleStmt/principal)"/>
        </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="normalize-space(/TEI.2/teiHeader/fileDesc/titleStmt/principal)"/>
        </a><br/>
        <xsl:for-each select="/TEI.2/teiHeader/fileDesc/titleStmt/sponsor" >
          <xsl:value-of select="normalize-space()" /><br/>
        </xsl:for-each>
        <xsl:for-each select="/TEI.2/teiHeader/fileDesc/titleStmt/funder" >
          <xsl:value-of select="normalize-space()" /><br/>
        </xsl:for-each>
      </div>
    </body>
  </xsl:template>
  <xsl:template match="front|back|body|div|performance|set|trailer|opener|closer">
    <div class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="q">
    <q class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  <xsl:template match="quote">
    <blockquote class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  <xsl:template match="cit">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="bibl">
    <cit class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </cit>
  </xsl:template>
  <xsl:template match="ab|bibl/title|bibl/author|bibl/biblScope|bibl/pubPlace|role|roleDesc|speaker|rs|term|soCalled">
    <span class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="foreign">
    <span class="tei-{local-name()}">
      <xsl:apply-templates select="@id|@lang"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="p|argument|salute|dateline|signed|byline">
    <p class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="epigraph">
    <blockquote class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>

  <xsl:template match="lg">
    <div class="tei-{local-name()}-{@type}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="l">
    <span class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </span>
    <br/>
  </xsl:template>

  <xsl:template match="l[anchor[@id]]" priority="1.5">
    <xsl:variable name="ptr" select="anchor/@id"/>
    <table class="alignment">
      <xsl:for-each select=".|following::l[anchor[@corresp = $ptr]]">
        <tr class="tei-l" id="@id">
          <td>
            <xsl:apply-templates select="node()[following-sibling::anchor]"/>
          </td>
          <td>
            <xsl:apply-templates select="node()[preceding-sibling::anchor]"/>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <xsl:template match="l[anchor[@corresp]]" priority="2">
    <xsl:variable name="corresp" select="anchor/@corresp"/>
    <xsl:if test="not(preceding::l[anchor[@id = $corresp]])">
      <xsl:message terminate="yes">
        Correspodence not found: <xsl:value-of select="$corresp"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="name">
    <abbr title="{@reg}">
      <xsl:attribute name="class">
        tei-<xsl:value-of select="local-name()"/>-<xsl:value-of select="@type"/>
        <xsl:if test="$hilite = @reg"><xsl:text> </xsl:text>hilite</xsl:if>
      </xsl:attribute>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>
  <xsl:template match="date">
    <abbr class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:if test="@value or @calendar or @certainty">
        <xsl:attribute name="title">
          <xsl:value-of select="@certainty"></xsl:value-of>
          <xsl:value-of select="@value"></xsl:value-of>
          <xsl:value-of select="@calendar"></xsl:value-of>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>
  <xsl:template match="dateRange">
    <abbr class="tei-{local-name()}" title="{@from}-{@to}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>
  <xsl:template match="orig">
    <abbr class="tei-{local-name()}" title="{@reg}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>
  <xsl:template match="emph|hi">
    <em>
      <xsl:attribute name="class">
        tei-<xsl:value-of select="local-name()"/>
        <xsl:if test="@rend">-<xsl:value-of select="@rend"/></xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  <xsl:template match="mentioned">
    <samp class="tei-{local-name()}"><xsl:apply-templates/></samp>
  </xsl:template>
  <xsl:template match="@id|@lang">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="head[@type = 'subordinate']">
    <h3>
      <xsl:apply-templates select="@id"/>
      <xsl:value-of select="ancestor-or-self::div[1]/@n"/>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>
  <xsl:template match="head">
    <h2>
      <xsl:apply-templates select="@id"/>
      <xsl:value-of select="ancestor-or-self::div[1]/@n"/>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  <xsl:template match="list/head|quote/title" priority="2">
    <h2>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="table/head" priority="2">
    <caption>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>

  <xsl:template match="list[@type = 'bill']/head" priority="2.5">
    <tr>
      <xsl:apply-templates select="@id"/>
      <th colspan="2">
        <xsl:apply-templates/>
      </th>
    </tr>
  </xsl:template>

  <xsl:template match="list/head" mode="alignment">
    <tr>
      <xsl:for-each select=".|following::list/head[@corresp = current()/@id]">
        <th>
          <xsl:apply-templates select="@id"/>
          <xsl:apply-templates/>
        </th>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <xsl:template match="list/head" mode="alignment">
    <tr>
      <xsl:for-each select=".|following::list/item[@corresp = current()/@id]">
        <td>
          <xsl:apply-templates select="@id"/>
          <xsl:apply-templates/>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>


  <xsl:template match="list/item">
    <li>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="list[@type = 'dialogue']/item" priority="2">
    <dt>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="label"/>
    </dt>
    <dd>
      <xsl:apply-templates select="node()[local-name() != 'label']"/>
    </dd>
  </xsl:template>

  <xsl:template match="list[@type = 'bill']/item" priority="2">
    <tr>
      <xsl:apply-templates select="@id"/>
      <td>
        <xsl:apply-templates select="node()[local-name() != 'label']"/>
      </td>
      <td>
        <xsl:apply-templates select="label"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="item/label">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="castList">
    <div class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="head"/>
      <ul>
        <xsl:apply-templates select="castItem"/>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="stage">
    <span class="tei-{local-name()}-{@type}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="sp">
    <p class="tei-{local-name}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="sp" mode="parallel">
    <p class="tei-{local-name}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="sp[following::sp[@corresp = current()/@id]]" priority="2">
    <xsl:variable name="corresp" select="following::sp[@id = current()/@corresp]"/>
    <table class="correspondence">
      <tr><td><xsl:apply-templates select="." mode="parallel"/></td></tr>
      <tr><td><xsl:apply-templates select="$corresp" mode="parallel"/></td></tr>
    </table>
  </xsl:template>

  <xsl:template match="castItem">
    <li>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="list[@type = 'ordered']">
    <div class="tei-list-ordered">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="head"/>
      <ol>
        <xsl:apply-templates select="item"/>
      </ol>
    </div>
  </xsl:template>
  <xsl:template match="list[@type = 'bulleted' or @type = 'simple']">
    <div class="tei-list-unordered">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="head"/>
      <ul>
        <xsl:apply-templates select="item"/>
      </ul>
    </div>
  </xsl:template>
  <xsl:template match="list[@type = 'dialogue']">
    <div class="tei-list-dialogue">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="head"/>
      <dl>
        <xsl:apply-templates select="item"/>
      </dl>
    </div>
  </xsl:template>

  <xsl:template match="list[@type = 'bill']">
    <table class="tei-list-bill">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="head"/>
      <xsl:apply-templates select="item"/>
    </table>
  </xsl:template>

  <xsl:template match="list[@type = 'simple' and following::list[@corresp = current()/@id]]" priority="2">
    <table class="tei-list-aligned">
      <xsl:apply-templates select="head" mode="alignment"/>
      <xsl:apply-templates select="item" mode="alignment"/>
    </table>
  </xsl:template>

  <xsl:template match="note[@place = 'inline']">
    <div class="tei-note-inline">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="note">
    <a class="tei-note-ref" href="#{@id}" id="{@id}_place">
      <xsl:call-template name="number-footnote"/>
    </a>
  </xsl:template>

  <xsl:template match="note" mode="footnotes">
    <p class="tei-note">
      <a class="tei-note-ref" href="#{@id}_place" id="{@id}">
        <xsl:call-template name="number-footnote"/>
      </a>
      <xsl:apply-templates/>
      <xsl:if test="@resp = 'editor'">
        <span class="tei-note-resp">(Прим. ред.)</span>
      </xsl:if>
      <xsl:if test="@resp = 'author'">
        <span class="tei-note-resp">(Прим. автора)</span>
      </xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="space[@dim = 'horizontal' and contains(@extent, 'letters')]">
    <span style="width: {substring-before(@extent, ' ')}em"/>
  </xsl:template>

  <xsl:template match="figure">
    <img class="tei-{local-name()}" 
         src="{unparsed-entity-uri(@entity)}" 
         alt="{normalize-space(figDesc)}" />
  </xsl:template>

  <xsl:template match="table">
    <table class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="row">   
    <tr class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="cell">   
    <td class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="row[type = 'label']/cell|cell[type = 'label']" priority="2">
    <th class="tei-{local-name()}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </th>
  </xsl:template>

  <xsl:template match="add">
    <ins class="tei-{local-name()}"><xsl:apply-templates/></ins>
  </xsl:template>

  <xsl:template match="w">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="span"/>
  <xsl:template match="move"/>
  <xsl:template match="*[@corresp]" priority="5">
    <xsl:variable name="corresp" select="@corresp"/>
    <xsl:if test="not(preceding::*[@id = $corresp])">
      <xsl:message terminate="yes">
        Corresponding element <xsl:value-of select="$corresp"/> not found
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*">
    <xsl:message terminate="yes">
      Unknown element <xsl:value-of select="local-name()"/> 
      (<xsl:value-of select="normalize-space()"/>) 
      in <xsl:value-of select="local-name(..)"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="teiHeader" mode="metadata">
    <table class="colophon">
      <tr>
        <td>Цит. по.:</td>
        <td></td>
      </tr>
      <tr>
      </tr>
    </table>
  </xsl:template>

  <xsl:template name="comma-list">
    <xsl:param name="nodes"/>
    <xsl:param name="keyword"/>
    <xsl:for-each select="$nodes">
      <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
      <a>
        <xsl:attribute name="href"><xsl:value-of select="$basepath"/>/search.cgi?<xsl:value-of select="$keyword"/>=<xsl:call-template name="encode">
        <xsl:with-param name="uri" select="normalize-space()"/>
      </xsl:call-template>
        </xsl:attribute>
        <xsl:value-of select="normalize-space()"/>
      </a>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="number-footnote">
    <xsl:if test="not(@n)">
      <xsl:choose>
        <xsl:when test="@resp = 'editor'">
          <xsl:number level="any" count="note[@resp = 'editor' and @place != 'inline']" from="text" format="а"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number level="any" count="note[@resp != 'editor' and @place != 'inline']" from="text" format="а"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:value-of select="@n"/>
  </xsl:template>
</xsl:stylesheet>