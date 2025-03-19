/*
NAME: Michael
DATE: 06/22/2022

Below are the items I want you to pull from the EDM and RDM referenced below. 

Server: RDUSQLRMS18\RMSV18
Databases: TRTP_20210630_EDMv18, TRTP_20210630_RDMv18

Provide the results and the script used to answer the following:
*/

select @@SERVERNAME 'RDUSQLRMS18\RMSV18'
use TRTP_20210630_EDMv18

----- 1.	TIV and risk count by portfolio



select PORTINFOID,SUM(VALUEAMT) as TIV, count(distinct(d.LOCID)) as RiskCount from
(select PORTINFOID,a.ACCGRPID,LOCID from portacct A inner join property B
on a.ACCGRPID=b.ACCGRPID) as c  inner join loccvg d
on c.LOCID=d.LOCID
group by PORTINFOID




-- PORTINFOID	TIV					RiskCount




select count(*) from address
group by Latitude,Longitude

----- 2.	TIV and risk count by state for the HU portfolio
select Admin1Code,SUM(VALUEAMT) as TIV, count(distinct(d.LOCID)) as RiskCount from
(select PORTINFOID,a.ACCGRPID,LOCID,AddressID from portacct A inner join property B
on a.ACCGRPID=b.ACCGRPID) as c  inner join loccvg d
on c.LOCID=d.LOCID inner join address e on c.addressID=e.AddressID
where PORTINFOID=1
group by Admin1Code


-- 3.	TIV and risk count by geocoding match for each portfolio
select GeoMatchCode,SUM(VALUEAMT) as TIV, count(distinct(d.LOCID)) as RiskCount from
(select PORTINFOID,a.ACCGRPID,LOCID,AddressID from portacct A inner join property B
on a.ACCGRPID=b.ACCGRPID) as c  inner join loccvg d
on c.LOCID=d.LOCID inner join address e on c.addressID=e.AddressID
where PORTINFOID=1
group by GeoMatchCode
order by RiskCount desc



select GeoMatchCode,SUM(VALUEAMT) as TIV, count(distinct(d.LOCID)) as RiskCount from
(select PORTINFOID,a.ACCGRPID,LOCID,AddressID from portacct A inner join property B
on a.ACCGRPID=b.ACCGRPID) as c  inner join loccvg d
on c.LOCID=d.LOCID inner join address e on c.addressID=e.AddressID
where PORTINFOID=2
group by GeoMatchCode
order by RiskCount desc

-- 4.	What roof geometry codes are present in the data?
select * from loccvg


use TRTP_20210630_RDMv18


-- 5.	For each analysis, 
-- a.	What sub-peril settings were used? (Hint - look in the rdm_analysis table!)


-- b.	Was loss amplification included?




-- 6.	Provide Gross AAL by state for analysis 1 




-- 7.	Provide the Gross ELT by State for analysis 3




-- 8.	Calculate the gross AAL by state from the ELT from #8

