-- ================================================================================================
-- Name: USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SET
--
-- Description:	Creates/updates a sample type/derivative type matrix.
--
-- Author: Unknown
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/13/2022 Added site alert logic and documentation header.
-- Leo Tracchia		02/22/2023 Added new logic for data auditing
-- Stephen Long     03/13/2023 Fix for object type ID and other issues.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SET]
(
    @idfDerivativeForSampleType BIGINT = NULL,
    @idfsSampleType BIGINT,
    @idfsDerivativeType BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
        @EventId BIGINT = -1,
        @EventSiteId BIGINT = @SiteId,
        @EventUserId BIGINT = @UserId,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = @LocationId,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = @SiteId,
        @idfUserId BIGINT = NULL,
        @idfSiteId BIGINT = NULL,
        @idfsDataAuditEventType BIGINT = NULL,
        @idfsObjectType BIGINT = 10017068,
        @idfObject BIGINT = @idfDerivativeForSampleType,
        @idfObjectTable_trtDerivativeForSampleType BIGINT = 740850000000,
        @idfDataAuditEvent BIGINT = NULL;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);

--Data audit 
DECLARE @trtDerivativeForSampleType_BeforeEdit TABLE
(
    idfDerivativeForSampleType BIGINT,
    idfsSampleType BIGINT,
    idfsDerivativeType BIGINT,
    intRowStatus INT
);
DECLARE @trtDerivativeForSampleType_AfterEdit TABLE
(
    idfDerivativeForSampleType BIGINT,
    idfsSampleType BIGINT,
    idfsDerivativeType BIGINT,
    intRowStatus INT
);

-- Get and Set user and site identifiers.
SELECT @idfUserId = userInfo.UserId,
       @idfSiteId = UserInfo.SiteId
FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
-- End data audit
BEGIN
    BEGIN TRY
        IF ( -- DUPLICATE CHECK
               EXISTS
        (
            SELECT idfDerivativeForSampleType
            FROM dbo.trtDerivativeForSampleType
            WHERE idfsDerivativeType = @idfsDerivativeType
                  AND idfsSampleType = @idfsSampleType
                  AND intRowStatus = 0
        )
               AND @idfDerivativeForSampleType IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfDerivativeForSampleType
            FROM dbo.trtDerivativeForSampleType
            WHERE idfsDerivativeType = @idfsDerivativeType
                  AND idfsSampleType = @idfsSampleType
                  AND idfDerivativeForSampleType <> @idfDerivativeForSampleType
                  AND intRowStatus = 0
        )
                  AND @idfDerivativeForSampleType IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfDerivativeForSampleType =
            (
                SELECT idfDerivativeForSampleType
                FROM dbo.trtDerivativeForSampleType
                WHERE idfsDerivativeType = @idfsDerivativeType
                      AND idfsSampleType = @idfsSampleType
                      AND intRowStatus = 0
            );
        END
        ELSE IF ( -- Update an existing record.
                    EXISTS
             (
                 SELECT idfDerivativeForSampleType
                 FROM dbo.trtDerivativeForSampleType
                 WHERE idfsDerivativeType = @idfsDerivativeType
                       AND idfsSampleType = @idfsSampleType
                       AND intRowStatus = 1
             )
                    AND @idfDerivativeForSampleType IS NULL
                )
        BEGIN
            UPDATE dbo.trtDerivativeForSampleType
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsDerivativeType = @idfsDerivativeType
                  AND idfsSampleType = @idfsSampleType
                  AND intRowStatus = 1;

            SELECT @idfDerivativeForSampleType =
            (
                SELECT idfDerivativeForSampleType
                FROM dbo.trtDerivativeForSampleType
                WHERE idfsDerivativeType = @idfsDerivativeType
                      AND idfsSampleType = @idfsSampleType
                      AND intRowStatus = 1
            );
        END
        ELSE IF ( -- UPDATE
                    EXISTS
             (
                 SELECT idfDerivativeForSampleType
                 FROM dbo.trtDerivativeForSampleType
                 WHERE idfsDerivativeType = @idfsDerivativeType
                       AND idfsSampleType = @idfsSampleType
                       AND idfDerivativeForSampleType = @idfDerivativeForSampleType
                       AND intRowStatus = 0
             )
                    AND @idfDerivativeForSampleType IS NOT NULL
                )
        BEGIN

            -- Data audit
            SET @idfsDataAuditEventType = 10016003; -- Edit event type

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserId,
                                                      @idfSiteId,
                                                      @idfsDataAuditEventType,
                                                      @idfsObjectType,
                                                      @idfDerivativeForSampleType,
                                                      @idfObjectTable_trtDerivativeForSampleType,
                                                      NULL,
                                                      @idfDataAuditEvent OUTPUT;

            INSERT INTO @trtDerivativeForSampleType_BeforeEdit
            (
                idfDerivativeForSampleType,
                idfsSampleType,
                idfsDerivativeType,
                intRowStatus
            )
            SELECT idfDerivativeForSampleType,
                   idfsSampleType,
                   idfsDerivativeType,
                   intRowStatus
            FROM dbo.trtDerivativeForSampleType
            WHERE idfDerivativeForSampleType = @idfDerivativeForSampleType;
            -- End data audit

            UPDATE dbo.trtDerivativeForSampleType
            SET idfsDerivativeType = @idfsDerivativeType,
                idfsSampleType = @idfsSampleType,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfDerivativeForSampleType = @idfDerivativeForSampleType
                  AND intRowStatus = 0;

            -- Data audit
            INSERT INTO @trtDerivativeForSampleType_AfterEdit
            (
                idfDerivativeForSampleType,
                idfsSampleType,
                idfsDerivativeType,
                intRowStatus
            )
            SELECT idfDerivativeForSampleType,
                   idfsSampleType,
                   idfsDerivativeType,
                   intRowStatus
            FROM trtDerivativeForSampleType
            WHERE idfDerivativeForSampleType = @idfDerivativeForSampleType;

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
                   @idfObjectTable_trtDerivativeForSampleType,
                   740870000000,
                   a.idfDerivativeForSampleType,
                   NULL,
                   a.idfsSampleType,
                   b.idfsSampleType
            FROM @trtDerivativeForSampleType_BeforeEdit a
                INNER JOIN @trtDerivativeForSampleType_AfterEdit b
                    ON a.idfDerivativeForSampleType = b.idfDerivativeForSampleType
            WHERE (a.idfsSampleType <> b.idfsSampleType)
                  OR (
                         a.idfsSampleType IS NOT NULL
                         AND b.idfsSampleType IS NULL
                     )
                  OR (
                         a.idfsSampleType IS NULL
                         AND b.idfsSampleType IS NOT NULL
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
                   @idfObjectTable_trtDerivativeForSampleType,
                   740880000000,
                   a.idfDerivativeForSampleType,
                   NULL,
                   a.idfsDerivativeType,
                   b.idfsDerivativeType
            FROM @trtDerivativeForSampleType_BeforeEdit a
                INNER JOIN @trtDerivativeForSampleType_AfterEdit b
                    ON a.idfDerivativeForSampleType = b.idfDerivativeForSampleType
            WHERE (a.idfsDerivativeType <> b.idfsDerivativeType)
                  OR (
                         a.idfsDerivativeType IS NOT NULL
                         AND b.idfsDerivativeType IS NULL
                     )
                  OR (
                         a.idfsDerivativeType IS NULL
                         AND b.idfsDerivativeType IS NOT NULL
                     );
        END
        ELSE
        BEGIN -- Add a new record.
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'trtDerivativeForSampleType',
                                              @idfDerivativeForSampleType OUTPUT;

            -- Data audit
            SET @idfsDataAuditEventType = 10016001; -- Create event type

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserId,
                                                      @idfSiteId,
                                                      @idfsDataAuditEventType,
                                                      @idfsObjectType,
                                                      @idfDerivativeForSampleType,
                                                      @idfObjectTable_trtDerivativeForSampleType,
                                                      NULL,
                                                      @idfDataAuditEvent OUTPUT;
            -- End data audit

            INSERT INTO dbo.trtDerivativeForSampleType
            (
                idfDerivativeForSampleType,
                idfsSampleType,
                idfsDerivativeType,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfDerivativeForSampleType, @idfsSampleType, @idfsDerivativeType, 0, GETDATE(), @AuditUserName);

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            VALUES
            (@idfDataAuditEvent, @idfObjectTable_trtDerivativeForSampleType, @idfDerivativeForSampleType);

            -- End data audit

            INSERT INTO dbo.trtDerivativeForSampleTypeToCP
            (
                idfDerivativeForSampleType,
                idfCustomizationPackage,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfDerivativeForSampleType, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        -- Site alert
        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfDerivativeForSampleType,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage',
               @idfDerivativeForSampleType 'idfDerivativeForSampleType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
