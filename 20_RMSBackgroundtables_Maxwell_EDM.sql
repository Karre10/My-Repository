/*
practice profiling information for training
*/

select @@servername 'RDUSQLRMS181\RMSV181'

use LHPIC_20201031_EDMv181

--Always start off looking at what portfolios you have
select *
from portinfo
--1	LHPIC_20210331_HU

--Lets pull location count by state
select *
from loc

select statecode, count(locid)
from loc A
inner join portacct B
on a.accgrpid = b.accgrpid
where portinfoid = 1
group by statecode


--how would we do this without the "loc" view?
select *
from address


--okay, lets add in the sum of location level values (TIV) to our risk count by state



--holy guacamole those risk counts are way too high!! 


--how do we fix this?


--there we go

--lets look at the loccvg table again

--LabelID tells us what kind of limit / coverage / deductible it is
--lets use the DB schema to find out



--coverage A & risk count by state
