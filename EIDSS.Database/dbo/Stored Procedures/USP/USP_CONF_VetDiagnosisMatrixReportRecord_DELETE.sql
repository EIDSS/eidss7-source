-- ================================================================================================
-- Name: USP_CONF_VetDiagnosisMatrixReportRecord_DELETE
--
-- Description: Deletes Entries For Vet Diagnosis Matrix Report Record
--
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                   Date       Change Detail
-- ---------------------- ---------- -------------------------------------------------------------
-- Lamont Mitchell        03/12/2019 Initial Created
-- Ann Xiong              02/23/2023 Implemented Data Audit
-- Stephen Long           04/17/2023 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VetDiagnosisMatrixReportRecord_DELETE]
    @idfAggrDiagnosticActionMTX BIGINT,
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
            @idfsDataAuditEventType BIGINT = NULL,
            @idfsObjectType BIGINT = 10017003, -- Matrix for Aggregate Reports
            @idfObject BIGINT = @idfAggrDiagnosticActionMTX,
            @idfObjectTable_tlbAggrDiagnosticActionMTX BIGINT = 75430000000,
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
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfAggrDiagnosticActionMTX = @idfAggrDiagnosticActionMTX
        )
        BEGIN
            DELETE FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfAggrDiagnosticActionMTX = @idfAggrDiagnosticActionMTX;

            -- Data audit
            -- tauDataAuditEvent Event Type - Delete
            SET @idfsDataAuditEventType = 10016002;

            -- insert record into tauDataAuditEvent
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserID,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfObject,
                                                 @idfObjectTable_tlbAggrDiagnosticActionMTX,
                                                 @idfDataAuditEvent OUTPUT;

            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrDiagnosticActionMTX,
                   @idfObject;
            -- End data audit

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_ADMIN_EVENT_SET-1,
                                            @EventTypeId,
                                            @UserId,
                                            @idfAggrDiagnosticActionMTX,
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
