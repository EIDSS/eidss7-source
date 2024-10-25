




--*************************************************************
-- Name 				: USSP_HUMAN_DISEASE_VACCINATIONS_DEDUP_SET
-- Description			: update Human Disease Report Vaccinations during dedup
--          
-- Author               : HAP
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- Mark Wilson		20220610	initial release
-- Testing code:
-- exec USSP_HUMAN_DISEASE_VACCINATIONS_DEDUP_SET null
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_HUMAN_DISEASE_VACCINATIONS_DEDUP_SET] 
    @idfHumanCase						BIGINT = NULL,
	@VaccinationsParameters				NVARCHAR(MAX) = NULL,
	@outbreakCall						INT = 0,
	@User								NVARCHAR(100) = ''
AS
BEGIN
	DECLARE

		@humanDiseaseReportVaccinationUID	BIGINT, -- HumanDiseaseReportVaccination.humanDiseaseReportVaccinationUID Primary Key
		@vaccinationName					nvarchar(200), -- HumanDiseaseReportVaccination.VaccinationName
		@vaccinationDate					DATETIME = NULL, --HumanDiseaseReportVaccination.VaccinationDate 
		@RowID								BIGINT

	DECLARE  @VaccinationsTemp TABLE 
	(				
		[humanDiseaseReportVaccinationUID] [bigint] NULL,
		[idfHumanCase] [bigint] NULL,
		[vaccinationName] [nvarchar](200) NULL,
		[vaccinationDate] [datetime2] NULL
	)

	INSERT INTO	@VaccinationsTemp 
	SELECT * FROM OPENJSON(@VaccinationsParameters) 
			WITH (
					[humanDiseaseReportVaccinationUID] [bigint],
					[idfHumanCase] [bigint],
					[vaccinationName] [nvarchar](200),
					[vaccinationDate] [datetime2]
				)

		WHILE EXISTS (SELECT * FROM @VaccinationsTemp)
			BEGIN

				SELECT TOP 1
					@RowID=humanDiseaseReportVaccinationUID,
					@humanDiseaseReportVaccinationUID = humanDiseaseReportVaccinationUID,
					@vaccinationName = vaccinationName,
					@vaccinationDate = vaccinationDate
				FROM @VaccinationsTemp

				UPDATE dbo.HumanDiseaseReportVaccination
				SET	VaccinationName = @vaccinationName,
					VaccinationDate = @vaccinationDate,	
					idfHumanCase = @idfHumanCase,
					intRowStatus = 0,
					AuditUpdateUser = @User,
					AuditUpdateDTM = GETDATE()	

				WHERE humanDiseaseReportVaccinationUID = @humanDiseaseReportVaccinationUID

			DELETE TOP (1) FROM @VaccinationsTemp	

			END

END
