-- ================================================================================================
-- NAME: USP_CONF_CUSTOMREPORT_DEL
--
-- DESCRIPTION: Removes a custom report item

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/21/2019 Initial Release
-- Ann Xiong		05/14/2021 Changed SELECT @returnCode 'returnCode', @returnMsg 'returnMsg' to 
--                             SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage, 
--                             @idfReportRows as idfReportRows
-- Stephen Long     04/13/2023 Added site alert logic.
--
-- exec USP_CONF_CUSTOMREPORT_DEL 55540680000323, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_CUSTOMREPORT_DEL]
(
    @idfReportRows BIGINT,
    @deleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        UPDATE dbo.trtReportRows
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfReportRows = @idfReportRows;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfReportRows,
                                       NULL,
                                       @SiteId,
                                       NULL,
                                       @SiteId,
                                       @LocationId,
                                       @AuditUserName;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
