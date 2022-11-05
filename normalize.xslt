<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude">
  <xsl:output method="xml" media-type="application/tei+xml"
              indent="yes"
              encoding="utf-8" />
  <xsl:variable name="entity_mapping" select="document('mapping.xml')"/>
  <xsl:key name="map_entity" match="mapping" use="@entity"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei.2" priority="1">
    <xsl:call-template name="recursive">
      <xsl:with-param name="tag" select="'TEI'"/>
    </xsl:call-template>
  </xsl:template>

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

  <xsl:template match="forename" priority="1">
    <xsl:call-template name="recursive">
      <xsl:with-param name="tag" select="'forename'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xref" priority="1">
    <tei:ref target="{unparsed-entity-uri(@doc)}">
      <xsl:apply-templates select="node()" />
    </tei:ref>
  </xsl:template>

  <xsl:template match="encodingdesc" priority="1">
    <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:attribute name="href">encoding.xml</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="profiledesc" priority="1">
    <tei:profileDesc>
      <xsl:if test="//*/@calendar = 'roman'">
        <tei:calendarDesc>
          <tei:calendar xml:id="roman" target="https://ru.wikipedia.org/wiki/Ab_Urbe_condita">
            <tei:p>Ab Urbe condita</tei:p>
          </tei:calendar>
        </tei:calendarDesc>
      </xsl:if>
      <xsl:apply-templates select="node()" />
    </tei:profileDesc>
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

  <xsl:template match="span[@value]" priority="1">
    <tei:span>
      <xsl:apply-templates select="@*" />
      <xsl:value-of select="@value" />
    </tei:span>
  </xsl:template>

  <xsl:template match="name[@reg]" priority="1">
    <tei:name>
      <xsl:apply-templates select="@*" />
      <tei:choice>
        <tei:orig><xsl:apply-templates select="node()" /></tei:orig>
        <tei:reg><xsl:value-of select="@reg" /></tei:reg>
      </tei:choice>
    </tei:name>
  </xsl:template>

  <xsl:template match="orig[@reg]" priority="1">
    <tei:choice>
      <tei:orig><xsl:apply-templates select="node()|@*" /></tei:orig>
      <tei:reg><xsl:value-of select="@reg" /></tei:reg>
    </tei:choice>
  </xsl:template>

  <xsl:template match="abbr[@expan]" priority="1">
    <tei:choice>
      <tei:abbr><xsl:apply-templates select="node()|@*" /></tei:abbr>
      <tei:expan><xsl:value-of select="@expan" /></tei:expan>
    </tei:choice>
  </xsl:template>

  <xsl:template match="figure[@entity]" priority="1">
    <tei:figure>
        <xsl:apply-templates select="@*|node()" />
        <tei:graphic url="{unparsed-entity-uri(@entity)}" />
    </tei:figure>
  </xsl:template>

  <xsl:template match="resp[name]" priority="1">
    <xsl:variable name="point" select="name" />
    <tei:resp>
      <xsl:apply-templates select="$point/preceding-sibling::node()" />
    </tei:resp>
    <tei:name>
      <xsl:apply-templates select="$point/@*" />
      <tei:choice>
        <tei:orig><xsl:apply-templates select="$point/node()" />
        <xsl:apply-templates select="$point/following-sibling::node()" />
        </tei:orig>
        <tei:reg><xsl:value-of select="$point/@reg" /></tei:reg>
      </tei:choice>
    </tei:name>
  </xsl:template>

  <xsl:template match="daterange" priority="1">
    <xsl:call-template name="recursive">
      <xsl:with-param name="tag" select="'date'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*">
    <xsl:call-template name="recursive">
      <xsl:with-param name="tag" select="local-name()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@teiform | @targorder"/>
  <xsl:template match="teiheader/@type | teiheader/@status | span/@value | name/@reg | orig/@reg | figure/@entity | abbr/@expan" />

  <xsl:template match="q/@direct">
    <xsl:if test=". != 'unspecified'">
      <xsl:message terminate="yes">
        Unsupported 'direct' attribute: <xsl:value-of select="." />
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@target">
    <xsl:attribute name="target">#<xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <xsl:template match="@anchored[. = 'no']">
    <xsl:attribute name="anchored">false</xsl:attribute>
  </xsl:template>

  <xsl:template match="@anchored[. = 'yes']">
    <xsl:attribute name="anchored">true</xsl:attribute>
  </xsl:template>

  <xsl:template match="@default[. = 'no']">
    <xsl:attribute name="default">false</xsl:attribute>
  </xsl:template>

  <xsl:template match="@id">
    <xsl:attribute name="xml:id"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <xsl:template match="biblscope/@type">
    <xsl:attribute name="unit"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <xsl:template match="date/@certainty[. = 'ca']">
    <xsl:attribute name="cert">medium</xsl:attribute>
  </xsl:template>

  <xsl:template match="date/@value">
    <xsl:variable name="ybc" select="substring-before(., 'BC')" />
    <xsl:variable name="abuc" select="substring-before(normalize-space(), ' ab U. c')" />
    <xsl:choose>
      <xsl:when test="string-length($ybc) = 3"><xsl:attribute name="when">-0<xsl:value-of select="$ybc" /></xsl:attribute></xsl:when>
      <xsl:when test="string-length($abuc) = 3"><xsl:attribute name="when-custom">0<xsl:value-of select="$abuc" /></xsl:attribute></xsl:when>
      <xsl:when test="string-length($abuc) = 9"><xsl:attribute name="when-custom">0<xsl:value-of select="substring(., 7, 3)" />-<xsl:value-of select="substring(., 4, 2)" />-<xsl:value-of select="substring(., 1, 2)" /></xsl:attribute></xsl:when>
      <xsl:when test="string-length(.) = 10"><xsl:attribute name="when"><xsl:value-of select="substring(., 7, 4)" />-<xsl:value-of select="substring(., 4, 2)" />-<xsl:value-of select="substring(., 1, 2)" /></xsl:attribute></xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          Unsupported date <xsl:value-of select="." />
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="date/@calendar">
    <xsl:choose>
      <xsl:when test=". = 'roman'"><xsl:attribute name="calendar">#roman</xsl:attribute></xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          Unsupported calendar <xsl:value-of select="." />
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@part">
    <xsl:attribute name="part"><xsl:value-of select="translate(., 'ynfmi', 'YNFMI')" /></xsl:attribute>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="translate(., '&#x0a;', ' ')" />
  </xsl:template>

  <xsl:template name="recursive">
    <xsl:param name="tag"/>
    <xsl:element name="{$tag}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
