

--=================================================================================================
-- Author:					Doug Albanese
--
-- Description:				11/30/2020: Created for Outbreak to provide zoonotic diseases for use
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Doug Albanese	11/30/2020	Initial release.
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_ZoonoticDiagnosis_GetList] (
	@LangID					NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;

	BEGIN TRY
		SELECT
			idfsDiagnosis,
			name
		from 
			dbo.FN_GBL_ReferenceRepair(@LangId, 19000019) dig_ref 
		INNER JOIN trtDiagnosis d 
			ON dig_ref.idfsReference = d.idfsDiagnosis AND d.intRowStatus = 0
		WHERE 
			intHACode IN  (34,66,98, 162, 194, 226) AND d.intRowStatus = 0
		ORDER BY 
			name

		SELECT @returnCode,
			@returnMsg;
	END TRY

	BEGIN CATCH
		BEGIN
			SET @returnCode = ERROR_NUMBER();
			SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode,
				@returnMsg;
		END
	END CATCH;
END

