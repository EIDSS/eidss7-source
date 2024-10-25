


--=================================================================================================
-- Name: USP_GBL_LKUP_SAMPLEFORDISEASE
--
-- Description:	Returns the list of sample types based on sample-disease matrix.
--							
-- Author:  Mandar Kulkarni
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni	11/11/2021 Initial Release
-- Mike Kornegay	01/15/2022 Corrected misspelling on AccessoryCode parameter and changed LangID to LangId
--
-- Test Code:
-- exec USP_GBL_LKUP_SAMPLESFORDISEASES 'en-us',7718050000000, 2
-- exec USP_GBL_LKUP_SAMPLESFORDISEASES 'en-us',7718060000000, 98
--=================================================================================================
CREATE   PROCEDURE [dbo].[USP_GBL_LKUP_SAMPLESFORDISEASES] 
(
	@LangId NVARCHAR(50) = 'en-US',
	@idfsDiagnosis BIGINT,
	@AccessoryCode INT = 2
)
AS
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS', @returnCode BIGINT = 0
BEGIN
	BEGIN TRY
			SELECT DISTINCT md.idfsSampleType, stbr.name AS strSampleType
			FROM dbo.trtMaterialForDisease md
			JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000087) stbr 
			ON md.idfsSampleType = stbr.idfsReference 
			WHERE EXISTS (SELECT dbo.FN_GBL_HACode_ToCSV('en-US',@AccessoryCode))
			AND md.idfsDiagnosis  = @idfsDiagnosis
			ORDER BY stbr.name
	END TRY
	BEGIN CATCH 
		BEGIN
			SET	@returnCode = ERROR_NUMBER();
			SET	@returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
				+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
				+ ' ErrorMessage: ' + ERROR_MESSAGE();

			--SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
		END
	END CATCH;
END

