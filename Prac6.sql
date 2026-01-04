CREATE TABLE Emails (
    Id INT,
    Email VARCHAR(100)
);

INSERT INTO Emails VALUES
(1, 'fuck.1995@gmail.com'),
(2, 'bitch@example.com');

select 
SUBSTRING(Email, 1, CHARINDEX('@', Email) - 1) as Username,
SUBSTRING(SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)), 2, CHARINDEX('.', SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email))) - 2) as Domain,
SUBSTRING(SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)), CHARINDEX('.', SUBSTRING(Email, CHARINDEX('@', Email) - 1, LEN(Email))), LEN(SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)))) as Extension,
RIGHT(Email, CHARINDEX('.', Reverse(SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)))) - 1) as Extension2
from Emails;

-- #2
CREATE TABLE RawStrings (
    RawValue VARCHAR(50)
);

INSERT INTO RawStrings VALUES
('  hello '),
('Hello   '),
('  HeLLo');

Select UPPER(TRIM(RawValue)) from RawStrings

-- #3
CREATE TABLE RawText (
    T VARCHAR(100)
);

INSERT INTO RawText VALUES
('John#Smith#Manager#IT');
select value from 
(
  Select *, ROW_NUMBER() over (order by (select null)) as rn from string_split((Select T from RawText), '#')
) as R1 where rn = 3
-- or
Declare @txt varchar(MAX) = 'Johndjdjd#Smithjjjjj#Manager#IT';
Declare @Step1 varchar(MAX) = Substring(@txt, charindex('#', @txt) + 1, Len(@txt));
Declare @Step2 varchar(MAX) = Substring(@Step1, charindex('#', @Step1) + 1, Len(@Step1));
Declare @word3 varchar(MAX) = Substring(@Step2, 1, charindex('#', @Step2) - 1);
print @word3;

-- #4
CREATE TABLE Persons (
    Id INT,
    BirthDate DATE
);

INSERT INTO Persons VALUES
(1, '1995-03-12'),
(2, '2001-09-28');

Select *, 
DATEDIFF(year, BirthDate, GETDATE()) as BirthDateInYears,
DATEDIFF(day, BirthDate, GETDATE()) as BirthDateInDays,
DATEDIFF(month, BirthDate, GETDATE()) as BirthDateInMonths,
DATENAME(WEEKDAY, BirthDate) as DayText,
DATENAME(MONTH, BirthDate) as MonthText
from Persons;

-- #5
CREATE TABLE Employees (
    Id INT,
    Name VARCHAR(50),
    HireDate DATE,
    LastActiveDate DATE
);

INSERT INTO Employees VALUES
(1, 'slut', '2020-03-10', '2025-11-02'),
(2, 'neo', '2021-11-05', '2025-01-28'),
(3, 'jon', '2025-11-15', '2025-11-19');

select * from Employees where LastActiveDate between DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) and GETDATE();

-- #6
CREATE TABLE Tasks (
    TaskId INT,
    StartTime DATETIME2,
    EndTime DATETIME2
);

INSERT INTO Tasks VALUES
(1, '2025-03-12 09:22:14.100', '2025-03-12 16:44:50.800');

select *, 
Concat
(
  DATEDIFF(HOUR, StartTime, EndTime),
  ' Hours, ',
  DATEDIFF(MINUTE, StartTime, EndTime),
  ' Minutes, ',
  DATEDIFF(SECOND, StartTime, EndTime),
  ' Seconds, ',
  DATEDIFF(MILLISECOND, StartTime, EndTime),
  ' Milliseconds, '
) as Info
from Tasks

-- #7
CREATE TABLE Products1 (
    ProductId INT,
    Name VARCHAR(50),
    Category VARCHAR(20),
    Price DECIMAL(10,2)
);

INSERT INTO Products1 VALUES
(1, 'Laptop', 'Electronics', 500),
(2, 'Mouse', 'Electronics', 20),
(3, 'Desk', 'Furniture', 100);

CREATE TABLE UpdatesLog (
    LogId INT IDENTITY,
    Message VARCHAR(200),
    LogDate DATETIME DEFAULT GETDATE()
);

Declare @Category VARCHAR(20) = 'Electronics';

UPDATE Products1
SET Price = Price * 1.2
WHERE Category = @Category

if (@@ROWCOUNT <> 0)
begin
  insert into UpdatesLog Values(Concat(@Category, ' updated price'), GETDATE());
end

Select * from UpdatesLog;

-- #8
CREATE TABLE Orders1 (
    Id INT,
    OrderDate DATE
);

INSERT INTO Orders1 VALUES
(1, '2022-01-05'),
(2, '2023-02-10'),
(3, '2024-02-15'),
(4, '2020-05-21'),
(5, '2019-11-10'),
(6, '2025-11-10');

delete from Orders1 where DATEDIFF(year, OrderDate, GETDATE()) = 1 and (select Count(*) from Orders where DATEDIFF(year, OrderDate, GETDATE()) = 1) > 500
select * from Orders;

-- #9
CREATE TABLE Users (
    Id INT,
    Username VARCHAR(50),
    Password VARBINARY(64)
);

INSERT INTO Users VALUES
(12, 'neo', HASHBYTES('SHA2_256','oldpass'));

UPDATE Users SET Password = HASHBYTES('SHA2_256', 'NewPass') WHERE Id = 12

if (@@ROWCOUNT <> 0)
  Print 'Password updated'
else
  Print 'No password updated'

-- #10
CREATE TABLE OrdersInfo (
    OrderId INT,
    CustomerName VARCHAR(50),
    Amount INT,
    Status VARCHAR(20),
    OrderDate DATE
);

INSERT INTO OrdersInfo VALUES
(1, 'leo', 100, 'Done', '2025-01-10'),
(2, 'idk names', 150, 'Done', '2025-01-15'),
(3, 'Samuels', 200, 'Done', '2025-01-20'),
(4, 'omg', 50, 'Pending', '2024-12-25'),
(5, 'neo', 400, 'Done', '2025-01-21');

Declare @AvgAmount DECIMAL(10, 2);
Declare @NumberOfOrders int;
Declare @CustomerName NVARCHAR(20);

Select top 1 @CustomerName = CustomerName,
@AvgAmount = AVG(Amount) OVER (ORDER BY (SELECT NULL)),
@NumberOfOrders = COUNT(*) OVER (ORDER BY (SELECT NULL))
from OrdersInfo where CustomerName LIKE 's%'

if (@@ROWCOUNT <> 0)
  Print Concat('Customer ', @CustomerName, ' made ', @NumberOfOrders, ' orders last month with avg ', @AvgAmount, '$')

-- #11
CREATE TABLE Phones (
    Phone VARCHAR(50)
);

INSERT INTO Phones VALUES
('+381 110-55 11'),
('  1100 5511  '),
('110-55-11');
-- just anything

select REPLACE(REPLACE(REPLACE(TRIM(Phone), '+', ''), '-', ''), ' ', '') from Phones

-- #12
select 
Year(OrderDate) as Year, 
MONTH(OrderDate) as Month,
DATENAME(Month, OrderDate) as Month,
ISDATE('2/29' + Cast(Year(OrderDate) as varchar(4))) as IsLeap
from Orders 

-- #13
Select *, power(value, 2) from string_split('10,20,30,40,50', ',')

-- #14
CREATE TABLE Products2 (
    Id INT,
    Name NVARCHAR(100),
    Tags NVARCHAR(100)
);

INSERT INTO Products2 VALUES
(1, 'Laptop', 'electronics,computers,portable'),
(2, 'Phone', 'electronics,mobile'),
(3, 'Chair', 'furniture,wood');

SELECT 
    p.Id,
    p.Name,
    value AS Tag
FROM Products2 p
CROSS APPLY STRING_SPLIT(p.Tags, ',');

SELECT *
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS A(x)
CROSS JOIN (VALUES (1),(1),(1),(1),(1)) AS B(y);

-- #15
CREATE TABLE SplitData (
    Raw VARCHAR(MAX)
);

INSERT INTO SplitData VALUES ('10,20,30,40,50');

select value, power(value, 2) from SplitData cross apply string_split(Raw, ',')

-- #16
CREATE TABLE JsonTable (
    Data NVARCHAR(MAX)
);

INSERT INTO JsonTable VALUES
('{"Name":"neo","Age":15,"Skills":["SQL","C#"]}');

select JSON_VALUE(Data, '$.Name') as Name, JSON_VALUE(Data, '$.Age' ) as Age, value as Skills from JsonTable cross apply OPENJSON(JSON_QUERY(Data, '$.Skills'))

-- #17
CREATE TABLE Paragraphs (
    TextLine VARCHAR(MAX)
);

INSERT INTO Paragraphs VALUES
('SQL is powerful. Speed starts with smart queries and indexing.');

select STRING_AGG(value, ', ') SearchedWords from Paragraphs cross apply string_split(TRANSLATE(TextLine, '.,;', '   '), ' ') where PATINDEX('S%', value) = 1;

-- #18
CREATE TABLE TimeLogs (
    StartTime DATETIME2(7),
    EndTime DATETIME2(7)
);

INSERT INTO TimeLogs VALUES
('2025-03-12 09:22:14.1000000', '2025-03-12 09:22:15.9999999');

select *, DATEDIFF_BIG(MICROSECOND, StartTime, EndTime) DiffInMs from TimeLogs;

SELECT DATEDIFF_BIG(MICROSECOND, StartTime, SYSDATETIME()) AS DiffNowInMicroseconds from TimeLogs;
SELECT DATEDIFF_BIG(MICROSECOND, StartTime, GETDATE()) AS DiffNowInMicroseconds from TimeLogs;
-- overflow result 
SELECT DATEDIFF(MICROSECOND, StartTime, SYSDATETIME()) AS DiffNowInMicroseconds from TimeLogs;

select GETDATE(), SYSDATETIME();

-- #19
CREATE TABLE CalendarBase (
    StartDate DATE,
    EndDate DATE
);

INSERT INTO CalendarBase VALUES
('2025-01-01', '2025-12-31');

WITH Dates AS (
    SELECT StartDate
    FROM CalendarBase
    UNION ALL
    SELECT DATEADD(DAY, 1, StartDate)
    FROM Dates
    WHERE StartDate < (SELECT EndDate FROM CalendarBase)
)
SELECT *
FROM Dates
OPTION (MAXRECURSION 4000);

-- #20
SELECT
  Email,
  CASE 
    WHEN CHARINDEX('@', Email) > 1 
    THEN LEFT(Email, CHARINDEX('@', Email) - 1)
    ELSE NULL
  END AS Username,

  CASE 
    WHEN CHARINDEX('@', Email) > 0 AND CHARINDEX('.', Email, CHARINDEX('@', Email)) > CHARINDEX('@', Email)
    THEN SUBSTRING(
           Email,
           CHARINDEX('@', Email) + 1,
           LEN(Email) - CHARINDEX('@', Email) - (CHARINDEX('.', REVERSE(Email)) - 1)
         )
    ELSE NULL
  END AS Domain,

  CASE
    WHEN CHARINDEX('.', REVERSE(Email)) > 0
    THEN RIGHT(Email, CHARINDEX('.', REVERSE(Email)) - 1)
    ELSE NULL
  END AS Extension
FROM Emails;

-- #21
SELECT
  Id,
  BirthDate,
  CASE
    WHEN MONTH(BirthDate) < MONTH(GETDATE())
      OR (MONTH(BirthDate) = MONTH(GETDATE()) AND DAY(BirthDate) <= DAY(GETDATE()))
    THEN DATEPART(year, GETDATE()) - DATEPART(year, BirthDate)
    ELSE DATEPART(year, GETDATE()) - DATEPART(year, BirthDate) - 1
  END AS AgeYears,

  DATEDIFF(day, BirthDate, GETDATE()) AS AgeDays,

  (DATEPART(year, GETDATE()) - DATEPART(year, BirthDate)) * 12
    + DATEPART(month, GETDATE()) - DATEPART(month, BirthDate)
    - CASE WHEN DAY(GETDATE()) < DAY(BirthDate) THEN 1 ELSE 0 END
    AS AgeMonths,

  DATENAME(weekday, BirthDate) AS BirthWeekday,
  DATENAME(month, BirthDate) AS BirthMonthName
FROM Persons;

-- #22
SELECT value
FROM STRING_SPLIT((SELECT T FROM RawText), '#', 1) 
WHERE ordinal = 3;

-- #23
DECLARE @StartOfMonth DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @StartNextMonth DATE = DATEADD(MONTH, 1, @StartOfMonth);

SELECT * FROM Employees WHERE LastActiveDate >= @StartOfMonth AND LastActiveDate < @StartNextMonth;

-- #24
DECLARE @Days INT = 7;

SELECT * FROM Employees WHERE LastActiveDate >= DATEADD(day, -@Days, GETDATE());

-- #25
SET DATEFIRST 6; -- Sturday
SELECT DATEADD(day, (7 - DATEPART(weekday, GETDATE())), CAST(GETDATE() AS date)) AS WeekEnd;
SELECT DATEADD(day, (7 - DATEPART(weekday, GETDATE())) + 7, CAST(GETDATE() AS date)) AS NextWeekEnd;

-- #26
SELECT
  REPLACE(TRANSLATE(Phone, '()- +', '     '), ' ', '') AS CleanedPhone
FROM Phones;

-- #27
DECLARE @txt2 NVARCHAR(200) = 'hello world sql';

SELECT
  CONCAT(
    UPPER(LEFT(value, 1)),
    LOWER(SUBSTRING(value, 2, LEN(value)))
  ) AS Part
FROM STRING_SPLIT(@txt2, ' ');

SELECT STRING_AGG(
         CONCAT(
           UPPER(LEFT(value, 1)),
           LOWER(SUBSTRING(value, 2, LEN(value)))
         ), ''
       ) AS CamelCase
FROM STRING_SPLIT(@txt2, ' ');

-- #28
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    DATENAME(MONTH, OrderDate) AS MonthName,
    IIF(DAY(EOMONTH(DATEFROMPARTS(YEAR(OrderDate), 2, 1))) = 29, 1, 0) AS IsLeapYear
FROM Orders;

-- #29
SELECT value, POWER(value, 2)
FROM string_split('10,20,30,40,50', ',', 1);
SELECT value, POWER(value, 2)
FROM OPENJSON('["10","20","30","40","50"]');

-- #30
SELECT 
    p.Id,
    p.Name,
    TRIM(value) AS Tag
FROM Products2 p
CROSS APPLY STRING_SPLIT(p.Tags, ',', 1);

SELECT A.x, B.y
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) A(x)
CROSS JOIN (VALUES (1),(1),(1),(1),(1)) B(y);

-- #31
SELECT 
    TRIM(value) AS Number,
    POWER(value, 2) AS Square
FROM SplitData
CROSS APPLY string_split(Raw, ',', 1);

-- #32
--DECLARE @AvgAmount DECIMAL(10, 2);
--DECLARE @NumberOfOrders INT;
--DECLARE @CustomerName NVARCHAR(20);

WITH C AS (
    SELECT
        CustomerName,
        AvgAmount      = AVG(Amount) OVER (),
        NumberOfOrders = COUNT(*) OVER ()
    FROM OrdersInfo
    WHERE CustomerName LIKE 'S%'
)
SELECT TOP 1
    @CustomerName = CustomerName,
    @AvgAmount = AvgAmount,
    @NumberOfOrders = NumberOfOrders
FROM C;

IF (@@ROWCOUNT <> 0)
BEGIN
    PRINT CONCAT(
        'Customer ', @CustomerName,
        ' made ', @NumberOfOrders,
        ' orders last month with avg ',
        @AvgAmount, '$'
    );
END;