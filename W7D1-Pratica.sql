SHOW DATABASES;          -- esploro DB disponibili
USE AdventureWorksDW;    -- seleziono DB che voglio interrogare
SHOW TABLES;             -- esploro tabelle del DB selezionato

-- Punto 1: Verifico che il campo ProductKey (nella tabella DimProduct) sia PK:
SHOW KEYS FROM dimproduct;          -- mi restituisce la tipologia delle CHIAVI
DESCRIBE dimproduct;			    -- ProductKey risulta INT come PK e non può essere NULL 
-- verifico con query (posso contare num. totale di chiavi, poi confronto con num. record effettivo tabella):
SELECT * FROM dimproduct;           -- 606 record totali -- numero effettivo record tabella dimproduct 
SELECT COUNT(ProductKey) AS ProductsNumber 
FROM dimproduct;		            -- 606 record = PK -- con COUNT, se c'è qualche NULL, non lo conta 
SELECT DISTINCT COUNT(ProductKey) AS ProductsNumber 
FROM dimproduct;				    -- 606 record = PK -- DISTINCT -> valori unici di chiave
-- verifico anche univocità:
SELECT ProductKey, COUNT(*) AS Univocita			
FROM dimproduct
GROUP BY ProductKey;                -- 606 record totali -- non esistono valori duplicati 
SELECT ProductKey, COUNT(*) AS Univocita			   -- ripeto con HAVING come controprova
FROM dimproduct
GROUP BY ProductKey
HAVING Univocita>1;  			    -- non resituisce risultato: dimostra che ogni valore è univoco

-- Punto 2: Verifico che la combinazione dei campi SalesOrderNumber e SalesOrderLineNumber sia una PK:
SELECT * FROM factresellersales;    -- oltre 50000 record totali -- con COUNT ho il numero effettivo  
SHOW KEYS FROM factresellersales;   -- mi restituisce la tipologia delle CHIAVI (chiave composita)
DESCRIBE factresellersales;	        -- risultano entrambe PK, quindi chiave composita 
-- verifico con COUNT -> se c'è qualche NULL, non lo conta (devono dare stesso risultato):
SELECT COUNT(SalesOrderNumber) AS SalesOrderNumber
FROM factresellersales;		        -- 57851 record (num. effettivo) = PK SalesOrderNumber
SELECT COUNT(SalesOrderLineNumber) AS SalesOrderLineNumber
FROM factresellersales;		        -- 57851 record (num. effettivo) = PK SalesOrderLineNumber 
-- verifico con DISTINCT -> valori unici di chiave (devono dare stesso risultato):
SELECT DISTINCT COUNT(SalesOrderNumber) AS SalesOrderNumber 
FROM factresellersales;			    -- 57851 record (num. effettivo) = PK SalesOrderNumber
SELECT DISTINCT COUNT(SalesOrderLineNumber) AS SalesOrderLineNumber 
FROM factresellersales;			    -- 57851 record (num. effettivo) = PK SalesOrderLineNumber

-- Query per verificare il nome_colonna in quante e quali tabelle del DB appare:
SELECT table_name, column_name
FROM information_schema.columns
WHERE column_name = 'SalesOrderLineNumber'
AND table_schema = 'AdventureWorksDW';

-- Punto 3: Conto numero transazioni (SalesOrderLineNumber) realizzate ogni giorno, a partire dal 2020-01-01:
SELECT * FROM factresellersales;    -- 57851 record effettivi 
-- filtro con WHERE:
SELECT F.OrderDate, COUNT(F.SalesOrderLineNumber) AS DailyTransaction
FROM factresellersales AS F
WHERE OrderDate>='2020-01-01'
GROUP BY OrderDate;                 -- 147 record = transazioni totali
-- filtro con HAVING:
SELECT F.OrderDate, COUNT(F.SalesOrderLineNumber) AS DailyTransaction
FROM factresellersales AS F
GROUP BY OrderDate
HAVING OrderDate>='2020-01-01';     -- 147 record = transazioni totali

-- Punto 4: Calcolo fatturato tot. (FactResellerSales.SalesAmount), quantità tot. venduta (FactResellerSales.OrderQuantity)
-- e prezzo medio di vendita (FactResellerSales.UnitPrice) per prodotto (DimProduct), a partire dal 2020-01-01.
-- Il result set deve esporre nome del prodotto, fatturato totale, quantità totale venduta e prezzo medio di vendita:
SELECT P.EnglishProductName AS ProductName, RS.OrderDate,
   SUM(RS.SalesAmount) AS TotalRevenue,
   SUM(RS.OrderQuantity) AS TotalQuantity,
   AVG(RS.UnitPrice) AS AveragePriceSales
FROM dimproduct AS P
JOIN factresellersales AS RS ON P.ProductKey = RS.ProductKey
WHERE RS.OrderDate>='2020-01-01'    -- metto prima il filtro con WHERE
GROUP BY ProductName;               -- poi raggruppo con GROUP BY -- 149 record
-- Funzione ROUND per arrotondamento del prezzo medio:
SELECT P.EnglishProductName AS ProductName, RS.OrderDate,
   SUM(RS.SalesAmount) AS TotalRevenue,
   SUM(RS.OrderQuantity) AS TotalQuantity,
   ROUND(AVG(RS.UnitPrice),2) AS AveragePriceSales   -- 2 indica i decimali, caratteri dopo la ,
FROM dimproduct AS P
JOIN factresellersales AS RS ON P.ProductKey = RS.ProductKey
WHERE RS.OrderDate>='2020-01-01'
GROUP BY ProductName;               -- stesso risultato -> 149 record

-- Punto 1.2: Calcolo fatturato tot. (FactResellerSales.SalesAmount) e quantità tot. venduta (FactResellerSales.OrderQuantity) 
-- per categoria prodotto (DimProductCategory).
-- Il result set deve esporre nome categoria prodotto, fatturato totale e quantità totale venduta:
SELECT C.EnglishProductCategoryName AS ProductCategoryName, 
   SUM(RS.SalesAmount) AS TotalRevenue,
   SUM(RS.OrderQuantity) AS TotalQuantity
FROM factresellersales AS RS
JOIN dimproduct AS P ON P.ProductKey= RS.ProductKey
JOIN dimproductsubcategory AS SC ON SC.ProductSubcategoryKey = P.ProductSubcategoryKey
JOIN dimproductcategory AS C ON C.ProductCategoryKey = SC.ProductCategoryKey
GROUP BY ProductCategoryName;       -- 4 record

-- Punto 2.2: Calcolo fatturato totale per area città (DimGeography.City) realizzato a partire dal 2020-01-01.
-- Il result set deve esporre lʼelenco delle città con fatturato realizzato superiore a 60K:
SELECT G.city AS City, RS.OrderDate, SUM(RS.SalesAmount) AS TotalRevenue
FROM factresellersales AS RS
JOIN dimreseller AS R ON R.ResellerKey = RS.ResellerKey
JOIN dimgeography AS G ON G.GeographyKey = R.GeographyKey
WHERE RS.OrderDate>='2020-01-01'
GROUP BY City
HAVING TotalRevenue>60000;          -- 65 record