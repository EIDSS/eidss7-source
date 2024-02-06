-- ================================================================================================
-- Name: USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DEL
--
-- Description: Removes sample type derivative matrix record
--							
-- Author:		unknown
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Leo Tracchia		02/22/2023 Added data audit logic for deletes
-- Stephen Long     03/13/2023 Fix for object type ID for data audit and added audit user name.
-- Stephen Long     04/17/2023 Added site alert logic.
--
-- Test Code:
-- exec USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DEL 6618200000000, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DEL]
(
    @idfDerivativeForSampleType BIGINT,
    @deleteAnyway BIT = 0,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @idfUserId BIGINT = @UserId,
        @idfSiteId BIGINT = @SiteId,
        @idfsDataAuditEventType BIGINT = 10016002, -- Delete event type
        @idfsObjectType BIGINT = 10017068,
        @idfObject BIGINT = @idfDerivativeForSampleType,
        @idfObjectTable_trtDerivativeForSampleType BIGINT = 740850000000,
        @idfDataAuditEvent BIGINT = NULL;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        UPDATE dbo.trtDerivativeForSampleType
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfDerivativeForSampleType = @idfDerivativeForSampleType;

        -- Data audit
        INSERT INTO @SuppressSelect
        EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserId,
                                                  @idfSiteId,
                                                  @idfsDataAuditEventType,
                                                  @idfsObjectType,
                                                  @idfObject,
                                                  @idfObjectTable_trtDerivativeForSampleType,
                                                  NULL,
                                                  @idfDataAuditEvent OUTPUT;

        INSERT INTO dbo.tauDataAuditDetailDelete
        (
            idfDataAuditEvent,
            idfObjectTable,
            idfObject
        )
        VALUES
        (@idfDataAuditEvent, @idfObjectTable_trtDerivativeForSampleType, @idfObject);
        -- End data audit

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USSP_ADMIN_EVENT_SET-1,
                                        @EventTypeId,
                                        @UserId,
                                        @idfDerivativeForSampleType,
                                        NULL,
                                        @SiteId,
                                        NULL,
                                        @SiteId,
                                        @LocationId,
                                        @AuditUserName,
                                        NULL,
                                        NULL;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
