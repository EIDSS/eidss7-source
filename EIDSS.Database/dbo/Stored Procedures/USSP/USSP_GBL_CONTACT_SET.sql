-- ================================================================================================
-- Name: USSP_GBL_CONTACT_SET
--
-- Description: Inserts/updates and deletes contacts for human and outbreak modules.
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/21/2022 Initial release 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_CONTACT_SET]
(
    @Contacts NVARCHAR(MAX) = NULL,
    @SiteId BIGINT NULL,
    @AuditUserName NVARCHAR(200) = NULL,
	@idfHumanCase BIGINT NULL
)
AS
BEGIN
    DECLARE @ContactedCasePersonId BIGINT = NULL,
            @OutbreakCaseContactId BIGINT = NULL, -- Outbreak only
            @CaseOrReportId BIGINT = NULL, -- Human disease report or outbreak case identifier
            @ContactTypeId BIGINT = NULL, -- Outbreak only
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
            @LocationId BIGINT = NULL, -- Lowest administrative level
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
            @ContactStatusId BIGINT = NULL, -- Outbreak only
            @ContactTracingObservationId BIGINT = NULL, -- Outbreak only
            @RowStatus INT = NULL,
            @RowAction INT = NULL,
            @ReturnMessage VARCHAR(MAX) = 'Success',
            @ReturnCode BIGINT = 0;
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
        HumanMasterId BIGINT  NULL,
        HumanId BIGINT  NULL,
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
                @HumanId =HumanId,
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
                EXECUTE dbo.USSP_GBL_ADDRESS_SET @GeolocationID = @AddressId OUTPUT,
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
                )

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
            END;
         ELSE
            BEGIN
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
            END;

            IF NOT EXISTS
            (
                SELECT idfContactedCasePerson
                FROM dbo.tlbContactedCasePerson
                WHERE idfContactedCasePerson = @ContactedCasePersonId
				and idfHumanCase=@idfHumanCase
                      AND intRowStatus = 0
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbContactedCasePerson',
                                               @ContactedCasePersonId OUTPUT;

                INSERT INTO [dbo].[tlbContactedCasePerson]
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
            END
            ELSE
            BEGIN
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

                    INSERT INTO OutbreakCaseContact
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
                    )
                END
                ELSE
                BEGIN
                    UPDATE OutbreakCaseContact
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
