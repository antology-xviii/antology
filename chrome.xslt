<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xhtml="http://www.w3.org/1999/xhtml/">
  <xsl:output method="html" encoding="utf-8" />
  <xsl:template match="html">
    <html>
      <head>
        <title>Электронная антология русской литературы XVIII века. <xsl:value-of select="head/title"/></title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
        <xsl:apply-templates select="head/meta"/>
        <xsl:apply-templates select="head/link"/>
      </head>
      <body>
        <div class="header">
          <h1 class="topheading">&quot;Русская литература XVIII века&quot;</h1>
          <h2 class="topsubhead">Информационно-поисковая система</h2>

          <div class="menu">
            <a href="/index.html">главная</a>
            <a href="/cgi-bin/searchform.cgi">поиск</a>
            <a href="/lecture.html">справочные и учебные материалы</a>
            <!-- [<a href="/tests.html" class=menu>тесты и задания</a>]<br> -->
            <a href="/cgi-bin/people.cgi">об участниках проекта</a>
            <a href="/manual.pdf">руководство для пользователя</a>
            <a href="/contact.html">контакты</a>
          </div>
        </div>
        <hr/>
        <div class="contents">
          <xsl:apply-templates select="body"/>
        </div>
        <hr/>
        <div class="footer">         
          © 2011 П. Е. Бухаркин, А. В. Андреев, Е. М. Матвеев, М. В. Пономарева.<br/>
          При поддержке РФФИ, грант № 11-07-00493-a<br/>
          © 2007 Факультет филологии и искусств СПбГУ<br/>
          © 2007 П. Е. Бухаркин, А. В. Андреев, М. В. Борисова, М. В. Пономарева<br/>
        </div>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="body">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="xhtml:*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>