-- ================================================================================================
-- Name: USSP_HUM_DISEASE_VACCINATION_SET
--
-- Description: Add, update and delete human disease report vaccination records.
--          
-- Author: Harold Arnold
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/21/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long     11/29/2022 Added delete data audit logic.
-- Stephen Long     12/01/2022 Added EIDSS object ID; smart key that represents the parent object.
--
-- Testing code:
-- exec USSP_HUMAN_DISEASE_VACCINATIONS_SET null
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HUM_DISEASE_VACCINATION_SET]
    @HumanDiseaseReportID BIGINT = NULL,
    @VaccinationsParameters NVARCHAR(MAX) = NULL,
    @OutbreakCall INT = 0,
    @AuditUserName NVARCHAR(100) = '',
    @DataAuditEventID BIGINT = NULL, 
    @EIDSSObjectID NVARCHAR(200) = NULL 
AS
DECLARE @HumanDiseaseReportVaccinationUID BIGINT,
        @VaccinationName NVARCHAR(200),
        @VaccinationDate DATETIME2 = NULL,
        @intRowStatus INT = NULL,
        @RowAction NVARCHAR(1),
        @RowID BIGINT,
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 53577590000000, -- HumanDiseaseReportVaccination
        @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
DECLARE @VaccinationsTemp TABLE
(
    vaccinationID INT NULL,
    humanDiseaseReportVaccinationUID BIGINT NULL,
    idfHumanCase BIGINT NULL,
    vaccinationName NVARCHAR(200) NULL,
    vaccinationDate DATETIME2 NULL,
    rowAction NVARCHAR(1) NULL, 
    intRowStatus INT
);
DECLARE @VaccinationsBeforeEdit TABLE
(
    VaccinationID BIGINT,
    VaccinationName NVARCHAR(200),
    VaccinationDate DATETIME2,
    RowStatus INT
);
DECLARE @VaccinationsAfterEdit TABLE
(
    VaccinationID BIGINT,
    VaccinationName NVARCHAR(200),
    VaccinationDate DATETIME2,
    RowStatus INT
);
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        INSERT INTO @VaccinationsTemp
        SELECT *
        FROM
            OPENJSON(@VaccinationsParameters)
            WITH
            (
                vaccinationID INT, 
                humanDiseaseReportVaccinationUID BIGINT,
                idfHumanCase BIGINT,
                vaccinationName NVARCHAR(200),
                vaccinationDate DATETIME2,
                rowAction NVARCHAR(1), 
                intRowStatus INT 
            );

        WHILE EXISTS (SELECT * FROM @VaccinationsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = humanDiseaseReportVaccinationUID,
                @HumanDiseaseReportVaccinationUID = humanDiseaseReportVaccinationUID,
                @VaccinationName = vaccinationName,
                @VaccinationDate = vaccinationDate,
                @RowAction = rowAction, 
                @intRowStatus = intRowStatus 
            FROM @VaccinationsTemp;

            IF NOT EXISTS
            (
                SELECT HumanDiseaseReportVaccinationUID
                FROM dbo.HumanDiseaseReportVaccination
                WHERE HumanDiseaseReportVaccinationUID = @HumanDiseaseReportVaccinationUID
            )
            BEGIN
                IF @OutbreakCall = 1
                BEGIN
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'HumanDiseaseReportVaccination',
                                                   @HumanDiseaseReportVaccinationUID OUTPUT;
                END
                ELSE
                BEGIN
                    INSERT INTO @SuppressSelect
                    EXEC dbo.USP_GBL_NEXTKEYID_GET 'HumanDiseaseReportVaccination',
                                                   @HumanDiseaseReportVaccinationUID OUTPUT;
                END

                INSERT INTO dbo.HumanDiseaseReportVaccination
                (
                    HumanDiseaseReportVaccinationUID,
                    idfHumanCase,
                    VaccinationName,
                    VaccinationDate,
                    intRowStatus,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (   @HumanDiseaseReportVaccinationUID,
                    @HumanDiseaseReportID,
                    @VaccinationName,
                    @VaccinationDate,
                    0, --Always 0, because this is a new record
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
                 @HumanDiseaseReportVaccinationUID,
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
                -- Data audit
                DELETE FROM @VaccinationsAfterEdit;
                DELETE FROM @VaccinationsBeforeEdit;

                INSERT INTO @VaccinationsBeforeEdit
                (
                    VaccinationID,
                    VaccinationDate,
                    VaccinationName,
                    RowStatus
                )
                SELECT HumanDiseaseReportVaccinationUID,
                       VaccinationDate,
                       VaccinationName,
                       intRowStatus
                FROM dbo.HumanDiseaseReportVaccination
                WHERE HumanDiseaseReportVaccinationUID = @HumanDiseaseReportVaccinationUID;
                -- End data audit 

                UPDATE dbo.HumanDiseaseReportVaccination
                SET VaccinationName = @VaccinationName,
                    VaccinationDate = @VaccinationDate,
                    intRowStatus = @intRowStatus,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE HumanDiseaseReportVaccinationUID = @HumanDiseaseReportVaccinationUID;

                -- Data audit
                INSERT INTO @VaccinationsAfterEdit
                (
                    VaccinationID,
                    VaccinationDate,
                    VaccinationName,
                    RowStatus
                )
                SELECT HumanDiseaseReportVaccinationUID,
                       VaccinationDate,
                       VaccinationName,
                       intRowStatus
                FROM dbo.HumanDiseaseReportVaccination
                WHERE HumanDiseaseReportVaccinationUID = @HumanDiseaseReportVaccinationUID;

                IF @intRowStatus = 0
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
                           51586690000002,
                           a.VaccinationID,
                           NULL,
                           b.VaccinationDate,
                           a.VaccinationDate,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @VaccinationsAfterEdit AS a
                        FULL JOIN @VaccinationsAfterEdit AS b
                            ON a.VaccinationID = b.VaccinationID
                    WHERE (a.VaccinationDate <> b.VaccinationDate)
                          OR (
                                 a.VaccinationDate IS NOT NULL
                                 AND b.VaccinationDate IS NULL
                             )
                          OR (
                                 a.VaccinationDate IS NULL
                                 AND b.VaccinationDate IS NOT NULL
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
                           51586690000001,
                           a.VaccinationID,
                           NULL,
                           b.VaccinationName,
                           a.VaccinationName,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @VaccinationsAfterEdit AS a
                        FULL JOIN @VaccinationsBeforeEdit AS b
                            ON a.VaccinationID = b.VaccinationID
                    WHERE (a.VaccinationName <> b.VaccinationName)
                          OR (
                                 a.VaccinationName IS NOT NULL
                                 AND b.VaccinationName IS NULL
                             )
                          OR (
                                 a.VaccinationName IS NULL
                                 AND b.VaccinationName IS NOT NULL
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
                    (@DataAuditEventID, @ObjectTableID, @HumanDiseaseReportVaccinationUID, @AuditUserName, @EIDSSObjectID);
                END
            -- End data audit
            END

            SET ROWCOUNT 1;
            DELETE FROM @VaccinationsTemp;
            SET ROWCOUNT 0;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
