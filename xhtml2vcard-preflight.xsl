<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform" 
 version="1.0"
>

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/x-vcard"
  method="text"
/>
<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-vCard Preflight
Version 0.1
2005-08-01

Copyright 2005 Brian Suda
This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/1.0/

NOTES:
This will check against some of the more common problems in hCard
-->

<xsl:param name="Anchor" />

<!-- there is no root element in vCard -->
<xsl:template match="/">
	<xsl:apply-templates select="//head[contains(concat(' ',normalize-space(@profile),' '),'foobar')]"/>
	<!-- @@ The following line will be removed because the vcard template should only be called from within the profile template -->
	<xsl:call-template name="vcard"/>
</xsl:template>

<!-- check for profile in head element -->
<xsl:template match="head[contains(concat(' ',normalize-space(@profile),' '),' http://foorbar ')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
<!-- <xsl:call-template name="vcard"/> -->
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template name="vcard">	
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<!-- Check for mandatory FN -->
		<xsl:if test="count(.//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]) = 0">
			<xsl:text>No FN property was found&lt;br/&gt;</xsl:text>
		</xsl:if>
		

		<!-- Check for Capitals in given-name -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Given-Name ')]">
			<xsl:text>&lt;code&gt;Given-Name&lt;/code&gt; property should be represented as &lt;code&gt;given-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Given-name ')]">
			<xsl:text>&lt;code&gt;Given-name&lt;/code&gt; property should be represented as &lt;code&gt;given-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
		<!-- Check for Capitals in family-name -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Family-Name ')]">
			<xsl:text>&lt;code&gt;Family-Name&lt;/code&gt; property should be represented as &lt;code&gt;family-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Family-name ')]">
			<xsl:text>&lt;code&gt;Family-name&lt;/code&gt; property should be represented as &lt;code&gt;family-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>

		<!-- Check for Capitals in additional-names -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Additional-Names ')]">
			<xsl:text>&lt;code&gt;Additional-Names&lt;/code&gt; property should be represented as &lt;code&gt;additional-names&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Additional-names ')]">
			<xsl:text>&lt;code&gt;Additional-names&lt;/code&gt; property should be represented as &lt;code&gt;additional-names&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Additional-Name ')]">
			<xsl:text>&lt;code&gt;Additional-Name&lt;/code&gt; property should be represented as &lt;code&gt;additional-names&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Additional-name ')]">
			<xsl:text>&lt;code&gt;Additional-name&lt;/code&gt; property should be represented as &lt;code&gt;additional-names&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
		<!-- Check for Capitals in honorific-prefixes -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-Prefixes ')]">
			<xsl:text>&lt;code&gt;Honorific-Prefixes&lt;/code&gt; property should be represented as &lt;code&gt;honorific-prefixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-prefixes ')]">
			<xsl:text>&lt;code&gt;Honorific-prefixes&lt;/code&gt; property should be represented as &lt;code&gt;honorific-prefixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-Prefix ')]">
			<xsl:text>&lt;code&gt;Honorific-Prefix&lt;/code&gt; property should be represented as &lt;code&gt;honorific-prefixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-prefix ')]">
			<xsl:text>&lt;code&gt;Honorific-prefix&lt;/code&gt; property should be represented as &lt;code&gt;honorific-prefixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>

		<!-- Check for Capitals in honorific-suffixes -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-Suffixes ')]">
			<xsl:text>&lt;code&gt;Honorific-Suffixes&lt;/code&gt; property should be represented as &lt;code&gt;honorific-suffixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-suffixes ')]">
			<xsl:text>&lt;code&gt;Honorific-suffixes&lt;/code&gt; property should be represented as &lt;code&gt;honorific-suffixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-Suffix ')]">
			<xsl:text>&lt;code&gt;Honorific-Suffix&lt;/code&gt; property should be represented as &lt;code&gt;honorific-suffixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Honorific-suffix ')]">
			<xsl:text>&lt;code&gt;Honorific-suffix&lt;/code&gt; property should be represented as &lt;code&gt;honorific-suffixes&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
		<!-- Check for Capitals in post-office-box -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Post-Office-Box ')]">
			<xsl:text>&lt;code&gt;Post-Office-Box&lt;/code&gt; property should be represented as &lt;code&gt;post-office-box&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Post-office-box ')]">
			<xsl:text>&lt;code&gt;Post-office-box&lt;/code&gt; property should be represented as &lt;code&gt;post-office-box&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>

		<!-- Check for Capitals in extended-address -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Extended-Address ')]">
			<xsl:text>&lt;code&gt;Extended-Address&lt;/code&gt; property should be represented as &lt;code&gt;extended-address&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Extended-address ')]">
			<xsl:text>&lt;code&gt;Extended-address&lt;/code&gt; property should be represented as &lt;code&gt;extended-address&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>

		<!-- Check for Capitals in street-address -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Street-Address ')]">
			<xsl:text>&lt;code&gt;Street-Address&lt;/code&gt; property should be represented as &lt;code&gt;street-address&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Street-address ')]">
			<xsl:text>&lt;code&gt;Street-address&lt;/code&gt; property should be represented as &lt;code&gt;street-address&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Address ')]">
			<xsl:text>&lt;code&gt;Address&lt;/code&gt; property should be represented as &lt;code&gt;street-address&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' address ')]">
			<xsl:text>&lt;code&gt;address&lt;/code&gt; property should be represented as &lt;code&gt;street-address&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>

		<!-- Check for Capitals in locality -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Locality ')]">
			<xsl:text>&lt;code&gt;Locality&lt;/code&gt; property should be represented as &lt;code&gt;locality&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' LOCALITY ')]">
			<xsl:text>&lt;code&gt;LOCALITY&lt;/code&gt; property should be represented as &lt;code&gt;locality&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' City ')]">
			<xsl:text>&lt;code&gt;City&lt;/code&gt; property should be represented as &lt;code&gt;locality&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' city ')]">
			<xsl:text>&lt;code&gt;city&lt;/code&gt; property should be represented as &lt;code&gt;locality&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>

		<!-- Check for Capitals in region -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Region ')]">
			<xsl:text>&lt;code&gt;Region&lt;/code&gt; property should be represented as &lt;code&gt;region&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' REGION ')]">
			<xsl:text>&lt;code&gt;REGION&lt;/code&gt; property should be represented as &lt;code&gt;region&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' State ')]">
			<xsl:text>&lt;code&gt;State&lt;/code&gt; property should be represented as &lt;code&gt;region&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' state ')]">
			<xsl:text>&lt;code&gt;state&lt;/code&gt; property should be represented as &lt;code&gt;region&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
		<!-- Check for Capitals in postal-code -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Postal-Code ')]">
			<xsl:text>&lt;code&gt;Postal-Code&lt;/code&gt; property should be represented as &lt;code&gt;postal-code&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Postal-code ')]">
			<xsl:text>&lt;code&gt;Postal-code&lt;/code&gt; property should be represented as &lt;code&gt;postal-code&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Zip-Code ')]">
			<xsl:text>&lt;code&gt;Zip-Code&lt;/code&gt; property should be represented as &lt;code&gt;postal-code&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Zip-code ')]">
			<xsl:text>&lt;code&gt;Zip-code&lt;/code&gt; property should be represented as &lt;code&gt;postal-code&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
		<!-- correct problems with Country-Name -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' country ')]">
			<xsl:text>&lt;code&gt;country&lt;/code&gt; property should be represented as &lt;code&gt;country-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Country ')]">
			<xsl:text>&lt;code&gt;Country&lt;/code&gt; property should be represented as &lt;code&gt;country-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Country-name ')]">
			<xsl:text>&lt;code&gt;Country-name&lt;/code&gt; property should be represented as &lt;code&gt;country-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Country-Name ')]">
			<xsl:text>&lt;code&gt;Country-Name&lt;/code&gt; property should be represented as &lt;code&gt;country-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>


		<!-- Check for Capitals in organization-name -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Organization-Name ')]">
			<xsl:text>&lt;code&gt;Organization-Name&lt;/code&gt; property should be represented as &lt;code&gt;organization-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Organization-name ')]">
			<xsl:text>&lt;code&gt;Organization-name&lt;/code&gt; property should be represented as &lt;code&gt;organization-name&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
		<!-- Check for Capitals in organization-unit -->
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Organization-Unit ')]">
			<xsl:text>&lt;code&gt;Organization-Unit&lt;/code&gt; property should be represented as &lt;code&gt;organization-unit&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		<xsl:if test=".//*[contains(concat(' ',normalize-space(@class),' '),' Organization-unit ')]">
			<xsl:text>&lt;code&gt;Organization-unit&lt;/code&gt; property should be represented as &lt;code&gt;organization-unit&lt;/code&gt;&lt;br/&gt;</xsl:text>
		</xsl:if>
		
	</xsl:if>
</xsl:template>


<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
