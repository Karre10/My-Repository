/*
practice profiling information for training
*/

select @@servername
--RDUSQLTS1001\ATSV10


use TRTP_20210630_CEDEv8

--Always start off looking at what portfolios you have
select * from tExposureSet

select * from tlocation 

--Lets pull location count by state

select Areacode, count(*)
from tlocation
group by AreaCode

--okay, lets add in the sum of location level values (TIV) to our risk count by state

select Areacode, count(*), sum(TotalReplacementValue)
from tlocation
group by AreaCode

--holy guacamole those risk counts are way too high!! 


select Areacode, count(*), sum(TotalReplacementValue)
from tlocation
where ExposureSetSID = 1
group by AreaCode


select * from [tLocFeature]

select * from tlocterm

--Roof Geo by TIV

select a.RoofGeometryCode, roofgeometry, count(*), sum(TotalReplacementValue)
from [dbo].[tLocFeature] a inner join tlocation b on a.LocationSID = b.LocationSID
inner join [AIRReference].[dbo]. c on a.RoofGeometryCode = c.RoofGeometryCode
where ExposureSetSID = 1
group by a.RoofGeometryCode, roofgeometry


use 
Amtrust_20221231_CEDEv9

select * from tExposureSet


select top 10 * from tcontract

select Exposuresetname, count(*) from tcontract a inner join [AIRReference]..tPerilSet b on a.PerilSetCode = b.PerilSetCode
inner join tExposureSet c on a.ExposureSetSID = c.ExposureSetSID
where b.CoversTropicalCyclone = 1
group by Exposuresetname

