/*
Practicing RDM queries
*/

select @@servername
--RDUSQLRMS181\RMSV181

use LHPIC_20210331_RDMv181

--always start by looking at your analyses
select *
from rdm_analysis
--1	LHPIC_20210331_HU	NA EP Distributed LTwLA byStateLOB LocAA

--lets look at the AAL by state
select *
from rdm_geoidlobstats
--purepremium

select state, format(sum(purepremium),'N0')
from rdm_geoidlobstats
where anlsid = 1 and perspcode = 'GR'
group by state
order by state
--FL	8,786,951
--LA	19,807,487
--NC	7,329,316
--SC	3,082,425
--TX	9,543,516

--What is the event causing the largest loss in Florida?

select *
from rdm_geoidlob

select eventID, sum(perspvalue) Loss
from rdm_geoidlob
where anlsid = 1 and perspcode = 'GR' and state = 'FL'
group by eventID
order by loss desc
--2864409   3,599,995,691.12196

select *
from [RMS_EVENTINFO]..event
where ID = 2864409


--Lets find HU Katrina

select *
from [RMS_EVENTINFO]..event
where Name like '%Katrina%'
--2848430

select *
from rdm_geoidlob
where eventID = 2848430 and anlsid = 1
and perspcode = 'GR'






--why did we get 4 rows?



