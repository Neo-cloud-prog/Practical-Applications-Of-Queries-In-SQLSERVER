-- #1
Declare @i int = 1;
WHILE @i <= 10
begin
  Print @i;
  SET @i += 1;
end

-- #2
Declare @Total int = 1;
WHILE @Total < 100
begin
  SET @Total += @Total;
end
Print @Total;

-- #3
Declare @j int = 1;
WHILE @j <= 20
begin
  if (@j % 2 = 0)
    Print @j;
  SET @j += 1;
end
-- or
WHILE @j <= 20
begin
  SET @j += 1;
  if (@j % 2 <> 0)
    Continue;
  Print @j;
end
-- or
DECLARE @j1 INT = 2;
WHILE @j1 <= 20
BEGIN
    PRINT @j1;
    SET @j1 += 2;
END

-- #4
Declare @k int = 1;
WHILE @k <= 1000
begin
  if (@k = 37)
    break;
  Print @k;
  SET @k += 1;
end

-- #5
CREATE TABLE NumbersLoop (Numbers INT);
INSERT INTO NumbersLoop VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

declare @Max int;
declare @Min int;
declare @Result int = 0;

select @Max = MAX(Numbers) from NumbersLoop;
select @Min = Min(Numbers) from NumbersLoop;

while @Min <= @Max
begin
  SET @Result += @Min;
  select @Min = Min(Numbers) from NumbersLoop where Numbers > @Min;
end
Print @Result;
-- or
DECLARE @Sum INT = 0;
DECLARE @nu INT;

DECLARE cur CURSOR FOR SELECT Numbers FROM NumbersLoop ORDER BY Numbers;
OPEN cur;
FETCH NEXT FROM cur INTO @nu;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sum += @nu;
    FETCH NEXT FROM cur INTO @nu;
END

CLOSE cur;
DEALLOCATE cur;

PRINT @Sum;
-- or
Select Sum(Numbers) from NumbersLoop

-- #6
declare @Max1 int;
declare @Min1 int;

select @Max1 = MAX(Numbers) from NumbersLoop;
select @Min1 = Min(Numbers) from NumbersLoop;

while @Min1 <= @Max1
begin
  Update NumbersLoop set Numbers += 10 where @Min1 = Numbers;
  select @Min1 = Min(Numbers) from NumbersLoop where Numbers > @Min1;
end
select * from NumbersLoop;
-- or
DECLARE @num INT;

DECLARE cur CURSOR FOR SELECT Numbers FROM NumbersLoop;
OPEN cur;
FETCH NEXT FROM cur INTO @num;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE NumbersLoop SET Numbers = Numbers + 10 WHERE Numbers = @num;
    FETCH NEXT FROM cur INTO @num;
END
CLOSE cur;
DEALLOCATE cur;
-- or
UPDATE NumbersLoop SET Numbers = Numbers + 10;

-- #7
Declare @n int = 6
Declare @Fac int = 1;
WHILE @n > 0
begin
  SET @Fac *= @n;
  SET @n -= 1;
end
Print @Fac;

-- #8
DECLARE @h INT = 1;
WHILE @h <= 100
BEGIN
    IF @h % 7 = 0 BREAK;

    IF @h % 3 = 0
        PRINT @h;

    SET @h += 1;
END

-- #9
DECLARE @Try INT = 1;
DECLARE @MaxTry INT = 5;
while @Try <= @MaxTry
begin
  Print 'Try number: ' + Cast(@Try as VARCHAR);
  if @Try = 3
  begin
	Print 'ur account is locked';
	Break;
  end
  SET @Try += 1;
end

-- #10
CREATE TABLE CounterTable (CounterValue INT);
Declare @Counter int = 1;
While @Counter <= 50
begin
  insert into CounterTable values(@Counter);
  SET @Counter += 1
end
Select * from CounterTable;
delete from CounterTable;
-- or
INSERT INTO CounterTable (CounterValue)
SELECT TOP 50 *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
FROM master..spt_values;
Select * from CounterTable;
delete from CounterTable;
-- or
INSERT INTO CounterTable (CounterValue)
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
FROM (VALUES (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) AS A(x)
CROSS JOIN (VALUES (1),(1),(1),(1),(1)) AS B(y);
Select * from CounterTable;
delete from CounterTable;
-- or
WITH Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numbers WHERE n < 50
)
INSERT INTO CounterTable (CounterValue)
SELECT n FROM Numbers;
Select * from CounterTable order by 1 DESC;
delete from CounterTable;

