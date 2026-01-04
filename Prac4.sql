CREATE TABLE sales3
  (
     id       INT PRIMARY KEY,
     product  VARCHAR(50),
     category VARCHAR(50),
     qty      INT,
     price    DECIMAL(10, 2)
  );

INSERT INTO sales3
            (id,
             product,
             category,
             qty,
             price)
VALUES      (1,
             'Book',
             'Education',
             2,
             10.00),
            (2,
             'Pen',
             'Education',
             5,
             2.00),
            (3,
             'Laptop',
             'Electronics',
             1,
             900.00),
            (4,
             'Mouse',
             'Electronics',
             3,
             20.00),
            (5,
             'Book',
             'Education',
             1,
             10.00),
            (6,
             'Pen',
             'Education',
             10,
             2.00),
            (7,
             'Laptop',
             'Electronics',
             2,
             900.00),
            (8,
             'Mouse',
             'Electronics',
             1,
             20.00); 
			 
-- #1 
SELECT category,
       Sum(qty) Total
FROM   sales3
GROUP  BY category 

-- #2 
SELECT category,
       Sum(qty * price) TotalRevenue
FROM   sales3
GROUP  BY category 

-- #3
SELECT category,
       Sum(qty * price) TotalRevenue
FROM   sales3
GROUP  BY category
HAVING Sum(qty * price) > 1000 

-- #4 
SELECT category,
       Count(*) AS TotalProducts
FROM   (SELECT DISTINCT category,
                        product
        FROM   sales3) AS R1
GROUP  BY category 
-- or
select Category, count(distinct Product) as TotalProducts
from Sales3
group by Category;


-- #5 
SELECT category,
       Count(*) AS TotalProducts
FROM   (SELECT DISTINCT category,
                        product
        FROM   sales3) AS R1
GROUP  BY category
HAVING Count(*) > 2
-- or
select Category, count(distinct Product) as TotalProducts
from Sales3
group by Category
having count(distinct Product) > 2;


-- #6 
SELECT category,
       product,
       Sum(qty) AS TotalQ
FROM   sales3
GROUP  BY category,
          product
HAVING Sum(qty) IN (SELECT maxq
                    FROM   (SELECT category,
                                   Max(totalq) AS MaxQ
                            FROM   (SELECT category,
                                           product,
                                           Sum(qty) AS TotalQ
                                    FROM   sales3
                                    GROUP  BY category,
                                              product) AS R1
                            GROUP  BY category) AS R2); 
-- or
with SalesAgg as (
    select 
        Category,
        Product,
        sum(Qty) as TotalQ,
        dense_rank() over (partition by Category order by sum(Qty) desc) as rn
    from Sales3
    group by Category, Product
)
select Category, Product, TotalQ
from SalesAgg
where rn = 1;

-- or
WITH ProdAgg AS (
    SELECT Category, Product, SUM(Qty) AS TotalQ
    FROM Sales3
    GROUP BY Category, Product
),
MaxAgg AS (
    SELECT Category, MAX(TotalQ) AS MaxQ
    FROM ProdAgg
    GROUP BY Category
)
SELECT p.Category, p.Product, p.TotalQ
FROM ProdAgg p
JOIN MaxAgg m
   ON p.Category = m.Category
  AND p.TotalQ   = m.MaxQ;


-- #7 
SELECT product,
       Sum(qty) Total
FROM   sales3
GROUP  BY product
HAVING Sum(qty) > 10 

-- #8 
SELECT category,
       Avg(price) AvgP
FROM   sales3
GROUP  BY category
HAVING Avg(price) > 50 

-- #9
select Category,
       sum(Qty * Price) * 1.0 / sum(Qty) as WeightedAvgPrice
from Sales3
group by Category
having sum(Qty * Price) * 1.0 / sum(Qty) > 50;
