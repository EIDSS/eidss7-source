/*
Author:			Mike Kornegay
Date:			10/21/2022
Description:	Update tlbMonitoringSession so all records have a idfsMonitoringSessionSpeciesType

*/

--AS Species Types
--129909620007069 = Avian
--129909620007070 = Livestock

declare @Sessions as table 
(
	idfMonitoringSession				bigint,
	intHACode							int,
	idfsMonitoringSessionSpeciesType	bigint
);

insert into	@Sessions
select		msd.idfMonitoringSession,
			br.intHACode,
	(case	br.intHACode 
	when	64 then 129909620007069
	when	32 then 129909620007070
	end)	as idfsMonitoringSessionSpeciesType
from		tlbMonitoringSessionToDiagnosis msd 
join		trtBaseReference br on br.idfsBaseReference = msd.idfsSpeciesType
group by	msd.idfMonitoringSession,
			br.intHACode
order by	msd.idfMonitoringSession

begin tran
update		tlbMonitoringSession
set			idfsMonitoringSessionSpeciesType = s.idfsMonitoringSessionSpeciesType
from		tlbMonitoringSession ms
join		@Sessions s
on			s.idfMonitoringSession = ms.idfMonitoringSession
commit tran

--select * from tlbMonitoringSession ms
--inner join tlbMonitoringSessionToDiagnosis msd
--on msd.idfMonitoringSession = ms.idfMonitoringSession
--inner join trtBaseReference br 
--on br.idfsBaseReference = msd.idfsSpeciesType