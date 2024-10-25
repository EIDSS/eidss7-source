

--=====================================================================================================
-- Author:					Joan Li
-- Description:				06/20/2017: Created based on V6 spDiagnosis_SelectLookup :  V7 USP68
--							Get lookup data from tables: trtDiagnosis;trtDiagnosisToDiagnosisGroup.
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Joan Li			06/20/2017 Initial release.
-- Stephen Long     05/22/2018 Renamed and re-factored to standard.
-- Mark Wilson		05/15/2019 Updated to return only intRowStatus = 0
-- Mark Wilson		09/30/2020 Updated to use FN_GBL_ReferenceRepair_GET()
-- 
-- Test Code:
-- EXEC report.USP_GBL_Diagnosis_SelectLookup 'en', 2, 10020001 -- 'dutStandardCase' (10020001, 10020002)
-- Related Fact Data From:
-- select distinct idfsusingtype  from trtDiagnosis  
-- select * from trtDiagnosisToDiagnosisGroup
--=====================================================================================================
CREATE PROCEDURE [Report].[USP_GBL_Diagnosis_SelectLookup] 
(
	@LangID					NVARCHAR(50),
	@HACode					INT = NULL,  --Bit mask that defines area where diagnosis are used (human, livestock or avian)
	@DiagnosisUsingType		BIGINT = NULL --standard or aggregate
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @returnMsg		VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode		BIGINT = 0;

	BEGIN TRY
	SELECT 0 AS idfsDiagnosis
		   ,'' AS name
		   ,NULL AS intOrder
    UNION ALL
	SELECT
		trtDiagnosis.idfsDiagnosis
		,d.name
		,d.intOrder
		--,trtDiagnosis.strIDC10
		--,trtDiagnosis.strOIECode
		--,d.intHACode
		--,d.intRowStatus
		--,blnZoonotic
		--,CASE WHEN blnZoonotic = 1 THEN stYes.name ELSE stNo.name END AS strZoonotic
		--,diagnosesGroup.idfsDiagnosisGroup
		--,diagnosesGroup.strDiagnosesGroupName

	FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) d
	INNER JOIN dbo.trtDiagnosis ON	trtDiagnosis.idfsDiagnosis = d.idfsReference
	LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000100) stYes ON stYes.idfsReference = 10100001
	LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000100) stNo ON stNo.idfsReference = 10100002
	OUTER APPLY 
	( 
		SELECT TOP 1 
			d_to_dg.idfsDiagnosisGroup, 
			dg.[name] AS strDiagnosesGroupName
		FROM dbo.trtDiagnosisToDiagnosisGroup d_to_dg
		INNER JOIN report.FN_GBL_ReferenceRepair_GET('en', 19000156) dg ON dg.idfsReference = d_to_dg.idfsDiagnosisGroup
		
		WHERE d_to_dg.intRowStatus = 0
		AND	d_to_dg.idfsDiagnosis = trtDiagnosis.idfsDiagnosis
		ORDER BY d_to_dg.idfDiagnosisToDiagnosisGroup ASC 
	) AS diagnosesGroup

	WHERE (@HACode = 0 OR @HACode IS NULL OR d.intHACode IS NULL OR (d.intHACode & @HACode) > 0)
	AND	(@DiagnosisUsingType IS NULL OR trtDiagnosis.idfsDiagnosis IS NULL OR trtDiagnosis.idfsUsingType = @DiagnosisUsingType)
--	AND d.intRowStatus = 0
	ORDER BY
		3,
		2;

	SELECT @returnCode, @returnMsg;
	END TRY  
	BEGIN CATCH 
		BEGIN
			SET				@returnCode = ERROR_NUMBER();
			SET				@returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
								+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
								+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
								+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
								+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
								+ ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT			@returnCode, @returnMsg;
		END
	END CATCH;
END

