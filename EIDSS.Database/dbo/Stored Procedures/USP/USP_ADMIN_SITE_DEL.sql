-- ================================================================================================
-- Name: USP_ADMIN_SITE_DEL
--
-- Description:	Sets a site record to "inactive".
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/12/2019 Initial release.
-- Mark Wilson      02/07/2023 Removed checks for child objects per conversation with Anatoliy.
--                             Also, added code to deactivate users and roles associated with the site.
-- Stephen Long     04/19/2023 Removed language ID parameter.

/*

EXEC dbo.USP_ADMIN_SITE_DEL 
	@LanguageID = 'en-US',
	@SiteID = 3614,
	@UserName = 'Mark'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SITE_DEL]
(
    @SiteID BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS'

        -- table to hold list of Employees to delete
        DECLARE @tlbEmployee TABLE (idfEmployee BIGINT);
        --------------------------------------------------------------------------------------------------------------------
        --- Disable all users and roles associated with this site before the site is de-activated
        --------------------------------------------------------------------------------------------------------------------
        INSERT INTO @tlbEmployee
        SELECT idfEmployee
        FROM dbo.tlbEmployee
        WHERE idfsSite = @SiteID;

        UPDATE dbo.tlbEmployeeGroup
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfsSite = @SiteID;

        UPDATE dbo.tlbEmployee
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfsSite = @SiteID;

        UPDATE dbo.LkupRoleSystemFunctionAccess
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfEmployee IN (
                                 SELECT idfEmployee FROM @tlbEmployee
                             );

        --------------------------------------------------------------------------------------------------------------------
        --- preceding lines were added to disable users and roles associated with the deleted sites
        --------------------------------------------------------------------------------------------------------------------		

        UPDATE dbo.tstSite
        SET intRowStatus = 1,
            AuditUpdateDTM = GETDATE(),
            AuditUpdateUser = @AuditUserName
        WHERE idfsSite = @SiteID;


        IF @@TRANCOUNT > 0
           AND @returnCode = 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
