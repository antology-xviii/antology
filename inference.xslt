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
      <xsl:call-template name="checkClass">
        <xsl:with-param name="metaclass" select="key('object', $resource)/rdf:type/@rdf:resource"/>
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

  <xsl:template name="processProperty">
    <xsl:param name="element"/>
    <xsl:param name="kind"/>
    <xsl:for-each select="$schemafile">
      <xsl:call-template name="checkProperty">
        <xsl:with-param name="propclass" select="key('object', name($element))/rdf:type/@rdf:resource"/>
      </xsl:call-template>
      <xsl:call-template name="checkDomain">
        <xsl:with-param name="prop" select="name($element)"/>
        <xsl:with-param name="domain" select="$element/../rdf:type/@rdf:resource"/>      
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$kind = 'resource'">
          <xsl:call-template name="checkRange">
            <xsl:with-param name="prop" select="name($element)"/>
            <xsl:with-param name="range" select="key('object', $element/@rdf:resource|$element/@rdf:nodeID)/rdf:type/@rdf:resource"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$kind = 'xmlliteral'">
          <xsl:call-template name="checkXMLLiteral">
            <xsl:with-param name="propns" select="$propns"/>
            <xsl:with-param name="prop" select="$prop"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$kind = 'typedliteral'">
          <xsl:call-template name="checkLiteral">
            <xsl:with-param name="propns" select="$propns"/>
            <xsl:with-param name="prop" select="$prop"/>
            <xsl:with-param name="xsdtype" select="$element/@rdf:datatype"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$kind = 'literal'">
          <xsl:call-template name="checkLiteral">
            <xsl:with-param name="propns" select="$propns"/>
            <xsl:with-param name="prop" select="$prop"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="expandProperty">
        <xsl:with-param name="propns" select="$propns"/> 
        <xsl:with-param name="prop" select="$prop"/>
        <xsl:with-param name="element" select="$element"/>
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

  <xsl:template name="checkClass">
    <xsl:param name="metaclass"/>
    <xsl:if test="not($metaclass)">
      <xsl:message terminate="yes">
        The class is not a Class
      </xsl:message>
    </xsl:if>
    <xsl:if test="$metaclass != 'http://www.w3.org/2000/01/rdf-schema#Class'">
      <xsl:if test="$metaclass = 'http://antology-xviii.spb.ru/schema/service.rdf#AbstractClass'">
        <xsl:message terminate="yes">
          Instantiating an abstract class
        </xsl:message>
      </xsl:if>
      <xsl:call-template name="checkClass">
        <xsl:with-param name="metaclass" select="key('object', $metaclass)/rdfs:subClassOf/@rdf:resource"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="expandType">
    <xsl:param name="class"/>
    <xsl:if test="$class">
      <xsl:for-each select="$class">
        <rdf:type rdf:resource="{.}"/>
      </xsl:for-each>
      <xsl:call-template name="expandType">
        <xsl:with-param name="class" select="key('object', $class)/rdfs:subClassOf/@rdf:resource"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="checkProperty">
    <xsl:param name="propclass"/>
    <xsl:if test="not($propclass)">
      <xsl:message terminate="yes">
        The property is not a Property
      </xsl:message>
    </xsl:if>
    <xsl:if test="$propclass != 'http://www.w3.org/2000/01/rdf-schema#Property'">
      <xsl:if test="$metaclass = 'http://antology-xviii.spb.ru/schema/service.rdf#AbstractProperty'">
        <xsl:message terminate="yes">
          Instantiating an abstract property
        </xsl:message>
      </xsl:if>
      <xsl:call-template name="checkProperty">
        <xsl:with-param name="propclass" select="key('object', $metaclass)/rdfs:subClassOf/@rdf:resource"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>