----------------------------------------------------------------------------
-- Name 				: [USP_VCTS_SURVEILLANCE_SESSION_SET]
-- Description			: INSERT/UPDATE Vector Surveillance Session including
--							Session, Detailed Collections, and Aggregate Collections
--          
-- Author               : Maheshwar Deo
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    10-Nov-2017   Convert EIDSS 6 to EIDSS 7 standards AND 
--                              changes calls to:
--                              
--                              USP_GBL_NEWID_GET call
--                              USP_GBL_NextNumber_GET
--                              
--                              Edited to pass 'Vector Surveillance Session' to
--                              USP_GBL_NextNumber_GET instead of hard-coded 
--                              idfs Value.
--
-- Harold Pryor		04-Apr-2018    Updated number of parameters being passed to dbo.USP_GBL_NEXTKEYID_GET from three to just two.   
-- Harold Pryor		05-Apr-2018    Updated to call dbo.USSP_GBL_ADDRESS_SET replacing dbo.USP_GBL_ADDRESS_SET.
-- Harold Pryor		08-May-2018    Updated to include @idfsGroundType,  @dblDistance, and @dblDirection input parameters
-- Harold Pryor		09-May-2018    Updated to @vectorInsstrApartment, @vectorInsstrBuildin, @vectorInsstrStreetName, 
--									vectorInsstrHouse   vectorInsstrHouse, @vectorInsidfsPostalCode input parameters.
-- Harold Pryor		31-May-2018    Updated to return @idfVectorSurveillanceSession, @strSessionID in output
-- Harold Pryor		04-June-2018   Updated to properly save Vector Surveillance Session record for foreign location where @vectorInsidfsCountry is only location parameter
-- Harold Pryor		05-June-2018   Updated to add @idfsResidentType input parameter to pass to dbo.USSP_GBL_ADDRESS_SET for processing of exact, relative, and foreign location types
-- Harold Pryor		07-June-2018   Updated to replace @idfsResidentType with @idfsGeolocationType as input parameter to pass to dbo.USSP_GBL_ADDRESS_SET for processing of exact, relative, foreign and national location types
--
-- Doug Albanese	03-10-2020		Changes Defect 6212
-- Doug Albanese	11-20-2020		Corrected the use of USSP_GBL_ADDRESS_SET to have dblDirection put in the right slot (coresponding to dblAlighment)
-- Stephen Long		12/04/2020		Added site ID parameter.
-- Steven Verner	10/18/2021		
-- Mark Wilson		10/19/2021		Added @AuditUser and call to USSP_GBL_ADDRESS_SET, @Elevation, removed @datModificationForArchiveDate general cleanup
---Lamont Mitchell	11/09/2021		Added output for new session id and idfVectorSurveillanceSession
-- Mark Wilson		01/14/2022		removed BEGIN TRANSACTION and COMMIT statements because of FK violations
-- Mike Kornegay	04/21/2022		Added saving of aggregate collections
-- Mike Kornegay	04/29/2022		Corrected problem with parameters when updating aggregate collections
--									and moved AggregateDiagnosis Info from summary to this stored proc.
-- Mike Kornegay	05/01/2022		Changed to call USSP_VCTS_SESSIONSUMMARY_SET instead of USP_VCTS_SESSIONSUMMARY_SET
-- Mike Kornegay	05/03/2022		Added detailed collections saving to this stored proc. (@DetailedCollections)
-- Mike Kornegay	05/05/2022		Added detailed collections samples and field test saving to this stored proc.
-- Mike Kornegay	05/10/2022		Fixes for samples and field tests inside detailed collections.
-- Mike Kornegay	05/11/2022		Various fixes for collection saves - aggregate, aggregate diagnosis, and detailed.
-- Mike Kornegay	05/18/2022		Corrected switched keys on detail collections causing duplicates.
-- Mike Kornegay	05/27/2022		Pass RowStatus to USSP_VCTS_SESSIONSUMMARY_SET to accommodate soft deletes.
-- Stephen Long     07/12/2022      Added events parameter and site alert logic.
-- Mike Kornegay	07/18/2022		Added events parameter to detailed collections for field test site alerts.
-- Mike Kornegay	07/21/2022		Remove events parameter from detailed collections - not needed.
--
-- Testing code:
/*
--Example of procedure call:

*/
CREATE PROCEDURE [dbo].[USP_VCTS_SURVEILLANCE_SESSION_SET]
(
    @LangID NVARCHAR(50) = NULL,
    @idfVectorSurveillanceSession BIGINT = NULL,
    @strSessionID NVARCHAR(50) = NULL,
    @strFieldSessionID NVARCHAR(50) = NULL,
    @idfsVectorSurveillanceStatus BIGINT = NULL,
    @datStartDate DATETIME = NULL,
    @datCloseDate DATETIME = NULL,
    @idfOutbreak BIGINT = NULL,
    @intCollectionEffort INT = NULL,
    @idfGeoLocation BIGINT = NULL,
    @idfsGeolocationType BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @dblLatitude FLOAT = NULL,
    @dblLongitude FLOAT = NULL,
    @strDescription NVARCHAR(400) = NULL,
    @idfsGroundType BIGINT = NULL,
    @dblDistance FLOAT = NULL,
    @dblDirection FLOAT = NULL,
    @Elevation FLOAT = NULL,
    @strStreetName NVARCHAR(400) = NULL,
    @strPostalCode NVARCHAR(400) = NULL,
    @strApartment NVARCHAR(400) = NULL,
    @strBuilding NVARCHAR(400) = NULL,
    @strHouse NVARCHAR(400) = NULL,
    @blnForeignAddress BIT = 0,
    @strForeignAddress NVARCHAR(400) = NULL,
    @blnGeoLocationShared BIT = 0,
    @strLocationDescription NVARCHAR(400) = NULL,
    @SiteID BIGINT,
    @AggregateCollections NVARCHAR(MAX) = NULL,
    @DiagnosisInfo NVARCHAR(MAX) = NULL,
    @DetailedCollections NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @AuditUser NVARCHAR(100)
)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @ReturnCode INT = 0;
        DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @EventId BIGINT,
                @EventTypeId BIGINT = NULL,
                @EventSiteId BIGINT = NULL,
                @EventObjectId BIGINT = NULL,
                @EventUserId BIGINT = NULL,
                @EventDiseaseId BIGINT = NULL,
                @EventLocationId BIGINT = NULL,
                @EventInformationString NVARCHAR(MAX) = NULL,
                @EventLoginSiteId BIGINT = NULL;
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );


        DECLARE @idfsVSSessionSummary bigint,
                @strVSSessionSummaryID nvarchar(200),
                @DiagnosisidfGeoLocation bigint,
                @lucAggregateCollectionidfsResidentType bigint,
                @lucAggregateCollectionidfsGroundType bigint,
                @lucAggregateCollectionidfsGeolocationType bigint,
                @lucAggregateCollectionLocationID bigint,
                @lucAggregateCollectionstrApartment nvarchar(200),
                @lucAggregateCollectionstrBuilding nvarchar(200),
                @lucAggregateCollectionstrStreetName nvarchar(200),
                @lucAggregateCollectionstrHouse nvarchar(200),
                @lucAggregateCollectionstrPostCode nvarchar(200),
                @lucAggregateCollectionstrDescription nvarchar(200),
                @lucAggregateCollectiondblDistance float,
                @lucAggregateCollectionstrLatitude float,
                @lucAggregateCollectionstrLongitude float,
                @lucAggregateCollectiondblAccuracy float,
                @lucAggregateCollectiondblAlignment float,
                @lucAggregateCollectiondblElevation float,
                @datSummaryCollectionDateTime datetime,
                @SummaryInfoSpecies bigint,
                @SummaryInfoSex bigint,
                @PoolsVectors int,
                @idfsVSSessionSummaryDiagnosis bigint,
                @idfsDiagnosis bigint,
                @intPositiveQuantity int,
                @idfVector bigint,
                @idfsDetailedVectorSurveillanceSession bigint,
                @idfHostVector bigint,
                @strVectorID nvarchar(50),
                @strFieldVectorID nvarchar(50),
                @idfDetailedLocation bigint,
                @lucDetailedCollectionidfsResidentType bigint,
                @lucDetailedCollectionidfsGroundType bigint,
                @lucDetailedCollectionidfsGeolocationType bigint,
                @lucDetailedCollectionidfsLocation bigint,
                @lucDetailedCollectionstrApartment nvarchar(200),
                @lucDetailedCollectionstrBuilding nvarchar(200),
                @lucDetailedCollectionstrStreetName nvarchar(200),
                @lucDetailedCollectionstrHouse nvarchar(200),
                @lucDetailedCollectionstrPostCode nvarchar(200),
                @lucDetailedCollectionstrDescription nvarchar(200),
                @lucDetailedCollectiondblDistance float,
                @lucDetailedCollectionstrLatitude float,
                @lucDetailedCollectionstrLongitude float,
                @lucDetailedCollectiondblAccuracy float,
                @lucDetailedCollectiondblAlignment float,
                @intDetailedElevation int,
                @DetailedSurroundings bigint,
                @strGEOReferenceSource nvarchar(500),
                @idfCollectedByOffice bigint,
                @idfCollectedByPerson bigint,
                @datCollectionDateTime datetime,
                @idfsCollectionMethod bigint,
                @idfsBasisOfRecord bigint,
                @idfDetailedVectorType bigint,
                @idfsVectorSubType bigint,
                @intQuantity int,
                @idfsSex bigint,
                @idfIdentIFiedByOffice bigint,
                @idfIdentIFiedByPerson bigint,
                @datIdentIFiedDateTime datetime,
                @idfsIdentIFicationMethod bigint,
                @idfObservation bigint,
                @idfsFormTemplate bigint,
                @idfsDayPeriod bigint,
                @strComment nvarchar(500),
                @idfsEctoparASitesCollected bigint,
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
                @FarmID BIGINT = NULL,
                @FarmMasterID BIGINT = NULL,
                @DiseaseID BIGINT = NULL,
                @DateEntered DATETIME = NULL,
                @Comments NVARCHAR(2000) = NULL,
                @SpeciesID BIGINT = NULL,
                @AnimalID BIGINT = NULL,
                @Samples NVARCHAR(MAX) = NULL,
                @FieldTests NVARCHAR(MAX) = NULL,
                @RowID bigint,
                @RowAction int,
                @RowStatus int



        --aggregate collections temp table
        DECLARE @AggregateCollectionsTemp TABLE
        (
            VectorSessionSummaryKey BIGINT NOT NULL,
            VectorSessionKey BIGINT NOT NULL,
            SummarySessionID NVARCHAR(200) NULL,
            GeoLocationID BIGINT NULL,
            ResidentTypeID BIGINT NULL,
            GroundTypeID BIGINT NULL,
            GeoLocationTypeID BIGINT NULL,
            LocationID BIGINT NULL,
            Apartment NVARCHAR(200) NULL,
            Building NVARCHAR(200) NULL,
            StreetName NVARCHAR(200) NULL,
            House NVARCHAR(200) NULL,
            PostCode NVARCHAR(200) NULL,
            [Description] NVARCHAR(200) NULL,
            Distance FLOAT NULL,
            Longitude FLOAT NULL,
            Latitude FLOAT NULL,
            Accuracy FLOAT NULL,
            Alignment FLOAT NULL,
            Elevation FLOAT NULL,
            IsForeignAddress BIT NULL,
            ForeignAddress NVARCHAR(200) NULL,
            IsGeoLocationShared BIT NULL,
            CollectionDateTime DATETIME2 NULL,
            SummaryInfoSpecies BIGINT NULL,
            SummaryInfoSex BIGINT NULL,
            PoolsVectors INT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );

        SET @AggregateCollections = REPLACE(@AggregateCollections, '"0001-01-01T00:00:00"', 'null');

        --aggregate collections json
        INSERT INTO @AggregateCollectionsTemp
        SELECT *
        FROM
            OPENJSON(@AggregateCollections)
            WITH
            (
                VectorSessionSummaryKey BIGINT,
                VectorSessionKey BIGINT,
                SummarySessionID NVARCHAR(200),
                GeoLocationID BIGINT,
                ResidentTypeID BIGINT,
                GroundTypeID BIGINT,
                GeoLocationTypeID BIGINT,
                LocationID BIGINT,
                Apartment NVARCHAR(200),
                Building NVARCHAR(200),
                StreetName NVARCHAR(200),
                House NVARCHAR(200),
                PostCode NVARCHAR(200),
                [Description] NVARCHAR(200),
                Distance FLOAT,
                Longitude FLOAT,
                Latitude FLOAT,
                Accuracy FLOAT,
                Alignment FLOAT,
                Elevation FLOAT,
                IsForeignAddress BIT,
                ForeignAddress NVARCHAR(200),
                IsGeoLocationShared BIT,
                CollectionDateTime DATETIME2,
                SummaryInfoSpecies BIGINT,
                SummaryInfoSex BIGINT,
                PoolsVectors INT,
                RowStatus INT,
                RowAction INT
            );

        --aggregate collections diagnosis (diseases)
        DECLARE @DiagnosisInfoTemp TABLE
        (
            idfsVSSessionSummaryDiagnosis BIGINT NULL,
            idfsVSSessionSummary BIGINT NOT NULL,
            idfsDiagnosis BIGINT NULL,
            intPositiveQuantity INT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );


        INSERT INTO @DiagnosisInfoTemp
        SELECT *
        FROM
            OPENJSON(@DiagnosisInfo)
            WITH
            (
                idfsVSSessionSummaryDiagnosis BIGINT,
                idfsVSSessionSummary BIGINT,
                idfsDiagnosis BIGINT,
                intPositiveQuantity INT,
                RowStatus INT,
                RowAction INT
            );

        DECLARE @DetailedCollectionsTemp TABLE
        (
            VectorSessionKey BIGINT NOT NULL,
            VectorSessionDetailedKey BIGINT NULL,
            HostVectorID BIGINT NULL,
            DetailSessionID NVARCHAR(50) NULL,
            FieldVectorID NVARCHAR(50) NULL,
            GeoLocationID BIGINT,
            ResidentTypeID BIGINT,
            GroundTypeID BIGINT,
            GeoLocationTypeID BIGINT,
            LocationID BIGINT,
            Apartment NVARCHAR(200),
            Building NVARCHAR(200),
            StreetName NVARCHAR(200),
            House NVARCHAR(200),
            PostCode NVARCHAR(200),
            [Description] NVARCHAR(200),
            Distance FLOAT,
            Longitude FLOAT,
            Latitude FLOAT,
            Accuracy FLOAT,
            Alignment FLOAT,
            Elevation FLOAT,
            IsForeignAddress BIT,
            ForeignAddress NVARCHAR(200),
            IsGeoLocationShared BIT,
            DetailedElevation INT NULL,
            DetailedSurroundings BIGINT NULL,
            GeoReferenceSource NVARCHAR(500),
            CollectedByOfficeID BIGINT NULL,
            CollectionByPersonID BIGINT NULL,
            CollectionDateTime DATETIME2 NULL,
            CollectionMethodID BIGINT NULL,
            BasisOfRecordID BIGINT NULL,
            DetailedVectorTypeID BIGINT NULL,
            VectorSubTypeID BIGINT NULL,
            Quantity INT NULL,
            SexID BIGINT NULL,
            IdentifiedByFieldOfficeID BIGINT NULL,
            IdentifiedByPersonID BIGINT NULL,
            IdentifiedDateTime DATETIME2 NULL,
            IdentificationMethodID BIGINT NULL,
            ObservationID BIGINT NULL,
            FormTemplateID BIGINT NULL,
            DayPeriodID BIGINT NULL,
            Comment NVARCHAR(500) NULL,
            EctoparASSitesCollectionID BIGINT NULL,
            Samples NVARCHAR(MAX) NULL,
            FieldTests NVARCHAR(MAX) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );

        INSERT INTO @DetailedCollectionsTemp
        SELECT *
        FROM
            OPENJSON(@DetailedCollections)
            WITH
            (
                VectorSessionKey BIGINT,
                VectorSessionDetailedKey BIGINT,
                HostVectorID BIGINT,
                DetailSessionID NVARCHAR(50),
                FieldVectorID NVARCHAR(50),
                GeoLocationID BIGINT,
                ResidentTypeID BIGINT,
                GroundTypeID BIGINT,
                GeoLocationTypeID BIGINT,
                LocationID BIGINT,
                Apartment NVARCHAR(200),
                Building NVARCHAR(200),
                StreetName NVARCHAR(200),
                House NVARCHAR(200),
                PostCode NVARCHAR(200),
                [Description] NVARCHAR(200),
                Distance FLOAT,
                Longitude FLOAT,
                Latitude FLOAT,
                Accuracy FLOAT,
                Alignment FLOAT,
                Elevation FLOAT,
                IsForeignAddress BIT,
                ForeignAddress NVARCHAR(200),
                IsGeoLocationShared BIT,
                DetailedElevation INT,
                DetailedSurroundings BIGINT,
                GeoReferenceSource NVARCHAR(500),
                CollectedByOfficeID BIGINT,
                CollectionByPersonID BIGINT,
                CollectionDateTime DATETIME2,
                CollectionMethodID BIGINT,
                BasisOfRecordID BIGINT,
                DetailedVectorTypeID BIGINT,
                VectorSubTypeID BIGINT,
                Quantity INT,
                SexID BIGINT,
                IdentifiedByFieldOfficeID BIGINT,
                IdentifiedByPersonID BIGINT,
                IdentifiedDateTime DATETIME2,
                IdentificationMethodID BIGINT,
                ObservationID BIGINT,
                FormTemplateID BIGINT,
                DayPeriodID BIGINT,
                Comment NVARCHAR(500),
                EctoparASSitesCollectionID BIGINT,
                Samples NVARCHAR(MAX),
                FieldTests NVARCHAR(MAX),
                RowStatus INT,
                RowAction INT
            );

        DECLARE @EventsTemp TABLE
        (
            EventId BIGINT NOT NULL,
            EventTypeId BIGINT NULL,
            UserId BIGINT NULL,
            SiteId BIGINT NULL,
            LoginSiteId BIGINT NULL,
            ObjectId BIGINT NULL,
            DiseaseId BIGINT NULL,
            LocationId BIGINT NULL,
            InformationString NVARCHAR(MAX) NULL
        );

        INSERT INTO @EventsTemp
        SELECT *
        FROM
            OPENJSON(@Events)
            WITH
            (
                EventId BIGINT,
                EventTypeId BIGINT,
                UserId BIGINT,
                SiteId BIGINT,
                LoginSiteId BIGINT,
                ObjectId BIGINT,
                DiseaseId BIGINT,
                LocationId BIGINT,
                InformationString NVARCHAR(MAX)
            );

        --save main vector surveillance session
        BEGIN TRANSACTION

        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USSP_GBL_ADDRESS_SET @idfGeoLocation OUTPUT,
                                          NULL,
                                          @idfsGroundType,
                                          @idfsGeolocationType,
                                          @idfslocation,
                                          @strApartment,
                                          @strBuilding,
                                          @strStreetName,
                                          @strHouse,
                                          @strPostalCode,
                                          @strLocationDescription,
                                          @dblDistance,
                                          @dblLatitude,
                                          @dblLongitude,
                                          @Elevation,
                                          NULL,
                                          @dblDirection,
                                          @blnForeignAddress,
                                          @strForeignAddress,
                                          @blnGeoLocationShared,
                                          @AuditUser;
        END;

        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbVectorSurveillanceSession
            WHERE idfVectorSurveillanceSession = @idfVectorSurveillanceSession
        )
        BEGIN

            UPDATE dbo.tlbVectorSurveillanceSession
            SET strFieldSessionID = @strFieldSessionID,
                idfsVectorSurveillanceStatus = @idfsVectorSurveillanceStatus,
                datStartDate = @datStartDate,
                datCloseDate = @datCloseDate,
                idfOutbreak = @idfOutbreak,
                strDescription = @strDescription,
                intCollectionEffort = @intCollectionEffort,
                datModificationForArchiveDate = GETDATE(),
                idfsSite = @SiteID,
                idfLocation = COALESCE(@idfGeoLocation, idfLocation),
                AuditUpdateUser = @AuditUser,
                AuditUpdateDTM = GETDATE()
            WHERE idfVectorSurveillanceSession = @idfVectorSurveillanceSession
            Select @strSessionID = strSessionID
            from tlbVectorSurveillanceSession
            where idfVectorSurveillanceSession = @idfVectorSurveillanceSession
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbVectorSurveillanceSession',
                                              @idfsKey = @idfVectorSurveillanceSession OUTPUT

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = 'Vector Surveillance Session',
                                               @NextNumberValue = @strSessionID OUTPUT,
                                               @InstallationSite = NULL

            INSERT INTO dbo.tlbVectorSurveillanceSession
            (
                idfVectorSurveillanceSession,
                strSessionID,
                strFieldSessionID,
                idfsVectorSurveillanceStatus,
                datStartDate,
                datCloseDate,
                idfLocation,
                idfOutbreak,
                strDescription,
                idfsSite,
                intRowStatus,
                rowguid,
                datModificationForArchiveDate,
                intCollectionEffort,
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
            (@idfVectorSurveillanceSession,
             @strSessionID,
             @strFieldSessionID,
             @idfsVectorSurveillanceStatus,
             @datStartDate,
             @datCloseDate,
             @idfGeoLocation,
             @idfOutbreak,
             @strDescription,
             @SiteID,
             0  ,
             NEWID(),
             GETDATE(),
             @intCollectionEffort,
             NULL,
             NULL,
             10519001,
             '[{"idfVectorSurveillanceSession":' + CAST(@idfVectorSurveillanceSession AS NVARCHAR(100)) + '}]',
             @AuditUser,
             GETDATE(),
             @AuditUser,
             GETDATE()
            )

            UPDATE @EventsTemp
            SET ObjectId = @idfVectorSurveillanceSession
            WHERE ObjectId = 0;
        END;

        UPDATE @AggregateCollectionsTemp
        SET VectorSessionKey = @idfVectorSurveillanceSession;
        UPDATE @DetailedCollectionsTemp
        SET VectorSessionKey = @idfVectorSurveillanceSession;

        --save aggregate collections			
        WHILE EXISTS (SELECT * FROM @AggregateCollectionsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = VectorSessionSummaryKey,
                @idfsVSSessionSummary = VectorSessionSummaryKey,
                @idfVectorSurveillanceSession = VectorSessionKey,
                @strVSSessionSummaryID = SummarySessionID,
                @DiagnosisidfGeoLocation = GeoLocationID,
                @lucAggregateCollectionidfsResidentType = ResidentTypeID,
                @lucAggregateCollectionidfsGroundType = GroundTypeID,
                @lucAggregateCollectionidfsGeolocationType = GeoLocationTypeID,
                @lucAggregateCollectionLocationID = LocationID,
                @lucAggregateCollectionstrApartment = Apartment,
                @lucAggregateCollectionstrBuilding = Building,
                @lucAggregateCollectionstrStreetName = StreetName,
                @lucAggregateCollectionstrHouse = House,
                @lucAggregateCollectionstrPostCode = PostCode,
                @lucAggregateCollectionstrDescription = [Description],
                @lucAggregateCollectiondblDistance = Distance,
                @lucAggregateCollectionstrLatitude = Latitude,
                @lucAggregateCollectionstrLongitude = Longitude,
                @lucAggregateCollectiondblAccuracy = Accuracy,
                @lucAggregateCollectiondblAlignment = Alignment,
                @lucAggregateCollectiondblElevation = Elevation,
                @blnForeignAddress = IsForeignAddress,
                @strForeignAddress = ForeignAddress,
                @blnGeoLocationShared = IsGeoLocationShared,
                @datSummaryCollectionDateTime = CAST(CollectionDateTime AS DATETIME),
                @SummaryInfoSpecies = SummaryInfoSpecies,
                @SummaryInfoSex = SummaryInfoSex,
                @PoolsVectors = PoolsVectors,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @AggregateCollectionsTemp;



            INSERT INTO @SuppressSelect
            EXECUTE [dbo].[USSP_VCTS_SESSIONSUMMARY_SET] @idfsVSSessionSummary OUTPUT,
                                                         @idfVectorSurveillanceSession,
                                                         @strVSSessionSummaryID,
                                                         @DiagnosisidfGeoLocation,
                                                         @lucAggregateCollectionidfsResidentType,
                                                         @lucAggregateCollectionidfsGroundType,
                                                         @lucAggregateCollectionidfsGeolocationType,
                                                         @lucAggregateCollectionLocationID,
                                                         @lucAggregateCollectionstrApartment,
                                                         @lucAggregateCollectionstrBuilding,
                                                         @lucAggregateCollectionstrStreetName,
                                                         @lucAggregateCollectionstrHouse,
                                                         @lucAggregateCollectionstrPostCode,
                                                         @lucAggregateCollectionstrDescription,
                                                         @lucAggregateCollectiondblDistance,
                                                         @lucAggregateCollectionstrLatitude,
                                                         @lucAggregateCollectionstrLongitude,
                                                         @lucAggregateCollectiondblAccuracy,
                                                         @lucAggregateCollectiondblAlignment,
                                                         @lucAggregateCollectiondblElevation,
                                                         @blnForeignAddress,
                                                         @strForeignAddress,
                                                         @blnGeoLocationShared,
                                                         @datSummaryCollectionDateTime,
                                                         @SummaryInfoSpecies,
                                                         @SummaryInfoSex,
                                                         @PoolsVectors,
                                                         @RowStatus,
                                                         @AuditUser

            UPDATE @DiagnosisInfoTemp
            SET idfsVSSessionSummary = @idfsVSSessionSummary
            WHERE idfsVSSessionSummary = @RowID;

            DELETE TOP (1)
            FROM @AggregateCollectionsTemp
            WHERE VectorSessionSummaryKey = @RowID;

        END;

        --save diagnosis items
        WHILE EXISTS (SELECT * FROM @DiagnosisInfoTemp)
        BEGIN
            SELECT TOP 1
                @RowID = idfsVSSessionSummaryDiagnosis,
                @idfsVSSessionSummary = idfsVSSessionSummary,
                @idfsVSSessionSummaryDiagnosis = idfsVSSessionSummaryDiagnosis,
                @idfsDiagnosis = idfsDiagnosis,
                @intPositiveQuantity = intPositiveQuantity,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @DiagnosisInfoTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VCTS_SESSIONSUMMARYDIAGNOSIS_SET @idfsVSSessionSummaryDiagnosis OUTPUT,
                                                              @idfsVSSessionSummary,
                                                              @idfsDiagnosis,
                                                              @intPositiveQuantity,
                                                              @RowStatus,
                                                              @AuditUser;


            DELETE TOP (1)
            FROM @DiagnosisInfoTemp
            WHERE idfsVSSessionSummaryDiagnosis = @RowID

        END;

        --save detailed collections			
        WHILE EXISTS (SELECT * FROM @DetailedCollectionsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = VectorSessionDetailedKey,
                @idfVector = VectorSessionDetailedKey,
                @idfsDetailedVectorSurveillanceSession = VectorSessionKey,
                @idfHostVector = HostVectorID,
                @strVectorID = DetailSessionID,
                @strFieldVectorID = FieldVectorID,
                @idfDetailedLocation = GeoLocationID,
                @lucDetailedCollectionidfsResidentType = ResidentTypeID,
                @lucDetailedCollectionidfsGroundType = GroundTypeID,
                @lucDetailedCollectionidfsGeolocationType = GeoLocationTypeID,
                @lucDetailedCollectionidfsLocation = LocationID,
                @lucDetailedCollectionstrApartment = Apartment,
                @lucDetailedCollectionstrBuilding = Building,
                @lucDetailedCollectionstrStreetName = StreetName,
                @lucDetailedCollectionstrHouse = House,
                @lucDetailedCollectionstrPostCode = PostCode,
                @lucDetailedCollectionstrDescription = [Description],
                @lucDetailedCollectiondblDistance = Distance,
                @lucDetailedCollectionstrLatitude = Latitude,
                @lucDetailedCollectionstrLongitude = Longitude,
                @lucDetailedCollectiondblAccuracy = Accuracy,
                @lucDetailedCollectiondblAlignment = Alignment,
                @blnForeignAddress = IsForeignAddress,
                @strForeignAddress = ForeignAddress,
                @blnGeoLocationShared = IsGeoLocationShared,
                @intDetailedElevation = DetailedElevation,
                @DetailedSurroundings = DetailedSurroundings,
                @strGEOReferenceSource = GeoReferenceSource,
                @idfCollectedByOffice = CollectedByOfficeID,
                @idfCollectedByPerson = CollectionByPersonID,
                @datCollectionDateTime = CollectionDateTime,
                @idfsCollectionMethod = CollectionMethodID,
                @idfsBasisOfRecord = BasisOfRecordID,
                @idfDetailedVectorType = DetailedVectorTypeID,
                @idfsVectorSubType = VectorSubTypeID,
                @intQuantity = Quantity,
                @idfsSex = SexID,
                @idfIdentIFiedByOffice = IdentifiedByFieldOfficeID,
                @idfIdentIFiedByPerson = IdentifiedByPersonID,
                @datIdentIFiedDateTime = IdentifiedDateTime,
                @idfsIdentIFicationMethod = IdentificationMethodID,
                @idfObservation = ObservationID,
                @idfsFormTemplate = FormTemplateID,
                @idfsDayPeriod = DayPeriodID,
                @strComment = Comment,
                @idfsEctoparASitesCollected = EctoparASSitesCollectionID,
                @Samples = Samples,
                @FieldTests = FieldTests
            FROM @DetailedCollectionsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VCTS_DETAILEDCOLLECTIONS_SET @LangID,
                                                          @idfVector,
                                                          @idfsDetailedVectorSurveillanceSession,
                                                          @idfHostVector,
                                                          @strVectorID,
                                                          @strFieldVectorID,
                                                          @idfDetailedLocation,
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
                                                          @lucDetailedCollectiondblAccuracy,
                                                          @lucDetailedCollectiondblAlignment,
                                                          @blnForeignAddress,
                                                          @strForeignAddress,
                                                          @blnGeoLocationShared,
                                                          @intDetailedElevation,
                                                          @DetailedSurroundings,
                                                          @strGEOReferenceSource,
                                                          @idfCollectedByOffice,
                                                          @idfCollectedByPerson,
                                                          @datCollectionDateTime,
                                                          @idfsCollectionMethod,
                                                          @idfsBasisOfRecord,
                                                          @idfDetailedVectorType,
                                                          @idfsVectorSubType,
                                                          @intQuantity,
                                                          @idfsSex,
                                                          @idfIdentIFiedByOffice,
                                                          @idfIdentIFiedByPerson,
                                                          @datIdentIFiedDateTime,
                                                          @idfsIdentIFicationMethod,
                                                          @idfObservation,
                                                          @idfsFormTemplate,
                                                          @idfsDayPeriod,
                                                          @strComment,
                                                          @idfsEctoparASitesCollected,
                                                          @Samples,
                                                          @FieldTests,
                                                          @AuditUser

            DELETE TOP (1)
            FROM @DetailedCollectionsTemp
            WHERE VectorSessionDetailedKey = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @EventsTemp)
        BEGIN
            SELECT TOP 1
                @EventId = EventId,
                @EventTypeId = EventTypeId,
                @EventUserId = UserId,
                @EventObjectId = ObjectId,
                @EventSiteId = SiteId,
                @EventDiseaseId = DiseaseId,
                @EventLocationId = LocationId,
                @EventInformationString = InformationString,
                @EventLoginSiteId = LoginSiteId
            FROM @EventsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @EventObjectId,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUser;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @idfVectorSurveillanceSession SessionKey,
               @strSessionID SessionID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH


END


