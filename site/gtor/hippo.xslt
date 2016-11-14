<?xml version="1.0"?>
<!DOCTYPE xml [
        <!ENTITY left-chevron "〈">
        <!ENTITY right-chevron "〉">
        ]>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:uri="java:java.net.URI"
                xmlns:url="java:java.net.URL"
                xmlns:file="java:java.io.File"
                xmlns:fn="http://www.couchbase.com/xsl/extension-functions"
                xmlns:saxon="http://saxon.sf.net/"
                exclude-result-prefixes="uri url file fn saxon">
  
  <xsl:output method="xhtml" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  
  <xsl:include href="search-index.xslt"/>
  
  <xsl:param name="generate-site" select="true()"/>
  <xsl:param name="index-search" select="true()"/>
  <xsl:param name="languages" select="//programming-languages/programming-language"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="site"/>
  </xsl:template>
  
  <!-- ==== -->
  <!-- Site -->
  <!-- ==== -->
  
  <xsl:template match="site">
    <xsl:if test="$generate-site">
      <xsl:apply-templates select="." mode="site-map"/>
      
      <!-- Generate Site -->
      <xsl:apply-templates select="(site-map | site-map/landing-pages)/(set | guide | class | article | lesson | page | xhtml-page | api)"/>
      
      <!-- Copy Resources -->
      <xsl:variable name="source-base-directory" select="string(file:getParent(file:new(base-uri())))"/>
      <xsl:variable name="destination-base-directory" select="string(fn:result-directory(.))"/>
      <xsl:for-each select="tokenize('styles scripts images', ' ')">
        <xsl:value-of select="fn:copy-directory(file:getAbsolutePath(file:new($source-base-directory, string(.))), file:getAbsolutePath(file:new($destination-base-directory)))"/>
      </xsl:for-each>
      
      <!-- Search -->
      <xsl:apply-templates select="/" mode="search"/>
    </xsl:if>
    
    <!-- Search Indexing -->
    <xsl:if test="$index-search">
      <xsl:result-document href="{concat($output-directory, 'scripts/search-index.js')}" method="text">
        <xsl:apply-templates select="." mode="search-index"/>
      </xsl:result-document>
      
      <xsl:result-document href="{concat($output-directory, 'scripts/search-index-advanced.js')}" method="text">
        <xsl:apply-templates select="." mode="search-index-advanced"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>
  
  <!-- ==================== -->
  <!-- Common Page Template -->
  <!-- ==================== -->
  
  <xsl:template match="*" mode="page">
    <xsl:param name="title" select="fn:iif(title, title, fn:iif(name, name, fn:iif(@name, @name, '')))"/>
    <xsl:param name="head"/>
    <xsl:param name="body"/>
    <xsl:param name="onload"/>
    <xsl:param name="exclude-search" select="false()"/>
    <!-- Add 'Send Feedback' button on every page (except xhtml pages). -->
    <xsl:param name="exclude-send-feedback" select="ancestor-or-self::xhtml-page"/>
    
    <xsl:variable name="active" select="."/>
    <xsl:variable name="site" select="ancestor-or-self::site"/>
    
    <html>
      <head>
        <xsl:copy-of select="$head"/>
        
        <title>
          <xsl:variable name="site-title" select="$site/title"/>
          
          <xsl:choose>
            <xsl:when test="$title != $site-title">
              <xsl:value-of select="$title"/>
              <xsl:text> | </xsl:text>
              <xsl:value-of select="$site-title"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$title"/>
            </xsl:otherwise>
          </xsl:choose>
        </title>
        
        <link rel="stylesheet" type="text/css" href="{fn:root-path(., 'styles/style.css')}"/>
        
        <!-- Include language stripes as inline styles. -->
        <xsl:for-each select="$languages/@name">
          <xsl:variable name="stripe" select="."/>
          <xsl:variable name="escaped-stripe" select="fn:escape-css-name($stripe)"/>
          
          <style class="language-stripe" id="language-stripe-{$escaped-stripe}" type="text/css">
            <xsl:for-each select="$languages/@name">
              <xsl:variable name="language" select="."/>
              <xsl:variable name="escaped-language" select="fn:escape-css-name($language)"/>
              
              <xsl:value-of select="concat('*.stripe-display.', $escaped-language, '{display:')"/>
              <xsl:value-of select="concat(fn:iif($language=$stripe, 'inline', 'none'),';}')"/>
              
              <xsl:value-of select="concat('*.stripe-active.', $escaped-language, '{background:')"/>
              <xsl:value-of select="concat(fn:iif($language=$stripe, 'rgba(0, 0, 0, 0.05)', 'transparent'),';}')"/>
            </xsl:for-each>
          </style>
        </xsl:for-each>
        
        <!-- NOTE: If we have a language set then write out a default style element that enables the selected
             stripe, and disables the other stripes, during the initial parse.  This keeps the code sets from
             flashing during load. -->
        <script type="text/javascript">
          <xsl:text>var languages = [</xsl:text>
          <xsl:for-each select="$languages/@name">
            <xsl:value-of select="concat(fn:iif(position() > 1, ',', ''), '&quot;', fn:escape-css-name(.), '&quot;')"/>
          </xsl:for-each>
          <xsl:text>];</xsl:text>

                    <xsl:text disable-output-escaping="yes">
                        <![CDATA[
                        var cookies = document.cookie.split(';');
                        for(var i=0; i<cookies.length; i++) {
                            var cookie = cookies[i].trim();

                            if (cookie.indexOf("language=")==0) {
                                var selectedLanguage = cookie.substring(9, cookie.length);
                                if (selectedLanguage.length > 0) {
                                    document.write("<style class='language-stripe' type='text/css'>");
                                    for (var j=0; j<languages.length; j++) {
                                        var language = languages[j];
                                        document.write("*.stripe-display." + language + "{display:" + (language == selectedLanguage ? "inline" : "none") + ";}");
                                        document.write("*.stripe-active." + language + "{background:" + (language == selectedLanguage ? "rgba(0, 0, 0, 0.05)" : "transparent") + ";}");
                                    }
                                    document.write("</style>");
                                }
                                break;
                            }
                        }
                        ]]>
                    </xsl:text>
        </script>
        
        <script type="text/javascript">
          <xsl:text>var rootPath = </xsl:text>
          <xsl:value-of select="concat('&quot;', fn:root-path(., ''), '&quot;;')"/>
        </script>
        
        <script src="{fn:root-path(., 'scripts/core.js')}"/>
        
        <xsl:if test="not($exclude-search)">
          <script src="{fn:root-path(., 'scripts/search-core.js')}"/>
          <script src="{fn:root-path(., 'scripts/search.js')}"/>
          <script src="{fn:root-path(., 'scripts/search-index.js')}"/>
        </xsl:if>
        
        <xsl:apply-templates select="/site/head/* | head/*"/>
      </head>
      <body onload="init();{$onload}">
        <!-- Needed to conditionally apply some style classes to accommodate secondary navs. -->
        <xsl:variable name="has-secondary-navs" select="(self::set | self::guide | self::class) | self::article/ancestor::*[self::guide or self::set] | self::lesson/ancestor::*[self::class or self::set] | (self::page | self::xhtml-page)/ancestor::set"/>
        
        <div>
          <xsl:attribute name="class">
            <xsl:text>body group</xsl:text>
            <xsl:if test="$has-secondary-navs">
              <xsl:text> with-secondary-navs</xsl:text>
            </xsl:if>
          </xsl:attribute>
          
          <div class="header group">
            <xsl:variable name="domains" select="$site/domains/*"/>
            
            <xsl:if test="$domains">
              <div class="domain-navs">
                <xsl:for-each select="$domains">
                  <div class="domain-nav">
                    <xsl:apply-templates select="*">
                      <xsl:with-param name="destination-node" select="$active"/>
                    </xsl:apply-templates>
                  </div>
                </xsl:for-each>
              </div>
            </xsl:if>
            
            <xsl:if test="not($exclude-search)">
              <div class="search">
                <div class="search-controls">
                  <!-- Search link displayed on smaller screens when the input is hidden. -->
                  <a href="{fn:root-path($active, 'search.html')}"/>
                  
                  <input type="text" onkeyup="search_onkeyup(this)" onchange="search_onchange(this)" onfocus="search_onfocus(this)" onblur="search_onblur(this)"/>
                </div>
                
                <!-- Search Results -->
                <div id="search-results" class="hidden group"/>
              </div>
            </xsl:if>
            
            <xsl:variable name="primary-navs" select="$site/site-map/*[not(self::landing-pages)]"/>
            <xsl:if test="$primary-navs">
              <div class="primary-navs">
                <xsl:for-each select="$primary-navs">
                  <div>
                    <xsl:attribute name="class">
                      <xsl:text>primary-nav</xsl:text>
                      <xsl:if test="descendant-or-self::*[fn:equals(self::*, $active)]">
                        <xsl:text> active</xsl:text>
                      </xsl:if>
                    </xsl:attribute>
                    
                    <xsl:choose>
                      <xsl:when test="self::external-ref">
                        <xsl:apply-templates select="."/>
                      </xsl:when>
                      <xsl:otherwise>
                        <a href="{fn:relative-result-path($active, .)}">
                          <xsl:value-of select="@title|title"/>
                        </a>
                      </xsl:otherwise>
                    </xsl:choose>
                  </div>
                </xsl:for-each>
              </div>
            </xsl:if>
          </div>
          
          <xsl:if test="$has-secondary-navs">
            <div class="secondary-navs">
              <xsl:variable name="current-set" select="ancestor-or-self::set[1]"/>
              <xsl:variable name="parent-nav-set" select="$current-set/ancestor::set[1]"/>
              <xsl:variable name="secondary-nav-sets" select="$current-set/items/*"/>
              
              <xsl:for-each select="$parent-nav-set">
                <a class="back" href="{fn:relative-result-path($active, .)}">
                  <xsl:value-of select="@title|title"/>
                </a>
              </xsl:for-each>
              
              <ul>
                <li class="current-set">
                  <span class="title">
                    <xsl:value-of select="$current-set/(@title|title)"/>
                  </span>
                  
                  <ul>
                    <li>
                      <a href="{fn:relative-result-path($active, $current-set)}">
                        <xsl:if test="fn:equals($active, $current-set)">
                          <xsl:attribute name="class">active</xsl:attribute>
                        </xsl:if>
                        
                        <xsl:text>Introduction</xsl:text>
                      </a>
                    </li>
                  </ul>
                </li>
                
                <xsl:for-each select="$secondary-nav-sets">
                  <li class="secondary-nav-set">
                    <span class="title">
                      <xsl:value-of select="@title|title"/>
                    </span>
                    
                    <ul>
                      <xsl:attribute name="class">
                        <xsl:if test="self::class">
                          <xsl:text>course-lessons-list</xsl:text>
                        </xsl:if>
                      </xsl:attribute>
                      
                      <li>
                        <xsl:attribute name="class">
                          <xsl:text>secondary-nav</xsl:text>
                          
                          <xsl:if test="fn:equals(., $active)">
                            <xsl:text> active</xsl:text>
                          </xsl:if>
                        </xsl:attribute>
                        
                        <a href="{fn:relative-result-path($active, .)}">
                          <xsl:attribute name="class">
                            <xsl:if test="fn:equals(., $active)">
                              <xsl:text>active</xsl:text>
                            </xsl:if>
                            
                            <xsl:if test="self::set">
                              <xsl:text> set</xsl:text>
                            </xsl:if>
                          </xsl:attribute>
                          
                          <xsl:text>Introduction</xsl:text>
                        </a>
                      </li>
                      
                      <xsl:variable name="secondary-navs" select="(items | articles | lessons)/*"/>
                      <xsl:if test="$secondary-navs">
                        <xsl:for-each select="$secondary-navs">
                          <li class="secondary-nav">
                            <a href="{fn:relative-result-path($active, .)}">
                              <xsl:attribute name="class">
                                <xsl:if test="fn:equals(., $active)">
                                  <xsl:text>active</xsl:text>
                                </xsl:if>
                                
                                <xsl:if test="self::set | self::guide | self::class">
                                  <xsl:text> set</xsl:text>
                                </xsl:if>
                              </xsl:attribute>
                              
                              
                              <xsl:value-of select="@title|title"/>
                            </a>
                          </li>
                        </xsl:for-each>
                      </xsl:if>
                    </ul>
                  </li>
                </xsl:for-each>
              </ul>
            </div>
          </xsl:if>
          
          <!-- TODO: Delete.  Alternative redering w/ guides/etc acting as sets. -->
          <!--<xsl:if test="$has-secondary-navs">
              <div class="secondary-navs">
                  <xsl:variable name="current-set" select="ancestor-or-self::*[self::set or self::guide][1]"/>
                  <xsl:variable name="parent-nav-set" select="$current-set/ancestor::*[self::set or self::guide][1]"/>
                  <xsl:variable name="secondary-nav-sets" select="$current-set/(items | articles)/*"/>

                  <xsl:for-each select="$parent-nav-set">
                      <a class="back" href="{fn:relative-result-path($active, .)}">
                          <xsl:value-of select="@title|title"/>
                      </a>
                  </xsl:for-each>

                  <ul>
                      <li class="current-set">
                          <span class="title">
                              <xsl:value-of select="$current-set/(@title|title)"/>
                          </span>

                          <ul>
                              <li>
                                  <a href="{fn:relative-result-path($active, $current-set)}">
                                      <xsl:if test="fn:equals($active, $current-set)">
                                          <xsl:attribute name="class">active</xsl:attribute>
                                      </xsl:if>

                                      <xsl:text>Introduction</xsl:text>
                                  </a>
                              </li>
                          </ul>
                      </li>

                      <xsl:choose>
                          <xsl:when test="self::set">
                              <xsl:for-each select="$secondary-nav-sets">
                                  <li class="secondary-nav-set">
                                      <span class="title">
                                          <xsl:value-of select="@title|title"/>
                                      </span>

                                      <ul>
                                          <li class="secondary-nav">
                                              <a href="{fn:relative-result-path($active, .)}">
                                                  <xsl:if test="fn:equals(., $active)">
                                                      <xsl:attribute name="class">active</xsl:attribute>
                                                  </xsl:if>

                                                  <xsl:text>Introduction</xsl:text>
                                              </a>
                                          </li>

                                          <xsl:variable name="secondary-navs" select="(items | articles)/*"/>
                                          <xsl:if test="$secondary-navs">
                                              <xsl:for-each select="$secondary-navs">
                                                  <li class="secondary-nav">
                                                      <a href="{fn:relative-result-path($active, .)}">
                                                          <xsl:if test="fn:equals(., $active)">
                                                              <xsl:attribute name="class">active</xsl:attribute>
                                                          </xsl:if>

                                                          <xsl:value-of select="@title|title"/>
                                                      </a>
                                                  </li>
                                              </xsl:for-each>
                                          </xsl:if>
                                      </ul>
                                  </li>
                              </xsl:for-each>
                          </xsl:when>
                          <xsl:otherwise>
                              <li class="secondary-nav-set">
                                  <xsl:for-each select="$secondary-nav-sets">
                                      <li class="secondary-nav">
                                          <a href="{fn:relative-result-path($active, .)}">
                                              <xsl:if test="fn:equals(., $active)">
                                                  <xsl:attribute name="class">active</xsl:attribute>
                                              </xsl:if>

                                              <xsl:value-of select="@title|title"/>
                                          </a>
                                      </li>
                                  </xsl:for-each>
                              </li>
                          </xsl:otherwise>
                      </xsl:choose>
                  </ul>
              </div>
          </xsl:if>-->
          
          <div>
            <xsl:attribute name="class">
              <xsl:text>content</xsl:text>
              <xsl:if test="$has-secondary-navs">
                <xsl:text> with-secondary-navs</xsl:text>
              </xsl:if>
            </xsl:attribute>
            
            <xsl:if test="not($exclude-send-feedback)">
              <!-- TODO: This is hardcoded for now.  Will probably want to move it to the site definition. -->
              <form class="send-feedback-form" action="https://docs.google.com/forms/d/1qGWLvLAPii0M27XEtirYDAjqcRx4bbdbVsHjUXAQ55s/viewform" method="get" target="_blank">
                <input name="entry.1497351318" type="hidden"/>
                <button class="submit" type="submit" onclick="this.previousSibling.value = location.href;">Send Feedback</button>
              </form>
            </xsl:if>
            
            <xsl:copy-of select="$body"/>
          </div>
          
          <div class="footer">
            <div class="copyright">
              <xsl:apply-templates select="$site/copyright/(text()|*)"/>
            </div>
            <div class="footer-navs">
              <div class="footer-nav">
                <xsl:apply-templates select="$site/terms-of-use/*"/>
              </div>
              <div class="footer-nav">
                <xsl:apply-templates select="$site/privacy-policy/*"/>
              </div>
              <div class="footer-nav">
                <a href="{fn:root-path($active, 'site-map.html')}">
                  <xsl:text>Site Map</xsl:text>
                </a>
              </div>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <!-- ======== -->
  <!-- Site Map -->
  <!-- ======== -->
  
  <xsl:template match="site" mode="site-map">
    <xsl:result-document href="{concat($output-directory, 'site-map.html')}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="exclude-send-feedback" select="true()"/>
        <xsl:with-param name="body">
          <div class="site-map">
            <ul class="level-1">
              <xsl:variable name="site" select="."/>
              
              <xsl:for-each select="site-map/(landing-pages/* | set | guide | class | page | xhtml-page)">
                <li>
                  <a class="title" href="{fn:relative-result-path($site, .)}">
                    <xsl:value-of select="title"/>
                  </a>
                  
                  <div class="description">
                    <xsl:value-of select="description"/>
                  </div>
                  
                  <xsl:if test="(items | articles | lessons)/*">
                    <ul class="level-2">
                      <xsl:apply-templates select="(items | articles | lessons)/*" mode="site-map-set">
                        <xsl:with-param name="site" select="$site"/>
                        <xsl:with-param name="level" select="2"/>
                      </xsl:apply-templates>
                    </ul>
                  </xsl:if>
                </li>
              </xsl:for-each>
            </ul>
          </div>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="*" mode="site-map-set">
    <xsl:param name="site"/>
    <xsl:param name="level"/>
    
    <li>
      <a class="title" href="{fn:relative-result-path($site, .)}">
        <xsl:value-of select="title"/>
      </a>
      
      <xsl:if test="$level = 2">
        <div class="description">
          <xsl:value-of select="description"/>
        </div>
      </xsl:if>
      
      <xsl:if test="(items | articles | lessons)/*">
        <ul class="level-{$level + 1}">
          <xsl:apply-templates select="(items | articles | lessons)/*" mode="site-map-set">
            <xsl:with-param name="site" select="$site"/>
            <xsl:with-param name="level" select="$level + 1"/>
          </xsl:apply-templates>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>
  
  <!-- ====== -->
  <!-- Search -->
  <!-- ====== -->
  
  <xsl:template match="/" mode="search">
    <xsl:result-document href="{concat($output-directory, 'search.html')}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="exclude-search" select="true()"/>
        <xsl:with-param name="exclude-send-feedback" select="true()"/>
        <xsl:with-param name="title">Search</xsl:with-param>
        <xsl:with-param name="onload">search_init();</xsl:with-param>
        <xsl:with-param name="head">
          <script src="{fn:root-path(., 'scripts/search-core.js')}"/>
          <script src="{fn:root-path(., 'scripts/search-advanced.js')}"/>
          <script src="{fn:root-path(., 'scripts/search-index.js')}"/>
          <script src="{fn:root-path(., 'scripts/search-index-advanced.js')}"/>
        </xsl:with-param>
        <xsl:with-param name="body">
          <input id="search-advanced" type="text" onkeyup="search_onkeyup(this)" onchange="search_onchange(this)"/>
          
          <div id="search-results-advanced"/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <!--<xsl:template match="/" mode="search">
      <xsl:result-document href="{concat($output-directory, 'search.html')}">
          <html>
              <head>
                  <title>
                      <xsl:value-of select="concat('Search | ', site/title)"/>
                  </title>

                  <link rel="stylesheet" type="text/css" href="{fn:root-path(., 'styles/style.css')}"/>

                  <script>
                      <xsl:text>var rootPath = </xsl:text>
                      <xsl:value-of select="concat('&quot;', fn:root-path(., ''), '&quot;;')"/>
                  </script>

                  <script src="{fn:root-path(., 'scripts/core.js')}"/>
                  <script src="{fn:root-path(., 'scripts/search-core.js')}"/>
                  <script src="{fn:root-path(., 'scripts/search-advanced.js')}"/>
                  <script src="{fn:root-path(., 'scripts/search-index.js')}"/>
                  <script src="{fn:root-path(., 'scripts/search-index-advanced.js')}"/>

                  <xsl:copy-of select="site/head/*" copy-namespaces="no"/>
              </head>
              <body onload="init(); search_init();">
                  <xsl:apply-templates select="." mode="page">
                      <xsl:with-param name="exclude-search" select="true()"/>
                  </xsl:apply-templates>

                  <div class="page-wrapper">
                      &lt;!&ndash; Search &ndash;&gt;
                      <input id="search" class="search advanced" type="text" onkeyup="search_onkeyup(this)" onchange="search_onchange(this)"/>

                      &lt;!&ndash; Search Results &ndash;&gt;
                      <div id="search-results" class="advanced"/>
                  </div>

                  <xsl:apply-templates select="descendant-or-self::site" mode="footer"/>
              </body>
          </html>
      </xsl:result-document>
  </xsl:template>-->
  
  <!-- ==== -->
  <!-- Sets -->
  <!-- ==== -->
  
  <xsl:template match="set">
    <xsl:apply-templates select="items/(set | guide | class | article | lesson | page | xhtml-page | api)"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <article class="set">
            <xsl:apply-templates select="." mode="breadcrumbs"/>
            
            <h1>
              <xsl:value-of select="title"/>
            </h1>
            
            <xsl:apply-templates select="." mode="toc"/>
            
            <xsl:apply-templates select="introduction/*"/>
            
            <xsl:if test="items/*">
              <h2>Items</h2>
              <dl>
                <xsl:variable name="set" select="."/>
                
                <xsl:for-each select="items/*">
                  <dt>
                    <a href="{fn:relative-result-path($set, .)}">
                      <xsl:value-of select="title"/>
                    </a>
                  </dt>
                  <dd>
                    <xsl:value-of select="description"/>
                  </dd>
                </xsl:for-each>
              </dl>
            </xsl:if>
          </article>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="set" mode="toc">
    <xsl:if test="items/* or dependencies/item or related/item">
      <div class="toc">
        <ul class="sections">
          <xsl:if test="items/*">
            <li class="section">
              <div class="title">In This Set</div>
              <ul class="items">
                <xsl:variable name="set" select="."/>
                
                <xsl:for-each select="items/*">
                  <li class="item">
                    <a href="{fn:relative-result-path($set, .)}">
                      <xsl:value-of select="title"/>
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
          
          <xsl:if test="dependencies/*">
            <li class="section">
              <div class="title">Dependencies &amp; Prerequisites</div>
              <ul class="items">
                <xsl:for-each select="dependencies/*">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
          
          <xsl:if test="related/*">
            <li class="section">
              <div class="title">See Also</div>
              <ul class="items">
                <xsl:for-each select="related/*">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- =========== -->
  <!-- Breadcrumbs -->
  <!-- =========== -->
  
  <xsl:template match="*" mode="breadcrumbs">
    <xsl:param name="active" select="."/>
    
    <xsl:if test="ancestor::*[self::set or self::guide]">
      <div class="breadcrumbs">
        <xsl:for-each select="ancestor::*[self::set or self::guide]">
          <div class="breadcrumb">
            <a href="{fn:relative-result-path($active, .)}">
              <xsl:value-of select="title"/>
            </a>
          </div>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- ======== -->
  <!-- Training -->
  <!-- ======== -->
  
  <xsl:template match="class[not(parent::classes/parent::package)]">
    <xsl:apply-templates select="lessons/lesson"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <xsl:apply-templates select="." mode="breadcrumbs"/>
          
          <h1>
            <xsl:value-of select="title"/>
          </h1>
          
          <xsl:apply-templates select="." mode="toc"/>
          
          <xsl:apply-templates select="introduction/*"/>
          
          <xsl:if test="lessons/lesson">
            <h2>Lessons</h2>
            <dl>
              <xsl:variable name="class" select="."/>
              
              <xsl:for-each select="lessons/lesson">
                <dt>
                  <a href="{fn:relative-result-path($class, .)}">
                    <xsl:value-of select="title"/>
                  </a>
                </dt>
                <dd>
                  <xsl:value-of select="description"/>
                </dd>
              </xsl:for-each>
            </dl>
          </xsl:if>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="class" mode="toc">
    <xsl:if test="lessons/* or dependencies/item or related/item">
      <div class="toc">
        <div class="class-nav">
          <a>
            <xsl:choose>
              <xsl:when test="lessons/lesson">
                <xsl:attribute name="href">
                  <xsl:value-of select="fn:relative-result-path(., lessons/lesson[1])"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class">disabled</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            
            <xsl:text>Get Started 〉</xsl:text>
          </a>
        </div>
        
        <ul class="sections">
          <xsl:if test="lessons/*">
            <li class="section">
              <div class="title">This Class Teaches You About</div>
              <ol class="items course-lessons-list">
                <xsl:variable name="set" select="."/>
                
                <xsl:for-each select="lessons/*">
                  <li class="item">
                    <a href="{fn:relative-result-path($set, .)}">
                      <xsl:value-of select="title"/>
                    </a>
                  </li>
                </xsl:for-each>
              </ol>
            </li>
          </xsl:if>
          
          <xsl:if test="dependencies/*">
            <li class="section">
              <div class="title">Dependencies &amp; Prerequisites</div>
              <ul class="items">
                <xsl:for-each select="dependencies/*">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
          
          <xsl:if test="related/*">
            <li class="section">
              <div class="title">See Also</div>
              <ul class="items">
                <xsl:for-each select="related/*">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="lesson">
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <xsl:apply-templates select="." mode="breadcrumbs"/>
          
          <h1>
            <xsl:value-of select="title"/>
          </h1>
          
          <xsl:apply-templates select="." mode="toc"/>
          
          <xsl:apply-templates select="introduction/*"/>
          
          <xsl:apply-templates select="tasks/task"/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="lesson" mode="toc">
    <div class="toc">
      <div class="lesson-nav group">
        <a>
          <xsl:choose>
            <xsl:when test="preceding-sibling::lesson">
              <xsl:attribute name="href">
                <xsl:value-of select="fn:relative-result-path(., preceding-sibling::lesson[1])"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:text>〈 Previous</xsl:text>
        </a>
        <a>
          <xsl:choose>
            <xsl:when test="following-sibling::lesson">
              <xsl:attribute name="href">
                <xsl:value-of select="fn:relative-result-path(., following-sibling::lesson[1])"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:text>Next 〉</xsl:text>
        </a>
      </div>
      
      <ul class="sections">
        <xsl:if test="descendant::task">
          <li class="section">
            <div class="title">This Lesson Teaches You To</div>
            <ol class="items">
              <xsl:variable name="set" select="."/>
              
              <xsl:for-each select="descendant::task">
                <li class="item">
                  <a href="#{@id}">
                    <xsl:value-of select="title"/>
                  </a>
                </li>
              </xsl:for-each>
            </ol>
          </li>
        </xsl:if>
        
        <xsl:if test="related/*">
          <li class="section">
            <div class="title">See Also</div>
            <ul class="items">
              <xsl:for-each select="related/*">
                <li class="item">
                  <xsl:apply-templates select="text()|*"/>
                </li>
              </xsl:for-each>
            </ul>
          </li>
        </xsl:if>
      </ul>
    </div>
  </xsl:template>
  
  <xsl:template match="task">
    <h2 id="{@id}">
      <xsl:value-of select="title"/>
    </h2>
    
    <xsl:apply-templates select="body/(*|text())"/>
  </xsl:template>
  
  <!-- ====== -->
  <!-- Guides -->
  <!-- ====== -->
  
  <xsl:template match="guide">
    <xsl:apply-templates select="articles/article"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <article class="guide">
            <xsl:apply-templates select="." mode="breadcrumbs"/>
            
            <h1>
              <xsl:value-of select="title"/>
            </h1>
            
            <xsl:apply-templates select="." mode="toc"/>
            
            <xsl:apply-templates select="introduction/*"/>
            
            <xsl:if test="articles/article">
              <h2>Articles</h2>
              <dl>
                <xsl:variable name="guide" select="."/>
                
                <xsl:for-each select="articles/article">
                  <dt>
                    <a href="{fn:relative-result-path($guide, .)}">
                      <xsl:value-of select="title"/>
                    </a>
                  </dt>
                  <dd>
                    <xsl:value-of select="description"/>
                  </dd>
                </xsl:for-each>
              </dl>
            </xsl:if>
          </article>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="guide" mode="toc">
    <xsl:if test="articles/article or dependencies/item or related/item">
      <div class="toc">
        <ul class="sections">
          <xsl:if test="articles/article">
            <li class="section">
              <div class="title">In This Guide</div>
              <ul class="items">
                <xsl:variable name="guide" select="."/>
                
                <xsl:for-each select="articles/article">
                  <li class="item">
                    <a href="{fn:relative-result-path($guide, .)}">
                      <xsl:value-of select="title"/>
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
          
          <xsl:if test="dependencies/*">
            <li class="section">
              <div class="title">Dependencies &amp; Prerequisites</div>
              <ul class="items">
                <xsl:for-each select="dependencies/*">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
          
          <xsl:if test="related/*">
            <li class="section">
              <div class="title">See Also</div>
              <ul class="items">
                <xsl:for-each select="related/*">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="article">
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <article class="article">
            <xsl:apply-templates select="." mode="breadcrumbs"/>
            
            <h1>
              <xsl:value-of select="title"/>
            </h1>
            
            <xsl:apply-templates select="." mode="toc"/>
            
            <xsl:apply-templates select="introduction/*"/>
            
            <xsl:apply-templates select="topics/topic"/>
          </article>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="article" mode="toc">
    <xsl:if test="descendant::topic or related/item">
      <div class="toc">
        <ul class="sections">
          <xsl:if test="topics/topic">
            <li class="section">
              <div class="title">In This Document</div>
              <ul class="items">
                <xsl:for-each select="topics/topic">
                  <li class="item">
                    <a href="#{@id}"><xsl:value-of select="title"/></a>
                    
                    <xsl:if test="body/section">
                      <ul class="sub-items">
                        <xsl:for-each select="body/section">
                          <li class="sub-item">
                            <a href="#{@id}"><xsl:value-of select="title"/></a>
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:if>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
          
          <xsl:if test="related/item">
            <li class="section">
              <div class="title">See Also</div>
              <ul class="items">
                <xsl:for-each select="related/item">
                  <li class="item">
                    <xsl:apply-templates select="text()|*"/>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:if>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="topic">
    <h2 id="{@id}">
      <xsl:value-of select="title"/>
    </h2>
    
    <xsl:apply-templates select="body/(text()|*)"/>
  </xsl:template>
  
  <!-- ==== -->
  <!-- Page -->
  <!-- ==== -->
  
  <xsl:template match="page">
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <article class="page">
            <h1>
              <xsl:value-of select="title"/>
            </h1>
            
            <xsl:apply-templates select="body/(text()|*)"/>
          </article>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="xhtml-page">
    <xsl:result-document href="{fn:result-path(.)}">
      <xsl:apply-templates select="." mode="page">
        <xsl:with-param name="body">
          <xsl:apply-templates select="body/(text()|*)"/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <!-- ====== -->
  <!-- Common -->
  <!-- ====== -->
  
  <xsl:template match="section">
    <h3 id="{@id}">
      <xsl:value-of select="title"/>
    </h3>
    
    <xsl:apply-templates select="body/*"/>
  </xsl:template>
  
  <xsl:template match="subsection">
    <h4 id="{@id}">
      <xsl:value-of select="title"/>
    </h4>
    
    <xsl:apply-templates select="body/*"/>
  </xsl:template>
  
  <xsl:template match="paragraph">
    <p>
      <xsl:apply-templates select="text()|*"/>
    </p>
  </xsl:template>
  
  <xsl:template match="image">
    <xsl:param name="source-node" select="."/>
    <xsl:param name="destination-node" select="."/>
    
    <!-- Copy the image from the source, to the destination. -->
    <xsl:variable name="source-file" select="file:new(string(fn:base-directory($source-node)), string(@href))"/>
    <xsl:variable name="destination-file" select="file:new(string(fn:result-directory($destination-node)), string(@href))"/>
    <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
    
    <img src="{@href}" alt="{@alt}" width="{@width}" height="{@height}" style="{@style}"/>
  </xsl:template>
  
  <xsl:template match="figure">
    <div>
      <xsl:attribute name="class">
        <xsl:text>figure</xsl:text>
        <xsl:choose>
          <xsl:when test="@importance='high'"> high</xsl:when>
          <xsl:when test="@importance='normal'"> normal</xsl:when>
          <xsl:otherwise> low</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:choose>
        <xsl:when test="@width">
          <xsl:attribute name="style">
            <xsl:text>width:</xsl:text>
            <xsl:value-of select="@width"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="descendant::*/@width">
          <xsl:attribute name="style">
            <xsl:text>width:</xsl:text>
            <xsl:value-of select="descendant::*/@width"/>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      
      <xsl:apply-templates select="*[not(self::description)]"/>
      
      <xsl:if test="description">
        <div class="caption">
          <xsl:variable name="base-uri" select="base-uri()"/>
          
          <span class="tag">Figure <xsl:value-of select="count(preceding::fig[description and base-uri()=$base-uri]) + 1"/>.</span>
          <xsl:apply-templates select="description[1]/(text()|*)"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
  
  <xsl:template match="code">
    <code>
      <xsl:apply-templates select="text()"/>
    </code>
  </xsl:template>
  
  <xsl:template match="code-block">
    <xsl:call-template name="code-block">
      <xsl:with-param name="code" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="code-block">
    <xsl:param name="code"/>
    
    <pre>
      <code>
        <!-- Get the number of leading spaces on the 1st line. -->
        <xsl:variable name="lines" select="tokenize(replace(string($code), '\t', '    '), '\n\r?')"/>
        <xsl:variable name="firstLine" select="fn:iif(string-length($lines[1]) > 0, $lines[1], $lines[2])"/>
        <xsl:variable name="indentSize" select="string-length(substring-before($firstLine, substring(normalize-space($firstLine), 1, 1))) + 1"/>
        
        <xsl:for-each select="$lines">
          <xsl:variable name="unindented-line" select="substring(., $indentSize)"/>
          
          <xsl:if test="string-length($unindented-line)">
            <xsl:value-of select="$unindented-line" />
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </code>
    </pre>
  </xsl:template>
  
  <xsl:template match="code-set">
    <xsl:variable name="code-set" select="."/>
    
    <div class="tab-bar">
      <xsl:for-each select="$languages">
        <xsl:variable name="language" select="."/>
        <xsl:variable name="language-name" select="$language/@name"/>
        <xsl:variable name="escaped-language-name" select="fn:escape-css-name($language-name)"/>
        
        <a href="javascript:setLanguage({fn:iif($escaped-language-name, concat('&quot;', $escaped-language-name, '&quot;'), 'null')})">
          <xsl:attribute name="class">
            <xsl:text>tab</xsl:text>
            <xsl:value-of select="fn:iif($escaped-language-name, concat(' stripe-active ', $escaped-language-name), '')"/>
            
            <xsl:if test="not(fn:get-code-block($code-set, $language))">
              <xsl:text> disabled</xsl:text>
            </xsl:if>
          </xsl:attribute>
          
          <xsl:value-of select="$language-name"/>
        </a>
      </xsl:for-each>
    </div>
    <xsl:for-each select="$languages">
      <xsl:variable name="language" select="."/>
      <xsl:variable name="language-name" select="$language/@name"/>
      <xsl:variable name="escaped-language-name" select="fn:escape-css-name($language-name)"/>
      <xsl:variable name="code-block" select="fn:get-code-block($code-set, $language)"/>
      
      <span class="stripe-display {$escaped-language-name}">
        <xsl:choose>
          <xsl:when test="$code-block">
            <xsl:apply-templates select="$code-block"/>
          </xsl:when>
          <xsl:otherwise>
            <pre>
              <code class="disabled">
                <xsl:text>No code example is currently available.</xsl:text>
              </code>
            </pre>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="fn:get-code-block">
    <xsl:param name="code-set"/>
    <xsl:param name="language"/>
    
    <!-- If there is a code-block for the current language then return that otherwise climb the super-language tree until we find a block. -->
    <xsl:choose>
      <xsl:when test="$code-set/code-block[lower-case(@language)=lower-case($language/@name)]">
        <xsl:copy-of select="$code-set/code-block[lower-case(@language)=lower-case($language/@name)]"/>
      </xsl:when>
      <xsl:when test="$language/@extends">
        <xsl:copy-of select="fn:get-code-block($code-set, $languages[@name = $language/@extends])"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
  <!-- Keys for ref lookups. -->
  <xsl:key name="target-uris" match="*" use="fn:get-uri(.)" />
  <xsl:key name="target-id-urls" match="*[@id]" use="url:new(url:new(string(fn:get-uri(.))), concat('#', @id))" />
  
  <xsl:template match="ref">
    <a>
      <xsl:if test="@href">
        <xsl:variable name="base-uri" select="fn:get-uri(.)"/>
        <xsl:variable name="target-url" select="url:new(url:new(string($base-uri)), @href)"/>
        
        <xsl:variable name="target" select="key('target-id-urls', string($target-url))"/>
        <xsl:variable name="href">
          <xsl:choose>
            <xsl:when test="$target">
              <xsl:value-of select="fn:relative-result-path(., $target)"/>
              
              <xsl:variable name="target-fragment" select="uri:getFragment(url:toURI($target-url))"/>
              <xsl:if test="$target-fragment">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$target-fragment"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="target" select="key('target-uris', string($target-url))"/>
              
              <xsl:if test="$target">
                <xsl:value-of select="fn:relative-result-path(., $target)"/>
                
                <xsl:variable name="target-fragment" select="uri:getFragment(url:toURI($target-url))"/>
                <xsl:if test="$target-fragment">
                  <xsl:text>#</xsl:text>
                  <xsl:value-of select="$target-fragment"/>
                </xsl:if>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
          <xsl:when test="string-length($href) > 0">
            <xsl:attribute name="href" select="$href"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>ERROR: Ref not found</xsl:text>
              <xsl:text>&#10;  Base Uri: </xsl:text>
              <xsl:value-of select="$base-uri"/>
              <xsl:text>&#10;  Target Uri: </xsl:text>
              <xsl:value-of select="$target-url"/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      
      <xsl:apply-templates select="text()|*"/>
    </a>
  </xsl:template>
  
  <xsl:template match="external-ref">
    <xsl:param name="source-node" select="."/>
    <xsl:param name="destination-node" select="."/>
    
    <a>
      <xsl:if test="@href">
        <xsl:attribute name="href" select="@href"/>
      </xsl:if>
      
      <xsl:apply-templates select="text()|*">
        <xsl:with-param name="source-node" select="$source-node"/>
        <xsl:with-param name="destination-node" select="$destination-node"/>
      </xsl:apply-templates>
    </a>
  </xsl:template>
  
  <xsl:template match="emphasis">
    <em>
      <xsl:apply-templates select="text()|*"/>
    </em>
  </xsl:template>
  
  <xsl:template match="strong">
    <strong>
      <xsl:apply-templates select="text()|*"/>
    </strong>
  </xsl:template>
  
  <xsl:template match="ordered-list">
    <ol>
      <xsl:apply-templates select="list-item"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="unordered-list">
    <ul>
      <xsl:apply-templates select="list-item"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="description-list">
    <dl>
      <xsl:apply-templates select="entry"/>
    </dl>
  </xsl:template>
  
  <xsl:template match="list-item">
    <li>
      <xsl:apply-templates select="text()|*"/>
    </li>
  </xsl:template>
  
  <xsl:template match="entry">
    <dt>
      <xsl:apply-templates select="title[1]/(text()|*)"/>
    </dt>
    <dd>
      <xsl:apply-templates select="description[1]/(text()|*)"/>
    </dd>
  </xsl:template>
  
  <xsl:template match="note">
    <div>
      <xsl:attribute name="class">
        <xsl:text>note</xsl:text>
        <xsl:choose>
          <xsl:when test="@type='tip'"> tip</xsl:when>
          <xsl:when test="@type='caution'"> caution</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      
      <span class="tag">
        <xsl:choose>
          <xsl:when test="@type='tip'">Tip:</xsl:when>
          <xsl:when test="@type='caution'">Caution:</xsl:when>
          <xsl:otherwise>Note:</xsl:otherwise>
        </xsl:choose>
      </span>
      
      <xsl:apply-templates select="text()|*"/>
    </div>
  </xsl:template>
  
  <xsl:template match="table[not(descendant::tr)]">
    <div class="table">
      <table>
        <xsl:for-each select="header">
          <thead>
            <xsl:for-each select="row">
              <tr>
                <xsl:for-each select="entry">
                  <th>
                    <xsl:if test="@colspan">
                      <xsl:attribute name="colspan" select="@colspan"/>
                    </xsl:if>
                    <xsl:if test="@rowspan">
                      <xsl:attribute name="rowspan" select="@rowspan"/>
                    </xsl:if>
                    
                    <xsl:apply-templates select="text()|*"/>
                  </th>
                </xsl:for-each>
              </tr>
            </xsl:for-each>
          </thead>
        </xsl:for-each>
        <xsl:for-each select="body">
          <tbody>
            <xsl:for-each select="row">
              <tr>
                <xsl:for-each select="entry">
                  <td>
                    <xsl:if test="@colspan">
                      <xsl:attribute name="colspan" select="@colspan"/>
                    </xsl:if>
                    <xsl:if test="@rowspan">
                      <xsl:attribute name="rowspan" select="@rowspan"/>
                    </xsl:if>
                    
                    <xsl:apply-templates select="text()|*"/>
                  </td>
                </xsl:for-each>
              </tr>
            </xsl:for-each>
          </tbody>
        </xsl:for-each>
      </table>
      
      <xsl:if test="description">
        <div class="caption">
          <xsl:variable name="base-uri" select="base-uri()"/>
          
          <span class="tag">Table <xsl:value-of select="count(preceding::table[description and base-uri()=$base-uri]) + 1"/>.</span>
          <xsl:apply-templates select="description[1]/(text()|*)"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
  
  <!-- ============================== -->
  <!-- Broad match for XHTML Elements -->
  <!-- ============================== -->
  
  <xsl:template match="*">
    <!-- Allow anything in an xhtml-page and a head element. -->
    <xsl:if test="ancestor::xhtml-page or ancestor::head">
      <xsl:if test="self::img">
        <!-- Copy the image from the source, to the destination. -->
        <xsl:variable name="source-file" select="file:new(string(fn:base-directory(.)), string(@src))"/>
        <xsl:variable name="destination-file" select="file:new(string(fn:result-directory(.)), string(@src))"/>
        <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
      </xsl:if>
      
      <xsl:if test="self::link">
        <!-- Copy the linked file from the source, to the destination. -->
        <xsl:variable name="source-file" select="file:new(string(fn:base-directory(.)), string(@href))"/>
        <xsl:variable name="destination-file" select="file:new(string(fn:result-directory(.)), string(@href))"/>
        <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
      </xsl:if>
      
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*"/>
        
        <xsl:apply-templates select="text()|*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>