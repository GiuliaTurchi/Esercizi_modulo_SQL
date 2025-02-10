-- Punto 1: 
SHOW DATABASES; -- trovo i DB che ho disponibili
USE AdventureWorksDW; -- selezione il DB che voglio interrogare
SHOW TABLES; -- esploro le tabelle del DB selezionato

-- Punto 2:
SELECT * FROM dimproduct; -- esploro la tabella dimproduct

-- Punto 3: interrogo la tabella dei prodotti (dimproduct)
SELECT ProductKey, ProductAlternateKey, EnglishProductName, Color, StandardCost, FinishedGoodsFlag 
FROM dimproduct;

-- Punto 4: espongo i prodotti finiti (quelli per cui il campo FinishedGoodsFlag è = 1)
SELECT ProductKey, ProductAlternateKey, EnglishProductName, Color, StandardCost, FinishedGoodsFlag 
FROM dimproduct 
WHERE FinishedGoodsFlag = 1;

-- Punto 5: espongo i prodotti il cui codice modello comincia con FR oppure BK. 
-- Result set deve contenere il codice prodotto, il modello, il nome del prodotto, il costo standard e il prezzo di listino
SELECT ProductKey, ProductAlternateKey, ModelName, EnglishProductName, StandardCost, ListPrice 
FROM dimproduct 
WHERE ProductAlternateKey LIKE 'BK%' OR ProductAlternateKey LIKE 'FR%';

-- Punto 1: eseguo il campo calcolato 'MarkUp' (ListPrice - StandardCost)
SELECT ProductKey, ProductAlternateKey, ModelName, EnglishProductName, StandardCost, ListPrice, 
ListPrice - StandardCost AS Markup 
FROM dimproduct 
WHERE ProductAlternateKey LIKE 'BK%' OR ProductAlternateKey LIKE 'FR%';

-- Punto 2: espongo elenco dei prodotti finiti il cui prezzo di listino è compreso tra 1000 e 2000
SELECT ProductKey, ProductAlternateKey, EnglishProductName, ListPrice 
FROM dimproduct 
WHERE FinishedGoodsFlag = 1 AND ListPrice BETWEEN 1000 AND 2000; 

-- Punto 3: 
SELECT * FROM dimemployee; -- esploro la tabella dimemployee

-- Punto 4: espongo elenco dei soli agenti (i dipendenti per i quali il campo SalespersonFlag è = 1)
SELECT EmployeeKey, FirstName, LastName, SalesPersonFlag 
FROM dimemployee 
WHERE SalesPersonFlag = 1;

-- Punto 5: espongo elenco transazioni registrate a partire dal 2020-01-01 solo per i codici prodotto: 597, 598, 477, 214
-- calcolo per ciascuna transazione il profitto (SalesAmount - TotalProductCost)
SELECT * FROM factresellersales; -- esploro la tabella factresellersales
SELECT ProductKey, DueDate, SalesAmount - TotalProductCost AS Profit 
FROM factresellersales 
WHERE DueDate >= '2020-01-01'AND ProductKey IN (597, 598, 477, 214);