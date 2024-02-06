-- ================================================================================================
-- NAME						: [USP_ADMIN_NOTIFICATION_SET]		
--
-- Description					: CREATES A NEW NOTIFICATION
--
-- Author						: Lamont Mitchell
--
--Revision History
--			Name							Date								Change Detail
--			Lamont Mitchell					7-5-19							Initial Created
-- Stephen Long                             09/11/2019                      Added dbo prefix.
-- Stephen Long                             07/05/2022 Corrected spelling of event subscription 
--                                                     table.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_NOTIFICATION_SET]
( 
    @USER VARCHAR(max) = ''
   ,@EVENTID BIGINT 
   ,@siteID BIGINT
)
AS
Declare @msg VARCHAR(max)
DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0 
Declare @idfNotification BIGINT
Declare @SupressSelect TABLE
			( retrunCode INT,
			  returnMessage VARCHAR(200)
			)
BEGIN
	BEGIN TRY  	
	BEGIN TRANSACTION
	IF EXISTS( Select * FROM dbo.EventSubscription WHERE EventNameID = @EVENTID AND ReceiveAlertFlag = 1)
		BEGIN
 
			SELECT @msg = strDefault FROM dbo.trtBaseReference where idfsBaseReference = @EVENTID
			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tstNotification', @idfNotification OUTPUT
			INSERT INTO [dbo].[tstNotification] 
			(IdfNotification,idfsNotificationType,strPayload, datCreationDate,idfsSite, AuditCreateUser)
			VALUES
			(@idfNotification,@EVENTID,@msg, GETDATE(),@siteID, @USER)

			INSERT INTO dbo.tstNotificationStatus
			(IdfNotification,intProcessed,AuditCreateUser, AuditCreateDTM)
			VALUES
			(@idfNotification,0,@USER,GETDATE())

		END

		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode 'ReturnCode', @returnMsg 'RetunMessage',@idfNotification 'idfNotification'
	END TRY  

	BEGIN CATCH  
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END;
		Throw
	END CATCH 
END
