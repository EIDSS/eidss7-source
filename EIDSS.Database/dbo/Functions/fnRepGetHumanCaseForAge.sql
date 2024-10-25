


-- =============================================
-- Author:		Vasilyev I.
-- Create date: 
-- Description:
-- =============================================


--##SUMMARY Select Human cases for given age diapazon.
--##REMARKS Author: Vasilyev I.
--##REMARKS Create date: 23.12.2009

--##REMARKS UPDATED BY: Vorobiev E. --deleted tlbCase
--##REMARKS Date: 22.04.2013

--##RETURNS Doesn't use

--
-- Updated by Mark Wilson 
-- 29June2018
--
-- COALESCE(tHumanCase.idfsFinalCaseStatus, tHumanCase.idfsInitialCaseStatus, 370000000) <> 370000000 -- Added to filter on case refused
--
-- this is per EIDSS 6.1 defect 67 to fix mis-matched report results

/*
--Example of a call of function:
select * from dbo.fnRepGetHumanCaseForAge (2009-01-01, '2011-01-01', 1, 2147483647, null)
*/

create Function [dbo].[fnRepGetHumanCaseForAge]
(
	@StartDate		as datetime, 
	@EndDate		as datetime,
	@StartAge		as int,
	@EndAge			as int,
	@FinalState		as bigint = null
)
Returns	 Table
AS

return
	select		COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis)			as idfsDiagnosis,
				count(tHumanCase.idfHumanCase)	as intCount
	
	from		dbo.tlbHumanCase as tHumanCase
		 where  COALESCE(tHumanCase.datOnsetDate, tHumanCase.datFinalDiagnosisDate, tHumanCase.datTentativeDiagnosisDate, tHumanCase.datNotificationDate, tHumanCase.datEnteredDate) >= @StartDate
		   and  COALESCE(tHumanCase.datOnsetDate, tHumanCase.datFinalDiagnosisDate, tHumanCase.datTentativeDiagnosisDate, tHumanCase.datNotificationDate, tHumanCase.datEnteredDate) < @EndDate

		   and  tHumanCase.intRowStatus = 0
		   and  (@FinalState is null or tHumanCase.idfsFinalState = @FinalState)
		 AND COALESCE(tHumanCase.idfsFinalCaseStatus, tHumanCase.idfsInitialCaseStatus, 370000000) <> 370000000 -- Added to filter on case refused
			and	(	
		     (@StartAge = 0 and @EndAge = 0)
					or
					( (@StartAge >= 1 and @EndAge >= 1) and 
						(tHumanCase.idfsHumanAgeType=10042003 /*Years*/  or tHumanCase.idfsHumanAgeType is null) and
						(tHumanCase.intPatientAge between @StartAge and @EndAge) 
					)
					or
					(
						(@StartAge <= 1 and @EndAge <= 1)  and
						(
							(tHumanCase.intPatientAge < 12 and tHumanCase.idfsHumanAgeType=10042002 /*Month*/) or 
							(tHumanCase.intPatientAge <=31 and tHumanCase.idfsHumanAgeType=10042001 /*Days*/)
						)
					)
          or
					(
						(@StartAge >= 1 and @EndAge >= 1) and (tHumanCase.idfsHumanAgeType = 10042002 /*Month*/) and
						(tHumanCase.intPatientAge >= 12 and cast(tHumanCase.intPatientAge / 12 as int) between @StartAge and @EndAge)
					)					
					
				)
				
	  group by	COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis)	
	  




