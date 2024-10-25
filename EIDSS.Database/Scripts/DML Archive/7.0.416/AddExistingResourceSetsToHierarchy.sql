
SET XACT_ABORT ON 
SET NOCOUNT ON 


declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''


BEGIN TRAN

BEGIN TRY

  declare @idfsResourceSet bigint
  declare @idfResourceHierarchy bigint
  declare @ResourceNode hierarchyid
  declare @AuditDateTime datetime = getutcdate()

  set @idfsResourceSet = 150 /*Error Messages*/
  set @idfResourceHierarchy = 578
  set @ResourceNode = hierarchyid::Parse('/3/501/') /*Global>Error Messages*/

  if not exists (select 1 from dbo.trtResourceSetHierarchy rsh where rsh.idfsResourceSet = @idfsResourceSet and rsh.ResourceSetNode = @ResourceNode)
		and not exists (select 1 from dbo.trtResourceSetHierarchy rsh where rsh.idfResourceHierarchy = @idfResourceHierarchy)
  begin
	insert into dbo.trtResourceSetHierarchy(idfResourceHierarchy, idfsResourceSet, ResourceSetNode, intOrder, intRowStatus, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	select	@idfResourceHierarchy, rs.idfsResourceSet, @ResourceNode, null, 0, 10519001 /*EIDSSv7*/, null, N'System', @AuditDateTime, N'System', @AuditDateTime
	from		dbo.trtResourceSet rs
	where		rs.idfsResourceSet = @idfsResourceSet
	print N'Hierarchy record for Resource Set ' + cast(@idfsResourceSet as nvarchar(20)) + N' - insert: ' + cast(@@rowcount as nvarchar(20))
  end

  set @idfsResourceSet = 255 /*Warning Messages*/
  set @idfResourceHierarchy = 579
  set @ResourceNode = hierarchyid::Parse('/3/502/') /*Global>Warning Messages*/


  if not exists (select 1 from dbo.trtResourceSetHierarchy rsh where rsh.idfsResourceSet = @idfsResourceSet and rsh.ResourceSetNode = @ResourceNode)
		and not exists (select 1 from dbo.trtResourceSetHierarchy rsh where rsh.idfResourceHierarchy = @idfResourceHierarchy)
  begin
	insert into dbo.trtResourceSetHierarchy(idfResourceHierarchy, idfsResourceSet, ResourceSetNode, intOrder, intRowStatus, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	select	@idfResourceHierarchy, rs.idfsResourceSet, @ResourceNode, null, 0, 10519001 /*EIDSSv7*/, null, N'System', @AuditDateTime, N'System', @AuditDateTime
	from		dbo.trtResourceSet rs
	where		rs.idfsResourceSet = @idfsResourceSet
	print N'Hierarchy record for Resource Set ' + cast(@idfsResourceSet as nvarchar(20)) + N' - insert: ' + cast(@@rowcount as nvarchar(20))
  end



END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = /*N'ErrorNumber: ' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+*/ N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();
	
	if	@Error <> 0
	begin
			
		RAISERROR (N'Error %d: %s.', -- Message text.
			   16, -- Severity,
			   1, -- State,
			   @Error,
			   @ErrorMsg) WITH SETERROR; -- Second argument.
	end
    
END CATCH;


IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

SET NOCOUNT OFF 
SET XACT_ABORT OFF 
