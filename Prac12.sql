-- data
CREATE TABLE Employees (
    EmpId INT,
    Name VARCHAR(100),
    Dept VARCHAR(50),
    Salary INT,
    HireDate DATE
);
GO;
INSERT INTO Employees VALUES
(1, 'nono', 'IT', 7000, '2023-01-10'),
(2, 'runy', 'IT', 9000, '2022-11-01'),
(3, 'jaja', 'IT', 9000, '2023-04-05'),
(4, 'human', 'HR', 6000, '2023-03-02'),
(5, 'human2', 'HR', 6000, '2023-03-03'),
(6, 'human3', 'HR', 8500, '2022-02-10'),
(7, 'huwomen1', 'Sales', 5000, '2023-01-05'),
(8, 'huwomen2', 'Sales', 4000, '2023-01-15'),
(9, 'hudog1', 'Sales', 6500, '2022-07-22');

GO;

-- #1
WITH RankedEmployees AS
(
  SELECT *, ROW_NUMBER() OVER (PARTITION BY Dept ORDER BY Salary DESC, HireDate) Rn FROM Employees
)
SELECT * FROM RankedEmployees WHERE Rn = 1
-- or
SELECT e.*
FROM Employees e
JOIN (
    SELECT Dept, MAX(Salary) MaxSalary
    FROM Employees
    GROUP BY Dept
) x ON e.Dept = x.Dept AND e.Salary = x.MaxSalary;

-- #2
WITH RankedAndDenseRankedEmployees AS
(
  SELECT *, RANK() OVER (ORDER BY Salary DESC, EmpId) Rank, DENSE_RANK() OVER (ORDER BY Salary DESC, EmpId) DenseRank FROM Employees
)
SELECT *, Rank - DenseRank DIFF FROM RankedAndDenseRankedEmployees

-- #3
SELECT *, RANK() OVER (PARTITION BY Dept ORDER BY Salary DESC) RankInDept FROM Employees

-- #4
SELECT *, 
SUM(Salary) OVER (PARTITION BY Dept) TotaSum, 
AVG(Salary) OVER (PARTITION BY Dept) TotalAvg,  
MAX(Salary) OVER (PARTITION BY Dept) MaxSalary,
MIN(Salary) OVER (PARTITION BY Dept) MinSalary
FROM Employees

-- #5
SELECT *,
Salary - LAG(Salary, 1) OVER (PARTITION BY Dept ORDER BY HireDate) AS SalaryDiff
FROM Employees;

-- #6
SELECT *, 
LEAD(Name, 1) OVER (PARTITION BY Dept ORDER BY HireDate) NextEmployee
FROM Employees

-- #7
SELECT *,
SUM(Salary) OVER (PARTITION BY Dept ORDER BY HireDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningSalary
FROM Employees;

-- #8
DECLARE @PageNumber AS INT, @RowsPerPage AS INT;
SET @PageNumber = 2;
SET @RowsPerPage = 3;

SELECT *
FROM Employees
ORDER BY EmpId
OFFSET (@PageNumber - 1) * @RowsPerPage ROWS
FETCH NEXT @RowsPerPage ROWS ONLY;

-- #9
SELECT *, AVG(Salary) OVER () AvgSalary, IIF(Salary > AVG(Salary) OVER (), 1, 0) FROM Employees
-- or
SELECT *,
       avg_salary,
       CASE
           WHEN Salary > avg_salary THEN '>'
           WHEN Salary < avg_salary THEN '<'
           ELSE '='
       END AS CompareToAvg
FROM (
    SELECT *,
           AVG(Salary) OVER () AS avg_salary
    FROM Employees
) x;

-- #10
WITH NumberedEmployees AS
(
  SELECT *, ROW_NUMBER() OVER (PARTITION BY Name, Dept ORDER BY HireDate) Rn FROM Employees
)
SELECT * FROM NumberedEmployees WHERE Rn = 1

-- #11
WITH RankedEmployees AS
(
  SELECT *, ROW_NUMBER() OVER (PARTITION BY Dept ORDER BY Salary DESC, HireDate) Rn FROM Employees
)
SELECT * FROM RankedEmployees WHERE Rn = 1

-- #12
SELECT e.*
FROM Employees d
CROSS APPLY (
    SELECT TOP 1 *
    FROM Employees e
    WHERE e.Dept = d.Dept
    ORDER BY Salary DESC, HireDate
) e;