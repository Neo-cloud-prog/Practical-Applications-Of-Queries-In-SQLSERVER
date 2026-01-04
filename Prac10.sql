-- #1
CREATE TABLE Accounts (
    AccountId INT PRIMARY KEY,
    Balance DECIMAL(18,2)
);

CREATE TABLE BalanceAudit (
    LogId INT IDENTITY PRIMARY KEY,
    AccountId INT,
    OldBalance DECIMAL(18,2),
    NewBalance DECIMAL(18,2),
    ChangedAt DATETIME DEFAULT GETDATE()
);

INSERT INTO Accounts VALUES
(1, 5000), (2, 300), (3, 10000);

CREATE TRIGGER trg_AfterUpdateBalance ON Accounts
AFTER UPDATE
AS
BEGIN
  INSERT INTO BalanceAudit(AccountId, OldBalance, NewBalance)
  SELECT i.AccountId, d.Balance AS OldBalance, i.Balance AS NewBalance
  FROM inserted i
  INNER JOIN deleted d ON i.AccountId = d.AccountId AND i.Balance <> d.Balance;
END;

UPDATE Accounts SET Balance = 5000 WHERE AccountId = 1 or AccountId = 2

SELECT * FROM BalanceAudit

-- #2
CREATE TABLE Invoices (
    InvoiceId INT PRIMARY KEY,
    Amount DECIMAL(10,2),
    CreatedAt DATE,
	IsDeleted BIT DEFAULT 0
);

INSERT INTO Invoices VALUES
(100, 500, '2024-01-01', 0),
(101, 900, '2024-02-01', 0),
(102, 485, '2024-03-01', 0);

CREATE TRIGGER trg_InsteadOfDeleteInvoices ON Invoices
INSTEAD OF DELETE
AS
BEGIN
  UPDATE Invoices SET IsDeleted = 1 FROM Invoices I INNER JOIN deleted ON I.InvoiceId = deleted.InvoiceId AND I.IsDeleted <> 1;
END;

DELETE FROM Invoices WHERE InvoiceId = 100 OR InvoiceId = 102

SELECT * FROM Invoices

-- #3
CREATE TABLE Employees (
    EmpId INT PRIMARY KEY,
    FullName VARCHAR(50),
    NationalId VARCHAR(20),
    Salary DECIMAL(10,2)
);

INSERT INTO Employees VALUES
(1, 'Again', 'A123456', 3000),
(2, 'shit', 'B999999', 5000);

CREATE TRIGGER trg_InsteadOfUpdateNationalIdOrSalary ON Employees
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.EmpId = d.EmpId
        WHERE i.NationalId <> d.NationalId
           OR i.Salary <> d.Salary
    )
        THROW 50000, 'You cannot update NationalId or Salary', 1;

    UPDATE Employees
    SET FullName = i.FullName
    FROM Employees e
    JOIN inserted i ON e.EmpId = i.EmpId;
END;

UPDATE Employees SET FullName = 'Bosko', NationalId = '22' WHERE EmpID = 1
SELECT * FROM Employees

-- #4
CREATE TABLE Products (
    ProductId INT PRIMARY KEY,
    Name VARCHAR(50),
    Stock INT
);

CREATE TABLE OrderItems (
    OrderItemId INT PRIMARY KEY,
    ProductId INT,
    Quantity INT
);

INSERT INTO Products VALUES
(1,'Laptop',5),(2,'Mouse',100),(3,'Banana',0);

CREATE TRIGGER trg_InsteadOfInsertOrderItem ON OrderItems
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Products p ON i.ProductId = p.ProductId
        WHERE i.Quantity > p.Stock
    )
        THROW 50000, 'Quantity exceeds stock', 1;

    INSERT INTO OrderItems(OrderItemId, ProductId, Quantity)
    SELECT OrderItemId, ProductId, Quantity FROM inserted;
END;


INSERT INTO OrderItems VALUES (1, 1, 2)
INSERT INTO OrderItems VALUES (2, 1, 6)
SELECT * FROM OrderItems

-- #5
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY,
    Total DECIMAL(10,2),
    Tax DECIMAL(10,2),
    NetAmount DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    DetailId INT PRIMARY KEY,
    OrderId INT,
    Price DECIMAL(10,2),
    Quantity INT
);

INSERT INTO OrderDetails VALUES
(1,1,100,2),(2,1,50,1),(3,2,10,5);

CREATE TRIGGER trg_AfterInsertOrder ON Orders
AFTER INSERT
AS
BEGIN
    UPDATE o
    SET Total = x.Total,
        Tax = x.Tax,
        NetAmount = x.Net
    FROM Orders o
    JOIN (
        SELECT d.OrderId,
               SUM(d.Price * d.Quantity) AS Total,
               SUM(d.Price * d.Quantity) * 0.15 AS Tax,
               SUM(d.Price * d.Quantity) * 1.15 AS Net
        FROM OrderDetails d
        JOIN inserted i ON d.OrderId = i.OrderId
        GROUP BY d.OrderId
    ) x ON x.OrderId = o.OrderId;
END;

CREATE TRIGGER trg_AfterUpdateOrderDetails ON OrderDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE o
    SET Total = x.Total,
        Tax = x.Tax,
        NetAmount = x.Net
    FROM Orders o
    JOIN (
        SELECT d.OrderId,
               SUM(d.Price * d.Quantity) AS Total,
               SUM(d.Price * d.Quantity) * 0.15 AS Tax,
               SUM(d.Price * d.Quantity) * 1.15 AS Net
        FROM OrderDetails d
        GROUP BY d.OrderId
    ) x ON x.OrderId = o.OrderId;
END;


insert into Orders VALUES(1, 0, 0 ,0), (2, 0, 0 ,0);
delete from Orders
SELECT * FROM OrderDetails
SELECT * FROM Orders

-- #6
CREATE TABLE Departments (
    DeptId INT PRIMARY KEY,
    Name VARCHAR(50)
);

CREATE TABLE Employees2 (
    EmpId INT PRIMARY KEY,
    DeptId INT,
    FullName VARCHAR(50)
);

INSERT INTO Departments VALUES (10,'IT'),(20,'HR');

CREATE TRIGGER trg_AfterInsertEmployee ON Employees2
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN Departments d ON i.DeptId = d.DeptId
        WHERE d.DeptId IS NULL
    )
        THROW 50000, 'Department does not exist', 1;
END;
-- or
ALTER TRIGGER trg_AfterInsertEmployee ON Employees2
AFTER INSERT
AS
BEGIN
  IF ((SELECT COUNT(*) FROM inserted) <> (SELECT COUNT(*) FROM inserted i inner join Departments d ON i.DeptId = d.DeptId))
    THROW 50000, 'Department not exists', 1;
END;

INSERT INTO Employees2 VALUES (1, 10, 'E1'), (2, 20, 'E2')

SELECT * FROM Employees2

-- #7
CREATE TABLE Product2 (
    ProductId INT PRIMARY KEY,
    Name VARCHAR(20),
    Category VARCHAR(20)
);

CREATE TABLE Sales (
    SaleId INT PRIMARY KEY,
    ProductId INT,
    Amount INT
);

INSERT INTO Product2 VALUES (1,'Laptop','Electronics'), (2,'Apple','Food');
INSERT INTO Sales VALUES (1,1,3);

CREATE TRIGGER trg_AfterUpdateCategory ON Product2
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.ProductId = d.ProductId
        WHERE i.Category <> d.Category
        AND EXISTS (SELECT 1 FROM Sales s WHERE s.ProductId = i.ProductId)
    )
        THROW 50000, 'Cannot change category for a product that has sales', 1;
END;


UPDATE Product2 SET Category = 'Electronics2' WHERE ProductId = 1
SELECT * FROM Product2

-- #8
CREATE TABLE Users (
    UserId INT PRIMARY KEY,
    FullName VARCHAR(50)
);

CREATE TABLE DeletedUsers (
    UserId INT,
    FullName VARCHAR(50),
    DeletedAt DATETIME DEFAULT GETDATE()
);

INSERT INTO Users VALUES (1,'Ali'),(2,'Mona');

CREATE TRIGGER trg_AfterDeleteUsers ON Users
AFTER DELETE
AS
BEGIN
  INSERT INTO DeletedUsers(UserId, FullName) SELECT UserId, FullName FROM deleted;
END;

SELECT * FROM Users
DELETE FROM Users
SELECT * FROM DeletedUsers

-- #9
CREATE TABLE Rooms (
    RoomId INT PRIMARY KEY,
    Capacity INT,
    CurrentOccupancy INT
);

CREATE TABLE Bookings (
    BookingId INT PRIMARY KEY,
    RoomId INT,
    PeopleCount INT
);

INSERT INTO Rooms VALUES (1,5,2),(2,10,7);

CREATE TRIGGER trg_InsteadOfInsertBooking ON Bookings
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Rooms r ON i.RoomId = r.RoomId
        WHERE r.CurrentOccupancy + i.PeopleCount > r.Capacity
    )
        THROW 50000, 'Room capacity exceeded', 1;

    INSERT INTO Bookings(BookingId, RoomId, PeopleCount)
    SELECT BookingId, RoomId, PeopleCount FROM inserted;

    UPDATE Rooms
    SET CurrentOccupancy = CurrentOccupancy + i.PeopleCount
    FROM Rooms r
    JOIN inserted i ON r.RoomId = i.RoomId;
END;

INSERT INTO Bookings VALUES (1,1,3),(2,2,2);

SELECT * FROM Bookings

-- #10
CREATE TABLE DimCustomer (
    CustomerId INT,
    Name VARCHAR(50),
    Version INT NULL DEFAULT 0
);

CREATE TRIGGER trg_InsteadOfUpdateCustomers ON DimCustomer
INSTEAD OF Update
AS
BEGIN
  INSERT INTO DimCustomer(CustomerId, Name, Version) SELECT d.CustomerId, i.Name, d.Version + 1 FROM inserted i
  JOIN deleted d ON i.CustomerId = d.CustomerId
END

INSERT INTO DimCustomer(CustomerId, Name, Version) VALUES (1,'Ali', 1);

UPDATE DimCustomer SET Name = 'Ali2' WHERE Name = 'Ali'

SELECT * FROM DimCustomer

DELETE FROM DimCustomer