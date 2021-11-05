<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="qty"/>
    <xsl:output method="text" indent="no"/>

    <xsl:template match="/">
        <xsl:text>\documentclass[a4paper,10pt]{article}&#xA;</xsl:text>
        <xsl:text>\usepackage{longtable}&#xA;</xsl:text>
        <xsl:text>\usepackage{array}&#xA;</xsl:text>
        <xsl:text>\usepackage{calc}&#xA;</xsl:text>
        <xsl:text>\usepackage[margin=1in]{geometry}&#xA;</xsl:text>
        <xsl:text>\usepackage[dvipsnames]{xcolor}&#xA;</xsl:text>
        <xsl:text>\begin{document}&#xA;</xsl:text>
        <xsl:text>\title{Flight Report}&#xA;</xsl:text>
        <xsl:text>\author{XML Group 03}&#xA;</xsl:text>
        <xsl:text>\date{\today}&#xA;</xsl:text>
        <xsl:text>\maketitle&#xA;</xsl:text>
        <xsl:text>\newpage&#xA;</xsl:text>
        <xsl:apply-templates select="//error"/>
        <xsl:variable name="entries" select="//flight"/>
        <xsl:call-template name="flights">
            <xsl:with-param name="flights" select="$entries"/>
        </xsl:call-template>
        <xsl:text>\end{document}</xsl:text>
    </xsl:template>

    <xsl:template match="//error">
        <xsl:text>\begin{flushleft}&#xA;</xsl:text>
        <xsl:text>\color{red}&#xA;</xsl:text>
        <xsl:text>\textbf{An error occurred: }</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>\end{flushleft}&#xA;</xsl:text>
    </xsl:template>

    <xsl:template name="flights">
        <xsl:param name="flights"/>
        <xsl:text>\begin{longtable}{|| m{.12\textwidth-2\tabcolsep} | m{.12\textwidth-2\tabcolsep} | m{.12\textwidth-2\tabcolsep} | m{.12\textwidth-2\tabcolsep} | m{.24\textwidth-2\tabcolsep} | m{.24\textwidth-2\tabcolsep}||}&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:text>\textbf{Flight ID} &amp; \textbf{Country} &amp; \textbf{Position} &amp; \textbf{Status} &amp; \textbf{Departure Airport} &amp; \textbf{Arrival Airport} \\&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:for-each select="$flights">
            <xsl:if test="position() &lt;= $qty or $qty = 0">
                <xsl:call-template name="entry">
                    <xsl:with-param name="data" select="."/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:text>\end{longtable}&#xA;</xsl:text>
    </xsl:template>

    <xsl:template name="entry">
        <xsl:param name="data"/>
        <xsl:value-of select="$data/@id"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:value-of select="$data/country"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>(</xsl:text><xsl:value-of select="$data/position/lat"/> , <xsl:value-of select="$data/position/lng"/><xsl:text>) &amp;</xsl:text>
        <xsl:choose>
            <xsl:when test="$data/status = 'scheduled'">
                <xsl:text>\color{YellowOrange}{</xsl:text><xsl:value-of select="$data/status"/><xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="$data/status = 'landed'">
                <xsl:text>\color{blue}{</xsl:text><xsl:value-of select="$data/status"/><xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="$data/status = 'en-route'">
                <xsl:text>\color{ForestGreen}{</xsl:text><xsl:value-of select="$data/status"/><xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\color{black}{</xsl:text><xsl:value-of select="$data/status"/><xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&amp;</xsl:text>
        <xsl:value-of select="$data/departure_airport/name"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:value-of select="$data/arrival_airport/name"/>
        <xsl:text>\\&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
