
-- ================================================================================================
-- NAME						: [USP_ADMIN_NOTIFICATIONS_STATUS_SET]		
--
-- Description					: Update notification status
--
-- Author						: Mani Govindarajan
--
--Revision History
--			Name							Date								Change Detail
--			Mani Govindarajan				02/16/2022							Initial Created

-- ================================================================================================

CREATE PROCEDURE USP_ADMIN_NOTIFICATIONS_STATUS_SET
(	@SiteId BIGINT
    ,@UserId BIGINT
	,@NotificationId BIGINT = NULL
	,@StatusValue INT
	,@AuditUser VARCHAR(100)=NULL
)
AS
DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0 
BEGIN
	BEGIN TRY  
		BEGIN TRANSACTION
			IF (@NotificationId IS NOT NULL)
			BEGIN
				UPDATE dbo.tstNotificationStatus SET intProcessed =@StatusValue ,AuditUpdateUser= @AuditUser WHERE idfNotification =@NotificationId
			END
			ELSE
			BEGIN
				UPDATE  ns 
					SET ns.intProcessed =@StatusValue,AuditUpdateUser= @AuditUser 
				FROM dbo.tstNotificationStatus ns INNER JOIN
					dbo.tstNotification n ON n.idfNotification = ns.idfNotification
				WHERE 
					((
				(
				(n.idfsTargetSite =@SiteId) OR (n.idfsTargetSite IS  NULL AND n.idfsSite = @SiteId))) 
				OR
				((n.idfTargetUserID =@UserId) OR (n.idfTargetUserID IS  NULL AND n.idfUserID = @UserId) ))
				AND ns.intProcessed IN (0,1)
			
			END

			IF @@TRANCOUNT > 0 
				COMMIT  
		 SELECT @returnCode 'ReturnCode', @returnMsg 'RetunMessage'
	END TRY  
	BEGIN CATCH  
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END;
		Throw
	END CATCH 
END

