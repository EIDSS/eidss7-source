-- ================================================================================================
-- Name: USSP_HUM_ANTIVIRAL_THERAPIES_SET
--
-- Description: Add or update human disease report anti-viral therapies
--          
-- Author: Harold Prior
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Stephen Long             11/21/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long             11/29/2022 Added delete data audit logic.
-- Stephen Long             12/01/2022 Added EIDSS object ID; smart key that represents the parent 
--                                     object.
--
-- Testing code:
-- exec USSP_HUM_ANTIVIRAL_THERAPIES_SET NULL
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HUM_ANTIVIRAL_THERAPIES_SET]
    @HumanDiseaseReportID BIGINT = NULL,
    @AntiviralTherapiesParameters NVARCHAR(MAX) = NULL,
    @OutbreakCall INT = 0,
    @AuditUserName NVARCHAR(200) = '',
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL 
AS
DECLARE @AntimicrobialTherapyID BIGINT = NULL,
        @FirstAdministeredDate DATETIME2 = NULL,
        @AntimicrobialTherapyName NVARCHAR(200),
        @Dosage NVARCHAR(200),
        @RowAction NVARCHAR(1),
        @RowStatus INT = 0,
        @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75470000000; -- tlbAntimicrobialTherapy
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(MAX)
);
DECLARE @AntiviralTherapiesTemp TABLE
(
    idfAntimicrobialTherapy BIGINT NULL,
    idfHumanCase BIGINT NULL,
    datFirstAdministeredDate DATETIME2 NULL,
    strAntimicrobialTherapyName NVARCHAR(200) NULL,
    strDosage NVARCHAR(200) NULL,
    rowAction NVARCHAR(1) NULL
);
DECLARE @AntiviralTherapiesBeforeEdit TABLE
(
    AntimicrobialTherapyID BIGINT,
    HumanDiseaseReportID BIGINT,
    FirstAdministeredDate DATETIME2,
    AntimicrobialTherapyName NVARCHAR(200),
    Dosage NVARCHAR(200),
    RowStatus INT
);
DECLARE @AntiviralTherapiesAfterEdit TABLE
(
    AntimicrobialTherapyID BIGINT,
    HumanDiseaseReportID BIGINT,
    FirstAdministeredDate DATETIME2,
    AntimicrobialTherapyName NVARCHAR(200),
    Dosage NVARCHAR(200),
    RowStatus INT
);
BEGIN
    SET NOCOUNT ON;

    INSERT INTO @AntiviralTherapiesTemp
    SELECT *
    FROM
        OPENJSON(@AntiviralTherapiesParameters)
        WITH
        (
            idfAntimicrobialTherapy BIGINT,
            idfHumanCase BIGINT,
            datFirstAdministeredDate DATETIME2,
            strAntimicrobialTherapyName NVARCHAR(200),
            strDosage NVARCHAR(200),
            rowAction NVARCHAR(1)
        );

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        WHILE EXISTS (SELECT * FROM @AntiviralTherapiesTemp)
        BEGIN
            SELECT TOP 1
                @AntimicrobialTherapyID = idfAntimicrobialTherapy,
                @FirstAdministeredDate = datFirstAdministeredDate,
                @AntimicrobialTherapyName = strAntimicrobialTherapyName,
                @Dosage = strDosage,
                @RowAction = rowAction
            FROM @AntiviralTherapiesTemp

            IF NOT EXISTS
            (
                SELECT TOP 1
                    idfAntimicrobialTherapy
                FROM dbo.tlbAntimicrobialTherapy
                WHERE idfAntimicrobialTherapy = @AntimicrobialTherapyID
            )
            BEGIN
                IF @OutbreakCall = 1
                BEGIN
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAntimicrobialTherapy',
                                                   @AntimicrobialTherapyID OUTPUT;
                END
                ELSE
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAntimicrobialTherapy',
                                                   @AntimicrobialTherapyID OUTPUT;
                END

                INSERT INTO dbo.tlbAntimicrobialTherapy
                (
                    idfAntimicrobialTherapy,
                    idfHumanCase,
                    datFirstAdministeredDate,
                    strAntimicrobialTherapyName,
                    strDosage,
                    intRowStatus,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@AntimicrobialTherapyID,
                 @HumanDiseaseReportID,
                 @FirstAdministeredDate,
                 @AntimicrobialTherapyName,
                 @Dosage,
                 0  ,
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
                 @ObjectTableID,
                 @AntimicrobialTherapyID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSObjectID
                );
            -- End data audit
            END
            ELSE
            BEGIN
                IF @RowAction = 'D'
                BEGIN
                    SET @RowStatus = 1;
                END
                ELSE
                BEGIN
                    SET @RowStatus = 0;
                END

                DELETE FROM @AntiviralTherapiesAfterEdit;
                DELETE FROM @AntiviralTherapiesBeforeEdit;

                INSERT INTO @AntiviralTherapiesBeforeEdit
                (
                    AntimicrobialTherapyID,
                    HumanDiseaseReportID,
                    FirstAdministeredDate,
                    AntimicrobialTherapyName,
                    Dosage,
                    RowStatus
                )
                SELECT idfAntimicrobialTherapy,
                       idfHumanCase,
                       datFirstAdministeredDate,
                       strAntimicrobialTherapyName,
                       strDosage,
                       intRowStatus
                FROM dbo.tlbAntimicrobialTherapy
                WHERE idfAntimicrobialTherapy = @AntimicrobialTherapyID;

                UPDATE dbo.tlbAntimicrobialTherapy
                SET idfHumanCase = @HumanDiseaseReportID,
                    datFirstAdministeredDate = @FirstAdministeredDate,
                    strAntimicrobialTherapyName = @AntimicrobialTherapyName,
                    strDosage = @Dosage,
                    intRowStatus = @RowStatus,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfAntimicrobialTherapy = @AntimicrobialTherapyID
                      AND intRowStatus = 0;

                INSERT INTO @AntiviralTherapiesAfterEdit
                (
                    AntimicrobialTherapyID,
                    HumanDiseaseReportID,
                    FirstAdministeredDate,
                    AntimicrobialTherapyName,
                    Dosage,
                    RowStatus
                )
                SELECT idfAntimicrobialTherapy,
                       idfHumanCase,
                       datFirstAdministeredDate,
                       strAntimicrobialTherapyName,
                       strDosage,
                       intRowStatus
                FROM dbo.tlbAntimicrobialTherapy
                WHERE idfAntimicrobialTherapy = @AntimicrobialTherapyID;

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
                           @ObjectTableID,
                           4577800000000,
                           a.AntimicrobialTherapyID,
                           NULL,
                           b.HumanDiseaseReportID,
                           a.HumanDiseaseReportID,
                           @AuditUserName, 
                           @EIDSSObjectID
                    FROM @AntiviralTherapiesAfterEdit AS a
                        FULL JOIN @AntiviralTherapiesBeforeEdit AS b
                            ON a.AntimicrobialTherapyID = b.AntimicrobialTherapyID
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
                           @ObjectTableID,
                           78350000000,
                           a.AntimicrobialTherapyID,
                           NULL,
                           b.FirstAdministeredDate,
                           a.FirstAdministeredDate,
                           @AuditUserName, 
                           @EIDSSObjectID
                    FROM @AntiviralTherapiesAfterEdit AS a
                        FULL JOIN @AntiviralTherapiesBeforeEdit AS b
                            ON a.AntimicrobialTherapyID = b.AntimicrobialTherapyID
                    WHERE (a.FirstAdministeredDate <> b.FirstAdministeredDate)
                          OR (
                                 a.FirstAdministeredDate IS NOT NULL
                                 AND b.FirstAdministeredDate IS NULL
                             )
                          OR (
                                 a.FirstAdministeredDate IS NULL
                                 AND b.FirstAdministeredDate IS NOT NULL
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
                           @ObjectTableID,
                           78360000000,
                           a.AntimicrobialTherapyID,
                           NULL,
                           b.AntimicrobialTherapyName,
                           a.AntimicrobialTherapyName,
                           @AuditUserName, 
                           @EIDSSObjectID
                    FROM @AntiviralTherapiesAfterEdit AS a
                        FULL JOIN @AntiviralTherapiesBeforeEdit AS b
                            ON a.AntimicrobialTherapyID = b.AntimicrobialTherapyID
                    WHERE (a.AntimicrobialTherapyName <> b.AntimicrobialTherapyName)
                          OR (
                                 a.AntimicrobialTherapyName IS NOT NULL
                                 AND b.AntimicrobialTherapyName IS NULL
                             )
                          OR (
                                 a.AntimicrobialTherapyName IS NULL
                                 AND b.AntimicrobialTherapyName IS NOT NULL
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
                           @ObjectTableID,
                           4577810000000,
                           a.AntimicrobialTherapyID,
                           NULL,
                           b.Dosage,
                           a.Dosage,
                           @AuditUserName, 
                           @EIDSSObjectID
                    FROM @AntiviralTherapiesAfterEdit AS a
                        FULL JOIN @AntiviralTherapiesBeforeEdit AS b
                            ON a.AntimicrobialTherapyID = b.AntimicrobialTherapyID
                    WHERE (a.Dosage <> b.Dosage)
                          OR (
                                 a.Dosage IS NOT NULL
                                 AND b.Dosage IS NULL
                             )
                          OR (
                                 a.Dosage IS NULL
                                 AND b.Dosage IS NOT NULL
                             );

                    INSERT INTO dbo.tauDataAuditDetailRestore
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        idfObjectDetail,
                        AuditCreateUser, 
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectTableID,
                           a.AntimicrobialTherapyID,
                           NULL,
                           @AuditUserName, 
                           @EIDSSObjectID
                    FROM @AntiviralTherapiesAfterEdit AS a
                        FULL JOIN @AntiviralTherapiesBeforeEdit AS b
                            ON a.AntimicrobialTherapyID = b.AntimicrobialTherapyID
                    WHERE a.RowStatus = 0
                          AND b.RowStatus = 1;
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
                    (@DataAuditEventid, @ObjectTableID, @AntimicrobialTherapyID, @AuditUserName, @EIDSSObjectID);
                END
            END

            SET ROWCOUNT 1;
            DELETE FROM @AntiviralTherapiesTemp;
            SET ROWCOUNT 0;
        END

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
