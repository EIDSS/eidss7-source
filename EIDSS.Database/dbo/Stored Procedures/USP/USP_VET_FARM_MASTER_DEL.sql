-- ================================================================================================
-- Name: USP_VET_FARM_MASTER_DEL
--
-- Description:	Sets a farm master record to "inactive".
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/08/2019 Initial release.
-- Stephen Long     04/26/2019 Made fixes to the laboratory sample count, and set the return code 
--                             accordingly; 0 if farm was soft deleted and 1 or 2 if a dependent 
--                             child objects exist or dependent on another object.
-- Ann Xiong        04/30/2020 Modified to skip checking any dependent child objects for Deduplication
-- Mike Kornegay	02/23/2022 Removed @LanguageID as it is not needed.
-- Stephen Long     06/01/2022 Add row status of 0 check on disease report, case and monitoring 
--                             session.
-- Stephen Long     12/06/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long     03/09/2023 Changed data audit call to USSP_GBL_DATA_AUDIT_EVENT_SET.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_FARM_MASTER_DEL]
(
    @FarmMasterID BIGINT,
    @DeduplicationIndicator BIT = 0,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @MonitoringSessionCount INT = 0,
            @DiseaseReportCount INT = 0,
            @OutbreakSessionCount INT = 0,
            @LabSampleCount INT = 0,
            @DataAuditEventTypeid BIGINT = 10016002, -- Delete audit event type
            @ObjectTypeID BIGINT = 10017020,         -- Farm
            @ObjectID BIGINT = @FarmMasterID,
            @ObjectTableID BIGINT = 4572790000000,   -- tlbFarmActual
            @DataAuditEventID BIGINT,
            @AuditUserID BIGINT,
            @AuditSiteID BIGINT,
            @EIDSSObjectID NVARCHAR(200) = (
                                               SELECT strFarmCode
                                               FROM dbo.tlbFarmActual
                                               WHERE idfFarmActual = @FarmMasterID
                                           );

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        SELECT @MonitoringSessionCount = COUNT(*)
        FROM dbo.tlbMonitoringSessionSummary m
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = m.idfFarm
            INNER JOIN dbo.tlbFarmActual fa
                ON fa.idfFarmActual = f.idfFarmActual
        WHERE fa.idfFarmActual = @FarmMasterID
              AND m.intRowStatus = 0;

        SELECT @OutbreakSessionCount = COUNT(*)
        FROM dbo.OutbreakCaseReport ocr
            INNER JOIN dbo.tlbVetCase v
                ON v.idfOutbreak = ocr.idfVetCase
                   AND v.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            INNER JOIN dbo.tlbFarmActual fa
                ON fa.idfFarmActual = f.idfFarmActual
        WHERE fa.idfFarmActual = @FarmMasterID
              AND ocr.intRowStatus = 0;

        SELECT @DiseaseReportCount = COUNT(*)
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            INNER JOIN dbo.tlbFarmActual fa
                ON fa.idfFarmActual = f.idfFarmActual
        WHERE fa.idfFarmActual = @FarmMasterID
              AND v.intRowStatus = 0;

        SELECT @LabSampleCount = COUNT(*)
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = m.idfVetCase
                   AND v.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
                   AND f.intRowStatus = 0
            INNER JOIN dbo.tlbFarmActual fa
                ON fa.idfFarmActual = f.idfFarmActual
        WHERE fa.idfFarmActual = @FarmMasterID
              AND m.intRowStatus = 0
              AND m.blnAccessioned = 1;

        IF @DeduplicationIndicator = 0
        BEGIN
            IF @MonitoringSessionCount = 0
               AND @OutbreakSessionCount = 0
               AND @DiseaseReportCount = 0
               AND @LabSampleCount = 0
            BEGIN
                UPDATE s
                SET s.intRowStatus = 1
                FROM dbo.tlbSpeciesActual s
                    INNER JOIN dbo.tlbHerdActual h
                        ON h.idfHerdActual = s.idfHerdActual
                WHERE h.idfFarmActual = @FarmMasterID;

                UPDATE dbo.tlbHerdActual
                SET intRowStatus = 1
                WHERE idfFarmActual = @FarmMasterID;

                UPDATE dbo.tlbFarmActual
                SET intRowStatus = 1,
                    datModificationDate = GETDATE()
                WHERE idfFarmActual = @FarmMasterID;

                SET @ReturnCode = 0;

                -- Data audit
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @ObjectTypeID,
                                                          @FarmMasterID,
                                                          @ObjectTableID,
                                                          @EIDSSObjectID, 
                                                          @DataAuditEventID OUTPUT;

                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       @FarmMasterID,
                       @AuditUserName,
                       @EIDSSObjectID;
            -- End data audit
            END
            ELSE
            BEGIN
                IF @MonitoringSessionCount > 0
                   OR @LabSampleCount > 0
                BEGIN
                    SET @ReturnCode = 2;
                    SET @ReturnMessage = 'Unable to delete this record as it is dependent on another object.';
                END;
                ELSE
                BEGIN
                    SET @ReturnCode = 1;
                    SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
                END;
            END;
        END
        ELSE
        BEGIN
            UPDATE s
            SET s.intRowStatus = 1
            FROM dbo.tlbSpeciesActual AS s
                INNER JOIN dbo.tlbHerdActual AS h
                    ON h.idfHerdActual = s.idfHerdActual
            WHERE h.idfFarmActual = @FarmMasterID;

            UPDATE dbo.tlbHerdActual
            SET intRowStatus = 1
            WHERE idfFarmActual = @FarmMasterID;

            UPDATE dbo.tlbFarmActual
            SET intRowStatus = 1,
                datModificationDate = GETDATE()
            WHERE idfFarmActual = @FarmMasterID;

            SET @ReturnCode = 0;

            -- Data audit
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @AuditUserID,
                                                 @AuditSiteID,
                                                 @DataAuditEventTypeID,
                                                 @ObjectTypeID,
                                                 @ObjectID,
                                                 @ObjectTableID,
                                                 @DataAuditEventID OUTPUT;

            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   @FarmMasterID,
                   @AuditUserName,
                   @EIDSSObjectID;
        -- End data audit
        END

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH;
END
