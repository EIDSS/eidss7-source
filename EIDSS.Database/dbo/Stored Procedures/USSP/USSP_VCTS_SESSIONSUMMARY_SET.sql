
--**************************************************************
-- Name 				: USSP_VCTS_SESSIONSUMMARY_SET
-- Description			: Set the Vector Sessions Summary
--          
-- Author               : Mike Kornegay
-- Revision History
--		Name		Date		Change Detail
--  Mike Kornegay	05/01/2022	Original - copied from USP_VCTS_SESSION_SUMMARY_SET for use 
--								from inside the primary Vector Surveillance SET procedure.
--	Mike Kornegay	05/15/2022	Removed insert into statement.
--  Mike Kornegay	05/27/2022	Added RowStatus to accommodate soft delete of aggregate collections.
--	Mike Kornegay	07/20/2022	Correct formatting issues.
--  Mike Kornegay	08/01/2022	Correct issue with getting new idfsVSSessionSummary.
--
-- Testing code:
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_VCTS_SESSIONSUMMARY_SET]
(
     @idfsVSSessionSummary							BIGINT OUTPUT 
	 ,@idfVectorSurveillanceSession					BIGINT = NULL
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
	 ,@PoolsVectors									INT = NULL
	 ,@RowStatus									INT
	 ,@AuditUser									NVARCHAR(100)
)
AS
DECLARE @ReturnCode						INT = 0 
DECLARE	@ReturnMessage					NVARCHAR(MAX) = 'SUCCESS'


DECLARE @SupressSelect TABLE
	( 
		ReturnCode INT,
		ReturnMessage NVARCHAR(MAX)
	);


BEGIN
	BEGIN TRY
;			-- Create GeoLocation
			--INSERT INTO @SupressSelect
			EXECUTE dbo.USSP_GBL_ADDRESS_SET 	
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
				@AuditUserName = @AuditUser;
		

			IF NOT EXISTS (SELECT * FROM dbo.tlbVectorSurveillanceSessionSummary  WHERE idfsVSSessionSummary = @idfsVSSessionSummary)
				BEGIN
					IF (ISNULL(@idfsVSSessionSummary,-1)<0) OR (@idfsVSSessionSummary < 0)
						BEGIN
							EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
								@tableName = 'tlbVectorSurveillanceSessionSummary', 
								@idfsKey = @idfsVSSessionSummary OUTPUT
						END;
					IF LEFT(ISNULL(@strVSSessionSummaryID, '(new'),4) = '(new'
					BEGIN
						EXECUTE dbo.USP_GBL_NextNumber_GET 
							@ObjectName = 'Vector Surveillance Summary Vector', 
							@NextNumberValue = @strVSSessionSummaryID OUTPUT ,
							@InstallationSite = NULL --N'AS Session'
					END;

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
						@idfVectorSurveillanceSession,
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
				END;
			ELSE 
				BEGIN
					UPDATE	dbo.tlbVectorSurveillanceSessionSummary
					SET idfVectorSurveillanceSession = @idfVectorSurveillanceSession,
						strVSSessionSummaryID = @strVSSessionSummaryID,
						idfGeoLocation = @DiagnosisidfGeoLocation,
						datCollectionDateTime = @datSummaryCollectionDateTime,
						idfsVectorSubType = @SummaryInfoSpecies,
						idfsSex = @SummaryInfoSex,
						intQuantity = @PoolsVectors,
						intRowStatus = @RowStatus,
						AuditUpdateUser = @AuditUser,
					    AuditUpdateDTM = GETDATE()
					WHERE	idfsVSSessionSummary = @idfsVSSessionSummary
				END;
	END TRY
	BEGIN CATCH
        THROW;
    END CATCH;
END;
