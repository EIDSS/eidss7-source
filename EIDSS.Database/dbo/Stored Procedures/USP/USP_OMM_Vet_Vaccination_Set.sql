
--*************************************************************
-- Name: [USP_OMM_Vet_Vaccination_Set]
-- Description: Insert/Update for Outbreak Case
--          
-- Author: Doug Albanese
-- Revision History
--		Name			Date		Change Detail
--    Doug Albanese		4/19/2019	New SP
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Vet_Vaccination_Set]
(    
	@LangID									NVARCHAR(50),
	@idfVaccination							BIGINT = -1,
	@idfVetCase								BIGINT = -1,
	@idfsDiagnosis							BIGINT = NULL,
	@datVaccination							DATETIME = NULL,
	@idfSpecies								BIGINT = NULL,
	@intVaccinated							INT = NULL,
	@idfsType								BIGINT = NULL,
	@idfsRoute								BIGINT = NULL,
	@strLotNumber							NVARCHAR(200),
	@strManufacturer						NVARCHAR(200),
	@strNote								NVARCHAR(200),
	@intRowStatus							INT = 0
)
AS

BEGIN    

	DECLARE	@returnCode						INT = 0;
	DECLARE @returnMsg						NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		
		IF @idfVaccination = -1
			BEGIN

				Declare @SupressSelect table
				( retrunCode int,
					returnMsg varchar(200)
				)

				INSERT INTO @SupressSelect
				EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbVaccination', @idfVaccination OUTPUT;

				INSERT INTO tlbVaccination
							(
								idfVaccination, 
								idfVetCase, 
								idfSpecies, 
								idfsVaccinationType, 
								idfsVaccinationRoute, 
								idfsDiagnosis, 
								datVaccinationDate, 
								strManufacturer,
								strLotNumber, 
								intNumberVaccinated, 
								strNote, 
								intRowStatus
							)
							VALUES
							(
								@idfVaccination, 
								@idfVetCase, 
								@idfSpecies, 
								@idfsType, 
								@idfsRoute, 
								@idfsDiagnosis, 
								@datVaccination, 
								@strManufacturer,
								@strLotNumber, 
								@intVaccinated, 
								@strNote, 
								0
							)

			END
		ELSE
			BEGIN
				
				UPDATE
						tlbVaccination
				SET
						idfSpecies = @idfSpecies,
						idfsVaccinationType = @idfsType,
						idfsVaccinationRoute = @idfsRoute,
						idfsDiagnosis = @idfsDiagnosis,
						datVaccinationDate = @datVaccination,
						strManufacturer = @strManufacturer,
						strLotNumber = @strLotNumber,
						intNumberVaccinated = @intVaccinated,
						strNote = @strNote,
						intRowStatus = @intRowStatus
				WHERE
						idfVaccination = @idfVaccination
			END

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		;throw;
	END CATCH

	SELECT	@returnCode as returnCode, @returnMsg as returnMsg
	
END
