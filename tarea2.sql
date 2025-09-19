--Consulta 1

SELECT ENTIDAD_RES, COUNT(*) AS total_confirmados
FROM datoscovid
WHERE YEAR(FECHA_INGRESO) = 2020
AND CLASIFICACION_FINAL IN (1, 2, 3)
GROUP BY ENTIDAD_RES
ORDER BY total_confirmados DESC;

--Consulta 2
SELECT TOP 5 ENTIDAD_RES, COUNT(*) AS total_defunciones
FROM datoscovid
WHERE FECHA_DEF != '9999-99-99'
AND YEAR(FECHA_INGRESO) = 2020
GROUP BY ENTIDAD_RES
ORDER BY total_defunciones ASC;


--Consulta 3
USE CovidHistorico;
go

SELECT ENTIDAD_RES, COUNT(*) AS total_comorbilidad
FROM datoscovid
WHERE YEAR(FECHA_INGRESO) = 2020 AND CLASIFICACION_FINAL IN (1, 2, 3)
AND ( DIABETES = 1 OR EPOC = 1 OR ASMA = 1 OR INMUSUPR = 1 OR HIPERTENSION = 1 OR OTRA_COM = 1 OR CARDIOVASCULAR = 1 OR
OBESIDAD = 1 OR RENAL_CRONICA = 1 OR TABAQUISMO = 1)
GROUP BY ENTIDAD_RES
HAVING COUNT(*) IN (
SELECT total
FROM ( SELECT COUNT(*) AS total
FROM datoscovid
WHERE YEAR(FECHA_INGRESO) = 2020
AND CLASIFICACION_FINAL IN (1, 2, 3)
AND ( DIABETES = 1 OR EPOC = 1 OR ASMA = 1 OR INMUSUPR = 1 OR HIPERTENSION = 1 OR OTRA_COM = 1 OR CARDIOVASCULAR = 1 OR
OBESIDAD = 1 OR RENAL_CRONICA = 1 OR TABAQUISMO = 1)
GROUP BY ENTIDAD_RES
HAVING COUNT(*) > 1) subcon)
ORDER BY total_comorbilidad;

/*Consulta 4 Listar por estado el total de casos confirmados fallecidos y el total de casos confirmados recuperados*/ 

create view casos_confirmados as 
select * 
from datoscovid
where CLASIFICACION_FINAL BETWEEN 1 and 3
GO

SELECT entidad_res, COUNT(case when FECHA_DEF != '9999-99-99' then 1 end) as t_f,
        COUNT(case when FECHA_DEF = '9999-99-99' then 1 end) as t_r,
        COUNT(*) tc
FROM casos_confirmados
GROUP BY ENTIDAD_RES

/*Para que aparezca con nombres */ 
SELECT entidad, COUNT(case when FECHA_DEF != '9999-99-99' then 1 end) as t_f,
        COUNT(case when FECHA_DEF = '9999-99-99' then 1 end) as t_r,
        COUNT(*) tc
FROM casos_confirmados cc join cat_entidades ce
on cc.ENTIDAD_RES = ce.clave
GROUP BY entidad


