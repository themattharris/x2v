<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns     ="http://simile.mit.edu/timeline/"
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

XHTML-2-Timeline
Version 0.1
2006-11-09

Copyright 2006 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

-->

<xsl:param name="Source" />
<xsl:param name="Anchor" />

<xsl:template match="/">
<data>
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' vevent ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' dtstart ')]]"/>
</data>
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vevent ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' dtstart ')]]">
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<xsl:call-template name="mf:doIncludes"/>
		<xsl:call-template name="properties"/>
	</xsl:if>
</xsl:template>

<xsl:template name="properties">
	
	
	<xsl:element name='event'>
		<!-- end date -->
		<xsl:variable name="dtend">
			<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' dtend ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:dateISO2RFC">
						<xsl:with-param name="iso-date"><xsl:call-template name="mf:extractDate" /></xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="$dtend != ''">
			<xsl:attribute name = "end">
				<xsl:value-of select="$dtend"/>
			</xsl:attribute>
		</xsl:if>
		<!-- start date -->
		<xsl:attribute name = "start">
			<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' dtstart ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:dateISO2RFC">
						<xsl:with-param name="iso-date"><xsl:call-template name="mf:extractDate" /></xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</xsl:attribute>

		<!-- title -->
		<xsl:attribute name = "title">
			<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' summary ')]">
				<xsl:if test="position() = 1">
					<xsl:call-template name="mf:extractText" />
				</xsl:if>
			</xsl:for-each>
		</xsl:attribute>

		<!-- node description -->
		<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' description ')]">
			<xsl:if test="position() = 1">
				<xsl:call-template name="mf:extractText" />
			</xsl:if>
		</xsl:for-each>
    </xsl:element>	
</xsl:template>

<xsl:template match="comment()"></xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
