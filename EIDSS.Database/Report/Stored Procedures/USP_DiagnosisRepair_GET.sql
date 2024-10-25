
-- ================================================================================================
-- Name: report.USP_DiagnosisRepair_GET
--
-- Description:	Selects diagnosis data for reports
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/* Sample Code

exec  report.USP_DiagnosisRepair_GET 'en-US', 32, 10020001 -- 

*/

CREATE PROCEDURE [Report].[USP_DiagnosisRepair_GET] 
(
	@LangID AS NVARCHAR(50), --##PARAM @LangID - language ID
	@HACode AS INT = NULL,  --##PARAM @HACode - bit mask that defines Area where diagnosis are used (human, LiveStock or avian)
	@DiagnosisUsingType AS BIGINT = NULL, --##PARAM @DiagnosisUsingType - diagnosis Type (standard or aggregate)
	@blnZoonoticOnly BIT = NULL
)
AS
SELECT	
	TD.idfsDiagnosis,
	d.name,
	TD.strIDC10,
	TD.strOIECode,
	d.intHACode,
	CASE WHEN (@HACode = 0 OR @HACode IS NULL OR d.intHACode IS NULL OR d.intHACode & @HACode > 0)
		AND (@DiagnosisUsingType IS NULL OR TD.idfsDiagnosis IS NULL OR TD.idfsUsingType = @DiagnosisUsingType)
		AND (@blnZoonoticOnly IS NULL OR (@blnZoonoticOnly = 1 AND TD.blnZoonotic = 1))
		THEN  d.intRowStatus
		ELSE 1 END AS intRowStatus,
	TD.blnZoonotic,
	CASE WHEN TD.blnZoonotic = 1 THEN stYes.name ELSE stNo.name END AS strZoonotic,
	diagnosesGroup.idfsDiagnosisGroup,
	diagnosesGroup.strDiagnosesGroupName
FROM report.FN_REP_ReferenceRepair_GET(@LangID, 19000019) D 
INNER JOIN dbo.trtDiagnosis TD ON TD.idfsDiagnosis = d.idfsReference
LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) stYes ON stYes.idfsReference = 10100001
LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) stNo ON stNo.idfsReference = 10100002
OUTER APPLY ( 
				SELECT 
					TOP 1 d_to_dg.idfsDiagnosisGroup, 
					dg.[name] AS strDiagnosesGroupName
				FROM dbo.trtDiagnosisToDiagnosisGroup d_to_dg
				INNER JOIN report.FN_REP_ReferenceRepair_GET('en-US', 19000156) dg ON dg.idfsReference = d_to_dg.idfsDiagnosisGroup
				
				WHERE d_to_dg.intRowStatus = 0
				AND d_to_dg.idfsDiagnosis = TD.idfsDiagnosis
				ORDER BY d_to_dg.idfDiagnosisToDiagnosisGroup ASC 
			) AS diagnosesGroup
ORDER BY
	d.intOrder, 
	d.name  

