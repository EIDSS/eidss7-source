--*************************************************************
-- Name 				:	USP_HUM_HUMAN_DISEASE_DEL
-- Description			:	delete human disease record
--          
-- Author               :	Jeff Johnson
-- Revision History
--	Name			Date			Change Detail
--	JWJ				20180508		created
--	Mark Wilson		20220526		updated the logic to support multiple testing records
--   Ann Xiong       11/01/2022		Updated to display message and not delete the disease report when the disease report is associated with an Outbreak Session 
--    								or when the disease report is associated with at least one child object (Test or Sample)
--
---exec USP_HUM_HUMAN_DISEASE_DEL
--*************************************************************
CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_DISEASE_DEL]
(
	@idfHumanCase	BIGINT  -- tlbHumanCase.idfHumanCase Primary Key
	,@idfUserID BIGINT
	,@idfSiteId BIGINT
	,@DeduplicationIndicator BIT = 0
)
AS
DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(MAX) = 'SUCCESS' 

declare @geoLocationId as TABLE
    (
      idfObject bigint,
	  idfTable bigint
    )

declare @tlbHumanCase as TABLE
    (
      idfObject bigint,
	  idfTable bigint
    )
declare @gHumanDiseaseReportRelationshipId as TABLE
    (
      idfObject bigint,
	  idfTable bigint
    )
declare @tlbAntimicrobialTherapyId as TABLE
    (
      idfObject bigint,
	  idfTable bigint
    )
declare @HumanDiseaseReportVaccinationId as TABLE
    (
      idfObject bigint,
	  idfTable bigint
    )
declare @tlbContactedCasePersonId as TABLE
(
      idfObject bigint,
	  idfTable bigint
)
declare @tlbMaterialId as TABLE
(
      idfObject bigint,
	  idfTable bigint
)

declare @tlbTestingId as TABLE
(
      idfObject bigint,
	  idfTable bigint
)

declare @tlbTestValidationId as TABLE
(
      idfObject bigint,
	  idfTable bigint
)

declare @idfsDataAuditEventType bigint =10016002;
declare @idfsObjectType bigint =10017026;
declare @idfObject bigint =@idfHumanCase;
declare @idfObjectTable bigint =75610000000;
declare @idfDataAuditEvent bigint;

BEGIN

	BEGIN TRY

		BEGIN TRANSACTION

		DECLARE @NonLaboratoryTestIndicator INT = 1

		DECLARE @SampleCount AS INT = 0
			,@TestCount AS INT = 0
			,@OutbreakSessionCount AS INT = 0;

		SELECT @SampleCount = COUNT(*)
		FROM dbo.tlbMaterial
		WHERE idfHumanCase = @idfHumanCase
			AND intRowStatus = 0;

		SELECT @TestCount = COUNT(*)
		FROM dbo.tlbTesting t
		INNER JOIN dbo.tlbMaterial m ON m.idfMaterial = t.idfMaterial
			AND m.intRowStatus = 0
		WHERE m.idfHumanCase = @idfHumanCase
			AND t.intRowStatus = 0;

		SELECT @OutbreakSessionCount = COUNT(*)
		FROM dbo.tlbHumanCase v
		INNER JOIN dbo.tlbOutbreak o ON o.idfOutbreak = v.idfOutbreak
			AND o.intRowStatus = 0
		WHERE v.idfHumanCase = @idfHumanCase
			AND v.idfOutbreak IS NOT NULL

		IF @DeduplicationIndicator = 0
		BEGIN
			IF @SampleCount = 0
				AND @TestCount = 0
				AND @OutbreakSessionCount = 0
			BEGIN
				UPDATE dbo.tlbHumanCase
				SET intRowStatus = 1	
				OUTPUT INSERTED.idfHumanCase,75610000000 into @tlbHumanCase
				WHERE	idfHumanCase = @idfHumanCase
				AND		intRowStatus = 0
			
				-- Continue deleting the child records

				-- Delete Location of Exposure
				UPDATE tg
				SET tg.intRowStatus = 1
				OUTPUT INSERTED.idfGeoLocation,75580000000 into @geoLocationId
				FROM dbo.tlbGeoLocation tg
				INNER JOIN dbo.tlbHumanCase thc ON thc.idfPointGeoLocation = tg.idfGeoLocation
				WHERE thc.idfHumanCase = @idfHumanCase

				--Delete from HumanDiseaseReportRelationship
				UPDATE hrr
				SET hrr.intRowStatus = 1
				OUTPUT INSERTED.HumanDiseasereportRelnUID,53577790000000 into @gHumanDiseaseReportRelationshipId
				FROM dbo.HumanDiseaseReportRelationship hrr 
				WHERE hrr.HumanDiseaseReportID = @idfHumanCase

				-- Delete from Antiviral Therapy
				UPDATE tat
				SET tat.intRowStatus = 1
				OUTPUT INSERTED.idfAntimicrobialTherapy,75470000000 into @tlbAntimicrobialTherapyId
				FROM dbo.tlbAntimicrobialTherapy tat
				WHERE tat.idfHumanCase = @idfHumanCase

				-- Delete from Human Disease Report Vaccination
				UPDATE hrv
				SET hrv.intRowStatus = 1
				OUTPUT INSERTED.HumanDiseaseReportVaccinationUID,53577590000000 into @HumanDiseaseReportVaccinationId
				FROM dbo.HumanDiseaseReportVaccination hrv
				WHERE hrv.idfHumanCase = @idfHumanCase

				-- Delete from Contacted Case Person
				UPDATE tccp
				SET tccp.intRowStatus = 1
				OUTPUT INSERTED.idfContactedCasePerson,75500000000 into @tlbContactedCasePersonId
				FROM dbo.tlbContactedCasePerson tccp
				WHERE tccp.idfHumanCase = @idfHumanCase

				--If record is being soft-deleted, then check if the test record was originally created 
				--in the laboaratory module.  If it was, then disassociate the test record from the 
				--human disease Report, so that the test record remains in the laboratory module 
				--for further action.
---------------------------------------------------------------------------------------------------------------
				-- updated the logic to support multiple testing records
				SET @NonLaboratoryTestIndicator = 1
				IF EXISTS 
				(
					SELECT tt.blnNonLaboratoryTest 
					FROM dbo.tlbTesting tt
					INNER JOIN dbo.tlbMaterial tm ON tt.idfMaterial = tm.idfMaterial AND tm.idfHumanCase = @idfHumanCase
					WHERE tt.blnNonLaboratoryTest = 0
				)
				SET @NonLaboratoryTestIndicator = 0

				IF @NonLaboratoryTestIndicator = 1 -- Okay to delete
				BEGIN
						-- Delete samples
						UPDATE tm
						SET tm.intRowStatus = 1
						OUTPUT INSERTED.idfMaterial,75620000000 into @tlbMaterialId
						FROM dbo.tlbMaterial tm WHERE tm.idfHumanCase = @idfHumanCase

						-- Delete tests
						UPDATE tt
						SET tt.intRowStatus = 1
						OUTPUT INSERTED.idfTesting,75740000000 into @tlbTestingId
						FROM dbo.tlbTesting tt
						INNER JOIN dbo.tlbMaterial tm ON tt.idfMaterial = tm.idfMaterial
						WHERE tm.idfHumanCase = @idfHumanCase

						-- Delete test valiation
						UPDATE tv
						SET tv.intRowStatus = 1
						OUTPUT INSERTED.idfTestValidation,75750000000 into @tlbTestValidationId
						FROM dbo.tlbTestValidation tv
						INNER JOIN dbo.tlbTesting tt ON tt.idfTesting = tv.idfTesting
						INNER JOIN dbo.tlbMaterial tm ON tt.idfMaterial = tm.idfMaterial
						WHERE tm.idfHumanCase = @idfHumanCase
				END
				ELSE -- Disassociate Samples from Human Case
				BEGIN
						UPDATE dbo.tlbMaterial
						SET idfHumanCase = NULL
						WHERE idfHumanCase= @idfHumanCase

				END

				--DataAudit 
				-- insert record into tauDataAuditEvent
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable, @idfDataAuditEvent OUTPUT
				-- insert into delete 

					-- Insert statements for tlbHumanCase
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @tlbHumanCase

				-- Insert statements for geoLocation
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @geoLocationId

				-- Insert statements for HumanDiseaseReportRelationship
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @gHumanDiseaseReportRelationshipId

				-- Insert statements for tlbAntimicrobialTherapy
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @tlbAntimicrobialTherapyId

				-- Insert statements for HumanDiseaseReportVaccination
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @HumanDiseaseReportVaccinationId
				
				-- Insert statements for tlbContactedCasePersonId
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @tlbContactedCasePersonId

				-- Insert statements for tlbMaterial
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @tlbMaterialId

				-- Insert statements for tlbTesting
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @tlbTestingId

				-- Insert statements for tlbTestValidation
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
				SELECT @idfDataAuditEvent, idfTable, idfObject
				FROM @tlbTestValidationId
				
			END
			ELSE
			BEGIN
				IF @OutbreakSessionCount > 0
				BEGIN
					SET @ReturnCode = 2;
					SET @ReturnMsg = 'Unable to delete this record as it is associated with an Outbreak Session.';
				END;
				ELSE
				BEGIN
					SET @ReturnCode = 1;
					SET @ReturnMsg = 'Unable to delete this record as it contains dependent child objects.';
				END;
			END;
		END
		ELSE
		BEGIN
			UPDATE dbo.tlbHumanCase
			SET intRowStatus = 1						
			WHERE	idfHumanCase = @idfHumanCase
			AND		intRowStatus = 0
			
			-- Continue deleting the child records

			-- Delete Location of Exposure
			UPDATE tg
			SET tg.intRowStatus = 1
			FROM dbo.tlbGeoLocation tg
			INNER JOIN dbo.tlbHumanCase thc ON thc.idfPointGeoLocation = tg.idfGeoLocation
			WHERE thc.idfHumanCase = @idfHumanCase

			--Delete from HumanDiseaseReportRelationship
			UPDATE hrr
			SET hrr.intRowStatus = 0
			FROM dbo.HumanDiseaseReportRelationship hrr 
			WHERE hrr.HumanDiseaseReportID = @idfHumanCase

			-- Delete from Antiviral Therapy
			UPDATE tat
			SET tat.intRowStatus = 1
			FROM dbo.tlbAntimicrobialTherapy tat
			WHERE tat.idfHumanCase = @idfHumanCase

			-- Delete from Human Disease Report Vaccination
			UPDATE hrv
			SET hrv.intRowStatus = 1
			FROM dbo.HumanDiseaseReportVaccination hrv
			WHERE hrv.idfHumanCase = @idfHumanCase

			-- Delete from Contacted Case Person
			UPDATE tccp
			SET tccp.intRowStatus = 1
			FROM dbo.tlbContactedCasePerson tccp
			WHERE tccp.idfHumanCase = @idfHumanCase

			--If record is being soft-deleted, then check if the test record was originally created 
			--in the laboaratory module.  If it was, then disassociate the test record from the 
			--human disease Report, so that the test record remains in the laboratory module 
			--for further action.

			--Data Audito



---------------------------------------------------------------------------------------------------------------
-- updated the logic to support multiple testing records
			SET @NonLaboratoryTestIndicator = 1
			IF EXISTS 
			(
				SELECT tt.blnNonLaboratoryTest 
				FROM dbo.tlbTesting tt
				INNER JOIN dbo.tlbMaterial tm ON tt.idfMaterial = tm.idfMaterial AND tm.idfHumanCase = @idfHumanCase
				WHERE tt.blnNonLaboratoryTest = 0
			)
			SET @NonLaboratoryTestIndicator = 0

			IF @NonLaboratoryTestIndicator = 1 -- Okay to delete
				BEGIN
					-- Delete samples
					UPDATE tm
					SET tm.intRowStatus = 1
					FROM dbo.tlbMaterial tm WHERE tm.idfHumanCase = @idfHumanCase

					-- Delete tests
					UPDATE tt
					SET tt.intRowStatus = 1
					FROM dbo.tlbTesting tt
					INNER JOIN dbo.tlbMaterial tm ON tt.idfMaterial = tm.idfMaterial
					WHERE tm.idfHumanCase = @idfHumanCase

					-- Delete test valiation
					UPDATE tv
					SET tv.intRowStatus = 1
					FROM dbo.tlbTestValidation tv
					INNER JOIN dbo.tlbTesting tt ON tt.idfTesting = tv.idfTesting
					INNER JOIN dbo.tlbMaterial tm ON tt.idfMaterial = tm.idfMaterial
					WHERE tm.idfHumanCase = @idfHumanCase
				END
			ELSE -- Disassociate Samples from Human Case
				BEGIN
					UPDATE dbo.tlbMaterial
					SET idfHumanCase = NULL
					WHERE idfHumanCase= @idfHumanCase
                		END

		END
			
			IF @@TRANCOUNT > 0 
				COMMIT
			
			SELECT 
				@returnCode 'ReturnCode',
				@returnMsg 'ReturnMessage'
	END TRY
	BEGIN CATCH
			IF @@Trancount = 1 
				THROW;
				
	END CATCH
END
