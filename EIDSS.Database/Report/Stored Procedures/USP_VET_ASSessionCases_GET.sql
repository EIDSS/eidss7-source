--=================================================================================================
-- Name: report.USP_VET_ASSessionCases_GET
--
-- Description: Returns dataset for monitoring session details report
--
-- Author: Mark Wilson
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		07/14/2022 initial release
-- Mike Kornegay	10/20/2022 Corrected joins for disease, farm address, and farm location.
--
--=================================================================================================

/*
--Example of a call of procedure:
exec report.USP_VET_ASSessionCases_GET  155415660001312, 'en-US'
exec report.USP_VET_ASSessionCases_GET  155415660001386, 'en-US'
*/


CREATE PROCEDURE [Report].[USP_VET_ASSessionCases_GET]
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS	

BEGIN

	DECLARE @intTotalCases int

	SELECT
		@intTotalCases = COUNT (VC.idfVetCase)
	FROM dbo.tlbVetCase VC
	WHERE VC.idfParentMonitoringSession = @idfCase
	AND VC.intRowStatus = 0		 

	SELECT  VC.idfVetCase				AS	idfsKey,
			VC.strCaseID				AS	strCaseID,
			ISNULL(VC.datInvestigationDate, ISNULL(
													(
														SELECT MAX(s1.dat) FROM 
														(
															SELECT 
																VC1.datTentativeDiagnosisDate AS dat
															FROM dbo.tlbVetCase AS VC1 
															WHERE VC1.idfVetCase = VC.idfVetCase
							
															UNION ALL
							
															SELECT 
																VC1.datTentativeDiagnosis1Date AS dat
															FROM dbo.tlbVetCase AS VC1 
															WHERE VC1.idfVetCase = VC.idfVetCase

															UNION ALL

															SELECT 
																VC1.datTentativeDiagnosis2Date AS dat
															FROM dbo.tlbVetCase AS VC1 
															WHERE VC1.idfVetCase = VC.idfVetCase
							
															UNION ALL
															SELECT 
																VC1.datFinalDiagnosisDate AS dat
															FROM dbo.tlbVetCase AS VC1 
															WHERE VC1.idfVetCase = VC.idfVetCase

													) s1),
				ISNULL(VC.datReportDate, VC.datEnteredDate))) AS datCaseDate,
			CaseStatus.name AS	strCaseClassification,
			ISNULL(finalDiagnosis.[name], VC.strDefaultDisplayDiagnosis) AS	strDiagnosis,
			(lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) AS strLocation,
			dbo.FN_GBL_CreateAddressString	(lh.AdminLevel1Name, lh.AdminLevel2Name, lh.AdminLevel3Name, '', '', lh.AdminLevel4Name, '', '', '', '',0,'') AS strAddress,
			--dbo.FN_GBL_GeoLocationString(@LangID,F.idfFarmAddress,NULL) AS	strLocation,
			--dbo.FN_GBL_AddressString(@LangID,F.idfFarmAddress)				AS	strAddress,
			@intTotalCases				AS  intTotalCases
	FROM dbo.tlbVetCase  VC
	--LEFT JOIN dbo.tlbVetCaseDisplayDiagnosis D ON VC.idfVetCase = D.idfVetCase AND D.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000019) finalDiagnosis ON finalDiagnosis.idfsReference = VC.idfsFinalDiagnosis
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000011) AS CaseStatus ON VC.idfsCaseClassification = CaseStatus.idfsReference
	LEFT JOIN dbo.tlbFarm F ON	F.idfFarm  = VC.idfFarm AND	F.intRowStatus = 0
	LEFT JOIN dbo.tlbGeoLocation gl ON gl.idfGeoLocation = F.idfFarmAddress
	LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
	LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lh ON lh.idfsLocation = g.idfsLocation

	WHERE VC.idfParentMonitoringSession = @idfCase
	AND VC.intRowStatus = 0		 

END

