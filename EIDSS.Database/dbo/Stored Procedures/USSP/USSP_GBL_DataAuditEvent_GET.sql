-- =============================================
-- Author:		Steven Verner
-- Create date: 2.2.2022
-- Description:	Gets the audit event for the given user
-- Added Additional input Parameters  @idfsDataAuditObjectType,@idfMainObject,@idfMainObjectTable
-- =============================================
CREATE PROCEDURE [dbo].[USSP_GBL_DataAuditEvent_GET] 
		-- Add the parameters for the stored procedure here
	@idfUserId BIGINT = NULL, 
	@idfSiteId BIGINT = NULL,
	@idfsDataAuditEventType BIGINT=NULL,
	@idfsDataAuditObjectType BIGINT=NULL,
	@idfMainObject BIGINT=NULL,
	@idfMainObjectTable BIGINT=NULL,
	@event BIGINT OUTPUT

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @officeid BIGINT
	DECLARE @siteid BIGINT 
	DECLARE @aspnetUserId UNIQUEIDENTIFIER

	-- Get the user's siteid...
	SELECT @aspnetUserId = ID FROM aspnetUsers WHERE idfUserID = @idfUserId
	SELECT @officeid = idfInstitution FROM EmployeeToInstitution eti WHERE eti.aspNetUserId = @aspnetUserId AND eti.IsDefault = 1
	if (@idfSiteId != NULL)
		SELECT @siteid = idfsSite FROM tstsite WHERE idfOffice = @officeid
	ELSE
		SEt @siteid= @idfSiteId

	SELECT @event = idfDataAuditEvent 
	FROM tstLocalConnectionContext lcc 
	WHERE @idfUserId = @idfUserId

	IF @event is null
	BEGIN
		EXEC USP_GBL_NEXTKEYID_GET 'tauDataAuditEvent', @event OUTPUT

		INSERT INTO [tauDataAuditEvent] (
			[idfDataAuditEvent],
			[idfsDataAuditObjectType],
			[idfsDataAuditEventType],
			[idfMainObject],
			[idfMainObjectTable],
			[idfUserID],
			[idfsSite],
			[datEnteringDate]
		) 
		values
			(@event,
			@idfsDataAuditObjectType,
			@idfsDataAuditEventType, 
			@idfMainObject,
			@idfMainObjectTable,
			@idfUserId,
			@siteid,
			GETDATE()
			)

			UPDATE tstLocalConnectionContext
			SET idfDataAuditEvent = @event
			WHERE idfUserID = @idfUserId
	END 
END

