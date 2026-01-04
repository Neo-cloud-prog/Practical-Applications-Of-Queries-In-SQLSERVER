-- #1
CREATE FUNCTION dbo.GetCategoriesTree()
RETURNS TABLE
AS
RETURN
(
    WITH C AS (
        SELECT 
            CategoryId,
            CategoryName,
            ParentId,
            CAST(CategoryName AS NVARCHAR(MAX)) AS Path,
            0 AS Level
        FROM Categories
        WHERE ParentId IS NULL

        UNION ALL

        SELECT 
            c.CategoryId,
            c.CategoryName,
            c.ParentId,
            CAST(p.Path + ' > ' + c.CategoryName AS NVARCHAR(MAX)),
            p.Level + 1
        FROM Categories c
        JOIN C p ON c.ParentId = p.CategoryId
    )
    SELECT CategoryId, CategoryName, ParentId, Path, Level
    FROM C
);

SELECT * FROM GetCategoriesTree();

-- #2
WITH EmployeeTreeHierarchy AS (
    SELECT EmployeeID, 
	ManagerID, Name, 
	CAST(Name AS VARCHAR(MAX)) AS 'Hierarchy', 0 AS Level
    FROM Employees7
    WHERE ManagerID IS NULL

    UNION ALL

    SELECT e.EmployeeID, e.ManagerID, e.Name, 
    CAST(ETH.Hierarchy + ' -> ' + e.Name + '(' + CAST(e.EmployeeID AS VARCHAR(10)) + ')'),
	ETH.Level + 1 AS Level
    FROM Employees7 e
    INNER JOIN EmployeeTreeHierarchy ETH ON e.ManagerID = ETH.EmployeeID
)
SELECT * FROM EmployeeTreeHierarchy
ORDER BY Hierarchy;


-- #3
CREATE TABLE Attendance (
    EmpId INT,
    WorkDate DATE,
    HoursWorked INT
);

INSERT INTO Attendance VALUES
(1, '2025-01-02', 7),
(1, '2025-01-05', 8),
(1, '2025-01-11', 6),
(1, '2025-01-15', 9),
(2, '2025-01-03', 8),
(2, '2025-01-04', 7);
 
DECLARE @Start DATE = '2025-01-01';
DECLARE @End   DATE = '2025-01-31';

WITH Dates AS (
    SELECT @Start AS d
    UNION ALL
    SELECT DATEADD(DAY,1,d)
    FROM Dates
    WHERE d < @End
)
SELECT d AS WorkDate, e.EmpId, a.HoursWorked
FROM Dates
CROSS JOIN (SELECT DISTINCT EmpId FROM Attendance) e
LEFT JOIN Attendance a 
    ON a.EmpId = e.EmpId AND a.WorkDate = d
ORDER BY e.EmpId, d
OPTION (MAXRECURSION 1000);

-- #4
CREATE TABLE Customers2 (
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20)
);

INSERT INTO Customers2 VALUES
(1, 'Salim shady muslim emenime', 'ali@gmail.com', '111'),
(2, 'neo foka', 'ali@gmail.com', '222'),
(3, 'Aisha', 'ALI@gmail.com', '333'),
(4, 'Somo', 'sarah@gmail.com', '555'),
(5, 'fine', 'sarah@gmail.com', '555'),
(6, 'jeck', 'omar@gmail.com', '999');

WITH DuplicateEmails AS
(
  SELECT COUNT(*) T, Email FROM Customers2 GROUP BY Email HAVING COUNT(*) > 1
)
SELECT CustomerId, FullName, DuplicateEmails.Email FROM Customers2 INNER JOIN DuplicateEmails ON Customers2.Email = DuplicateEmails.Email

WITH Dups AS (
    SELECT CustomerId, Email,
           ROW_NUMBER() OVER(PARTITION BY Email ORDER BY CustomerId) AS RN
    FROM Customers2
)
SELECT * FROM Dups WHERE RN > 1;

WITH D AS (
    SELECT 
        CustomerId,
        FullName,
        LOWER(Email) AS EmailNormalized
    FROM Customers2
),
Dup AS (
    SELECT EmailNormalized
    FROM D
    GROUP BY EmailNormalized
    HAVING COUNT(*) > 1
)
SELECT d.*
FROM D
JOIN Dup dp ON d.EmailNormalized = dp.EmailNormalized;

-- #5
CREATE TABLE Sales (
    SaleId INT PRIMARY KEY,
    ProductId INT,
    SaleDate DATE,
    Amount DECIMAL(10,2)
);

INSERT INTO Sales VALUES
(1, 100, '2025-01-01', 500),
(2, 100, '2025-01-02', 300),
(3, 101, '2025-01-01', 200),
(4, 101, '2025-01-03', 900),
(5, 102, '2025-01-01', 150),
(6, 102, '2025-01-02', 450),
(7, 100, '2025-01-03', 700),
(8, 102, '2025-01-05', 800),
(9, 103, '2025-01-02', 50);

WITH RankedProductes AS
(
  SELECT ProductId, SUM(Amount) TotalSales, DENSE_RANK() OVER(ORDER BY SUM(Amount) DESC) RankOrder FROM Sales GROUP BY ProductId
)
SELECT * FROM RankedProductes

-- #6
CREATE TABLE InventoryMovements (
    MovementId INT PRIMARY KEY,
    ProductId INT,
    MovementDate DATE,
    MovementType VARCHAR(10),
    Quantity INT
);

INSERT INTO InventoryMovements VALUES
(1, 10, '2025-01-01', 'IN', 100),
(2, 10, '2025-01-02', 'OUT', 30),
(3, 10, '2025-01-03', 'OUT', 20),
(4, 10, '2025-01-04', 'IN', 50),
(5, 10, '2025-01-05', 'OUT', 60),
(6, 11, '2025-01-01', 'IN', 200),
(7, 11, '2025-01-03', 'OUT', 40);

WITH M AS (
    SELECT 
        MovementId,
        ProductId,
        MovementDate,
        CASE 
            WHEN MovementType = 'IN' THEN Quantity
            ELSE -Quantity
        END AS QtySigned
    FROM InventoryMovements
),
R AS (
    SELECT 
        ProductId,
        MovementId,
        MovementDate,
        QtySigned,
        SUM(QtySigned) OVER (
            PARTITION BY ProductId
            ORDER BY MovementDate, MovementId
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningBalance
    FROM M
)
SELECT * FROM R;