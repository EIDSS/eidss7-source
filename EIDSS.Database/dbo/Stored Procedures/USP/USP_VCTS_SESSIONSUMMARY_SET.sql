
--**************************************************************
-- Name 				: USP_VCTS_SESSIONSUMMARY_SET
-- Description			: Set the Vector Sessions Summary
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name		Date       Change Detail
--  Harold Pryor	6/12/2018   Updated to replace parameters with @lucSummaryCollection prefix to @lucAggregateCollection
--  Mark Wilson		10/06/2021	Added Elevation (NULL) to USP_GBL_ADDRESS_SET
--  Mark Wilson		10/19/2021	changed to USSP_GBL_ADDRESS_SET
--  Mark Wilson		10/20/2021	fixed everything, pretty much
--	Doug Albanese	11/09/2021	Refactored to work with EF
--  Mike Kornegay	04/20/2022	Added lucAggregateCollectiondblElevation parameter
--  Mike Kornegay	04/21/2022  Added @AggregateDiagnosisInfo to optionally update diagnosis in one save
--	Mike Kornegay	04/29/2022	Removed ROLLBACK because the proc gets called from USP_VCTS_SURVEILLANCE_SESSION_SET
--								and moved AggregateDiagnosisInfo to main save proc.
--	Mike Kornegay	05/01/2022	Removed DiagnosisInfo parameter because this gets saved separately.
--
-- Testing code:
--*************************************************************
CREATE PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARY_SET]
(
     @idfsVSSessionSummary							BIGINT OUTPUT 
	 ,@idfDiagnosisVectorSurveillanceSession		BIGINT = NULL
     ,@strVSSessionSummaryID						NVARCHAR(200) = NULL 
	 ,@DiagnosisidfGeoLocation						BIGINT = NULL
  	 ,@lucAggregateCollectionidfsResidentType		BIGINT	= NULL
	 ,@lucAggregateCollectionidfsGroundType			BIGINT = NULL
	 ,@lucAggregateCollectionidfsGeolocationType	BIGINT = 10036001
	 ,@lucAggregateCollectionLocationID				BIGINT = NULL
	 ,@lucAggregateCollectionstrApartment			NVARCHAR(200) = NULL
	 ,@lucAggregateCollectionstrBuilding			NVARCHAR(200) = NULL
	 ,@lucAggregateCollectionstrStreetName			NVARCHAR(200) = NULL
	 ,@lucAggregateCollectionstrHouse				NVARCHAR(200) = NULL
	 ,@lucAggregateCollectionstrPostCode			NVARCHAR(200) = NULL
	 ,@lucAggregateCollectionstrDescription			NVARCHAR(200) = NULL
	 ,@lucAggregateCollectiondblDistance			FLOAT = NULL
     ,@lucAggregateCollectionstrLatitude			FLOAT = NULL
     ,@lucAggregateCollectionstrLongitude			FLOAT = NULL
	 ,@lucAggregateCollectiondblAccuracy			FLOAT = NULL
	 ,@lucAggregateCollectiondblAlignment			FLOAT = NULL
	 ,@lucAggregateCollectiondblElevation			FLOAT = NULL
	 ,@blnForeignAddress							BIT = 0
	 ,@strForeignAddress							NVARCHAR(200) = NULL
	 ,@blnGeoLocationShared							BIT = 0
	 ,@datSummaryCollectionDateTime					DATETIME = NULL
	 ,@SummaryInfoSpecies							BIGINT = NULL
	 ,@SummaryInfoSex								BIGINT = NULL
	 ,@PoolsVectors									BIGINT = NULL
	 ,@AuditUser									NVARCHAR(100)
)
AS
DECLARE @ReturnCode						INT = 0 
DECLARE	@ReturnMessage					NVARCHAR(MAX) = 'SUCCESS'


DECLARE @SupressSelect TABLE
	( 
		ReturnCode INT,
		ReturnMessage NVARCHAR(200)
	);


BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			-- Create GeoLocation
			INSERT INTO @SupressSelect
			EXEC dbo.USSP_GBL_ADDRESS_SET 	
				@GeolocationID = @DiagnosisidfGeoLocation OUTPUT,
				@ResidentTypeID = @lucAggregateCollectionidfsResidentType,
				@GroundTypeID = @lucAggregateCollectionidfsGroundType,
				@GeolocationTypeID = @lucAggregateCollectionidfsGeolocationType,
				@LocationID = @lucAggregateCollectionLocationID,
				@Apartment = @lucAggregateCollectionstrApartment,
				@Building = @lucAggregateCollectionstrBuilding,
				@StreetName = @lucAggregateCollectionstrStreetName,
				@House = @lucAggregateCollectionstrHouse,
				@PostalCodeString = @lucAggregateCollectionstrPostCode,
				@DescriptionString = @lucAggregateCollectionstrDescription,
				@Distance = @lucAggregateCollectiondblDistance,
				@Latitude = @lucAggregateCollectionstrLatitude,
				@Longitude = @lucAggregateCollectionstrLongitude,
				@Elevation = @lucAggregateCollectiondblElevation,
				@Accuracy = @lucAggregateCollectiondblAccuracy,
				@Alignment = @lucAggregateCollectiondblAlignment,
				@ForeignAddressIndicator = @blnForeignAddress,
				@ForeignAddressString = @strForeignAddress,
				@GeolocationSharedIndicator = @blnGeoLocationShared,
				@AuditUserName = @AuditUser,
				@ReturnCode = @ReturnCode OUTPUT,
				@ReturnMessage = @ReturnMessage OUTPUT

			IF NOT EXISTS (SELECT * FROM dbo.tlbVectorSurveillanceSessionSummary  WHERE idfsVSSessionSummary = @idfsVSSessionSummary)
				BEGIN
					IF ISNULL(@idfsVSSessionSummary,-1)<0
						BEGIN
							INSERT INTO @SupressSelect
							EXEC dbo.USP_GBL_NEXTKEYID_GET 
								@tableName = 'tlbVectorSurveillanceSessionSummary', 
								@idfsKey = @idfsVSSessionSummary OUTPUT
						END
					IF LEFT(ISNULL(@strVSSessionSummaryID, '(new'),4) = '(new'
					BEGIN
						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_NextNumber_GET 
							@ObjectName = 'Vector Surveillance Summary Vector', 
							@NextNumberValue = @strVSSessionSummaryID OUTPUT ,
							@InstallationSite = NULL --N'AS Session'
					END
					INSERT 
					INTO dbo.tlbVectorSurveillanceSessionSummary
					(
					    idfsVSSessionSummary,
					    idfVectorSurveillanceSession,
					    strVSSessionSummaryID,
					    idfGeoLocation,
					    datCollectionDateTime,
					    idfsVectorSubType,
					    idfsSex,
					    intQuantity,
					    intRowStatus,
					    rowguid,
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
						@idfsVSSessionSummary,
						@idfDiagnosisVectorSurveillanceSession,
						@strVSSessionSummaryID,
						@DiagnosisidfGeoLocation,
						@datSummaryCollectionDateTime,
						@SummaryInfoSpecies,
						@SummaryInfoSex,
						@PoolsVectors,
						0,
						NEWID(),
						NULL,
						NULL,
						10519001,
						'[{"idfsVSSessionSummary":' + CAST(@idfsVSSessionSummary AS NVARCHAR(300)) + '}]',
						@AuditUser,
						GETDATE(),
						@AuditUser,
						GETDATE()
					)
				END
			ELSE 
				BEGIN
					UPDATE	dbo.tlbVectorSurveillanceSessionSummary
					SET idfVectorSurveillanceSession = @idfDiagnosisVectorSurveillanceSession,
						strVSSessionSummaryID = @strVSSessionSummaryID,
						idfGeoLocation = @DiagnosisidfGeoLocation,
						datCollectionDateTime = @datSummaryCollectionDateTime,
						idfsVectorSubType = @SummaryInfoSpecies,
						idfsSex = @SummaryInfoSex,
						intQuantity = @PoolsVectors,
						AuditUpdateUser = @AuditUser,
					    AuditUpdateDTM = GETDATE()
					WHERE	idfsVSSessionSummary = @idfsVSSessionSummary
				END

		
		IF @@TRANCOUNT > 0 AND @ReturnCode =0
            COMMIT TRANSACTION;

         
	END TRY

	  BEGIN CATCH
        --IF @@Trancount > 0
        --    ROLLBACK TRANSACTION;

			SET @ReturnCode = ERROR_NUMBER()
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
		@ReturnCode AS ReturnCode
		,@ReturnMessage AS ReturnMesssage
		,@idfsVSSessionSummary AS idfsVSSessionSummary
		,@strVSSessionSummaryID AS strVSSessionSummaryID

END
