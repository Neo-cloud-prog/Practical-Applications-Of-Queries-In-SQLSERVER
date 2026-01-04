-- #1
CREATE TABLE Transactions (
    TransactionId INT PRIMARY KEY,
    CustomerId INT,
    Amount DECIMAL(10,2),
    CreatedAt DATETIME
);

INSERT INTO Transactions VALUES
(1, 100, 50.00, '2025-12-01 08:01'),
(2, 101, 75.25, '2025-12-01 08:05'),
(3, 100, 20.00, '2025-12-01 08:10'),
(4, 102, 150.00, '2025-12-01 08:12'),
(5, 100, 5.00, '2025-12-01 08:20');

DECLARE @Summary Table 
(
  CustomerId INT,
  TotalAmount DECIMAL(10,2)
)

DECLARE static_cursor CURSOR STATIC FOR
SELECT CustomerId, Amount FROM dbo.Transactions;

OPEN static_cursor;

DECLARE @CustomerId int, @Amount DECIMAL(10,2);

FETCH NEXT FROM static_cursor INTO @CustomerId, @Amount;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM @Summary WHERE CustomerId = @CustomerId) 
	  INSERT INTO @Summary VALUES (@CustomerId, @Amount);
	ELSE 
	  UPDATE @Summary SET TotalAmount += @Amount WHERE CustomerId = @CustomerId;
    FETCH NEXT FROM static_cursor INTO @CustomerId, @Amount;
END

CLOSE static_cursor;

DEALLOCATE static_cursor;

SELECT * FROM @Summary;

-- #2
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY,
    CustomerId INT,
    Status VARCHAR(20),
    UpdatedAt DATETIME
);

INSERT INTO Orders VALUES
(1001, 100, 'Pending', '2025-12-01 09:00'),
(1002, 101, 'Pending', '2025-12-01 09:02'),
(1003, 102, 'Pending', '2025-12-01 09:05'),
(1004, 103, 'Pending', '2025-12-01 09:06');


DECLARE dynamic_cursor CURSOR DYNAMIC FOR
SELECT OrderId, Status FROM Orders WHERE Status = 'Pending';

OPEN dynamic_cursor;

DECLARE @OrderID int, @Status VARCHAR(20);

UPDATE Orders SET Status = 'Approved' WHERE OrderId = 1003

FETCH NEXT FROM dynamic_cursor INTO @OrderID, @Status;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF (@Status <> 'Pending')
	  PRINT 'This order is ignored';
	ELSE
	  PRINT 'Order id = ' + CAST(@OrderID AS VARCHAR) + ' Status = ' + @Status
    FETCH NEXT FROM dynamic_cursor INTO @OrderID, @Status;
END

CLOSE dynamic_cursor;

DEALLOCATE dynamic_cursor;

-- #3
CREATE TABLE ImportedUsers (
    ImportId INT PRIMARY KEY,
    FullName NVARCHAR(200),
    Email NVARCHAR(200)
);

INSERT INTO ImportedUsers VALUES
(1, 'Abdulah bomb', 'bom@example.com'),
(2, 'Nigga Smith', 'blackmail@example.com'),
(3, 'Lee chon chin hon chanines japones chan tea', 'screamingAtRestaurentItadakimas@example.com');

CREATE TABLE Users (
    UserId INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200),
    Email NVARCHAR(200)
);

CREATE TABLE ImportLog (
    LogId INT IDENTITY PRIMARY KEY,
    ImportId INT,
    UserId INT,
    Status NVARCHAR(50),
    LogTime DATETIME DEFAULT GETDATE()
);

DECLARE forward_only_cursor CURSOR STATIC FORWARD_ONLY FOR
SELECT ImportId, FullName, Email FROM dbo.ImportedUsers;

OPEN forward_only_cursor;

DECLARE @ImportId INT, @FullName NVARCHAR(50), @Email NVARCHAR(200);

FETCH NEXT FROM forward_only_cursor INTO @ImportId, @FullName, @Email;

WHILE @@FETCH_STATUS = 0
BEGIN
  INSERT INTO Users VALUES(@FullName, @Email);
  INSERT INTO ImportLog(ImportId, UserId, Status) VALUES(@ImportId, SCOPE_IDENTITY(), 'Inserted')
  FETCH NEXT FROM forward_only_cursor INTO @ImportId, @FullName, @Email;
END

CLOSE forward_only_cursor;

DEALLOCATE forward_only_cursor;

SELECT * FROM Users

SELECT * FROM ImportLog

-- #4
CREATE TABLE EmployeeSalaries (
    EmployeeId INT PRIMARY KEY,
    Name NVARCHAR(100),
    Salary INT
);

INSERT INTO EmployeeSalaries VALUES
(1, 'human1',    4000),
(2, 'human2',   4500),
(3, 'human3',   4800),
(4, 'human4',   5000),
(5, 'human5',   5200),
(6, 'human6',   5500),
(7, 'Adel',   6000),
(8, 'Lina',   6200),
(9, 'jack jerker', 7000);

DECLARE @Id INT, @Name NVARCHAR(100), @Salary INT;

DECLARE salary_cursor SCROLL CURSOR FOR
    SELECT EmployeeId, Name, Salary
    FROM EmployeeSalaries
    ORDER BY Salary;

OPEN salary_cursor;

FETCH ABSOLUTE 5 FROM salary_cursor INTO @Id, @Name, @Salary;
PRINT '1) ABSOLUTE 5 -> ' + @Name + ' | ' + CAST(@Salary AS VARCHAR);

FETCH PRIOR FROM salary_cursor INTO @Id, @Name, @Salary;
PRINT '2) PRIOR      -> ' + @Name + ' | ' + CAST(@Salary AS VARCHAR);

FETCH RELATIVE 2 FROM salary_cursor INTO @Id, @Name, @Salary;
PRINT '3) RELATIVE 2 -> ' + @Name + ' | ' + CAST(@Salary AS VARCHAR);

FETCH ABSOLUTE 3 FROM salary_cursor INTO @Id, @Name, @Salary;
PRINT '4) ABSOLUTE 3 -> ' + @Name + ' | ' + CAST(@Salary AS VARCHAR);

CLOSE salary_cursor;

DEALLOCATE salary_cursor;

-- #5
CREATE TABLE Employees (
    EmpId INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Salary INT
);

INSERT INTO Employees VALUES
(1, 'tired', 4000),
(2, 'human1', 5000),
(3, 'Adel2', 4500);

CREATE TABLE Employees_Import (
    EmpId INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Salary INT
);

INSERT INTO Employees_Import VALUES
(1, 'fuck life', 4200),
(3, 'running out of names', 4500),
(4, 'Maya', 3800);


MERGE INTO Employees AS Target
USING Employees_Import AS Source
ON Target.EmpId = Source.EmpId

WHEN MATCHED AND (Target.FullName <> Source.FullName OR Target.Salary <> Source.Salary)
    THEN UPDATE SET
        Target.FullName = Source.FullName,
        Target.Salary = Source.Salary

WHEN NOT MATCHED BY TARGET
    THEN INSERT (EmpId, FullName, Salary)
         VALUES (Source.EmpId, Source.FullName, Source.Salary)

WHEN NOT MATCHED BY SOURCE
    THEN DELETE;