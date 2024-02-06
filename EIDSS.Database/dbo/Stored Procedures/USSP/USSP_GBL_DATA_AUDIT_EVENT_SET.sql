-- ================================================================================================
-- Name: USSP_GBL_DATA_AUDIT_EVENT_SET
--
-- Description:	Inserts a new record into the data audit event table.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/03/2023 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_DATA_AUDIT_EVENT_SET] 
	@idfUserId BIGINT = NULL, 
	@idfSiteId BIGINT = NULL,
	@idfsDataAuditEventType BIGINT=NULL,
	@idfsDataAuditObjectType BIGINT=NULL,
	@idfMainObject BIGINT=NULL,
	@idfMainObjectTable BIGINT=NULL,
	@strMainObject NVARCHAR(200)=NULL,
	@event BIGINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @officeid BIGINT
	DECLARE @siteid BIGINT 
	DECLARE @aspnetUserId UNIQUEIDENTIFIER

	-- Get the user's siteid...
	SELECT @aspnetUserId = ID FROM dbo.aspnetUsers WHERE idfUserID = @idfUserId;
	SELECT @officeid = idfInstitution FROM dbo.EmployeeToInstitution eti WHERE eti.aspNetUserId = @aspnetUserId AND eti.IsDefault = 1;
	IF (@idfSiteId != NULL)
		SELECT @siteid = idfsSite FROM dbo.tstsite WHERE idfOffice = @officeid;
	ELSE
		SET @siteid= @idfSiteId;

	SELECT @event = idfDataAuditEvent 
	FROM dbo.tstLocalConnectionContext lcc 
	WHERE @idfUserId = @idfUserId;

	IF @event is null
	BEGIN
		EXEC dbo.USP_GBL_NEXTKEYID_GET 'tauDataAuditEvent', @event OUTPUT;

		INSERT INTO dbo.tauDataAuditEvent (
			idfDataAuditEvent,
			idfsDataAuditObjectType,
			idfsDataAuditEventType,
			idfMainObject,
			idfMainObjectTable,
			idfUserID,
			idfsSite,
			datEnteringDate,
			strMainObject
		) 
		VALUES
			(@event,
			@idfsDataAuditObjectType,
			@idfsDataAuditEventType, 
			@idfMainObject,
			@idfMainObjectTable,
			@idfUserId,
			@siteid,
			GETDATE(),
			@strMainObject
			);

			UPDATE dbo.tstLocalConnectionContext
			SET idfDataAuditEvent = @event
			WHERE idfUserID = @idfUserId;
	END 
END

