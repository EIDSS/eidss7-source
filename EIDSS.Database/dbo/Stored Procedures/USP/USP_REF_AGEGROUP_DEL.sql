-- ================================================================================================
-- Name: USP_REF_AGEGROUP_DEL
-- Description:	Removes the Age Group from the active reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/03/2018 Initial release.
-- Ricky Moss		12/12/2018 Removed return codes
-- Ricky Moss		01/02/2019 Added deleteAnyway parameters and added return codes
-- Ricky Moss		01/03/2019 Refactor to determine if record is in use
-- Stephen Long     10/27/2022 Added site alert logic.
--
-- exec USP_REF_AGEGROUP_DEL 55615180000031, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_AGEGROUP_DEL]
(
    @idfsAgeGroup BIGINT,
    @deleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF (
               NOT EXISTS
        (
            SELECT idfsDiagnosis
            FROM dbo.trtDiagnosisAgeGroupToDiagnosis
            WHERE idfsDiagnosisAgeGroup = @idfsAgeGroup
        )
               AND NOT EXISTS
        (
            SELECT idfsStatisticalAgeGroup
            FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
            WHERE idfsDiagnosisAgeGroup = @idfsAgeGroup
        )
           )
           OR @deleteAnyway = 1
        BEGIN
            UPDATE dbo.trtDiagnosisAgeGroup
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsDiagnosisAgeGroup = @idfsAgeGroup
                  AND intRowStatus = 0

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsAgeGroup
                  AND intRowStatus = 0;

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsAgeGroup;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsAgeGroup,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE IF (
                    EXISTS
             (
                 SELECT idfsDiagnosis
                 FROM dbo.trtDiagnosisAgeGroupToDiagnosis
                 WHERE idfsDiagnosisAgeGroup = @idfsAgeGroup
             )
                    OR EXISTS
             (
                 SELECT idfsStatisticalAgeGroup
                 FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
                 WHERE idfsDiagnosisAgeGroup = @idfsAgeGroup
             )
                )
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
END
