-- #1
CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY,
    CustomerName NVARCHAR(100)
);

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY,
    CustomerId INT REFERENCES Customers(CustomerId),
    TotalAmount DECIMAL(10,2),
    OrderDate DATE
);

INSERT INTO Customers VALUES
(1, 'Omg'),
(2, 'I hate thinking of ppl names'),
(3, 'Jesus');

INSERT INTO Orders VALUES
(101,1,120.50,'2024-01-10'),
(102,1,300.00,'2024-02-11'),
(103,2,50.00,'2024-01-20'),
(104,3,900.00,'2024-03-15'),
(105,3,150.00,'2024-03-16'),
(106,1,45.50,'2025-01-10'),
(107,1,67.00,'2025-02-11'),
(108,2,395.00,'2026-01-20');

CREATE FUNCTION dbo.GetOrdersByRange
(
    @CustomerId INT = NULL,
    @MinAmount DECIMAL(10,2),
    @MaxAmount DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Orders
    WHERE TotalAmount BETWEEN @MinAmount AND @MaxAmount AND (@CustomerId IS NULL OR CustomerId = @CustomerId)
);

SELECT * FROM dbo.GetOrdersByRange(3, 50, 200);

-- #2
CREATE FUNCTION dbo.GetLastOrder
(
    @CustomerId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1 OrderId, OrderDate
    FROM Orders
    WHERE CustomerId = @CustomerId
    ORDER BY OrderDate DESC
)

SELECT * FROM GetLastOrder(1);

-- #3
CREATE FUNCTION dbo.GetOrdersCount
(
    @CustomerId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT COUNT(*) as OrdersCount FROM Orders WHERE CustomerId = @CustomerId
)

SELECT * FROM GetOrdersCount(3);

-- #4
CREATE TABLE Orders2 (
    OrderId INT PRIMARY KEY,
    CustomerId INT REFERENCES Customers(CustomerId),
    Status VARCHAR(20),
    TotalAmount DECIMAL(10,2)
);

INSERT INTO Orders2 VALUES
(201,1,'Shipped',100),
(202,1,'Pending',200),
(203,2,'Shipped',300),
(204,2,'Cancelled',50),
(205,3,'Pending',500);

CREATE FUNCTION dbo.GetOrdersByStatus
(
     @Status VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Orders2 WHERE Status = @Status
)

SELECT O.OrderId, O.Status, O.TotalAmount, C.CustomerId, C.CustomerName FROM GetOrdersByStatus('Shipped') O JOIN Customers C ON O.CustomerId = C.CustomerId;

-- #5
CREATE TABLE Payments (
    PaymentId INT PRIMARY KEY,
    CustomerId INT REFERENCES Customers(CustomerId),
    Amount DECIMAL(10,2),
    PaymentDate DATE
);

INSERT INTO Payments VALUES
(1,1,100,'2024-01-15'),
(2,1,50,'2024-02-20'),
(3,2,300,'2024-01-25'),
(4,3,400,'2024-03-17');

CREATE FUNCTION dbo.GetFinancialSummary
(
     @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT  
        o.CustomerId,
        (SELECT COUNT(*)  FROM Orders   WHERE CustomerId = @CustomerId) AS TotalOrders,
        (SELECT COUNT(*)  FROM Payments WHERE CustomerId = @CustomerId) AS TotalPayments,
        (SELECT SUM(TotalAmount) FROM Orders   WHERE CustomerId = @CustomerId) -
        (SELECT SUM(Amount)      FROM Payments WHERE CustomerId = @CustomerId) AS Balance
)

SELECT C.CustomerName, TotalOrders, TotalPayments, Balacne from dbo.GetFinancialSummary(1) Fs INNER JOIN Customers C ON  Fs.CustomerId = C.CustomerId

-- #6
CREATE FUNCTION dbo.GetOrdersCountByYear()
RETURNS @Result TABLE (
    Year INT,
    OrdersCount INT
)
AS
BEGIN
  DECLARE static_cursor CURSOR STATIC FOR SELECT Year(OrderDate) Year FROM Orders;

  OPEN static_cursor;

  DECLARE @PrevYear INT = 1, @Year INT = 1, @OrdersCount INT = 0, @i INT = 0, @Count INT = 0;

  SELECT @Count = COUNT(*) FROM Orders;

  FETCH NEXT FROM static_cursor INTO @Year;

  SET @PrevYear = @Year;

  WHILE @i <= @Count
    BEGIN	  	  
      IF (@PrevYear <> @Year OR @i = @Count)
	  BEGIN
	    INSERT INTO @Result VALUES (@PrevYear, @OrdersCount);
	    SET @PrevYear = @Year;
		SET @OrdersCount = 0;
	  END

	  FETCH NEXT FROM static_cursor INTO @Year;

	  SET @OrdersCount += 1;

	  SET @i += 1;
    END

    CLOSE static_cursor;

    DEALLOCATE static_cursor;

    RETURN;
END;
-- or
ALTER FUNCTION dbo.GetOrdersCountByYear()
RETURNS @Result TABLE (
    Year INT,
    OrdersCount INT
)
AS
BEGIN
    INSERT INTO @Result
    SELECT YEAR(OrderDate) AS Year, COUNT(*)
    FROM Orders
    GROUP BY YEAR(OrderDate);

    RETURN;
END;
Select * from GetOrdersCountByYear();

-- #7
CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY,
    CategoryName NVARCHAR(100),
    ParentId INT NULL REFERENCES Categories(CategoryId)
);

INSERT INTO Categories VALUES
(1, 'Electronics', NULL),
(2, 'Phones', 1),
(3, 'Smartphones', 2),
(4, 'Android Phones', 3),
(5, 'iPhone', 3),
(6, 'Laptops', 1),
(7, 'Gaming Laptops', 6),
(8, 'Ultrabooks', 6);

CREATE FUNCTION dbo.GetCategoriesTree()
RETURNS @Result TABLE (
    Category NVARCHAR(100),
    Tree NVARCHAR(MAX),
	Level INT
)
AS
BEGIN
  WITH CategoriesTree AS
  (
  SELECT CategoryId, CategoryName, Cast (CategoryName as VARCHAR(MAX)) Tree, 0 Level FROM Categories WHERE ParentId IS NULL
  UNION ALL
  SELECT C.CategoryId, C.CategoryName, Cast (Tree + '->' + C.CategoryName as VARCHAR(MAX)), Level + 1 FROM Categories C
  INNER JOIN CategoriesTree CT ON C.ParentId = CT.CategoryId
  )
  INSERT INTO @Result SELECT CategoryName, Tree, Level FROM CategoriesTree;
  RETURN;
END

SELECT * FROM GetCategoriesTree();

-- #8
CREATE FUNCTION dbo.CustomerSummary(@CustomerID INT)
RETURNS @Result TABLE (
    AvgOrderValue DECIMAL(10, 2),
    AvgPayment DECIMAL(10, 2),
    CancellationRate DECIMAL(5,2),
    Top5Orders VARCHAR(MAX),
    Min5Orders VARCHAR(MAX)
)
AS
BEGIN
    DECLARE 
        @AvgOrderValue DECIMAL(10, 2),
        @AvgPayment DECIMAL(10, 2),
        @CancellationRate DECIMAL(5,2),
        @Top5Orders VARCHAR(MAX),
        @Min5Orders VARCHAR(MAX),
        @TotalOrders INT;

    SELECT @AvgOrderValue = AVG(TotalAmount)
    FROM Orders2 WHERE CustomerID = @CustomerID;

    SELECT @AvgPayment = AVG(Amount)
    FROM Payments WHERE CustomerID = @CustomerID;

    SELECT @TotalOrders = COUNT(*) 
    FROM Orders2 WHERE CustomerID = @CustomerID;

    SELECT @CancellationRate = 
        (COUNT(*) * 100.0 / NULLIF(@TotalOrders, 0))
    FROM Orders2 
    WHERE Status = 'Cancelled' AND CustomerID = @CustomerID;

    SELECT @Top5Orders =
        STRING_AGG(CONVERT(VARCHAR(10), OrderId), ',')
    FROM (
        SELECT TOP 5 OrderId
        FROM Orders2
        WHERE CustomerID = @CustomerID
        ORDER BY TotalAmount DESC
    ) AS T;

    SELECT @Min5Orders =
        STRING_AGG(CONVERT(VARCHAR(10), OrderId), ',')
    FROM (
        SELECT TOP 5 OrderId
        FROM Orders2
        WHERE CustomerID = @CustomerID
        ORDER BY TotalAmount ASC
    ) AS T;

    INSERT INTO @Result
    VALUES (@AvgOrderValue, @AvgPayment, @CancellationRate, @Top5Orders, @Min5Orders);

    RETURN;
END

SELECT * FROM CustomerSummary(2)

-- #9
CREATE FUNCTION dbo.CalcTax(@Amount DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
AS
BEGIN
  RETURN CASE
           WHEN @Amount >= 90 THEN @Amount * 0.5
           WHEN @Amount >= 60 THEN @Amount * 0.2
           WHEN @Amount >= 20 THEN @Amount * 0.1
           WHEN @Amount >= 5 THEN @Amount * 0.05
		   ELSE @Amount
         END
END
PRINT dbo.CalcTax(5)

-- #10
CREATE FUNCTION dbo.RemoveDoubleSpaces(@Text NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @TrimedText NVARCHAR(MAX) = TRIM(@Text), @i INT = 1,  @Result NVARCHAR(MAX) = '', @FirstSpace BIT = 0;

  WHILE @i <= LEN(@TrimedText)
  BEGIN
    DECLARE @CurrentChar CHAR(1) = SUBSTRING(@TrimedText, @i, 1);
    IF (@CurrentChar = ' ')
	BEGIN
	  IF @FirstSpace = 0
	    SET @Result += ' ';

	  SET @FirstSpace = 1;
	END
	ELSE
	  SET @FirstSpace = 0;
	 
	IF (@FirstSpace = 0)
	  SET @Result += @CurrentChar;

	SET @i += 1;
  END
  RETURN @Result;
END

-- or
ALTER FUNCTION dbo.RemoveDoubleSpaces(@Text NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    WHILE CHARINDEX('  ', @Text) > 0
        SET @Text = REPLACE(@Text, '  ', ' ');
    RETURN TRIM(@Text);
END

PRINT dbo.RemoveDoubleSpaces('   Hello  how are     u    ');
PRINT LEN(dbo.RemoveDoubleSpaces('   Hello  how are     u    '));
