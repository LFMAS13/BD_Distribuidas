--Consulta A

CREATE INDEX IX_copia_salesorderdetail_ProductID_OrderQty
ON copia_salesorderdetail (ProductID, OrderQty);

CREATE INDEX IX_copia_salesorderdetail_SalesOrderID
ON copia_salesorderdetail (SalesOrderID);

CREATE INDEX IX_copia_salesorderheader_SalesOrderID
ON copia_salesorderheader (SalesOrderID);

SELECT soh.CustomerID, sod.ProductID
FROM copia_SalesOrderHeader AS soh
JOIN copia_salesorderdetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN (
    SELECT TOP 10 ProductID
    FROM copia_salesorderdetail
    GROUP BY ProductID
    ORDER BY SUM(OrderQty) DESC
) AS Top10Products
    ON sod.ProductID = Top10Products.ProductID;


--Consulta D 
--Crear indices para acelerar la consulta

CREATE INDEX IX_salesorderdetail_ProductID ON copia_salesorderdetail(ProductID);
CREATE INDEX IX_salesorderdetail_SalesOrderID ON copia_salesorderdetail(SalesOrderID);
CREATE INDEX IX_salesorderheader_CustomerID ON copia_salesorderheader(CustomerID);
CREATE INDEX IX_customer_PersonID ON copia_customer(PersonID);


SELECT 
    p.Name AS ProductName,
    CONCAT(per.FirstName, ' ', per.LastName) AS CustomerName,
    sod.UnitPriceDiscount AS Discount,
    sod.UnitPrice,
    sod.OrderQty,
    (sod.OrderQty * sod.UnitPrice * (1 - sod.UnitPriceDiscount)) AS TotalSale
FROM copia_salesorderdetail AS sod
INNER JOIN copia_product AS p 
    ON sod.ProductID = p.ProductID
INNER JOIN copia_salesorderheader AS soh 
    ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN copia_customer AS c 
    ON soh.CustomerID = c.CustomerID
INNER JOIN copia_person AS per 
    ON c.PersonID = per.BusinessEntityID;
