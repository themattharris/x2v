<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
	xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo   ="http://www.w3.org/1999/XSL/Format"
	xmlns:mf   ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
 	xmlns:common="http://exslt.org/common"
	version="1.0"
>

<xsl:include href="../mf-templates.xsl"/>

<xsl:output 
	indent="yes" 
	omit-xml-declaration="yes" 
	method="xml"
/>

<xsl:param name="Source" />

<xsl:template name="properties">
</xsl:template>
		
<xsl:template match="/">

<fo:root>
    <fo:layout-master-set>
        <fo:simple-page-master master-name="BusinessCard" page-width="3.370in" page-height="2.125in" >
            <fo:region-body region-name="CardBody" margin="0.1in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

	<!-- loop through for hCard data -->
	<xsl:for-each select="//*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
    	<fo:page-sequence master-reference="BusinessCard">
        	<fo:flow flow-name="CardBody">
				<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]">
					<xsl:if test="position() = 1">
						<fo:block font-size="24pt"><xsl:call-template name="mf:extractText"/></fo:block>
					</xsl:if>
				</xsl:for-each>

			<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
					<fo:block font-size="8pt">
						<xsl:call-template name="mf:extractUrl">
							<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
						</xsl:call-template>
					</fo:block>
			</xsl:for-each>

			<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' email ')]">
				<fo:block font-size="10pt">
					<xsl:variable name="emailData-RTF">
						<xsl:call-template name="mf:extractUid">
							<xsl:with-param name="protocol">mailto</xsl:with-param>
							<xsl:with-param name="type-list">internet x400 pref</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="emailData" select="common:node-set($emailData-RTF)" />
					
					<xsl:value-of select="$emailData/value"/>
				</fo:block>
			</xsl:for-each>

			<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' adr ')]">
				<xsl:variable name="addressData-RTF">
					<xsl:call-template name="mf:extractAdr">
						<xsl:with-param name="type-list">dom intl postal parcel home work pref</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="addressData" select="common:node-set($addressData-RTF)" />
				
				
				<xsl:if test="not($addressData/post-office-box) = ''">
					<fo:block><xsl:value-of select="$addressData/post-office-box"/></fo:block>
				</xsl:if>
				<xsl:if test="not($addressData/extended-address) = ''">
			    	<fo:block><xsl:value-of select="$addressData/extended-address"/></fo:block>
				</xsl:if>
				<xsl:if test="not($addressData/street-address) = ''">
					<fo:block><xsl:value-of select="$addressData/street-address"/></fo:block>
				</xsl:if>
				<fo:block>
				<xsl:if test="not($addressData/locality) = ''">
			    	<xsl:value-of select="$addressData/locality"/>
				</xsl:if>
				<xsl:if test="not($addressData/region) = ''">
			    	<xsl:value-of select="$addressData/region"/>
				</xsl:if>
				<xsl:if test="not($addressData/postal-code) = ''">
			    	<xsl:value-of select="$addressData/postal-code"/>
				</xsl:if>
				</fo:block>
				<xsl:if test="not($addressData/country-name) = ''">
			    	<fo:block><xsl:value-of select="$addressData/country-name"/></fo:block>
				</xsl:if>
				
			</xsl:for-each>

			<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' tel ')]">
				<fo:block font-size="10pt">
					<xsl:variable name="telData-RTF">
						<xsl:call-template name="mf:extractUid">
							<xsl:with-param name="protocol">tel</xsl:with-param>
							<xsl:with-param name="type-list">home work pref voice fax msg cell pager bbs modem car isdn video pcs</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="telData" select="common:node-set($telData-RTF)" />
					
					<xsl:value-of select="$telData/value"/>
				</fo:block>
			</xsl:for-each>

    		</fo:flow>
    	</fo:page-sequence>
	</xsl:for-each>
</fo:root>

</xsl:template>

</xsl:stylesheet>