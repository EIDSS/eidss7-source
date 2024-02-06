CREATE PROCEDURE [dbo].[USP_GBL_LogSecurityEvent]
(
	@idfUserID Bigint = Null
	,@idfsAction bigint
	,@success bit--success	
	,@strErrorText As Nvarchar(200) = Null
	,@strDescription As Nvarchar(200) = Null
	,@idfObjectID as bigint =0
	,@idfsProcessType as bigint = 10130000--eidss
)
AS

Begin

	DECLARE @SupressSelect table
	( 
		retrunCode int,
		returnMessage varchar(200)
	)


	DECLARE @ID BIGINT
	
	INSERT INTO @SupressSelect
	EXEC dbo.USP_GBL_NEXTKEYID_GET 'tstSecurityAudit', @ID OUTPUT

	insert into dbo.tstSecurityAudit(
		idfSecurityAudit
		,idfsAction
		,idfsResult
		,idfUserID
		,datActionDate
		,idfsProcessType
		,idfAffectedObjectType
		,idfObjectID
		,strErrorText
		,strProcessID
		,strDescription
	)
	values
	(
		@ID
		,@idfsAction--@typeID
		,case @success when 1 then 10120000 else 10120001 end
		,@idfUserID
		,GetUtcDate()
		,@idfsProcessType
		,0
		,@idfObjectID
		,@strErrorText
		,dbo.fnGetContext()
		,@strDescription
	)
END


