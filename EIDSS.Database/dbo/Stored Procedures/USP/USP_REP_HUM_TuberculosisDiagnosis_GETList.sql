-- ================================================================================================
-- Name: dbo.USP_REP_HUM_TuberculosisDiagnosis_GETList
--
-- Description: 
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli      02/05/2021 Initial release.
--
-- Testing code:
/*

exec [dbo].[USP_REP_HUM_TuberculosisDiagnosis_GETList] 'en'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REP_HUM_TuberculosisDiagnosis_GETList] @LangID AS VARCHAR(36)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
	DECLARE @ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT 0 AS idfsReference
			,'' AS strName
			,1 AS intOrder
		
		UNION
		
		SELECT DISTINCT r.idfsReference
			,r.[name] AS strName
			,r.intOrder
		FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r
		INNER JOIN trtDiagnosis d
		INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt ON dgrt.idfsDiagnosis = d.idfsDiagnosis
			AND dgrt.idfsCustomReportType = 10290041 --Report on Tuberculosis cases tested for HIV
		INNER JOIN dbo.trtReportDiagnosisGroup dg ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
			AND dg.intRowStatus = 0
			AND dg.strDiagnosisGroupAlias = 'DG_Tuberculosis' ON r.idfsReference = d.idfsDiagnosis
			AND d.intRowStatus = 0 ORDER BY 2
			,1;

		SELECT @ReturnCode
			,@ReturnMessage;
	END TRY

	BEGIN CATCH
		BEGIN
			SET @returnCode = ERROR_NUMBER();
			SET @returnMessage = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @ReturnCode
				,@ReturnMessage;
		END
	END CATCH;
END
