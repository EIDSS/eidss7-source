-- ================================================================================================
-- Name: USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SET
--
-- Description: Creates or updates an active species types to animal age matrix given an id, 
-- species types, and an animal age
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name				Date       Change
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		04/16/2019 Initial Release
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SET 838610000000, 837790000000, 838430000000
-- USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SET NULL, 837860000000, 6618920000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SET]
(
    @idfSpeciesTypeToAnimalAge BIGINT = NULL,
    @idfsSpeciesType BIGINT,
    @idfsAnimalAge BIGINT,
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
            SELECT idfSpeciesTypeToAnimalAge
            FROM dbo.trtSpeciesTypeToAnimalAge
            WHERE idfsAnimalAge = @idfsAnimalAge
                  AND idfsSpeciesType = @idfsSpeciesType
                  AND intRowStatus = 0
        )
               AND @idfSpeciesTypeToAnimalAge IS NULL
           )
           OR (
                  EXISTS
        (
            SELECT idfSpeciesTypeToAnimalAge
            FROM dbo.trtSpeciesTypeToAnimalAge
            WHERE idfsAnimalAge = @idfsAnimalAge
                  AND idfsSpeciesType = @idfsSpeciesType
                  AND idfSpeciesTypeToAnimalAge <> @idfSpeciesTypeToAnimalAge
                  AND intRowStatus = 0
        )
                  AND @idfSpeciesTypeToAnimalAge IS NOT NULL
              )
        BEGIN
            SELECT @ReturnCode = 1;
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfSpeciesTypeToAnimalAge =
            (
                SELECT idfSpeciesTypeToAnimalAge
                FROM dbo.trtSpeciesTypeToAnimalAge
                WHERE idfsAnimalAge = @idfsAnimalAge
                      AND idfsSpeciesType = @idfsSpeciesType
                      AND intRowStatus = 0
            );
        END
        ELSE IF (
                    EXISTS
             (
                 SELECT idfSpeciesTypeToAnimalAge
                 FROM dbo.trtSpeciesTypeToAnimalAge
                 WHERE idfsAnimalAge = @idfsAnimalAge
                       AND idfsSpeciesType = @idfsSpeciesType
                       AND intRowStatus = 1
             )
                    AND @idfSpeciesTypeToAnimalAge IS NULL
                )
        BEGIN
            UPDATE dbo.trtSpeciesTypeToAnimalAge
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfsAnimalAge = @idfsAnimalAge
                  AND idfsSpeciesType = @idfsSpeciesType
                  AND intRowStatus = 1
            SELECT @idfSpeciesTypeToAnimalAge =
            (
                SELECT idfSpeciesTypeToAnimalAge
                FROM dbo.trtSpeciesTypeToAnimalAge
                WHERE idfsAnimalAge = @idfsAnimalAge
                      AND idfsSpeciesType = @idfsSpeciesType
                      AND intRowStatus = 1
            )
        END
        ELSE IF (EXISTS
             (
                 SELECT idfSpeciesTypeToAnimalAge
                 FROM dbo.trtSpeciesTypeToAnimalAge
                 WHERE idfSpeciesTypeToAnimalAge = @idfSpeciesTypeToAnimalAge
                       AND intRowStatus = 0
             )
                )
        BEGIN
            UPDATE dbo.trtSpeciesTypeToAnimalAge
            SET idfsSpeciesType = @idfsSpeciesType,
                idfsAnimalAge = @idfsAnimalAge, 
                AuditUpdateDTM = GETDATE(), 
                AuditUpdateUser = @AuditUserName 
            WHERE idfSpeciesTypeToAnimalAge = @idfSpeciesTypeToAnimalAge
                  AND intRowStatus = 0
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtSpeciesTypeToAnimalAge',
                                           @idfSpeciesTypeToAnimalAge OUTPUT;

            INSERT INTO dbo.trtSpeciesTypeToAnimalAge
            (
                idfSpeciesTypeToAnimalAge,
                idfsSpeciesType,
                idfsAnimalAge,
                intRowStatus, 
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfSpeciesTypeToAnimalAge, @idfsSpeciesType, @idfsAnimalAge, 0, GETDATE(), @AuditUserName);

            INSERT INTO dbo.trtSpeciesTypeToAnimalAgeToCP
            (
                idfSpeciesTypeToAnimalAge,
                idfCustomizationPackage, 
                AuditCreateDTM, 
                AuditCreateUser
            )
            VALUES
            (@idfSpeciesTypeToAnimalAge, dbo.FN_GBL_CustomizationPackage_GET(), GETDATE(), @AuditUserName);
        END

        INSERT INTO @SuppressSelect 
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfSpeciesTypeToAnimalAge,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfSpeciesTypeToAnimalAge AS 'idfSpeciesTypeToAnimalAge';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
