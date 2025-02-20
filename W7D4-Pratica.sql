SHOW DATABASES;             -- Esploro DB che ci sono nel server
USE adventureworksdw;       -- Seleziono DB adventureworksdw

-- Punto 1: Implementa una vista denominata Product per creare anagrafica (dimensione) prodotto completa. 
-- La vista, se interrogata/utilizzata come sorgente dati, deve esporre nome prodotto, nome sottocategoria associata 
-- e nome categoria associata.
SELECT * FROM dimproduct;              -- 606 record
SELECT * FROM dimproductsubcategory;   -- 37 record
SELECT * FROM dimproductcategory;      -- 4 record
CREATE VIEW Product AS (
    SELECT P.ProductKey AS IDProduct, 
    P.EnglishProductName AS ProductName, 
    IFNULL(SC.EnglishProductSubcategoryName, 'NA') AS SubcategoryName,
    IFNULL(C.EnglishProductCategoryName, 'NA') AS CategoryName
    FROM dimproduct AS P 
    LEFT JOIN dimproductsubcategory AS SC ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey
    LEFT JOIN dimproductcategory AS C ON SC.ProductCategoryKey = C.ProductCategoryKey
);  -- 606 record  -- Utilizzo LEFT JOIN, perchè nelle FK ci sono dei NULL
SELECT * FROM Product;
-- Punto 2: Implementa una vista denominata Reseller per creare anagrafica (dimensione) reseller completa. 
-- La vista, se interrogata/utilizzata come sorgente dati, deve esporre nome reseller, nome città e nome regione.
SELECT * FROM dimreseller;             -- 701 record
SELECT * FROM dimgeography;            -- 655 record
CREATE VIEW Reseller AS (
    SELECT R.ResellerKey AS IDReseller, R.ResellerName, G.City, G.EnglishCountryRegionName AS RegionName
    FROM dimreseller AS R 
    INNER JOIN dimgeography AS G ON R.GeographyKey = G.GeographyKey  
);  -- 701 record  -- Utilizzo INNER JOIN, perchè non ci sono NULL
SELECT * FROM Reseller;
-- Punto 3: Crea una vista denominata Sales che deve restituire data dellʼordine, codice documento, 
-- riga di corpo del documento, quantità venduta, importo totale e profitto.
SELECT * FROM dimproduct;              -- 606 record
SELECT * FROM factresellersales;       -- oltre 50000 record
SELECT * FROM dimreseller;             -- 701 record
CREATE VIEW Sales AS (
    SELECT P.ProductKey AS IDProduct, R.ResellerKey AS IDReseller, RS.OrderDate, RS.SalesOrderNumber, 
    RS.SalesOrderLineNumber, RS.OrderQuantity, RS.SalesAmount,
    ROUND(SUM(RS.SalesAmount-IFNULL(RS.TotalProductCost,0)),2) AS Profit    -- IFNULL perchè ci sono NULL
    FROM dimproduct AS P 
    JOIN factresellersales AS RS ON RS.ProductKey = P.ProductKey
    JOIN dimreseller AS R ON RS.ResellerKey = R.ResellerKey
    GROUP BY P.ProductKey, R.ResellerKey, RS.OrderDate, RS.SalesOrderNumber, RS.SalesOrderLineNumber, 
    RS.OrderQuantity, RS.SalesAmount
);  -- oltre 50000 record
SELECT * FROM Sales;                   -- oltre 50000 record

SELECT * FROM Sales WHERE Profit < 0;  -- Visualizzo i profitti minori di 0
SELECT * FROM Sales ORDER BY Profit;   -- Ordino ASC: dal profitto minore a quello maggiore 
