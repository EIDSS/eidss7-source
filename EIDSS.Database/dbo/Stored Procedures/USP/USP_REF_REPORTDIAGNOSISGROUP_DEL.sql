-- ================================================================================================
-- Name: USP_REF_REPORTDIAGNOSISGROUP_DEL
--
-- Description:	Deletes the report disease group record from the list of active records.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/25/2018 Initial release.
-- Ricky Moss		01/16/2019 Merged with USP_REF_REPORTDIAGNOSISGROUP_CANDEL stored procedure
-- Stephen Long     11/01/2022 Added site alert logic.
--
-- exec USP_REF_REPORTDIAGNOSISGROUP_DEL 55615180000016
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_REPORTDIAGNOSISGROUP_DEL]
(
	@idfsReportDiagnosisGroup BIGINT,
    @DeleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
) AS

Begin
 BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

	IF NOT EXISTS(SELECT idfDiagnosisToGroupForReportType FROM dbo.trtDiagnosisToGroupForReportType WHERE idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup) OR @deleteAnyway = 1
	BEGIN
	UPDATE dbo.trtReportDiagnosisGroup 
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
		WHERE idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
		and intRowStatus = 0;

	UPDATE dbo.trtBaseReference 
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
		WHERE idfsBaseReference = @idfsReportDiagnosisGroup
		AND intRowStatus = 0;

	UPDATE dbo.trtStringNameTranslation 
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
		WHERE idfsBaseReference = @idfsReportDiagnosisGroup;

                    INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsReportDiagnosisGroup,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
	END
	ELSE IF EXISTS(SELECT idfDiagnosisToGroupForReportType FROM dbo.trtDiagnosisToGroupForReportType WHERE idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup)
	BEGIN
            SELECT @ReturnCode = -1;
            SELECT @ReturnMessage = 'IN USE';
	END

            SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
END TRY
BEGIN CATCH
	THROW;
END CATCH
end
