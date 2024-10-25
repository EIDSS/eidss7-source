-- ================================================================================================
-- Name: USP_ADMIN_ORG_DEL
--
-- Description:	Set an organization record to inactive.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/14/2019 Initial release.
-- Ricky Moss		06/11/2020 Set References of organization names to inactive.
-- Stephen Long     04/24/2021 Added dbo prefix.
-- Stephen Long     06/18/2021 Added check for site association; return 1 when site ID is not null.
-- Stephen Long     03/06/2023 Added data audit logic for SAUC30.
--
-- Testing Code:
--
-- EXEC USP_ADMIN_ORG_DEL, 'Administrator', 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ORG_DEL]
(
    @OrganizationKey BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @OrganizationAbbreviatedNameID BIGINT,
        @OrganizationFullNameID BIGINT,
        @DataAuditEventTypeid BIGINT = 10016002,                  -- Delete audit event type
        @ObjectTypeID BIGINT = 10017034,                          -- Organization
        @ObjectID BIGINT = @OrganizationKey,
        @ObjectTableID BIGINT = 75650000000,                      -- tlbOffice
        @ObjectBaseReferenceTableID BIGINT = 75820000000,         -- trtBaseReference
        @ObjectStringNameTranslationTableID BIGINT = 75990000000, -- tstStringNameTranslation
        @DataAuditEventID BIGINT,
        @AuditUserID BIGINT,
        @AuditSiteID BIGINT,
        @EIDSSObjectID NVARCHAR(200) = (
                                           SELECT strOrganizationID
                                           FROM dbo.tlbOffice
                                           WHERE idfOffice = @OrganizationKey
                                       ),
        @SiteID BIGINT = NULL;
DECLARE @SuppressSelect TABLE
(
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        SELECT @SiteID =
        (
            SELECT s.idfsSite
            FROM dbo.tlbOffice o
                INNER JOIN dbo.tstSite s
                    ON s.idfOffice = o.idfOffice
            WHERE o.idfOffice = @OrganizationKey
        );

        IF @SiteID IS NULL
        BEGIN
            -- Data audit
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @OrganizationKey,
                                                      @ObjectTableID,
                                                      @EIDSSObjectID, 
                                                      @DataAuditEventID OUTPUT;
            -- End data audit

            SELECT @OrganizationAbbreviatedNameID =
            (
                SELECT idfsOfficeAbbreviation
                FROM dbo.tlbOffice
                WHERE idfOffice = @OrganizationKey
            );

            SELECT @OrganizationFullNameID =
            (
                SELECT idfsOfficeName
                FROM dbo.tlbOffice
                WHERE idfOffice = @OrganizationKey
            );

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1
            WHERE idfsBaseReference IN ( @OrganizationAbbreviatedNameID, @OrganizationFullNameID );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectBaseReferenceTableID,
                   @OrganizationAbbreviatedNameID,
                   @AuditUserName,
                   @EIDSSObjectID;

            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectBaseReferenceTableID,
                   @OrganizationFullNameID,
                   @AuditUserName,
                   @EIDSSObjectID;
            -- End data audit

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1
            WHERE idfsBaseReference IN ( @OrganizationAbbreviatedNameID, @OrganizationFullNameID );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectStringNameTranslationTableID,
                   @OrganizationAbbreviatedNameID,
                   @AuditUserName,
                   @EIDSSObjectID;

            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectStringNameTranslationTableID,
                   @OrganizationFullNameID,
                   @AuditUserName,
                   @EIDSSObjectID;
            -- End data audit

            UPDATE dbo.tlbOffice
            SET intRowStatus = 1
            WHERE idfOffice = @OrganizationKey;

            -- Data audit
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
                   @OrganizationKey,
                   @AuditUserName,
                   @EIDSSObjectID;
        -- End data audit
        END
        ELSE
        BEGIN
            SET @ReturnCode = 1;
            SET @ReturnMessage = 'IN USE';
        END;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
