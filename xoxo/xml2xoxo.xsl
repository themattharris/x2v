<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 version="1.0"
>

<xsl:template match="/">
	<ol class='xoxo'>
	<xsl:for-each select="node()">
  	  <li><xsl:value-of select="name()"/>
	  <dl>
	  <xsl:for-each select="@*">
	  	<dt><xsl:value-of select="name()"/></dt>
	  	<dd><xsl:value-of select="."/></dd>
	  </xsl:for-each>
  	  </dl>
		<xsl:if test="child::node() = true()">
			<ol>
			<xsl:for-each select="child::node()">
				<li><xsl:value-of select="name()"/>
				<dl>
				<xsl:for-each select="@*">
			  	<dt><xsl:value-of select="name()"/></dt>
			  	<dd><xsl:value-of select="."/></dd>
			    </xsl:for-each>				
		  		</dl>
			
				<xsl:for-each select="child::node()">
					<ol>
					<xsl:call-template name="getChild">
						<xsl:with-param name="child"><xsl:value-of select="."/></xsl:with-param>
					</xsl:call-template>
					</ol>
				</xsl:for-each>

				</li>
			</xsl:for-each>
			</ol>
		</xsl:if>
		</li>
	</xsl:for-each>
	</ol>
</xsl:template>

<!-- recursive call to get to root node -->
<xsl:template name="getChild">
	<li><xsl:value-of select="name()"/>
	  <dl>
	  <xsl:for-each select="@*">
	  	<dt><xsl:value-of select="name()"/></dt>
	  	<dd><xsl:value-of select="."/></dd>
	  </xsl:for-each>				
  	</dl>
	<xsl:for-each select=".">
		<xsl:choose>
			<xsl:when test="child::node() = true()">
				<xsl:for-each select="child::node()">
					<xsl:call-template name="getChild">
						<xsl:with-param name="child"><xsl:value-of select="."/></xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(normalize-space(.) = '')">
			  		<xsl:value-of select="."/>
		  		</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>	
	<!-- this needs to be moved -->
	</li>
</xsl:template>

</xsl:stylesheet>
