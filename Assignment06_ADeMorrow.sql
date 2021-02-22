--*************************************************************************--
-- Title: Assignment06
-- Author: Amy DeMorrow
-- Desc: This file demonstrates how to use Views
-- Change Log: 
-- 2021-02-20, ADeMorrow, answered first 8 questions with Views w/ 
--   matching results.
-- 2021-02-21, ADeMorrow, answered final 2 questions with Views w/
--   matching results and tested all views.
-- 2021-02-20,ADeMorrow,Created initial file with fully populated DB
--   tables, constraints, and data from instructor provided code.
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ADeMorrow')
	 Begin 
	  Alter Database [Assignment06DB_ADeMorrow] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ADeMorrow;
	 End
	Create Database Assignment06DB_ADeMorrow;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ADeMorrow;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go
Create View vCategories
With SCHEMABINDING
As
  Select CategoryID, CategoryName
  From dbo.Categories;
Go

Create View vProducts
With SCHEMABINDING
As
  Select ProductID, ProductName, CategoryID, UnitPrice
  From dbo.Products;
Go

Create View vEmployees
With SCHEMABINDING
As
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
  From dbo.Employees;
Go

Create View vInventories
With SCHEMABINDING
As
  Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
  From dbo.Inventories;
Go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
Go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create
View vCategoryProductPrice
As
  Select CategoryName, ProductName, UnitPrice
  From Categories as c 
   Inner Join Products as p
   On c.CategoryID = p.CategoryID
Go

Select * From vCategoryProductPrice 
  Order By CategoryName, ProductName;
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create
View vProductInventoryCountInventoryDate
As
  Select ProductName, InventoryDate, [Count]
  From Products as p 
   Inner Join Inventories as i
  On p.ProductID = i.ProductID
Go

Select * From vProductInventoryCountInventoryDate 
  Order By ProductName, InventoryDate, [Count]; 
Go

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create
View vInventoryDateEmployee
As
 Select InventoryDate, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
 From Employees as e 
  Inner Join Inventories as i
 On e.EmployeeID = i.EmployeeID
 Group By EmployeeFirstName + ' ' + EmployeeLastName, InventoryDate;
Go

Select * From vInventoryDateEmployee 
  Order By InventoryDate, [EmployeeName];
Go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create
View vCategoryProductInventoryDateCount
As
  Select CategoryName, ProductName, InventoryDate, [Count]
  From Categories as c 
   Inner Join Products as p 
  On c.CategoryID = p.CategoryID
   Inner Join Inventories as i 
  On i.ProductID = p.ProductID;
Go

Select * From vCategoryProductInventoryDateCount 
  Order By CategoryName, ProductName, InventoryDate, [Count];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create
View vCategoryProductInventoryDateCountEmployee
As
  Select 
   CategoryName, 
   ProductName, 
   InventoryDate, 
   [Count], 
   EmployeeFirstName + ' ' + EmployeeLastName as [EmployeeName]
  From Categories as c 
   Inner Join Products as p 
    On c.CategoryID = p.CategoryID
   Inner Join Inventories as i 
    On i.ProductID = p.ProductID
   Inner Join Employees as e
    On i.EmployeeID = e.EmployeeID;
Go

Select * From vCategoryProductInventoryDateCountEmployee 
  Order By InventoryDate, CategoryName, ProductName, [EmployeeName];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create
View vCategoryProductInventoryDateCountEmployee_FilteredByProductsChaiAndChang
As
  Select 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	[Count], 
	EmployeeFirstName + ' ' + EmployeeLastName as [EmployeeName]
  From Categories as c 
	Inner Join Products as p 
	On c.CategoryID = p.CategoryID
	Inner Join Inventories as i 
	On i.ProductID = p.ProductID
	Inner Join Employees as e
	On i.EmployeeID = e.EmployeeID
  Where p.ProductID IN 
	(Select ProductID From Products Where ProductName = 'Chai' or ProductName = 'Chang')

Go

Select * From vCategoryProductInventoryDateCountEmployee_FilteredByProductsChaiAndChang
  Order By InventoryDate, CategoryName, ProductName;
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create
View vEmployeeWithManager
As
Select
 m.EmployeeFirstName + ' ' + m.EmployeeLastName as [Manager],
 e.EmployeeFirstName + ' ' + e.EmployeeLastName as [Employee]
From Employees as e 
 Inner Join Employees as m
  On m.EmployeeID = e.ManagerID;
Go

Select * From vEmployeeWithManager Order By Manager, Employee;
Go

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

Create View vAllBASIC
With SCHEMABINDING
As
  Select 
    c.CategoryID
  , CategoryName
  , p.ProductID
  , ProductName
  , UnitPrice
  , InventoryID
  , InventoryDate
  , [Count]
  , e.EmployeeID
  , Employee =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
  , Manager = m.EmployeeFirstName + ' ' + m.EmployeeLastName
  From dbo.Categories as c 
	Inner Join dbo.Products as p 
	On c.CategoryID = p.CategoryID
	Inner Join dbo.Inventories as i 
	On i.ProductID = p.ProductID
	Inner Join dbo.Employees as e
	On i.EmployeeID = e.EmployeeID 
    Inner Join dbo.Employees as m
    On m.EmployeeID = e.ManagerID;
Go

Select * From vAllBASIC Order By CategoryID, ProductID, EmployeeID, InventoryID;
Go

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoryProductPrice]
Select * From [dbo].[vProductInventoryCountInventoryDate]
Select * From [dbo].[vInventoryDateEmployee]
Select * From [dbo].[vCategoryProductInventoryDateCount]
Select * From [dbo].[vCategoryProductInventoryDateCountEmployee]
Select * From [dbo].[vCategoryProductInventoryDateCountEmployee_FilteredByProductsChaiAndChang]
Select * From [dbo].[vEmployeeWithManager]
Select * From [dbo].[vAllBASIC]
/***************************************************************************************/