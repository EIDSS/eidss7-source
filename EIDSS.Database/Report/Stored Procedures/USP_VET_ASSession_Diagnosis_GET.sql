
-- ============================================================================
-- Name: report.US__VET_ASSession_Diagnosis_GET
-- Description:	Get the session diseases.
--                      
-- Author: Mark Wilson
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Mark Wilson		07/14/2022 Initial release
--
/*
--Example of a call of procedure:

EXEC report.USP_VET_ASSession_Diagnosis_GET 5410000870, 'en-US'

*/

CREATE PROCEDURE report.USP_VET_ASSession_Diagnosis_GET
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS	

BEGIN

	SELECT  
		MSD.idfMonitoringSessionToDiagnosis AS idfsKey,
		D.[name] AS strDiagnosis,
		S.[name] AS strSpecies

	FROM dbo.tlbMonitoringSessionToDiagnosis MSD
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) D ON D.idfsReference = MSD.idfsDiagnosis
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) S ON S.idfsReference = MSD.idfsSpeciesType
	WHERE MSD.idfMonitoringSession = @idfCase
	AND MSD.intRowStatus = 0		 

END