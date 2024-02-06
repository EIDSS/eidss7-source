


--=====================================================================================================
-- Author:					Mark Wilson
-- Description:				06/10/2019: Created based on V6 spDiagnosis_SelectLookup :  
--							updated for reports using idfsCustomReportType
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Test Code:
-- EXEC report.USP_REP_Diagnosis_GET 'en', 10290053 -- Comparative Report of Several Years by Month
-- 
--
--=====================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Diagnosis_GET] 
(
	@LangID					NVARCHAR(50),
	@idfsCustomReportType	BIGINT  -- idfsCustomReportType
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @returnMsg		VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode		BIGINT = 0;

	BEGIN TRY
		SELECT 
			DGFRT.idfsReportDiagnosisGroup,
			GRR.[name] AS strReportDiagnosisGroup_trans,
			DGFRT.idfsDiagnosis,
			DRR.[name] AS strDiagnosis,
			D.strIDC10 AS [ICD-10 Code]
		into report.#temp
		FROM dbo.trtDiagnosisToGroupForReportType DGFRT
		LEFT JOIN dbo.trtBaseReference GR ON GR.idfsBaseReference = DGFRT.idfsReportDiagnosisGroup
		LEFT JOIN dbo.trtBaseReference DR ON DR.idfsBaseReference = DGFRT.idfsDiagnosis
		LEFT JOIN dbo.trtDiagnosis D ON D.idfsDiagnosis = DGFRT.idfsDiagnosis
		LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000130) GRR ON GRR.idfsReference = DGFRT.idfsReportDiagnosisGroup -- 19000030 = Diagnosis Group
		LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) DRR ON DRR.idfsReference = DGFRT.idfsDiagnosis -- 19000019 = Diagnosis

		WHERE DGFRT.idfsCustomReportType = @idfsCustomReportType
		AND DR.intRowStatus = 0
		AND GR.intRowStatus = 0

		ORDER BY 
			GR.strDefault,
			DR.strDefault

		SELECT 
			0 AS idfsReportDiagnosisGroup,
			'' AS strReportDiagnosisGroup_trans,
			0 As idfsDiagnosis,
			'' AS strDiagnosis,
			'' AS [ICD-10 Code]
		UNION ALL
		SELECT 
			idfsReportDiagnosisGroup,
			strReportDiagnosisGroup_trans,
			idfsDiagnosis,
			strDiagnosis,
			[ICD-10 Code]
		FROM report.#temp
		
		DROP TABLE report.#temp
		
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



