<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
	xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo   ="http://www.w3.org/1999/XSL/Format"
	xmlns:mf   ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	version="1.0"
>

<xsl:include href="../mf-templates.xsl"/>

<xsl:output 
	indent="yes" 
	omit-xml-declaration="yes" 
	method="xml"
/>

<xsl:param name="Source" />

<xsl:template match="/">

<fo:root>
    <fo:layout-master-set>
        <fo:simple-page-master master-name="LetterPage" page-width="8.5in" page-height="11in" >
            <fo:region-body region-name="PageBody" margin="0.2in 0.25in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

	<!-- loop through for hResume data -->
	<xsl:for-each select="//*[contains(concat(' ',normalize-space(@class),' '),' hresume ')]">
    	<fo:page-sequence master-reference="LetterPage">
        	<fo:flow flow-name="PageBody">
					<!-- Resume Owner Data -->
				  <xsl:for-each select="descendant::*[
					 (contains(concat(' ',normalize-space(@class),' '),' contact ') and
					  contains(concat(' ',normalize-space(@class),' '),' vcard '))
					][1]">
						<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">
							<fo:block font-size="36pt" border-bottom-style="solid" border-bottom-width="0.5mm" padding-bottom="0mm" margin-bottom="4mm"><xsl:call-template name="mf:extractText"/></fo:block>
						</xsl:for-each>

						<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
							<!-- need absolute URL -->
							<fo:block>
								<xsl:call-template name="mf:extractUrl">
									<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</xsl:for-each>
				  </xsl:for-each>

				<!-- Summary -->
				<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')][1]">
					<fo:block font-size="18pt" padding-top="2mm">Summary</fo:block>
					<fo:block><xsl:call-template name="mf:extractText"/></fo:block>
				</xsl:for-each>
				
				<!-- Education -->
				<fo:block font-size="18pt" padding-top="2mm">Education</fo:block>
				<xsl:for-each select="descendant::*[
					 (contains(concat(' ',normalize-space(@class),' '),' education ') and
					  contains(concat(' ',normalize-space(@class),' '),' vevent '))
					]">
					
					<!-- Summary -->
					<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')][1]">
						<fo:block><xsl:call-template name="mf:extractText"/></fo:block>
					</xsl:for-each>
					
					<!-- dtstart -->
					<fo:block>
					<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' dtstart ')][1]">
						<xsl:call-template name="mf:extractText"/>
					</xsl:for-each>
					
					<!-- dtend -->
					<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' dtend ')][1]">
						 - <xsl:call-template name="mf:extractText"/>
					</xsl:for-each>
					</fo:block>
				</xsl:for-each>
				
        	</fo:flow>
    	</fo:page-sequence>
	</xsl:for-each>
</fo:root>

</xsl:template>
</xsl:stylesheet>