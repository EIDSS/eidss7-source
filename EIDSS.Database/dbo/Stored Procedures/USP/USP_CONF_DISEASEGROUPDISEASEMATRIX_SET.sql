-- =========================================================================================
-- NAME: USP_CONF_DISEASEGROUPDISEASEMATRIX_SET
-- DESCRIPTION: Creates a disease group to disease relationship

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		03/18/2019	Initial Release
-- Ricky Moss		04/26/2016  Check for Duplicates
-- Ann Xiong		06/23/2021	Fixed a minor issue
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- exec USP_CONF_DISEASEGROUPDISEASEMATRIX_SET NULL, 51529030000000, 784230000000
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASEGROUPDISEASEMATRIX_SET]
(
    @idfDiagnosisToDiagnosisGroup BIGINT,
    @idfsDiagnosisGroup BIGINT,
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
        IF (
               EXISTS
        (
            SELECT idfDiagnosisToDiagnosisGroup
            FROM dbo.trtDiagnosisToDiagnosisGroup
            WHERE idfsDiagnosis = @idfsDiagnosis
                  AND idfsDiagnosisGroup = @idfsDiagnosisGroup
                  AND intRowStatus = 0
        )
               AND @idfDiagnosisToDiagnosisGroup IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfDiagnosisToDiagnosisGroup
            FROM dbo.trtDiagnosisToDiagnosisGroup
            WHERE idfsDiagnosis = @idfsDiagnosis
                  AND idfsDiagnosisGroup = @idfsDiagnosisGroup
                  AND idfDiagnosisToDiagnosisGroup <> @idfDiagnosisToDiagnosisGroup
                  AND intRowStatus = 0
        )
                  AND @idfDiagnosisToDiagnosisGroup IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfDiagnosisToDiagnosisGroup =
            (
                SELECT idfDiagnosisToDiagnosisGroup
                FROM dbo.trtDiagnosisToDiagnosisGroup
                WHERE idfsDiagnosis = @idfsDiagnosis
                      AND idfsDiagnosisGroup = @idfsDiagnosisGroup
                      AND intRowStatus = 0
            );
        END
        ELSE IF EXISTS
        (
            SELECT idfDiagnosisToDiagnosisGroup
            FROM dbo.trtDiagnosisToDiagnosisGroup
            WHERE idfsDiagnosis = @idfsDiagnosis
                  AND idfsDiagnosisGroup = @idfsDiagnosisGroup
                  AND intRowStatus = 1
        )
        BEGIN
            SELECT @idfDiagnosisToDiagnosisGroup =
            (
                SELECT idfDiagnosisToDiagnosisGroup
                FROM dbo.trtDiagnosisToDiagnosisGroup
                WHERE idfsDiagnosis = @idfsDiagnosis
                      AND idfsDiagnosisGroup = @idfsDiagnosisGroup
                      AND intRowStatus = 1
            );

            UPDATE dbo.trtDiagnosisToDiagnosisGroup
            SET intRowStatus = 0, 
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfsDiagnosis = @idfsDiagnosis
                  AND idfsDiagnosisGroup = @idfsDiagnosisGroup
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtDiagnosisToDiagnosisGroup',
                                           @idfDiagnosisToDiagnosisGroup OUTPUT;

            INSERT INTO dbo.trtDiagnosisToDiagnosisGroup
            (
                idfDiagnosisToDiagnosisGroup,
                idfsDiagnosis,
                idfsDiagnosisGroup,
                intRowStatus, 
                AuditCreateDTM, 
                AuditCreateUser
            )
            VALUES
            (@idfDiagnosisToDiagnosisGroup, @idfsDiagnosis, @idfsDiagnosisGroup, 0, GETDATE(), @AuditUserName);

            INSERT INTO dbo.trtDiagnosisToDiagnosisGroupToCP
            (
                idfDiagnosisToDiagnosisGroup,
                idfCustomizationPackage,
                AuditCreateDTM, 
                AuditCreateUser
            )
            VALUES
            (@idfDiagnosisToDiagnosisGroup, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfDiagnosisToDiagnosisGroup,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfDiagnosisToDiagnosisGroup AS 'idfDiagnosisToDiagnosisGroup';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
