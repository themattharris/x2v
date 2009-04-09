<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns:geo ="http://www.w3.org/2003/01/geo/wgs84_pos#"
 xmlns:common="http://exslt.org/common"
 extension-element-prefixes="common"
 exclude-result-prefixes="mf"
 version="1.0"
>

<xsl:import href="../mf-templates.xsl" />

<xsl:output
  encoding="UTF-8"
  indent="yes"
  method="xml"
/>

<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-GeoRSS
Version 0.3
2007-06-29

Copyright 2006 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

-->


<xsl:param name="Source" />
<xsl:param name="Anchor" />

<xsl:template match="/">
	<rss version="2.0">
		<channel>
			<title><xsl:value-of select="//*[name() = 'title']" /></title>
			<link><xsl:text>http://suda.co.uk/projects/microformats/geo/get-geo.php?type=georss&amp;amp;url=</xsl:text><xsl:value-of select="$Source" /></link>
			<description/>
			<xsl:apply-templates select="//*[contains(concat(' ',normalize-space(@class),' '),' geo ')]"/>
		</channel>
	</rss>
</xsl:template>

<!-- Each GEO is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' geo ') and (not($Anchor) = true() or ancestor-or-self::*[@id = $Anchor])]">
	<item>
		<link><xsl:value-of select="$Source" /></link>
	
		<xsl:call-template name="mf:doIncludes"/>
		
		<xsl:call-template name="properties"/>
	</item>
</xsl:template>


<xsl:template name="properties">
	<xsl:variable name="latLon-RTF">
		<xsl:call-template name="mf:extractGeo"/>
	</xsl:variable>	
	<xsl:variable name="latLon" select="common:node-set($latLon-RTF)"/>
	<title>
	<xsl:choose>
		<!-- if this is an abbr element, use the value -->
		<xsl:when test="name() = 'abbr'">
			<xsl:value-of select="."/>
		</xsl:when>
		<!-- if this is inside an hCard, use the hCard FN -->
		<xsl:when test="ancestor::*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' vcard ')]//*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' fn ')]">
			<xsl:for-each select="ancestor::*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' vcard ')]//*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' fn ')][1]">
				<xsl:call-template name="mf:extractText" />
			</xsl:for-each>
		</xsl:when>
		<!-- if this is inside an hCalendar, use the hCalendar Summary -->
		<xsl:when test="ancestor::*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' vevent ')]//*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' summary ')]">
			<xsl:for-each select="ancestor::*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' vevent ')]//*[not(name() = 'del') = true() and contains(concat(' ', normalize-space(@class), ' '),' summary ')][1]">
				<xsl:call-template name="mf:extractText" />
			</xsl:for-each>
		</xsl:when>
		
		<!-- default: use the co-ordinates -->
		<xsl:otherwise>
			<!-- not perfect because of issues with a delimiter -->
			<xsl:value-of select="$latLon/longitude"/><xsl:text>,</xsl:text><xsl:value-of select="$latLon/latitude"/>
		</xsl:otherwise>
	</xsl:choose>
	</title>
	
	<geo:long><xsl:value-of select="$latLon/longitude"/></geo:long>
	<geo:lat><xsl:value-of select="$latLon/latitude"/></geo:lat>
</xsl:template>

<xsl:template match="comment()"></xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
