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
        @RootCurrentResidenceAddressID BIGINT,
        @RootEmployerAddressID BIGINT,
        @RootRegistrationAddressID BIGINT,
        @RootSchoolAddressID BIGINT,
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
BEGIN
    BEGIN TRY
        SELECT @CurrentResidenceAddressID = idfCurrentResidenceAddress,
               @EmployerAddressID = idfEmployerAddress,
               @RegistrationAddressID = idfRegistrationAddress
        FROM dbo.tlbHumanActual
        WHERE idfHumanActual = @HumanActualID;

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

        -- Get ID for root idfCurrentResidenceAddress
        SET @RootCurrentResidenceAddressID = NULL;
        SELECT @RootCurrentResidenceAddressID = dbo.tlbHuman.idfCurrentResidenceAddress
        FROM dbo.tlbHuman
        WHERE dbo.tlbHuman.idfHuman = @HumanID;

        IF @RootCurrentResidenceAddressID IS NULL
           AND NOT @CurrentResidenceAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @RootCurrentResidenceAddressID OUTPUT;

            -- Copy address for root human
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @CurrentResidenceAddressID,
                                                   @RootCurrentResidenceAddressID,
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

        -- Get ID for root idfEmployerAddress
        SET @RootEmployerAddressID = NULL;
        SELECT @RootEmployerAddressID = dbo.tlbHuman.idfEmployerAddress
        FROM dbo.tlbHuman
        WHERE dbo.tlbHuman.idfHuman = @HumanID;

        IF @RootEmployerAddressID IS NULL
           AND NOT @EmployerAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @RootEmployerAddressID OUTPUT;

            -- Copy address for employer
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @EmployerAddressID,
                                                   @RootEmployerAddressID,
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

        -- Get ID for root idfRegistrationAddress
        SET @RootRegistrationAddressID = NULL;
        SELECT @RootRegistrationAddressID = dbo.tlbHuman.idfRegistrationAddress
        FROM dbo.tlbHuman
        WHERE dbo.tlbHuman.idfHumanActual = @HumanID;

        IF @RootRegistrationAddressID IS NULL
           AND NOT @RegistrationAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @RootRegistrationAddressID OUTPUT;

            -- Copy registration address
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @RegistrationAddressID,
                                                   @RootRegistrationAddressID,
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
                idfCurrentResidenceAddress = @RootCurrentResidenceAddressID,
                idfEmployerAddress = @RootEmployerAddressID,
                idfRegistrationAddress = @RootRegistrationAddressID,
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
                   @RootCurrentResidenceAddressID,
                   @RootEmployerAddressID,
                   @RootRegistrationAddressID,
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

        -- Get id for root idfSchoolAddress
        SET @RootSchoolAddressID = NULL;
        SELECT @RootSchoolAddressID = dbo.HumanAddlInfo.SchoolAddressID
        FROM dbo.HumanAddlInfo
        WHERE dbo.HumanAddlInfo.HumanAdditionalInfo = @HumanID;

        IF @RootSchoolAddressID IS NULL
           AND NOT @SchoolAddressID IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @RootSchoolAddressID OUTPUT

            -- Copy addresses for root human
            EXEC dbo.USSP_GBL_COPY_GEOLOCATION_SET @SchoolAddressID,
                                                   @RootSchoolAddressID,
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

        IF EXISTS
        (
            SELECT *
            FROM dbo.HumanAddlInfo
            WHERE HumanAdditionalInfo = @HumanID
        )
        BEGIN
            UPDATE dbo.HumanAddlInfo
            SET ReportedAge = haai.ReportedAge,
                ReportedAgeUOMID = haai.ReportedAgeUOMID,
                ReportedAgeDTM = haai.ReportedAgeDTM,
                PassportNbr = haai.PassportNbr,
                IsEmployedID = haai.IsEmployedID,
                EmployerPhoneNbr = haai.EmployerPhoneNbr,
                EmployedDTM = haai.EmployedDTM,
                IsStudentID = haai.IsStudentID,
                SchoolPhoneNbr = haai.SchoolPhoneNbr,
                SchoolAddressID = haai.SchoolAddressID,
                SchoolLastAttendDTM = haai.SchoolLastAttendDTM,
                ContactPhoneCountryCode = haai.ContactPhoneCountryCode,
                ContactPhoneNbr = haai.ContactPhoneNbr,
                ContactPhoneNbrTypeID = haai.ContactPhoneNbrTypeID,
                ContactPhone2CountryCode = haai.ContactPhone2CountryCode,
                ContactPhone2Nbr = haai.ContactPhone2Nbr,
                ContactPhone2NbrTypeID = haai.ContactPhone2NbrTypeID,
                AltAddressID = haai.AltAddressID,
                SchoolName = haai.SchoolName,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            FROM dbo.HumanAddlInfo hai
                INNER JOIN dbo.humanActualAddlInfo haai
                    ON hai.HumanAdditionalInfo = haai.HumanActualAddlInfoUID
            WHERE hai.HumanAdditionalInfo = @HumanID;
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
                AuditCreateUser
            )
            SELECT @HumanID,
                   ReportedAge,
                   ReportedAgeUOMID,
                   ReportedAgeDTM,
                   PassportNbr,
                   IsEmployedID,
                   EmployerPhoneNbr,
                   EmployedDTM,
                   IsStudentID,
                   SchoolPhoneNbr,
                   @RootSchoolAddressID,
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
                   @AuditUserName
            FROM dbo.humanActualAddlInfo
            WHERE HumanActualAddlInfoUID = @HumanActualID;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
