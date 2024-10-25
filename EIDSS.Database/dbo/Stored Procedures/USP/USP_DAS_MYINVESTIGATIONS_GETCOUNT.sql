-- ================================================================================================
-- Name: USP_DAS_MYINVESTIGATIONS_GETCOUNT
--
-- Description: Returns a count of veterinary disease reports filtered by the user.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Ricky Moss         05/07/2018 Initial Release
-- Stephen Long       01/24/2020 Corrected active row status check.
--
-- Testing Code:
-- exec USP_DAS_MYINVESTIGATIONS_GETCOUNT 55423100000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_MYINVESTIGATIONS_GETCOUNT] (@LanguageID NVARCHAR(50), @PersonID BIGINT)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT COUNT(vc.idfVetCase) AS RecordCount
		FROM dbo.tlbVetCase vc
		INNER JOIN dbo.tlbFarm AS f
			ON f.idfFarm = vc.idfFarm
		LEFT JOIN dbo.tlbGeoLocation AS glFarm
			ON glFarm.idfGeoLocation = f.idfFarmAddress
				AND glFarm.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000001) AS country
			ON country.idfsReference = glFarm.idfsCountry
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000002) AS rayon
			ON rayon.idfsReference = glFarm.idfsRayon
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000003) AS region
			ON region.idfsReference = glFarm.idfsRegion
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000004) AS settlement
			ON settlement.idfsReference = glFarm.idfsSettlement
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS finalDiagnosis
			ON finalDiagnosis.idfsReference = vc.idfsFinalDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) AS caseClassification
			ON caseClassification.idfsReference = vc.idfsCaseClassification
		WHERE vc.intRowStatus = 0
			AND vc.idfPersonEnteredBy = @PersonID
			AND vc.idfsCaseProgressStatus = 10109001; --In Process

		SELECT @ReturnCode,
			@ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;
END
