

--=================================================================================================
-- Name: report.USP_HUM_ASSessionCases_GET
--
-- Description: Returns dataset for human session details report
--
-- Author: Mark Wilson
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		07/26/2022 initial release
--=================================================================================================

/*
--Example of a call of procedure:
exec report.USP_HUM_ASSessionCases_GET  155415660001409, 'en-US'
exec report.USP_HUM_ASSessionCases_GET  155415660001409, 'ka-GE'
exec report.USP_HUM_ASSessionCases_GET  155415660001462, 'en-US'
exec report.USP_HUM_ASSessionCases_GET  155415660001462, 'ka-GE'
*/


CREATE PROCEDURE [Report].[USP_HUM_ASSessionCases_GET]
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS	

BEGIN

	DECLARE @intTotalCases int

	SELECT
		@intTotalCases = COUNT (HC.idfHumanCase)
	FROM dbo.tlbHumanCase HC
	WHERE HC.idfParentMonitoringSession = @idfCase
	AND HC.intRowStatus = 0		 

	SELECT  HC.idfHumanCase				AS	idfsKey,
			HC.strCaseID				AS	strCaseID,
			COALESCE(HC.datFinalDiagnosisDate, HC.datOnSetDate, HC.datNotificationDate, HC.datEnteredDate) AS datCaseDate,
			CaseStatus.name AS	strCaseClassification,
			D.[name] AS	strDiagnosis,
			dbo.FN_GBL_GeoLocationString(@LangID,H.idfCurrentResidenceAddress,NULL) AS	strLocation,
			dbo.FN_GBL_AddressString(@LangID,H.idfCurrentResidenceAddress) AS	strAddress,
			@intTotalCases AS  intTotalCases
	FROM dbo.tlbHumanCase HC
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) D ON HC.idfsFinalDiagnosis = D.idfsReference
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000011) AS CaseStatus ON HC.idfsFinalCaseStatus = CaseStatus.idfsReference
	LEFT JOIN dbo.tlbHuman H ON	H.idfHuman = HC.idfHuman AND H.intRowStatus = 0

	WHERE HC.idfParentMonitoringSession = @idfCase
	AND HC.intRowStatus = 0		 

END