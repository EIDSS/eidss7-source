-- ================================================================================================
-- Name: USP_CONF_DISEASEHUMANGENDERMATRIX_SET
--
-- Description: Returns a list of disease group Tto human gender relationships
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/24/2019 Initial Release
-- Ricky Moss		04/30/2020 Changed duplicate check to validate disease only
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- exec USP_CONF_DISEASEHUMANGENDERMATRIX_SET NULL, ,
-- exec USP_CONF_DISEASEHUMANGENDERMATRIX_SET NULL, ,
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASEHUMANGENDERMATRIX_SET]
(
    @DiagnosisGroupToGenderUID BIGINT = NULL,
    @DiagnosisGroupID BIGINT,
    @GenderID BIGINT,
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
        (
            EXISTS
        (
            SELECT DisgnosisGroupToGenderUID
            FROM dbo.DiagnosisGroupToGender
            WHERE DisgnosisGroupID = @DiagnosisGroupID
                  AND intRowStatus = 0
        )
            AND @DiagnosisGroupToGenderUID IS NULL
        )
           )
           OR (
        (
            EXISTS
        (
            SELECT DisgnosisGroupToGenderUID
            FROM dbo.DiagnosisGroupToGender
            WHERE DisgnosisGroupID = @DiagnosisGroupID
                  AND DisgnosisGroupToGenderUID <> @DiagnosisGroupToGenderUID
                  AND intRowStatus = 0
        )
            AND @DiagnosisGroupToGenderUID IS NOT NULL
        )
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @DiagnosisGroupToGenderUID =
            (
                SELECT DisgnosisGroupToGenderUID
                FROM dbo.DiagnosisGroupToGender
                WHERE DisgnosisGroupID = @DiagnosisGroupID
                      AND GenderID = @GenderID
                      AND intRowStatus = 0
            );
        END
        ELSE IF EXISTS
             (
                 SELECT DisgnosisGroupToGenderUID
                 FROM dbo.DiagnosisGroupToGender
                 WHERE DisgnosisGroupID = @DiagnosisGroupID
                       AND GenderID = @GenderID
                       AND intRowStatus = 1
             )
                AND @DiagnosisGroupToGenderUID IS NULL
        BEGIN
            UPDATE dbo.DiagnosisGroupToGender
            SET intRowStatus = 0, 
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE DisgnosisGroupID = @DiagnosisGroupID
                  AND GenderID = @GenderID;
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'DiagnosisGroupToGender',
                                           @DiagnosisGroupToGenderUID OUTPUT;

            INSERT INTO dbo.DiagnosisGroupToGender
            (
                DisgnosisGroupToGenderUID,
                DisgnosisGroupID,
                GenderID,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser 
            )
            VALUES
            (@DiagnosisGroupToGenderUID, @DiagnosisGroupID, @GenderID, 0, GETDATE(), @AuditUserName)
        END

        INSERT INTO @SuppressSelect 
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @DiagnosisGroupToGenderUID,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @returnMessage AS 'ReturnMessage',
               @DiagnosisGroupToGenderUID AS 'DiagnosisGroupToGenderUID'
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
