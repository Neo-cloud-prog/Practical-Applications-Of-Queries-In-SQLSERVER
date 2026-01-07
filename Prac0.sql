-- select * from VehicleDetails where Year between 1950 and 2000

-- select Count(*) as NumberOfVehicles from VehicleDetails where Year between 1950 and 2000

-- select Make, Count(*) as NumberOfVehicles from VehicleDetails inner join Makes on Makes.MakeID = VehicleDetails.MakeID where Year between 1950 and 2000 group by Make order by NumberOfVehicles Desc

-- select * from (select Make, Count(*) as NumberOfVehicles from VehicleDetails inner join Makes on Makes.MakeID = VehicleDetails.MakeID where Year between 1950 and 2000 group by Make) R1 where NumberOfVehicles > 12000 order by NumberOfVehicles Desc

-- select Make, Count(*) as NumberOfVehicles from VehicleDetails inner join Makes on Makes.MakeID = VehicleDetails.MakeID where Year between 1950 and 2000 group by Make having Count(*) > 12000 order by NumberOfVehicles Desc

-- select Make, Count(*) as NumberOfVehicles, (select Count(*) from VehicleDetails) as TotalVehicles from VehicleDetails inner join Makes on Makes.MakeID = VehicleDetails.MakeID where Year between 1950 and 2000 group by Make order by NumberOfVehicles Desc

-- select Make, Count(*) as NumberOfVehicles, (select Count(*) from VehicleDetails) as TotalVehicles, CAST(Count(*) AS float) / CAST((select Count(*) from VehicleDetails) AS float) AS Perc from VehicleDetails inner join Makes on Makes.MakeID = VehicleDetails.MakeID where Year between 1950 and 2000 group by Make order by NumberOfVehicles Desc

 -- select *, cast(NumberOfVehicles as float) / cast(TotalVehicles as float) as Perc From 
 -- (
 --  select Make, Count(*) as NumberOfVehicles, (select Count(*) from VehicleDetails) as TotalVehicles from VehicleDetails inner join Makes on Makes.MakeID = VehicleDetails.MakeID where Year between 1950 and 2000 group by Make
 -- ) R1 order by NumberOfVehicles Desc

-- select Make, FuelTypeName, COUNT(*) as NumberOfVehicles From VehicleDetails 
-- inner join Makes on Makes.MakeID = VehicleDetails.MakeID
-- inner join FuelTypes on FuelTypes.FuelTypeID = VehicleDetails.FuelTypeID
-- where Year between 1950 and 2000
-- group by Make, FuelTypeName order by Makes.Make

-- select VehicleDetails.*, FuelTypes.FuelTypeName from VehicleDetails
-- inner join FuelTypes on FuelTypes.FuelTypeID = VehicleDetails.FuelTypeID
-- where FuelTypes.FuelTypeName = N'GAS'

-- select distinct Makes.Make, FuelTypes.FuelTypeName from VehicleDetails
-- inner join Makes on Makes.MakeID = VehicleDetails.MakeID
-- inner join FuelTypes on FuelTypes.FuelTypeID = VehicleDetails.FuelTypeID
-- where FuelTypes.FuelTypeName = N'GAS' order by Make

--select count(*) as TotalMakesRunsOnGas from 
--(
-- select distinct Makes.MakeID from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--inner join FuelTypes on FuelTypes.FuelTypeID = VehicleDetails.FuelTypeID
--where FuelTypes.FuelTypeName = N'GAS'
--)R1

--select count(*) as TotalMakesRunsOnGas from 
--(
--select distinct Makes.Make, FuelTypes.FuelTypeName from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--inner join FuelTypes on FuelTypes.FuelTypeID = VehicleDetails.FuelTypeID
--where FuelTypes.FuelTypeName = N'GAS'
--)R1

--select Make, Count(*) as NumberOfMakes from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--group by Make order by NumberOfMakes desc

--select Make, Count(*) as NumberOfMakes from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--group by Make having Count(*) > 20000 order by NumberOfMakes desc


--select * From 
--(
--select Make, Count(*) as NumberOfMakes from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--group by Make
--)R1 
--where NumberOfMakes > 20000
--order by NumberOfMakes desc

--SELECT Makes.Make FROM Makes where Makes.Make like 'B%';

--SELECT Makes.Make FROM Makes where Makes.Make like '%W';

--SELECT distinct Makes.Make, DriveTypes.DriveTypeName FROM DriveTypes
--INNER JOIN VehicleDetails ON DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID 
--INNER JOIN Makes ON VehicleDetails.MakeID = Makes.MakeID
--Where DriveTypes.DriveTypeName ='FWD'

--select Make, DriveTypeName from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--inner join DriveTypes on DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID
--where DriveTypes.DriveTypeName = 'FWD'

--select Count(*) MakeWithFWD From 
--(
--SELECT distinct Makes.Make, DriveTypes.DriveTypeName FROM DriveTypes
--INNER JOIN VehicleDetails ON DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID 
--INNER JOIN Makes ON VehicleDetails.MakeID = Makes.MakeID
--Where DriveTypes.DriveTypeName ='FWD'
--)R1

--select Make, DriveTypeName,Count(*) TotalVehicles from VehicleDetails
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--inner join DriveTypes on DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID
--group by DriveTypeName, Make
--order by  Make asc, TotalVehicles desc

--SELECT distinct Makes.Make, DriveTypes.DriveTypeName, Count(*) AS Total FROM DriveTypes 
--INNER JOIN VehicleDetails ON DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID 
--INNER JOIN Makes ON VehicleDetails.MakeID = Makes.MakeID
--Group By Makes.Make, DriveTypes.DriveTypeName
--Order By Make ASC, Total Desc

--SELECT distinct Makes.Make, DriveTypes.DriveTypeName, Count(*) AS Total FROM DriveTypes 
--INNER JOIN VehicleDetails ON DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID 
--INNER JOIN Makes ON VehicleDetails.MakeID = Makes.MakeID
--Group By Makes.Make, DriveTypes.DriveTypeName
--Having Count(*) > 10000
--Order By Make ASC, Total Desc

--select * from VehicleDetails where NumDoors is NULL

--select Cast((select COUNT(*) TotalWithNoSpecifiedDoors from VehicleDetails where NumDoors is NULL) as float) / Cast(Count(*) as float) as PercOfNoSpecifiedDoors From VehicleDetails

--select (CAST((select count(*) as TotalWithNoSpecifiedDoors from VehicleDetails where NumDoors is Null) as float) / Cast((select count(*) from VehicleDetails as TotalVehicles) as float)) as PercOfNoSpecifiedDoors

--select distinct Makes.*, SubModelName from VehicleDetails 
--inner join Makes on Makes.MakeID = VehicleDetails.MakeID
--inner join SubModels on VehicleDetails.SubModelID = SubModels.SubModelID
--where SubModelName = 'Elite'

--SELECT distinct VehicleDetails.MakeID, Makes.Make, SubModelName FROM VehicleDetails 
--INNER JOIN SubModels ON VehicleDetails.SubModelID = SubModels.SubModelID 
--INNER JOIN Makes ON VehicleDetails.MakeID = Makes.MakeID
--where SubModelName='Elite'

--select * From VehicleDetails where Engine_Liter_Display > 3 and NumDoors = 2

--select Make, VehicleDetails.* From VehicleDetails
--INNER JOIN Makes ON VehicleDetails.MakeID = Makes.MakeID
--where Engine Like '%OHV%' and Engine_Cylinders = 4

--select BodyName, VehicleDetails.* From VehicleDetails inner join Bodies on VehicleDetails.BodyID = Bodies.BodyID where Year > 2020 and BodyName = 'Sport Utility'

--select BodyName, VehicleDetails.* From VehicleDetails inner join Bodies on VehicleDetails.BodyID = Bodies.BodyID where BodyName IN ('Coupe', 'Hatchback', 'Sedan')

--select BodyName, VehicleDetails.* From VehicleDetails inner join Bodies on VehicleDetails.BodyID = Bodies.BodyID where BodyName IN ('Coupe', 'Hatchback', 'Sedan') and Year IN (2008, 2020, 2021)

--IF EXISTS (SELECT top 1 b = 1 FROM VehicleDetails WHERE Year = 1950)
--BEGIN
--    PRINT '1';
--END
--ELSE
--BEGIN
--    PRINT '0';
--END

--select found = 1 where exists (select top 1 v = 1 from VehicleDetails where Year = 1950)

--SELECT
--    Vehicle_Display_Name,
--	NumDoors,
--    CASE
--	    WHEN NumDoors = 0 THEN 'Zero Doors'
--        WHEN NumDoors = 1 THEN 'One Door'
--        WHEN NumDoors = 2 THEN 'Tow Doors'
--		WHEN NumDoors = 3 THEN 'Three Doors'
--		WHEN NumDoors = 4 THEN 'Four Doors'
--		WHEN NumDoors = 5 THEN 'Five Doors'
--		WHEN NumDoors = 6 THEN 'Six Doors'
--		WHEN NumDoors = 8 THEN 'Eight Doors'
--        ELSE 'Not Set'
--    END AS NumDoorsName
--FROM VehicleDetails;

--SELECT
--    Vehicle_Display_Name,
--	NumDoors,
--    CASE
--	    WHEN NumDoors = 0 THEN 'Zero Doors'
--        WHEN NumDoors = 1 THEN 'One Door'
--        WHEN NumDoors = 2 THEN 'Tow Doors'
--		WHEN NumDoors = 3 THEN 'Three Doors'
--		WHEN NumDoors = 4 THEN 'Four Doors'
--		WHEN NumDoors = 5 THEN 'Five Doors'
--		WHEN NumDoors = 6 THEN 'Six Doors'
--		WHEN NumDoors = 8 THEN 'Eight Doors'
--        WHEN NumDoors is null THEN 'Not Set'
--		ELSE 'Unknown'
--    END AS NumDoorsName
--FROM VehicleDetails;

-- select Vehicle_Display_Name, Year, Age = YEAR(GETDATE()) - VehicleDetails.Year from VehicleDetails order by Age desc

--select * from
--(
--select Vehicle_Display_Name, Year, Age = YEAR(GETDATE()) - VehicleDetails.Year from VehicleDetails
--)R1 where Age between 15 and 25
--order by Age desc

--select  Min(Engine_CC) as MinimimEngineCC,Max(Engine_CC) as MaximumEngineCC, AVG(Engine_CC)  as AverageEngineCC from VehicleDetails

--select VehicleDetails.Vehicle_Display_Name From VehicleDetails where Engine_CC = (select Min(Engine_CC) as MinEngineCC From VehicleDetails)

--select VehicleDetails.Vehicle_Display_Name from VehicleDetails where Engine_CC = (select  Max(Engine_CC) as MinEngineCC  from VehicleDetails)

--select VehicleDetails.Vehicle_Display_Name from VehicleDetails where Engine_CC < (select avg(Engine_CC) as MinEngineCC from VehicleDetails)

--select COUNT(*) as NumberOfVehiclesAboveAverageEngineCC from VehicleDetails where Engine_CC > (select avg(Engine_CC) as MinEngineCC from VehicleDetails)
--select COUNT(*) as NumberOfVehiclesAboveAverageEngineCC from (select a = 1 from VehicleDetails where Engine_CC > (select avg(Engine_CC) as MinEngineCC from VehicleDetails))R1
--select Count(*) as NumberOfVehiclesAboveAverageEngineCC from (Select ID,VehicleDetails.Vehicle_Display_Name from VehicleDetails where Engine_CC > ( select  Avg(Engine_CC) as MinEngineCC  from VehicleDetails )) R1

--select distinct Engine_CC from VehicleDetails order by Engine_CC desc

--select distinct top 3 Engine_CC from VehicleDetails order by Engine_CC desc

-- select Vehicle_Display_Name from VehicleDetails where Engine_CC in (select distinct top 3 Engine_CC from VehicleDetails order by Engine_CC desc)

--select distinct Makes.Make from VehicleDetails
--inner join Makes on VehicleDetails.MakeID = Makes.MakeID
--where (VehicleDetails.Engine_CC in (select distinct top 3 VehicleDetails.Engine_CC from VehicleDetails order by Engine_CC desc))
--order by Make

--select Engine_CC,
--  CASE 
--   WHEN Engine_CC between 0 and 1000 THEN 100
--   WHEN Engine_CC between 1001 and 2000 THEN 200
--   WHEN Engine_CC between 2001 and 4000 THEN 300
--   WHEN Engine_CC between 4001 and 6000 THEN 400
--   WHEN Engine_CC between 6001 and 8000 THEN 500
--   WHEN Engine_CC > 8000 THEN 600
--   ELSE 0
--  END
--  AS Tax
--from VehicleDetails group by Engine_CC order by Engine_CC


--select Engine_CC,
--	CASE
--		 WHEN Engine_CC between 0 and 1000 THEN 100
--		 WHEN Engine_CC between 1001 and 2000 THEN 200
--		 WHEN Engine_CC between 2001 and 4000 THEN 300
--		 WHEN Engine_CC between 4001 and 6000 THEN 400
--		 WHEN Engine_CC between 6001 and 8000 THEN 500
--		 WHEN Engine_CC > 8000 THEN 600	
--		 ELSE 0
--	END as Tax
--from 
--(
--	select distinct Engine_CC from VehicleDetails
--) R1
--order by Engine_CC

--select Make, Sum(NumDoors) TotalNumberOfDoors from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID group by Make Order By TotalNumberOfDoors desc

--select Makes.Make, Sum(NumDoors) AS TotalNumberOfDoors from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID group by Make having Make = 'Ford'

--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--Order By NumberOfModels Desc

--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM MakeModels 
--INNER JOIN Makes ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--Order By NumberOfModels Desc

--SELECT ModelName, COUNT(*) AS NumberOfModels FROM MakeModels 
--INNER JOIN Makes ON Makes.MakeID = MakeModels.MakeID
--GROUP BY MakeModels.ModelName
--Order By NumberOfModels Desc

--SELECT top 3 Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--Order By NumberOfModels Desc

--SELECT top 1 COUNT(*) AS MaxNumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--Order By MaxNumberOfModels Desc

--select Max(NumberOfModels) as MaxNumberOfModels from
--( 
--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make		
--)R1

--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--having COUNT(*) = (SELECT top 1 COUNT(*) AS NumberOfModels FROM MakeModels GROUP BY MakeID Order By NumberOfModels Desc)

--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--having COUNT(*) = (select MAX(NumberOfModels) as MaxNumberOfModels from (SELECT MakeID, COUNT(*) AS NumberOfModels FROM MakeModels GROUP BY MakeID) R1)

--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--having COUNT(*) = (SELECT top 1 COUNT(*) AS NumberOfModels FROM MakeModels GROUP BY MakeID Order By NumberOfModels)

--SELECT Makes.Make, COUNT(*) AS NumberOfModels FROM Makes 
--INNER JOIN MakeModels ON Makes.MakeID = MakeModels.MakeID
--GROUP BY Makes.Make
--having COUNT(*) = (select MIN(NumberOfModels) as MaxNumberOfModels from (SELECT MakeID, COUNT(*) AS NumberOfModels FROM MakeModels GROUP BY MakeID) R1)

--select * from FuelTypes order by NEWID()

------------------------------------------------------------------------------------------------------------------------

-- RESTORE DATABASE EmployeesDB FROM DISK = 'C:\EmployeesDB.bak'

--select Employees.Name, Managers.Name as ManagerName, Employees.Salary From Employees as Managers inner join Employees on Managers.EmployeeID = Employees.ManagerID
--SELECT Employees.Name, Employees.ManagerID, Employees.Salary, Managers.Name AS ManagerName FROM Employees INNER JOIN Employees AS Managers ON Employees.ManagerID = Managers.EmployeeID

--SELECT Employees.Name, Employees.ManagerID, Employees.Salary,
--CASE
-- WHEN Managers.Name is NULL THEN Employees.Name
-- ELSE Managers.Name
--END AS ManagerName 
--FROM Employees Left outer JOIN Employees AS Managers ON Employees.ManagerID = Managers.EmployeeID

--select Employees.Name, Managers.Name as ManagerName, Employees.Salary From Employees as Managers inner join Employees on Managers.EmployeeID = Employees.ManagerID where Managers.Name = 'Mohammed'
