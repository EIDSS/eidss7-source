-- ================================================================================================
-- Name: USSP_GBL_SAMPLE_SET
--
-- Description:	Inserts or updates sample records for various non-laboratory module use cases.
--
--	Revision History:
--	Name            Date		Change Detail
--	--------------- ----------	-------------------------------------------------------------------
--	Stephen Long    04/17/2019	Initial release.
--	Stephen Long    03/11/2020	Changed entered date on insert to use get date.
--	Stephen Long    04/20/2020	Changed original sample ID to parent sample ID; removed from 
--								insert as this field is for aliquots/derivatives in the lab module.
--								In future update, recommend removing parameter.
--	Stephen Long    08/25/2020	Moved local/field sample ID set to insert or update.
--	Mark Wilson     10/20/2021	removed @LanguageID, added @AuditUser, re-worked insert and update.
--	Stephen Long    01/19/2022	Added row action check of 1 to sync up with row action type enum.
--	Stephen Long    01/22/2022	Removed set of lab module source, let the default value apply.
--	Stephen Long    03/30/2022	Removed set of root sample ID on update.
--	Stephen Long    08/02/2022	Removed set of current side ID and sample status type ID on update; 
--								should only be for lab.
--	Stephen Long	08/12/2022	Removed set of entered date on update.
--	Doug Albanese	08/26/2022	Formatted SQL, after testing problem from HAS.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_SAMPLE_SET]
(
    @AuditUserName NVARCHAR(100) = NULL,
    @SampleID BIGINT OUTPUT,
    @SampleTypeID BIGINT,
    @RootSampleID BIGINT = NULL,
    @ParentSampleID BIGINT = NULL,
    @HumanID BIGINT = NULL,
    @SpeciesID BIGINT = NULL,
    @AnimalID BIGINT = NULL,
    @VectorID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @VectorSessionID BIGINT = NULL,
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @CollectionDate DATETIME = NULL,
    @CollectedByPersonID BIGINT = NULL,
    @CollectedByOrganizationID BIGINT = NULL,
    @SentDate DATETIME = NULL,
    @SentToOrganizationID BIGINT = NULL,
    @EIDSSLocalFieldSampleID NVARCHAR(200) = NULL,
    @SiteID BIGINT,
    @EnteredDate DATETIME = NULL,
    @ReadOnlyIndicator BIT,
    @SampleStatusTypeID BIGINT = NULL,
    @Comments NVARCHAR(500) = NULL,
    @CurrentSiteID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @BirdStatusTypeID BIGINT = NULL,
    @RowStatus INT,
    @RowAction CHAR
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --Local/field sample EIDSS ID. Only system assign when user leaves blank.
        IF @EIDSSLocalFieldSampleID IS NULL
           OR @EIDSSLocalFieldSampleID = ''
        BEGIN
            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Sample Field Barcode',
                                               @NextNumberValue = @EIDSSLocalFieldSampleID OUTPUT,
                                               @InstallationSite = NULL;
        END;
		
        IF @RowAction = 'I' OR @RowAction = '1' -- Insert
			BEGIN
				EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbMaterial',
												  @idfsKey = @SampleID OUTPUT;

				INSERT INTO dbo.tlbMaterial
				(
					idfMaterial,
					idfsSampleType,
					idfRootMaterial,
					idfParentMaterial,
					idfHuman,
					idfSpecies,
					idfAnimal,
					idfMonitoringSession,
					idfFieldCollectedByPerson,
					idfFieldCollectedByOffice,
					idfMainTest,
					datFieldCollectionDate,
					datFieldSentDate,
					strFieldBarcode,
					idfVectorSurveillanceSession,
					idfVector,
					idfsSampleStatus,
					datEnteringDate,
					strNote,
					idfsSite,
					intRowStatus,
					rowguid,
					idfSendToOffice,
					blnReadOnly,
					idfsBirdStatus,
					idfHumanCase,
					idfVetCase,
					idfsCurrentSite,
					SourceSystemNameID,
					SourceSystemKeyValue,
					DiseaseID,
					AuditCreateUser,
					AuditCreateDTM,
					AuditUpdateUser,
					AuditUpdateDTM,
					TestUnassignedIndicator,
					TestCompletedIndicator,
					TransferIndicator
				)
				VALUES
				(
					@SampleID,
					@SampleTypeID,
					@SampleID,
					@ParentSampleID,
					@HumanID,
					@SpeciesID,
					@AnimalID,
					@MonitoringSessionID,
					@CollectedByPersonID,
					@CollectedByOrganizationID,
					NULL,
					@CollectionDate,
					@SentDate,
					@EIDSSLocalFieldSampleID,
					@VectorSessionID,
					@VectorID,
					@SampleStatusTypeID,
					GETDATE(),
					@Comments,
					@SiteID,
					0  ,
					NEWID(),
					@SentToOrganizationID,
					@ReadOnlyIndicator,
					@BirdStatusTypeID,
					@HumanDiseaseReportID,
					@VeterinaryDiseaseReportID,
					@CurrentSiteID,
					10519001,
					'[{"idfMaterial":' + CAST(@SampleID AS NVARCHAR(300)) + '}]',
					@DiseaseID,
					@AuditUserName,
					GETDATE(),
					@AuditUserName,
					GETDATE(),
					1,
					0,
					0
				);
			END;
        ELSE
			BEGIN
				UPDATE dbo.tlbMaterial
				SET 
					idfsSampleType = @SampleTypeID,
					idfHuman = @HumanID,
					idfSpecies = @SpeciesID,
					idfAnimal = @AnimalID,
					idfMonitoringSession = @MonitoringSessionID,
					idfFieldCollectedByPerson = @CollectedByPersonID,
					idfFieldCollectedByOffice = @CollectedByOrganizationID,
					datFieldCollectionDate = @CollectionDate,
					datFieldSentDate = @SentDate,
					strFieldBarcode = @EIDSSLocalFieldSampleID,
					idfVectorSurveillanceSession = @VectorSessionID,
					idfVector = @VectorID,
					strNote = @Comments,
					idfsSite = @SiteID,
					intRowStatus = @RowStatus,
					idfSendToOffice = @SentToOrganizationID,
					blnReadOnly = @ReadOnlyIndicator,
					idfHumanCase = @HumanDiseaseReportID,
					idfVetCase = @VeterinaryDiseaseReportID,
					DiseaseID = @DiseaseID,
					idfsBirdStatus = @BirdStatusTypeID,
					AuditUpdateUser = @AuditUserName,
					AuditUpdateDTM = GETDATE()
				WHERE 
					idfMaterial = @SampleID;
			END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
