-- ================================================================================================
-- Name: USSP_GBL_CONTACTS_SET
--
-- Description: Inserts/updates and deletes contacts for human and outbreak modules.
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/28/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long     12/01/2022 Added EIDSS object ID; smart key that represents the parent object.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_CONTACTS_SET]
(
    @Contacts NVARCHAR(MAX) = NULL,
    @SiteId BIGINT NULL,
    @AuditUserName NVARCHAR(200) = NULL,
    @DataAuditEventID BIGINT = NULL,
    @idfHumanCase BIGINT NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL 
)
AS
BEGIN
    DECLARE @ContactedCasePersonId BIGINT = NULL,
            @OutbreakCaseContactId BIGINT = NULL,                      -- Outbreak only
            @CaseOrReportId BIGINT = NULL,                             -- Human disease report or outbreak case identifier
            @ContactTypeId BIGINT = NULL,                              -- Outbreak only
            @ContactRelationshipTypeId BIGINT = NULL,
            @HumanMasterId BIGINT = NULL,
            @HumanId BIGINT = NULL,
            @PersonalIdTypeId BIGINT = NULL,
            @PersonalId NVARCHAR(100) = NULL,
            @FirstName NVARCHAR(200) = NULL,
            @SecondName NVARCHAR(200) = NULL,
            @LastName NVARCHAR(200) = NULL,
            @DateOfBirth DATETIME = NULL,
            @Age INT = NULL,
            @AgeTypeId BIGINT = NULL,
            @GenderTypeId BIGINT = NULL,
            @CitizenshipTypeId BIGINT = NULL,
            @AddressId BIGINT = NULL,
            @LocationId BIGINT = NULL,                                 -- Lowest administrative level
            @Street NVARCHAR(200) = NULL,
            @PostalCode NVARCHAR(200) = NULL,
            @Apartment NVARCHAR(200) = NULL,
            @Building NVARCHAR(200) = NULL,
            @House NVARCHAR(200) = NULL,
            @ForeignAddressString NVARCHAR(200) = NULL,
            @ContactPhoneCountryCode INT = NULL,
            @ContactPhone NVARCHAR(200) = NULL,
            @ContactPhoneTypeId BIGINT = NULL,
            @DateOfLastContact DATETIME = NULL,
            @PlaceOfLastContact NVARCHAR(200) = NULL,
            @Comments NVARCHAR(500) = NULL,
            @ContactStatusId BIGINT = NULL,                            -- Outbreak only
            @ContactTracingObservationId BIGINT = NULL,                -- Outbreak only
            @RowStatus INT = NULL,
            @RowAction INT = NULL,
            @ReturnMessage VARCHAR(MAX) = 'Success',
            @ReturnCode BIGINT = 0,
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @ObjectID BIGINT = NULL,
            @ObjectHumanTableID BIGINT = 75600000000,                  -- tlbHuman,
            @ObjectHumanAdditionalInfoTableID BIGINT = 53577690000000, -- HumanAddlInfo 
            @ObjectContactedCasePersonTableID BIGINT = 75500000000;    -- tlbContactedCasePerson
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    DECLARE @ContactsTemp TABLE
    (
        ContactedCasePersonId BIGINT NOT NULL,
        OutbreakCaseContactId BIGINT NULL,
        CaseOrReportId BIGINT NULL, -- Human disease report or outbreak case identifiers
        ContactTypeId BIGINT NOT NULL,
        ContactRelationshipTypeId BIGINT NULL,
        HumanMasterId BIGINT NULL,
        HumanId BIGINT NULL,
        PersonalIdTypeId BIGINT NULL,
        PersonalId NVARCHAR(100) NULL,
        FirstName NVARCHAR(200) NULL,
        SecondName NVARCHAR(200) NULL,
        LastName NVARCHAR(200) NULL,
        DateOfBirth DATETIME NULL,
        GenderTypeId BIGINT NULL,
        CitizenshipTypeId BIGINT NULL,
        AddressId BIGINT NULL,
        LocationId BIGINT NULL,
        Street NVARCHAR(200) NULL,
        PostalCode NVARCHAR(200) NULL,
        Apartment NVARCHAR(200) NULL,
        Building NVARCHAR(200) NULL,
        House NVARCHAR(200) NULL,
        ForeignAddressString NVARCHAR(200) NULL,
        ContactPhoneCountryCode INT NULL,
        ContactPhone NVARCHAR(200) NULL,
        ContactPhoneTypeId BIGINT NULL,
        DateOfLastContact DATETIME NULL,
        PlaceOfLastContact NVARCHAR(200) NULL,
        Comments NVARCHAR(500) NULL,
        ContactStatusId BIGINT NULL,
        ContactTracingObservationId BIGINT NULL,
        RowStatus INT NOT NULL,
        RowAction INT NOT NULL,
        AuditUserName NVARCHAR(200)
    );
    DECLARE @HumanBeforeEdit TABLE
    (
        HumanID BIGINT,
        PersonalIDTypeID BIGINT,
        PersonalID NVARCHAR(100),
        FirstName NVARCHAR(200),
        SecondName NVARCHAR(200),
        LastName NVARCHAR(200),
        DateOfBirth DATETIME,
        GenderTypeID BIGINT,
        CitizenshipTypeID BIGINT,
        CurrentResidenceAddressID BIGINT
    );
    DECLARE @HumanAfterEdit TABLE
    (
        HumanID BIGINT,
        PersonalIDTypeID BIGINT,
        PersonalID NVARCHAR(100),
        FirstName NVARCHAR(200),
        SecondName NVARCHAR(200),
        LastName NVARCHAR(200),
        DateOfBirth DATETIME,
        GenderTypeID BIGINT,
        CitizenshipTypeID BIGINT,
        CurrentResidenceAddressID BIGINT
    );
    DECLARE @HumanAdditionalInfoBeforeEdit TABLE
    (
        HumanID BIGINT,
        Age INT,
        AgeTypeID BIGINT,
        ContactPhoneCountryCode INT,
        ContactPhone NVARCHAR(200),
        ContactPhoneTypeID BIGINT
    );
    DECLARE @HumanAdditionalInfoAfterEdit TABLE
    (
        HumanID BIGINT,
        Age INT,
        AgeTypeID BIGINT,
        ContactPhoneCountryCode INT,
        ContactPhone NVARCHAR(200),
        ContactPhoneTypeID BIGINT
    );
    DECLARE @ContactedCasePersonBeforeEdit TABLE
    (
        ContactedCasePersonID BIGINT,
        ContactRelationshipTypeID BIGINT,
        HumanID BIGINT,
        HumanDiseaseReportID BIGINT,
        DateOfLastContact DATETIME,
        PlaceOfLastContact NVARCHAR(200),
        Comments NVARCHAR(500),
        RowStatus INT
    );
    DECLARE @ContactedCasePersonAfterEdit TABLE
    (
        ContactedCasePersonID BIGINT,
        ContactRelationshipTypeID BIGINT,
        HumanID BIGINT,
        HumanDiseaseReportID BIGINT,
        DateOfLastContact DATETIME,
        PlaceOfLastContact NVARCHAR(200),
        Comments NVARCHAR(500),
        RowStatus INT
    );

    INSERT INTO @ContactsTemp
    SELECT *
    FROM
        OPENJSON(@Contacts)
        WITH
        (
            ContactedCasePersonId BIGINT,
            OutbreakCaseContactId BIGINT,
            CaseOrReportId BIGINT,
            ContactTypeId BIGINT,
            ContactRelationshipTypeId BIGINT,
            HumanMasterId BIGINT,
            HumanId BIGINT,
            PersonalIdTypeId BIGINT,
            PersonalId NVARCHAR(100),
            FirstName NVARCHAR(200),
            SecondName NVARCHAR(200),
            LastName NVARCHAR(200),
            DateOfBirth DATETIME,
            GenderTypeId BIGINT,
            CitizenshipTypeId BIGINT,
            AddressId BIGINT,
            LocationId BIGINT,
            Street NVARCHAR(200),
            PostalCode NVARCHAR(200),
            Apartment NVARCHAR(200),
            Building NVARCHAR(200),
            House NVARCHAR(200),
            ForeignAddressString NVARCHAR(200),
            ContactPhoneCountryCode INT,
            ContactPhone NVARCHAR(20),
            ContactPhoneTypeId BIGINT,
            DateOfLastContact DATETIME,
            PlaceOfLastContact NVARCHAR(200),
            Comments NVARCHAR(500),
            ContactStatusId BIGINT,
            ContactTracingObservationId BIGINT,
            RowStatus INT,
            RowAction INT,
            AuditUserName NVARCHAR(200)
        );

    BEGIN TRY
        WHILE EXISTS (SELECT * FROM @ContactsTemp)
        BEGIN

            SELECT TOP 1
                @ContactedCasePersonId = ContactedCasePersonId,
                @OutbreakCaseContactId = OutbreakCaseContactId,
                @CaseOrReportId = @idfHumanCase,
                @ContactTypeId = ContactTypeId,
                @ContactRelationshipTypeId = ContactRelationshipTypeId,
                @HumanMasterId = HumanMasterId,
                @HumanId = HumanId,
                @PersonalIdTypeId = PersonalIdTypeId,
                @PersonalId = PersonalId,
                @FirstName = FirstName,
                @SecondName = SecondName,
                @LastName = LastName,
                @DateOfBirth = DateOfBirth,
                @GenderTypeId = GenderTypeId,
                @CitizenshipTypeId = CitizenshipTypeId,
                @AddressId = AddressId,
                @LocationId = LocationId,
                @Street = Street,
                @PostalCode = PostalCode,
                @Apartment = Apartment,
                @Building = Building,
                @House = House,
                @ForeignAddressString = ForeignAddressString,
                @ContactPhone = ContactPhone,
                @ContactPhoneTypeId = ContactPhoneTypeId,
                @DateOfLastContact = DateOfLastContact,
                @PlaceOfLastContact = PlaceOfLastContact,
                @Comments = Comments,
                @ContactStatusId = ContactStatusId,
                @ContactTracingObservationId = ContactTracingObservationId,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @AuditUserName = AuditUserName
            FROM @ContactsTemp;

            DECLARE @AdminLevel INT = 0;
            SELECT @AdminLevel = node.GetLevel()
            FROM dbo.gisLocation
            WHERE idfsLocation = @LocationId;
            DECLARE @ForeignAddressIndicator BIT = 0;
            IF @ForeignAddressString IS NOT NULL
            BEGIN
                SET @ForeignAddressIndicator = 1;
            END

            IF (@LocationId IS NOT NULL)
                EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING @GeolocationID = @AddressId OUTPUT,
                                                               @DataAuditEventID = @DataAuditEventID,
                                                               @ResidentTypeID = NULL,
                                                               @GroundTypeID = NULL,
                                                               @GeolocationTypeID = NULL,
                                                               @LocationID = @LocationId,
                                                               @Apartment = @Apartment,
                                                               @Building = @Building,
                                                               @StreetName = @Street,
                                                               @House = @House,
                                                               @PostalCodeString = @PostalCode,
                                                               @DescriptionString = NULL,
                                                               @Distance = NULL,
                                                               @Latitude = NULL,
                                                               @Longitude = NULL,
                                                               @Elevation = NULL,
                                                               @Accuracy = NULL,
                                                               @Alignment = NULL,
                                                               @ForeignAddressIndicator = @ForeignAddressIndicator,
                                                               @ForeignAddressString = @ForeignAddressString,
                                                               @GeolocationSharedIndicator = 0,
                                                               @AuditUserName = @AuditUserName,
                                                               @ReturnCode = @ReturnCode OUTPUT,
                                                               @ReturnMessage = @ReturnMessage OUTPUT;

            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.tlbHuman
                WHERE idfHuman = @HumanId
                      AND intRowStatus = 0
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbHuman',
                                                  @idfsKey = @HumanId OUTPUT;

                INSERT INTO dbo.tlbHuman
                (
                    idfHuman,
                    idfHumanActual,
                    idfsNationality,
                    idfsHumanGender,
                    idfCurrentResidenceAddress,
                    idfsOccupationType,
                    idfEmployerAddress,
                    idfRegistrationAddress,
                    datDateofBirth,
                    datDateOfDeath,
                    strFirstName,
                    strSecondName,
                    strLastName,
                    strRegistrationPhone,
                    strEmployerName,
                    strHomePhone,
                    strWorkPhone,
                    idfsPersonIDType,
                    strPersonID,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@HumanId,
                 @HumanMasterId,
                 @CitizenshipTypeId,
                 @GenderTypeId,
                 @AddressId,
                 NULL,
                 NULL,
                 NULL,
                 @DateOfBirth,
                 NULL,
                 @FirstName,
                 @SecondName,
                 @LastName,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 @PersonalIdTypeId,
                 @PersonalId,
                 0  ,
                 10519001,
                 '[{"idfHuman":' + CAST(@HumanId AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE()
                );

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailCreate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser, 
                    strObject
                )
                VALUES
                (@DataAuditEventID,
                 @ObjectHumanTableID,
                 @HumanId,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectHumanTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSObjectID
                );
                -- End data audit

                INSERT INTO dbo.HumanAddlInfo
                (
                    HumanAdditionalInfo,
                    ReportedAge,
                    ReportedAgeUOMID,
                    PassportNbr,
                    IsEmployedID,
                    EmployerPhoneNbr,
                    EmployedDTM,
                    IsStudentID,
                    SchoolName,
                    SchoolPhoneNbr,
                    SchoolAddressID,
                    SchoolLastAttendDTM,
                    ContactPhoneCountryCode,
                    ContactPhoneNbr,
                    ContactPhoneNbrTypeID,
                    ContactPhone2CountryCode,
                    ContactPhone2Nbr,
                    ContactPhone2NbrTypeID,
                    AltAddressID,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@HumanId,
                 @Age,
                 @AgeTypeId,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 @ContactPhoneCountryCode,
                 @ContactPhone,
                 @ContactPhoneTypeId,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 0  ,
                 10519001,
                 '[{"HumanAddlInfoUID":' + CAST(@HumanId AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE()
                );

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailCreate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser, 
                    strObject
                )
                VALUES
                (@DataAuditEventID,
                 @ObjectHumanAdditionalInfoTableID,
                 @HumanId,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectHumanAdditionalInfoTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSObjectID
                );
            -- End data audit
            END;
            ELSE
            BEGIN
                -- Data audit
                DELETE FROM @HumanAdditionalInfoAfterEdit;
                DELETE FROM @HumanAdditionalInfoBeforeEdit;
                DELETE FROM @HumanAfterEdit;
                DELETE FROM @HumanBeforeEdit;

                INSERT INTO @HumanBeforeEdit
                (
                    HumanID,
                    PersonalIDTypeID,
                    PersonalID,
                    FirstName,
                    SecondName,
                    LastName,
                    DateOfBirth,
                    GenderTypeID,
                    CitizenshipTypeID,
                    CurrentResidenceAddressID
                )
                SELECT idfHuman,
                       idfsPersonIDType,
                       strPersonID,
                       strFirstName,
                       strSecondName,
                       strLastName,
                       datDateofBirth,
                       idfsHumanGender,
                       idfsNationality,
                       idfCurrentResidenceAddress
                FROM dbo.tlbHuman
                WHERE idfHuman = @HumanId;
                -- End data audit

                UPDATE dbo.tlbHuman
                SET idfsNationality = @CitizenshipTypeId,
                    idfsHumanGender = @GenderTypeId,
                    idfCurrentResidenceAddress = @AddressId,
                    idfsOccupationType = NULL,
                    idfEmployerAddress = NULL,
                    idfRegistrationAddress = NULL,
                    datDateofBirth = @DateOfBirth,
                    datDateOfDeath = NULL,
                    strFirstName = @FirstName,
                    strSecondName = @SecondName,
                    strLastName = @LastName,
                    strRegistrationPhone = NULL,
                    strEmployerName = NULL,
                    strHomePhone = NULL,
                    strWorkPhone = NULL,
                    idfsPersonIDType = @PersonalIdTypeId,
                    strPersonID = @PersonalId,
                    SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
                    SourceSystemKeyValue = ISNULL(
                                                     SourceSystemKeyValue,
                                                     '[{"idfHuman":' + CAST(@HumanId AS NVARCHAR(300)) + '}]'
                                                 ),
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfHuman = @HumanId;

                -- Data audit
                INSERT INTO @HumanAfterEdit
                (
                    HumanID,
                    PersonalIDTypeID,
                    PersonalID,
                    FirstName,
                    SecondName,
                    LastName,
                    DateOfBirth,
                    GenderTypeID,
                    CitizenshipTypeID,
                    CurrentResidenceAddressID
                )
                SELECT idfHuman,
                       idfsPersonIDType,
                       strPersonID,
                       strFirstName,
                       strSecondName,
                       strLastName,
                       datDateofBirth,
                       idfsHumanGender,
                       idfsNationality,
                       idfCurrentResidenceAddress
                FROM dbo.tlbHuman
                WHERE idfHuman = @HumanId;

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79370000000,
                       a.HumanID,
                       NULL,
                       b.HumanID,
                       a.HumanID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.HumanID <> b.HumanID)
                      OR (
                             a.HumanID IS NOT NULL
                             AND b.HumanID IS NULL
                         )
                      OR (
                             a.HumanID IS NULL
                             AND b.HumanID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79400000000,
                       a.HumanID,
                       NULL,
                       b.CitizenshipTypeID,
                       a.CitizenshipTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.CitizenshipTypeID <> b.CitizenshipTypeID)
                      OR (
                             a.CitizenshipTypeID IS NOT NULL
                             AND b.CitizenshipTypeID IS NULL
                         )
                      OR (
                             a.CitizenshipTypeID IS NULL
                             AND b.CitizenshipTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79350000000,
                       a.HumanID,
                       NULL,
                       b.CurrentResidenceAddressID,
                       a.CurrentResidenceAddressID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.CurrentResidenceAddressID <> b.CurrentResidenceAddressID)
                      OR (
                             a.CurrentResidenceAddressID IS NOT NULL
                             AND b.CurrentResidenceAddressID IS NULL
                         )
                      OR (
                             a.CurrentResidenceAddressID IS NULL
                             AND b.CurrentResidenceAddressID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79330000000,
                       a.HumanID,
                       NULL,
                       b.DateOfBirth,
                       a.DateOfBirth,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.DateOfBirth <> b.DateOfBirth)
                      OR (
                             a.DateOfBirth IS NOT NULL
                             AND b.DateOfBirth IS NULL
                         )
                      OR (
                             a.DateOfBirth IS NULL
                             AND b.DateOfBirth IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79430000000,
                       a.HumanID,
                       NULL,
                       b.FirstName,
                       a.FirstName,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.FirstName <> b.FirstName)
                      OR (
                             a.FirstName IS NOT NULL
                             AND b.FirstName IS NULL
                         )
                      OR (
                             a.FirstName IS NULL
                             AND b.FirstName IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79390000000,
                       a.HumanID,
                       NULL,
                       b.GenderTypeID,
                       a.GenderTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.GenderTypeID <> b.GenderTypeID)
                      OR (
                             a.GenderTypeID IS NOT NULL
                             AND b.GenderTypeID IS NULL
                         )
                      OR (
                             a.GenderTypeID IS NULL
                             AND b.GenderTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       79450000000,
                       a.HumanID,
                       NULL,
                       b.LastName,
                       a.LastName,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.LastName <> b.LastName)
                      OR (
                             a.LastName IS NOT NULL
                             AND b.LastName IS NULL
                         )
                      OR (
                             a.LastName IS NULL
                             AND b.LastName IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       12014470000000,
                       a.HumanID,
                       NULL,
                       b.PersonalID,
                       a.PersonalID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.PersonalID <> b.PersonalID)
                      OR (
                             a.PersonalID IS NOT NULL
                             AND b.PersonalID IS NULL
                         )
                      OR (
                             a.PersonalID IS NULL
                             AND b.PersonalID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanTableID,
                       12014460000000,
                       a.HumanID,
                       NULL,
                       b.PersonalIDTypeID,
                       a.PersonalIDTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAfterEdit AS a
                    FULL JOIN @HumanAfterEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.PersonalIDTypeID <> b.PersonalIDTypeID)
                      OR (
                             a.PersonalIDTypeID IS NOT NULL
                             AND b.PersonalIDTypeID IS NULL
                         )
                      OR (
                             a.PersonalIDTypeID IS NULL
                             AND b.PersonalIDTypeID IS NOT NULL
                         );

                INSERT INTO @HumanAdditionalInfoBeforeEdit
                (
                    HumanID,
                    Age,
                    AgeTypeID,
                    ContactPhoneCountryCode,
                    ContactPhone,
                    ContactPhoneTypeID
                )
                SELECT HumanAdditionalInfo,
                       ReportedAge,
                       ReportedAgeUOMID,
                       ContactPhoneCountryCode,
                       ContactPhoneNbr,
                       ContactPhoneNbrTypeID
                FROM dbo.HumanAddlInfo
                WHERE HumanAdditionalInfo = @HumanId;
                -- End data audit

                UPDATE dbo.HumanAddlInfo
                SET ReportedAge = @Age,
                    ReportedAgeUOMID = @AgeTypeId,
                    PassportNbr = NULL,
                    IsEmployedID = NULL,
                    EmployerPhoneNbr = NULL,
                    EmployedDTM = NULL,
                    IsStudentID = NULL,
                    SchoolName = NULL,
                    SchoolPhoneNbr = NULL,
                    SchoolAddressID = NULL,
                    SchoolLastAttendDTM = NULL,
                    ContactPhoneCountryCode = @ContactPhoneCountryCode,
                    ContactPhoneNbr = @ContactPhone,
                    ContactPhoneNbrTypeID = @ContactPhoneTypeID,
                    ContactPhone2CountryCode = NULL,
                    ContactPhone2Nbr = NULL,
                    ContactPhone2NbrTypeID = NULL,
                    AltAddressID = NULL,
                    SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
                    SourceSystemKeyValue = ISNULL(
                                                     SourceSystemKeyValue,
                                                     '[{"HumanAddlInfoUID":' + CAST(@HumanId AS NVARCHAR(300)) + '}]'
                                                 ),
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE HumanAdditionalInfo = @HumanId;

                -- Data audit
                INSERT INTO @HumanAdditionalInfoAfterEdit
                (
                    HumanID,
                    Age,
                    AgeTypeID,
                    ContactPhoneCountryCode,
                    ContactPhone,
                    ContactPhoneTypeID
                )
                SELECT HumanAdditionalInfo,
                       ReportedAge,
                       ReportedAgeUOMID,
                       ContactPhoneCountryCode,
                       ContactPhoneNbr,
                       ContactPhoneNbrTypeID
                FROM dbo.HumanAddlInfo
                WHERE HumanAdditionalInfo = @HumanId;

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanAdditionalInfoTableID,
                       51586890000001,
                       a.HumanID,
                       NULL,
                       b.Age,
                       a.Age,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAdditionalInfoAfterEdit AS a
                    FULL JOIN @HumanAdditionalInfoBeforeEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.Age <> b.Age)
                      OR (
                             a.Age IS NOT NULL
                             AND b.Age IS NULL
                         )
                      OR (
                             a.Age IS NULL
                             AND b.Age IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanAdditionalInfoTableID,
                       51586890000002,
                       a.HumanID,
                       NULL,
                       b.AgeTypeID,
                       a.AgeTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAdditionalInfoAfterEdit AS a
                    FULL JOIN @HumanAdditionalInfoBeforeEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.AgeTypeID <> b.AgeTypeID)
                      OR (
                             a.AgeTypeID IS NOT NULL
                             AND b.AgeTypeID IS NULL
                         )
                      OR (
                             a.AgeTypeID IS NULL
                             AND b.AgeTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanAdditionalInfoTableID,
                       51586890000003,
                       a.HumanID,
                       NULL,
                       b.ContactPhone,
                       a.ContactPhone,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAdditionalInfoAfterEdit AS a
                    FULL JOIN @HumanAdditionalInfoBeforeEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.ContactPhone <> b.ContactPhone)
                      OR (
                             a.ContactPhone IS NOT NULL
                             AND b.ContactPhone IS NULL
                         )
                      OR (
                             a.ContactPhone IS NULL
                             AND b.ContactPhone IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanAdditionalInfoTableID,
                       51586890000004,
                       a.HumanID,
                       NULL,
                       b.ContactPhoneCountryCode,
                       a.ContactPhoneCountryCode,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAdditionalInfoAfterEdit AS a
                    FULL JOIN @HumanAdditionalInfoBeforeEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.ContactPhoneCountryCode <> b.ContactPhoneCountryCode)
                      OR (
                             a.ContactPhoneCountryCode IS NOT NULL
                             AND b.ContactPhoneCountryCode IS NULL
                         )
                      OR (
                             a.ContactPhoneCountryCode IS NULL
                             AND b.ContactPhoneCountryCode IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanAdditionalInfoTableID,
                       51586890000005,
                       a.HumanID,
                       NULL,
                       b.ContactPhoneTypeID,
                       a.ContactPhoneTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAdditionalInfoAfterEdit AS a
                    FULL JOIN @HumanAdditionalInfoBeforeEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.ContactPhoneTypeID <> b.ContactPhoneTypeID)
                      OR (
                             a.ContactPhoneTypeID IS NOT NULL
                             AND b.ContactPhoneTypeID IS NULL
                         )
                      OR (
                             a.ContactPhoneTypeID IS NULL
                             AND b.ContactPhoneTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectHumanAdditionalInfoTableID,
                       51586890000006,
                       a.HumanID,
                       NULL,
                       b.HumanID,
                       a.HumanID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanAdditionalInfoAfterEdit AS a
                    FULL JOIN @HumanAdditionalInfoBeforeEdit AS b
                        ON a.HumanID = b.HumanID
                WHERE (a.HumanID <> b.HumanID)
                      OR (
                             a.HumanID IS NOT NULL
                             AND b.HumanID IS NULL
                         )
                      OR (
                             a.HumanID IS NULL
                             AND b.HumanID IS NOT NULL
                         );
            -- End data audit
            END;

            IF NOT EXISTS
            (
                SELECT idfContactedCasePerson
                FROM dbo.tlbContactedCasePerson
                WHERE idfContactedCasePerson = @ContactedCasePersonId
                      AND idfHumanCase = @idfHumanCase
                      AND intRowStatus = 0
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbContactedCasePerson',
                                               @ContactedCasePersonId OUTPUT;

                INSERT INTO dbo.tlbContactedCasePerson
                (
                    idfContactedCasePerson,
                    idfsPersonContactType,
                    idfHuman,
                    idfHumanCase,
                    datDateOfLastContact,
                    strPlaceInfo,
                    intRowStatus,
                    strComments,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@ContactedCasePersonId,
                 @ContactRelationshipTypeId,
                 @HumanId,
                 @idfHumanCase,
                 @DateOfLastContact,
                 @PlaceOfLastContact,
                 @RowStatus,
                 @Comments,
                 10519001,
                 '[{"idfContactedCasePerson":' + CAST(@ContactedCasePersonId AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE()
                );

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailCreate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    strObject
                )
                VALUES
                (@DataAuditEventID,
                 @ObjectContactedCasePersonTableID,
                 @HumanId,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectContactedCasePersonTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSObjectID
                );
            -- End data audit
            END
            ELSE
            BEGIN
                -- Data audit
                DELETE FROM @ContactedCasePersonAfterEdit;
                DELETE FROM @ContactedCasePersonBeforeEdit;

                INSERT INTO @ContactedCasePersonBeforeEdit
                (
                    ContactedCasePersonID,
                    ContactRelationshipTypeID,
                    HumanID,
                    HumanDiseaseReportID,
                    DateOfLastContact,
                    PlaceOfLastContact,
                    Comments,
                    RowStatus
                )
                SELECT idfContactedCasePerson,
                       idfsPersonContactType,
                       idfHuman,
                       idfHumanCase,
                       datDateOfLastContact,
                       strPlaceInfo,
                       strComments,
                       intRowStatus
                FROM dbo.tlbContactedCasePerson
                WHERE idfContactedCasePerson = @ContactedCasePersonId;
                -- End data audit

                UPDATE dbo.tlbContactedCasePerson
                SET idfsPersonContactType = @ContactRelationshipTypeId,
                    idfHuman = @HumanId,
                    idfHumanCase = @idfHumanCase,
                    datDateOfLastContact = @DateOfLastContact,
                    strPlaceInfo = @PlaceOfLastContact,
                    intRowStatus = @RowStatus,
                    strComments = @Comments,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfContactedCasePerson = @ContactedCasePersonId
                      AND intRowStatus = 0;

                -- Data audit
                INSERT INTO @ContactedCasePersonAfterEdit
                (
                    ContactedCasePersonID,
                    ContactRelationshipTypeID,
                    HumanID,
                    HumanDiseaseReportID,
                    DateOfLastContact,
                    PlaceOfLastContact,
                    Comments,
                    RowStatus
                )
                SELECT idfContactedCasePerson,
                       idfsPersonContactType,
                       idfHuman,
                       idfHumanCase,
                       datDateOfLastContact,
                       strPlaceInfo,
                       strComments,
                       intRowStatus
                FROM dbo.tlbContactedCasePerson
                WHERE idfContactedCasePerson = @ContactedCasePersonId;

                IF @RowStatus = 0
                BEGIN
                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectContactedCasePersonTableID,
                           12675390000000,
                           a.ContactedCasePersonID,
                           NULL,
                           b.Comments,
                           a.Comments,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ContactedCasePersonAfterEdit AS a
                        FULL JOIN @ContactedCasePersonBeforeEdit AS b
                            ON a.ContactedCasePersonID = b.ContactedCasePersonID
                    WHERE (a.Comments <> b.Comments)
                          OR (
                                 a.Comments IS NOT NULL
                                 AND b.Comments IS NULL
                             )
                          OR (
                                 a.Comments IS NULL
                                 AND b.Comments IS NOT NULL
                             );

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectContactedCasePersonTableID,
                           78520000000,
                           a.ContactedCasePersonID,
                           NULL,
                           b.ContactRelationshipTypeID,
                           a.ContactRelationshipTypeID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ContactedCasePersonAfterEdit AS a
                        FULL JOIN @ContactedCasePersonBeforeEdit AS b
                            ON a.ContactedCasePersonID = b.ContactedCasePersonID
                    WHERE (a.ContactRelationshipTypeID <> b.ContactRelationshipTypeID)
                          OR (
                                 a.ContactRelationshipTypeID IS NOT NULL
                                 AND b.ContactRelationshipTypeID IS NULL
                             )
                          OR (
                                 a.ContactRelationshipTypeID IS NULL
                                 AND b.ContactRelationshipTypeID IS NOT NULL
                             );

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectContactedCasePersonTableID,
                           78500000000,
                           a.ContactedCasePersonID,
                           NULL,
                           b.DateOfLastContact,
                           a.DateOfLastContact,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ContactedCasePersonAfterEdit AS a
                        FULL JOIN @ContactedCasePersonBeforeEdit AS b
                            ON a.ContactedCasePersonID = b.ContactedCasePersonID
                    WHERE (a.DateOfLastContact <> b.DateOfLastContact)
                          OR (
                                 a.DateOfLastContact IS NOT NULL
                                 AND b.DateOfLastContact IS NULL
                             )
                          OR (
                                 a.DateOfLastContact IS NULL
                                 AND b.DateOfLastContact IS NOT NULL
                             );

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectContactedCasePersonTableID,
                           4566380000000,
                           a.ContactedCasePersonID,
                           NULL,
                           b.HumanDiseaseReportID,
                           a.HumanDiseaseReportID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ContactedCasePersonAfterEdit AS a
                        FULL JOIN @ContactedCasePersonBeforeEdit AS b
                            ON a.ContactedCasePersonID = b.ContactedCasePersonID
                    WHERE (a.HumanDiseaseReportID <> b.HumanDiseaseReportID)
                          OR (
                                 a.HumanDiseaseReportID IS NOT NULL
                                 AND b.HumanDiseaseReportID IS NULL
                             )
                          OR (
                                 a.HumanDiseaseReportID IS NULL
                                 AND b.HumanDiseaseReportID IS NOT NULL
                             );

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectContactedCasePersonTableID,
                           78510000000,
                           a.ContactedCasePersonID,
                           NULL,
                           b.HumanID,
                           a.HumanID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ContactedCasePersonAfterEdit AS a
                        FULL JOIN @ContactedCasePersonBeforeEdit AS b
                            ON a.ContactedCasePersonID = b.ContactedCasePersonID
                    WHERE (a.HumanID <> b.HumanID)
                          OR (
                                 a.HumanID IS NOT NULL
                                 AND b.HumanID IS NULL
                             )
                          OR (
                                 a.HumanID IS NULL
                                 AND b.HumanID IS NOT NULL
                             );

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectContactedCasePersonTableID,
                           4566390000000,
                           a.ContactedCasePersonID,
                           NULL,
                           b.PlaceOfLastContact,
                           a.PlaceOfLastContact,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @ContactedCasePersonAfterEdit AS a
                        FULL JOIN @ContactedCasePersonBeforeEdit AS b
                            ON a.ContactedCasePersonID = b.ContactedCasePersonID
                    WHERE (a.PlaceOfLastContact <> b.PlaceOfLastContact)
                          OR (
                                 a.PlaceOfLastContact IS NOT NULL
                                 AND b.PlaceOfLastContact IS NULL
                             )
                          OR (
                                 a.PlaceOfLastContact IS NULL
                                 AND b.PlaceOfLastContact IS NOT NULL
                             );
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.tauDataAuditDetailDelete
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        AuditCreateUser,
                        strObject
                    )
                    VALUES
                    (@DataAuditEventID, @ObjectContactedCasePersonTableID, @ContactedCasePersonId, @AuditUserName, @EIDSSObjectID);
                END
            END

            IF @OutbreakCaseContactId IS NOT NULL
            BEGIN
                IF NOT EXISTS
                (
                    SELECT OutbreakCaseContactUID
                    FROM dbo.OutbreakCaseContact
                    WHERE OutbreakCaseContactUID = @OutbreakCaseContactId
                          AND intRowStatus = 0
                )
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseContact',
                                                   @OutbreakCaseContactId OUTPUT;

                    INSERT INTO dbo.OutbreakCaseContact
                    (
                        OutbreakCaseContactUID,
                        OutbreakCaseReportUID,
                        ContactTypeID,
                        ContactedHumanCasePersonID,
                        idfHuman,
                        ContactRelationshipTypeID,
                        DateOfLastContact,
                        PlaceOfLastContact,
                        CommentText,
                        ContactStatusID,
                        ContactTracingObservationID,
                        intRowStatus,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser,
                        AuditCreateDTM
                    )
                    VALUES
                    (@OutbreakCaseContactId,
                     @CaseOrReportId,
                     @ContactTypeId,
                     @ContactedCasePersonId,
                     @HumanId,
                     @ContactRelationshipTypeId,
                     @DateOfLastContact,
                     @PlaceOfLastContact,
                     @Comments,
                     @ContactStatusId,
                     @ContactTracingObservationId,
                     @RowStatus,
                     10519001,
                     '[{"OutbreakCaseContactUID":' + CAST(@OutbreakCaseContactId AS NVARCHAR(300)) + '}]',
                     @AuditUserName,
                     GETDATE()
                    );
                END
                ELSE
                BEGIN
                    UPDATE dbo.OutbreakCaseContact
                    SET ContactTypeID = @ContactTypeId,
                        ContactRelationshipTypeID = @ContactRelationshipTypeId,
                        DateOfLastContact = @DateOfLastContact,
                        PlaceOfLastContact = @PlaceOfLastContact,
                        CommentText = @Comments,
                        ContactStatusID = @ContactStatusId,
                        intRowStatus = @RowStatus,
                        AuditUpdateUser = @AuditUserName,
                        AuditUpdateDTM = GETDATE()
                    WHERE OutbreakCaseContactUID = @OutbreakCaseContactId;
                END
            END;

            SET ROWCOUNT 1;
            DELETE FROM @ContactsTemp;
            SET ROWCOUNT 0;
        END
    END TRY
    BEGIN CATCH
        THROW
    END CATCH;
END
