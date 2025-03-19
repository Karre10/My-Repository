/*
Practicing Loss DB queries
*/

select @@servername
--RDUSQLTS1001\ATSV10

use TRTP_20210630_LOSSv8

--always start by looking at your analyses

select * from tAnalysisResult

--Let's see how we ran them

select * from tLossAnalysisOption

select *
from AIRReference.[dbo].[tPerilSet]
where perilsetcode = 11534338

--lets look at the HU AAL by state

select AreaCode, sum(GrossLoss)/10000
from t2_LOSS_ByExposureAttributeGeo a inner join AIRGeography..tGeography b on a.GeographySID = b.GeographySID
where CatalogTypeCode = 'STC'
group by AreaCode
order by sum(GrossLoss)/10000 desc




--What is the event causing the largest loss in Florida?

select ModelCode*10000000+EventID, sum(GrossLoss)
from t2_LOSS_ByExposureAttributeGeo a inner join AIRGeography..tGeography b on a.GeographySID = b.GeographySID
where CatalogTypeCode = 'STC' and AreaCode = 'FL'
group by ModelCode*10000000+EventID
order by sum(GrossLoss) desc

--230053402
select * from AIREvents..TblModel27_STD
where EventID = 270260515





