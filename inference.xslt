<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:svc="http://antology-xviii.spb.ru/schema/service.rdf#">
  <xsl:param name="schema"/>
  <xsl:key name="object" match="rdf:Description" use="@rdf:about"/>
  <xsl:key name="anonObject" match="rdf:Description" use="@rdf:nodeID"/>
  <xsl:variable name="schemafile" select="document($schema)"/>

  <xsl:template match="/rdf:RDF[not(@*)]">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="rdf:RDF/rdf:Description[not(@*[name() != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#about' and 
                       name() != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#nodeID'])]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="rdf:Description/rdf:type[not(child::node()) and not(@*[name() != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#resource']) and @rdf:resource">
    <xsl:variable name="resource" select="@rdf:resource"/>
    <xsl:for-each select="$schemafile">
      <xsl:call-template name="checkClass">
        <xsl:with-param name="metaclass" select="key('object', $resource)/rdf:type/@rdf:resource"/>
      </xsl:call-template>
      <xsl:call-template name="expandType">
        <xsl:with-param name="class" select="$resource"/> 
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="rdf:Description/*[not(child::node()) and not(@*[name() != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#resource']) and @rdf:resource">
    <xsl:variable name="prop" select="name()"/>
    <xsl:variable name="range" select="key('object', @rdf:resource)/rdf:type/@rdf:resource"/>
    <xsl:variable name="domain" select="../rdf:type/@rdf:resource"/>
    <xsl:for-each select="$schemafile">
      <xsl:call-template name="checkProperty">
        <xsl:with-param name="prop" select="$prop"/>
      </xsl:call-template>
      <xsl:call-template name="checkDomain">
        <xsl:with-param name="prop" select="$prop"/>
        <xsl:with-param name="domain" select="$domain"/>      
      </xsl:call-template>
      <xsl:call-template name="checkRange">
        <xsl:with-param name="range" select="$range"/>
      </xsl:call-template>
      <xsl:call-template name="expandProperty">
        <xsl:with-param name="prop" select="$prop"/> 
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="*">
    <xsl:message terminate="yes">
      The input RDF file is not normalized (unexpected element <xsl:value-of select="name()"/>)
    </xsl:message>
  </xsl:template>
  <xsl:template match="text()">
    <xsl:message terminate="yes">
      The input RDF file is not normalized (unexpected text <xsl:value-of select="."/>)
    </xsl:message>
  </xsl:template>
</xsl:stylesheet>