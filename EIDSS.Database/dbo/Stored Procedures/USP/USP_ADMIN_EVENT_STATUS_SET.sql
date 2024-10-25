-- ================================================================================================
-- Name: USP_ADMIN_EVENT_STATUS_SET		
--
-- Description: Updates an event notification status.
--
-- Author: Stephen Long
--
-- Revision History:
-- Name	                      Date       Change Detail
-- -------------------------- ---------- ---------------------------------------------------------
-- Stephen Long               07/07/2022 Initial release
-- Stephen Long               09/14/2022 Changed where clause from site ID or user ID to and
--                                       operator.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EVENT_STATUS_SET]
(
    @SiteId BIGINT,
    @UserId BIGINT,
    @EventId BIGINT = NULL,
    @StatusValue INT,
    @AuditUserName VARCHAR(200) = NULL
)
AS
DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
        @ReturnCode BIGINT = 0;
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@EventId IS NOT NULL)
        BEGIN
            UPDATE dbo.tstEvent
            SET intProcessed = @StatusValue,
                AuditUpdateUser = @AuditUserName, 
                AuditUpdateDTM = GETDATE()
            WHERE idfEventID = @EventId 
                  AND idfUserID = @UserId;
        END
        ELSE
        BEGIN
            UPDATE e
            SET e.intProcessed = @StatusValue,
                AuditUpdateUser = @AuditUserName, 
                AuditUpdateDTM = GETDATE() 
            FROM dbo.tstEvent e
            WHERE (
                      e.idfsSite = @SiteId
                      AND e.idfUserID = @UserId
                  )
                  AND e.intProcessed IN ( 0, 1 );
        END

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK
        END;
        THROW;
    END CATCH
END
