
/*PRÁCTICA 2 DE BASES DE DATOS DISTRIBUIDAS
	TEMA: Planes de ejecución y otmización  mediante indices
*/


/* 1.- Genere copia de cada tabla a utilizar en las consultas 
de tal forma que el análisis inicial se realice sin PK e indices.*/
use AdventureWorks2022

-- Copia de tabla Product
SELECT *
INTO copia_Product
FROM Production.Product;

-- Copia de tabla SalesOrderDetail
SELECT *
INTO copia_SalesOrderDetail
FROM Sales.SalesOrderDetail;

-- Copia de tabla SalesOrderHeader
SELECT *
INTO copia_SalesOrderHeader
FROM Sales.SalesOrderHeader;

-- Copia de tabla Person
SELECT *
INTO copia_Person
FROM Person.Person;

-- Copia de tabla Employee
SELECT *
INTO copia_Employee
FROM HumanResources.Employee;

-- Confirmacion de copia 
SELECT name 
FROM sys.tables 
WHERE name LIKE 'copia_%';

--Para revisar que no hay indices 
SELECT t.name AS TableName, i.name AS IndexName
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name LIKE 'copia_%';


/*Programar las siguientes consultas sobre la base de datos AdventureWors OLTP
----a. listar los clientes solicitan al menos dos productos del topo 10 de productos más solicitados
--b. listar los empleados sin salario refistrado.Los datos estan en el esquema HumanResources en las tablas de Employees y EmployeeSalary.
--c.Listar los productos que no han sido vendidos.
--d.Listar una relacion productos vendidos, nombre de los clientes que los comprqaron, descuentos aplicados, precio unitario, cantidad  solicitada y total de la venta por producto
*/

--a)
WITH Top10Productos AS (
    SELECT TOP 10 
        ProductID, 
        SUM(OrderQty) AS TotalVendido
    FROM copia_SalesOrderDetail
    GROUP BY ProductID
    ORDER BY SUM(OrderQty) DESC
),
VentasTop10 AS (
    SELECT 
        soh.CustomerID,
        sod.ProductID
    FROM copia_SalesOrderDetail AS sod
    INNER JOIN copia_SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
    WHERE sod.ProductID IN (SELECT ProductID FROM Top10Productos)
),
ClientesConMasDeDos AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT ProductID) AS ProductosTop10Comprados
    FROM VentasTop10
    GROUP BY CustomerID
    HAVING COUNT(DISTINCT ProductID) >= 2
)
SELECT 
    p.BusinessEntityID AS ClienteID,
    p.FirstName,
    p.LastName,
    c.ProductosTop10Comprados
FROM ClientesConMasDeDos AS c
INNER JOIN copia_SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
INNER JOIN copia_Person AS p
    ON soh.CustomerID = p.BusinessEntityID
GROUP BY 
    p.BusinessEntityID, p.FirstName, p.LastName, c.ProductosTop10Comprados
ORDER BY 
    c.ProductosTop10Comprados DESC;

-- b) Empleados sin salario registrado
SELECT 
    e.BusinessEntityID,
    e.JobTitle,
    e.Gender,
    e.HireDate
FROM HumanResources.Employee AS e
LEFT JOIN HumanResources.EmployeePayHistory AS ph
    ON e.BusinessEntityID = ph.BusinessEntityID
WHERE ph.BusinessEntityID IS NULL;
--
SELECT 
    BusinessEntityID,
    JobTitle,
    Gender,
    HireDate
FROM HumanResources.Employee
WHERE SalariedFlag = 0;
--
SELECT *
INTO copia_EmployeePayHistory
FROM HumanResources.EmployeePayHistory;
-- Crear tabla con empleados sin salario registrado o sin salario fijo
SELECT 
    e.BusinessEntityID,
    e.JobTitle,
    e.Gender,
    e.HireDate,
    e.SalariedFlag,
    CASE 
        WHEN ph.BusinessEntityID IS NULL THEN 'Sin registro de pago'
        WHEN e.SalariedFlag = 0 THEN 'No tiene salario fijo'
        ELSE 'Con salario'
    END AS SituacionSalarial
INTO copia_EmpleadosSinSalario
FROM copia_Employee AS e
LEFT JOIN copia_EmployeePayHistory AS ph
    ON e.BusinessEntityID = ph.BusinessEntityID
WHERE ph.BusinessEntityID IS NULL
   OR e.SalariedFlag = 0;
   -- Verificar resultados
SELECT * FROM copia_EmpleadosSinSalario;
-- C)Listar los productos que no han sido vendidos.
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.ProductNumber,
    p.ListPrice
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL
ORDER BY p.Name;
-- D)Listar una relacion productos vendidos, nombre de los clientes que los compraron, descuentos aplicados, precio unitario, cantidad  solicitada y total de la venta por producto
SELECT 
    p.ProductID,
    p.Name AS Producto,
    CONCAT(per.FirstName, ' ', per.LastName) AS Cliente,
    sod.UnitPrice AS PrecioUnitario,
    sod.OrderQty AS Cantidad,
    sod.UnitPriceDiscount AS Descuento,
    (sod.UnitPrice * sod.OrderQty) - (sod.UnitPrice * sod.OrderQty * sod.UnitPriceDiscount) AS TotalVenta
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
INNER JOIN Sales.Customer AS c
    ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person AS per
    ON c.PersonID = per.BusinessEntityID
ORDER BY Cliente, Producto;

 