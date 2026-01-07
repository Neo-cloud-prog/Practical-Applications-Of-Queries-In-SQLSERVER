-- 00
select
 CASE 
  WHEN (A + B) <= C or (B + C) <= A or (A + C) <= B THEN "Not A Triangle"
  WHEN A = B and B = C THEN "Equilateral"
  WHEN A = B or B = C or A = C THEN "Isosceles"
  WHEN Not (A = B) and Not (B = C) THEN "Scalene"
 END
from TRIANGLES;

--00
SELECT Name + '(' + SUBSTRING(OCCUPATION, 1, 1) + ')' FROM OCCUPATIONS ORDER BY Name ASC;
SELECT "There are a total of " + Cast(COUNT(*) AS Char) + " " + LOWER(OCCUPATION) + 's.' FROM OCCUPATIONS GROUP BY OCCUPATION ORDER BY COUNT(*);