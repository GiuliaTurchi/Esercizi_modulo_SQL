SHOW DATABASES;                 -- esploro DB disponibili
USE AdventureWorksDW;           -- seleziono DB che voglio interrogare
SHOW TABLES;                    -- esploro tabelle del DB selezionato

-- Punto 1: Espongo anagrafica prodotti, con rispettiva sottocategoria (DimProduct e DimProductSubcategory):
-- con LEFT JOIN (preservo tutti record della tabella di sinistra e gli associo record della tabella di destra 
-- per i quali esiste una corrispondenza, dove il predicato di JOIN è vero)
SELECT * FROM dimproduct;                 -- esploro tabella prodotti (DimProduct)
SELECT * FROM dimproductsubcategory;      -- esploro tabella sottocategoria prodotti (DimProductSubCategory)
SELECT P.ProductKey, P.EnglishProductName AS Product, SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
LEFT JOIN dimproductsubcategory AS SC                     -- così vedo anche i valori nulli della sottocategoria
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey;    -- 606 record
-- con INNER JOIN (combino record di due tabelle che includono valori corrispondenti in un campo comune -> chiave) 
-- restituisce lʼintersezione degli insiemi
SELECT P.ProductKey, P.EnglishProductName AS Product, SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
INNER JOIN dimproductsubcategory AS SC                    -- così scompaiono i valori nulli dalla sottocategoria
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey;    -- 397 record

-- Punto 2: Espongo anagrafica prodotti, con rispettiva categoria e sottocategoria 
-- (DimProduct, DimProductSubcategory e DimProductCategory):
-- con più INNER JOIN (trovo valori solo con corrispondenza -> non include valori nulli)
SELECT * FROM dimproductcategory;         -- esploro tabella categoria prodotti (DimProductCategory)
SELECT P.ProductKey, P.EnglishProductName AS Product, C.EnglishProductCategoryName AS ProductCategory, 
SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
JOIN dimproductsubcategory AS SC          -- la sintassi JOIN è equivalente a INNER JOIN
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
JOIN dimproductcategory AS C              -- la sintassi JOIN è equivalente a INNER JOIN
ON SC.ProductCategoryKey = C.ProductCategoryKey;          -- 397 record
-- con più LEFT JOIN (trovo anche i valori nulli della categoria e sottocategoria prodotti)
SELECT P.ProductKey, P.EnglishProductName AS Product, C.EnglishProductCategoryName AS ProductCategory, 
SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
LEFT JOIN dimproductsubcategory AS SC          
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
LEFT JOIN dimproductcategory AS C             
ON SC.ProductCategoryKey = C.ProductCategoryKey;          -- 606 record

-- Punto 3: Espongo elenco dei soli prodotti venduti (DimProduct e FactResellerSales):
-- con INNER JOIN, perché non voglio valori nulli
SELECT * FROM factresellersales;          -- esploro tabella vendite (FactResellerSales)
SELECT P.ProductKey, P.EnglishProductName AS Product, RS.SalesOrderNumber, RS.OrderQuantity, P.FinishedGoodsFlag
FROM dimproduct AS P 
INNER JOIN factresellersales AS RS        
ON P.ProductKey = RS.ProductKey          
WHERE RS.OrderQuantity >=1;                               -- oltre 50000 record
-- con RIGHT JOIN (preservo tutti i record della tabella di destra e gli associo i record della tabella sinistra 
-- per i quali esiste una corrispondenza, dove il predicato di JOIN è vero)
SELECT P.ProductKey, P.EnglishProductName AS Product, RS.SalesOrderNumber, RS.OrderQuantity, P.FinishedGoodsFlag
FROM dimproduct AS P 
RIGHT JOIN factresellersales AS RS       
ON P.ProductKey = RS.ProductKey          
WHERE RS.OrderQuantity >=1;                               -- oltre 50000 record
-- con una SUBQUERY -- anagrafica prodotti che hanno almeno una vendita
SELECT P.ProductKey, P.EnglishProductName AS Product, P.StandardCost, P.ListPrice, P.FinishedGoodsFlag
FROM dimproduct AS P
WHERE P.ProductKey IN (SELECT RS.ProductKey FROM factresellersales AS RS);  -- 334 record 

-- Punto 4: Espongo elenco prodotti non venduti (soli prodotti finiti, quelli per i quali FinishedGoodsFlag è = 1)
-- (DimProduct e FactResellerSales):
-- con una SUBQUERY
SELECT P.ProductKey, P.EnglishProductName AS Product, P.StandardCost, P.ListPrice, P.FinishedGoodsFlag
FROM dimproduct AS P 
WHERE P.FinishedGoodsFlag = 1 AND P.ProductKey NOT IN (
	  SELECT RS.ProductKey 
      FROM factresellersales AS RS
);                                                        -- 63 record
-- con LEFT JOIN
SELECT P.ProductKey, P.EnglishProductName AS Product, P.StandardCost, P.ListPrice, P.FinishedGoodsFlag
FROM dimproduct AS P 
LEFT JOIN factresellersales AS RS 
ON P.ProductKey = RS.ProductKey
WHERE RS.ProductKey IS NULL AND P.FinishedGoodsFlag = 1;  -- 63 record

-- Punto 5: Espongo elenco transazione di vendita, con nome prodotto venduto (DimProduct e FactResellerSales):
-- con INNER JOIN
SELECT RS.SalesOrderNumber, RS.OrderDate, RS.SalesAmount, P.EnglishProductName AS Product
FROM factresellersales AS RS 
JOIN dimproduct AS P
ON RS.ProductKey = P.ProductKey;                          -- oltre 50000 record

-- Extra: Recupero dati del prodotto venduto, come ultima transazione (DimProduct e FactResellerSales):
-- con INNER JOIN
SELECT P.ProductKey, P.EnglishProductName, P.ListPrice, RS.OrderDate 
FROM dimproduct AS P 
JOIN factresellersales AS RS
ON P.ProductKey = RS.ProductKey
WHERE OrderDate = (SELECT MAX(OrderDate) FROM factresellersales AS RS);     -- 94 record

-- Punto 1.2: Espongo elenco transazione di vendita, con categoria di appartenenza per ciascuno prodotto venduto:
-- con più INNER JOIN (combino FactResellerSales, DimProduct, DimProductSubCategory e DimProductCategory),
-- perchè mi serve categoria di appartenenza -> DimProductCategory entità estrema, non collegata con FactResellerSales
SELECT RS.SalesOrderNumber, RS.OrderDate, RS.SalesAmount, P.EnglishProductName AS Product, 
C.EnglishProductCategoryName AS Category
FROM factresellersales AS RS
INNER JOIN dimproduct AS P
ON RS.ProductKey = P.ProductKey
INNER JOIN dimproductsubcategory AS SC
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
INNER JOIN dimproductcategory AS C
ON SC.ProductCategoryKey = C.ProductCategoryKey;          -- oltre 50000 record

-- Punto 2.2: Esploro tabella DimReseller:
SELECT * FROM dimreseller;                                -- 701 record

-- Punto 3.2: Espongo elenco dei reseller, indicando per ciascuno anche la sua area geografica:
-- con INNER JOIN (combino DimReseller e DimGeography)
SELECT * FROM dimgeography; -- esploro tab. DimGeography  -- 655 record
SELECT R.ResellerName AS Reseller, G.City, G.StateProvinceName AS StateProvince, G.EnglishCountryRegionName AS CountryRegion
FROM dimreseller AS R
INNER JOIN dimgeography AS G 
ON R.GeographyKey = G.GeographyKey;                       -- 701 record

-- Punto 4.2: Espongo elenco transazioni di vendita, con determinati campi 
-- (SalesOrderNumber, SalesOrderLineNumber, OrderDate, UnitPrice, Quantity e TotalProductCost).
-- Deve indicare anche ProductName, CategoryName, ResellerName e GeographicalArea (City):
-- con INNER JOIN -> per esporre tutti i campi richiesti, combino tra loro queste tabelle, con questo ordine
-- DimGeography -> DimReseller -> FactResellerSales -> DimProduct -> DimProductSubCategory -> DimProductCategory
-- (come punto 1.2, si parte sempre da una tabella estrema, per arrivare all'altra estrema, tramite le chiavi)
SELECT RS.SalesOrderNumber, RS.SalesOrderLineNumber, RS.OrderDate, RS.UnitPrice, RS.OrderQuantity, RS.TotalProductCost,
P.EnglishProductName AS Product, C.EnglishProductCategoryName AS Category, R.ResellerName AS Reseller, G.City
FROM dimgeography AS G
INNER JOIN dimreseller AS R 
ON G.GeographyKey = R.GeographyKey
INNER JOIN factresellersales AS RS
ON R.ResellerKey = RS.ResellerKey 
JOIN dimproduct AS P 
ON RS.ProductKey = P.ProductKey
INNER JOIN dimproductsubcategory AS SC 
ON P.ProductSubCategoryKey = SC.ProductSubcategoryKey                        
INNER JOIN dimproductcategory AS C 
ON SC.ProductCategoryKey = C.ProductCategoryKey;          -- oltre 50000 record