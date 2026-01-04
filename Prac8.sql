-- #1 
CREATE TABLE customers
  (
     customerid INT PRIMARY KEY,
     fullname   NVARCHAR(100),
     phoneraw   NVARCHAR(50)
  );

INSERT INTO customers
VALUES      (1,
             'jack Nigga',
             '002123456789'),
            (2,
             'Nono neony',
             '+2123456789'),
            (3,
             'mutherfucker',
             '212-34-56789');

CREATE FUNCTION dbo.Normalizephonenumbers (@PhoneRaw VARCHAR(50))
returns VARCHAR(50)
AS
  BEGIN
      DECLARE @ClearedPhone VARCHAR(50) = Replace(@PhoneRaw, '-', '');
      DECLARE @Result VARCHAR(50) = Stuff(Stuff('+'
                    + Substring(@ClearedPhone, Charindex('2', @ClearedPhone, 0),
                                                Len(
                                                        @ClearedPhone)), 5, 0,
                                          '-'
                                          ), 9
                                    ,
                                      0, '-');

      RETURN @Result;
  END

SELECT dbo.Normalizephonenumbers(phoneraw),
       phoneraw
FROM   customers; 

-- #2 
CREATE TABLE employees
  (
     empid     INT PRIMARY KEY,
     fullname  NVARCHAR(100),
     birthdate DATE
  );

INSERT INTO employees
VALUES      (1,
             'foxy vexin',
             '1990-02-15'),
            (2,
             'black mail man',
             '1985-11-01'),
            (3,
             'Rousa fukedup',
             '2000-07-30');

CREATE FUNCTION dbo.Fn_calcage(@BirthDay DATE)
returns TINYINT
AS
  BEGIN
      DECLARE @Age TINYINT = Datediff(year, @BirthDay, Getdate());

      RETURN @Age;
  END

SELECT dbo.Fn_calcage(birthdate)
FROM   employees 

-- #3 
CREATE TABLE logs
  (
     logid     INT PRIMARY KEY,
     ipaddress NVARCHAR(50),
     url       NVARCHAR(200)
  );

INSERT INTO logs
VALUES      (1,
             '192.168.1.10',
             '/home'),
            (2,
             '10.4.5.33',
             '/login'),
            (3,
             '172.16.5.88',
             '/cart');

CREATE FUNCTION dbo.Fn_getipclass(@IpAddress NVARCHAR(50))
returns VARCHAR(10)
AS
  BEGIN
      DECLARE @IpClass VARCHAR(10) = CASE
          WHEN @IpAddress LIKE '192.168%' THEN 'Local'
          WHEN @IpAddress LIKE '10%' THEN 'PRIVATE'
          WHEN @IpAddress LIKE '172.16%' THEN 'DMZ'
          ELSE 'PUBLIC'
        END

      RETURN @IpClass;
  END

SELECT *,
       dbo.Fn_getipclass(ipaddress) IpClass
FROM   logs; 

-- #4
CREATE TABLE users
  (
     userid     INT PRIMARY KEY,
     fullname   NVARCHAR(100),
     nationalid NVARCHAR(20)
  );

INSERT INTO users
VALUES      (1,
             'Lola lolipop goth rock girl',
             'A123456'),
            (2,
             'running out of drugs',
             '999999999999'),
            (3,
             'User5734838',
             'B888888');

CREATE FUNCTION dbo.Fn_isvalidnationalid(@NationalId NVARCHAR(20))
returns BIT
AS
  BEGIN
      DECLARE @NumaricPart VARCHAR(20) = Substring(@NationalId, 2,
                                         Len(@NationalId));

      IF( Upper(@NationalId) LIKE '[A-Z]%'
          AND Patindex('%[^0-9]%', @NumaricPart) = 0
          AND Len(@NumaricPart) = 6 )
        BEGIN
            RETURN 1;
        END

      RETURN 0;
  END

SELECT *,
       dbo.Fn_isvalidnationalid(nationalid) IsValidNationalId,
       Substring(nationalid, 2, Len(nationalid))
FROM   users; 

-- #5 
CREATE TABLE orders
  (
     orderid INT PRIMARY KEY,
     total   MONEY
  );

INSERT INTO orders
VALUES      (1,
             200),
            (2,
             150),
            (3,
             400);

CREATE FUNCTION dbo.Fn_generateordercode(@OrderID INT)
returns VARCHAR(10)
AS
  BEGIN
      RETURN 'ORD-'
             + Stuff(Replicate('0', 6), Len(Replicate('0', 6)) - (Len(@OrderID)
             - 1),
             Len(@OrderID), @OrderID);
  END

SELECT *,
       dbo.Fn_generateordercode(orderid) OrderCode
FROM   orders; 

-- #6 
CREATE TABLE products
  (
     productid INT PRIMARY KEY,
     NAME      NVARCHAR(100),
     price     DECIMAL(10, 2),
     category  NVARCHAR(50)
  );

INSERT INTO products
VALUES      (1,
             'Laptop',
             800,
             'Electronics'),
            (2,
             'Banana',
             1,
             'Food'),
            (3,
             'Headphones',
             50,
             'Electronics');

CREATE FUNCTION dbo.Fn_calctax(@ProductPrice    DECIMAL(10, 2),
                               @ProductCategory NVARCHAR(50))
returns DECIMAL(10, 2)
AS
  BEGIN
      RETURN CASE @ProductCategory
               WHEN 'Electronics' THEN @ProductPrice * 0.2
               WHEN 'Food' THEN @ProductPrice * 0.05
               ELSE @ProductPrice * 0.1
             END;
  END

SELECT *,
       dbo.Fn_calctax(price, category) Tax
FROM   products 