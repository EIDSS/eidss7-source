-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_SPECIES_GETList
--
-- Description:	Gets a concatenated list of species types for a specific veterinary disease 
-- report.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     01/04/2021 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_SPECIES_GETList] (
	@LanguageID NVARCHAR(50)
	,@VeterinaryDiseaseReportID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS'
		,@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT 
			 STUFF((
					SELECT ', ' + speciesType.name
					FROM dbo.tlbSpecies s
					INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) AS speciesType ON speciesType.idfsReference = s.idfsSpeciesType
					INNER JOIN dbo.tlbHerd AS h ON h.idfHerd = s.idfHerd AND h.idfFarm = v.idfFarm AND h.intRowStatus = 0
					WHERE s.intRowStatus = 0 
					GROUP BY speciesType.name
					FOR XML PATH('')
						,TYPE
					).value('.[1]', 'NVARCHAR(MAX)'), 1, 2, '') AS SpeciesList
		FROM dbo.tlbVetCase v
		WHERE v.idfVetCase = @VeterinaryDiseaseReportID;
				
		SELECT @ReturnCode AS ReturnCode
			,@ReturnMessage AS ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode
			,@ReturnMessage;

		THROW;
	END CATCH;
END;
