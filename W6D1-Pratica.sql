-- Punto 1: Eseguo il restore (recupero) del db aziendale:
SHOW DATABASES;                       -- esploro DB disponibili
USE AdventureWorksDW;                 -- seleziono DB che voglio interrogare
SHOW TABLES;                          -- esploro tabelle del DB selezionato

-- Punto 2: Esploro tabella prodotti (DimProduct):
SELECT * FROM dimproduct;             -- 606 record  

-- Punto 3: Interrogo tabella prodotti (DimProduct).
-- Seleziono campi ProductKey, ProductAlternateKey, EnglishProductName, Color, StandardCost, FinishedGoodsFlag:
SELECT ProductKey, ProductAlternateKey, EnglishProductName AS ProductName, Color, StandardCost, FinishedGoodsFlag 
FROM dimproduct;                                                           -- 606 record

-- Punto 4: Espongo prodotti finiti (quelli per cui il campo FinishedGoodsFlag è = 1):
SELECT ProductKey, ProductAlternateKey, EnglishProductName AS ProductName, Color, StandardCost, FinishedGoodsFlag 
FROM dimproduct                       
WHERE FinishedGoodsFlag = 1;                                               -- 397 record

-- Punto 5: Espongo prodotti il cui codice modello (ProductAlternateKey) comincia con FR oppure BK. 
-- Result set deve contenere codice prodotto, modello, nome del prodotto, costo standard e prezzo di listino:
SELECT ProductKey, ProductAlternateKey, ModelName, EnglishProductName AS ProductName, StandardCost, ListPrice 
FROM dimproduct 
WHERE ProductAlternateKey LIKE 'BK%' OR ProductAlternateKey LIKE 'FR%';    -- 253 record

-- Punto 1.2: Eseguo il campo calcolato 'MarkUp' (ListPrice - StandardCost):
SELECT ProductKey, ProductAlternateKey, ModelName, EnglishProductName AS ProductName, StandardCost, ListPrice, 
ListPrice - StandardCost AS Markup 
FROM dimproduct 
WHERE ProductAlternateKey LIKE 'BK%' OR ProductAlternateKey LIKE 'FR%';    -- 253 record

-- Punto 2.2: Espongo elenco prodotti finiti (il prezzo di listino è compreso tra 1000 e 2000):
SELECT ProductKey, ProductAlternateKey, EnglishProductName AS ProductName, ListPrice 
FROM dimproduct 
WHERE FinishedGoodsFlag = 1 AND ListPrice BETWEEN 1000 AND 2000;           -- 80 record

-- Punto 3.2: Esploro tabella impiegati aziendali (DimEmployee):
SELECT * FROM dimemployee;                                                 -- 296 record

-- Punto 4.2: Espongo elenco dei soli agenti (i dipendenti per i quali il campo SalespersonFlag è = 1):
SELECT EmployeeKey, FirstName, LastName, SalesPersonFlag 
FROM dimemployee 
WHERE SalesPersonFlag = 1;                                                 -- 18 record

-- Punto 5.2: Espongo elenco transazioni registrate a partire dal 2020-01-01 (solo per codici prodotto: 597,598,477,214).
-- Calcolo per ciascuna transazione il profitto (SalesAmount - TotalProductCost):
SELECT * FROM factresellersales; -- esploro tab.vendite (FactResellerSales)-- 50000 record (max)
SELECT ProductKey, DueDate, SalesAmount - TotalProductCost AS Profit 
FROM factresellersales 
WHERE DueDate >= '2020-01-01'AND ProductKey IN (597,598,477,214);          -- 346 record