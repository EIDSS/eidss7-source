



--*************************************************************
-- Name 				: USSP_VCTS_DETAILEDCOLLECTIONS_SET
-- Description			: SET Vector details with Sample and FieldTest User Defined Table Types
--          
-- Author               : Mike Kornegay
-- Revision History
--		Name		Date		Change Detail
--	Mike Kornegay	05/03/2022	Initial Creation - copied from USP_VCTS_VECT_STRUCTURED_SET so that detailed collections can be saved
--								from USP_VCTS_SURVEILLANCESESSION_SET.
--	Mike Kornegay	05/16/2022	Removed INSERT INTO on EXEC statements.
--	Mike Kornegay	05/20/2022	Corrected idfVector insert for USSP_GBL_TEST_SET.
--	Mike Kornegay	07/18/2022	Added events parameter and site alert logic for tests and samples
--	Mike Kornegay	07/21/2022	Removed events parameter - not needed

--
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_VCTS_DETAILEDCOLLECTIONS_SET]
(
    @LangID										NVARCHAR(50) = NULL, 
    @idfVector									BIGINT = NULL, 
    @idfsDetailedVectorSurveillanceSession		BIGINT = NULL, 
    @idfHostVector								BIGINT = NULL, 
    @strVectorID								NVARCHAR(50) = NULL, 
    @strFieldVectorID							NVARCHAR(50) = NULL, 
    @idfDetailedLocation						BIGINT = NULL, 
	@lucDetailedCollectionidfsResidentType		BIGINT	= NULL,
	@lucDetailedCollectionidfsGroundType		BIGINT = NULL,
	@lucDetailedCollectionidfsGeolocationType	BIGINT = 10036001,
	@lucDetailedCollectionidfsLocation			BIGINT = NULL,
	@lucDetailedCollectionstrApartment			NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrBuilding			NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrStreetName			NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrHouse				NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrPostCode			NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrDescription		NVARCHAR(200) = NULL,
	@lucDetailedCollectiondblDistance			FLOAT = NULL,
    @lucDetailedCollectionstrLatitude			FLOAT = NULL,
    @lucDetailedCollectionstrLongitude			FLOAT = NULL,
	@lucDetailedCollectiondblAccuracy			FLOAT = NULL,
	@lucDetailedCollectiondblAlignment			FLOAT = NULL,
	@blnForeignAddress							BIT = 0,
	@strForeignAddress							NVARCHAR(200) = NULL,
	@blnGeoLocationShared						BIT = 0, 
    @intDetailedElevation						INT = NULL, 
	@DetailedSurroundings						BIGINT = NULL, 
    @strGEOReferenceSource						NVARCHAR(500), 
    @idfCollectedByOffice						BIGINT = NULL, 
    @idfCollectedByPerson						BIGINT = NULL, 
    @datCollectionDateTime						DATETIME = NULL, 
    @idfsCollectionMethod						BIGINT = NULL, 
    @idfsBasisOfRecord							BIGINT = NULL, 
    @idfDetailedVectorType						BIGINT = NULL, 
    @idfsVectorSubType							BIGINT = NULL, 
    @intQuantity								INT = NULL, 
    @idfsSex									BIGINT = NULL, 
    @idfIdentIFiedByOffice						BIGINT = NULL, 
    @idfIdentIFiedByPerson						BIGINT = NULL, 
    @datIdentIFiedDateTime						DATETIME = NULL, 
    @idfsIdentIFicationMethod					BIGINT = NULL, 
    @idfObservation								BIGINT = NULL,
	@idfsFormTemplate							BIGINT = NULL,
	@idfsDayPeriod								BIGINT = NULL,
	@strComment									NVARCHAR(500) = NULL,
	@idfsEctoparASitesCollected					BIGINT = NULL,        
	@Samples									NVARCHAR(MAX) = NULL,
	@FieldTests									NVARCHAR(MAX) = NULL,
    @AuditUser									NVARCHAR(100) = NULL
)
AS 

DECLARE @datConcludedDate				DateTime = null

DECLARE @returnCode							INT = 0 
DECLARE	@returnMsg							NVARCHAR(max) = 'SUCCESS' 

DECLARE @intRowStatus INT = 0,
@datFieldCollectionDate datetime = GetDate(),
@datFieldSentDate datetime  = GetDate(),
@RecordAction NCHAR(1) = 'I',
@idfsSite INT = 1	

DECLARE @datReceivedDate datetime = GetDate(),
@datStartDate datetime = GetDate(),
@idfsTestStatus INT = 10001005,	-- default set to Not Started 	
@blnReadOnly    BIT = 0, 
@blnNonLaboratory   BIT = 0

		
DECLARE @idfMaterial                    BIGINT
DECLARE	@idfsSampleType					BIGINT
DECLARE	@idfVectorSurveillanceSession	BIGINT
DECLARE	@idfSendToOffice				BIGINT = NULL
DECLARE	@idfFieldCollectedByOffice		BIGINT = NULL

DECLARE @idfTesting						BIGINT 
DECLARE @strFieldBarCode				varchar(50)
DECLARE	@idfsTestName					BIGINT = NULL
DECLARE	@idfsTestCategory				BIGINT = NULL
DECLARE	@idfTestedByOffice				BIGINT = NULL
DECLARE	@idfsTestResult					BIGINT = NULL
DECLARE @idfTestedByPerson				BIGINT = NULL
DECLARE @idfsDiagnosis					BIGINT = NULL

	DECLARE @RowID BIGINT,
			@SampleID BIGINT,
            @SampleTypeID BIGINT = NULL,
            @RootSampleID BIGINT = NULL,
            @ParentSampleID BIGINT = NULL,
            @CollectedByPersonID BIGINT = NULL,
            @CollectedByOrganizationID BIGINT = NULL,
            @CollectionDate DATETIME = NULL,
            @SentDate DATETIME = NULL,
            @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
            @SampleStatusTypeID BIGINT = NULL,
			@SpeciesTypeID BIGINT = NULL,
            @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
            @SentToOrganizationID BIGINT = NULL,
            @ReadOnlyIndicator BIT = NULL,
            @CurrentSiteID BIGINT = NULL,
            @BirdStatusTypeID BIGINT = NULL,
            @PensideTestID BIGINT = NULL,
            @PensideTestResultTypeID BIGINT = NULL,
            @PensideTestNameTypeID BIGINT = NULL,
            @TestedByPersonID BIGINT = NULL,
            @TestedByOrganizationID BIGINT = NULL,
            @TestDate DATETIME = NULL,
            @PensideTestCategoryTypeID BIGINT = NULL,
            @TestID BIGINT = NULL,
            @TestNameTypeID BIGINT = NULL,
            @TestCategoryTypeID BIGINT = NULL,
            @TestResultTypeID BIGINT = NULL,
            @TestStatusTypeID BIGINT,
			@TestVectorID BIGINT = NULL,
            @BatchTestID BIGINT = NULL,
            @StartedDate DATETIME = NULL,
            @ResultDate DATETIME = NULL,
            @ResultEnteredByOrganizationID BIGINT = NULL,
            @ResultEnteredByPersonID BIGINT = NULL,
            @ValidatedByOrganizationID BIGINT = NULL,
            @ValidatedByPersonID BIGINT = NULL,
            @NonLaboratoryTestIndicator BIT,
            @ExternalTestIndicator BIT = NULL,
            @PerformedByOrganizationID BIGINT = NULL,
            @ReceivedDate DATETIME = NULL,
            @ContactPersonName NVARCHAR(200) = NULL,
            @TestMonitoringSesssionID BIGINT = NULL,
			@SpeciesID BIGINT = NULL,
			@AnimalID BIGINT = NULL,
			@FarmID BIGINT = NULL,
			@FarmMasterID  BIGINT = NULL,
			@FarmOwnerID BIGINT = NULL,
			@DiseaseID  BIGINT = NULL,
			@DateEntered DATETIME = NULL,
			@Comments NVARCHAR(200) = NULL,
			@SiteID BIGINT = NULL,
			@RowStatus INT,
			@RowAction INT,
			@RowActionChar CHAR;

	SET @Samples = REPLACE ( @Samples , '"0001-01-01T00:00:00"' , 'null')
	SET @FieldTests = REPLACE ( @FieldTests , '"0001-01-01T00:00:00"' , 'null')

    DECLARE @SamplesTemp TABLE
    (
        SampleID BIGINT NOT NULL,
        SampleTypeID BIGINT NULL,
        RootSampleID BIGINT NULL,
        ParentSampleID BIGINT NULL,
        SpeciesID BIGINT NULL,
        AnimalID BIGINT NULL,
        MonitoringSessionID BIGINT NULL,
        SampleStatusTypeID BIGINT NULL,
        CollectionDate DATETIME NULL,
        CollectedByOrganizationID BIGINT NULL,
        CollectedByPersonID BIGINT NULL,
        SentDate DATETIME NULL,
        SentToOrganizationID BIGINT NULL,
        EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL,
        Comments NVARCHAR(200) NULL,
        SiteID BIGINT NOT NULL,
        CurrentSiteID BIGINT NULL,
        EnteredDate DATETIME NULL,
        DiseaseID BIGINT NULL,
        BirdStatusTypeID BIGINT NULL,
        ReadOnlyIndicator BIT NULL,
        FarmID BIGINT NULL,
		FarmMasterID BIGINT NULL,
        FarmOwnerID BIGINT NULL,
        RowStatus INT NOT NULL,
        RowAction INT NULL
    );
    
	DECLARE @FieldTestsTemp TABLE
    (
        TestID BIGINT NOT NULL,
        TestNameTypeID BIGINT NULL,
        TestCategoryTypeID BIGINT NULL,
        TestResultTypeID BIGINT NULL,
        TestStatusTypeID BIGINT NOT NULL,
        DiseaseID BIGINT NOT NULL,
        SampleID BIGINT NULL,
        BatchTestID BIGINT NULL,
        ObservationID BIGINT NULL,
        TestNumber INT NULL,
        Comments NVARCHAR NULL,
        StartedDate DATETIME NULL,
        ResultDate DATETIME NULL,
        TestedByOrganizationID BIGINT NULL,
        TestedByPersonID BIGINT NULL,
        ResultEnteredByOrganizationID BIGINT NULL,
        ResultEnteredByPersonID BIGINT NULL,
        ValidatedByOrganizationID BIGINT NULL,
        ValidatedByPersonID BIGINT NULL,
        ReadOnlyIndicator BIT NOT NULL,
        NonLaboratoryTestIndicator BIT NOT NULL,
        ExternalTestIndicator BIT NULL,
        PerformedByOrganizationID BIGINT NULL,
        ReceivedDate DATETIME NULL,
        ContactPersonName NVARCHAR(200) NULL,
        RowStatus INT NOT NULL,
        RowAction INT NULL
    );

	INSERT INTO @SamplesTemp
    SELECT *
    FROM
        OPENJSON(@Samples)
        WITH
        (
            SampleID BIGINT,
            SampleTypeID BIGINT,
            RootSampleID BIGINT,
            ParentSampleID BIGINT,
            SpeciesID BIGINT,
            AnimalID BIGINT,
            MonitoringSessionID BIGINT,
            SampleStatusTypeID BIGINT,
            CollectionDate DATETIME2,
            CollectedByOrganizationID BIGINT,
            CollectedByPersonID BIGINT,
            SentDate DATETIME2,
            SentToOrganizationID BIGINT,
            EIDSSLocalOrFieldSampleID NVARCHAR(200),
            Comments NVARCHAR(200),
            SiteID BIGINT,
            CurrentSiteID BIGINT,
            EnteredDate DATETIME2,
            DiseaseID BIGINT,
            BirdStatusTypeID BIGINT,
            ReadOnlyIndicator BIT,
            FarmID BIGINT,
			FarmMasterID BIGINT,
            FarmOwnerID BIGINT,
            RowStatus INT,
            RowAction INT
        );
        
		INSERT INTO @FieldTestsTemp
		SELECT *
		FROM
			OPENJSON(@FieldTests)
			WITH
			(
				TestID BIGINT,
				TestNameTypeID BIGINT,
				TestCategoryTypeID BIGINT,
				TestResultTypeID BIGINT,
				TestStatusTypeID BIGINT,
				DiseaseID BIGINT,
				SampleID BIGINT,
				BatchTestID BIGINT,
				ObservationID BIGINT,
				TestNumber INT,
				Comments NVARCHAR(500),
				StartedDate DATETIME2,
				ResultDate DATETIME2,
				TestedByOrganizationID BIGINT,
				TestedByPersonID BIGINT,
				ResultEnteredByOrganizationID BIGINT,
				ResultEnteredByPersonID BIGINT,
				ValidatedByOrganizationID BIGINT,
				ValidatedByPersonID BIGINT,
				ReadOnlyIndicator BIT,
				NonLaboratoryTestIndicator BIT,
				ExternalTestIndicator BIT,
				PerformedByOrganizationID BIGINT,
				ReceivedDate DATETIME2,
				ContactPersonName NVARCHAR(200),
				RowStatus INT,
				RowAction INT
			);
		
		Declare @SupressSelect table
		( retrunCode int,
			returnMsg varchar(200)
		)

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		-- Create GeoLocation
			--INSERT INTO @SupressSelect
			EXEC dbo.USSP_GBL_ADDRESS_SET 	@idfDetailedLocation OUTPUT,
											@lucDetailedCollectionidfsResidentType,
											@lucDetailedCollectionidfsGroundType,
											@lucDetailedCollectionidfsGeolocationType,
											@lucDetailedCollectionidfsLocation,
											@lucDetailedCollectionstrApartment,
											@lucDetailedCollectionstrBuilding,
											@lucDetailedCollectionstrStreetName,
											@lucDetailedCollectionstrHouse,
											@lucDetailedCollectionstrPostCode,
											@lucDetailedCollectionstrDescription,
											@lucDetailedCollectiondblDistance,
											@lucDetailedCollectionstrLatitude,
											@lucDetailedCollectionstrLongitude,
											NULL,
											@lucDetailedCollectiondblAccuracy,
											@lucDetailedCollectiondblAlignment,
											@blnForeignAddress,
											@strForeignAddress,
											@blnGeoLocationShared,
                                            @AuditUser,
											@returnCode OUTPUT,
											@returnMsg OUTPUT;

		IF NOT EXISTS( SELECT idfObservation from dbo.tlbObservation where idfObservation = 0 )
		BEGIN		 
			Insert into [dbo].[tlbObservation]
			(idfObservation, idfsFormTemplate, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, idfsSite,AuditCreateUser) 
			values (0, null, 0, NEWID(), null, null, 1, @AuditUser)
		END

		--IF @idfObservation <> 0
		--BEGIN
		----INSERT INTO @SupressSelect
		--EXEC dbo.USP_FLEXFORMS_OBSERVATIONS_SET @idfObservation, @idfsFormTemplate
		--END
		IF NOT EXISTS( SELECT * FROM dbo.tlbVector WHERE idfVector = @idfVector)	
			BEGIN

					--INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbVector', @idfVector OUTPUT

					--INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NextNumber_GET 'Vector Surveillance Vector', @strVectorID OUTPUT , NULL --N'AS Session'

				INSERT INTO dbo.tlbVector
						   (idfVector, 
							idfVectorSurveillanceSession, 
							idfHostVector, 
							strVectorID, 
							strFieldVectorID, 
							idfLocation, 
							intElevation, 
							idfsSurrounding, 
							strGEOReferenceSources, 
							idfCollectedByOffice, 
							idfCollectedByPerson, 
							datCollectionDateTime, 
							--intCollectionEffort, 
							idfsCollectionMethod, 
							idfsBASisOfRecord, 
							idfsVectorType, 
							idfsVectorSubType, 
							intQuantity, 
							idfsSex, 
							idfIdentIFiedByOffice, 
							idfIdentIFiedByPerson, 
							datIdentIFiedDateTime, 
							idfsIdentIFicationMethod, 
							idfObservation
							,idfsDayPeriod
							,strComment
							,idfsEctoparASitesCollected
							,AuditCreateDTM
                            ,AuditCreateUser
						   )
					 VALUES
						   (
							@idfVector, 
							@idfsDetailedVectorSurveillanceSession, 
							@idfHostVector, 
							@strVectorID, 
							@strFieldVectorID, 
							@idfDetailedLocation, 
							@intDetailedElevation, 
							@DetailedSurroundings, 
							@strGEOReferenceSource, 
							@idfCollectedByOffice, 
							@idfCollectedByPerson, 
							@datCollectionDateTime, 
							--@intCollectionEffort, 
							@idfsCollectionMethod, 
							@idfsBASisOfRecord, 
							@idfDetailedVectorType, 
							@idfsVectorSubType, 
							@intQuantity, 
							@idfsSex, 
							@idfIdentifiedByOffice, 
							@idfIdentIFiedByPerson, 
							@datIdentIFiedDateTime, 
							@idfsIdentIFicationMethod, 
							@idfObservation,
							@idfsDayPeriod,
							@strComment,
							@idfsEctoparASitesCollected,
							GETDATE(),
                            @AuditUser
						   )
			END
		ELSE 
			BEGIN
				UPDATE dbo.tlbVector
				   SET 
							idfVectorSurveillanceSession = @idfsDetailedVectorSurveillanceSession, 
							idfHostVector = @idfHostVector, 
							strVectorID = @strVectorID, 
							strFieldVectorID = @strFieldVectorID, 
							idfLocation = @idfDetailedLocation, 
							intElevation = @intDetailedElevation, 
							idfsSurrounding = @DetailedSurroundings, 
							strGEOReferenceSources = @strGEOReferenceSource, 
							idfCollectedByOffice = @idfCollectedByOffice, 
							idfCollectedByPerson = @idfCollectedByPerson, 
							datCollectionDateTime = @datCollectionDateTime, 
							--intCollectionEffort = @intCollectionEffort, 
							idfsCollectionMethod = @idfsCollectionMethod, 
							idfsBASisOfRecord = @idfsBASisOfRecord, 
							idfsVectorType = @idfDetailedVectorType, 
							idfsVectorSubType = @idfsVectorSubType, 
							intQuantity = @intQuantity, 
							idfsSex = @idfsSex, 
							idfIdentIFiedByOffice = @idfIdentifiedByOffice, 
							idfIdentIFiedByPerson = @idfIdentIFiedByPerson, 
							datIdentIFiedDateTime = @datIdentIFiedDateTime, 
							idfsIdentIFicationMethod =@idfsIdentIFicationMethod , 
							idfObservation = @idfObservation,
							idfsDayPeriod = @idfsDayPeriod,
							strComment = @strComment,
							idfsEctoparASitesCollected = @idfsEctoparASitesCollected,
                            AuditUpdateUser = @AuditUser,
                            AuditUpdateDTM = GETDATE()

				 WHERE 		idfVector = @idfVector
			END;

		WHILE EXISTS (SELECT * FROM @SamplesTemp)
			BEGIN
				SELECT TOP 1
					@RowID = SampleID,
					@SampleID = SampleID,
					@SampleTypeID = SampleTypeID,
					@RootSampleID = RootSampleID,
					@ParentSampleID = ParentSampleID,
					@SpeciesID = SpeciesID,
					@AnimalID = AnimalID,
					@CollectedByPersonID = CollectedByPersonID,
					@CollectedByOrganizationID = CollectedByOrganizationID,
					@CollectionDate = CollectionDate,
					@SentDate = SentDate,
					@EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
					@SampleStatusTypeID = SampleStatusTypeID,
					@FarmID = FarmID,
					@FarmMasterID = FarmMasterID,
					@DiseaseID = DiseaseID,
					@DateEntered = EnteredDate,
					@Comments = Comments,
					@SiteID = SiteID,
					@CurrentSiteID = CurrentSiteID,
					@RowStatus = RowStatus,
					@SentToOrganizationID = SentToOrganizationID,
					@BirdStatusTypeID = BirdStatusTypeID,
					@ReadOnlyIndicator = ReadOnlyIndicator,
					@RowAction = RowAction
				FROM @SamplesTemp;

				--DECLARE @Iteration INT = 0;

				--IF (@EIDSSLocalOrFieldSampleID IS NULL OR @EIDSSLocalOrFieldSampleID = '') AND @LinkLocalOrFieldSampleIDToReportID = 1
				--BEGIN
				--    SET @Iteration = @Iteration + 1;
				--    IF @Iteration < 10
				--    BEGIN
				--        SET @EIDSSLocalOrFieldSampleID = @EIDSSReportID + '-0' + CONVERT(NVARCHAR(4), @Iteration);
				--    END
				--    ELSE
				--    BEGIN
				--        SET @EIDSSLocalOrFieldSampleID = @EIDSSReportID + '-' + CONVERT(NVARCHAR(4), @Iteration);
				--    END;
				--END;


				--INSERT INTO @SuppressSelect
				EXECUTE dbo.USSP_GBL_SAMPLE_SET @AuditUser,
												@SampleID OUTPUT,
												@SampleTypeID,
												@RootSampleID,
												@ParentSampleID,
												@FarmOwnerID,
												@SpeciesID,
												@AnimalID,
												@idfVector,
												NULL,
												@idfsDetailedVectorSurveillanceSession,
												NULL,
												NULL,
												@CollectionDate,
												@CollectedByPersonID,
												@CollectedByOrganizationID,
												@SentDate,
												@SentToOrganizationID,
												@EIDSSLocalOrFieldSampleID,
												@SiteID,
												@DateEntered,
												@ReadOnlyIndicator,
												@SampleStatusTypeID,
												@Comments,
												@CurrentSiteID,
												@DiseaseID,
												@BirdStatusTypeID,
												@RowStatus,
												@RowAction;


				UPDATE @FieldTestsTemp
				SET SampleID = @SampleID
				WHERE SampleID = @RowID;

				DELETE FROM @SamplesTemp
				WHERE SampleID = @RowID;
			END;

				WHILE EXISTS (SELECT * FROM @FieldTestsTemp)
				BEGIN
					SELECT TOP 1
						@RowID = TestID,
						@TestID = TestID,
						@TestNameTypeID = TestNameTypeID,
						@TestCategoryTypeID = TestCategoryTypeID,
						@TestResultTypeID = TestResultTypeID,
						@TestStatusTypeID = TestStatusTypeID,
						@DiseaseID = DiseaseID,
						@SampleID = SampleID,
						@Comments = Comments,
						@RowStatus = RowStatus,
						@StartedDate = StartedDate,
						@ResultDate = ResultDate,
						@TestedByOrganizationID = TestedByOrganizationID,
						@TestedByPersonID = TestedByPersonID,
						@ResultEnteredByOrganizationID = ResultEnteredByOrganizationID,
						@ResultEnteredByPersonID = ResultEnteredByPersonID,
						@ValidatedByOrganizationID = ValidatedByOrganizationID,
						@ValidatedByPersonID = ValidatedByPersonID,
						@ReadOnlyIndicator = ReadOnlyIndicator,
						@NonLaboratoryTestIndicator = NonLaboratoryTestIndicator,
						@ExternalTestIndicator = ExternalTestIndicator,
						@PerformedByOrganizationID = PerformedByOrganizationID,
						@ReceivedDate = ReceivedDate,
						@ContactPersonName = ContactPersonName,
						@RowActionChar = CONVERT(char, RowAction)
					FROM @FieldTestsTemp;

					--If record is being soft-deleted, then check if the test record was originally created 
					--in the laboaratory module.  If it was, then disassociate the test record from the 
					--vector detailed collection, so that the test record remains in the laboratory module 
					--for further action.
					IF @RowStatus = 1
					   AND @NonLaboratoryTestIndicator = 0
					BEGIN
						SET @RowStatus = 0;
						SET @TestVectorID = NULL;
					END
					ELSE
					BEGIN
						SET @TestVectorID = @idfVector;
					END;

					--INSERT INTO @SuppressSelect
					EXECUTE dbo.USSP_GBL_TEST_SET NULL,
												  @TestID OUTPUT,
												  @TestNameTypeID,
												  @TestCategoryTypeID,
												  @TestResultTypeID,
												  @TestStatusTypeID,
												  @DiseaseID,
												  @SampleID,
												  NULL,
												  NULL,
												  NULL,
												  @Comments,
												  @RowStatus,
												  @StartedDate,
												  @ResultDate,
												  @TestedByOrganizationID,
												  @TestedByPersonID,
												  @ResultEnteredByOrganizationID,
												  @ResultEnteredByPersonID,
												  @ValidatedByOrganizationID,
												  @ValidatedByPersonID,
												  @ReadOnlyIndicator,
												  @NonLaboratoryTestIndicator,
												  @ExternalTestIndicator,
												  @PerformedByOrganizationID,
												  @ReceivedDate,
												  @ContactPersonName,
												  NULL,
												  @TestVectorID,
												  NULL,
												  NULL,
												  @AuditUser,
												  @RowActionChar;

					DELETE FROM @FieldTestsTemp
					WHERE TestID = @RowID;
				END;
		
		IF @@TRANCOUNT > 0 AND @returnCode =0
			COMMIT

	END TRY

	BEGIN CATCH
			IF @@Trancount > 0
				
				SET @returnCode = ERROR_NUMBER()
				SET @returnMsg = 
			   'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
			   + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
			   + ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
			   + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
			   + ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
			   + ' ErrorMessage: '+ ERROR_MESSAGE();
			   THROW;

	END CATCH

END
