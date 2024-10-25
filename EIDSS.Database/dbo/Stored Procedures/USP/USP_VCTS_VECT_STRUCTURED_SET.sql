



--*************************************************************
-- Name 				: USP_VCTS_VECT_STRUCTURED_SET
-- Description			: SET Vector details with Sample and FieldTest User Defined Table Types
--          
-- Author               : Harold Pryor
-- Revision History
--		Name       Date       Change Detail
--  Harold Pryor  05/11/2018   Initial Creation
--  Harold Pryor  05/16/2018 Removed @AccessionDate 
--  Harold Pryor  05/29/2018 Updated to pass @idfTestedByOffice, @idfTestedByPerson and @idfsTestResult values to dbo.USSP_GBL_TESTING_SET 
--  Harold Pryor  6/13/2018  Updated save geolocation using dbo.USP_GBL_ADDRESS_SET and also save idfsGeoLocationType
--  Harold Pryor  6/20/2018  Updated to properly save FieldTest with default idfMaterial when @idfMaterial parameter is null
--  Harold Pryor  6/20/2018  Updated to properly save Sample from dbo.tlbVectorSampleGetListSPType @strFieldBarcode to dbo.USSP_GBL_MATERIAL_SET  
--  Mark Wilson   10/06/2021  Added Elevation (NULL) to USP_GBL_ADDRESS_SET
--  Steven Verner 10/20/2021 Added @AuditUser parameter
--
-- Testing code:
--EXECUTE [USP_VCTS_VECT_STRUCTURED_SET] 
--      @idfVector, 
--      @idfVectorSurveillanceSession, 
--      @idfHostVector, 
--      @strVectorID, 
--      @strFieldVectorID, 
--      @idfLocation , 
--      @intElevation , 
--      @idfsSurrounding , 
--      @strGEOReferenceSources , 
--      @idfCollectedByOffice , 
--      @idfCollectedByPerson , 
--      @datCollectionDateTime , 
--      @intCollectionEffort , 
--      @idfsCollectionMethod , 
--      @idfsBASisOfRecord , 
--      @idfsVectorType , 
--      @idfsVectorSubType , 
--      @intQuantity , 
--      @idfsSex , 
--      @idfIdentIFiedByOffice , 
--      @idfIdentIFiedByPerson , 
--      @datIdentIFiedDateTime , 
--      @idfsIdentIFicationMethod , 
--      @idfObservation, 
--*************************************************************
CREATE PROCEDURE [dbo].[USP_VCTS_VECT_STRUCTURED_SET]
(
    @LangID									NVARCHAR(50) = NULL, 
    @idfVector								BIGINT = NULL, 
    @idfsDetailedVectorSurveillanceSession	BIGINT = NULL, 
    @idfHostVector							BIGINT = NULL, 
    @strVectorID							NVARCHAR(50) = NULL, 
    @strFieldVectorID						NVARCHAR(50) = NULL, 
    @idfDetailedLocation					BIGINT = NULL, 
	@lucDetailedCollectionidfsResidentType	BIGINT	= NULL,
	@lucDetailedCollectionidfsGroundType	BIGINT = NULL,
	@lucDetailedCollectionidfsGeolocationType	BIGINT = 10036001,
	@lucDetailedCollectionidfsLocation		BIGINT = NULL,
	@lucDetailedCollectionstrApartment		NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrBuilding		NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrStreetName		NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrHouse			NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrPostCode		NVARCHAR(200) = NULL,
	@lucDetailedCollectionstrDescription	NVARCHAR(200) = NULL,
	@lucDetailedCollectiondblDistance		FLOAT = NULL,
    @lucDetailedCollectionstrLatitude		FLOAT = NULL,
    @lucDetailedCollectionstrLongitude		FLOAT = NULL,
	@lucDetailedCollectiondblAccuracy		FLOAT = NULL,
	@lucDetailedCollectiondblAlignment		FLOAT = NULL,
	@blnForeignAddress						BIT = 0,
	@strForeignAddress						NVARCHAR(200) = NULL,
	@blnGeoLocationShared					BIT = 0, 
    @intDetailedElevation					INT = NULL, 
	@DetailedSurroundings					BIGINT = NULL, 
    @strGEOReferenceSource					NVARCHAR(500), 
    @idfCollectedByOffice					BIGINT = NULL, 
    @idfCollectedByPerson					BIGINT = NULL, 
    @datCollectionDateTime					DATETIME = NULL, 
    --@intCollectionEffort int, 
    @idfsCollectionMethod					BIGINT = NULL, 
    @idfsBasisOfRecord						BIGINT = NULL, 
    @idfDetailedVectorType					BIGINT = NULL, 
    @idfsVectorSubType						BIGINT = NULL, 
    @intQuantity							INT = NULL, 
    @idfsSex								BIGINT = NULL, 
    @idfIdentIFiedByOffice					BIGINT = NULL, 
    @idfIdentIFiedByPerson					BIGINT = NULL, 
    @datIdentIFiedDateTime					DATETIME = NULL, 
    @idfsIdentIFicationMethod				BIGINT = NULL, 
    @idfObservation							BIGINT = NULL,
	@idfsFormTemplate						BIGINT = NULL,
	@idfsDayPeriod							BIGINT = NULL,
	@strComment								NVARCHAR(500) = NULL,
	@idfsEctoparASitesCollected				BIGINT = NULL,        
	@Samples								NVARCHAR(MAX) = NULL,
	@FieldTests								NVARCHAR(MAX) = NULL,
    @AuditUser                              NVARCHAR(100) = NULL
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
DECLARE @ResultDate						Date = NULL
IF (@Samples = 'null')
	BEGIN
		SET @Samples = null
	END

IF (@FieldTests = 'null')
	BEGIN
		SET @FieldTests = null
	END

SET @Samples = REPLACE ( @Samples , '"0001-01-01T00:00:00"' , 'null')
SET @FieldTests = REPLACE ( @FieldTests , '"0001-01-01T00:00:00"' , 'null')

	DECLARE @SamplesTemp TABLE (
		idfMaterial BIGINT NOT NULL,
		idfsSampleType BIGINT NULL,
		strFieldBarcode NVARCHAR(200) NULL,
		idfAnimal BIGINT NULL,
		strAnimalCode NVARCHAR(200) NULL,
		idfSpecies BIGINT NULL,
		Species NVARCHAR(200) NULL,
		idfsBirdStatus BIGINT NULL,
		BirdStatus NVARCHAR(200) NULL,
		datFieldCollectionDate DATETIME2 NULL,
		idfFieldCollectedByOffice BIGINT NULL,
		FieldCollectedByOffice NVARCHAR(200) NULL,
		idfFieldCollectedByPerson BIGINT NULL,
		FieldColectedByPerson NVARCHAR(200) NULL,
		idfSendToOffice BIGINT NULL,
		SendToOffice NVARCHAR(200) NULL,
		strNote NVARCHAR(200) NULL,
		idfVectorSurveillanceSession BIGINT NULL,
		intRowStatus INT NULL,
		RowAction NVARCHAR(1) NULL
	);

	DECLARE @SamplesHold TABLE (
		idfMaterial BIGINT NOT NULL,
		idfsSampleType BIGINT NULL,
		strFieldBarcode NVARCHAR(200) NULL,
		idfAnimal BIGINT NULL,
		strAnimalCode NVARCHAR(200) NULL,
		idfSpecies BIGINT NULL,
		Species NVARCHAR(200) NULL,
		idfsBirdStatus BIGINT NULL,
		BirdStatus NVARCHAR(200) NULL,
		datFieldCollectionDate DATETIME2 NULL,
		idfFieldCollectedByOffice BIGINT NULL,
		FieldCollectedByOffice NVARCHAR(200) NULL,
		idfFieldCollectedByPerson BIGINT NULL,
		FieldColectedByPerson NVARCHAR(200) NULL,
		idfSendToOffice BIGINT NULL,
		SendToOffice NVARCHAR(200) NULL,
		strNote NVARCHAR(200) NULL,
		idfVectorSurveillanceSession BIGINT NULL,
		intRowStatus INT NULL,
		RowAction NVARCHAR(1) NULL
	);

	DECLARE @FieldTestTemp TABLE (
		idfTesting BIGINT NOT NULL,
		strFieldBarcode NVARCHAR(200) NULL,
		idfMaterial BIGINT NULL,
		idfsSampleType BIGINT NULL,
		SampleType NVARCHAR(200) NULL,
		idfSpecies BIGINT NULL,
		Species NVARCHAR(200) NULL,
		strAnimalCode NVARCHAR(200) NULL,
		idfsTestName BIGINT NULL,
		TestName NVARCHAR(200) NULL,
		idfsTestResult BIGINT NULL,
		Result NVARCHAR(200) NULL,
		idfsTestCategory BIGINT NULL,
		idfTestedByPerson BIGINT NULL,
		idfsDiagnosis BIGINT NULL,
		intRowStatus INT NOT NULL,
		ResultDate date null,
		RecordAction NVARCHAR(1) NULL,
		idfVector BIGINT NULL,
		datConcludedDate date null,
		idfTestedByOffice BIGINT NULL
	);

	INSERT INTO @SamplesTemp
		SELECT *
		FROM OPENJSON(@Samples) WITH (
			idfMaterial BIGINT,
			idfsSampleType BIGINT,
			strFieldBarcode NVARCHAR(200),
			idfAnimal BIGINT,
			strAnimalCode NVARCHAR(200),
			idfSpecies BIGINT,
			Species NVARCHAR(200),
			idfsBirdStatus BIGINT,
			BirdStatus NVARCHAR(200),
			datFieldCollectionDate DATETIME2,
			idfFieldCollectedByOffice BIGINT,
			FieldCollectedByOffice NVARCHAR(200),
			idfFieldCollectedByPerson BIGINT,
			FieldColectedByPerson NVARCHAR(200),
			idfSendToOffice BIGINT,
			SendToOffice NVARCHAR(200),
			strNote NVARCHAR(200),
			idfVectorSurveillanceSession BIGINT,
			intRowStatus INT,
			RowAction NVARCHAR(1)
		);

	INSERT INTO @SamplesHold
		SELECT *
		FROM OPENJSON(@Samples) WITH (
			idfMaterial BIGINT,
			idfsSampleType BIGINT,
			strFieldBarcode NVARCHAR(200),
			idfAnimal BIGINT,
			strAnimalCode NVARCHAR(200),
			idfSpecies BIGINT,
			Species NVARCHAR(200),
			idfsBirdStatus BIGINT,
			BirdStatus NVARCHAR(200),
			datFieldCollectionDate DATETIME2,
			idfFieldCollectedByOffice BIGINT,
			FieldCollectedByOffice NVARCHAR(200),
			idfFieldCollectedByPerson BIGINT,
			FieldColectedByPerson NVARCHAR(200),
			idfSendToOffice BIGINT,
			SendToOffice NVARCHAR(200),
			strNote NVARCHAR(200),
			idfVectorSurveillanceSession BIGINT,
			intRowStatus INT,
			RowAction NVARCHAR(1)
		);

	INSERT INTO @FieldTestTemp
		SELECT *
		FROM OPENJSON(@FieldTests) WITH (
			idfTesting BIGINT,
			strFieldBarcode NVARCHAR(200),
			idfMaterial BIGINT,
			idfsSampleType BIGINT,
			SampleType NVARCHAR(200),
			idfSpecies BIGINT,
			Species NVARCHAR(200),
			strAnimalCode NVARCHAR(200),
			idfsTestName BIGINT,
			TestName NVARCHAR(200),
			idfsTestResult BIGINT,
			Result NVARCHAR(200),
			idfsTestCategory BIGINT,
			idfTestedByPerson BIGINT,
			idfsDiagnosis BIGINT,
			intRowStatus INT,
			ResultDate DateTime,
			RecordAction NVARCHAR(1),
			idfVector BIGINT,
			datConcludedDate date,
			idfTestedByOffice BIGINT
		);
		Declare @SupressSelect table
		( retrunCode int,
			returnMsg varchar(200)
		)

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		-- Create GeoLocation
			INSERT INTO @SupressSelect
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

		IF @idfObservation <> 0
		BEGIN
		INSERT INTO @SupressSelect
		EXEC dbo.USP_FLEXFORMS_OBSERVATIONS_SET @idfObservation, @idfsFormTemplate
		END
		IF NOT EXISTS( SELECT * FROM dbo.tlbVector WHERE idfVector = @idfVector)	
			BEGIN

					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbVector', @idfVector OUTPUT

					INSERT INTO @SupressSelect
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
			END

			WHILE EXISTS (SELECT * FROM @SamplesTemp where RowAction <> '')
				BEGIN
					SELECT TOP 1					@idfMaterial = idfMaterial,
													@strFieldBarcode = strFieldBarcode,
													@idfsSampleType = idfsSampleType,
												    @idfVectorSurveillanceSession = idfVectorSurveillanceSession,
													@idfSendToOffice = idfSendToOffice,				
													@idfFieldCollectedByOffice = idfSendToOffice,
													@RecordAction = RowAction 

					FROM @SamplesTemp where RowAction <> '';	

						IF @RecordAction = 'I'	
						BEGIN
						   set @idfMaterial = null
						END
						INSERT INTO @SupressSelect
						 EXEC				dbo.USSP_GBL_MATERIAL_SET 
											@LangID, 
											@idfMaterial , 
											@idfsSampleType,
											null, 
											null,  
											NULL, 
											null,  
											null, 
											null, 
											null, 
											@idfFieldCollectedByOffice,
											null,  
											@datFieldCollectionDate, 
											@datFieldSentDate, 
											@strFieldBarcode, 
											NULL, 
											NULL, 
											@idfVectorSurveillanceSession, 
											@idfVector, 
											NULL, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											@idfsSite, 
											@intRowStatus, 
											@idfSendToOffice, 
											0, 
											null, 
											NULL, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											null, 
											@RecordAction,
                                            @AuditUser;						
					
					DELETE TOP (1) FROM @SamplesTemp
				END;
				
				set @strFieldBarcode = null
				WHILE EXISTS (SELECT * FROM @FieldTestTemp WHERE RecordAction <> '')
				BEGIN
					SELECT TOP 1				@idfTesting = idfTesting,
					                            @strFieldBarCode = strFieldBarCode,
												@idfsTestName = idfsTestName,
												@idfsTestCategory = idfsTestCategory, 
												@idfTestedByOffice = idfTestedByOffice,	
												@idfsTestResult = idfsTestResult,	
												@idfTestedByPerson = idfTestedByPerson,
												@idfsDiagnosis = idfsDiagnosis,
												@RecordAction = RecordAction, 
												@ResultDate = ResultDate,
												@datConcludedDate = datConcludedDate,
												@idfVector = idfVector,
												@idfMaterial = idfMaterial
					FROM @FieldTestTemp where RecordAction <> ''

					If @strFieldBarCode is  null
						   BEGIN
						     SELECT TOP 1 @idfMaterial = idfMaterial
								FROM [dbo].[tlbMaterial] where strFieldBarCode = @strFieldBarCode
						   END

					IF @RecordAction = 'I'	
						BEGIN
						   set @idfTesting = null						   				   

						   IF @idfmaterial IS NULL
							BEGIN
								SELECT TOP 1 @idfMaterial = idfMaterial
								FROM @SamplesHold WHERE idfMaterial IS NOT NULL 
							END
						END

						set @idfObservation = 0

						INSERT INTO @SupressSelect
						EXEC dbo.USSP_GBL_TESTING_SET_2 

							@LangID, 
							@idfTesting , 
							@idfsTestName,
							@idfsTestCategory, 
							@idfsTestResult, 
							@idfsTestStatus, 
							@idfsDiagnosis, 
							@idfmaterial, 
							NULL, 
							0, 
							NULL,
							NULL,
							@intRowStatus, 
							@datStartDate,  
							@datConcludedDate,  
							@idfTestedByOffice, 
							@idfTestedByPerson,  
							NULL, 
							NULL, 
							NULL,   
							NULL, 
							@blnReadOnly, 
							@blnNonLaboratory, 
							NULL,
							NULL,
							@ResultDate, 											
							NULL, 											
							NULL, 
							@RecordAction, 
							@idfVector,
							@AuditUser;         

                DELETE TOP (1) FROM @FieldTestTemp
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

	SELECT 
		@returnCode AS ReturnCode
		,@returnMsg AS ReturnMsg
		,@idfVector AS idfVector
		,@strVectorID AS strVectorID
		,@idfDetailedLocation AS idfDetailedLocation

END
