-- ================================================================================================
-- Name: USP_CONF_HumanAggregateCaseMatrixReport_DELETE
--
-- Description: Deletes Entries For Human Aggregate Case Matrix Report and Version
--
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                        Date       Change Detail
-- --------------------------- ---------- --------------------------------------------------------
-- Lamont Mitchell             01/24/2019 Initial Created
-- Ann Xiong                   02/21/2023 Implemented Data Audit
-- Stephen Long                04/14/2023 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_HumanAggregateCaseMatrixReport_DELETE]
    @idfAggrHumanCaseMTX BIGINT NULL,
    @idfVersion BIGINT NULL,
    @idfsDiagnosis BIGINT NULL,
    @intNumRow INT,
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
            @idfObject BIGINT = @idfVersion,
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

        -- Data audit
        -- insert record into tauDataAuditEvent
        EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserID,
                                             @idfSiteId,
                                             @idfsDataAuditEventType,
                                             @idfsObjectType,
                                             @idfObject,
                                             @idfObjectTable_tlbAggrHumanCaseMTX,
                                             @idfDataAuditEvent OUTPUT;
        -- End data audit

        DELETE FROM dbo.tlbAggrHumanCaseMTX
        WHERE idfAggrHumanCaseMTX = @idfAggrHumanCaseMTX;

        -- Data audit
        INSERT INTO dbo.tauDataAuditDetailDelete
        (
            idfDataAuditEvent,
            idfObjectTable,
            idfObject
        )
        SELECT @idfDataAuditEvent,
               @idfObjectTable_tlbAggrHumanCaseMTX,
               @idfObject;
        -- End data audit

        DELETE FROM dbo.tlbAggrMatrixVersionHeader
        WHERE idfVersion = @idfVersion;

        -- Data audit
        INSERT INTO dbo.tauDataAuditDetailDelete
        (
            idfDataAuditEvent,
            idfObjectTable,
            idfObject
        )
        SELECT @idfDataAuditEvent,
               @idfObjectTable_tlbAggrMatrixVersionHeader,
               @idfObject;
        -- End data audit

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