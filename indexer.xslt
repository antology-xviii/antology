<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings">
  <xsl:param name="docid"/>
  <xsl:param name="operation"/>
  <xsl:output method="text" media-type="text/x-sql" encoding="koi8-r" />
  <xsl:template match="/">
    begin;
    insert into texts (url,
                       title,
                       <xsl:if test="//SOURCEDESC//SOURCEDESC">original_title, publisher, published,</xsl:if>
                       <xsl:if test="//LG1/L|//LG/L">first_line,</xsl:if>
                       <xsl:if test="//PROFILEDESC/CREATION/DATE">written,</xsl:if>
                       <xsl:if test="//PROFILEDESC/CREATION/NAME[@TYPE='place']|//DATELINE/NAME[@TYPE='place']">
                         written_place,
                       </xsl:if>
                       <xsl:if test="//PERFORMANCE//DATE">performed,</xsl:if>
                       author_id
                       ) values
                       ('<xsl:value-of select="$docid"/>',                       
                       <xsl:variable name="title"><xsl:apply-templates select="//FILEDESC/TITLESTMT/TITLE"/></xsl:variable>
                       '<xsl:value-of select="normalize-space($title)"/>',
                       <xsl:if test="//SOURCEDESC//SOURCEDESC">
                         <xsl:variable name="origTitle"><xsl:apply-templates select="//SOURCEDESC//SOURCEDESC//TITLE"/></xsl:variable>
                         '<xsl:value-of select="normalize-space($origTitle)"/>',
                         '<xsl:value-of select="normalize-space(//SOURCEDESC//SOURCEDESC//PUBLICATIONSTMT/PUBLISHER)"/>',
                         '<xsl:value-of select="normalize-space(//SOURCEDESC//SOURCEDESC//PUBLICATIONSTMT/DATE)"/>',
                       </xsl:if>
                       <xsl:if test="//LG1/L|//LG/L">$$<xsl:value-of select='normalize-space(//LG1/L[1]|//LG/L[1])'/>$$,</xsl:if>
                       <xsl:if test="//PROFILEDESC/CREATION/DATE">
                         '<xsl:value-of select="//PROFILEDESC/CREATION/DATE"/>',
                       </xsl:if>
                       <xsl:if test="//PROFILEDESC/CREATION/NAME[@TYPE='place']|//DATELINE/NAME[@TYPE='place']">
                         '<xsl:value-of select="normalize-space(//PROFILEDESC/CREATION/NAME[@TYPE='place']|//DATELINE/NAME[@TYPE='place'])"/>',
                       </xsl:if>
                       <xsl:if test="//PERFORMANCE//DATE">
                         '<xsl:value-of select="normalize-space(//PERFORMANCE//DATE)"/>',
                       </xsl:if>
                       (select uid from authors where given_name = '<xsl:value-of select="//AUTHOR/PERSNAME/FORENAME[1]"/>' and
                                                      surname = '<xsl:value-of select="//AUTHOR/PERSNAME/SURNAME"/>')
                       );
       
    insert into text_structure (text_id, label) values ('<xsl:value-of select="$docid"/>', '');
    <xsl:apply-templates select="*[@ID]" mode="idrefs" />
    <xsl:apply-templates select="//TEXTCLASS/CATREF"/>
    <xsl:apply-templates select="//*[@MET]" mode="met"/>
    <xsl:apply-templates select="//*[@RHYME]" mode="rhyme"/>
    <xsl:apply-templates select="/TEI.2/TEIHEADER//TITLESTMT//NAME" mode="refs">
      <xsl:with-param name="fragment" select="''"/> 
    </xsl:apply-templates>
    <xsl:apply-templates select="/TEI.2/TEXT" mode="refs">
      <xsl:with-param name="fragment" select="''"/> 
    </xsl:apply-templates>
    <xsl:choose>
      <xsl:when test="$operation = 'simulate'">rollback;</xsl:when>
      <xsl:otherwise>commit;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="CATREF">
    insert into text_classification (text_id, taxonomy, category) 
    values ('<xsl:value-of select="$docid"/>', 
    lower('<xsl:value-of select="@SCHEME"/>'), 
    lower('<xsl:value-of select="@TARGET"/>'));
  </xsl:template>
  <xsl:template match="*[@MET]" mode="met">
    insert into text_metric (text_id, frag_id, sys_id, characteristic) 
    values ('<xsl:value-of select="$docid"/>', '',
    'met', '<xsl:value-of select="normalize-space(@MET)"/>');
  </xsl:template>
  <xsl:template match="*[@RHYME]" mode="rhyme">
    insert into text_metric (text_id, frag_id, sys_id, characteristic) 
    values ('<xsl:value-of select="$docid"/>', '',
    'rhyme', $$<xsl:value-of select='normalize-space(@RHYME)'/>$$);
  </xsl:template>
  <xsl:template match="TITLE">
    <xsl:if test="not(@TYPE) or @TYPE != 'subordinate'">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="NOTE"/>
  <xsl:template match="DIV1|DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9" mode="refs">
    <xsl:param name="fragment"/>
    <xsl:variable name="divnum">
      <xsl:number level="multiple" 
                  count="DIV1|DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9" format="1."/>
    </xsl:variable>
    insert into text_structure (text_id, label, container) 
    values ('<xsl:value-of select="$docid"/>',
            '<xsl:value-of select="$divnum"/>',
            '<xsl:value-of select="$fragment"/>');
    <xsl:apply-templates mode="refs">
      <xsl:with-param name="fragment" select="$divnum"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="TITLE[NAME]|HEAD[NAME]|ITEM[NAME]|Q[NAME]|L[NAME]|P[NAME]|QUOTE[NAME]|CELL[NAME]" mode="refs">
    <xsl:param name="fragment"/>
    <xsl:variable name="relid">
      <xsl:number level="any"
                  count="TITLE[NAME]|HEAD[NAME]|ITEM[NAME]|Q[NAME]|L[NAME]|P[NAME]|QUOTE[NAME]|CELL[NAME]"
                  from="BODY|DIV0|DIV1|DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9"
                  format=":1"/>                 
    </xsl:variable>
    insert into text_structure (text_id, label, container, fragment) values
    ('<xsl:value-of select="$docid"/>',
    '<xsl:value-of select="concat($fragment, $relid)"/>',
    '<xsl:value-of select="$fragment"/>',
    $$<xsl:value-of select='normalize-space(.)'/>$$);
    <xsl:apply-templates mode="refs">
      <xsl:with-param name="fragment" select="concat($fragment, $relid)"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="NAME" mode="refs">
        <xsl:param name="fragment"/>
        <xsl:variable name="thebody" select='normalize-space(.)'/>
        <xsl:variable name="thereg" select='normalize-space(@REG)'/>
        insert into text_names (text_id, frag_id, name_class, proper_name, occurrence, refid)
        values ('<xsl:value-of select="$docid"/>', '<xsl:value-of select="$fragment"/>',
                  '<xsl:value-of select="normalize-space(@TYPE)"/>',
                  <xsl:if test="@REG">$$<xsl:value-of select="$thereg"/>$$,</xsl:if>
                  <xsl:if test="not(@REG)">$$<xsl:value-of select="$thebody"/>$$,</xsl:if>
                  $$<xsl:value-of select="$thebody"/>$$,
                  'NAME<xsl:number level="any" format="1"/>');
        <xsl:if test="@TYPE = 'person' and (ancestor::SALUTE)">
          insert into text_annotations (text_id, frag_id, kind, annotation)
          values ('<xsl:value-of select="$docid"/>', '<xsl:value-of select="$fragment"/>',
          'addressee',
          <xsl:if test="@REG">$$<xsl:value-of select="$thereg"/>$$</xsl:if>
          <xsl:if test="not(@REG)">$$<xsl:value-of select="$thebody"/>$$</xsl:if>);
        </xsl:if>
    <xsl:apply-templates mode="refs">
      <xsl:with-param name="fragment" select="$fragment"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="ROLE" mode="refs">
    <xsl:param name="fragment"/>
    insert into text_names (text_id, frag_id, name_class, proper_name, occurrence, refid)
    values ('<xsl:value-of select="$docid"/>', '<xsl:value-of select="$fragment"/>',
    'person', '<xsl:value-of select="translate(normalize-space(.), '.', '')"/>', 
    '<xsl:value-of select="translate(normalize-space(.), '.', '')"/>', 
    '<xsl:value-of select="@ID"/>');
  </xsl:template>
  <xsl:template match="SPAN" mode="refs">
    insert into text_annotations (text_id, frag_id, kind, annotation) values
    ('<xsl:value-of select="$docid"/>', 
    <xsl:choose>
        <xsl:when test="id(@FROM)/self::BODY|id(@FROM)/self::DIV0|id(@FROM)/self::TEXT">
          '',
        </xsl:when>
        <xsl:when test="id(@FROM)/self::DIV1|id(@FROM)/self::DIV2|id(@FROM)/self::DIV3|id(@FROM)/self::DIV4|id(@FROM)/self::DIV5|id(@FROM)/self::DIV6">
          <xsl:for-each select="id(@FROM)">
            '<xsl:number level="multiple" 
                  count="DIV1|DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9" format="1."/>',
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>'<xsl:value-of select="@FROM"/>',</xsl:otherwise>
    </xsl:choose>
    '<xsl:value-of select="@TYPE"/>',
    '<xsl:value-of select="normalize-space(@VALUE)"/>');
  </xsl:template>
  <xsl:template match="text()" mode="refs"/>
  <xsl:template match="*" mode="refs">
    <xsl:param name="fragment"/>
    <xsl:apply-templates mode="refs">
      <xsl:with-param name="fragment" select="$fragment"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="*[@ID]" mode="idrefs">
    <xsl:if test="not(self::BODY|self::DIV0|self::DIV1|self::DIV2|self::DIV3|self::DIV4|self::DIV5|self::DIV6|self::TEXT)">
      insert into text_structure (text_id, label)
      values ('<xsl:value-of select="$docid"/>', '<xsl:value-of select="@ID"/>');
    </xsl:if>
    <xsl:apply-templates mode="idrefs"/>
  </xsl:template>
</xsl:stylesheet>
