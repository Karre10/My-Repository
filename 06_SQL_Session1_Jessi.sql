select @@SERVERNAME   --RDUSQLSCR01\SCRATCH2012R2
Use Training_June2023_SQL  ---- SESSION 1 

------------------------------------------------------------------------------------------------------------ Section 1.0 - See data from R:\01_REFERENCES\TrainingMaterials\CatModelingTraining_2021\TrainingPresentations\03_SQL_Session1&2_Jessi

-- Create a new database on this scratch server with the name "FirstName_LastName_Working" for example: John_Doe_Working
-- Import raw .csv data into your new database from directory referenced above for this section lesson
-- Import data from another database:  Import the [State_Abbrev] table from the database [Common_2021] into your working database

-- Deleting tables (TAKE CAUTION WHEN DELETING): Use the following script to delete tables you don't want
Drop table 

------------------------------------------------------------------------------------------------------------ Section 1.1
-- Comments out a line with 2 hyphens.  
/*
Comments out everything between these characters.

Comments are important in noting what you are doing and why and what output you get.  A lot of times we include as a comment control totals or number of rows affected 
so that we can keep track of important infomation as we query the data
*/

------------------------------------------------------------------------------------------------------------ Section 1.2 - Requesting & Filtering & Group By

/*  This is the general order of a general select query

SELECT column_name(s)
FROM table_name
WHERE condition						 <-- Filtering
GROUP BY column_name(s)	 <-- Aggregating
HAVING condition						 <-- Filtering aggregated data
ORDER BY column_name(s);
*/

-- Display Data
select * from [dbo].[RentalPrices] -- look at the whole table
--12133 rows
select top 10 * from RentalPrices -- look at a few rows
select State, Regionname as City from RentalPrices -- look at certain columns & use of an alias named "City"
select * from [Common_2021].[dbo].[State_Abbrev] -- even though you are "using" a certain database you can still get data from other databases using this format
select * from [Common_2021]..[State_Abbrev]

select distinct numbedrooms
from RentalPrices


alter table [dbo].[RentalPrices] alter column MedianPrice float

-- Filter data using different qualifiers
select State, CountyName, format(MedianPrice,'n0') as MedianRent 
from RentalPrices
where NumBedrooms = '5+' and MedianPrice <= 5000 and MedianPrice <> 0
order by MedianPrice desc

select * from RentalPrices
where Metro like '%Tampa%' -- use of the wildcard qualifier "%"

select * from RentalPrices
where State in ('NY','MA') and Numbedrooms in ('1','2') and year = 2019 -- can also use "or" and a combination of both
order by MedianPrice asc

select * from RentalPrices
where Metro is NULL

select * from RentalPrices
where Metro is NOT NULL

--(Practice) What counties in NY have median rent prices higher than $3,000?
-- Answer:


--(Practice) What is the range of rent prices in 2017 for studio appartments in the MN Minneapolis and St.Paul metro?
-- Answer:


-- Aggregate Data
select distinct State from RentalPrices
order by State
-- All states accounted for with the inclusion of D.C.

select State from RentalPrices
group by State
order by State

select State, RegionName from RentalPrices
group by State, RegionName 
order by State, RegionName 

select distinct State, RegionName from RentalPrices
order by State, RegionName 

-- Arithmetic (need group by and columns must be of the right type)
Sum()
Avg()
Max()
Min()
Count() 

select Count(*) as numrecords from RentalPrices ---we use count a lot as a check.  Column name is an alias
--12133 ... This is the total number of rows in this table

select Sum(MedianPrice) as Sum, Avg(MedianPrice) as avg, Min(MedianPrice)min, Max(MedianPrice)max, Count(*) NumRecords from RentalPrices

select Year, Sum(MedianPrice)Sum, Avg(MedianPrice) avg, Min(MedianPrice)min, Max(MedianPrice)max from RentalPrices
group by Year -- need group that names every column you want breakouts for
order by Year asc

--(Practice) What are all the values used in the columns NumBedrooms, and year (this is a form of profiling the data)?
-- Answer:



--(Practice) What state(s) have the highest median rent in general?  What is the amount?  Provide the other qualitative information for the answers, that is what year, county and bedroom size for the anwers to the previous question?
-- Answer:



--There are other ways of answering this questions especially if we have more tools like those in session #2

--(Practice) Are there any duplicate records or records with all information the same except the MedianPrice? *Duplicates are very important to look for in our work to avoid double counting / joining (joins come up in session #2)*
-- Answer:

------------------------------------------------------------------------------------------------------------ Section 1.3 

select * from RentalPrices
-- Nested query
select *
from(
		select State, Year, Sum(MedianPrice)sum, Avg(MedianPrice) avg, Min(MedianPrice)min, Max(MedianPrice)max from RentalPrices
		group by State,Year
		--order by Year asc --- cannot have "order by" in inner query when nesting
		)a -- Must have this alias referring to the table that is created from the inner query
where State = 'NY'

-- Stack Data
select RegionName, State from RentalPrices
union all
select RegionName, State from RentalPrices -- Must have same number of columns that have the same type and name/alias
--24266 rows = twice that of RentalPrices 12133

-- Case Statements
select * 
from(
			select a.*
				, case when MedianPrice <= 1000 then '1. Less than $1000'
				when MedianPrice > 1000 and MedianPrice <= 2000 then '2.  ($1000, $2000]'
				when MedianPrice > 2000 and MedianPrice  <= 3000 then '3. ($2000, $3000]'
				else '4. Greater than $3000' end as MedianPriceBuckets
			from RentalPrices a
			)b
where MedianPriceBuckets like '4.%'

select * from RentalPrices

--(Practice) Write a query that adds a column that buckets the rent price into groups where the rental prices fall in the buckets, [0,1000], (1000,2000], (2000, 3000], ..., (max(MedianPrice)]-1000, max(MedianPrice)].  (Hint) it is nice to use excel to write most of the query for using functions and then paste it into SQL
-- Answer:



--(Practice) Using the above query how many records are in highest bucket, (max(MedianPrice)]-1000, max(MedianPrice)], by year?
-- Answer:



