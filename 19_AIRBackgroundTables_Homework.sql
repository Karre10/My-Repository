/*
NAME
DATE

Below are the items I want you to pull from the EDM and RDM referenced below. 

Server: RDUSQLTS701\ATSV7
Databases: TRTP_20210630_CEDEv7, TRTP_20210630_LOSSv7

Provide the results and the script used to answer the following:
*/

select @@SERVERNAME 'RDUSQLTS701\ATSV7'
use THIG_20220228_CEDEv7

----- 1.	TIV and risk count by portfolio/exposureset

select * from tExposureSet

-- PORTINFOID	TIV					RiskCount




----- 2.	TIV and risk count by state for the 20220228_PRIME_DTL (exposuresetSID = 10)


-- 3.	TIV and risk count by geocoding match for each portfolio porfolios 10 and 14



-- 4.	What roof geometry codes are present in the data?



use THIG_20220228_LOSSv7
select * from tAnalysisResult

-- 5.	For analyses 6 & 42
-- a.	What peril settings were used? 


-- b.	Was loss amplification included?




-- 6.	Provide Gross AAL by state for analysis 6 




-- 7.	Provide the Gross ELT by State for analysis 42




-- 8.	Calculate the gross AAL by state from the ELT from #7

