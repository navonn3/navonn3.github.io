------ Matan Navon - Project 2

USE AdventureWorks2019;  
GO  

------ Question 1

SELECT ProductID, Name, Color,ListPrice, Size
	FROM Production.product
	WHERE productid NOT IN
		(SELECT DISTINCT ProductID
		FROM sales.SalesOrderDetail)
	ORDER BY ProductID;


------ Question 2

UPDATE sales.customer SET personid=customerid 
   WHERE customerid <=290
UPDATE sales.customer SET personid=customerid+1700 
   WHERE customerid >= 300 and customerid<=350
UPDATE sales.customer SET personid=customerid+1700 
   WHERE customerid >= 352 and customerid<=701

SELECT	CustomerID, 
		IIF(LastName IS NULL, 'Unknown',Lastname) as LastName,
		IIF(FirstName IS NULL, 'Unknown',Firstname) as FirstName		
FROM sales.customer c
LEFT JOIN Person.Person p ON c.PersonID=p.BusinessEntityID
WHERE c.CustomerID NOT IN
		(SELECT DISTINCT CustomerID
		FROM sales.SalesOrderHeader) 
ORDER BY CustomerID;


------ Question 3

SELECT Top 10 
	s.CustomerID, p.FirstName, p.LastName, COUNT(s.CustomerID) as CountOfOrder
FROM Sales.SalesOrderHeader s
JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
JOIN Person.person p ON p.BusinessEntityID=c.PersonID
GROUP BY s.CustomerID, p.FirstName, p.LastName
ORDER BY CountOfOrder DESC, CustomerID


------ Question 4

SELECT	p.FirstName, p.LastName, h.JobTitle, h.HireDate, 
		COUNT(h.BusinessEntityID) OVER (Partition By h.JobTitle) AS CountOfTitle
FROM HumanResources.Employee h
JOIN Person.person p on h.BusinessEntityID=p.BusinessEntityID;


------ Question 5

WITH CTE
AS
	(SELECT s.SalesOrderID, s.CustomerID, p.LastName, p.FirstName, s.OrderDate,
			LAG(OrderDate,1) OVER (Partition By c.PersonID Order By s.OrderDate) as PreviousOrder,
			RANK() OVER (Partition BY c.PersonID Order By s.OrderDate DESC) as Rankk
	FROM Sales.SalesOrderHeader s
	JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
	JOIN Person.person p ON p.BusinessEntityID=c.PersonID)

SELECT SalesOrderID, CustomerID, LastName, FirstName, OrderDate AS LastOrder, PreviousOrder
FROM CTE
WHERE CTE.Rankk=1;


------ Question 6

WITH CTE
AS
	(SELECT SalesOrderID, YEAR(OrderDate) as Year, OrderDate, SubTotal, p.LastName, p.FirstName,
	RANK() OVER (PARTITION BY (YEAR(OrderDate)) ORDER BY SubTotal DESC) as Rankk
	FROM Sales.SalesOrderHeader s
	JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
	JOIN Person.person p ON p.BusinessEntityID=c.PersonID)

SELECT Year, SalesOrderID, LastName, FirstName, SubTotal as Total
FROM CTE
WHERE CTE.Rankk=1;


------ Question 7

SELECT	Month,        
		ISNULL([2011], 0) AS [2011], 
		ISNULL([2012], 0) AS [2012], 
		ISNULL([2013], 0) AS [2013], 
		ISNULL([2014], 0) AS [2014]
FROM 
	(SELECT	MONTH(OrderDate) AS Month,
			YEAR(OrderDate) AS Year,
			COUNT(*) AS OrderCount
	FROM Sales.SalesOrderHeader s
	GROUP BY MONTH(OrderDate), YEAR(OrderDate)) AS Cols
PIVOT
(
  SUM(OrderCount)
  FOR Year IN ([2011], [2012], [2013], [2014])
) AS Rows;


------ Question 8

WITH CTE
AS
	(
	SELECT
		YEAR(OrderDate) AS Year,
		MONTH(OrderDate) AS Month,
		ROUND(SUM(SubTotal),2) AS month_total,
		ROUND(SUM(SUM(SubTotal)) OVER (PARTITION BY YEAR(OrderDate) ORDER BY MONTH(OrderDate)),2) AS ytd_total
	FROM Sales.SalesOrderHeader s
	GROUP BY YEAR(OrderDate),MONTH(OrderDate)
	)

SELECT	Year,
		Convert(nvarchar(11),Month) as Month,
		month_total AS Sum_Price,
		ytd_total AS Money
FROM CTE

UNION ALL

SELECT
    Year, 'Grand_Total', NULL,
    SUM(month_total) AS Money
FROM CTE
GROUP BY Year
ORDER BY Year, Money;


------ Question 9

WITH CTE
AS
	(
	SELECT	d.Name as DepartmentName, h.BusinessEntityID as EmployeeID, 	
			CONCAT(p.FirstName,' ',p.LastName) as 'EmployeeFullName', h.HireDate,
			DATEDIFF(MONTH, h.HireDate, GETDATE()) AS 'Seniority'
	FROM HumanResources.Employee h
		LEFT JOIN Person.person p ON h.BusinessEntityID=p.BusinessEntityID
		LEFT JOIN HumanResources.EmployeeDepartmentHistory ed ON h.BusinessEntityID=ed.BusinessEntityID 
		LEFT JOIN HumanResources.Department d ON ed.DepartmentID=d.DepartmentID
	WHERE ed.EndDate IS NULL
	)

SELECT *,
		LAG(EmployeeFullName,1) OVER (PARTITION BY DepartmentName ORDER BY HireDate) as PerviousEmpName,
		LAG(HireDate,1) OVER (PARTITION BY DepartmentName ORDER BY HireDate) as PerviousEmpHDate,
		DATEDIFF(D,(LAG(HireDate,1) OVER (PARTITION BY DepartmentName ORDER BY HireDate)),HireDate) as DiffDays
		 
FROM CTE c
ORDER BY c.DepartmentName, HireDate DESC;


------ Question 10

WITH CTE
AS	
	(SELECT h.HireDate, ed.DepartmentID,
			CONCAT(h.BusinessEntityID,' ',p.LastName,' ', p.FirstName,' ') as Emp
	FROM HumanResources.Employee h
		LEFT JOIN Person.person p ON h.BusinessEntityID=p.BusinessEntityID
		LEFT JOIN HumanResources.EmployeeDepartmentHistory ed ON h.BusinessEntityID=ed.BusinessEntityID 
	WHERE ed.EndDate IS NULL
	)

SELECT HireDate, DepartmentID,	STUFF((SELECT ',' + Emp FROM CTE c2
								WHERE c1.HireDate=c2.HireDate AND
								c1.DepartmentID=c2.DepartmentID
								FOR XML PATH ('')),1,1,'') AS 'Employees'
FROM CTE c1
GROUP BY HireDate,DepartmentID
ORDER BY HireDate