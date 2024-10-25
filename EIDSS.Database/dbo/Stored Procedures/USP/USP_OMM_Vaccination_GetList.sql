
-- ================================================================================================
-- Name: USP_OMM_HerdSpecies_GetList
--
-- Description: Gets a list of outbreak case reports.
--          
-- Author: Doug Albanese
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- 
--                           
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Vaccination_GetList]
(
    @LangID							NVARCHAR(50),
	@idfSpecies						BIGINT
)
AS
BEGIN
    DECLARE @returnCode INT = 0;
    DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

    BEGIN TRY

		SELECT
			   idfVaccination			AS idfVetVaccination,
			   idfsDiagnosis			AS Name,
			   datVaccinationDate		AS Date,
			   idfSpecies				AS Species,
			   intNumberVaccinated		AS NumberVaccinated,
			   idfsVaccinationType		AS Type,
			   idfsVaccinationRoute		AS Route,
			   strLotNumber				As LotNumber,
			   strManufacturer			AS Manufactor,
			   strNote					AS Comments
		FROM
				tlbVaccination
		WHERE
				idfSpecies = @idfSpecies

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT = 1
            ROLLBACK;

        SET @returnCode = ERROR_NUMBER();
        SET @returnMsg
            = N'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + N' ErrorSeverity: '
              + CONVERT(VARCHAR, ERROR_SEVERITY()) + N' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
              + N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + N' ErrorLine: '
              + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + N' ErrorMessage: ' + ERROR_MESSAGE();

        SELECT @returnCode,
               @returnMsg;
    END CATCH;
END;
