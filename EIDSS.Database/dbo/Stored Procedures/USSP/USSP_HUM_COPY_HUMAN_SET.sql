-- ================================================================================================
-- Name: USSP_HUM_COPY_HUMAN_SET
--
-- Description:	Copies information from tlbHumanActual into tlbHuman if @HumanActualID is null or 
-- record with @HumanID doesn't exist in tlbHuman, then new record is created in tlbHuman.
--
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Stephen Long        11/18/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long        04/05/2023 Added output to return code and return message.
--
--BEGIN tran
--EXEC USSP_HUM_COPY_HUMAN_SET @HumanActualID, @HumanID OUT
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HUM_COPY_HUMAN_SET]
(
    @HumanActualID BIGINT = NULL,
    @DataAuditEventID BIGINT = NULL,
    @AuditUserName NVARCHAR(200) = NULL, 
    @HumanID BIGINT = NULL OUTPUT,
    @ReturnCode INT = 0 OUTPUT,
    @ReturnMessage NVARCHAR(MAX) = 'SUCCESS' OUTPUT
)
AS
DECLARE @CurrentResidenceAddressID BIGINT,
        @EmployerAddressID BIGINT,
        @RegistrationAddressID BIGINT,
        @SchoolAddressID BIGINT,
		@AltAddressID BIGINT,
        @CopyCurrentResidenceAddressID BIGINT,
        @CopyEmployerAddressID BIGINT,
        @CopyRegistrationAddressID BIGINT,
        @CopySchoolAddressID BIGINT,
		@CopyAltAddress BIGINT,
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = @HumanID,
        @ObjectTableID BIGINT = 75600000000; -- tlbHuman

DECLARE @HumanBeforeEdit TABLE
(
    HumanID BIGINT,
    HumanActualID BIGINT,
    OccupationTypeID BIGINT,
    NationalityTypeID BIGINT,
    GenderTypeID BIGINT,
    CurrentResidenceAddressID BIGINT,
    EmployerAddressID BIGINT,
    RegistrationAddressID BIGINT,
    DateOfBirth DATETIME,
    DateOfDeath DATETIME,
    LastName NVARCHAR(200),
    SecondName NVARCHAR(200),
    FirstName NVARCHAR(200),
    RegistrationPhone NVARCHAR(200),
    EmployerName NVARCHAR(200),
    HomePhone NVARCHAR(200),
    WorkPhone NVARCHAR(200),
    PersonIDType BIGINT,
    PersonID NVARCHAR(100),
    PermanentAddressAsCurrentIndicator BIT,
    EnteredDate DATETIME,
    ModificationDate DATETIME
);
DECLARE @HumanAfterEdit TABLE
(
    HumanID BIGINT,
    HumanActualID BIGINT,
    OccupationTypeID BIGINT,
    NationalityTypeID BIGINT,
    GenderTypeID BIGINT,
    CurrentResidenceAddressID BIGINT,
    EmployerAddressID BIGINT,
    RegistrationAddressID BIGINT,
    DateOfBirth DATETIME,
    DateOfDeath DATETIME,
    LastName NVARCHAR(200),
    SecondName NVARCHAR(200),
    FirstName NVARCHAR(200),
    RegistrationPhone NVARCHAR(200),
    EmployerName NVARCHAR(200),
    HomePhone NVARCHAR(200),
    WorkPhone NVARCHAR(200),
    PersonIDType BIGINT,
    PersonID NVARCHAR(100),
    PermanentAddressAsCurrentIndicator BIT,
    EnteredDate DATETIME,
    ModificationDate DATETIME
);

DECLARE @HumanAddlInfoBeforeEdit table
(
    HumanID BIGINT,
	PassportNbr NVARCHAR(20),
    IsEmployedID BIGINT,
    EmployerPhoneNbr NVARCHAR(200),
    EmployedDTM DATETIME,
    IsStudentID BIGINT,
    SchoolPhoneNbr NVARCHAR(200),
    SchoolAddressID BIGINT,
    SchoolLastAttendDTM DATETIME,
    ContactPhoneCountryCode INT,
    ContactPhoneNbr NVARCHAR(200),
    ContactPhoneNbrTypeID BIGINT,
    ContactPhone2CountryCode INT,
    ContactPhone2Nbr NVARCHAR(200),
    ContactPhone2NbrTypeID BIGINT,
    AltAddressID BIGINT,
    SchoolName NVARCHAR(200),
	IsAnotherPhoneID BIGINT,
	IsAnotherAddressID BIGINT
);

DECLARE @HumanAddlInfoAfterEdit table
(
    HumanID BIGINT,
	PassportNbr NVARCHAR(20),
    IsEmployedID BIGINT,
    EmployerPhoneNbr NVARCHAR(200),
    EmployedDTM DATETIME,
    IsStudentID BIGINT,
    SchoolPhoneNbr NVARCHAR(200),
    SchoolAddressID BIGINT,
    SchoolLastAttendDTM DATETIME,
    ContactPhoneCountryCode INT,
    ContactPhoneNbr NVARCHAR(200),
    ContactPhoneNbrTypeID BIGINT,
    ContactPhone2CountryCode INT,
    ContactPhone2Nbr NVARCHAR(200),
    ContactPhone2NbrTypeID BIGINT,
    AltAddressID BIGINT,
    SchoolName NVARCHAR(200),
	IsAnotherPhoneID BIGINT,
	IsAnotherAddressID BIGINT
);

BEGIN
    BEGIN TRY
        SELECT @CurrentResidenceAddressID = ha.idfCurrentResidenceAddress,
               @EmployerAddressID = ha.idfEmployerAddress,
               @RegistrationAddressID = ha.idfRegistrationAddress,
			   @SchoolAddressID = haai.SchoolAddressID,
			   @AltAddressID = haai.AltAddressID
        FROM dbo.tlbHumanActual ha
		left join dbo.HumanActualAddlInfo haai
		on	haai.HumanActualAddlInfoUID = ha.idfHumanActual
        WHERE ha.idfHumanActual = @HumanActualID;

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = UserInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        IF @HumanID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbHuman', @HumanID OUTPUT;
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type
        END
        ELSE
        BEGIN
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
        END

        -- Get ids for copies of idfCurrentResidenceAddress, idfEmployerAddress, idfRegistrationAddress
        SET @CopyCurrentResidenceAddressID = NULL;
        SET @CopyEmployerAddressID = NULL;
        SET @CopyRegistrationAddressID = NULL;

        SELECT @CopyCurrentResidenceAddressID = dbo.tlbHuman.idfCurrentResidenceAddress,
		       @CopyEmployerAddressID = dbo.tlbHuman.idfEmployerAddress,
			   @CopyRegistrationAddressID = dbo.tlbHuman.idfRegistrationAddress
        FROM dbo.tlbHuman
        WHERE dbo.tlbHuman.idfHuman = @HumanID;

        -- Generate id for copy of idfCurrentResidenceAddress
        IF @CopyCurrentResidenceAddressID IS NULL
           AND NOT @CurrentResidenceAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @CopyCurrentResidenceAddressID OUTPUT;

            -- Copy current residence address
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @CurrentResidenceAddressID,
                                                   @CopyCurrentResidenceAddressID,
                                                   0,
                                                   @DataAuditEventID,
                                                   @AuditUserName,
                                                   @ReturnCode OUTPUT,
                                                   @ReturnMessage OUTPUT;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy current residence address';
                SELECT @ReturnCode,
                       @ReturnMessage;
                RETURN;
            END
        END

        -- Generate id for copy of idfEmployerAddress
        IF @CopyEmployerAddressID IS NULL
           AND NOT @EmployerAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @CopyEmployerAddressID OUTPUT;

            -- Copy employer address
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @EmployerAddressID,
                                                   @CopyEmployerAddressID,
                                                   0,
                                                   @DataAuditEventID,
                                                   @AuditUserName,
                                                   @ReturnCode OUTPUT,
                                                   @ReturnMessage OUTPUT;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy employer address';
                SELECT @ReturnCode,
                       @ReturnMessage;
                RETURN;
            END
        END

        -- Generate id for copy of idfRegistrationAddress
        IF @CopyRegistrationAddressID IS NULL
           AND NOT @RegistrationAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @CopyRegistrationAddressID OUTPUT;

            -- Copy registration address
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @RegistrationAddressID,
                                                   @CopyRegistrationAddressID,
                                                   0,
                                                   @DataAuditEventID,
                                                   @AuditUserName, 
                                                   @ReturnCode OUTPUT,
                                                   @ReturnMessage OUTPUT;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy registration address';
                SELECT @ReturnCode,
                       @ReturnMessage;
                RETURN;
            END
        END


        IF EXISTS (SELECT * FROM dbo.tlbHuman WHERE idfHuman = @HumanID)
        BEGIN
            INSERT INTO @HumanBeforeEdit
            (
                HumanID,
                HumanActualID,
                OccupationTypeID,
                NationalityTypeID,
                GenderTypeID,
                CurrentResidenceAddressID,
                EmployerAddressID,
                RegistrationAddressID,
                DateOfBirth,
                DateOfDeath,
                LastName,
                SecondName,
                FirstName,
                RegistrationPhone,
                EmployerName,
                HomePhone,
                WorkPhone,
                PersonIDType,
                PersonID,
                PermanentAddressAsCurrentIndicator,
                EnteredDate,
                ModificationDate
            )
            SELECT idfHuman,
                   idfHumanActual,
                   idfsOccupationType,
                   idfsNationality,
                   idfsHumanGender,
                   idfCurrentResidenceAddress,
                   idfEmployerAddress,
                   idfRegistrationAddress,
                   datDateofBirth,
                   datDateOfDeath,
                   strLastName,
                   strSecondName,
                   strFirstName,
                   strRegistrationPhone,
                   strEmployerName,
                   strHomePhone,
                   strWorkPhone,
                   idfsPersonIDType,
                   strPersonID,
                   blnPermantentAddressAsCurrent,
                   datEnteredDate,
                   datModificationDate
            FROM dbo.tlbHuman
            WHERE idfHuman = @HumanID;

            UPDATE dbo.tlbHuman
            SET idfHumanActual = @HumanActualID,
                idfsOccupationType = ha.idfsOccupationType,
                idfsNationality = ha.idfsNationality,
                idfsHumanGender = ha.idfsHumanGender,
                idfCurrentResidenceAddress = @CopyCurrentResidenceAddressID,
                idfEmployerAddress = @CopyEmployerAddressID,
                idfRegistrationAddress = @CopyRegistrationAddressID,
                datDateofBirth = ha.datDateofBirth,
                datDateOfDeath = ha.datDateOfDeath,
                strLastName = ha.strLastName,
                strSecondName = ha.strSecondName,
                strFirstName = ha.strFirstName,
                strRegistrationPhone = ha.strRegistrationPhone,
                strEmployerName = ha.strEmployerName,
                strHomePhone = ha.strHomePhone,
                strWorkPhone = ha.strWorkPhone,
                idfsPersonIDType = ha.idfsPersonIDType,
                strPersonID = ha.strPersonID,
                datModIFicationDate = ha.datModIFicationDate, 
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            FROM dbo.tlbHuman h
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = ha.idfHumanActual
            WHERE h.idfHuman = @HumanID;

            INSERT INTO @HumanAfterEdit
            (
                HumanID,
                HumanActualID,
                OccupationTypeID,
                NationalityTypeID,
                GenderTypeID,
                CurrentResidenceAddressID,
                EmployerAddressID,
                RegistrationAddressID,
                DateOfBirth,
                DateOfDeath,
                LastName,
                SecondName,
                FirstName,
                RegistrationPhone,
                EmployerName,
                HomePhone,
                WorkPhone,
                PersonIDType,
                PersonID,
                PermanentAddressAsCurrentIndicator,
                EnteredDate,
                ModificationDate
            )
            SELECT idfHuman,
                   idfHumanActual,
                   idfsOccupationType,
                   idfsNationality,
                   idfsHumanGender,
                   idfCurrentResidenceAddress,
                   idfEmployerAddress,
                   idfRegistrationAddress,
                   datDateofBirth,
                   datDateOfDeath,
                   strLastName,
                   strSecondName,
                   strFirstName,
                   strRegistrationPhone,
                   strEmployerName,
                   strHomePhone,
                   strWorkPhone,
                   idfsPersonIDType,
                   strPersonID,
                   blnPermantentAddressAsCurrent,
                   datEnteredDate,
                   datModificationDate
            FROM dbo.tlbHuman
            WHERE idfHuman = @HumanID;

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572310000000,
                   a.HumanID,
                   NULL,
                   b.HumanActualID,
                   a.HumanActualID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.HumanActualID <> b.HumanActualID)
                  OR (
                         a.HumanActualID IS NOT NULL
                         AND b.HumanActualID IS NULL
                     )
                  OR (
                         a.HumanActualID IS NULL
                         AND b.HumanActualID IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79410000000,
                   a.HumanID,
                   NULL,
                   b.OccupationTypeID,
                   a.OccupationTypeID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.OccupationTypeID <> b.OccupationTypeID)
                  OR (
                         a.OccupationTypeID IS NOT NULL
                         AND b.OccupationTypeID IS NULL
                     )
                  OR (
                         a.OccupationTypeID IS NULL
                         AND b.OccupationTypeID IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79400000000,
                   a.HumanID,
                   NULL,
                   b.NationalityTypeID,
                   a.NationalityTypeID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.NationalityTypeID <> b.NationalityTypeID)
                  OR (
                         a.NationalityTypeID IS NOT NULL
                         AND b.NationalityTypeID IS NULL
                     )
                  OR (
                         a.NationalityTypeID IS NULL
                         AND b.NationalityTypeID IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79390000000,
                   a.HumanID,
                   NULL,
                   b.GenderTypeID,
                   a.GenderTypeID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79350000000,
                   a.HumanID,
                   NULL,
                   b.CurrentResidenceAddressID,
                   a.CurrentResidenceAddressID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79360000000,
                   a.HumanID,
                   NULL,
                   b.EmployerAddressID,
                   a.EmployerAddressID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.EmployerAddressID <> b.EmployerAddressID)
                  OR (
                         a.EmployerAddressID IS NOT NULL
                         AND b.EmployerAddressID IS NULL
                     )
                  OR (
                         a.EmployerAddressID IS NULL
                         AND b.EmployerAddressID IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79380000000,
                   a.HumanID,
                   NULL,
                   b.RegistrationAddressID,
                   a.RegistrationAddressID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.RegistrationAddressID <> b.RegistrationAddressID)
                  OR (
                         a.RegistrationAddressID IS NOT NULL
                         AND b.RegistrationAddressID IS NULL
                     )
                  OR (
                         a.RegistrationAddressID IS NULL
                         AND b.RegistrationAddressID IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79330000000,
                   a.HumanID,
                   NULL,
                   b.DateOfBirth,
                   a.DateOfBirth,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79340000000,
                   a.HumanID,
                   NULL,
                   b.DateOfDeath,
                   a.DateOfDeath,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.DateOfDeath <> b.DateOfDeath)
                  OR (
                         a.DateOfDeath IS NOT NULL
                         AND b.DateOfDeath IS NULL
                     )
                  OR (
                         a.DateOfDeath IS NULL
                         AND b.DateOfDeath IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79450000000,
                   a.HumanID,
                   NULL,
                   b.LastName,
                   a.LastName,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79470000000,
                   a.HumanID,
                   NULL,
                   b.SecondName,
                   a.SecondName,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.SecondName <> b.SecondName)
                  OR (
                         a.SecondName IS NOT NULL
                         AND b.SecondName IS NULL
                     )
                  OR (
                         a.SecondName IS NULL
                         AND b.SecondName IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79430000000,
                   a.HumanID,
                   NULL,
                   b.FirstName,
                   a.FirstName,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79460000000,
                   a.HumanID,
                   NULL,
                   b.RegistrationPhone,
                   a.RegistrationPhone,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.RegistrationPhone <> b.RegistrationPhone)
                  OR (
                         a.RegistrationPhone IS NOT NULL
                         AND b.RegistrationPhone IS NULL
                     )
                  OR (
                         a.RegistrationPhone IS NULL
                         AND b.RegistrationPhone IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79420000000,
                   a.HumanID,
                   NULL,
                   b.EmployerName,
                   a.EmployerName,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.EmployerName <> b.EmployerName)
                  OR (
                         a.EmployerName IS NOT NULL
                         AND b.EmployerName IS NULL
                     )
                  OR (
                         a.EmployerName IS NULL
                         AND b.EmployerName IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79440000000,
                   a.HumanID,
                   NULL,
                   b.HomePhone,
                   a.HomePhone,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.HomePhone <> b.HomePhone)
                  OR (
                         a.HomePhone IS NOT NULL
                         AND b.HomePhone IS NULL
                     )
                  OR (
                         a.HomePhone IS NULL
                         AND b.HomePhone IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79480000000,
                   a.HumanID,
                   NULL,
                   b.WorkPhone,
                   a.WorkPhone,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.WorkPhone <> b.WorkPhone)
                  OR (
                         a.WorkPhone IS NOT NULL
                         AND b.WorkPhone IS NULL
                     )
                  OR (
                         a.WorkPhone IS NULL
                         AND b.WorkPhone IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014460000000,
                   a.HumanID,
                   NULL,
                   b.PersonIDType,
                   a.PersonIDType,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.PersonIDType <> b.PersonIDType)
                  OR (
                         a.PersonIDType IS NOT NULL
                         AND b.PersonIDType IS NULL
                     )
                  OR (
                         a.PersonIDType IS NULL
                         AND b.PersonIDType IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014470000000,
                   a.HumanID,
                   NULL,
                   b.PersonID,
                   a.PersonID,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.PersonID <> b.PersonID)
                  OR (
                         a.PersonID IS NOT NULL
                         AND b.PersonID IS NULL
                     )
                  OR (
                         a.PersonID IS NULL
                         AND b.PersonID IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12675400000000,
                   a.HumanID,
                   NULL,
                   b.PermanentAddressAsCurrentIndicator,
                   a.PermanentAddressAsCurrentIndicator,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.PermanentAddressAsCurrentIndicator <> b.PermanentAddressAsCurrentIndicator)
                  OR (
                         a.PermanentAddressAsCurrentIndicator IS NOT NULL
                         AND b.PermanentAddressAsCurrentIndicator IS NULL
                     )
                  OR (
                         a.PermanentAddressAsCurrentIndicator IS NULL
                         AND b.PermanentAddressAsCurrentIndicator IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51389530000000,
                   a.HumanID,
                   NULL,
                   b.EnteredDate,
                   a.EnteredDate,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.EnteredDate <> b.EnteredDate)
                  OR (
                         a.EnteredDate IS NOT NULL
                         AND b.EnteredDate IS NULL
                     )
                  OR (
                         a.EnteredDate IS NULL
                         AND b.EnteredDate IS NOT NULL
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
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51389540000000,
                   a.HumanID,
                   NULL,
                   b.ModificationDate,
                   a.ModificationDate,
                   GETDATE(),
                   @AuditUserName
            FROM @HumanAfterEdit AS a
                FULL JOIN @HumanBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.ModificationDate <> b.ModificationDate)
                  OR (
                         a.ModificationDate IS NOT NULL
                         AND b.ModificationDate IS NULL
                     )
                  OR (
                         a.ModificationDate IS NULL
                         AND b.ModificationDate IS NOT NULL
                     );
        END
        ELSE
        BEGIN
            INSERT INTO dbo.tlbHuman
            (
                idfHuman,
                idfHumanActual,
                idfsOccupationType,
                idfsNationality,
                idfsHumanGender,
                idfCurrentResidenceAddress,
                idfEmployerAddress,
                idfRegistrationAddress,
                datDateofBirth,
                datDateOfDeath,
                strLastName,
                strSecondName,
                strFirstName,
                strRegistrationPhone,
                strEmployerName,
                strHomePhone,
                strWorkPhone,
                idfsPersonIDType,
                strPersonID,
                datEnteredDate,
                datModIFicationDate,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            SELECT @HumanID,
                   @HumanActualID,
                   idfsOccupationType,
                   idfsNationality,
                   idfsHumanGender,
                   @CopyCurrentResidenceAddressID,
                   @CopyEmployerAddressID,
                   @CopyRegistrationAddressID,
                   datDateofBirth,
                   datDateOfDeath,
                   strLastName,
                   strSecondName,
                   strFirstName,
                   strRegistrationPhone,
                   strEmployerName,
                   strHomePhone,
                   strWorkPhone,
                   idfsPersonIDType,
                   strPersonID,
                   datEnteredDate,
                   datModIFicationDate,
                   0,
                   GETDATE(),
                   @AuditUserName
            FROM dbo.tlbHumanActual
            WHERE idfHumanActual = @HumanActualID;

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (
                @DataAuditEventID, 
                @ObjectTableID, 
                @HumanID, 
                10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
                 + ',"idfObjectTable":' + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                @AuditUserName
            );
            -- End data audit
        END

        -- Insert/Update Additional Info

        -- Get ids for copies of SchoolAddressID and AltAddressID
        SET @CopySchoolAddressID = NULL;
		SET @CopyAltAddress = NULL;
        SELECT @CopySchoolAddressID = dbo.HumanAddlInfo.SchoolAddressID,
		       @CopyAltAddress = dbo.HumanAddlInfo.AltAddressID
        FROM dbo.HumanAddlInfo
        WHERE dbo.HumanAddlInfo.HumanAdditionalInfo = @HumanID;

        -- Generate id for copy of SchoolAddressID
        IF @CopySchoolAddressID IS NULL
           AND NOT @SchoolAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @CopySchoolAddressID OUTPUT

            -- Copy school address
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @SchoolAddressID,
                                                   @CopySchoolAddressID,
                                                   0,
                                                   @DataAuditEventID,
                                                   @AuditUserName,
                                                   @ReturnCode OUTPUT,
                                                   @ReturnMessage OUTPUT;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy school address';
                SELECT @ReturnCode 'ReturnCode',
                       @ReturnMessage 'ReturnMessage';
                RETURN;
            END
        END

        -- Generate id for copy of AltAddressID
        IF @CopyAltAddress IS NULL
           AND NOT @AltAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @CopyAltAddress OUTPUT

            -- Copy alternative address
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @AltAddressID,
                                                   @CopyAltAddress,
                                                   0,
                                                   @DataAuditEventID,
                                                   @AuditUserName,
                                                   @ReturnCode OUTPUT,
                                                   @ReturnMessage OUTPUT;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy alternative address';
                SELECT @ReturnCode 'ReturnCode',
                       @ReturnMessage 'ReturnMessage';
                RETURN;
            END
        END


		DECLARE @ObjectTable_HumanAddlInfo BIGINT = 53577690000000
        
		IF EXISTS
        (
            SELECT 1
            FROM dbo.HumanAddlInfo
            WHERE HumanAdditionalInfo = @HumanID
        )
        BEGIN
			insert into @HumanAddlInfoBeforeEdit
			(
				HumanID,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
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
				SchoolName,
				IsAnotherPhoneID,
				IsAnotherAddressID
			)
            SELECT
				HumanAdditionalInfo,
				PassportNbr,
                IsEmployedID,
                EmployerPhoneNbr,
                EmployedDTM,
                IsStudentID,
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
                SchoolName,
				IsAnotherPhoneID,
				IsAnotherAddressID
            FROM dbo.HumanAddlInfo hai
            WHERE hai.HumanAdditionalInfo = @HumanID;


            UPDATE dbo.HumanAddlInfo
            SET PassportNbr = haai.PassportNbr,
                IsEmployedID = haai.IsEmployedID,
                EmployerPhoneNbr = haai.EmployerPhoneNbr,
                EmployedDTM = haai.EmployedDTM,
                IsStudentID = haai.IsStudentID,
                SchoolPhoneNbr = haai.SchoolPhoneNbr,
                SchoolAddressID = @CopySchoolAddressID,
                SchoolLastAttendDTM = haai.SchoolLastAttendDTM,
                ContactPhoneCountryCode = haai.ContactPhoneCountryCode,
                ContactPhoneNbr = haai.ContactPhoneNbr,
                ContactPhoneNbrTypeID = haai.ContactPhoneNbrTypeID,
                ContactPhone2CountryCode = haai.ContactPhone2CountryCode,
                ContactPhone2Nbr = haai.ContactPhone2Nbr,
                ContactPhone2NbrTypeID = haai.ContactPhone2NbrTypeID,
                AltAddressID = @CopyAltAddress,
                SchoolName = haai.SchoolName,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName,
				IsAnotherPhoneID = haai.IsAnotherPhoneID,
				IsAnotherAddressID = haai.IsAnotherAddressID
            FROM dbo.HumanAddlInfo hai
                INNER JOIN dbo.humanActualAddlInfo haai
                    ON hai.HumanAdditionalInfo = haai.HumanActualAddlInfoUID
            WHERE hai.HumanAdditionalInfo = @HumanID;

			insert into @HumanAddlInfoAfterEdit
			(
				HumanID,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
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
				SchoolName,
				IsAnotherPhoneID,
				IsAnotherAddressID
			)
            SELECT
				HumanAdditionalInfo,
				PassportNbr,
                IsEmployedID,
                EmployerPhoneNbr,
                EmployedDTM,
                IsStudentID,
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
                SchoolName,
				IsAnotherPhoneID,
				IsAnotherAddressID
            FROM dbo.HumanAddlInfo hai
            WHERE hai.HumanAdditionalInfo = @HumanID;

			--AltAddressID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000130,
                   a.HumanID,
                   NULL,
                   b.AltAddressID,
                   a.AltAddressID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.AltAddressID <> b.AltAddressID)
                  OR (
                         a.AltAddressID IS NOT NULL
                         AND b.AltAddressID IS NULL
                     )
                  OR (
                         a.AltAddressID IS NULL
                         AND b.AltAddressID IS NOT NULL
                     );

			--PassportNbr
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000131,
                   a.HumanID,
                   NULL,
                   b.PassportNbr,
                   a.PassportNbr
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.PassportNbr <> b.PassportNbr)
                  OR (
                         a.PassportNbr IS NOT NULL
                         AND b.PassportNbr IS NULL
                     )
                  OR (
                         a.PassportNbr IS NULL
                         AND b.PassportNbr IS NOT NULL
                     );

			--IsEmployedID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000132,
                   a.HumanID,
                   NULL,
                   b.IsEmployedID,
                   a.IsEmployedID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.IsEmployedID <> b.IsEmployedID)
                  OR (
                         a.IsEmployedID IS NOT NULL
                         AND b.IsEmployedID IS NULL
                     )
                  OR (
                         a.IsEmployedID IS NULL
                         AND b.IsEmployedID IS NOT NULL
                     );

			--IsStudentID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000133,
                   a.HumanID,
                   NULL,
                   b.IsStudentID,
                   a.IsStudentID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.IsStudentID <> b.IsStudentID)
                  OR (
                         a.IsStudentID IS NOT NULL
                         AND b.IsStudentID IS NULL
                     )
                  OR (
                         a.IsStudentID IS NULL
                         AND b.IsStudentID IS NOT NULL
                     );

			--EmployerPhoneNbr
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000134,
                   a.HumanID,
                   NULL,
                   b.EmployerPhoneNbr,
                   a.EmployerPhoneNbr
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.EmployerPhoneNbr <> b.EmployerPhoneNbr)
                  OR (
                         a.EmployerPhoneNbr IS NOT NULL
                         AND b.EmployerPhoneNbr IS NULL
                     )
                  OR (
                         a.EmployerPhoneNbr IS NULL
                         AND b.EmployerPhoneNbr IS NOT NULL
                     );

			--EmployedDTM
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000135,
                   a.HumanID,
                   NULL,
                   b.EmployedDTM,
                   a.EmployedDTM
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.EmployedDTM <> b.EmployedDTM)
                  OR (
                         a.EmployedDTM IS NOT NULL
                         AND b.EmployedDTM IS NULL
                     )
                  OR (
                         a.EmployedDTM IS NULL
                         AND b.EmployedDTM IS NOT NULL
                     );

			--SchoolName
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000136,
                   a.HumanID,
                   NULL,
                   b.SchoolName,
                   a.SchoolName
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.SchoolName <> b.SchoolName)
                  OR (
                         a.SchoolName IS NOT NULL
                         AND b.SchoolName IS NULL
                     )
                  OR (
                         a.SchoolName IS NULL
                         AND b.SchoolName IS NOT NULL
                     );

			--SchoolPhoneNbr
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000137,
                   a.HumanID,
                   NULL,
                   b.SchoolPhoneNbr,
                   a.SchoolPhoneNbr
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.SchoolPhoneNbr <> b.SchoolPhoneNbr)
                  OR (
                         a.SchoolPhoneNbr IS NOT NULL
                         AND b.SchoolPhoneNbr IS NULL
                     )
                  OR (
                         a.SchoolPhoneNbr IS NULL
                         AND b.SchoolPhoneNbr IS NOT NULL
                     );

			--SchoolLastAttendDTM
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000138,
                   a.HumanID,
                   NULL,
                   b.SchoolLastAttendDTM,
                   a.SchoolLastAttendDTM
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.SchoolLastAttendDTM <> b.SchoolLastAttendDTM)
                  OR (
                         a.SchoolLastAttendDTM IS NOT NULL
                         AND b.SchoolLastAttendDTM IS NULL
                     )
                  OR (
                         a.SchoolLastAttendDTM IS NULL
                         AND b.SchoolLastAttendDTM IS NOT NULL
                     );

			--ContactPhone2Nbr
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000139,
                   a.HumanID,
                   NULL,
                   b.ContactPhone2Nbr,
                   a.ContactPhone2Nbr
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.ContactPhone2Nbr <> b.ContactPhone2Nbr)
                  OR (
                         a.ContactPhone2Nbr IS NOT NULL
                         AND b.ContactPhone2Nbr IS NULL
                     )
                  OR (
                         a.ContactPhone2Nbr IS NULL
                         AND b.ContactPhone2Nbr IS NOT NULL
                     );

			--ContactPhone2NbrTypeID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000140,
                   a.HumanID,
                   NULL,
                   b.ContactPhone2NbrTypeID,
                   a.ContactPhone2NbrTypeID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.ContactPhone2NbrTypeID <> b.ContactPhone2NbrTypeID)
                  OR (
                         a.ContactPhone2NbrTypeID IS NOT NULL
                         AND b.ContactPhone2NbrTypeID IS NULL
                     )
                  OR (
                         a.ContactPhone2NbrTypeID IS NULL
                         AND b.ContactPhone2NbrTypeID IS NOT NULL
                     );

			--ContactPhone2CountryCode
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000141,
                   a.HumanID,
                   NULL,
                   b.ContactPhone2NbrTypeID,
                   a.ContactPhone2NbrTypeID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.ContactPhone2CountryCode <> b.ContactPhone2CountryCode)
                  OR (
                         a.ContactPhone2CountryCode IS NOT NULL
                         AND b.ContactPhone2CountryCode IS NULL
                     )
                  OR (
                         a.ContactPhone2CountryCode IS NULL
                         AND b.ContactPhone2CountryCode IS NOT NULL
                     );

			--ContactPhoneCountryCode
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586890000003,
                   a.HumanID,
                   NULL,
                   b.ContactPhoneCountryCode,
                   a.ContactPhoneCountryCode
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
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

			--ContactPhoneNbr
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586890000004,
                   a.HumanID,
                   NULL,
                   b.ContactPhoneCountryCode,
                   a.ContactPhoneCountryCode
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.ContactPhoneNbr <> b.ContactPhoneNbr)
                  OR (
                         a.ContactPhoneNbr IS NOT NULL
                         AND b.ContactPhoneNbr IS NULL
                     )
                  OR (
                         a.ContactPhoneNbr IS NULL
                         AND b.ContactPhoneNbr IS NOT NULL
                     );

			--ContactPhoneNbrTypeID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586890000005,
                   a.HumanID,
                   NULL,
                   b.ContactPhoneCountryCode,
                   a.ContactPhoneCountryCode
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.ContactPhoneNbrTypeID <> b.ContactPhoneNbrTypeID)
                  OR (
                         a.ContactPhoneNbrTypeID IS NOT NULL
                         AND b.ContactPhoneNbrTypeID IS NULL
                     )
                  OR (
                         a.ContactPhoneNbrTypeID IS NULL
                         AND b.ContactPhoneNbrTypeID IS NOT NULL
                     );

			--IsAnotherPhoneID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000126,
                   a.HumanID,
                   NULL,
                   b.IsAnotherPhoneID,
                   a.IsAnotherPhoneID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.IsAnotherPhoneID <> b.IsAnotherPhoneID)
                  OR (
                         a.IsAnotherPhoneID IS NOT NULL
                         AND b.IsAnotherPhoneID IS NULL
                     )
                  OR (
                         a.IsAnotherPhoneID IS NULL
                         AND b.IsAnotherPhoneID IS NOT NULL
                     );

			--IsAnotherAddressID
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @DataAuditEventID,
                   @ObjectTable_HumanAddlInfo,
                   51586990000127,
                   a.HumanID,
                   NULL,
                   b.IsAnotherAddressID,
                   a.IsAnotherAddressID
            FROM @HumanAddlInfoAfterEdit AS a
                FULL JOIN @HumanAddlInfoBeforeEdit AS b
                    ON a.HumanID = b.HumanID
            WHERE (a.IsAnotherAddressID <> b.IsAnotherAddressID)
                  OR (
                         a.IsAnotherAddressID IS NOT NULL
                         AND b.IsAnotherAddressID IS NULL
                     )
                  OR (
                         a.IsAnotherAddressID IS NULL
                         AND b.IsAnotherAddressID IS NOT NULL
                     );

        END
        ELSE
        BEGIN
            INSERT INTO dbo.HumanAddlInfo
            (
                HumanAdditionalInfo,
                ReportedAge,
                ReportedAgeUOMID,
                ReportedAgeDTM,
                PassportNbr,
                IsEmployedID,
                EmployerPhoneNbr,
                EmployedDTM,
                IsStudentID,
                SchoolPhoneNbr,
                SchoolAddressID,
                SchoolLastAttendDTM,
                ContactPhoneCountryCode,
                ContactPhoneNbr,
                ContactPhoneNbrTypeID,
                ContactPhone2CountryCode,
                ContactPhone2Nbr,
                ContactPhone2NbrTypeID,
                SchoolName,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser,
				AltAddressID,
				IsAnotherPhoneID,
				IsAnotherAddressID
            )
            SELECT @HumanID,
                   NULL,
                   NULL,
                   NULL,
                   PassportNbr,
                   IsEmployedID,
                   EmployerPhoneNbr,
                   EmployedDTM,
                   IsStudentID,
                   SchoolPhoneNbr,
                   @CopySchoolAddressID,
                   SchoolLastAttendDTM,
                   ContactPhoneCountryCode,
                   ContactPhoneNbr,
                   ContactPhoneNbrTypeID,
                   ContactPhone2CountryCode,
                   ContactPhone2Nbr,
                   ContactPhone2NbrTypeID,
                   SchoolName,
                   intRowStatus,
                   GETDATE(),
                   @AuditUserName,
				   @CopyAltAddress,
				   IsAnotherPhoneID,
				   IsAnotherAddressID
            FROM dbo.humanActualAddlInfo
            WHERE HumanActualAddlInfoUID = @HumanActualID;

            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            VALUES
            (
                @DataAuditEventID, 
                @ObjectTable_HumanAddlInfo, 
                @HumanID
            );

        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
