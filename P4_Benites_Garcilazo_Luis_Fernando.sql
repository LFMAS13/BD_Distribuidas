/*
	Particionamiento por Regiones Geogr·ficas
	Utiliza una Columna Calculada Persistida (Region_ID) para mapear
	la ENTIDAD_RES (Clave de Entidad) 

	Discusion de la diferencia de particionamiento solamente con el group file PRIMARY
	y con un group file para cada region, asÌ como la diferencia entre LEFT y RIGHT.

	Utilizando ˙nicamente el grupo de archivos PRIMARY, todas las particiones lÛgicas se 
	almacenan fÌsicamente en el mismo archivo de base de datos. En cambio, usando RANGE 
	LEFT o RANGE RIGHT cada particiÛn se almacena en un archivo distinto (.ndf) que puede 
	ubicarse incluso en diferentes discos. Esto permite distribuir el trabajo de lectura y escritura 
	de manera paralela, facilitando los respaldos y restauraciones por regiÛn, y ofrece un mayor 
	control para el mantenimiento o el archivado de datos histÛricos

	La diferencia entre RANGE LEFT y RANGE RIGHT es en como se define el valor lÌmite de la particiÛn. 
	En RANGE LEFT, el valor lÌmite se incluye dentro de la particiÛn izquierda, por 
	lo que los valores iguales al lÌmite quedan en esa particiÛn; mientras que en RANGE RIGHT, el 
	valor lÌmite pertenece a la particiÛn derecha. Para nuestro caso el adecuado es el valor de RANGE LEFT.

*/

USE [covidHistorico];
GO

-- DefiniciÛn de Grupos de Archivos (Filegroups)
ALTER DATABASE covidHistorico ADD FILEGROUP FG_NOROESTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_NORESTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_OCCIDENTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_ORIENTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_CENTRONORTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_CENTROSUR;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_SUROESTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_SURESTE;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_OTRAS_REGIONES;
GO

-- ParticiÛn 1: Noroeste. Baja California, Baja California Sur, Chihuahua, Durango, Sinaloa, Sonora
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_NOROESTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_NOROESTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_NOROESTE;

-- ParticiÛn 2: Noreste. Coahuila, Nuevo LeÛn, Tamaulipas
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_NORESTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_NORESTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_NORESTE;

-- ParticiÛn 3: Occidente. Colima, Jalisco, Michoac·n, Nayarit
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_OCCIDENTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_OCCIDENTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_OCCIDENTE;

-- ParticiÛn 4: Oriente. Hidalgo, Puebla, Tlaxcala, Veracruz
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_ORIENTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_ORIENTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_ORIENTE;

-- ParticiÛn 5: Centronorte. Aguascalientes, Guanajuato, QuerÈtaro, San Luis PotosÌ, Zacatecas
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_CENTRONORTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_CENTRONORTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_CENTRONORTE;

-- ParticiÛn 6: Centrosur. Ciudad de MÈxico, Estado de MÈxico, Morelos
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_CENTROSUR',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_CENTROSUR.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_CENTROSUR;

-- ParticiÛn 7: Suroeste. Chiapas, Guerrero, Oaxaca
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_SUROESTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_SUROESTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_SUROESTE;

-- ParticiÛn 8: Sureste. Campeche, Quintana Roo, Tabasco, Yucat·n
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_SURESTE',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_SURESTE.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_SURESTE;

-- ParticiÛn 9: Otros (36, 97, 98, 99 y cualquier otro)
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_OTRAS_REGIONES',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\COVID_OTRAS_REGIONES.NDF', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_OTRAS_REGIONES;

-- Crear funciÛn de particiÛn
CREATE PARTITION FUNCTION pf_RegionesCovid (INT)
AS RANGE LEFT FOR VALUES
(
    1, 
    2, 
    3,
    4,
    5,
    6,
    7,
    8 
);
GO

-- Crear esquema de particiÛn
CREATE PARTITION SCHEME ps_RegionesCovid
AS PARTITION pf_RegionesCovid
TO (
    FG_NOROESTE, 
    FG_NORESTE,  
    FG_OCCIDENTE,
    FG_ORIENTE,  
    FG_CENTRONORTE,     
    FG_CENTROSUR,       
    FG_SUROESTE,        
    FG_SURESTE,         
    FG_OTRAS_REGIONES   
);
GO

-- Crear la tabla particionada
CREATE TABLE [dbo].[datoscovid_region_part](
    [Region_ID] AS
    (
        CASE [ENTIDAD_RES]
            -- 1: Noroeste: Baja California (02), Baja California Sur (03), Chihuahua (08), Durango (10), Sinaloa (25), Sonora (26)
            WHEN 2 THEN 1 WHEN 3 THEN 1 WHEN 8 THEN 1 WHEN 10 THEN 1 WHEN 25 THEN 1 WHEN 26 THEN 1
            -- 2: Noreste: Coahuila (05), Nuevo LeÛn (19), Tamaulipas (28)
            WHEN 5 THEN 2 WHEN 19 THEN 2 WHEN 28 THEN 2
            -- 3: Occidente: Colima (06), Jalisco (14), Michoac·n (16), Nayarit (18)
            WHEN 6 THEN 3 WHEN 14 THEN 3 WHEN 16 THEN 3 WHEN 18 THEN 3
            -- 4: Oriente: Hidalgo (13), Puebla (21), Tlaxcala (29), Veracruz (30)
            WHEN 13 THEN 4 WHEN 21 THEN 4 WHEN 29 THEN 4 WHEN 30 THEN 4
            -- 5: Centronorte: Aguascalientes (01), Guanajuato (11), QuerÈtaro (22), San Luis PotosÌ (24), Zacatecas (32)
            WHEN 1 THEN 5 WHEN 11 THEN 5 WHEN 22 THEN 5 WHEN 24 THEN 5 WHEN 32 THEN 5
            -- 6: Centrosur: Ciudad de MÈxico (09), MÈxico (15), Morelos (17)
            WHEN 9 THEN 6 WHEN 15 THEN 6 WHEN 17 THEN 6
            -- 7: Suroeste: Chiapas (07), Guerrero (12), Oaxaca (20)
            WHEN 7 THEN 7 WHEN 12 THEN 7 WHEN 20 THEN 7
            -- 8: Sureste: Campeche (04), Quintana Roo (23), Tabasco (27), Yucat·n (31)
            WHEN 4 THEN 8 WHEN 23 THEN 8 WHEN 27 THEN 8 WHEN 31 THEN 8
            -- 9: Otros/No Aplica/Se Ignora (36, 97, 98, 99) o cualquier otro valor
            ELSE 9
        END
    ) PERSISTED, 
    [FECHA_ACTUALIZACION] [date] NULL,
    [ID_REGISTRO] [text] NULL,
    [ORIGEN] [int] NULL,
    [SECTOR] [int] NULL,
    [ENTIDAD_UM] [int] NULL,
    [SEXO] [int] NULL,
    [ENTIDAD_NAC] [int] NULL,
    [ENTIDAD_RES] [int] NULL, -- Columna fuente 
    [MUNICIPIO_RES] [int] NULL,
    [TIPO_PACIENTE] [int] NULL,
    [FECHA_INGRESO] [date] NULL,
    [FECHA_SINTOMAS] [date] NULL,
    [FECHA_DEF] [date] NULL,
    [INTUBADO] [int] NULL,
    [NEUMONIA] [int] NULL,
    [EDAD] [int] NULL,
    [NACIONALIDAD] [int] NULL,
    [EMBARAZO] [int] NULL,
    [HABLA_LENGUA_INDIG] [int] NULL,
    [INDIGENA] [int] NULL,
    [DIABETES] [int] NULL,
    [EPOC] [int] NULL,
    [ASMA] [int] NULL,
    [INMUSUPR] [int] NULL,
    [HIPERTENSION] [int] NULL,
    [OTRA_COM] [int] NULL,
    [CARDIOVASCULAR] [int] NULL,
    [OBESIDAD] [int] NULL,
    [RENAL_CRONICA] [int] NULL,
    [TABAQUISMO] [int] NULL,
    [OTRO_CASO] [int] NULL,
    [TOMA_MUESTRA_LAB] [int] NULL,
    [RESULTADO_PCR] [int] NULL,
    [RESULTADO_PCR_COINFECCION] [int] NULL,
    [TOMA_MUESTRA_ANTIGENO] [int] NULL,
    [RESULTADO_ANTIGENO] [int] NULL,
    [CLASIFICACION_FINAL_COVID] [int] NULL,
    [CLASIFICACION_FINAL_FLU] [int] NULL,
    [MIGRANTE] [int] NULL,
    [PAIS_NACIONALIDAD] [text] NULL,
    [PAIS_ORIGEN] [text] NULL,
    [UCI] [int] NULL
) ON ps_RegionesCovid([Region_ID]); 
GO

-- Insertar datos de la tabla original a la nueva tabla particionada
INSERT INTO [dbo].[datoscovid_region_part]
(
    [FECHA_ACTUALIZACION], [ID_REGISTRO], [ORIGEN], [SECTOR], [ENTIDAD_UM], [SEXO],
    [ENTIDAD_NAC], [ENTIDAD_RES], [MUNICIPIO_RES], [TIPO_PACIENTE],
    [FECHA_INGRESO], [FECHA_SINTOMAS], [FECHA_DEF],
    [INTUBADO], [NEUMONIA], [EDAD], [NACIONALIDAD], [EMBARAZO],
    [HABLA_LENGUA_INDIG], [INDIGENA], [DIABETES], [EPOC], [ASMA],
    [INMUSUPR], [HIPERTENSION], [OTRA_COM], [CARDIOVASCULAR], [OBESIDAD],
    [RENAL_CRONICA], [TABAQUISMO], [OTRO_CASO], [TOMA_MUESTRA_LAB],
    [RESULTADO_PCR], [RESULTADO_PCR_COINFECCION],
    [TOMA_MUESTRA_ANTIGENO], [RESULTADO_ANTIGENO],
    [CLASIFICACION_FINAL_COVID], [CLASIFICACION_FINAL_FLU],
    [MIGRANTE], [PAIS_NACIONALIDAD], [PAIS_ORIGEN], [UCI]
)
SELECT
    TRY_CONVERT(date, [FECHA_ACTUALIZACION], 23),
    [ID_REGISTRO],
    TRY_CONVERT(int, [ORIGEN]),
    TRY_CONVERT(int, [SECTOR]),
    TRY_CONVERT(int, [ENTIDAD_UM]),
    TRY_CONVERT(int, [SEXO]),
    TRY_CONVERT(int, [ENTIDAD_NAC]),
    TRY_CONVERT(int, [ENTIDAD_RES]),
    TRY_CONVERT(int, [MUNICIPIO_RES]),
    TRY_CONVERT(int, [TIPO_PACIENTE]),
    TRY_CONVERT(date, [FECHA_INGRESO], 23),
    TRY_CONVERT(date, [FECHA_SINTOMAS], 23),
    TRY_CONVERT(date, [FECHA_DEF], 23),
    TRY_CONVERT(int, [INTUBADO]),
    TRY_CONVERT(int, [NEUMONIA]),
    TRY_CONVERT(int, [EDAD]),
    TRY_CONVERT(int, [NACIONALIDAD]),
    TRY_CONVERT(int, [EMBARAZO]),
    TRY_CONVERT(int, [HABLA_LENGUA_INDIG]),
    TRY_CONVERT(int, [INDIGENA]),
    TRY_CONVERT(int, [DIABETES]),
    TRY_CONVERT(int, [EPOC]),
    TRY_CONVERT(int, [ASMA]),
    TRY_CONVERT(int, [INMUSUPR]),
    TRY_CONVERT(int, [HIPERTENSION]),
    TRY_CONVERT(int, [OTRA_COM]),
    TRY_CONVERT(int, [CARDIOVASCULAR]),
    TRY_CONVERT(int, [OBESIDAD]),
    TRY_CONVERT(int, [RENAL_CRONICA]),
    TRY_CONVERT(int, [TABAQUISMO]),
    TRY_CONVERT(int, [OTRO_CASO]),
    TRY_CONVERT(int, [TOMA_MUESTRA_LAB]),
    TRY_CONVERT(int, [RESULTADO_LAB]) AS [RESULTADO_PCR],
    NULL AS [RESULTADO_PCR_COINFECCION],
    TRY_CONVERT(int, [TOMA_MUESTRA_ANTIGENO]),
    TRY_CONVERT(int, [RESULTADO_ANTIGENO]),
    TRY_CONVERT(int, [CLASIFICACION_FINAL]) AS [CLASIFICACION_FINAL_COVID],
    NULL AS [CLASIFICACION_FINAL_FLU],
    TRY_CONVERT(int, [MIGRANTE]),
    [PAIS_NACIONALIDAD],
    [PAIS_ORIGEN],
    TRY_CONVERT(int, [UCI])
FROM [dbo].[datoscovid];
GO


select top 0 * from dbo.datoscovid