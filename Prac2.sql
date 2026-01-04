-- #1
Declare @a int = 20
Declare @b int = 5

if @a > @b
begin
  Print 'a is greater than b'
end
else if(@a < @b)
begin
  Print 'b is greater than a'
end
else
begin
  Print 'a equals b'
end

Declare @Output VARCHAR(20);
SET @Output = case 
                WHEN @a > @b then 'a is greater than b'
				WHEN @a < @b then 'b is greater than a'
				ELSE 'a equals b'
			  END;
Print @Output;

-- #2
Declare @Age INT = 15;
if @Age < 13
begin
  Print 'Child'
end
else if(@Age BETWEEN 13 and 17)
begin
  Print 'Teenager'
end
else
begin
  Print 'Adult'
end

-- #3
declare @score int = 86;
if (@score >= 90)
begin
  Print 'Excellent'
end
else if(@score >= 75)
begin
  Print 'Good'
end
else if(@score >= 60)
begin
  Print 'Pass'
end
else
begin
  Print 'Fail'
end

-- #4
Declare @BirthYear DATE = '1/1/2000';
Print DATEDIFF(YEAR, @BirthYear, GETDATE())
if (DATEDIFF(YEAR, @BirthYear, GETDATE()) > 30)
begin
  Print 'ur age is greater than 30'
end
else 
begin
  Print 'ur age is not greater than 30 u pass'
end

-- #5
Declare @VirTabel Table (
  Val1 INT Primary Key,
  Val2 INT,
  Val3 INT
)

Insert into @VirTabel Values (1, 2, 3)
if @@ERROR <> 0 
begin
  Print 'Insert failed'
end
else
begin
  Print 'Insert successful'
end
Insert into @VirTabel Values (2, 2, 3)
if @@ERROR <> 0 
begin
  Print 'Insert failed'
end
else
begin
  Print 'Insert successful'
end
Insert into @VirTabel Values (1, 4, 5)
if @@ERROR <> 0 
begin
  Print 'Insert failed'
end
else
begin
  Print 'Insert successful'
end

begin try
  Insert into @VirTabel Values (1, 2, 3)
  Insert into @VirTabel Values (1, 4, 5)
end try
begin catch
  Print ERROR_MESSAGE();
end catch

-- #6
Update @VirTabel SET Val1 = 1
if @@ERROR = 0
begin
  Print '0'
end
else
begin
  Print '1'
end

-- #7
Declare @x int = 0
Declare @y int = 0
Declare @Result int = @x / @y;

if @@ERROR <> 0
begin 
  Print 'U cannot divide by zero'
end
Print @Result;

begin try 
 SET @Result = @x / @y;
 Print @Result
end try
begin catch 
  Print ERROR_MESSAGE();
end catch 

-- #8
Delete from @VirTabel Where Val1 = 15
if @@ERROR <> 0 or @@ROWCOUNT = 0
begin
  Print 'Error or row not found'
end
else
begin
  Print 'Row deleted'
end

-- #9
if exists (select top 1 1 from @VirTabel where Val1 = 1)
begin
  Print 'Row found'
end
else 
begin
  Print 'Row not found'
end

-- #10
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerId INT,
    OrderDate DATE
);

INSERT INTO Orders (OrderID, CustomerId, OrderDate) VALUES
(1, 101, '2023-01-10'),
(2, 102, '2023-02-15'),
(3, 101, '2023-03-20'),
(4, 103, '2023-04-05');

Declare @CustomerID int = 1033;

if Exists (select top 1 1 from Orders where CustomerId = @CustomerID)
begin
  Print 'Has orders'
end
else
begin
  Print 'Has no orders'
end

-- #11
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2)
);

INSERT INTO Products (ProductID, ProductName, Price) VALUES
(1, 'Notebook', 12.50),
(2, 'Pen', 2.50),
(3, 'Backpack', 25.00),
(4, 'Eraser', 0.99),
(5, 'Tablet', 200.00);

if Exists (select top 1 1 from Products where Price < 10)
begin
  Print 'Cheap product exists'
end
else
begin
  Print 'No cheap products'
end

-- #12
CREATE TABLE Employees4 (
    EmployeeID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employees4 (EmployeeID, FullName, Salary) VALUES
(1, 'Bosko', 8500.00),
(2, 'Neo', 12000.00),
(3, 'Your mom', 9500.00),
(4, 'Your dad', 6000.00),
(5, 'alix', 15000.00);

Declare @LimitSalary DECIMAL(10, 2) = 12000.00;

if Exists (select top 1 1 from Employees4 where Salary > @LimitSalary)
begin
  Print 'High salary detected'
end

-- #13
--understand that if there is no record with “nothing” FullName, no error will appear
-- u can use (@@ERROR <> 0 or @@ROWCOUNT = 0)
Update Employees4 set Salary = 0 where FullName = 'Nothing';
if @@ERROR <> 0
begin
  Print 'Update Error'
end

-- #14
Declare @EmployeeID int = 1;
if Not exists(select Top 1 1 from Employees4 where EmployeeID = @EmployeeID) 
begin
  INSERT INTO Employees4 (EmployeeID, FullName, Salary) VALUES (@EmployeeID, 'Mona', 4832.00)
end

-- #15
if Not exists(select top 1 1 from Products) 
begin
  Print 'Empty'
end
else
begin
  Print 'Has Data'
end

-- #16
Declare @EmID2 int = 7;
if Not exists(select Top 1 1 from Employees4 where EmployeeID = @EmID2) 
begin
  INSERT INTO Employees4 (EmployeeID, FullName, Salary) VALUES (@EmID2, 'Lily', 6754.00)
  if @@ERROR <> 0 or @@ROWCOUNT = 0
  begin
    Print 'Insert Failed'
  end
  else
  begin
    Print 'Insert Success'
  end
end
else
begin
  Print 'Already Exist'
end