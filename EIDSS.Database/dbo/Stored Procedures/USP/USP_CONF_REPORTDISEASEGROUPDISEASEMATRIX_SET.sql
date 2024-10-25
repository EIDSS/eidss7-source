-- ================================================================================================
-- Name: USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_SET
--
-- Description: Creates Report Disease Group - Disease Matrix Record
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Leo Tracchia             07/23/2021 Added duplication check
-- Stephen Long             07/13/2022 Added site alert logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_SET]
(
    @idfDiagnosisToGroupForReportType BIGINT,
    @idfsCustomReportType BIGINT,
    @idfsReportDiagnosisGroup BIGINT,
    @idfsDiagnosis BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
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

        IF NOT EXISTS
        (
            SELECT idfDiagnosisToGroupForReportType
            FROM dbo.trtDiagnosisToGroupForReportType
            WHERE idfsCustomReportType = @idfsCustomReportType
                  and idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
                  and idfsDiagnosis = @idfsDiagnosis
        )
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtDiagnosisToGroupForReportType',
                                           @idfDiagnosisToGroupForReportType OUTPUT;

            INSERT INTO dbo.trtDiagnosisToGroupForReportType
            (
                idfDiagnosisToGroupForReportType,
                idfsCustomReportType,
                idfsReportDiagnosisGroup,
                idfsDiagnosis, 
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfDiagnosisToGroupForReportType, @idfsCustomReportType, @idfsReportDiagnosisGroup, @idfsDiagnosis, GETDATE(), @AuditUserName);
        END
        ELSE
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfDiagnosisToGroupForReportType = idfDiagnosisToGroupForReportType
            FROM dbo.trtDiagnosisToGroupForReportType
            WHERE idfsCustomReportType = @idfsCustomReportType
                  and idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
                  and idfsDiagnosis = @idfsDiagnosis;
        END

        INSERT INTO @SuppressSelect 
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfDiagnosisToGroupForReportType,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfDiagnosisToGroupForReportType AS 'idfDiagnosisToGroupForReportType';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
