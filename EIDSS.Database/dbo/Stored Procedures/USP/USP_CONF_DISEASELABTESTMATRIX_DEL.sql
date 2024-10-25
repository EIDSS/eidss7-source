-- ================================================================================================
-- Name: USP_CONF_DISEASELABTESTMATRIX_DEL
--
-- Description: Removes a disease to lab test matrix given an ID and whether or not to delete 
-- regardless of reference.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name:				Date       Change
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss           04/08/2019 Initial Release
-- Stephen Long         04/14/2023 Added site alert logic.
--
-- EXEC USP_CONF_DISEASELABTESTMATRIX_DEL 6707170000001, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASELABTESTMATRIX_DEL]
(
    @idfTestforDisease BIGINT,
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
        UPDATE dbo.trtTestForDisease
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfTestForDisease = @idfTestforDisease;

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfTestforDisease,
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
