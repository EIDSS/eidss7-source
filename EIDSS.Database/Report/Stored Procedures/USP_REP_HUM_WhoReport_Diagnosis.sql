
--*************************************************************************
-- Name 				: report.USP_REP_HUM_WhoReport_Diagnosis
-- Description			: SINT03 - WHO Report 
--						: Needed for diagnosis dropdown
-- 
-- Author               : Mark Wilson
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
/*
--Example of a call of procedure:
exec report.USP_REP_HUM_WhoReport_Diagnosis 

*/

CREATE PROCEDURE [Report].[USP_REP_HUM_WhoReport_Diagnosis]

AS	
	
BEGIN

	--SELECT 
	--	0 AS idfsDiagnosis,
	--	'' AS strDiagnosis
	--UNION ALL
	SELECT 
		idfsBaseReference AS idfsDiagnosis,
		strDefault AS strDiagnosis
		
	FROM dbo.trtBaseReference
	WHERE idfsReferenceType = 19000019
	AND strDefault IN ('Rubella','Measles')

END

