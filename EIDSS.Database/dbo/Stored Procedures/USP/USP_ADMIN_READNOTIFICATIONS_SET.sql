/*******************************************************
NAME						: [USP_ADMIN_READNOTIFICATIONS_SET]	


Description					: Updates the Notification Process after it has been read

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					7-5-19							Initial Created
*******************************************************/
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_READNOTIFICATIONS_SET]
( 

   @NotificationID BIGINT
   ,@UPDATEUSER VARCHAR(Max)
   
 
)
AS

DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0 


BEGIN
	BEGIN TRY  	

  IF EXISTS (SELECT * FROM tstNotificationStatus where idfNotification = @NotificationID AND intProcessed = 0)
   BEGIN
		UPDATE tstNotificationStatus 
			SET intProcessed = 1 , AuditUpdateDTM = GETDATE(),AuditUpdateUser = @UPDATEUSER
		WHERE idfNotification = @NotificationID AND intProcessed = 0
		SELECT @returnCode 'ReturnCode', @returnMsg 'RetunMessage',@NotificationID 'idfNotification'
   END
	END TRY  

	BEGIN CATCH  

			Throw;
	END CATCH 
	
END





