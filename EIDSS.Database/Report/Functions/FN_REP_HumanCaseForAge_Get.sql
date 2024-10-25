--*************************************************************************************************
-- Name 				: FN_REP_HumanCaseForAge_Get
-- Description			: Returns Table of Human Cases for Age 
--                        span and dates  
--						
-- Author               : Mark Wilson
-- Revision History
-- June 2019 updated E6 code to E7 standards
--
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    01/31/2023 Fix for bug 5455.
--
-- Testing code:
-- SELECT * FROM report.FN_REP_HumanCaseForAge_Get (2009-01-01, '2011-01-01', 1, 100, NULL)
--
--*************************************************************************************************
CREATE FUNCTION [Report].[FN_REP_HumanCaseForAge_Get]
(
	@StartDate AS DATETIME, 
	@EndDate AS DATETIME,
	@StartAge AS INT,
	@EndAge AS INT,
	@FinalState AS BIGINT = NULL
)
RETURNS TABLE
AS

RETURN
	SELECT 
		COALESCE(HC.idfsFinalDiagnosis, HC.idfsTentativeDiagnosis) AS idfsDiagnosis,
		COUNT(HC.idfHumanCase) AS intCount
	FROM dbo.tlbHumanCase HC
         LEFT JOIN dbo.tlbGeoLocation cgl
              ON HC.idfPointGeoLocation = cgl.idfGeoLocation
                   AND cgl.intRowStatus = 0 -- added by MCW to ensure non-foreign address
	WHERE (COALESCE(HC.datOnsetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datNotificationDate, HC.datEnteredDate) >= @StartDate AND 
	    COALESCE(HC.datOnsetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datNotificationDate, HC.datEnteredDate) < @EndDate)
	AND HC.intRowStatus = 0
	AND (
	     ISNULL(cgl.idfsGeoLocationType, -1) <> 10036001 -- Foreign Address          
	     OR cgl.idfsCountry IS NULL 
		 OR cgl.idfsCountry = 780000000
    )
	AND (@FinalState IS NULL OR HC.idfsFinalState = @FinalState OR (@FinalState = 10035001 /* Deceased */ AND HC.idfsOutcome = 10770000000 /* Died */))
	AND COALESCE(HC.idfsFinalCaseStatus, HC.idfsInitialCaseStatus, 370000000) <> 370000000 -- Added to filter on case refused
	AND	((@StartAge = 0 AND @EndAge = 0)
		 OR	((@StartAge >= 1 and @EndAge >= 1) 
		     AND (HC.idfsHumanAgeType = 10042003 /* Years */ OR HC.idfsHumanAgeType IS NULL) 
			 AND (HC.intPatientAge BETWEEN @StartAge and @EndAge))
		 OR ((@StartAge <= 1 AND @EndAge <= 1)  
		     AND ((HC.intPatientAge < 12 AND HC.idfsHumanAgeType = 10042002 /* Month */) 
			      OR (HC.intPatientAge <= 31 and HC.idfsHumanAgeType = 10042001 /* Days */)))
         OR ((@StartAge >= 1 AND @EndAge >= 1) AND (HC.idfsHumanAgeType = 10042002 /* Month */) 
		     AND (HC.intPatientAge >= 12 AND CAST(HC.intPatientAge / 12 AS INT) BETWEEN @StartAge AND @EndAge))					
		)
	GROUP BY COALESCE(HC.idfsFinalDiagnosis, HC.idfsTentativeDiagnosis)	