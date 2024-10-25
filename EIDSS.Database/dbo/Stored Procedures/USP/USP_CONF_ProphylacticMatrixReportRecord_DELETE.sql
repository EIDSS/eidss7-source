-- ================================================================================================
-- Name: USP_CONF_ProphylacticMatrixReportRecord_DELETE
--
-- Description: Deletes Entries For Vet Diagnosis Matrix Report Record
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
CREATE PROCEDURE [dbo].[USP_CONF_ProphylacticMatrixReportRecord_DELETE]
    @idfAggrProphylacticActionMTX BIGINT,
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
            @idfObject BIGINT = @idfAggrProphylacticActionMTX,
            @idfObjectTable_tlbAggrProphylacticActionMTX BIGINT = 75440000000,
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
            FROM dbo.tlbAggrProphylacticActionMTX
            WHERE idfAggrProphylacticActionMTX = @idfAggrProphylacticActionMTX
        )
        BEGIN

            DELETE FROM dbo.tlbAggrProphylacticActionMTX
            WHERE idfAggrProphylacticActionMTX = @idfAggrProphylacticActionMTX;

            --Data Audit
            -- insert record into tauDataAuditEvent
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserID,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfObject,
                                                 @idfObjectTable_tlbAggrProphylacticActionMTX,
                                                 @idfDataAuditEvent OUTPUT;

            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrProphylacticActionMTX,
                   @idfObject
            -- End data audit

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_ADMIN_EVENT_SET-1,
                                            @EventTypeId,
                                            @UserId,
                                            @idfAggrProphylacticActionMTX,
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
