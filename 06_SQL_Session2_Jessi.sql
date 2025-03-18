select @@SERVERNAME   --RDUSQLSCR01\SCRATCH2012R2
Use Training_June2023_SQL  ---- SESSION 2
------------------------------------------------------------------------------------------------------------ Section 2.1 - Joins
-- Inner Join/join (intersection of the tables)
select * from [Common_2021].[dbo].[Counties] --3151
select * from [Common_2021].[dbo].[State_Abbrev] --51


select statecode
from [Common_2021].[dbo].[Counties] 
join [dbo].[State_Abbrev] on [Common_2021].[dbo].[Counties].STATECODE = [State_Abbrev].[State Abbrev]
group by statecode
order by statecode

select a.StateCode, [State Name], [State Abbrev]
from [Common_2021].[dbo].[Counties] a
join [Common_2021].[dbo].[State_Abbrev] b on a.StateCode = b.[State Abbrev]
group by a.StateCode, [State Name] , [State Abbrev]
order by  a.StateCode, [State Name]

 
select a.*, b.[State Name]
from [Common_2021].[dbo].[Counties] a
inner join [Common_2021].[dbo].[State_Abbrev] b on a.StateCode = b.[State Abbrev] 
order by  a.StateCode, [State Name] 


-- Left join (data within first table)
select a.StateCode as A, b.StateCode as B
from [Common_2021].[dbo].[Counties] a
left join (select StateCode from [Common_2021].[dbo].[Counties] where countyShort = 'Jefferson' group by StateCode) b on a.StateCode = b.StateCode -- recall nested/sub-query
where b.StateCode is NULL -- Look at with and without this line
group by a.StateCode , b.StateCode 
order by a.StateCode

-- outer join 
select a.StateCode A, b.StateCode  B
from (select StateCode from [Common_2021].[dbo].[Counties] where Countyshort = 'Adams' group by StateCode) a
Full Outer join (select StateCode from [Common_2021].[dbo].[Counties] where countyShort = 'Jefferson' group by StateCode) b on a.StateCode = b.StateCode
where b.StateCode  is NULL or a.stateCode is NULL  -- Look at with and without this line
group by a.StateCode , b.StateCode 
order by a.StateCode

--- Might need to join on more than 1 column
select * from RentalPrices--12,133 rows 
select * from [Common_2021].[dbo].[Counties]

select * from RentalPrices a
join [Common_2021].[dbo].[Counties] b on a.State = b.STATECODE and a.CountyName = b.AIR_County
-- Hmm only 11541 are joining out of 12133 rows in table a.  See HW for investigative assignment
--(11541 rows affected)

select * from RentalPrices a
full outer join [Common_2021].[dbo].[Counties] b on a.State = b.STATECODE and a.CountyName = b.AIR_County
where a.State is null or b.StateCode is null
-- Hmm only 11541 are joining out of 12133 rows in table a.  See HW for investigative assignment
--(11541 rows affected)
select * from [Common_2021].[dbo].[Counties]  where STATECODE = 'FL' order by AIR_County --St. Johns County
--Miami-Dade County

-- Join on more than 1 table
select * from RentalPrices a
join [Common_2021].[dbo].[Counties] b on a.State = b.STATECODE and a.CountyName = b.AIR_County
join [Common_2021].[dbo].[State_Abbrev] c on b.StateCode = c.[State Abbrev]  

select b.*
from RentalPrices a
join [Common_2021].[dbo].[Counties] b on a.State = b.STATECODE and a.CountyName = b.AIR_County
join [Common_2021].[dbo].[State_Abbrev] c on b.StateCode = c.[State Abbrev]  

select *
from RentalPrices

--(Practice) What states have counties named Washington and the same state not having a county named Adams? What about vice versa?
-- Answer:


------------------------------------------------------------------------------------------------------------ Section 2.2 - Editing data

select *
from rentalprices

select *
into RentalPrices_Orig
from RentalPrices

select *
from a_USCityPopulations

select *
from rentalprices

-- Select Into
select a.State, RegionName, Metro, CountyShort as County, FIPS, POP_2010, MedianPrice, NumBedrooms, Year
into Temp_JS_RentalPrice_wCityPop
from RentalPrices a
join [Common_2021].[dbo].[Counties] b on a.State = b.STATECODE and a.CountyName = b.AIR_County -- I know not all will join. we'll just deal with the data we have for now
join (select State_FIPS, CountyFIPS, Sum(POP_2010) as POP_2010
		from(
			select State_FIPS, CountyFIPS, Case when POP_2010 >0 then POP_2010 else 0 end as POP_2010
			from a_USCityPopulations 
			)b group by State_FIPS, CountyFIPS
		)c on c.STATE_FIPS = b.STATEFIPS and c.COUNTYFIPS = b.COUNTYCODE
--(11541 row(s) affected) <-- this helps to check if you have done things correctly.
-- refresh DB to see the added table

select * from Temp_JS_RentalPrice_wCityPop

-- Delete a table (CAUTION!!) A lot of the time I will comment out my DROP TABLE query to avoid accidentally running it
-- Drop table Temp_JS_RentalPrice_wCityPop   

-- Create blank table then populate it
-- drop table TEMP_JS
Create Table TEMP_JS(State Varchar(2), RegionName Varchar(100), Metro Varchar(100), County Varchar(100), FIPS Varchar(5), POP int, MedianPrice float, NumBedrooms Varchar(100), Year int)

select *
from TEMP_JS

insert into TEMP_JS 
select a.State, RegionName, Metro, CountyShort as County, FIPS, POP_2010 as POP, MedianPrice, NumBedrooms, Year
from RentalPrices a
join [Common_2021].[dbo].[Counties] b on a.State = b.STATECODE and a.CountyName = b.AIR_County -- I know not all will join. we'll just deal with the data we have for now
join (select State_FIPS, CountyFIPS, Sum(POP_2010) as POP_2010
		from(
			select State_FIPS, CountyFIPS, Case when POP_2010 >0 then POP_2010 else 0 end as POP_2010
			from a_USCityPopulations 
			)b group by State_FIPS, CountyFIPS
		)c on c.STATE_FIPS = b.STATEFIPS and c.COUNTYFIPS = b.COUNTYCODE
--(11541 row(s) affected) 

-- Can choose to continue to populate table with more information using insert again and again
-- Can choose to only populate some of the columns

insert into TEMP_JS(Year)
select 2020
--(1 row(s) affected)


select * from TEMP_JS
where Year = 2020

insert into TEMP_JS
select 'MN' as state, 'Minneapolis' as regionname, 'Minneapolis' as metro, 'Hennepin' as County, '00000' as Fips, 300000 as POP, 1800 as MedianPrice, '4' as NumBedrooms, 2021 as year


select * from TEMP_JS
where Year in (2020, 2021)

insert into TEMP_JS
select *
from TEMP_JS
where year = 2021

select * from TEMP_JS
where Year = 2021

--- This same query lists the table's column types
select column_name, data_type from information_schema.columns
where table_name = 'Temp_JS_RentalPrice_wCityPop' 
-- Hmm I might not want the year to be a varchar  lets change it to int

-- Delete & Drop &Alter & Update 
Delete from TEMP_JS where Year = 2020

select *
from TEMP_JS
where year = 2020

delete from TEMP_JS where year = 2021

Alter table Temp_JS_RentalPrice_wCityPop alter column year int  -- change the column type
Alter table Temp_JS_RentalPrice_wCityPop add NewCol varchar(200), ABCD float  -- add a new column

Alter table Temp_JS_RentalPrice_wCityPop drop column NewCol

select top 10* from Temp_JS_RentalPrice_wCityPop

Update Temp_JS_RentalPrice_wCityPop 
set NewCol = case 
when MedianPrice >= 0 and  MedianPrice <= 1000 then 'A. Less than $1000'
when MedianPrice > 1000 and MedianPrice <= 2000 then 'B.  ($1000, $2000]'
when MedianPrice > 2000 and MedianPrice  <= 3000 then 'C. ($2000, $3000]'
when medianprice > 3000 then 'D. Greater than $3000'
else 'ERROR' end 
, ABCD = .983


select NewCol,ABCD,Count(*) from Temp_JS_RentalPrice_wCityPop
group by NewCol,ABCD

select *
from Temp_JS_RentalPrice_wCityPop

alter table Temp_JS_RentalPrice_wCityPop add New_Old varchar(1)

select distinct year from Temp_JS_RentalPrice_wCityPop

update Temp_JS_RentalPrice_wCityPop
set New_Old = 'O' 
where year < 2018


------------------------------------------------------------------------------------------------------------ Section 2.3 - Miscellaneous
--Rename Column (can also just rename mannually by expanding columns in the Object explorer and right clicking)
EXEC sp_rename 'Temp_JS_RentalPrice_wCityPop.NewCol','RentBands','Column';

select * from Temp_JS_RentalPrice_wCityPop

--Unique integer for each row
Alter table Temp_JS_RentalPrice_wCityPop add ID int Identity (1,1)

select * from Temp_JS_RentalPrice_wCityPop

--Data type
select column_name, data_type from information_schema.columns
where table_name = 'Temp_JS_RentalPrice_wCityPop' 
-- Sometimes when you perform arithmatic, it will not work because the data types are not compatible so you must alter the column type or convert the typesee below.



-- Functions
select Len(FIPS) from Temp_JS_RentalPrice_wCityPop
group by Len(FIPS)

select *
from Common_2021..counties
select state, fips
from Temp_JS_RentalPrice_wCityPop

select State, FIPS, Left(FIPS,2) as StateFIPS from Temp_JS_RentalPrice_wCityPop
group by State, FIPS, Left(FIPS,2)

select *
from [RentalPrices]

select CountyName, Replace(CountyName, ' County','') CountyShort from [dbo].[RentalPrices]
group by CountyName, Replace(CountyName, ' County','')


select State,County,State_FIPS,COuntyFIPS, CONCAT(State_FIPS,COuntyFIPS) as FIPS from [dbo].[a_USCityPopulations]
group by State,County,State_FIPS,COuntyFIPS, CONCAT(State_FIPS,COuntyFIPS) 

select FIPS, Convert(float, FIPS) from Temp_JS_RentalPrice_wCityPop
group by FIPS, Convert(float, FIPS)
order by FIPS


-- Row_Number() Over([Partition by ]) : Sequentially numbers the rows within a partition of a results set starting at 1 (One use is for calculating an EP curve from a YELT) 

select Row_Number()Over(order by MedianPrice desc) PriceRank, a.* from Temp_JS_RentalPrice_wCityPop a
-- This orders the data from highest to lowest Price and addes the row number.  If there are ties then in randomly orders the ones that are tied

select * 
from(select Row_Number()Over(Partition by State order by MedianPrice desc) as PriceRank, a.* from Temp_JS_RentalPrice_wCityPop a
		) a 
--order by PriceRank asc
where PriceRank =1
-- Same as above except that the row number restarts at 1 for every partition.  
-- The result gives you the price rank by state


--(Practice) Rank the MedianPrice by state, year and number of bedrooms.  What counties have the highest rent prices for studio appartments in each year in MN?  What about 1 and 2 bedroom appartments?
-- Answer:



