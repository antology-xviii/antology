<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:svc="http://antology-xviii.spb.ru/schema/service.rdf#">
  <xsl:param name="schema"/>
  <xsl:key name="object" match="rdf:Description" use="@rdf:about|@rdf:nodeID"/>
  <xsl:variable name="schemafile" select="document($schema)"/>

  <xsl:template match="/rdf:RDF[not(@*)]">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="rdf:RDF/rdf:Description">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="rdf:Description/rdf:type[@rdf:resource and count(@*) = 1]">
    <xsl:variable name="resource" select="@rdf:resource"/>
    <xsl:for-each select="$schemafile">
      <xsl:call-template name="isSubclassOf">
        <xsl:with-param name="class" select="key('object', $resource)/rdf:type/@rdf:resource"/>
        <xsl:with-param name="baseclass" select="'http://www.w3.org/2000/01/rdf-schema#Class'"/>
        <xsl:with-param name="stopclass" select="'http://antology-xviii.spb.ru/schema/service.rdf#AbstractClass'"/>
        <xsl:with-param name="stopmsg" select="'A class is an abstract class'"/>
        <xsl:with-param name="failmsg" select="'A class is not a Class'"/>
      </xsl:call-template>
      <xsl:call-template name="expandType">
        <xsl:with-param name="class" select="$resource"/> 
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="rdf:Description/*[not(self::rdf:type|self::rdf:Description) 
                       and not(child::node())
                       and @rdf:resource|@rdf:nodeID and count($*) = 1]">
    <xsl:call-template name="processProperty">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="kind" select="'resource'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="rdf:Description/*[not(self::rdf:type|self::rdf:Description) 
                       and @rdf:parseType = 'Literal' and count($*) = 1]">
    <xsl:call-template name="processProperty">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="kind" select="'xmlliteral'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="rdf:Description/*[not(self::rdf:type|self::rdf:Description) 
                       and not(child::*)
                       and @rdf:datatype and count($*) = 1]">
    <xsl:call-template name="processProperty">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="kind" select="'typedliteral'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="rdf:Description/*[not(self::rdf:type|self::rdf:Description) 
                       and not(child::*) and count(@xml:*) = count(@*)]">
    <xsl:call-template name="processProperty">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="kind" select="'literal'"/>
    </xsl:call-template>
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

  <xsl:template name="processProperty">
    <xsl:param name="element"/>
    <xsl:param name="kind"/>
    <xsl:for-each select="$schemafile">
      <xsl:variable name="prop" select="key('object', name($element))"/>
      <xsl:call-template name="isSubclassOf">
        <xsl:with-param name="class" select="$prop/rdf:type/@rdf:resource"/>
        <xsl:with-param name="baseclass" select="'http://www.w3.org/2000/01/rdf-schema#Property'"/>
        <xsl:with-param name="stopclass" select="'http://antology-xviii.spb.ru/schema/service.rdf#AbstractProperty'"/>
        <xsl:with-param name="stopmsg" select="'A property is an abstract property'"/>
        <xsl:with-param name="failmsg" select="'A class is not a Property'"/>
      </xsl:call-template>
      <xsl:call-template name="checkDomain">
        <xsl:with-param name="prop" select="$prop"/>
        <xsl:with-param name="domain" select="$element/../rdf:type/@rdf:resource"/>      
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$kind = 'resource'">
          <xsl:call-template name="checkRange">
            <xsl:with-param name="prop" select="$prop"/>
            <xsl:with-param name="range" select="key('object', $element/@rdf:resource|$element/@rdf:nodeID)/rdf:type/@rdf:resource"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$kind = 'xmlliteral'">
          <xsl:call-template name="checkXMLLiteral">
            <xsl:with-param name="prop" select="$prop"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$kind = 'typedliteral'">
          <xsl:call-template name="checkLiteral">
            <xsl:with-param name="prop" select="$prop"/>
            <xsl:with-param name="xsdtype" select="$element/@rdf:datatype"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$kind = 'literal'">
          <xsl:call-template name="checkLiteral">
            <xsl:with-param name="prop" select="$prop"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="expandProperty">
        <xsl:with-param name="prop" select="$prop"/>
        <xsl:with-param name="element" select="$element"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="checkDomain">
    <xsl:param name="prop"/>
    <xsl:param name="domain"/>
    <xsl:if test="$prop">
      <xsl:variable name="domains" select="$prop/rdfs:domain/@rdf:resource"/>
      <xsl:if test="$domains">
        <xsl:call-template name="isSubclassOf">
          <xsl:with-param name="class" select="$domain"/>
          <xsl:with-param name="baseclass" select="$domains"/>
          <xsl:with-param name="failmsg" select="'Unsatisfied domain constraint'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not($domains)">
        <xsl:call-template name="checkDomain">
          <xsl:with-param name="prop" select="key('object', $prop/rdfs:subPropertyOf/@rdf:resource)"/>
          <xsl:with-param name="domain" select="$domain"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="checkRange">
    <xsl:param name="prop"/>
    <xsl:param name="range"/>
    <xsl:if test="$prop">
      <xsl:variable name="ranges" select="$prop/rdfs:range/@rdf:resource"/>
      <xsl:if test="$ranges">
        <xsl:call-template name="isSubclassOf">
          <xsl:with-param name="class" select="$range"/>
          <xsl:with-param name="baseclass" select="$ranges"/>
          <xsl:with-param name="failmsg" select="'Unsatisfied range constraint'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not($ranges)">
        <xsl:call-template name="checkRange">
          <xsl:with-param name="prop" select="key('object', $prop/rdfs:subPropertyOf/@rdf:resource)"/>
          <xsl:with-param name="range" select="$range"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template name="expandType">
    <xsl:param name="class"/>
    <xsl:for-each select="$class">
      <rdf:type rdf:resource="{.}"/>
    </xsl:for-each>
    <xsl:variable name="next" select="key('object', $class)/rdfs:subClassOf/@rdf:resource"/>
    <xsl:if test="$next">
      <xsl:call-template name="expandType">
        <xsl:with-param name="class" select="$next"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="isSubclassOf">
    <xsl:param name="class"/>
    <xsl:param name="baseclass"/>
    <xsl:param name="stopclass"/>
    <xsl:param name="stopmsg"/>
    <xsl:param name="failmsg"/>
    <xsl:if test="$stopclass and $class = $stopclass">
      <xsl:message terminate="yes">
        <xsl:value-of select="$stopmsg"/>
      </xsl:message>
    </xsl:if>
    <xsl:if test="$class != $baseclass">
      <xsl:variable name="next" select="key('object', $class)/rdfs:subClassOf/@rdf:resource"/>
      <xsl:if test="not($next)">
        <xsl:message terminate="yes">
          <xsl:value-of select="$failmsg"/>
        </xsl:message>
      </xsl:if>
      <xsl:call-template name="isSubclassOf">
        <xsl:with-param name="class" select="$next"/>
        <xsl:with-param name="baseclass" select="$baseclass"/>
        <xsl:with-param name="stopclass" select="$stopclass"/>
        <xsl:with-param name="stopmsg" select="$stopmsg"/>
        <xsl:with-param name="failmsg" select="$failmsg" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>