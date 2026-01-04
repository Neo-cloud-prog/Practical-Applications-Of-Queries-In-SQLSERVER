-- #1
CREATE TABLE Customers(
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(200),
    Email NVARCHAR(200)
);
-- finally i will name ppl using colors 
INSERT INTO Customers VALUES
(1, 'Brown', 'alice@mail.com'),
(2, 'Purple', 'john@mail.com');


CREATE TABLE Products(
    ProductId INT PRIMARY KEY,
    Name NVARCHAR(200),
    Price DECIMAL(10,2),
    Stock INT
);

INSERT INTO Products VALUES
(1, 'Keyboard', 30.00, 10),
(2, 'Mouse', 15.00, 20),
(3, 'Monitor', 120.00, 5);


CREATE TABLE Orders(
    OrderId INT IDENTITY PRIMARY KEY,
    CustomerId INT,
    Total DECIMAL(10,2),
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE OrderItems(
    OrderItemId INT IDENTITY PRIMARY KEY,
    OrderId INT,
    ProductId INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE OrderLogs(
    LogId INT IDENTITY PRIMARY KEY,
    Message NVARCHAR(300),
    LogDate DATETIME DEFAULT GETDATE()
);


CREATE TYPE OrderItemType AS TABLE(
    ProductId INT,
    Quantity INT
);

go;

CREATE PROCEDURE CreateOrder
(
    @CustomerId INT,
    @Items OrderItemType READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerId = @CustomerId)
        BEGIN
            RAISERROR('Customer does not exist.', 16, 1);
        END

        IF EXISTS (
            SELECT 1
            FROM @Items i
            LEFT JOIN Products p ON p.ProductId = i.ProductId
            WHERE p.ProductId IS NULL
        )
        BEGIN
            RAISERROR('One or more products do not exist.', 16, 1);
        END

        IF EXISTS (
            SELECT 1
            FROM @Items i
            JOIN Products p ON p.ProductId = i.ProductId
            WHERE p.Stock < i.Quantity
        )
        BEGIN
            RAISERROR('Insufficient stock for one or more products.', 16, 1);
        END

        DECLARE @Total DECIMAL(10,2);

        SELECT @Total = SUM(i.Quantity * p.Price)
        FROM @Items i
        JOIN Products p ON p.ProductId = i.ProductId;

        INSERT INTO Orders (CustomerId, Total)
        VALUES (@CustomerId, @Total);

        DECLARE @OrderId INT = SCOPE_IDENTITY();

        INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice)
        SELECT @OrderId, i.ProductId, i.Quantity, p.Price
        FROM @Items i
        JOIN Products p ON p.ProductId = i.ProductId;

        UPDATE p
        SET p.Stock = p.Stock - i.Quantity
        FROM Products p
        JOIN @Items i ON p.ProductId = i.ProductId;

        INSERT INTO OrderLogs (Message)
        VALUES ('Order created successfully. OrderId=' + CAST(@OrderId AS NVARCHAR(20)));

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;

        INSERT INTO OrderLogs (Message)
        VALUES ('ERROR: ' + ERROR_MESSAGE());

        THROW;
    END CATCH
END

go;

DECLARE @Items OrderItemType;

INSERT INTO @Items VALUES
(1, 2), -- 2 Keyboards
(2, 1); -- 1 Mouse

EXEC CreateOrder 1, @Items;

select * from Orders

select * from OrderItems

select * from Products

select * from OrderLogs

-- #2
CREATE TABLE Employees(
    EmployeeId INT PRIMARY KEY,
    FullName NVARCHAR(200),
    BaseSalary DECIMAL(10,2)
);

INSERT INTO Employees VALUES
(1, 'Mark shit', 3000),
(2, 'Alkantara Adams', 2800),
(3, 'David human', 3500);


CREATE TABLE PerformanceRating(
    EmployeeId INT,
    Rating INT, -- 1 to 5
    Month INT,
    Year INT
);

INSERT INTO PerformanceRating VALUES
(1, 5, 1, 2025),
(2, 3, 1, 2025),
(3, 4, 1, 2025);


CREATE TABLE SalaryHistory(
    HistoryId INT IDENTITY PRIMARY KEY,
    EmployeeId INT,
    FinalSalary DECIMAL(10,2),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO;
CREATE Procedure CalcualteEmployeeSalary
(@EmployeeID int, @Hours int, @Deduction int)
AS
Begin
   BEGIN TRY
        BEGIN TRANSACTION;
		  DECLARE @BaseSalary DECIMAL(10, 2);
		  SELECT @BaseSalary = BaseSalary FROM Employees WHERE EmployeeId = @EmployeeID;

		  DECLARE @Rating INT;
		  SELECT @Rating = Rating FROM PerformanceRating WHERE (MONTH(GETDATE()) = Month and YEAR(GETDATE()) = Year) and EmployeeId = @EmployeeID;

		  DECLARE @Bonus DECIMAL(10,2);
		  SET @Bonus = CASE
		                 WHEN @Rating = 5 THEN @BaseSalary * 0.2
		                 WHEN @Rating = 4 THEN @BaseSalary * 0.1
		                 WHEN @Rating = 3 THEN @BaseSalary * 0.05
						 ELSE 0
		               END
		  DECLARE @PricePerHour DECIMAL(10, 2) = 20;

		  DECLARE @Overtime DECIMAL(10, 2) = @Hours * @PricePerHour;

		  DECLARE @FinalSalary DECIMAL(10, 2) = @BaseSalary + @Bonus + @Overtime - @Deduction;

		  INSERT INTO SalaryHistory(EmployeeId, FinalSalary) VALUES (@EmployeeID, @FinalSalary);

		  IF (@@ROWCOUNT = 0)
		    THROW 50000, 'Faild to add FinalSalary to SalaryHistory', 1;

		COMMIT TRANSACTION;
   END TRY
   BEGIN CATCH
     ROLLBACK TRANSACTION;
   END CATCH
End

EXEC CalcualteEmployeeSalary 1, 10, 70;

Select * from Employees;
Select * from PerformanceRating;
Select * from SalaryHistory;

-- #3
CREATE TABLE HotelCustomers(
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(150)
);

INSERT INTO HotelCustomers VALUES
(1, 'Stone'),
(2, 'mr hamlton VII');


CREATE TABLE Rooms(
    RoomId INT PRIMARY KEY,
    RoomNumber INT,
    PricePerNight DECIMAL(10,2)
);

INSERT INTO Rooms VALUES
(1, 101, 60),
(2, 102, 80),
(3, 201, 120);


CREATE TABLE Reservations(
    ReservationId INT IDENTITY PRIMARY KEY,
    CustomerId INT,
    RoomId INT,
    StartDate DATE,
    EndDate DATE,
    Total DECIMAL(10,2)
);

go;
CREATE PROCEDURE CreateReservation
(@CustomerId INT, @RoomId INT, @StartDate DATE, @EndDate DATE)
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
	  IF NOT EXISTS (select top 1 1 from HotelCustomers where CustomerId = @CustomerId)
	    THROW 50000, 'Customer dose not exits', 1; 
	  IF EXISTS (select top 1 1 from  Reservations where RoomId = @RoomId AND @StartDate BETWEEN StartDate AND EndDate)
	  	THROW 50001, 'The room is booked for the same period', 1; 

	  DECLARE @Total int;

	  SELECT @Total = PricePerNight * (DATEDIFF(DAY, @StartDate, @EndDate)) FROM Rooms WHERE RoomId = @RoomId;

	  INSERT INTO Reservations VALUES(@CustomerId, @RoomId, @StartDate, @EndDate, @Total);
	COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
	PRINT ERROR_MESSAGE();
	THROW;
  END CATCH
END

EXEC CreateReservation 2, 1, '12/6/2022', '12/7/2022'

select * from Reservations

-- #4
CREATE TABLE LoyaltyCustomers(
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(200),
    Points INT DEFAULT 0
);

INSERT INTO LoyaltyCustomers VALUES
(1, 'Jesica oklahoma', 0),
(2, 'Lana white', 0);


CREATE TABLE Purchases(
    PurchaseId INT IDENTITY PRIMARY KEY,
    CustomerId INT,
    Amount DECIMAL(10,2),
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE PointsTransactions(
    TransactionId INT IDENTITY PRIMARY KEY,
    CustomerId INT,
    PointsAdded INT,
    Reset BIT,
    TransactionTime DATETIME DEFAULT GETDATE()
);
go;
CREATE PROCEDURE CreatePurchase 
(@CustomerId int, @Amount DECIMAL(10,2))
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION
	    INSERT INTO Purchases(CustomerId, Amount) VALUES
        (@CustomerId, @Amount);

		IF (@@ROWCOUNT = 0)
		  THROW 50000, 'Purchase not completed', 1

        DECLARE @Points int;
        SET @Points = CASE 
                  WHEN @Amount > 90 THEN 50
                  WHEN @Amount > 80 THEN 30
                  WHEN @Amount > 70 THEN 20
                  WHEN @Amount > 30 THEN 15
                  WHEN @Amount > 20 THEN 10
				  ELSE  1
			    END;

        DECLARE @RESET BIT;

        SELECT @RESET = CASE 
                    WHEN (Points + @Points) >= 100 then 1  
                    ELSE 0
	              END 
				  from LoyaltyCustomers where @CustomerId = CustomerId;

       UPDATE LoyaltyCustomers SET Points = CASE 
                                         WHEN @RESET = 1 then 0  
										 ELSE Points + @Points
										 END
       WHERE @CustomerId = CustomerId;

	   IF (@@ROWCOUNT = 0)
		  THROW 50001, 'Update Loyal points not completed', 1;

       INSERT INTO PointsTransactions (CustomerId, PointsAdded, Reset) VALUES(@CustomerId, @Points, @RESET)

	   IF (@@ROWCOUNT = 0)
		  THROW 50002, 'Update Loyal points not completed', 1;
	COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
  END CATCH
END

EXEC CreatePurchase 1, 25;

Select * from Purchases;

Select * from LoyaltyCustomers;

Select * from PointsTransactions;
