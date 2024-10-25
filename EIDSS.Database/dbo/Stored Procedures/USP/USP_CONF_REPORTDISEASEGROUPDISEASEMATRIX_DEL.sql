-- ================================================================================================
-- Name: USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_DEL
--
-- Description: Deactivates a disease group to disease relationships
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/04/2019 Initial Release
-- Stephen Long     04/13/2023 Added site alert logic and comment box.
--
-- exec USP_CONF_DISEASEGROUPDISEASEMATRIX_DEL 6704450000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_DEL]
(
    @idfDiagnosisToGroupForReportType BIGINT,
    @deleteAnyway BIT = 0,
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
        UPDATE dbo.trtDiagnosisToGroupForReportType
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfDiagnosisToGroupForReportType = @idfDiagnosisToGroupForReportType;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfDiagnosisToGroupForReportType,
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
