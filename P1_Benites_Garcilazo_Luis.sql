use CovidHistorico

--Consulta 1 Janeth 

 select anio, ENTIDAD_RES, total_sospechosos
FROM (
    SELECT 
        YEAR(FECHA_INGRESO) AS anio,
        ENTIDAD_RES,
        COUNT(*) AS total_sospechosos,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FECHA_INGRESO) 
                           ORDER BY COUNT(*) DESC) AS orden
    FROM datoscovid
    WHERE MONTH(FECHA_INGRESO) = 7
      AND CLASIFICACION_FINAL = 6 
    GROUP BY YEAR(FECHA_INGRESO), ENTIDAD_RES
) t
WHERE orden = 1
ORDER BY anio;

--Consulta 2 Janeth

SELECT name 
FROM sys.tables;

SELECT 
    ENTIDAD_RES,
    COUNT(*) AS total_casos
FROM (
    SELECT 
        ENTIDAD_RES,
        (CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END +
         CASE WHEN EPOC = 1 THEN 1 ELSE 0 END +
         CASE WHEN ASMA = 1 THEN 1 ELSE 0 END +
         CASE WHEN INMUSUPR = 1 THEN 1 ELSE 0 END +
         CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END +
         CASE WHEN OTRA_COM = 1 THEN 1 ELSE 0 END +
         CASE WHEN CARDIOVASCULAR = 1 THEN 1 ELSE 0 END +
         CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END +
         CASE WHEN RENAL_CRONICA = 1 THEN 1 ELSE 0 END +
         CASE WHEN TABAQUISMO = 1 THEN 1 ELSE 0 END
        ) AS total_comorbilidades
    FROM datoscovid  
    WHERE CLASIFICACION_FINAL IN (1,2,3)  -- casos confirmados
) t
WHERE total_comorbilidades >= 4
GROUP BY ENTIDAD_RES
ORDER BY total_casos DESC;

--Consulta 3 Janeth
CREATE VIEW vista_Casos2021 AS
SELECT 
    ENTIDAD_RES,
    COUNT(*) AS total_registrados,
    SUM(CASE WHEN CLASIFICACION_FINAL IN (1,2,3) THEN 1 ELSE 0 END) AS total_confirmados,
    SUM(CASE WHEN CLASIFICACION_FINAL IN (4,5,6) THEN 1 ELSE 0 END) AS total_sospechosos,
    SUM(CASE WHEN CLASIFICACION_FINAL = 7 THEN 1 ELSE 0 END) AS total_negativos,
    SUM(CASE WHEN FECHA_DEF <> '9999-99-99' THEN 1 ELSE 0 END) AS total_defunciones
FROM dbo.datoscovid
WHERE YEAR(FECHA_INGRESO) = 2021
GROUP BY ENTIDAD_RES;

--Consulta de vista
SELECT * FROM vista_Casos2021;

--Consulta 4 Luis

WITH Defunciones AS (
    SELECT 
        YEAR(FECHA_DEF) AS anio,
MONTH(FECHA_DEF) AS mes,
COUNT(*) AS total_defunciones,
SUM(CASE WHEN CLASIFICACION_FINAL IN (1,2,3) THEN 1 ELSE 0 END) AS confirmados
FROM dbo.datoscovid
WHERE NEUMONIA = 1
AND FECHA_DEF <> '9999-99-99'
GROUP BY YEAR(FECHA_DEF), MONTH(FECHA_DEF)
)
SELECT d.*
FROM Defunciones d
WHERE NOT EXISTS (
SELECT 1 
FROM Defunciones d2
WHERE d.anio = d2.anio
AND d2.total_defunciones > d.total_defunciones
)
ORDER BY anio, mes;



--Consulta 5 Luis
SELECT ENTIDAD_RES,
SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS casos_diabetes,
SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS casos_hipertension,
SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS casos_obesidad
FROM dbo.datoscovid
GROUP BY ENTIDAD_RES
HAVING SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) =
SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END)
AND SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) =
SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END);

-- Consulta 6 Luis 
--Primero vistas 
CREATE VIEW vista_TotalesMunicipio AS
SELECT 
ENTIDAD_RES,
MUNICIPIO_RES,
COUNT(*) AS total_municipio
FROM dbo.datoscovid
GROUP BY ENTIDAD_RES, MUNICIPIO_RES;

CREATE VIEW vista_TotalesEntidad AS
SELECT 
ENTIDAD_RES,
COUNT(*) AS total_entidad
FROM dbo.datoscovid
GROUP BY ENTIDAD_RES;

--Consulta 
SELECT TOP 1 
m.ENTIDAD_RES,
m.MUNICIPIO_RES,
m.total_municipio,
CAST(m.total_municipio * 100.0 / e.total_entidad AS DECIMAL(5,2)) AS porcentaje_estatal
FROM vista_TotalesMunicipio m
JOIN vista_TotalesEntidad e ON m.ENTIDAD_RES = e.ENTIDAD_RES
ORDER BY porcentaje_estatal ASC;

-- Por año Luis y Janeth
/* Sintaxis: 
DECLARE @sql NVARCHAR(MAX);
DECLARE @parametros NVARCHAR(100);
DECLARE @valor INT = 10;

SET @sql = N'SELECT * FROM MiTabla WHERE columna = @col';
SET @parametros = N'@col INT';

EXEC sp_executesql @sql, @parametros, @col = @valor;
*/

DECLARE @Año INT = 2021; -- En este caso se busco solamente cambiar el año

DECLARE @sql NVARCHAR(MAX);
SET @sql = N'
SELECT 
    ENTIDAD_RES,
    COUNT(*) AS total_registrados,
    SUM(CASE WHEN CLASIFICACION_FINAL IN (1,2,3) THEN 1 ELSE 0 END) AS total_confirmados,
    SUM(CASE WHEN CLASIFICACION_FINAL IN (4,5,6) THEN 1 ELSE 0 END) AS total_sospechosos,
    SUM(CASE WHEN CLASIFICACION_FINAL = 7 THEN 1 ELSE 0 END) AS total_negativos,
    SUM(CASE WHEN FECHA_DEF <> ''9999-99-99'' THEN 1 ELSE 0 END) AS total_defunciones
FROM dbo.datoscovid
WHERE YEAR(FECHA_INGRESO) = @Año
GROUP BY ENTIDAD_RES';
EXEC sp_executesql @sql, N'@Año INT', @Año;
