-- ================================================================================================
-- Name: USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DEL
--
-- Description: Removes an active species types to animal age matrix given an id and the ability to 
-- delete regardless of being referenced. 
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		04/16/2019 Initial Release
-- Stephen Long     04/14/2023 Added site alert logic.
--
-- USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DEL 838610000000, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DEL]
(
    @idfSpeciesTypeToAnimalAge BIGINT,
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
        UPDATE dbo.trtSpeciesTypeToAnimalAge
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfSpeciesTypeToAnimalAge = @idfSpeciesTypeToAnimalAge;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfSpeciesTypeToAnimalAge,
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
