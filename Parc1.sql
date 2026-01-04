-- #1
Declare @TotalSum INT = 0;

create Table #TempEmplyees (
  Salary INT,
  RowNumber int
)

insert into #TempEmplyees select Salary, ROW_NUMBER() over(Order by Name) as RowNumber from Employees2;

Declare @I INT = 1;
Declare @Max INT = 0;

Select TOP 1 @Max = RowNumber from #TempEmplyees Order by RowNumber Desc

WHILE @I <= @Max
begin
  select @TotalSum += Salary from #TempEmplyees where RowNumber = @I;
  Set @I = @I + 1;
end

Print @TotalSum;

drop Table #TempEmplyees;


-- #2
Declare @Target INT = 6;
Declare @J INT = 2;
Declare @Result INT = 1;

WHILE @J <= @Target
begin
  set @Result = @Result * @J;
  set @J = @J + 1;
end

Print @Result;

-- #3
Declare @n INT = 5;
Declare @K INT = 0;
Declare @Prev INT = 0;
Declare @Next INT = 1;
Declare @FobResult INT = 0;
Declare @FobString VARCHAR(MAX) = '0,1,';

WHILE @K <= @n
begin
  SET @FobResult = @Prev + @Next;
  SET @FobString += CAST(@FobResult as NVARCHAR) + ',';
  SET @Prev = @Next;
  SET @Next = @FobResult;
  SET @K += 1;
end

Print SubString(@FobString, 0, LEN(@FobString));

-- #4
Declare @NTh4Salary int = 0;

create Table #TempEmplyees3 (
  Salary INT,
  RowNumber int
)

insert into #TempEmplyees3 select Salary, ROW_NUMBER() over(Order by Salary) as RowNumber from employees3;

Declare @Max2 INT = 0;

Select Top 1 @Max2 = RowNumber from #TempEmplyees3 Order by RowNumber DESC;

Declare @m INT = 0;

DECLARE @IgnorentSalaries TABLE (
  Salary INT
);

While @m < 4 
begin
  Declare @g INT = 0;
  Declare @CurrentMax INT = 0;
  Declare @MaxSalary INT = 0;

  while (@g <= @Max2)
  begin
    select @CurrentMax = Salary from #TempEmplyees3 where @g = RowNumber;
	IF NOT EXISTS (Select Top 1 found = 1 from @IgnorentSalaries where Salary = @CurrentMax) 
	begin
      if (@MaxSalary < @CurrentMax) 
	  begin
	    SET @MaxSalary = @CurrentMax;
	  end
	end
	SET @g += 1;
  end
  SET @m += 1;
  if(@m >= 4)
  begin
    SET @NTh4Salary = @MaxSalary;
	break;
  end
  Insert into @IgnorentSalaries Values (@MaxSalary);
end

Print @NTh4Salary;

drop table #TempEmplyees3;

-- #5
Declare @Count int = 0;
Declare @Max3 int = 0;
Declare @Min3 int = 0;

select @Max3 = Max(ID) from Employees3;
select @Min3 = MIN(ID) from Employees3;

while @Min3 <= @Max3
begin
  SET @Count += 1;
  select @Min3 = MIN(ID) from Employees3 where ID > @Min3;
end

Print @Count;

-- #6
DECLARE @txt NVARCHAR(100) = 'Hello';
DECLARE @txtResult NVARCHAR(100) = '';
Declare @LI int = Len(@txt);
while (@LI > 0)
begin
  SET @txtResult += SUBSTRING(@txt, @LI, 1);
  SET @LI = @LI - 1;
end

Print @txtResult;

-- #7
DECLARE @NumbersString NVARCHAR(100) = '';
DECLARE @Number NVARCHAR(MAX) = '5 scd 08   dddvdvfvdv'; 
Declare @SN int = 1;
while (@SN <= LEN(@Number))
begin
  Declare @CurrentNumber CHAR(1) = SUBSTRING(@Number, @SN, 1);
  if (@CurrentNumber = '0') 
  begin
    SET @NumbersString += 'Zero';
  end
  else if (@CurrentNumber = '1')
  begin
    SET @NumbersString += 'One';
  end
  else if (@CurrentNumber = '2') 
  begin
    SET @NumbersString += 'Two';
  end
  else if (@CurrentNumber = '3') 
  begin
    SET @NumbersString += 'Three';
  end
  else if (@CurrentNumber = '4') 
  begin
    SET @NumbersString += 'Four';
  end
  else if (@CurrentNumber = '5') 
  begin
    SET @NumbersString += 'Five';
  end
  else if (@CurrentNumber = '6') 
  begin
    SET @NumbersString += 'Six';
  end
  else if (@CurrentNumber = '7') 
  begin
    SET @NumbersString += 'Seven';
  end
  else if (@CurrentNumber = '8') 
  begin
    SET @NumbersString += 'Eight';
  end
  else if (@CurrentNumber = '9') 
  begin
    SET @NumbersString += 'Nine';
  end
  SET @SN = @SN + 1;
end

Print @NumbersString;

-- #9
DECLARE @Numbers Table (
  Number int,
  RowNumber int
);

insert into @Numbers Values(5, 1)
insert into @Numbers Values(100, 2)
insert into @Numbers Values(3, 3)
insert into @Numbers Values(70, 4)
insert into @Numbers Values(71, 5)
insert into @Numbers Values(1, 6)

Declare @Size int = 0;
Declare @itr int = 1;

Select @Size = Count(*) from @Numbers;

Declare @CurrentN int = 0;

Declare @MinGap int = 0;

Declare @Number1 int = 0;
Declare @Number2 int = 0;

select @Number1 = Number from @Numbers where RowNumber = 1;
select @Number2 = Number from @Numbers where RowNumber = 2;

Select @MinGap = Abs(@Number1 - @Number2);

While @itr <= @Size 
begin
  Declare @kk INT = 0;
  Select @CurrentN = Number From @Numbers where @itr = RowNumber;
  Declare @CurrentMin INT = 0;

  while (@kk <= @Size)
  begin	
    Declare @CurrentK int = 0;
    Select @CurrentK = Number From @Numbers where @kk = RowNumber;

	if (@CurrentMin > @CurrentK and @CurrentK > @CurrentN)
	  SET @CurrentMin = @CurrentK; 

    if (@CurrentK > @CurrentN)
    begin
	  SET @CurrentMin = @CurrentK;
	end
	SET @kk += 1;
  end
  SET @itr += 1;
  if(ABS(@CurrentMin - @CurrentN) < @MinGap) 
  begin
    SET @Number1 = @CurrentMin;
    SET @Number2 = @CurrentN;
    Set @MinGap = ABS(@CurrentMin - @CurrentN);
  end
end

 Print @MinGap; -- 1
 Print @Number1; -- 71
 Print @Number2; -- 70


-- #10
CREATE TABLE monthly_data (
    id INT PRIMARY KEY Identity(1,1),
    month INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    RowNumber int
);

INSERT INTO monthly_data (month, amount, RowNumber) VALUES
(1, 100.00, 1),
(1, 200.00, 2),
(2, 50.00, 3),
(2, 25.00, 4),
(3, 99.00, 5);

Create Table MonthlySummery (
  Month int,
  Total int
);

Declare @Ig int = 1;

Declare @MTableSize int = 0;

Declare @CurrentMonth int = 0;
Declare @CurrentAmount int = 0;

Select @MTableSize = Max(RowNumber) From monthly_data;

while @Ig <= @MTableSize
begin
   Select @CurrentMonth = month, @CurrentAmount = amount from monthly_data where RowNumber = @Ig;
  if not exists (select Month from MonthlySummery where Month = @CurrentMonth)
  begin
    Insert into MonthlySummery Values(@CurrentMonth, @CurrentAmount);
  end
  else
  begin 
    Update MonthlySummery set Total = Total + @CurrentAmount where Month = @CurrentMonth;
  end
  Set @Ig += 1;
end

Select * from MonthlySummery;

-- #1 using cursors

DECLARE static_cursor CURSOR STATIC FORWARD_ONLY FOR
SELECT salary FROM Employees2;
OPEN static_cursor;

DECLARE @Amount int, @TotalSuSalary int = 0;

FETCH NEXT FROM static_cursor INTO @Amount;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TotalSuSalary += @Amount;
    FETCH NEXT FROM static_cursor INTO @Amount;
END

Print @TotalSuSalary;

CLOSE static_cursor;
DEALLOCATE static_cursor;


-- #6 Fibonacci using CTE
with Fibonacci as 
(
  Select B = 1, A = 0, n = 5 
  UNION ALL
  Select b = a + b, a = b, n - 1 from Fibonacci where n > 0
) select a, b from Fibonacci

WITH Fibonacci AS
(
    SELECT 
        n = 0,
        A = 0,
        B = 1
    UNION ALL
    SELECT
        n = n + 1,
        A = B,
        B = A + B
    FROM Fibonacci
    WHERE n < 5
)
SELECT a, b AS FibonacciValue
FROM Fibonacci;