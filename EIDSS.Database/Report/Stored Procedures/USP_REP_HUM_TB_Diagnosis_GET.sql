
-- ================================================================================================
-- Name: Report.USP_REP_HUM_TB_Diagnosis_GET
--
-- Description:	Selects diagnosis data for reports
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/* Sample Code

exec Report.USP_REP_HUM_TB_Diagnosis_GET 'en-US'

*/ 
 
CREATE PROCEDURE [Report].[USP_REP_HUM_TB_Diagnosis_GET]
	@LangID			AS VARCHAR(36)
AS
BEGIN
	SELECT DISTINCT
		r.idfsReference, 
		r.[name] AS strName,
		r.intOrder  

	FROM dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r
	INNER JOIN dbo.trtDiagnosis d
			--Report on Tuberculosis cases tested for HIV
			INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt ON dgrt.idfsDiagnosis = d.idfsDiagnosis AND dgrt.idfsCustomReportType = 10290041 
			INNER JOIN dbo.trtReportDiagnosisGroup dg ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Tuberculosis'
		ON  r.idfsReference = d.idfsDiagnosis AND d.intRowStatus = 0
	ORDER BY
		r.[name],
		r.idfsReference

END

