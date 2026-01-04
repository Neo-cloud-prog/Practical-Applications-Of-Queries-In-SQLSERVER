CREATE TABLE Products (
    ProductId INT PRIMARY KEY,
    Name NVARCHAR(100),
    Category NVARCHAR(50),
    Price DECIMAL(10,2),
    CreatedAt DATETIME
);

INSERT INTO Products VALUES
(1, 'Laptop X', 'Electronics', 1500, '2025-01-01'),
(2, 'Mouse A',  'Electronics', 25,   '2025-01-05'),
(3, 'Desk Pro', 'Furniture',   220,  '2025-01-15'),
(4, 'Chair Z',  'Furniture',   120,  '2025-02-01'),
(5, 'Camera C', 'Electronics', 890,  '2025-02-05');

-- #1
DECLARE @Category NVARCHAR(50) = 'Electronics';
DECLARE @MinPrice DECIMAL(10,2) = NULL;
DECLARE @MaxPrice DECIMAL(10,2) = 1000;
DECLARE @SearchText NVARCHAR(MAX) = 'a';

DECLARE @Filter NVARCHAR(MAX) = '
SELECT *
FROM Products
WHERE 1 = 1
';

IF @Category IS NOT NULL
    SET @Filter += ' AND Category = @Category ';

IF @MinPrice IS NOT NULL
    SET @Filter += ' AND Price >= @MinPrice';

IF @MaxPrice IS NOT NULL
    SET @Filter += ' AND Price <= @MaxPrice';

IF @SearchText IS NOT NULL
    SET @Filter += ' AND Name LIKE ''%'' + @SearchText + ''%'' ';

SET @Filter += ' OPTION(RECOMPILE);';

EXEC sp_executesql @Filter,
    N'@Category NVARCHAR(50), @MinPrice DECIMAL(10,2), @MaxPrice DECIMAL(10,2), @SearchText NVARCHAR(MAX)',
    @Category, @MinPrice, @MaxPrice, @SearchText;

-- #2
DECLARE @SortColumn VARCHAR(10) = 'Price'
DECLARE @SortDirection VARCHAR(10) = 'DESC'

DECLARE @DynamicSort NVARCHAR(MAX) = '
SELECT *
FROM ' + QUOTENAME('Products') +
'ORDER BY ' + @SortColumn + ' ' + @SortDirection;

EXEC sp_executesql @DynamicSort
-- or
SELECT *
FROM Products
ORDER BY
    CASE WHEN @SortColumn = 'Price' AND @SortDirection = 'ASC' THEN Price END ASC,
    CASE WHEN @SortColumn = 'Price' AND @SortDirection = 'DESC' THEN Price END DESC,
    CASE WHEN @SortColumn = 'Name' AND @SortDirection = 'ASC' THEN Name END ASC,
    CASE WHEN @SortColumn = 'Name' AND @SortDirection = 'DESC' THEN Name END DESC;

-- #3
CREATE TABLE Sales (
    [Year] INT,
    [Month] NVARCHAR(20),
    Amount DECIMAL(10,2)
);

INSERT INTO Sales VALUES
(2025, 'Jan', 1000),
(2025, 'Feb', 1200),
(2025, 'Mar', 900),
(2024, 'Jan', 800),
(2024, 'Mar', 1100);

DECLARE @Cols NVARCHAR(MAX), @SQL NVARCHAR(MAX);

SELECT @Cols = STRING_AGG(QUOTENAME([Month]), ',')
FROM (SELECT DISTINCT [Month] FROM Sales) AS x;


SET @SQL = '
SELECT *
FROM Sales
PIVOT (
   SUM(Amount) FOR [Month] IN ('+@Cols+')
) AS pvt
';

SELECT year,month
FROM Sales group by year,month

EXEC (@SQL);

-- #4
CREATE TABLE Sales_2025_01 (Id INT, Amount INT);
CREATE TABLE Sales_2025_02 (Id INT, Amount INT);
CREATE TABLE Sales_2025_03 (Id INT, Amount INT);

INSERT INTO Sales_2025_01 VALUES (1, 100), (2, 150);
INSERT INTO Sales_2025_02 VALUES (1, 80);
INSERT INTO Sales_2025_03 VALUES (1, 200), (2, 250), (3, 300);

DECLARE @MonthNumber TINYINT = 3

DECLARE @tbl NVARCHAR(50) = QUOTENAME('Sales_2025_' + FORMAT(@MonthNumber,'00'));

DECLARE @Sq NVARCHAR(MAX) = 'SELECT * FROM ' + @tbl;

EXEC(@Sq);

-- #5
CREATE TABLE Users (
    UserId INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(50),
    Address NVARCHAR(200),
    City NVARCHAR(50)
);

INSERT INTO Users VALUES
(1, 'huhome',  'home@example.com', '123', 'Street 10', 'Rabat'),
(2, 'huwave',   'idk@example.com', '555', 'Street 20', 'Casablanca'),
(3, 'Mono',  'mono@example.com', '999', 'Street 30', 'Tanger');

DECLARE @Search NVARCHAR(MAX) = 'Ali';

DECLARE @DynamicSearchAcrossColumns NVARCHAR(MAX) = '
SELECT *
FROM Users WHERE
FullName LIKE ''%'' + @Search + ''%'' 
OR 
Email LIKE ''%'' + @Search + ''%''
OR 
Phone LIKE ''%'' + @Search + ''%''
OR 
Address LIKE ''%'' + @Search + ''%''
OR 
City LIKE ''%'' + @Search + ''%''';

EXEC sp_executesql @DynamicSearchAcrossColumns, N'@Search NVARCHAR(MAX)', @Search
-- or, Note : First off, u have to create FULLTEXT INDEX...
SELECT *
FROM Users
WHERE CONTAINS((FullName, Email, Phone, Address, City), @Search)

-- #6
DECLARE @UserId INT = 1
DECLARE @FieldName NVARCHAR(100) = 'Email'
DECLARE @NewValue NVARCHAR(100) = 'home_new@example.com'

DECLARE @DynamicUpdate NVARCHAR(MAX) = 
'UPDATE Users SET '+QUOTENAME(@FieldName)+' = @NewValue WHERE UserId = @UserId';
;

EXEC sp_executesql @DynamicUpdate, 
                   N'@UserId INT, @NewValue NVARCHAR(100)', 
				   @UserId, @NewValue

SELECT * FROM Users

-- #7
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY,
    CustomerId INT,
    Amount DECIMAL(10,2)
);

INSERT INTO Orders VALUES
(10, 1, 100),
(11, 2, 150),
(12, 3, 200);

CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(100)
);

INSERT INTO Customers VALUES
(1, 'Mono'),
(2, 'Cell'),
(3, 'Atom');

CREATE TABLE Payments (
    OrderId INT,
    PaidAmount DECIMAL(10,2)
);

INSERT INTO Payments VALUES
(10, 100),
(11, 120);

DECLARE @IncludeCustomers BIT = 1
DECLARE @IncludePayments BIT = 0

DECLARE @DynamicJoin NVARCHAR(MAX) = 
'
  SELECT * FROM Orders
';

IF @IncludeCustomers = 1
  SET @DynamicJoin += ' INNER JOIN Customers ON Orders.CustomerId = Customers.CustomerId' 
IF @IncludePayments = 1
  SET @DynamicJoin += ' INNER JOIN Payments ON Orders.OrderId = Payments.OrderId' 

EXEC sp_executesql @DynamicJoin

-- #8
DECLARE @json NVARCHAR(MAX) = '{ "FullName":"neo", "Email":"n@p.com", "City":"Prokuplje" }';

SELECT *
FROM OPENJSON(@json)
WITH (
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    City NVARCHAR(50)
) AS x;

UPDATE Users
SET 
    FullName = JSON_VALUE(@json,'$.FullName'),
    Email    = JSON_VALUE(@json,'$.Email'),
    City     = JSON_VALUE(@json,'$.City')
WHERE UserId = 1;

SELECT * FROm Users

-- #9
DECLARE @DynamicEXECWithOUTPUT NVARCHAR(MAX) = 
'
  SELECT @OutputVar = COUNT(*) FROM Products WHERE Price > 200
';

DECLARE @OutputVar INT;

EXEC sp_executesql @DynamicEXECWithOUTPUT, N'@OutputVar INT OUTPUT',  @OutputVar OUTPUT

SELECT @OutputVar AS OutParamValue;

-- #10
CREATE TABLE #TempTable 
(
  Name NVARCHAR(100),
  Category NVARCHAR(50),
  Price DECIMAL(10,2)
)

INSERT INTO #TempTable (Name,Category,Price)
EXEC sp_executesql N'SELECT Name,Category,Price FROM Products WHERE Category=@c',
N'@c NVARCHAR(50)',
'Furniture';

SELECT * FROM #TempTable
