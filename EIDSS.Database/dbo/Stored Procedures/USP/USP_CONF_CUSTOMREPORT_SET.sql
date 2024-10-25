-- ================================================================================================
-- Name: USP_CONF_CUSTOMREPORT_SET
-- Description: Creates a custom report item

-- Author: Ricky Moss

-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/21/2019 Initial Release
-- Ann Xiong		05/14/2021 Changed SELECT @returnCode 'returnCode', @returnMsg 'returnMsg', 
--                             @idfReportRows 'idfsReportRows' to SELECT @returnCode as 
--                             ReturnCode, @returnMsg as ReturnMessage, @idfReportRows as 
--                             idfReportRows
-- Ann Xiong		06/08/2021 Deleted the last SELECT to fix the error when saving
-- Ann Xiong		06/23/2021 Added scripts to check for duplicate values
-- Mike Kornegay	08/17/2021 Added the ability to save specific row order in intRowOrder 
--                             field
-- Stephen Long     08/15/2022 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_CUSTOMREPORT_SET]
(
    @idfReportRows BIGINT = NULL,
    @idfsCustomReportType BIGINT,
    @idfsDiagnosisOrReportDiagnosisGroup BIGINT,
    @idfsReportAdditionalText BIGINT,
    @idfsICDReportAdditionalText BIGINT,
    @intRowOrder INT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @EventId BIGINT = -1,
        @EventSiteId BIGINT = @SiteId,
        @EventUserId BIGINT = @UserId,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = @LocationId,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = @SiteId;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
BEGIN
    BEGIN TRY
        IF (
               EXISTS
        (
            SELECT idfReportRows
            FROM dbo.trtReportRows
            WHERE idfsCustomReportType = @idfsCustomReportType
                  AND idfsDiagnosisOrReportDiagnosisGroup = @idfsDiagnosisOrReportDiagnosisGroup
                  AND intRowStatus = 0
        )
               AND @idfReportRows IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfReportRows
            FROM dbo.trtReportRows
            WHERE idfsCustomReportType = @idfsCustomReportType
                  AND idfsDiagnosisOrReportDiagnosisGroup = @idfsDiagnosisOrReportDiagnosisGroup
                  AND idfReportRows <> @idfReportRows
                  AND intRowStatus = 0
        )
                  AND @idfReportRows IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfReportRows =
            (
                SELECT idfReportRows
                FROM dbo.trtReportRows
                WHERE idfsCustomReportType = @idfsCustomReportType
                      AND idfsDiagnosisOrReportDiagnosisGroup = @idfsDiagnosisOrReportDiagnosisGroup
                      AND intRowStatus = 0
            )
        END
        ELSE IF EXISTS
        (
            SELECT idfReportRows
            FROM dbo.trtReportRows
            WHERE idfsCustomReportType = @idfsCustomReportType
                  AND idfsDiagnosisOrReportDiagnosisGroup = @idfsDiagnosisOrReportDiagnosisGroup
                  AND intRowStatus = 1
        )
        BEGIN
            SELECT @idfReportRows =
            (
                SELECT idfReportRows
                FROM dbo.trtReportRows
                WHERE idfsCustomReportType = @idfsCustomReportType
                      AND idfsDiagnosisOrReportDiagnosisGroup = @idfsDiagnosisOrReportDiagnosisGroup
                      AND intRowStatus = 1
            )
            UPDATE dbo.trtReportRows
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName
            WHERE idfsCustomReportType = @idfsCustomReportType
                  AND idfsDiagnosisOrReportDiagnosisGroup = @idfsDiagnosisOrReportDiagnosisGroup;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @idfReportRows,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUserName;
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtReportRows', @idfReportRows OUTPUT;

            INSERT INTO dbo.trtReportRows
            (
                idfReportRows,
                idfsCustomReportType,
                idfsDiagnosisOrReportDiagnosisGroup,
                idfsReportAdditionalText,
                idfsICDReportAdditionalText,
                intRowOrder,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfReportRows,
             @idfsCustomReportType,
             @idfsDiagnosisOrReportDiagnosisGroup,
             @idfsReportAdditionalText,
             @idfsICDReportAdditionalText,
             @intRowOrder,
             0,
             GETDATE(), 
             @AuditUserName
            );

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @idfReportRows,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUserName;
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @idfReportRows AS idfReportRows;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END


