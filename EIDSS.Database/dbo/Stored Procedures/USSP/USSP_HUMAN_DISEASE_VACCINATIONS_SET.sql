--*************************************************************
-- Name 				: USSP_HUMAN_DISEASE_VACCINATIONS_SET
-- Description			: add update delete Human Disease Report Vaccinations
--          
-- Author               : HAP
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- HAP				20190104     Created
-- HAP				20190109    Update delete of temp table
-- Leo Tracchia		20221011	updated field names on json string - for bug fix 3871
--
-- Testing code:
-- exec USSP_HUMAN_DISEASE_VACCINATIONS_SET null
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_HUMAN_DISEASE_VACCINATIONS_SET] 
  @idfHumanCase						BIGINT = NULL,
	@VaccinationsParameters				NVARCHAR(MAX) = NULL,
	@outbreakCall						INT = 0,
	@User								NVARCHAR(100) = ''
AS
Begin
	SET NOCOUNT ON;
		Declare @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)
	DECLARE

	@HumanDiseaseReportVaccinationUID	BIGINT, -- HumanDiseaseReportVaccination.HumanDiseaseReportVaccinationUID Primary Key
	@VaccinationName					nvarchar(200), -- HumanDiseaseReportVaccination.VaccinationName
	@VaccinationDate					DATETIME = NULL, --HumanDiseaseReportVaccination.VaccinationDate 
	@intRowStatus						INT = 0,
	@RowAction							NVARCHAR(1),
	@RowID								BIGINT

	DECLARE @returnCode	INT = 0;
	DECLARE	@returnMsg	NVARCHAR(MAX) = 'SUCCESS';

	DECLARE  @VaccinationsTemp TABLE (				
					[HumanDiseaseReportVaccinationUID] [bigint] NULL,
					[idfHumanCase] [bigint] NULL,
					[VaccinationName] [nvarchar](200) NULL,
					[VaccinationDate] [datetime2] NULL,
					[RowAction] [nvarchar] NULL
			)

	INSERT INTO	@VaccinationsTemp 
	SELECT * FROM OPENJSON(@VaccinationsParameters) 
			WITH (
					[humanDiseaseReportVaccinationUID] [bigint],
					[idfHumanCase] [bigint],
					[vaccinationName] [nvarchar](200),
					[vaccinationDate] [datetime2],
					[rowAction] [nvarchar](1)
				)
	BEGIN TRY  
		WHILE EXISTS (SELECT * FROM @VaccinationsTemp)
			BEGIN
				SELECT TOP 1
					@RowID=humanDiseaseReportVaccinationUID,
					@HumanDiseaseReportVaccinationUID=humanDiseaseReportVaccinationUID,
					@VaccinationName	= vaccinationName,
					@VaccinationDate	= vaccinationDate,
					@RowAction			= rowAction
				FROM @VaccinationsTemp

				IF NOT EXISTS(SELECT HumanDiseaseReportVaccinationUID from HumanDiseaseReportVaccination WHERE HumanDiseaseReportVaccinationUID = @HumanDiseaseReportVaccinationUID)
				BEGIN
						IF @outbreakCall = 1
							BEGIN
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'HumanDiseaseReportVaccination',  @HumanDiseaseReportVaccinationUID OUTPUT;
							END
						ELSE
							BEGIN
								INSERT INTO @SupressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'HumanDiseaseReportVaccination',  @HumanDiseaseReportVaccinationUID OUTPUT;
							END

						INSERT INTO	dbo.HumanDiseaseReportVaccination
									(
									 HumanDiseaseReportVaccinationUID,
									 idfHumanCase,		
									 VaccinationName,
									 VaccinationDate,				
									 intRowStatus,
									 AuditCreateUser,
									 AuditCreateDTM	
									)
							VALUES (
									 @HumanDiseaseReportVaccinationUID,
									 @idfHumanCase,		
									 @VaccinationName,
									 @VaccinationDate,
									 0, --Always 0, because this is a new record
									 @User,
									 Getdate()	
									)
					END
				ELSE
					BEGIN
						IF @RowAction = 'D' 
							BEGIN
								SET @intRowStatus = 1
							END
						ELSE
							BEGIN
								SET @intRowStatus = 0
							END

						UPDATE dbo.HumanDiseaseReportVaccination
							SET			
									 VaccinationName  = @VaccinationName,
									 VaccinationDate  = @VaccinationDate,				
									 intRowStatus	  = @intRowStatus,
									 AuditUpdateUser  = @User,
									 AuditUpdateDTM	  =  Getdate()	

							WHERE	HumanDiseaseReportVaccinationUID = @HumanDiseaseReportVaccinationUID
					END

						SET ROWCOUNT 1
					DELETE FROM @VaccinationsTemp
					SET ROWCOUNT 0
			END		

	END TRY
	BEGIN CATCH
		THROW;
		
	END CATCH
END
