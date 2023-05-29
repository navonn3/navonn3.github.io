-- Matan Navon - Project 1

CREATE DATABASE Sales;
GO

USE Sales;
GO

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Person;
GO

CREATE SCHEMA Purchasing;
GO

USE Sales;
GO


CREATE TABLE Sales.CurrencyRate (
	CurrencyRateID		int NOT NULL PRIMARY KEY,
	CurrencyRateDate	datetime NOT NULL,
	FromCurrencyCode	nchar(3) NOT NULL,
	ToCurrencyCode		nchar(3) NOT NULL,
	AverageRate			money NOT NULL,
	EndOfDayRate		money NOT NULL,
	ModifiedDate		datetime NOT NULL
);

CREATE TABLE Purchasing.ShipMethod (
	ShipMethodID		int NOT NULL PRIMARY KEY,
	Name				nvarchar(50) NOT NULL,
	ShipBase			money NOT NULL,
	ShipRate			money NOT NULL,
	rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 


CREATE TABLE Person.Address (
	AddressID			int NOT NULL PRIMARY KEY,
	AddressLine1		nvarchar(60) NOT NULL,
	AddressLine2		nvarchar(60),
	City				nvarchar(30) NOT NULL,
	StateProvinceID		int NOT NULL,
	PostalCode			nvarchar(15) NOT NULL,
	SpatialLocation		geography,
	rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 

CREATE TABLE Sales.SpecialOfferProduct (
	SpecialOfferID		int NOT NULL,
	ProductID			int NOT NULL,
	rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 


CREATE TABLE Sales.CreditCard (
	CreditCardID		int NOT NULL PRIMARY KEY,
	CardType			nvarchar(50) NOT NULL,
	CardNumber			nvarchar(25) NOT NULL,
	ExpMonth			tinyint NOT NULL,
	ExpYear				smallint NOT NULL,
	ModifiedDate		datetime NOT NULL
); 

CREATE TABLE Sales.SalesTerritory (
	TerritoryID			int NOT NULL PRIMARY KEY,
	Name				nvarchar(50) NOT NULL,
	CountryRegionCode	nvarchar(3) NOT NULL,
	[Group]				nvarchar(50) NOT NULL,
	SalesYTD			money NOT NULL,
	SalesLastYear		money NOT NULL,
	CostYTD				money NOT NULL,
	CostLastYear		money NOT NULL,
	rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 

CREATE TABLE Sales.SalesPerson (
	BusinessEntityID	int NOT NULL PRIMARY KEY,
	TerritoryID			int FOREIGN KEY REFERENCES Sales.SalesTerritory(TerritoryID),
	SalesQuota			money,
	Bonus				money NOT NULL,
	CommissionPct		smallmoney NOT NULL,
	SalesYTD			money NOT NULL,
	SalesLastYear		money NOT NULL,
	rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 

CREATE TABLE Sales.Customer (
	CustomerID			int NOT NULL PRIMARY KEY,
	PersonID			int,
	StoreID				int,
	TerritoryID			int FOREIGN KEY REFERENCES Sales.SalesTerritory(TerritoryID),
	AccountNumber		varchar(10) NOT NULL,
	rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 

CREATE TABLE Sales.SalesOrderHeader (
	SalesOrderID		int NOT NULL PRIMARY KEY,
	RevisionNumber		tinyint NOT NULL,
	OrderDate			datetime NOT NULL,
	DueDate				datetime NOT NULL,
	ShipDate			datetime,
	Status				tinyint NOT NULL,
	OnlineOrderFlag		bit NOT NULL,
	SalesOrderNumber	nvarchar(25) NOT NULL,
	PurchaseOrderNumber	nvarchar(15),
	AccountNumber		nvarchar(15),
	CustomerID			int FOREIGN KEY REFERENCES Sales.Customer(CustomerID),
	SalesPersonID		int FOREIGN KEY REFERENCES Sales.SalesPerson(BusinessEntityID),
	TerritoryID			int FOREIGN KEY REFERENCES Sales.SalesTerritory(TerritoryID),
	BillToAddressID		int FOREIGN KEY REFERENCES Person.Address(AddressID),
	ShipToAddressID		int FOREIGN KEY REFERENCES Person.Address(AddressID),
	ShipMethodID		int FOREIGN KEY REFERENCES Purchasing.ShipMethod(ShipMethodID),
	CreditCardID		int FOREIGN KEY REFERENCES Sales.CreditCard(CreditCardID),
	CreditCardApprovalCode	varchar(15),
	CurrencyRateID		int FOREIGN KEY REFERENCES Sales.CurrencyRate(CurrencyRateID),
	SubTotal			money NOT NULL,
	TaxAmt				money NOT NULL,
	Freight				money NOT NULL
); 

CREATE TABLE Sales.SalesOrderDetail (
	SalesOrderID		int NOT NULL FOREIGN KEY REFERENCES Sales.SalesOrderHeader(SalesOrderID) ,
	SalesOrderDetailID	int NOT NULL PRIMARY KEY,
	CarrierTrackingNumber nvarchar(25),
	OrderQTY			smallint NOT NULL,
	ProductID			int NOT NULL,
	SpecialOfferID		int NOT NULL,
	UnitPrice			money NOT NULL,
	UnitPriceDiscount	money NOT NULL,
	LineTotal			money NOT NULL,
	Rowguid				uniqueidentifier NOT NULL,
	ModifiedDate		datetime NOT NULL
); 

INSERT INTO Sales.Sales.CurrencyRate
			(CurrencyRateID, CurrencyRateDate, FromCurrencyCode, ToCurrencyCode, AverageRate, EndOfDayRate, ModifiedDate)
SELECT		CurrencyRateID, CurrencyRateDate, FromCurrencyCode, ToCurrencyCode, AverageRate, EndOfDayRate, ModifiedDate
FROM		AdventureWorks2019.Sales.CurrencyRate

INSERT INTO Sales.Purchasing.ShipMethod
			(ShipMethodID, Name, ShipBase, ShipRate, rowguid, ModifiedDate)
SELECT		ShipMethodID, Name, ShipBase, ShipRate, rowguid, ModifiedDate
FROM		AdventureWorks2019.Purchasing.ShipMethod

INSERT INTO Sales.Person.Address
			(AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation, rowguid, ModifiedDate)
SELECT		AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation, rowguid, ModifiedDate
FROM		AdventureWorks2019.Person.Address

INSERT INTO Sales.Sales.SpecialOfferProduct
			(SpecialOfferID, ProductID, rowguid, ModifiedDate)
SELECT		SpecialOfferID, ProductID, rowguid, ModifiedDate
FROM		AdventureWorks2019.Sales.SpecialOfferProduct

INSERT INTO Sales.Sales.CreditCard
			(CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate)
SELECT		CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate
FROM		AdventureWorks2019.Sales.CreditCard

INSERT INTO Sales.Sales.SalesTerritory
			(TerritoryID, Name, CountryRegionCode, [Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate)
SELECT		TerritoryID, Name, CountryRegionCode, [Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate
FROM		AdventureWorks2019.Sales.SalesTerritory

INSERT INTO Sales.Sales.SalesPerson
			(BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear, rowguid, ModifiedDate)
SELECT		BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear, rowguid, ModifiedDate
FROM		AdventureWorks2019.Sales.SalesPerson

INSERT INTO Sales.Sales.Customer
			(CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate)
SELECT		CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate
FROM		AdventureWorks2019.Sales.Customer

INSERT INTO Sales.Sales.SalesOrderHeader
			(SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight)
SELECT		SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight
FROM		AdventureWorks2019.Sales.SalesOrderHeader

INSERT INTO Sales.Sales.SalesOrderDetail
			(SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQTY, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, Rowguid, ModifiedDate)
SELECT		SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQTY, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, Rowguid, ModifiedDate
FROM		AdventureWorks2019.Sales.SalesOrderDetail