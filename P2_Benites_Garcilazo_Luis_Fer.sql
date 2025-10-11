use adventureWorks2022;
select * from sales.SalesOrderDetail

create database AdventureWorksCP
use adventureWorks2022
-- Se crea una copia de la tabla datos covid en la nueva base de datos
SELECT * into copia_customer
from AdventureWorks2022.Production.product
SELECT * into copia_salesorderdetail
from AdventureWorks2022.sales.SalesOrderDetail
SELECT * into copia_salesorderheader
from AdventureWorks2022.sales.SalesOrderHeader

SELECT * from copia_salesorderheader
--Primera Consulta
with Top10Products as 
(select top 10 ProductID, SUM(OrderQty) as total
from copia_salesorderdetail
GROUP BY ProductID
ORDER BY SUM(OrderQty) DESC ) --LIMIT 10; Si estuviera en Mysql
SELECT soh.CustomerID, sod.ProductID
FROM copia_SalesOrderHeader AS soh
JOIN copia_salesorderdetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    where sod.ProductID in (select productID from Top10Products);
 ------------------------------------------------------------------------------------------------------------
--Segunda consulta
/*Listar los empleados sin salario registrado*/

SELECT * into copia_Employee
from AdventureWorks2022.HumanResources.Employee

SELECT BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion
INTO copia_person
FROM AdventureWorks2022.Person.Person;

--Consulta 2 
SELECT BusinessEntityID, JobTitle, Gender, HireDate
FROM copia_employee
WHERE SalariedFlag = 0;
/*
select BusinessEntityID, Jobtitle, SalarieFlag
from HumanResources.Employee JOIN person.person
--where SalariedFlag = 0 */

SELECT * from person.person
SELECT * from copia_Employee
------------------------------------------------------
--Generada con IA
SELECT 
    p.FirstName,
    p.LastName,
    e.JobTitle,
    e.Gender,
    e.HireDate
FROM copia_employee AS e
JOIN copia_person AS p
    ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.SalariedFlag = 0;
------------------------------------------------------

--Consulta 3

SELECT * into copia_product
from AdventureWorks2022.Production.Product

SELECT * into copia_salesorderdetail
from AdventureWorks2022.sales.SalesOrderDetail

SELECT * 
from copia_salesorderdetail

SELECT * 
from copia_product

--------------------------------------------------------------
/*Consulta 3*/
SELECT *
FROM copia_product
WHERE ProductID NOT IN (
    SELECT ProductID FROM copia_salesorderdetail
);

----------------------------------------------
/*IA*/
SELECT *
FROM copia_product
WHERE ProductID NOT IN (
    SELECT ProductID 
    FROM copia_salesorderdetail
    WHERE ProductID IS NOT NULL
);
---------------------------------------------------------------

/*Consulta 4*/

SELECT 
    p.Name AS ProductName,
    per.FirstName + ' ' + per.LastName AS CustomerName,
    sod.UnitPriceDiscount AS Discount,
    sod.UnitPrice,
    sod.OrderQty,
    (sod.OrderQty * sod.UnitPrice * (1 - sod.UnitPriceDiscount)) AS TotalSale
FROM copia_salesorderdetail AS sod
JOIN copia_product AS p 
    ON sod.ProductID = p.ProductID
JOIN copia_salesorderheader AS soh 
    ON sod.SalesOrderID = soh.SalesOrderID
JOIN copia_customer AS c 
    ON soh.CustomerID = c.CustomerID
JOIN copia_person AS per 
    ON c.PersonID = per.BusinessEntityID;


SELECT TOP 5 * FROM copia_product;
SELECT TOP 5 * FROM copia_salesorderdetail;
SELECT TOP 5 * FROM copia_customer;
EXEC sp_columns copia_customer;
SELECT TOP 5 * FROM copia_person;
