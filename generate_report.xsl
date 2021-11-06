<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="qty"/>
    <xsl:output method="text" indent="no"/>

    <!-- NOTA: todos los elementos de texto "hardcodeados" fueron embebidos en el tag <text> para evitar indentación errática. -->
    <xsl:template match="/">
        <xsl:text>\documentclass[a4paper,10pt]{article}&#xA;</xsl:text>
        <xsl:text>\usepackage{longtable}&#xA;</xsl:text>
        <xsl:text>\usepackage{array}&#xA;</xsl:text> <!-- Paquete utilizado para calcular el ancho de las columnas del reporte -->
        <xsl:text>\usepackage{calc}&#xA;</xsl:text> <!-- Paquete utilizado para calcular el ancho de las columnas del reporte -->
        <xsl:text>\usepackage[margin=1in]{geometry}&#xA;</xsl:text> <!-- Paquete utilizado para hacer el márgen de la página más estrecho -->
        <xsl:text>\usepackage[dvipsnames]{xcolor}&#xA;</xsl:text> <!-- Paquete utilizado para obtener color en algunos textos -->
        <xsl:text>\usepackage[T1]{fontenc}&#xA;</xsl:text> <!-- Paquete utilizado para escapar correctamente el guión bajo -->
        <xsl:text>\begin{document}&#xA;</xsl:text>
        <xsl:text>\title{Flight Report}&#xA;</xsl:text>
        <xsl:text>\author{XML Group 03}&#xA;</xsl:text>
        <xsl:text>\date{\today}&#xA;</xsl:text>
        <xsl:text>\maketitle&#xA;</xsl:text>
        <xsl:text>\newpage&#xA;</xsl:text>
        <xsl:variable name="entries" select="//flight"/> <!-- Genero una variable con todos los vuelos, para poder controlar su cantidad -->
        <xsl:choose> <!-- Si hay uno o más vuelos, significa que no hubo errores => llamo al constructor de la tabla -->
            <xsl:when test="count($entries) &gt; 0">
                <xsl:call-template name="flights">
                    <xsl:with-param name="flights" select="$entries"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise> <!-- Si no hay vuelos, entonces hubo un error => llamo al constructor de errores -->
                <xsl:apply-templates select="//error"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\end{document}</xsl:text>
    </xsl:template>

    <!-- Template de errores. Recibe cada error y genera un párrafo para cada uno -->
    <xsl:template match="//error">
        <xsl:text>\begin{flushleft}&#xA;</xsl:text>
        <xsl:text>\color{red}&#xA;</xsl:text>
        <xsl:text>\textbf{An error occurred: }</xsl:text> <!-- Texto en negrita -->
        <xsl:text>\detokenize{</xsl:text><xsl:value-of select="."/><xsl:text>}</xsl:text> <!-- Se utiliza el tag \detokenize en conjunto con el paquete anterior para escapar _ -->
        <xsl:text>\end{flushleft}&#xA;</xsl:text>
    </xsl:template>

    <!-- Constructor de la tabla. Recibe TODOS los vuelos. -->
    <xsl:template name="flights">
        <xsl:param name="flights"/>
        <!-- La linea siguiente define la tabla y los anchos de las columnas -->
        <xsl:text>\begin{longtable}{|| m{.12\textwidth-2\tabcolsep} | m{.12\textwidth-2\tabcolsep} | m{.12\textwidth-2\tabcolsep} | m{.12\textwidth-2\tabcolsep} | m{.24\textwidth-2\tabcolsep} | m{.24\textwidth-2\tabcolsep}||}&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <!-- La linea siguiente define el encabezado -->
        <xsl:text>\textbf{Flight ID} &amp; \textbf{Country} &amp; \textbf{Position} &amp; \textbf{Status} &amp; \textbf{Departure Airport} &amp; \textbf{Arrival Airport} \\&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <xsl:text>\hline&#xA;</xsl:text>
        <!-- Para cada vuelo, me fijo si su posicion es menor o igual que $qty (cantidad de vuelos). Si es menor, hay que agregarlo => llamo al constructor de la fila. -->
        <!-- Si $qty es 0, entonces quiero que todos los vuelos estén en el reporte => siempre llamo al constructor -->
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

    <!-- Constructor de la fila. Recibe un vuelo y genera la fila de información -->
    <xsl:template name="entry">
        <xsl:param name="data"/>
        <xsl:value-of select="$data/@id"/>
        <xsl:text>&amp;</xsl:text> <!-- Separador de columnas -->
        <xsl:value-of select="$data/country"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>(</xsl:text><xsl:value-of select="$data/position/lat"/> , <xsl:value-of select="$data/position/lng"/><xsl:text>) &amp;</xsl:text>
        <xsl:choose> <!-- IF statement para definir el color del status => amarillo para 'scheduled' ; azul para 'landed' ; verde para 'en-route' ; negro en otro caso -->
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
