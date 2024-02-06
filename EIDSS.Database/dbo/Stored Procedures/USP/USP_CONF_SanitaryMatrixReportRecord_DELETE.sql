-- ================================================================================================
-- Name: USP_CONF_SanitaryMatrixReportRecord_DELETE
--
-- Description: Deletes Entries For Vet Sanitary Action Matrix Report Record
--
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                   Date       Change Detail
-- ---------------------- ---------- -------------------------------------------------------------
-- Lamont Mitchell        03/12/2019 Initial Created
-- Ann Xiong              02/24/2023 Implemented Data Audit
-- Stephen Long           04/17/2023 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SanitaryMatrixReportRecord_DELETE]
    @idfAggrSanitaryActionMTX BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    -- Data audit
    DECLARE @idfUserId BIGINT = NULL,
            @idfSiteId BIGINT = NULL,
            @idfsDataAuditEventType BIGINT = 10016002,
            @idfsObjectType BIGINT = 10017003, -- Matrix for Aggregate Reports
            @idfObject BIGINT = @idfAggrSanitaryActionMTX,
            @idfObjectTable_tlbAggrSanitaryActionMTX BIGINT = 12666690000000,
            @idfDataAuditEvent BIGINT = NULL;

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
            FROM dbo.tlbAggrSanitaryActionMTX
            WHERE idfAggrSanitaryActionMTX = @idfAggrSanitaryActionMTX
        )
        BEGIN

            DELETE FROM dbo.tlbAggrSanitaryActionMTX
            WHERE idfAggrSanitaryActionMTX = @idfAggrSanitaryActionMTX;

            -- Data audit
            -- insert record into tauDataAuditEvent
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserID,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfObject,
                                                 @idfObjectTable_tlbAggrSanitaryActionMTX,
                                                 @idfDataAuditEvent OUTPUT;

            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrSanitaryActionMTX,
                   @idfObject
            -- End data audit

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_ADMIN_EVENT_SET-1,
                                            @EventTypeId,
                                            @UserId,
                                            @idfAggrSanitaryActionMTX,
                                            NULL,
                                            @SiteId,
                                            NULL,
                                            @SiteId,
                                            @LocationId,
                                            @AuditUserName,
                                            NULL,
                                            NULL;
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
