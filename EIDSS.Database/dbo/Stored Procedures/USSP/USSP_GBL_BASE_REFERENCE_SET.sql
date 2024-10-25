-- ================================================================================================
-- Name: USSP_GBL_BASE_REFERENCE_SET
--
-- Description: Insert/update base reference data.  Non-API stored procedure.  Only call via 
-- other stored procedures.
--           
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		12/13/2022 Initial release for data auditing for SAUC30 and 31.
-- Stephen Long     02/13/2023 Changed default name from varchar to nvarchar.
-- Ann Xiong		02/27/2023 Replaced NULL with @AccessoryCode when INSERT INTO dbo.trtBaseReference
--
-- Testing Code:
/*
DECLARE @idfsSpeciesType BIGINT

EXEC dbo.USSP_GBL_Base_Reference_SET @idfsSpeciesType OUTPUT, 19000086, 'en-US', 'Mark', 'Mark', 0, 0, 'System'
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_BASE_REFERENCE_SET]
(
    @BaseReferenceID BIGINT = NULL OUTPUT,
    @BaseReferenceTypeID BIGINT,
    @LanguageID NVARCHAR(50),
    @DefaultName NVARCHAR(200),          -- Default reference name, used if there is no reference translation
    @NationalName NVARCHAR(200) = NULL, -- Reference name in the language defined by @LanguageID
    @AccessoryCode INT = NULL,          -- Bit mask for reference using
    @Order INT = NULL,                  -- Reference record order for sorting
    @SystemValueIndicator BIT = 0,
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @UniqueDefaultValueIndicator BIT = 'TRUE' OUTPUT
)
AS
-- Data audit
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @CustomizationPackageID BIGINT,
        @ObjectTypeID BIGINT = 10017042,     -- Base Reference
        @ObjectID BIGINT = @BaseReferenceID,
        @ObjectTableID BIGINT = 75820000000; -- trtBaseReference

DECLARE @BaseReferenceAfterEdit TABLE
(
    BaseReferenceID BIGINT,
    BaseReferenceTypeID BIGINT,
    BaseReferenceCode VARCHAR(36),
    DefaultValue NVARCHAR(2000),
    AccessoryCode INT,
    OrderValue INT,
    SystemValueIndicator BIT
);
DECLARE @BaseReferenceBeforeEdit TABLE
(
    BaseReferenceID BIGINT,
    BaseReferenceTypeID BIGINT,
    BaseReferenceCode VARCHAR(36),
    DefaultValue NVARCHAR(2000),
    AccessoryCode INT,
    OrderValue INT,
    SystemValueIndicator BIT
);
-- End data audit
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

        IF EXISTS
        (
            SELECT idfsBaseReference
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @BaseReferenceID
                  AND intRowStatus = 0
        )
        BEGIN
            -- Data audit
            INSERT INTO @BaseReferenceBeforeEdit
            (
                BaseReferenceID,
                BaseReferenceTypeID,
                BaseReferenceCode,
                DefaultValue,
                AccessoryCode,
                OrderValue,
                SystemValueIndicator
            )
            SELECT idfsBaseReference,
                   idfsReferenceType,
                   strBaseReferenceCode,
                   strDefault,
                   intHACode,
                   intOrder,
                   blnSystem
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @BaseReferenceID;
            -- End data audit

            UPDATE dbo.trtBaseReference
            SET idfsReferenceType = @BaseReferenceTypeID,
                strDefault = ISNULL(@DefaultName, strDefault),
                intHACode = ISNULL(@AccessoryCode, intHACode),
                intOrder = ISNULL(@Order, intOrder),
                blnSystem = ISNULL(@SystemValueIndicator, blnSystem),
                rowguid = ISNULL(rowguid, NEWID()),
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfsBaseReference = @BaseReferenceID;

            -- Data audit
            INSERT INTO @BaseReferenceAfterEdit
            (
                BaseReferenceID,
                BaseReferenceTypeID,
                BaseReferenceCode,
                DefaultValue,
                AccessoryCode,
                OrderValue,
                SystemValueIndicator
            )
            SELECT idfsBaseReference,
                   idfsReferenceType,
                   strBaseReferenceCode,
                   strDefault,
                   intHACode,
                   intOrder,
                   blnSystem
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @BaseReferenceID;

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
                   81080000000,
                   a.BaseReferenceID,
                   NULL,
                   b.BaseReferenceTypeID,
                   a.BaseReferenceTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @BaseReferenceAfterEdit AS a
                FULL JOIN @BaseReferenceBeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.BaseReferenceTypeID <> b.BaseReferenceTypeID)
                  OR (
                         a.BaseReferenceTypeID IS NOT NULL
                         AND b.BaseReferenceTypeID IS NULL
                     )
                  OR (
                         a.BaseReferenceTypeID IS NULL
                         AND b.BaseReferenceTypeID IS NOT NULL
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
                   81110000000,
                   a.BaseReferenceID,
                   NULL,
                   b.BaseReferenceCode,
                   a.BaseReferenceCode,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @BaseReferenceAfterEdit AS a
                FULL JOIN @BaseReferenceBeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.BaseReferenceCode <> b.BaseReferenceCode)
                  OR (
                         a.BaseReferenceCode IS NOT NULL
                         AND b.BaseReferenceCode IS NULL
                     )
                  OR (
                         a.BaseReferenceCode IS NULL
                         AND b.BaseReferenceCode IS NOT NULL
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
                   81120000000,
                   a.BaseReferenceID,
                   NULL,
                   b.DefaultValue,
                   a.DefaultValue,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @BaseReferenceAfterEdit AS a
                FULL JOIN @BaseReferenceBeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.DefaultValue <> b.DefaultValue)
                  OR (
                         a.DefaultValue IS NOT NULL
                         AND b.DefaultValue IS NULL
                     )
                  OR (
                         a.DefaultValue IS NULL
                         AND b.DefaultValue IS NOT NULL
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
                   81090000000,
                   a.BaseReferenceID,
                   NULL,
                   b.AccessoryCode,
                   a.AccessoryCode,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @BaseReferenceAfterEdit AS a
                FULL JOIN @BaseReferenceBeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.AccessoryCode <> b.AccessoryCode)
                  OR (
                         a.AccessoryCode IS NOT NULL
                         AND b.AccessoryCode IS NULL
                     )
                  OR (
                         a.AccessoryCode IS NULL
                         AND b.AccessoryCode IS NOT NULL
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
                   81100000000,
                   a.BaseReferenceID,
                   NULL,
                   b.OrderValue,
                   a.OrderValue,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @BaseReferenceAfterEdit AS a
                FULL JOIN @BaseReferenceBeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.OrderValue <> b.OrderValue)
                  OR (
                         a.OrderValue IS NOT NULL
                         AND b.OrderValue IS NULL
                     )
                  OR (
                         a.OrderValue IS NULL
                         AND b.OrderValue IS NOT NULL
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
                   747460000000,
                   a.BaseReferenceID,
                   NULL,
                   b.SystemValueIndicator,
                   a.SystemValueIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @BaseReferenceAfterEdit AS a
                FULL JOIN @BaseReferenceBeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.SystemValueIndicator <> b.SystemValueIndicator)
                  OR (
                         a.SystemValueIndicator IS NOT NULL
                         AND b.SystemValueIndicator IS NULL
                     )
                  OR (
                         a.SystemValueIndicator IS NULL
                         AND b.SystemValueIndicator IS NOT NULL
                     );
        -- End data audit
        END
        ELSE
        BEGIN
            IF @BaseReferenceID IS NULL
            BEGIN
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference',
                                               @BaseReferenceID OUTPUT;
            END

            IF @Order IS NULL
            BEGIN
                SET @Order = 0;
            END

            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @DefaultName
                      AND idfsReferenceType = @BaseReferenceTypeID
            )
                SET @UniqueDefaultValueIndicator = 'FALSE';
            ELSE
                SET @UniqueDefaultValueIndicator = 'TRUE';

            INSERT INTO dbo.trtBaseReference
            (
                idfsBaseReference,
                idfsReferenceType,
                strBaseReferenceCode,
                strDefault,
                intHACode,
                intOrder,
                blnSystem,
                intRowStatus,
                rowguid,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@BaseReferenceID,
             @BaseReferenceTypeID,
             NULL,
             @DefaultName,
             @AccessoryCode,
             @Order,
             0  ,
             0  ,
             NEWID(),
             'ADD',
             'EIDSS7 new reference data',
             10519001,
             N'[{"idfsBaseReference":' + CAST(@BaseReferenceID AS NVARCHAR(300)) + '}]',
             GETDATE(),
             @AuditUserName
            );

            SELECT @CustomizationPackageID = dbo.FN_GBL_CustomizationPackage_GET();

            IF @CustomizationPackageID IS NOT NULL
               AND @CustomizationPackageID <> 51577300000000 -- The USA
            BEGIN
                EXEC dbo.USP_GBL_BaseReferenceToCP_SET @BaseReferenceID,
                                                       @CustomizationPackageID;
            END

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
             @BaseReferenceID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
        -- End data audit
        END

        EXEC dbo.USSP_GBL_StringTranslation_SET @BaseReferenceID,
                                                @LanguageID,
                                                @NationalName;

        RETURN;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
