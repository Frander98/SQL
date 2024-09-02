USE [Sales Analysis]; 

--CREATE TABLE [Invoice] (
--	[Invoice_ID] VARCHAR(100) NOT NULL UNIQUE,
--	[Branch_ID] INTEGER NOT NULL,
--	[Customer_Type_ID] INTEGER NOT NULL,
--	[Tax_0.05] DECIMAL,
--	[Gender_ID] INTEGER NOT NULL,
--	[Unit_price] DECIMAL NOT NULL,
--	[Product_Line_ID] INTEGER NOT NULL,
--	[Quantity] DECIMAL NOT NULL,
--	[Time] TIME NOT NULL,
--	[Payment] VARCHAR(100) NOT NULL,
--	[cogs] DECIMAL NOT NULL,
--	[gross_margin_percentage] DECIMAL NOT NULL,
--	[gross_income] DECIMAL NOT NULL,
--	[Rating] DECIMAL NOT NULL,
--	[Date] DATE NOT NULL,
--	[Total] DECIMAL NOT NULL,
--	PRIMARY KEY([Invoice_ID])
--);
--GO



--CREATE TABLE [Customer_Type] (
--	[Customer_Type_ID] INTEGER NOT NULL UNIQUE,
--	[Customer_type] VARCHAR(100) NOT NULL,
--	PRIMARY KEY([Customer_Type_ID])
--);
--GO

--CREATE TABLE [Branch] (
--	[Branch_ID] INTEGER NOT NULL UNIQUE,
--	[Branch_Name] VARCHAR(100),
--	[City_ID] INTEGER,
--	PRIMARY KEY([Branch_ID])
--);
--GO

--CREATE TABLE [City] (
--	[City_ID] INTEGER NOT NULL UNIQUE,
--	[City] VARCHAR(100) NOT NULL,
--	PRIMARY KEY([City_ID])
--);
--GO

--CREATE TABLE [Product_Line] (
--	[Product_Line_ID] INTEGER NOT NULL UNIQUE,
--	[Product_line] VARCHAR(100) NOT NULL,
--	PRIMARY KEY([Product_Line_ID])
--);
--GO

--CREATE TABLE [Gender] (
--	[Gender_ID] INTEGER NOT NULL UNIQUE,
--	[Gender] VARCHAR(100) NOT NULL,
--	PRIMARY KEY([Gender_ID])
--);
--GO


--ALTER TABLE [Invoice]
--ADD FOREIGN KEY([Customer_Type_ID]) REFERENCES [Customer_Type]([Customer_Type_ID])
--ON UPDATE NO ACTION ON DELETE NO ACTION;
--GO

--ALTER TABLE [Invoice]
--ADD FOREIGN KEY([Branch_ID]) REFERENCES [Branch]([Branch_ID])
--ON UPDATE NO ACTION ON DELETE NO ACTION;
--GO

--ALTER TABLE [Branch]
--ADD FOREIGN KEY([City_ID]) REFERENCES [City]([City_ID])
--ON UPDATE NO ACTION ON DELETE NO ACTION;
--GO

--ALTER TABLE [Invoice]
--ADD FOREIGN KEY([Product_Line_ID]) REFERENCES [Product_Line]([Product_Line_ID])
--ON UPDATE NO ACTION ON DELETE NO ACTION;
--GO

--ALTER TABLE [Invoice]
--ADD FOREIGN KEY([Gender_ID]) REFERENCES [Gender]([Gender_ID])
--ON UPDATE NO ACTION ON DELETE NO ACTION;
--GO

------------------------------------------
--Query to retrieve denormalized data from all tables

--SELECT Invoice_ID, B.Branch_Name, Ci.City, C.Customer_type, G.Gender, P.Product_line,
--Unit_price, Quantity,Tax, Total, I.Date, Time, 
--Payment, cogs, gross_margin_percentage,gross_income, Rating   FROM Invoice I 
--JOIN Branch B
--ON I.Branch_ID = B.Branch_ID
--JOIN Customer_Type C
--ON I.Customer_Type_ID = C.Customer_Type_ID
--JOIN Gender G 
--ON I.Gender_ID = g.Gender_ID
--JOIN Product_Line P
--ON I.Product_Line_ID = P.Product_Line_ID
--JOIN City Ci 
--ON B.City_ID = Ci.City_ID;


--CREATE VIEW TO RETRIEVE ALL THE DATA
--CREATE VIEW Denormalized_data AS
--	(
--	SELECT Invoice_ID, B.Branch_Name, Ci.City, C.Customer_type, G.Gender, P.Product_line,
--	Unit_price, Quantity,Tax, Total, I.Date, Time, 
--	Payment, cogs, gross_margin_percentage,gross_income, Rating   FROM Invoice I 
--	JOIN Branch B
--	ON I.Branch_ID = B.Branch_ID
--	JOIN Customer_Type C
--	ON I.Customer_Type_ID = C.Customer_Type_ID
--	JOIN Gender G 
--	ON I.Gender_ID = g.Gender_ID
--	JOIN Product_Line P
--	ON I.Product_Line_ID = P.Product_Line_ID
--	JOIN City Ci 
--	ON B.City_ID = Ci.City_ID
--	);

--ALTER VIEW Denormalized_data
--AS
--	(
--	SELECT 
--	Invoice_ID, B.Branch_Name, Ci.City, C.Customer_type, G.Gender, P.Product_line,
--	Unit_price, Quantity,Tax, Total, I.Date, Time, Payment, cogs, gross_margin_percentage,
--	gross_income, Rating, DATENAME(weekday, Date) AS Day_name,
--	DATENAME(month, Date) AS Month_name, 
--	DATENAME(year, Date) AS Year_name, 
--	CASE
--        WHEN Time >= '00:00:00' AND Time < '12:00:00' THEN 'Morning'
--        WHEN Time >= '12:00:00' AND Time < '18:00:00' THEN 'Afternoon'
--        ELSE 'Evening'
--    END AS part_of_day
--	FROM Invoice I 
--	JOIN Branch B
--	ON I.Branch_ID = B.Branch_ID
--	JOIN Customer_Type C
--	ON I.Customer_Type_ID = C.Customer_Type_ID
--	JOIN Gender G 
--	ON I.Gender_ID = g.Gender_ID
--	JOIN Product_Line P
--	ON I.Product_Line_ID = P.Product_Line_ID
--	JOIN City Ci 
--	ON B.City_ID = Ci.City_ID
--	);

--VIEW
SELECT TOP 5 * FROM Denormalized_data;

--Business questions
--1-How many distinct cities are present in the dataset?
SELECT DISTINCT(City) FROM Denormalized_data;

--2-In which city is each branch situated?
SELECT DISTINCT(Branch_Name), City FROM Denormalized_data;

-----------------------PRODUCT ANALYSIS-----------------------
--3-How many distinct product lines are there in the dataset?
SELECT COUNT(DISTINCT(Product_Line))
AS distinct_product_lines
FROM Denormalized_data;

SELECT DISTINCT(Product_Line)
AS Distinct_product_lines
FROM Denormalized_data;

--4-What is the total revenue by month? 
--Total revenue = Number of units sold * Unit price
SELECT Month_name, SUM(Unit_price * Quantity) AS TotalRevenue
FROM Denormalized_data
GROUP BY Month_name
ORDER BY TotalRevenue DESC;

--5-Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT Month_name, SUM(cogs) AS Cogs
FROM Denormalized_data
GROUP BY Month_name
ORDER BY Cogs DESC;

--6-Which product line generated the highest revenue?
SELECT TOP 3 Product_Line, SUM(Total) AS Revenue
FROM Denormalized_data
GROUP BY Product_line
ORDER BY Revenue DESC;

--7.Which city has the highest revenue?
SELECT City, SUM(Total) AS Revenue
FROM Denormalized_data
GROUP BY City
ORDER BY Revenue DESC;

-- 8.Which product line incurred the highest VAT?
SELECT TOP 1 Product_Line, SUM(Tax) AS TotalVAT
FROM Denormalized_data
GROUP BY Product_line
ORDER BY TotalVAT DESC;


--9-Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on
--whether its sales are above the average.
SELECT Product_Line, Total, AVG(Total) OVER() AS Average,
CASE
	WHEN Total > (SELECT AVG(Total) FROM Denormalized_data) THEN 'Good'
	ELSE 'Bad'
END AS Product_Line_Category
FROM Denormalized_data
ORDER BY Product_Line_Category;


--10-Which branch sold more products than average product sold?
SELECT Branch_Name, Quantity AS QuantityOfArticlesSold,
AVG(Quantity) OVER() AS Average
FROM Denormalized_data
;

SELECT Branch_Name, SUM(Quantity) AS Quantity
FROM Denormalized_data
GROUP BY Branch_Name
HAVING SUM(Quantity) > AVG(Quantity)
ORDER BY Quantity DESC; 

--11-What is the most common product line by gender?
SELECT Gender, Product_Line, COUNT(Product_line) AS QuantityOfEvents
FROM Denormalized_data
GROUP BY Gender, Product_line
ORDER BY  Product_line, Gender DESC;

--12-What is the average rating of each product line?
SELECT Product_Line, AVG(Rating) AS AverageRating
FROM Denormalized_data
GROUP BY Product_line
order by AverageRating DESC;

--13-What is the most common payment method?
SELECT Payment, COUNT(*) AS PaymentMethod
FROM Denormalized_data
GROUP BY Payment
ORDER BY PaymentMethod DESC;

-----------------------PRODUCT ANALYSIS-----------------------
--14-Number of sales events made in each day per weekday
SELECT Day_name, COUNT(Invoice_ID) AS Transactions
FROM Denormalized_data
GROUP BY Day_name
ORDER BY Transactions DESC;

--15-Number of sales made in each part of the day per weekday
SELECT Day_name, part_of_day, COUNT(*) AS transactions,
SUM(COUNT(*)) OVER(PARTITION BY Day_name) AS total_day_transactions
FROM Denormalized_data
GROUP BY Day_name, part_of_day
ORDER BY Day_name, transactions DESC;

--16-Identify the customer type that generates the highest revenue.
SELECT Customer_Type, SUM(Total) AS Revenue
FROM Denormalized_data
GROUP BY Customer_type;

--17-Which customer type pays the most in VAT?
SELECT Customer_Type, SUM(Tax) AS TaxTotal
FROM Denormalized_data
GROUP BY Customer_type
ORDER BY TaxTotal DESC;

--18-Total sales per week day
SELECT Day_name, SUM(Total) AS Revenue
FROM Denormalized_data
GROUP BY Day_name
ORDER BY Revenue DESC;

--19-Which customer type buys the most?
SELECT Customer_Type, SUM(Total) AS Revenue
FROM Denormalized_data
GROUP BY Customer_type
ORDER BY Revenue DESC;

--20-Which day of the week has the best average ratings per branch?
SELECT Branch_Name, Day_name, Rating
--AVG(Rating) OVER(PARTITION BY Day_name) AS AVG_per_day
SELECT Branch_Name, Day_name, Rating,
AVG(Rating) OVER(PARTITION BY Branch_Name) AS Rating
FROM Denormalized_data

--SELECT Day_name, COUNT(Invoice_ID) AS Transactions,
--SUM(Total) AS Revenue
--FROM Denormalized_data
--GROUP BY Day_name
--ORDER BY Transactions DESC;