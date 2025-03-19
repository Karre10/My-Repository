
SELECT @@SERVERNAME
--RDUSQLSCR02\SCRATCH2017

use Hippo_Working

--DO A SELECT * INTO A NEW 'TIGER_EDITS' table so you have a raw 'source' file.

SELECT TOP 10*
FROM Hippo_20210630_TigerEdits

--now let's create our account file
--what do we know we need? an account number!
--OFTEN POLICY_NUMBER AND ACCOUNT NUMBER ARE USED INTERCHANGEABLY.

--- unique identifier?
select policy_id, count(*)
from [Hippo_20210630_TigerEdits]
group by policy_id 
order by count(*) desc
--all unique.

select policy_number, count(*)
from [Hippo_20210630_TigerEdits]
group by policy_number 
order by count(*) desc
--all unique.

--so what else do we need in our account file for sure? POLICY TYPE!

select top 10*
from Hippo_20210630_TigerEdits
--we do have a wind exclusion field

select wind_exclusion, count(*)
from Hippo_20210630_TigerEdits
group by Wind_Exclusion

--do we have policy terms?
--no there are no blanket limits or deductibles here.

--do we have any inuring reinsurance treaties that will be applied? no.

--okay, so now that we have everything that is  *REQUIRED* for import, we should now think about adding in the fields that are best practice to include.

--always good to have a LOB. 
select product
from Hippo_20210630_TigerEdits
group by product

select carrier
from Hippo_20210630_TigerEdits
group by carrier
 
--do we have inception/expiration dates of accounts? yes!

--so let's make our account file. 

select *
from Hippo_20210630_TigerEdits

--FF
SELECT POLICY_ID ACCNTNUM, 'HIPPO' CEDANTID, 'HIPPO' CEDANTNAME, POLICY_NUMBER POLICYNUM, Product LOBNAME, 
EFFECTIVE_DATE INCEPTDATE, EXPIRATION_DATE EXPIREDATE, 1 POLICYTYPE
FROM [Hippo_20210630_TigerEdits]
--235645

--HU
SELECT POLICY_ID ACCNTNUM, 'HIPPO' CEDANTID, 'HIPPO' CEDANTNAME, POLICY_NUMBER POLICYNUM, Product LOBNAME, 
EFFECTIVE_DATE INCEPTDATE, EXPIRATION_DATE EXPIREDATE, 2 POLICYTYPE
FROM [Hippo_20210630_TigerEdits]
WHERE Wind_Exclusion <> 'TRUE'
--235,038

--SCS/WT
SELECT POLICY_ID ACCNTNUM, 'HIPPO' CEDANTID, 'HIPPO' CEDANTNAME, POLICY_NUMBER POLICYNUM, Product LOBNAME, 
EFFECTIVE_DATE INCEPTDATE, EXPIRATION_DATE EXPIREDATE, 3 POLICYTYPE
FROM [Hippo_20210630_TigerEdits]
WHERE Wind_Exclusion <> 'TRUE'
--235038

-----------
--okay now let's create our location files!
-----------

--what do we need?! account number, geographic information, location terms & risk characteristics

SELECT TOP 10*
FROM Hippo_20210630_TigerEdits

-----------
--DO WE HAVE COVERAGE VALUES?
-----------

SELECT POLICY_NUMBER, coverage_A, coverage_B, coverage_C, coverage_D
FROM [Hippo_20210630_TigerEdits]
GROUP BY POLICY_NUMBER, coverage_A, coverage_B, coverage_C, coverage_D

------------
--DO WE HAVE DEDUCTIBLE INFORMATION?
------------

--WE HAVE 3 DIFFERENT DEDUCTIBLE FIELDS: HURRICANE, WIND, AND DEDUCTIBLE.

SELECT DEDUCTIBLE, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Deductible
ORDER BY CAST(Deductible AS FLOAT) ASC
--so the deductible field has a value for EVERYTHING. and when you see an extremely low deductible, you can assume that deductible is considered to be a percentage of coverage A (this should be noted and approved
--by the client in your assumptions document)

alter table [Hippo_20210630_TigerEdits] add Deductible_FINAL float

update [Hippo_20210630_TigerEdits]
set Deductible_FINAL = case
	when deductible = 1 then cast(Coverage_A as float)*.01
	else Deductible
end
--(235645 row(s) affected)

--okay so now let's look at the wind deductible, aka SCS/WT
SELECT wind_deductible, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY wind_deductible
ORDER BY CAST(wind_deductible AS FLOAT) ASC

alter table [Hippo_20210630_TigerEdits] add wind_deductible_final float 
alter table [Hippo_20210630_TigerEdits] alter column wind_Deductible float

update [Hippo_20210630_TigerEdits]
set wind_Deductible_Final = case
	when wind_deductible = 0.5 then cast(coverage_a as float)*0.005
	when wind_deductible = 1 then cast(coverage_a as float)*0.01
	when wind_deductible = 2 then cast(coverage_a as float)*0.02
	when wind_Deductible = 3 then cast(coverage_a as float)*0.03
	when wind_deductible = 4 then cast(coverage_a as float)*0.04
	when wind_deductible = 5 then cast(coverage_a as float)*0.05
	when wind_deductible = 10 then cast(coverage_a as float)*0.1
	when wind_deductible = 1000 then 1000
	when wind_deductible = 1500 then 1500
	when wind_deductible = 2500 then 2500
	when wind_deductible = 5000 then 5000
	else Deductible_FINAL
end
--(235645 row(s) affected)

select wind_deductible, wind_Deductible_Final, count(*)
from [Hippo_20210630_TigerEdits]
group by wind_deductible, wind_Deductible_Final
order by cast(wind_deductible_final as float)

--now let's look at the hurricane deductible 
SELECT HURRICANE_dEDUCTIBLE, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY HURRICANE_dEDUCTIBLE
ORDER BY CAST(HURRICANE_dEDUCTIBLE AS FLOAT) ASC

alter table [Hippo_20210630_TigerEdits] add Hurricane_Deductible_Final float 

alter table [Hippo_20210630_TigerEdits] alter column Coverage_A float
alter table [Hippo_20210630_TigerEdits] alter column hurricane_Deductible float

update [Hippo_20210630_TigerEdits]
set Hurricane_Deductible_Final = case
	when hurricane_deductible = 0.5 then coverage_a*0.005
	when hurricane_deductible = 1 then coverage_a*0.01
	when hurricane_deductible = 2 then coverage_a*0.02
	when hurricane_Deductible = 3 then coverage_a*0.03
	when hurricane_deductible = 4 then coverage_a*0.04
	when hurricane_deductible = 5 then coverage_a*0.05
	when hurricane_deductible = 10 then coverage_a*0.1
	when hurricane_deductible = 1000 then 1000
	when hurricane_deductible = 2500 then 2500
	when hurricane_deductible = 5000 then 5000
	when hurricane_deductible = 10000 then 10000
	else wind_Deductible_Final
end
--(235645 row(s) affected)

select hurricane_Deductible, Hurricane_Deductible_final, count(*)
from [Hippo_20210630_TigerEdits]
group by hurricane_Deductible, Hurricane_Deductible_final
order by hurricane_Deductible_FINAL ASC

------------------------------------------
---NOW LET'S LOOK FOR PRIMARY MODIFIERS! Construction, Occupancy, Yearbuilt, Number of Stories.
------------------------------------------

SELECT TOP 10*
FROM Hippo_20210630_TigerEdits

--OCC
SELECT PRODUCT, NUMBER_OF_FAMILY_UNITS, COUNT(*) RISKS
FROM [Hippo_20210630_TigerEdits]
GROUP BY PRODUCT, Number_Of_Family_Units
ORDER BY PRODUCT, NUMBER_OF_FAMILY_UNITS

alter table [Hippo_20210630_TigerEdits] add RMS_OCC float 

update [Hippo_20210630_TigerEdits]
set RMS_OCC = case
	when product = 'ho6' then 43
	when product in ('dp3','ho3') and number_of_family_units in (2,3,4) then 2
	else 1
end
--(235645 row(s) affected)

SELECT PRODUCT, NUMBER_OF_FAMILY_UNITS, RMS_OCC
FROM [Hippo_20210630_TigerEdits]
GROUP BY PRODUCT, Number_Of_Family_Units, RMS_OCC
ORDER BY PRODUCT, NUMBER_OF_FAMILY_UNITS

--CONST
SELECT CONSTRUCTION_TYPE, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Construction_Type

alter table [Hippo_20210630_TigerEdits] add RMS_CONST float 

select top 10*
from [Hippo_20210630_TigerEdits]

SELECT CONSTRUCTION_TYPE, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Construction_Type

update [Hippo_20210630_TigerEdits]
set RMS_CONST = case
	when construction_type = 'brick_veneer' then 1
	when construction_type in ('concrete','concrete_or_reinforced_concrete_with_combustible') then 3
	when construction_type = 'frame' then 1
	when construction_type in ('masonry','masonry_joisted') then 2
	when construction_type in ('steel','steel_with_combustible_features') then 4
	else 0
end 
--(235645 row(s) affected)

SELECT CONSTRUCTION_TYPE, RMS_CONST
FROM [Hippo_20210630_TigerEdits]
GROUP BY Construction_Type, RMS_CONST
ORDER BY Construction_Type

ALTER TABLE [Hippo_20210630_TigerEdits] ADD Cladsys_RMS FLOAT

update [Hippo_20210630_TigerEdits]
set Cladsys_RMS = 
case when Construction_Type = 'brick_veneer' then 1 
else 0 
end
--(235645 row(s) affected)

SELECT CONSTRUCTION_TYPE, RMS_CONST, Cladsys_RMS
FROM [Hippo_20210630_TigerEdits]
GROUP BY Construction_Type, RMS_CONST, Cladsys_RMS
ORDER BY Construction_Type

--STORIES
SELECT NUMBER_OF_STORIES, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Number_Of_Stories

alter table [Hippo_20210630_TigerEdits] add numstories_final float 

update [Hippo_20210630_TigerEdits]
set numstories_final = case
	when number_of_stories = '1.5' then 2
	when number_of_stories = '2.5' then 3
	when number_of_stories = '3+' then 3
	else number_of_stories
end
--(235645 row(s) affected)

SELECT NUMBER_OF_STORIES, numstories_final
FROM [Hippo_20210630_TigerEdits]
GROUP BY Number_Of_Stories, numstories_final

--YEARBUILT
SELECT YEAR_BUILT, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY YEAR_BUILT
ORDER BY YEAR_BUILT ASC
--all are valid. 

--SQUARE FOOTAGE
SELECT SQUARE_FOOTAGE, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Square_Footage
ORDER BY CAST(SQUARE_fOOTAGE AS FLOAT) ASC
--all seem valid. 

--------------------------------
--NOW LET'S LOOK AT SECONDARY MODIFIERS
--------------------------------

SELECT ROOF_SHAPE, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Roof_Shape

alter table [Hippo_20210630_TigerEdits] add RMS_RoofGeom float

update [Hippo_20210630_TigerEdits]
set RMS_RoofGeom = case
	when roof_shape in ('F','flat') then 1
	when roof_Shape in ('G','gable') then 5
	when roof_shape in ('GM','gambrel') then 0
	when roof_shape in ('H','hip') then 3
	when roof_shape in ('M','mansard') then 0
	when roof_shape in ('S','shed') then 0
	else 0
end 
--(235645 row(s) affected)

SELECT ROOF_SHAPE, RMS_RoofGeom
FROM [Hippo_20210630_TigerEdits]
GROUP BY ROOF_SHAPE, RMS_RoofGeom
order by roof_shape

select roof_type, count(*)
from [Hippo_20210630_TigerEdits]
group by roof_type

alter table [Hippo_20210630_TigerEdits] add RMS_RoofSys float

update [Hippo_20210630_TigerEdits]
set RMS_RoofSys = case
	when roof_type in ('architectural_shingles','asphalt_fiberglass_shingles','asphalt') then 7
	when roof_type in ('asphalt_event_rated') then 9
	when roof_type in ('clay_tile','concrete_tile') then 5
	when roof_type in ('slate_tile') then 5
	when roof_type in ('steel_or_metal','metal_decking') then 1
	when roof_type in ('wood_shingle_or_shake','wood_shingles_or_wood_shakes') then 6
	else 0
end 
--(235645 row(s) affected)

select roof_type, RMS_RoofSys
from [Hippo_20210630_TigerEdits]
group by roof_type, RMS_RoofSys
order by roof_Type

select top 10*
from [Hippo_20210630_TigerEdits]

SELECT roof_year_built, AGE_OF_ROOF, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY roof_year_built, AGE_OF_ROOF
ORDER BY roof_year_built
--SOME AGE OF ROOF BLANK.
--so let's just use Year Roof Built.

alter table [Hippo_20210630_TigerEdits] add RMS_RoofAge float

update [Hippo_20210630_TigerEdits]
set RMS_RoofAge = case
	when roof_year_built in ('2022','2021','2020','2019','2018','2017') then 1
	when roof_year_built in ('2016','2015','2014','2013','2012') then 2
	when roof_year_built = '' then 0
	else 3
end
--(235645 row(s) affected)

SELECT roof_year_built, RMS_RoofAge, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY roof_year_built, RMS_RoofAge
ORDER BY roof_year_built
--SOME AGE OF ROOF BLANK.

--PROTECTION CLASS IS NOT A MODELED FIELD.
SELECT PROTECTION_CLASS, COUNT(*)
FROM Hippo_20210630_TigerEdits
GROUP BY Protection_Class

SELECT HAIL_RESISTANT_ROOF, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Hail_Resistant_Roof
--AIR has a modifier for this.

--HURRICANE SHUTTERS?
SELECT OTHER_WIND_LOSS_PREVENTION, COUNT(*)
FROM [Hippo_20210630_TigerEdits]
GROUP BY Other_Wind_Loss_Prevention

alter table [Hippo_20210630_TigerEdits] add RMS_ResistOpen float

update [Hippo_20210630_TigerEdits]
set RMS_ResistOpen = case
	when other_wind_loss_prevention = 'impact_resistant_glass' then 1
	when other_wind_loss_prevention = 'none' then 9
	when other_wind_loss_prevention = 'shutters' then 3
	else 0
end 
--(235645 row(s) affected)

SELECT OTHER_WIND_LOSS_PREVENTION, RMS_ResistOpen, sum(TIV) TIV, COUNT(*) RISKS
FROM [Hippo_20210630_TigerEdits]
GROUP BY Other_Wind_Loss_Prevention, RMS_ResistOpen
order by Other_Wind_Loss_Prevention

select top 10*
from [Hippo_20210630_TigerEdits]

------------------------
--RMS - w lat long
------------------------

select top 10*
from [Hippo_20210630_TigerEdits]

--FF
SELECT POLICY_ID ACCNTNUM, POLICY_ID LOCNUM, STREET AS STREETNAME, CITY, STATE AS STATECODE, ZIP AS POSTALCODE, COUNTY, 
LATITUDE, LONGITUDE, 'ISO2A' AS CNTRYSCHEME, 'US' AS CNTRYCODE, 
'RMS' AS BLDGSCHEME, RMS_CONST AS BLDGCLASS, 'ATC' AS OCCSCHEME, RMS_OCC AS OCCTYPE, 
'12/31/'+YEAR_BUILT YEARBUILT, SQUARE_FOOTAGE AS FLOORAREa,  numstories_final NUMSTORIES,
WRITTENPREM_FINAL USERID1, REINSURANCE_TREATY_PROPERTY USERID2, carrier AS USERTXT1,
coverage_A AS EQCV4VAL, coverage_B AS EQCV5VAL, coverage_C AS EQCV6VAL, coverage_D as EQCV7VAL, 
coverage_A AS EQCV4LIMIT, coverage_B AS EQCV5LIMIT, coverage_C AS EQCV6LIMIT, coverage_D as EQCV7LIMIT, deductible_final AS EQSITEDED,
CLADSYS_RMS CLADSYS, RMS_RoofSys ROOFSYS, RMS_RoofAge ROOFAGE, RMS_RoofGeom ROOFGEOM, RMS_ResistOpen RESISTOPEN, RMS_Basement BASEMENT
FROM [Hippo_20210630_TigerEdits]
--235645

--SCS/WT
SELECT POLICY_ID ACCNTNUM, POLICY_ID LOCNUM, STREET AS STREETNAME, CITY, STATE AS STATECODE, ZIP AS POSTALCODE, COUNTY, 
LATITUDE, LONGITUDE, 'ISO2A' AS CNTRYSCHEME, 'US' AS CNTRYCODE, 
'RMS' AS BLDGSCHEME, RMS_CONST AS BLDGCLASS, 'ATC' AS OCCSCHEME, RMS_OCC AS OCCTYPE,
'12/31/'+YEAR_BUILT YEARBUILT, SQUARE_FOOTAGE AS FLOORAREA, numstories_final NUMSTORIES, 
WRITTENPREM_FINAL USERID1, REINSURANCE_TREATY_PROPERTY USERID2, carrier AS USERTXT1,
coverage_A AS TOCV4VAL, coverage_B AS TOCV5VAL, coverage_C AS TOCV6VAL, coverage_D as TOCV7VAL, 
coverage_A AS TOCV4LIMIT, coverage_B AS TOCV5LIMIT, coverage_C AS TOCV6LIMIT, coverage_D as TOCV7LIMIT, wind_deductible_final AS TOSITEDED, 
CLADSYS_RMS CLADSYS, RMS_RoofSys ROOFSYS, RMS_RoofAge ROOFAGE, RMS_RoofGeom ROOFGEOM, RMS_ResistOpen RESISTOPEN, RMS_Basement BASEMENT
FROM [Hippo_20210630_TigerEdits]
WHERE Wind_Exclusion <> 'TRUE'
--235038

--HU
SELECT POLICY_ID ACCNTNUM, POLICY_ID LOCNUM, STREET AS STREETNAME, CITY, STATE AS STATECODE, ZIP AS POSTALCODE, COUNTY, 
LATITUDE, LONGITUDE, 'ISO2A' AS CNTRYSCHEME, 'US' AS CNTRYCODE, 
'RMS' AS BLDGSCHEME, RMS_CONST AS BLDGCLASS, 'ATC' AS OCCSCHEME, RMS_OCC AS OCCTYPE, 
'12/31/'+YEAR_BUILT YEARBUILT, SQUARE_FOOTAGE AS FLOORAREA, numstories_final NUMSTORIES,
WRITTENPREM_FINAL USERID1, REINSURANCE_TREATY_PROPERTY USERID2, carrier AS USERTXT1
coverage_A AS WSCV4VAL, coverage_B AS WSCV5VAL, coverage_C AS WSCV6VAL, coverage_D as WSCV7VAL, 
Hurricane_Deductible_Final AS WSSITEDED, coverage_A AS WSCV4LIMIT, coverage_B AS WSCV5LIMIT, coverage_C AS WSCV6LIMIT, coverage_D as WSCV7LIMIT, 
CLADSYS_RMS CLADSYS, RMS_RoofSys ROOFSYS, RMS_RoofAge ROOFAGE, RMS_RoofGeom ROOFGEOM, RMS_ResistOpen RESISTOPEN, RMS_Basement BASEMENT
FROM [Hippo_20210630_TigerEdits]
WHERE Wind_Exclusion <> 'TRUE'
--235,038

SELECT TOP 10*
FROM [Hippo_20210630_TigerEdits]