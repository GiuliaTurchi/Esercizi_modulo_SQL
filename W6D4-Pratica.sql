SHOW DATABASES; -- trovo i DB che ho disponibili
USE AdventureWorksDW; -- selezione il DB che voglio interrogare
SHOW TABLES; -- esploro le tabelle del DB selezionato

SELECT * FROM dimproduct; -- esploro la tabella dimproduct
SELECT * FROM dimproductsubcategory; -- esploro la tabella dimproductsubcategory

-- Punto 1: Epongo anagrafica prodotti, con rispettiva sottocategoria 
-- uso LEFT JOIN, per preservare tutti i record della tabella di sinistra e associare a questi i record della tabella destra 
-- per i quali esiste una corrispondenza, dove il predicato di JOIN è vero
SELECT P.ProductKey, P.EnglishProductName AS Product, SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
LEFT JOIN dimproductsubcategory AS SC 
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey; -- vedo anche i valori nulli della sottocategoria

-- uso INNER JOIN, per combinare i record di due tabelle che includono valori corrispondenti in un campo in comune 
-- restituisce lʼintersezione degli insiemi 
SELECT P.ProductKey, P.EnglishProductName AS Product, SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
INNER JOIN dimproductsubcategory AS SC 
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey; -- scompaiono i valori nulli dalla sottocategoria

-- Punto 2: Espongo anagrafica prodotti, con rispettiva categoria e sottocategoria 
-- uso INNER JOIN, per trovare valori solo con corrispondenza, non include valori nulli
SELECT * FROM dimproductcategory; -- esploro la tabella dimproductcategory
SELECT P.ProductKey, P.EnglishProductName AS Product, C.EnglishProductCategoryName AS ProductCategory, 
SC.EnglishProductSubcategoryName AS ProductSubcategory
FROM dimproduct AS P 
JOIN dimproductsubcategory AS SC -- la sintassi JOIN è equivalente a INNER JOIN
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
JOIN dimproductcategory AS C -- la sintassi JOIN è equivalente a INNER JOIN
ON SC.ProductCategoryKey = C.ProductCategoryKey;

-- Punto 3: Espongo elenco soli prodotti venduti -- uso INNER JOIN, perché non vuole valori nulli
SELECT * FROM factresellersales; -- esploro la tabella factresellersales
SELECT P.ProductKey, P.EnglishProductName AS Product, RS.SalesOrderNumber, RS.OrderQuantity
FROM dimproduct AS P 
INNER JOIN factresellersales AS RS
ON P.ProductKey = RS.ProductKey
WHERE RS.OrderQuantity >=1; -- vedo tutti i prodotti, con più ordini di vendita (valori ripetuti)

-- uso RIGHT JOIN, per preservare tutti i record della tabella di destra e associare a questi i record della tabella sinistra 
-- per i quali esiste una corrispondenza, dove il predicato di JOIN è vero
SELECT P.ProductKey, P.EnglishProductName AS Product, RS.SalesOrderNumber, RS.OrderQuantity
FROM dimproduct AS P 
RIGHT JOIN factresellersales AS RS
ON P.ProductKey = RS.ProductKey
WHERE RS.OrderQuantity >=1; -- vedo tutti i prodotti, una sola volta, basta che hanno almeno un ordine di vendita

-- uso una SUBQUERY 
SELECT P.ProductKey, P.EnglishProductName AS Product, P.StandardCost, P.ListPrice, P.FinishedGoodsFlag
FROM dimproduct AS P
WHERE P.ProductKey IN (SELECT RS.ProductKey FROM factresellersales AS RS); 

-- Punto 4: Espongo elenco prodotti non venduti (soli prodotti finiti, quelli per i quali il campo FinishedGoodsFlag è = 1)
-- uso una SUBQUERY
SELECT P.ProductKey, P.EnglishProductName AS Product, P.StandardCost, P.ListPrice, P.FinishedGoodsFlag
FROM dimproduct AS P 
WHERE P.FinishedGoodsFlag = 1 AND P.ProductKey NOT IN (
	  SELECT RS.ProductKey 
      FROM factresellersales AS RS
      WHERE R.OrderQuantity > 0
);

-- uso LEFT JOIN
SELECT P.ProductKey, P.EnglishProductName AS Product, P.StandardCost, P.ListPrice, P.FinishedGoodsFlag
FROM dimproduct AS P 
LEFT JOIN factresellersales AS RS 
ON P.ProductKey = RS.ProductKey
WHERE RS.ProductKey IS NULL AND P.FinishedGoodsFlag = 1;

-- Punto 5: Espongo elenco transazione di vendita, con nome prodotto venduto
SELECT RS.SalesOrderNumber, RS.OrderDate, RS.SalesAmount, P.EnglishProductName AS Product
FROM factresellersales AS RS 
JOIN dimproduct AS P
ON RS.ProductKey = P.ProductKey;

-- Extra: Recupero i dati del prodotto venduto, come ultima transazione
SELECT P.ProductKey, P.EnglishProductName, P.ListPrice, RS.OrderDate 
FROM dimproduct AS P 
JOIN factresellersales AS RS
ON P.ProductKey = RS.ProductKey
WHERE OrderDate = (SELECT MAX(OrderDate) FROM factresellersales AS RS);

-- Punto 1: Espongo elenco transazione di vendita, con categoria di appartenenza per ciascuno prodotto venduto
SELECT RS.SalesOrderNumber, RS.OrderDate, RS.SalesAmount, P.EnglishProductName AS Product, 
C.EnglishProductCategoryName AS Category
FROM factresellersales AS RS
INNER JOIN dimproduct AS P
ON RS.ProductKey = P.ProductKey
INNER JOIN dimproductsubcategory AS SC
ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
INNER JOIN dimproductcategory AS C
ON SC.ProductCategoryKey = C.ProductCategoryKey;

-- Punto 2: Esploro tabella DimReseller
SELECT * FROM dimreseller; 

-- Punto 3: Espongo elenco dei reseller indicando, per ciascun reseller, anche la sua area geografica
SELECT * FROM dimgeography; -- esploro la tabella dimgeography
SELECT R.ResellerName AS Reseller, G.City, G.StateProvinceName AS StateProvince, G.EnglishCountryRegionName AS CountryRegion
FROM dimreseller AS R
INNER JOIN dimgeography AS G 
ON R.GeographyKey = G.GeographyKey;

-- Punto 4: Espongo elenco transazioni di vendita, con determinati campi
SELECT RS.SalesOrderNumber, RS.SalesOrderLineNumber, RS.OrderDate, RS.UnitPrice, RS.OrderQuantity, RS.TotalProductCost,
P.EnglishProductName AS Product, C.EnglishProductCategoryName AS Category, R.ResellerName AS Reseller, G.City
FROM factresellersales AS RS
INNER JOIN dimproduct AS P 
ON RS.ProductKey = P.ProductKey
INNER JOIN dimproductsubcategory AS SC 
ON P.ProductSubCategoryKey = SC.ProductSubcategoryKey
INNER JOIN dimproductcategory AS C 
ON SC.ProductCategoryKey = C.ProductCategoryKey
INNER JOIN dimgeography AS G 
ON RS.SalesTerritoryKey = G.SalesTerritoryKey
INNER JOIN dimreseller AS R 
ON G.GeographyKey = R.GeographyKey;
