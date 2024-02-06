-- ================================================================================================
-- Name: USP_CONF_HumanAggregateCaseMatrixReportRecord_DELETE
--
-- Description: Deletes Entries For Human Aggregate Disease Report Matrix Records
--
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                        Date       Change Detail
-- --------------------------- ---------- --------------------------------------------------------
-- Lamont Mitchell             01/24/2019 Initial Created
-- Ann Xiong                   02/22/2023 Implemented Data Audit
-- Stephen Long                04/14/2023 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_HumanAggregateCaseMatrixReportRecord_DELETE]
    @idfAggrHumanCaseMTX BIGINT,
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
            @idfObject BIGINT = @idfAggrHumanCaseMTX,
            @idfObjectTable_tlbAggrHumanCaseMTX BIGINT = 12666620000000,
            @idfDataAuditEvent BIGINT = NULL,
            @idfObjectTable_tlbAggrMatrixVersionHeader BIGINT = 707330000000;

    -- Get and Set UserId and SiteId
    SELECT @idfUserId = userInfo.UserId,
           @idfSiteId = userInfo.SiteId
    FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
    -- End data audit

    BEGIN TRY
        SET NOCOUNT ON;
        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbAggrHumanCaseMTX
            WHERE idfAggrHumanCaseMTX = @idfAggrHumanCaseMTX
        )
        BEGIN
            DELETE FROM dbo.tlbAggrHumanCaseMTX
            WHERE idfAggrHumanCaseMTX = @idfAggrHumanCaseMTX;

            -- Data audit
            -- insert record into tauDataAuditEvent
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserID,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfObject,
                                                 @idfObjectTable_tlbAggrHumanCaseMTX,
                                                 @idfDataAuditEvent OUTPUT;

            INSERT INTO tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrHumanCaseMTX,
                   @idfObject
        -- End data audit
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USSP_ADMIN_EVENT_SET-1,
                                        @EventTypeId,
                                        @UserId,
                                        @idfAggrHumanCaseMTX,
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