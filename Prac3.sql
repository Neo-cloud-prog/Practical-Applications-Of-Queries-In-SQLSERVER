-- #1
CREATE TABLE Students2 (
    Name NVARCHAR(50),
    Score INT
);

INSERT INTO Students2 VALUES 
('neo', 92),
('leo', 79),
('veo', 65),
('seo', 48);

select Name, Score,
case 
When Score >= 90 then 'A'
When Score >= 80 then 'B'
When Score >= 70 then 'C'
When Score >= 60 then 'D'
Else 'F'
end AS Grade
from Students2;

-- #2
CREATE TABLE OrdersStatus (
    OrderID INT,
    StatusCode INT
);

INSERT INTO OrdersStatus VALUES
(1, 0),
(2, 1),
(3, 2),
(4, 9);

Select *, 
CASE StatusCode
  WHEN 0 THEN 'Pending'
  WHEN 1 THEN 'Approved'
  WHEN 2 THEN 'Rejected'
  Else 'Unknown'
END AS Status
from OrdersStatus;

-- #3
CREATE TABLE EmployeesSalary (
    Name NVARCHAR(50),
    Salary INT
);

INSERT INTO EmployeesSalary VALUES
('neo', 15000),
('seo', 8000),
('veo', 3000),
('leo', 500);

Select *, 
Case
  When Salary > 10000 then 'High'
  When Salary >= 3000 then 'Medium'
  When Salary >= 1000 then 'Low'
  ELSE 'Very Low'
END AS SalaryLevel
from EmployeesSalary

-- #4
CREATE TABLE OrdersWeight (
    Weight DECIMAL(10,2)
);

INSERT INTO OrdersWeight VALUES
(5.5),
(0.2),
(2),
(6),
(25);


Select *,
CASE
  WHEN Weight < 1 THEN 'Very Light'
  WHEN Weight >= 1 AND Weight < 6 THEN 'Light'
  WHEN Weight >= 6 AND Weight <= 20 THEN 'Medium'
  ELSE 'Heavy'
END
from OrdersWeight

-- #5
CREATE TABLE Tickets (
    ID INT,
    Priority NVARCHAR(20)
);

INSERT INTO Tickets VALUES
(1, 'Low'),
(2, 'Critical'),
(3, 'High'),
(4, 'Medium');

SELECT *, 
 CASE Priority 
   WHEN 'Critical' THEN 4
   WHEN 'High'     THEN 3
   WHEN 'Medium'   THEN 2
   WHEN 'Low'      THEN 1
 END AS PriorityRank
FROM Tickets
ORDER BY PriorityRank DESC;

-- or

SELECT *
FROM Tickets
ORDER BY CASE Priority 
            WHEN 'Critical' THEN 4
            WHEN 'High'     THEN 3
            WHEN 'Medium'   THEN 2
            WHEN 'Low'      THEN 1
         END DESC;

-- #6
CREATE TABLE Numbers (
    Value INT NULL
);

INSERT INTO Numbers VALUES
(5),
(NULL),
(9),
(1);

-- V      C
-- 1    - 0
-- 5    - 0
-- 9    - 0
-- NULL - 1
Select * from Numbers ORDER BY CASE WHEN Value IS NULL THEN 1 ELSE 0 END, Value

-- #7
CREATE TABLE EmployeesPosition (
    Name NVARCHAR(50),
    Position NVARCHAR(50),
    Salary DECIMAL(10,2)
);

INSERT INTO EmployeesPosition VALUES
('Ali', 'Manager', 9000),
('Sara', 'Developer', 6000),
('Omar', 'Intern', 2000);

Update EmployeesPosition set Salary = 
Case Position
  When 'Manager' then Salary * 1.10
  When 'Developer' then Salary * 1.05
  When 'Intern' then Salary * 1.02
End

Select * from EmployeesPosition

-- #8
CREATE TABLE ProductsStock (
    Name NVARCHAR(50),
    Qty INT,
    Status NVARCHAR(20) NULL
);

INSERT INTO ProductsStock VALUES
('A', 0, NULL),
('B', 5, NULL),
('C', 50, NULL);

Update ProductsStock set Status =
case
 when Qty = 0 then 'Out'
 when Qty < 10 then 'Low'
 when Qty < 50 then 'Stock'
 Else 'Full'
end

Select * from ProductsStock

-- #9
CREATE TABLE Customers2 (
    Name NVARCHAR(50),
    Type NVARCHAR(20),
    Years INT
);

INSERT INTO Customers2 VALUES
('Ali', 'Regular', 5),
('Sara', 'VIP', 1),
('Omar', 'VIP', 7);

Select *, 
Case Type 
 when 'VIP' then
   Case 
     when Years >= 5 then 0.2
	 else 0.1
   End
 when 'Regular' then
   Case 
     when Years >= 5 then 0.05
	 else 0
   End
End AS DiscountValue
from Customers2

-- #10
CREATE TABLE ProductsShipping (
    Weight DECIMAL(10,2),
    Fragile NVARCHAR(5)
);

INSERT INTO ProductsShipping VALUES
(1, 'Yes'),
(10, 'No'),
(3, 'Yes');

Select *,
case Fragile
  when 'Yes' then 
    case 
	  when Weight <= 2 then 'Special Small'
	  else 'Special Large'
	end
  Else 
      case 
	    when Weight <= 5 then 'Normal Small'
	    else 'Normal Large'
	  end
end Size
from ProductsShipping

-- #11
CREATE TABLE People (
    Name NVARCHAR(50),
    Age INT
);

INSERT INTO People VALUES
('Ali', 12),
('Sara', 25),
('Omar', 40),
('Lina', 8);

Select Count(*) Count, 
case
  When Age < 13 then 'Child'
  When Age between 14 and 30 then 'Young'
  else 'Adult'
end as AgeGroup
from People
group by case
  When Age < 13 then 'Child'
  When Age between 14 and 30 then 'Young'
  else 'Adult'
end
-- or
Select Count(*), AgeGroup From (
Select *,
case
  When Age < 13 then 'Child'
  When Age between 14 and 30 then 'Young'
  else 'Adult'
end as AgeGroup
from People
) as R1
group by AgeGroup

-- #12
CREATE TABLE Sales2 (
    Amount DECIMAL(10,2)
);

INSERT INTO Sales2 VALUES
(10),
(500),
(1200),
(60);

With SalesWithCategory as
(
  Select *, 
  Case
    When Amount < 100 then 'Small'
    When Amount between 100 and 1000 then 'Medium'
    else 'Large'
  End AS Category
from Sales2
)
Select Category, Sum(Amount) Total from SalesWithCategory Group by Category Order by Total DESC

-- ??

With SalesWithCategory as
(
  Select top 1 *, 
  Case
    When Amount < 100 then 'Small'
    When Amount between 100 and 1000 then 'Medium'
    else 'Large'
  End AS Category
from Sales2 order by Amount DESC
)
Select Category, Sum(Amount) Total from SalesWithCategory Group by Category Order by Total DESC