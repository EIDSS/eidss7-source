-- ================================================================================================
-- Name: USP_CONF_HumanAggregateCaseMatrixVersion_SET
--
-- Description: Saves Entries For Human Aggregate Case Matrix Version
--
-- Author: Lamont Mitchell
-- 
-- Revision History:
-- Name                    Date       Change Detail
-- ----------------------- ---------- ------------------------------------------------------------
-- Lamont Mitchell         01/24/2019 Initial Created
-- Stephen Long            08/17/2022 Renamed to meet standard, and added site alert logic.
-- Ann Xiong			   02/21/2023 Implemented Data Audit
-- Stephen Long            04/17/2023 Fix to not add a site alert when event type ID is null.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_HumanAggregateCaseMatrixVersion_SET]
    @idfVersion BIGINT = NULL,
    @idfsMatrixType BIGINT,
    @datStartDate DATETIME,
    @MatrixName NVARCHAR(200),
    @blnIsActive BIT = 0,
    @blnIsDefault BIT = 0,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
AS
BEGIN
    DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
            @ReturnCode BIGINT = 0,
            @idfsReferenceType BIGINT,
            @EventId BIGINT = -1,
            @EventSiteId BIGINT = @SiteId,
            @EventUserId BIGINT = @UserId,
            @EventDiseaseId BIGINT = NULL,
            @EventLocationId BIGINT = @LocationId,
            @EventInformationString NVARCHAR(MAX) = NULL,
            @EventLoginSiteId BIGINT = @SiteId;
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(200)
    );

    -- Data audit
    DECLARE @idfUserId BIGINT = NULL,
            @idfSiteId BIGINT = NULL,
            @idfsDataAuditEventType bigint = NULL,
            @idfsObjectType bigint = 10017003, -- Matrix for Aggregate Reports
            @idfObject bigint = @idfVersion,
            @idfDataAuditEvent bigint = NULL,
            @idfObjectTable_tlbAggrMatrixVersionHeader bigint = 707330000000;
    DECLARE @tlbAggrMatrixVersionHeader_BeforeEdit TABLE
    (
        VersionID BIGINT,
        MatrixName VARCHAR(200),
        StartDate DATETIME,
        IsActive BIT,
        IsDefault BIT
    );
    DECLARE @tlbAggrMatrixVersionHeader_AfterEdit TABLE
    (
        VersionID BIGINT,
        MatrixName VARCHAR(200),
        StartDate DATETIME,
        IsActive BIT,
        IsDefault BIT
    );

    -- Get and Set UserId and SiteId
    SELECT @idfUserId = userInfo.UserId,
           @idfSiteId = userInfo.SiteId
    FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
    -- End data audit

    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrMatrixVersionHeader
            WHERE idfVersion = @idfVersion
        )
        BEGIN
            IF @blnIsActive = 1
            BEGIN
                UPDATE dbo.tlbAggrMatrixVersionHeader
                SET blnIsActive = 0,
                    blnIsDefault = 0,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsMatrixType = @idfsMatrixType;
            END

            -- Data audit
            INSERT INTO @tlbAggrMatrixVersionHeader_BeforeEdit
            (
                VersionID,
                MatrixName,
                StartDate,
                IsActive,
                IsDefault
            )
            SELECT idfVersion,
                   MatrixName,
                   datStartDate,
                   blnIsActive,
                   blnIsDefault
            FROM dbo.tlbAggrMatrixVersionHeader
            WHERE idfVersion = @idfVersion
            -- End data audit

            UPDATE dbo.tlbAggrMatrixVersionHeader
            SET MatrixName = @MatrixName,
                datStartDate = @datStartDate,
                blnIsActive = @blnIsActive,
                intRowStatus = 0,
                blnIsDefault = @blnIsDefault,
                strMaintenanceFlag = NULL,
                strReservedAttribute = NULL,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfVersion = @idfVersion;

            -- Data audit
            INSERT INTO @tlbAggrMatrixVersionHeader_AfterEdit
            (
                VersionID,
                MatrixName,
                StartDate,
                IsActive,
                IsDefault
            )
            SELECT idfVersion,
                   MatrixName,
                   datStartDate,
                   blnIsActive,
                   blnIsDefault
            FROM dbo.tlbAggrMatrixVersionHeader
            WHERE idfVersion = @idfVersion;

            --  tauDataAuditEvent  Event Type- Edit 
            SET @idfsDataAuditEventType = 10016003;
            -- insert record into tauDataAuditEvent - 
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserId,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfVersion,
                                                 @idfObjectTable_tlbAggrMatrixVersionHeader,
                                                 @idfDataAuditEvent OUTPUT;

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
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrMatrixVersionHeader,
                   707360000000,
                   a.VersionID,
                   NULL,
                   a.MatrixName,
                   b.MatrixName
            FROM @tlbAggrMatrixVersionHeader_BeforeEdit a
                INNER JOIN @tlbAggrMatrixVersionHeader_AfterEdit b
                    ON a.VersionID = b.VersionID
            WHERE (a.MatrixName <> b.MatrixName)
                  OR (
                         a.MatrixName IS NOT NULL
                         AND b.MatrixName IS NULL
                     )
                  OR (
                         a.MatrixName IS NULL
                         AND b.MatrixName IS NOT NULL
                     );

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
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrMatrixVersionHeader,
                   707370000000,
                   a.VersionID,
                   NULL,
                   a.StartDate,
                   b.StartDate
            FROM @tlbAggrMatrixVersionHeader_BeforeEdit a
                INNER JOIN @tlbAggrMatrixVersionHeader_AfterEdit b
                    ON a.VersionID = b.VersionID
            WHERE (a.StartDate <> b.StartDate)
                  OR (
                         a.StartDate IS NOT NULL
                         AND b.StartDate IS NULL
                     )
                  OR (
                         a.StartDate IS NULL
                         AND b.StartDate IS NOT NULL
                     );

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
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrMatrixVersionHeader,
                   707380000000,
                   a.VersionID,
                   NULL,
                   a.IsActive,
                   b.IsActive
            FROM @tlbAggrMatrixVersionHeader_BeforeEdit a
                INNER JOIN @tlbAggrMatrixVersionHeader_AfterEdit b
                    ON a.VersionID = b.VersionID
            WHERE (a.IsActive <> b.IsActive)
                  OR (
                         a.IsActive IS NOT NULL
                         AND b.IsActive IS NULL
                     )
                  OR (
                         a.IsActive IS NULL
                         AND b.IsActive IS NOT NULL
                     );

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
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrMatrixVersionHeader,
                   840870000000,
                   a.VersionID,
                   NULL,
                   a.IsDefault,
                   b.IsDefault
            FROM @tlbAggrMatrixVersionHeader_BeforeEdit a
                INNER JOIN @tlbAggrMatrixVersionHeader_AfterEdit b
                    ON a.VersionID = b.VersionID
            WHERE (a.IsDefault <> b.IsDefault)
                  OR (
                         a.IsDefault IS NOT NULL
                         AND b.IsDefault IS NULL
                     )
                  OR (
                         a.IsDefault IS NULL
                         AND b.IsDefault IS NOT NULL
                     );
        -- End data audit
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbAggrMatrixVersionHeader',
                                           @idfVersion OUTPUT;
            INSERT INTO dbo.tlbAggrMatrixVersionHeader
            (
                idfVersion,
                idfsMatrixType,
                MatrixName,
                datStartDate,
                blnIsActive,
                blnIsDefault,
                AuditCreateDTM
            )
            VALUES
            (@idfVersion, @idfsMatrixType, @MatrixName, @datStartDate, @blnIsActive, @blnIsDefault, GETDATE());

            -- Data audit
            -- tauDataAuditEvent Event Type - Create 
            SET @idfsDataAuditEventType = 10016001;
            -- insert record into tauDataAuditEvent - 
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserId,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfVersion,
                                                 @idfObjectTable_tlbAggrMatrixVersionHeader,
                                                 @idfDataAuditEvent OUTPUT;

            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            VALUES
            (@idfDataAuditEvent, @idfObjectTable_tlbAggrMatrixVersionHeader, @idfVersion);
        -- End data audit
        END

        IF @EventTypeId IS NOT NULL
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @idfVersion,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUserName;
        END

        SELECT idfVersion,
               idfsMatrixType,
               MatrixName,
               datStartDate,
               blnIsActive,
               blnIsDefault,
               @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage'
        FROM dbo.tlbAggrMatrixVersionHeader
        WHERE idfVersion = @idfVersion;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END