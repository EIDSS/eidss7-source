


--*************************************************************
-- Name 				: USP_VCTS_VECT_SET
-- Description			: SET Vector details
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--  Harold Pryor   6/13/2018   Updated save geolocation using dbo.USP_GBL_ADDRESS_SET and also save idfsGeoLocationType
--  Mark Wilson    10/06/2021  Added Elevation (NULL) to USP_GBL_ADDRESS_SET
--  Steven Verner  10/20/2021  Change to use USSP_GBL_Address_Set
-- Lamont Mitchell 12/13/21 Renamed ReturnMessage fom retrunMsg
-- Testing code:
--EXECUTE [USP_VCTS_VECT_SET] 
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
--      @idfObservation 
--*************************************************************
CREATE PROCEDURE [dbo].[USP_VCTS_VECT_SET]
(
    @idfVector								BIGINT = NULL, 
    @idfsDetailedVectorSurveillanceSession	BIGINT = NULL, 
    @idfHostVector							BIGINT = NULL, 
    @strVectorID							NVARCHAR(50) = NULL, 
    @strFieldVectorID						NVARCHAR(50) = NULL, 
    @idfDetailedLocation					BIGINT =  NULL,
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
    @strGEOReferenceSource					NVARCHAR(500) = NULL, 
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
    @AuditUser                              NVARCHAR(100) = NULL
)
AS 
DECLARE @returnCode					INT = 0 
DECLARE	@ReturnMessage					NVARCHAR(max) = 'SUCCESS' 

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		-- Create GeoLocation
			EXEC dbo.USSP_GBL_ADDRESS_SET 	
				@GeolocationID = @idfDetailedLocation OUTPUT,
				@ResidentTypeID = @lucDetailedCollectionidfsResidentType,
				@GroundTypeID = @lucDetailedCollectionidfsGroundType,
				@GeolocationTypeID = @lucDetailedCollectionidfsGeolocationType,
				@LocationID = @lucDetailedCollectionidfsLocation,
				@Apartment = @lucDetailedCollectionstrApartment,
				@Building = @lucDetailedCollectionstrBuilding,
				@StreetName = @lucDetailedCollectionstrStreetName,
				@House = @lucDetailedCollectionstrHouse,
				@PostalCodeString = @lucDetailedCollectionstrPostCode,
				@DescriptionString = @lucDetailedCollectionstrDescription,
				@Distance = @lucDetailedCollectiondblDistance,
				@Latitude = @lucDetailedCollectionstrLatitude,
				@Longitude = @lucDetailedCollectionstrLongitude,
				@Elevation = NULL,
				@Accuracy = @lucDetailedCollectiondblAccuracy,
				@Alignment = @lucDetailedCollectiondblAlignment,
				@ForeignAddressIndicator = @blnForeignAddress,
				@ForeignAddressString = @strForeignAddress,
				@GeolocationSharedIndicator = @blnGeoLocationShared,
                @AuditUserName = @AuditUser,
				@ReturnCode = @returnCode,
				@ReturnMessage = @ReturnMessage


		IF NOT EXISTS( SELECT idfObservation from dbo.tlbObservation where idfObservation = 0 )
		BEGIN		 
			Insert into [dbo].[tlbObservation]
			(idfObservation, idfsFormTemplate, intRowStatus, rowguid, strMaintenanceFlag, strReservedAttribute, idfsSite) 
			values (0, null, 0, NEWID(), null, null, 1)
		END

		EXEC dbo.USP_FLEXFORMS_OBSERVATIONS_SET @idfObservation, @idfsFormTemplate

		IF NOT EXISTS( SELECT * FROM dbo.tlbVector WHERE idfVector = @idfVector)	
			BEGIN
				BEGIN
					EXEC dbo.USP_GBL_NEXTKEYID_GET 
						@tableName = 'tlbVector', 
						@idfsKey = @idfVector OUTPUT
				END

				BEGIN
					EXEC dbo.USP_GBL_NextNumber_GET 
						@ObjectName = 'Vector Surveillance Session', 
						@NextNumberValue = @strVectorID OUTPUT , 
						@InstallationSite = NULL 
				END

				INSERT INTO dbo.tlbVector
				(
				    idfVector,
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
				    idfsCollectionMethod,
				    idfsBasisOfRecord,
				    idfsVectorType,
				    idfsVectorSubType,
				    intQuantity,
				    idfsSex,
				    idfIdentifiedByOffice,
				    idfIdentifiedByPerson,
				    datIdentifiedDateTime,
				    idfsIdentificationMethod,
				    idfObservation,
				    intRowStatus,
				    rowguid,
				    idfsDayPeriod,
				    strComment,
				    idfsEctoparasitesCollected,
				    strMaintenanceFlag,
				    strReservedAttribute,
				    SourceSystemNameID,
				    SourceSystemKeyValue,
				    AuditCreateUser,
				    AuditCreateDTM,
				    AuditUpdateUser,
				    AuditUpdateDTM
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
					0,
					NEWID(),
					@idfsDayPeriod,
					@strComment,
					@idfsEctoparASitesCollected,
					NULL,
					NULL,
					10519001,
					'[{"idfVector":' + CAST(@idfVector AS NVARCHAR(300)) + '}]',
					@AuditUser,
					GETDATE(),
					@AuditUser,
					GETDATE()
                            
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
		IF @@TRANCOUNT > 0 AND @returnCode =0
			COMMIT
		
	END TRY

	BEGIN CATCH
			IF @@Trancount > 0
				ROLLBACK
				SET @returnCode = ERROR_NUMBER()
				SET @ReturnMessage = 
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
		,@ReturnMessage AS ReturnMessage
		,@idfVector AS idfVector
		,@strVectorID AS strVectorID
		,@idfDetailedLocation AS idfDetailedLocation
END
