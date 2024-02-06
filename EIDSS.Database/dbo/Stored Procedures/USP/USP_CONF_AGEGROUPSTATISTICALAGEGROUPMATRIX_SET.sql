-- ================================================================================================
-- Name: USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_SET
-- Description:	Creates/updates an age group to statistical age group matrix.
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		04/03/2019 Initial Release
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- EXEC USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_SET NULL, 15300001100, 51529190000000
-- EXEC USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_SET NULL, 15300001100, 51529060000000
-- EXEC USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_SET 51528390000001, 15300001100, 51529190000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_SET]
(
    @idfDiagnosisAgeGroupToStatisticalAgeGroup BIGINT = NULL,
    @idfsDiagnosisAgeGroup BIGINT,
    @idfsStatisticalAgeGroup BIGINT,
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
        IF (
               EXISTS
        (
            SELECT idfDiagnosisAgeGroupToStatisticalAgeGroup
            FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
            WHERE idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
                  AND idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
                  AND intRowStatus = 0
        )
               AND @idfDiagnosisAgeGroupToStatisticalAgeGroup IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfDiagnosisAgeGroupToStatisticalAgeGroup
            FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
            WHERE idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
                  AND idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
                  AND idfDiagnosisAgeGroupToStatisticalAgeGroup <> @idfDiagnosisAgeGroupToStatisticalAgeGroup
                  AND intRowStatus = 0
        )
                  AND @idfDiagnosisAgeGroupToStatisticalAgeGroup IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @idfDiagnosisAgeGroupToStatisticalAgeGroup =
            (
                SELECT idfDiagnosisAgeGroupToStatisticalAgeGroup
                FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
                WHERE idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
                      AND idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
                      AND intRowStatus = 0
            )
            SELECT @ReturnMessage = 'DOES EXIST';
        END
        ELSE IF EXISTS
             (
                 SELECT idfDiagnosisAgeGroupToStatisticalAgeGroup
                 FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
                 WHERE idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
                       AND idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
                       AND intRowStatus = 1
             )
                AND @idfDiagnosisAgeGroupToStatisticalAgeGroup IS NULL
            UPDATE dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
            SET intRowStatus = 0, 
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
                  AND idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup;
        ELSE IF EXISTS
             (
                 SELECT idfDiagnosisAgeGroupToStatisticalAgeGroup
                 FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
                 WHERE idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
                       AND idfDiagnosisAgeGroupToStatisticalAgeGroup = @idfDiagnosisAgeGroupToStatisticalAgeGroup
                       AND intRowStatus = 0
             )
                AND @idfDiagnosisAgeGroupToStatisticalAgeGroup IS NOT NULL
            UPDATE dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
            SET idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup, 
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfDiagnosisAgeGroupToStatisticalAgeGroup = @idfDiagnosisAgeGroupToStatisticalAgeGroup;
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtDiagnosisAgeGroupToStatisticalAgeGroup',
                                           @idfDiagnosisAgeGroupToStatisticalAgeGroup OUTPUT;

            INSERT INTO dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup
            (
                idfDiagnosisAgeGroupToStatisticalAgeGroup,
                idfsDiagnosisAgeGroup,
                idfsStatisticalAgeGroup,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfDiagnosisAgeGroupToStatisticalAgeGroup, @idfsDiagnosisAgeGroup, @idfsStatisticalAgeGroup, 0, GETDATE(), @AuditUserName);

            INSERT INTO dbo.trtDiagnosisAgeGroupToStatisticalAgeGroupToCP
            (
                idfDiagnosisAgeGroupToStatisticalAgeGroup,
                idfCustomizationPackage, 
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfDiagnosisAgeGroupToStatisticalAgeGroup, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfDiagnosisAgeGroupToStatisticalAgeGroup,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage',
               @idfDiagnosisAgeGroupToStatisticalAgeGroup 'idfDiagnosisAgeGroupToStatisticalAgeGroup';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
