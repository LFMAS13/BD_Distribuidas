use CovidHistorico
GO
 
/* Se añade grupos de archivos en la base de datos para cada particion */
ALTER DATABASE covidHistorico ADD FILEGROUP FG_COVID_2020;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_COVID_2021;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_COVID_2022;
ALTER DATABASE covidHistorico ADD FILEGROUP FG_COVID_OTROS;
 
-- Crear archivos físicos asociados
-- crear un segmento por cada FILEGROUP (FG_COVID_2020, FG_COVID_2021, FG_COVID_2022,
-- FG_COVID_OTROS)
-- El archivo de partición primaria lleva la extension MDF
-- Los archivos de particiones adicionales lleva la extensión NDF
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_2020', -- Nombre del archivo
    -- ruta donde se almacena físicamente los archivos de la base de datos
	FILENAME = N'/var/opt/mssql/data/CovidHistorico.ndf', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_COVID_2020;

-- 2021
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_2021', -- Nombre del archivo
    -- ruta donde se almacena físicamente los archivos de la base de datos
	FILENAME = N'/var/opt/mssql/data/CovidHistorico2021.ndf', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_COVID_2021;

-- 2022
ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_2022', -- Nombre del archivo
    -- ruta donde se almacena físicamente los archivos de la base de datos
	FILENAME = N'/var/opt/mssql/data/CovidHistorico2022.ndf', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_COVID_2022;

-- FG_COVID_OTROS

ALTER DATABASE covidHistorico ADD FILE 
(
    NAME = N'COVID_OTROS', -- Nombre del archivo
    -- ruta donde se almacena físicamente los archivos de la base de datos
	FILENAME = N'/var/opt/mssql/data/CovidHistoricootros.ndf', 
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 50MB
) TO FILEGROUP FG_COVID_OTROS;


-- recupera la ruta a utilizar para crear cada archivo de partición
select name, physical_name
from sys.master_files
where database_id = DB_ID('covidHistorico')
 
 
-- Crear función de partición
-- Sin esta función no se logra el particionamiento
CREATE PARTITION FUNCTION pf_AniosCovid (DATE)
AS RANGE RIGHT FOR VALUES 
(
    '2020-12-31', -- partición para el año 2020
    '2021-12-31', -- partición para el año 2021
    '2022-12-31'  -- partición para el año 2022   
);
GO
 
-- Crear esquema de partición
CREATE PARTITION SCHEME ps_AniosCovid
AS PARTITION pf_AniosCovid
TO (
    FG_COVID_2020,
    FG_COVID_2021,
    FG_COVID_2022,
    FG_COVID_OTROS    
);
GO
 
-- se crea una tabla para el uso de FECHA_INGRESO de tipo DATE
CREATE TABLE [dbo].[datoscovid_part](      
    [ORIGEN] [int] NULL,
    [SECTOR] [int] NULL,      
    [SEXO] [int] NULL,      
    [TIPO_PACIENTE] [int] NULL,
    [FECHA_INGRESO] [date] NULL,  -- uso de DATE para la pf_AniosCovid    
    [INTUBADO] [int] NULL,
    [NEUMONIA] [int] NULL,
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
    [RESULTADO_LAB] [int] NULL,
    [TOMA_MUESTRA_ANTIGENO] [int] NULL,
    [RESULTADO_ANTIGENO] [int] NULL,
    [CLASIFICACION_FINAL] [int] NULL,
    [MIGRANTE] [int] NULL) ON ps_AniosCovid(FECHA_INGRESO)

GO
INSERT INTO [dbo].[datoscovid_part] (
    [ORIGEN],
    [SECTOR],
    [SEXO],
    [TIPO_PACIENTE],
    [FECHA_INGRESO],
    [INTUBADO],
    [NEUMONIA],
    [NACIONALIDAD],
    [EMBARAZO],
    [HABLA_LENGUA_INDIG],
    [INDIGENA],
    [DIABETES],
    [EPOC],
    [ASMA],
    [INMUSUPR],
    [HIPERTENSION],
    [OTRA_COM],
    [CARDIOVASCULAR],
    [OBESIDAD],
    [RENAL_CRONICA],
    [TABAQUISMO],
    [OTRO_CASO],
    [TOMA_MUESTRA_LAB],
    [RESULTADO_LAB],
    [TOMA_MUESTRA_ANTIGENO],
    [RESULTADO_ANTIGENO],
    [CLASIFICACION_FINAL],
    [MIGRANTE]
)
SELECT 
    [ORIGEN],
    [SECTOR],
    [SEXO],
    [TIPO_PACIENTE],
    [FECHA_INGRESO],
    [INTUBADO],
    [NEUMONIA],
    [NACIONALIDAD],
    [EMBARAZO],
    [HABLA_LENGUA_INDIG],
    [INDIGENA],
    [DIABETES],
    [EPOC],
    [ASMA],
    [INMUSUPR],
    [HIPERTENSION],
    [OTRA_COM],
    [CARDIOVASCULAR],
    [OBESIDAD],
    [RENAL_CRONICA],
    [TABAQUISMO],
    [OTRO_CASO],
    [TOMA_MUESTRA_LAB],
    [RESULTADO_LAB],
    [TOMA_MUESTRA_ANTIGENO],
    [RESULTADO_ANTIGENO],
    [CLASIFICACION_FINAL],
    [MIGRANTE]
FROM [dbo].[datoscovid];

SELECT 

SELECT *
FROM
    sys.master_files
    WHERE database_id = DB_ID ('covidhistorico')


SELECT name, physical_name
FROM
    sys.master_files
    WHERE database_id = DB_ID ('covidhistorico')


-- Ver las funciones de partición
SELECT * FROM sys.partition_functions;

-- Ver los esquemas de partición
SELECT * FROM sys.partition_schemes;


-- Ver particiones 
SELECT 
    $PARTITION.pf_AniosCovid(FECHA_INGRESO) AS particion,
    COUNT(*) AS totalfilas
FROM dbo.datoscovid_part
GROUP BY $PARTITION.pf_AniosCovid(FECHA_INGRESO)
ORDER BY particion;

SELECT *
from dbo.datoscovid_part
WHERE FECHA_INGRESO = '2022-02-20'




/*Generar particion por regiones 8 regiones

Select * from covidhistorico.dbo.cat_entidades
where entidad in ('Baja California', 'BAJA CALIFORNIA SUR', 'CHIHUAHUA','DURANGO','SINALOA')

-- Particion de lista (02,03,08,10,25)

--Funcion de particionamiento
--Funcion del esquema de particionamiento 

--Discutir la diferencia del particionamiento solamente con el groupfile PRIMARY 
--y con un groupfile para cada region
Es decir empezariamos desde el create particion funcion

CREATE PARTITION FUNCTION pf_AniosCovid (DATE)
AS RANGE RIGHT FOR VALUES 
(
    '2020-12-31', -- partición para el año 2020
    '2021-12-31', -- partición para el año 2021
    '2022-12-31'  -- partición para el año 2022   
);
GO
 
-- Crear esquema de partición
CREATE PARTITION SCHEME ps_AniosCovid
AS PARTITION pf_AniosCovid
TO (
    primary],[primary],[primary]    
);
GO
 
-- se crea una tabla para el uso de FECHA_INGRESO de tipo DATE
CREATE TABLE [dbo].[datoscovid_part](      
    [ORIGEN] [int] NULL,
    [SECTOR] [int] NULL,      
    [SEXO] [int] NULL,      
    [TIPO_PACIENTE] [int] NULL,
    [FECHA_INGRESO] [date] NULL,  -- uso de DATE para la pf_AniosCovid    
    [INTUBADO] [int] NULL,
    [NEUMONIA] [int] NULL,
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
    [RESULTADO_LAB] [int] NULL,
    [TOMA_MUESTRA_ANTIGENO] [int] NULL,
    [RESULTADO_ANTIGENO] [int] NULL,
    [CLASIFICACION_FINAL] [int] NULL,
    [MIGRANTE] [int] NULL) ON ps_AniosCovid(FECHA_INGRESO)

GO
*/
