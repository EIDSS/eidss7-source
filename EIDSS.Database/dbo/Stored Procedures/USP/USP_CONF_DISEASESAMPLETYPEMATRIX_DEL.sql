-- ================================================================================================
-- Name: USP_CONF_DISEASESAMPLETYPEMATRIX_DEL
--
-- Description: Removes a Disease to sample type matrix given an id and whether or not to delete 
-- regardless of reference
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name:				Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss           04/08/2019 Initial Release
-- Stephen Long         04/14/2023 Added site alert logic.
--
-- EXEC USP_CONF_DISEASESAMPLETYPEMATRIX_DEL 800110000007, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASESAMPLETYPEMATRIX_DEL]
(
	@idfMaterialForDisease BIGINT,
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
		UPDATE dbo.trtMaterialForDisease 
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfMaterialForDisease = @idfMaterialForDisease;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfMaterialForDisease,
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
