﻿
--

SET XACT_ABORT ON 
SET NOCOUNT ON 

/*Specify or update name of the EIDSSv7 database here
  Note: (1) Database shall exist with schemas of the tables except triggers and foreign keys.
		(2) Script is not applicable for cloud-hosted databases.
		(3) Stored Procedure sp_executesql shall be enabled for the instance of SQL Server, where database triggers and foreign keys shall be created.
*/
declare @DbName sysname = 'EIDSS7'

declare @cmd nvarchar(max) = N''

declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''

if not exists (select 1 from sys.databases where [name] = @DbName collate Latin1_General_CI_AS)
begin
	set @Error = 1
	set @ErrorMsg = N'Database with name [' + isnull(@DbName, N'') + N'] does not exists. Please specify name of existing database with empty schema again.'
end
else begin
	declare @isDbWithTables bit = 0
	declare @isDbWithTriggersOrFKs bit = 0

	set @cmd = N'
	set @isDbWithTablesOut = 0
	if exists (select 1 from [' + @DbName + N'].sys.tables)
	begin
		set @isDbWithTablesOut = 1
	end

	set @isDbWithTriggersOrFKsOut = 0
	if exists (select 1 from [' + @DbName + N'].sys.triggers)
		or exists (select 1 from [' + @DbName + N'].sys.foreign_keys)
	begin
		set @isDbWithTriggersOrFKsOut = 1
	end
	'
	exec sp_executesql 
			@cmd, 
			N'@isDbWithTablesOut bit output,  @isDbWithTriggersOrFKsOut bit output', 
			@isDbWithTablesOut = @isDbWithTables output,
			@isDbWithTriggersOrFKsOut = @isDbWithTriggersOrFKs output

	if @isDbWithTables = 0
	begin
		set @Error = 1
		set @ErrorMsg = N'Database with name [' + isnull(@DbName, N'') + N'] does not have tables. No changes will be applied. Please specify name of existing database with tables and no triggers or foreign keys, and then execute script again.'
	end
	else if @isDbWithTriggersOrFKs = 1
	begin
		set @Error = 1
		set @ErrorMsg = N'Database with name [' + isnull(@DbName, N'') + N'] contains triggers or foreign keys. No changes will be applied. Please specify name of existing database with tables and no triggers or foreign keys, and then execute script again.'
	end
end

if @Error <> 0
begin
	raiserror(@ErrorMsg, 16, 1) with seterror;
end
else begin

set @cmd = N''



----


-- Triggers --



--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_AccessRule_A_Update] ON [dbo].[AccessRule]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(AccessRuleID) )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_AccessRule_I_Delete] ON [dbo].[AccessRule]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([AccessRuleID]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [AccessRuleID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [AccessRuleID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.AccessRule AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.AccessRuleID = b.AccessRuleID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_AppSessionLog_A_Update] ON [dbo].[AppSessionLog]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE(AppSessionLogUID))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ArchiveSetting_A_Update] ON [dbo].[ArchiveSetting]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE(ArchiveSettingUID))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ArchiveSetting_I_Delete] ON [dbo].[ArchiveSetting]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([ArchiveSettingUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [ArchiveSettingUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [ArchiveSettingUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ArchiveSetting as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.ArchiveSettingUID = b.ArchiveSettingUID;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_CampaignToSampleType_A_Update] ON [dbo].[CampaignToSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork()=1 AND UPDATE(CampaignToSampleTypeUID))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_CampaignToSampleType_I_Delete] ON [dbo].[CampaignToSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([CampaignToSampleTypeUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [CampaignToSampleTypeUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [CampaignToSampleTypeUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.CampaignToSampleType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.CampaignToSampleTypeUID = b.CampaignToSampleTypeUID;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_DiagnosisGroupToGender_A_Update] on [dbo].[DiagnosisGroupToGender]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(DisgnosisGroupToGenderUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_DiagnosisGroupToGender_I_Delete] on [dbo].[DiagnosisGroupToGender]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([DisgnosisGroupToGenderUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [DisgnosisGroupToGenderUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [DisgnosisGroupToGenderUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.DiagnosisGroupToGender as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[DisgnosisGroupToGenderUID] = b.[DisgnosisGroupToGenderUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_dotNetAppenderLog_A_Update] ON [dbo].[dotNetAppenderLog]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork()=1 AND UPDATE(dotNetAppenderLogUID))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_EmployeeToInstitution_A_Update] on [dbo].[EmployeeToInstitution]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(EmployeeToInstitution))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_EmployeeToInstitution_I_Delete] on [dbo].[EmployeeToInstitution]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([EmployeeToInstitution]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EmployeeToInstitution] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EmployeeToInstitution] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.EmployeeToInstitution as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[EmployeeToInstitution] = b.[EmployeeToInstitution];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_ffDecorElement_A_Update] ON [dbo].[ffDecorElement]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDecorElement) )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDecorElement_I_Delete] ON [dbo].[ffDecorElement]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDecorElement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffDecorElement AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDecorElement = b.idfDecorElement'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDecorElementLine_A_Update] ON [dbo].[ffDecorElementLine]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDecorElement) )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDecorElementLine_I_Delete] ON [dbo].[ffDecorElementLine]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDecorElement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffDecorElementLine as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDecorElement = b.idfDecorElement;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDecorElement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffDecorElement as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDecorElement = b.idfDecorElement;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDecorElementText_A_Update] ON [dbo].[ffDecorElementText]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDecorElement) )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDecorElementText_I_Delete] on [dbo].[ffDecorElementText]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDecorElement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffDecorElementText as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDecorElement = b.idfDecorElement;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDecorElement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDecorElement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffDecorElement as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDecorElement = b.idfDecorElement;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDeterminantType_A_Update] on [dbo].[ffDeterminantType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDeterminantType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDeterminantValue_A_Update] on [dbo].[ffDeterminantValue]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDeterminantValue))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffDeterminantValue_I_Delete] on [dbo].[ffDeterminantValue]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDeterminantValue]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDeterminantValue] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDeterminantValue] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffDeterminantValue as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDeterminantValue = b.idfDeterminantValue;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffFormTemplate_A_Update] ON [dbo].[ffFormTemplate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF((dbo.FN_GBL_TriggersWork ()=1) AND UPDATE(idfsFormTemplate))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffFormTemplate_I_Delete] on [dbo].[ffFormTemplate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsFormTemplate]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffFormTemplate as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsFormTemplate = b.idfsFormTemplate;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsFormTemplate]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsFormTemplate;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameter_A_Update] on [dbo].[ffParameter]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfsParameter))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameter_I_Delete] on [dbo].[ffParameter]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsParameter]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameter] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameter] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameter as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsParameter = b.idfsParameter;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsParameter]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameter] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameter] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsParameter;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterDesignOption_A_Update] ON [dbo].[ffParameterDesignOption]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfParameterDesignOption))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterDesignOption_I_Delete] on [dbo].[ffParameterDesignOption]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfParameterDesignOption]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfParameterDesignOption] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfParameterDesignOption] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameterDesignOption as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfParameterDesignOption = b.idfParameterDesignOption;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterFixedPresetValue_A_Update] ON [dbo].[ffParameterFixedPresetValue]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfsParameterFixedPresetValue))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterFixedPresetValue_I_Delete] on [dbo].[ffParameterFixedPresetValue]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsParameterFixedPresetValue]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterFixedPresetValue] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterFixedPresetValue] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameterFixedPresetValue as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsParameterFixedPresetValue = b.idfsParameterFixedPresetValue;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsParameterFixedPresetValue]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterFixedPresetValue] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterFixedPresetValue] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsParameterFixedPresetValue;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterForAction_A_Update] ON [dbo].[ffParameterForAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfParameterForAction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterForAction_I_Delete] on [dbo].[ffParameterForAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfParameterForAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfParameterForAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfParameterForAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameterForAction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfParameterForAction = b.idfParameterForAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterForFunction_A_Update] ON [dbo].[ffParameterForFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfParameterForFunction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterForFunction_I_Delete] on [dbo].[ffParameterForFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfParameterForFunction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfParameterForFunction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfParameterForFunction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameterForFunction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfParameterForFunction = b.idfParameterForFunction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterForTemplate_A_Update] ON [dbo].[ffParameterForTemplate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfsFormTemplate) OR UPDATE(idfsParameter))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterForTemplate_I_Delete] on [dbo].[ffParameterForTemplate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsFormTemplate], [idfsParameter]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate], [idfsParameter] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate], [idfsParameter] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameterForTemplate as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsFormTemplate = b.idfsFormTemplate'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsParameter = b.idfsParameter;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterType_A_Update] ON [dbo].[ffParameterType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfsParameterType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffParameterType_I_Delete] on [dbo].[ffParameterType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsParameterType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffParameterType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsParameterType = b.idfsParameterType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsParameterType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsParameterType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsParameterType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffRule_A_Update] ON [dbo].[ffRule]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(idfsRule))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffRule_I_Delete] on [dbo].[ffRule]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsRule]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRule] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRule] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffRule as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsRule = b.idfsRule;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsRule]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRule] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRule] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsRule;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffRuleConstant_A_Update] ON [dbo].[ffRuleConstant]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (TRIGGER_NESTLEVEL()<2)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfRuleConstant))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffRuleConstant_I_Delete] on [dbo].[ffRuleConstant]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfRuleConstant]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfRuleConstant] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfRuleConstant] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffRuleConstant as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfRuleConstant = b.idfRuleConstant;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffRuleFunction_A_Update] ON [dbo].[ffRuleFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (TRIGGER_NESTLEVEL()<2)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsRuleFunction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSection_A_Update] ON [dbo].[ffSection]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSection))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSection_I_Delete] on [dbo].[ffSection]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSection]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSection] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSection] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffSection as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSection = b.idfsSection;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSectionDesignOption_A_Update] ON [dbo].[ffSectionDesignOption]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSectionDesignOption))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSectionDesignOption_I_Delete] on [dbo].[ffSectionDesignOption]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSectionDesignOption]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSectionDesignOption] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSectionDesignOption] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffSectionDesignOption as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSectionDesignOption = b.idfSectionDesignOption;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSectionForAction_A_Update] ON [dbo].[ffSectionForAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (TRIGGER_NESTLEVEL()<2)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSectionForAction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSectionForAction_I_Delete] on [dbo].[ffSectionForAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSectionForAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSectionForAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSectionForAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffSectionForAction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSectionForAction = b.idfSectionForAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSectionForTemplate_A_Update] ON [dbo].[ffSectionForTemplate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsFormTemplate) OR UPDATE(idfsSection)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_ffSectionForTemplate_I_Delete] on [dbo].[ffSectionForTemplate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsFormTemplate], [idfsSection]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate], [idfsSection] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsFormTemplate], [idfsSection] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.ffSectionForTemplate as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsFormTemplate = b.idfsFormTemplate'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsSection = b.idfsSection;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisBaseReference_A_Update] ON [dbo].[gisBaseReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGISBaseReference))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- If the strDefault column was updated...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END ELSE IF( UPDATE(strDefault))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DECLARE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			 @idfsGISReferenceType BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			,@oldlocationName NVARCHAR(255)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			,@updatedLocationName NVARCHAR(255)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @idfsGISReferenceType = idfsGISReferenceType, @updatedlocationName = strDefault'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM INSERTED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @oldlocationName = strDefault'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- If the change was to any gisreference type...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- This test should ideally be testing if any one of the administrative level names changed...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- IF(@idfsGISReferenceTYpe IN( 19000001,19000002,19000003,19000004,AdminLevel5ID, AdminLevel6ID, AdminLevel7ID)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- GIS Reference Types for Admin Levels 5 thru 7 have yet to be created...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF(@idfsGISReferenceType IN('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT idfsGisReferenceType'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM gisReferenceType rt))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- Update the gisLocationDenormalized table with the updated location name...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE ld'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				 ld.Level1Name = CASE WHEN ld.Level1Name = @oldLocationName THEN @updatedLocationName ELSE Level1Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				,ld.Level2Name = CASE WHEN ld.Level2Name = @oldLocationName THEN @updatedLocationName ELSE Level2Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				,ld.Level3Name = CASE WHEN ld.Level3Name = @oldLocationName THEN @updatedLocationName ELSE Level3Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				,ld.Level4Name = CASE WHEN ld.Level4Name = @oldLocationName THEN @updatedLocationName ELSE Level4Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				,ld.Level5Name = CASE WHEN ld.Level5Name = @oldLocationName THEN @updatedLocationName ELSE Level5Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				,ld.Level6Name = CASE WHEN ld.Level6Name = @oldLocationName THEN @updatedLocationName ELSE Level6Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				,ld.Level7Name = CASE WHEN ld.Level7Name = @oldLocationName THEN @updatedLocationName ELSE Level7Name END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM gisLocationDenormalized ld'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			JOIN gisReferenceType rt ON rt.strGISReferenceTypeName = ld.LevelType'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHERE @oldlocationName IN(Level1Name,Level2Name,Level3Name,Level4Name,Level5Name,Level6Name,Level7Name)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisBaseReference_I_Delete] on [dbo].[gisBaseReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsGISBaseReference]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsGISBaseReference] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsGISBaseReference] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISBaseReference = b.idfsGISBaseReference;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisCountry_A_Update] ON [dbo].[gisCountry]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsCountry))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisCountry_I_Delete] on [dbo].[gisCountry]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsCountry]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsCountry] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsCountry] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisCountry as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsCountry = b.idfsCountry;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsCountry]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsCountry] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsCountry] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISBaseReference = b.idfsCountry;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisDistrictSubdistrict_A_Update] ON [dbo].[gisDistrictSubdistrict]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisLegendSymbol_A_Update] ON [dbo].[gisLegendSymbol]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfLegendSymbol))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisLocation_I_Delete] ON [dbo].[gisLocation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsLocation]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsLocation] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsLocation] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisLocation AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsLocation = b.idfsLocation;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Steven Verner'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: 1/4/2021'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Rebuilds gisLocationDenormalized when:'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- 1.  When a new location is inserted.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- 2.  When a location is re-parented (moved)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- 3.  When the location is deleted (intRowStatus = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- History:'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--	Date		Developer			Comments'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--	03/17/2022	Steven Verner		Fixed the issue where the incorrect level type was specified.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--  10/31/2022  Mani Govindarajan   Update the idfsLocation based on location Node and Node.ToString(), Updated the Final Insert-Selct Condition.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--  01/09/2023  Steven Verner		Modified gisStringNameTranslation joins to use left joins.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisLocation_UpdateDenormalizedHierarchy]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[gisLocation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   AFTER INSERT,DELETE,UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DECLARE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@current INT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@max INT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@languageId BIGINT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@hi HIERARCHYID ,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@hiString varchar(255);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DECLARE @t TABLE('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			L1ID BIGINT, L2ID BIGINT, L3ID BIGINT, L4ID BIGINT, L5ID BIGINT, L6ID BIGINT, L7ID BIGINT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			L1NAME NVARCHAR(255),L2NAME NVARCHAR(255),L3NAME NVARCHAR(255),L4NAME NVARCHAR(255),L5NAME NVARCHAR(255),L6NAME NVARCHAR(255),L7NAME NVARCHAR(255),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			Node HIERARCHYID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			[Level] INT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfsLocation BIGINT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			LanguageId BIGINT )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DECLARE @Languages TABLE(id INT IDENTITY, idfsLanguage BIGINT)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INSERT INTO @Languages(idfsLanguage)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT idfsLanguage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisLocationDenormalized ld'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		GROUP BY idfsLanguage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DECLARE @idfsLocation BIGINT = NULL,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@newParent HIERARCHYID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@oldParent HIERARCHYID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@newDeleted BIT,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@oldDeleted BIT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- The following use cases must be captured:'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- 1.  When a new location is inserted.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- 2.  When a location is re-parented (moved)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- 3.  When the location is deleted (intRowStatus = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- 4.  When the location name changes...  (This use case cannot be captured here; it must be captured on the trtBaseReference table trigger...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) -- This is an update'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--	===================================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--  Test to see if the location moved...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--	===================================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		 @idfsLocation = idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		,@newDeleted = CASE WHEN intRowStatus=1 THEN 1 ELSE 0 END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		,@newParent = NODE.GetAncestor(1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM Inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @oldDeleted = intRowStatus,  @oldParent = Node.GetAncestor(1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- We always remove all references of the location in the gislocationDenormalized table,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- then generate a new entry...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- This handles both when a record was deleted (intRowStatus=1) and the need to remove the existing recordsprior to generating a new one for reparenting...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- When the location has moved or the record is reactivated (intRowStatus = 0)...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF(@newParent != @oldParent)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			DELETE FROM gisLocationDenormalized WHERE idfsLocation = @idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			GOTO GenerateNewReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END ELSE IF( @newDeleted = 1 )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			DELETE FROM gisLocationDenormalized WHERE idfsLocation = @idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE IF(@oldDeleted =1 and @newDeleted = 0 )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				DELETE FROM gisLocationDenormalized WHERE idfsLocation = @idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				GOTO GenerateNewReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		GOTO Fini'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted) -- This is an insert'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- New location was inserted...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @idfsLocation = idfsLocation FROM inserted;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		GOTO GenerateNewReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted) -- this is a delete'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- Location was deleted...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @idfsLocation = idfsLocation FROM deleted;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE FROM dbo.gisLocationDenormalized WHERE idfsLocation = @idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	GOTO Fini'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	GenerateNewReference:'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--	===================================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @current = 1, @max= COUNT(*) FROM @Languages'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT @hi = Node, @hiString=Node.ToString()  FROM gisLocation l WHERE l.idfsLocation = @idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- iterate thru all the languages and insert the hierarchy record for each...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHILE (@current <= @max)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			--	Select a language...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT @languageId = idfsLanguage FROM @Languages WHERE id = @current'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- Perform the insert...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- 1st into table variable...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INSERT INTO @t('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						 L1ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L2ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L3ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L4ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L5ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L6ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L7ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L1NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L2NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L3NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L4NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L5NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L6NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,L7NAME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,Node'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,[Level]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						--,idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						,LanguageId)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- PIVOT!!!!!'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			-- Flatten the hierarchy and insert into gisLocationDenormalized...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				-- LevelIDs 1 thru 7...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=1 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=2 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=3 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=4 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=5 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=6 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=7 THEN idfsLocation END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				-- LevelNames 1 thru 7...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=1 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=2 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=3 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=4 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=5 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=6 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(CASE WHEN [Level]=7 THEN LevelName END ),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				-- Node...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(Node),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MAX(level),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				--MAX(idfsLocation),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				@languageId'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					l.Node.GetLevel() [Level]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					,COALESCE(snt.strTextString, b.strDefault) [LevelName]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					,b.strDefault [LevelNameDefault]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					,idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					,Node'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					--,LevelType.strTextString'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					 ,rn=ROW_NUMBER() OVER (PARTITION BY 0 ORDER BY node.GetLevel())'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				FROM gisLocation l'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				JOIN gisBaseReference b ON b.idfsGISBaseReference = l.idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				LEFT JOIN dbo.gisStringNameTranslation snt ON snt.idfsGISBaseReference = l.idfsLocation AND'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					snt.idfsLanguage = @languageId'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				WHERE @hi.IsDescendantOf(node) = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				) a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				-- Reset...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				SET @current = @current+1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				SELECT @languageId = NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- Update the idfsLocation...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE @t'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET idfsLocation ='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =1 AND  Node =@hiString THEN L1ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =2 AND  Node =@hiString THEN L2ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =3 AND  Node =@hiString THEN L3ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =4 AND  Node =@hiString THEN  L4ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =5 AND  Node =@hiString THEN   L5ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =6 AND  Node =@hiString THEN   L6ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN level =7 AND  Node =@hiString THEN   L7ID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- Finally, insert into gis table...'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INSERT INTO dbo.gisLocationDenormalized'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level1ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level2ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level3ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level4ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level5ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level6ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level7ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level1Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level2Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level3Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level4Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level5Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level6Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level7Name,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Node,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				Level,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfsLocation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				LevelType,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfsLanguage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT  L1ID,L2ID,L3ID,L4ID,L5ID,L6ID,L7ID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				L1NAME,L2NAME,L3NAME,L4NAME,L5NAME,L6NAME,L7NAME,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				node,[level],l.idfsLocation,COALESCE(lt.strTextString, T.strGISReferenceTypeName),l.LanguageId'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM @t l'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		JOIN gisBaseReference b ON b.idfsGISBaseReference = l.idfsLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		JOIN gisReferenceType t ON t.idfsGISReferenceType = b.idfsGISReferenceType'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		LEFT JOIN dbo.trtStringNameTranslation lt ON'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		lt.idfsLanguage = l.LanguageId AND lt.idfsBaseReference ='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		case l.level'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 1 THEN 10003001'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 2 THEN 10003003'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 3 THEN 10003002'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 4 THEN 10003004'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 5 THEN 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 6 THEN 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN 7 THEN 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE 0 END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	Fini:'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		-- Bye!'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RETURN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisMetadata_A_Update] ON [dbo].[gisMetadata]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(strLayer))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisNewID_A_Update] ON [dbo].[gisNewID]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(gisNewID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisOtherBaseReference_A_Update] ON [dbo].[gisOtherBaseReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGISOtherBaseReference))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisOtherStringNameTranslation_A_Update] ON [dbo].[gisOtherStringNameTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsgisOtherBaseReference)) OR UPDATE(idfsLanguage))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisRayon_A_Update] ON [dbo].[gisRayon]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsRayon))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisRayon_I_Delete] on [dbo].[gisRayon]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsRayon]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRayon] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRayon] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisRayon as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsRayon = b.idfsRayon;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsRayon]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRayon] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRayon] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISBaseReference = b.idfsRayon;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisReferenceType_A_Update] ON [dbo].[gisReferenceType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGISReferenceType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisReferenceType_I_Delete] on [dbo].[gisReferenceType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsGISReferenceType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsGISReferenceType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsGISReferenceType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisReferenceType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISReferenceType = b.idfsGISReferenceType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisRegion_A_Update] ON [dbo].[gisRegion]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsRegion))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisRegion_I_Delete] on [dbo].[gisRegion]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsRegion]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRegion] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRegion] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisRegion as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsRegion = b.idfsRegion;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsRegion]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRegion] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsRegion] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISBaseReference = b.idfsRegion;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisSettlement_A_Update] ON [dbo].[gisSettlement]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSettlement))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisSettlement_I_Delete] on [dbo].[gisSettlement]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSettlement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSettlement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSettlement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisSettlement as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSettlement = b.idfsSettlement;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSettlement]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSettlement] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSettlement] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISBaseReference = b.idfsSettlement;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisStringNameTranslation_A_Update] ON [dbo].[gisStringNameTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsGISBaseReference) OR UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisStringNameTranslation_I_Delete] on [dbo].[gisStringNameTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsGISBaseReference], [idfsLanguage]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsGISBaseReference], [idfsLanguage] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsGISBaseReference], [idfsLanguage] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.gisStringNameTranslation as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsGISBaseReference = b.idfsGISBaseReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsLanguage = b.idfsLanguage;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisUserLayer_A_Update] ON [dbo].[gisUserLayer]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(guidLayer))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBCountry_A_Update] ON [dbo].[gisWKBCountry]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBDistrict_A_Update] ON [dbo].[gisWKBDistrict]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBDistrictReady_A_Update] ON [dbo].[gisWKBDistrictReady]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(oid))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBEarthRoad_A_Update] ON [dbo].[gisWKBEarthRoad]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBForest_A_Update] ON [dbo].[gisWKBForest]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBHighway_A_Update] ON [dbo].[gisWKBHighway]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBInlandWater_A_Update] ON [dbo].[gisWKBInlandWater]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBLake_A_Update] ON [dbo].[gisWKBLake]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBLandUse_A_Update] ON [dbo].[gisWKBLandUse]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBMainRiver_A_Update] ON [dbo].[gisWKBMainRiver]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBMajorRoad_A_Update] ON [dbo].[gisWKBMajorRoad]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBPath_A_Update] ON [dbo].[gisWKBPath]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRailroad_A_Update] ON [dbo].[gisWKBRailroad]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRayon_A_Update] ON [dbo].[gisWKBRayon]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRayonReady_A_Update] ON [dbo].[gisWKBRayonReady]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(oid))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRegion_A_Update] ON [dbo].[gisWKBRegion]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRegionReady_A_Update] ON [dbo].[gisWKBRegionReady]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(oid))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRiver_A_Update] ON [dbo].[gisWKBRiver]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBRiverPolygon_A_Update] ON [dbo].[gisWKBRiverPolygon]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBSea_A_Update] ON [dbo].[gisWKBSea]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBSettlement_A_Update] ON [dbo].[gisWKBSettlement]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBSettlementReady_A_Update] ON [dbo].[gisWKBSettlementReady]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(oid))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_gisWKBSmallRiver_A_Update] ON [dbo].[gisWKBSmallRiver]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanActualAddlInfo_A_Update] ON [dbo].[HumanActualAddlInfo]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(HumanActualAddlInfoUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanActualAddlInfo_I_Delete] on [dbo].[HumanActualAddlInfo]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([HumanActualAddlInfoUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanActualAddlInfoUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanActualAddlInfoUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.HumanActualAddlInfo as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[HumanActualAddlInfoUID] = b.[HumanActualAddlInfoUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanAddlInfo_A_Update] ON [dbo].[HumanAddlInfo]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(HumanAdditionalInfo))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanAddlInfo_I_Delete] on [dbo].[HumanAddlInfo]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([HumanAdditionalInfo]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanAdditionalInfo] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanAdditionalInfo] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.HumanAddlInfo as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[HumanAdditionalInfo] = b.[HumanAdditionalInfo];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanDiseaseReportRelationship_A_Update] ON [dbo].[HumanDiseaseReportRelationship]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(HumanDiseasereportRelnUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanDiseaseReportRelationship_I_Delete] on [dbo].[HumanDiseaseReportRelationship]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([HumanDiseasereportRelnUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanDiseasereportRelnUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanDiseasereportRelnUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.HumanDiseaseReportRelationship as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[HumanDiseasereportRelnUID] = b.[HumanDiseasereportRelnUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanDiseaseReportVaccination_A_Update] ON [dbo].[HumanDiseaseReportVaccination]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(HumanDiseaseReportVaccinationUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_HumanDiseaseReportVaccination_I_Delete] on [dbo].[HumanDiseaseReportVaccination]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([HumanDiseaseReportVaccinationUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanDiseaseReportVaccinationUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [HumanDiseaseReportVaccinationUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.HumanDiseaseReportVaccination as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[HumanDiseaseReportVaccinationUID] = b.[HumanDiseaseReportVaccinationUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupEIDSSAppObject_A_Update] ON [dbo].[LkupEIDSSAppObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(AppObjectNameID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupEIDSSAppObject_I_Delete] on [dbo].[LkupEIDSSAppObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([AppObjectNameID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [AppObjectNameID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [AppObjectNameID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupEIDSSAppObject] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[AppObjectNameID] = b.[AppObjectNameID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([AppObjectNameID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [AppObjectNameID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [AppObjectNameID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[trtBaseReference] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfsBaseReference] = b.[AppObjectNameID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupEIDSSMenu_A_Update] ON [dbo].[LkupEIDSSMenu]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(EIDSSMenuID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupEIDSSMenu_I_Delete] on [dbo].[LkupEIDSSMenu]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([EIDSSMenuID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EIDSSMenuID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EIDSSMenuID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupEIDSSMenu] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[EIDSSMenuID] = b.[EIDSSMenuID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([EIDSSMenuID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EIDSSMenuID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EIDSSMenuID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[trtBaseReference] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfsBaseReference] = b.[EIDSSMenuID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupEIDSSMenuToSystemFunction_A_Update] ON [dbo].[LkupEIDSSMenuToSystemFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork () = 1 AND (UPDATE(EIDSSMenuID) AND UPDATE(SystemFunctionID)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupEIDSSMenuToSystemFunction_I_Delete] ON [dbo].[LkupEIDSSMenuToSystemFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([EIDSSMenuID], [SystemFunctionID]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EIDSSMenuID], [SystemFunctionID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [EIDSSMenuID], [SystemFunctionID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupEIDSSMenuToSystemFunction] AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[EIDSSMenuID] = b.[EIDSSMenuID]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.[SystemFunctionID] = b.[SystemFunctionID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LKUPNextKey_A_Update] ON [dbo].[LKUPNextKey]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(TableName))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupNextKey_I_Delete] on [dbo].[LkupNextKey]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([TableName]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [TableName] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [TableName] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupNextKey] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[TableName] = b.[TableName];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupRoleDashboardObject_A_Update] ON [dbo].[LkupRoleDashboardObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(DashboardObjectID) AND UPDATE(idfEmployee)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupRoleDashboardObject_I_Delete] on [dbo].[LkupRoleDashboardObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfEmployee], [DashboardObjectID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee], [DashboardObjectID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee], [DashboardObjectID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupRoleDashboardObject] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfEmployee] = b.[idfEmployee]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.[DashboardObjectID] = b.[DashboardObjectID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupRoleMenuAccess_A_Update] ON [dbo].[LkupRoleMenuAccess]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(EIDSSMenuID) AND UPDATE(idfEmployee)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupRoleMenuAccess_I_Delete] on [dbo].[LkupRoleMenuAccess]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfEmployee], [EIDSSMenuID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee], [EIDSSMenuID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee], [EIDSSMenuID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupRoleMenuAccess] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfEmployee] = b.[idfEmployee]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.[EIDSSMenuID] = b.[EIDSSMenuID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupRoleSystemFunctionAccess_A_Update] ON [dbo].[LkupRoleSystemFunctionAccess]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(SystemFunctionID) OR UPDATE(SystemFunctionOperationID) OR UPDATE(idfEmployee)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- Added 07 Dec 2020 to update the AuditUpdateDTM when the record is updated'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET a.AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.LkupRoleSystemFunctionAccess AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID AND a.idfEmployee = b.idfEmployee'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET a.AuditUpdateUser = SUSER_NAME()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.LkupRoleSystemFunctionAccess AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID AND a.idfEmployee = b.idfEmployee'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE NOT UPDATE(AuditUpdateUser)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupRoleSystemFunctionAccess_I_Delete] on [dbo].[LkupRoleSystemFunctionAccess]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfEmployee], [SystemFunctionID], [SystemFunctionOperationID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT Deleted.idfEmployee, [SystemFunctionID], [SystemFunctionOperationID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT idfEmployee, [SystemFunctionID], [SystemFunctionOperationID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupRoleSystemFunctionAccess] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfEmployee = b.idfEmployee'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.[SystemFunctionID] = b.[SystemFunctionID]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.[SystemFunctionOperationID] = b.[SystemFunctionOperationID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupSystemFunctionToOperation_A_Update] ON [dbo].[LkupSystemFunctionToOperation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(SystemFunctionID) AND UPDATE(SystemFunctionOperationID)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- Added 07 Dec 2020 to update the AuditUpdateDTM when the record is updated'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET a.AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.LkupSystemFunctionToOperation AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET a.AuditUpdateUser = SUSER_NAME()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.LkupSystemFunctionToOperation AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE NOT UPDATE(AuditUpdateUser)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_LkupSystemFunctionToOperation_I_Delete] on [dbo].[LkupSystemFunctionToOperation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([SystemFunctionID], [SystemFunctionOperationID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [SystemFunctionID], [SystemFunctionOperationID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [SystemFunctionID], [SystemFunctionOperationID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[LkupSystemFunctionToOperation] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[SystemFunctionID] = b.[SystemFunctionID]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.[SystemFunctionOperationID] = b.[SystemFunctionOperationID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
ALTER TABLE [dbo].[LkupSystemFunctionToOperation] ENABLE TRIGGER [TR_LkupSystemFunctionToOperation_I_Delete]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_locBaseReference_A_Update] ON [dbo].[locBaseReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idflBaseReference))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_locStringNameTranslation_A_Update] ON [dbo].[locStringNameTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idflBaseReference) OR UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_MonitoringSessionToSampleType_A_Update] ON [dbo].[MonitoringSessionToSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(MonitoringSessionToSampleType)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_MonitoringSessionToSampleType_I_Delete] on [dbo].[MonitoringSessionToSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([MonitoringSessionToSampleType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [MonitoringSessionToSampleType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [MonitoringSessionToSampleType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[MonitoringSessionToSampleType] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[MonitoringSessionToSampleType] = b.[MonitoringSessionToSampleType];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_OutbreakCaseContact_A_Update] ON [dbo].[OutbreakCaseContact]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(OutbreakCaseContactUID)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_OutbreakCaseContact_I_Delete] ON [dbo].[OutbreakCaseContact]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([OutbreakCaseContactUID]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [OutbreakCaseContactUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [OutbreakCaseContactUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[OutbreakCaseContact] AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[OutbreakCaseContactUID] = b.[OutbreakCaseContactUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_OutbreakCaseReport_A_Update] ON [dbo].[OutbreakCaseReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(OutbreakCaseReportUID)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_OutbreakCaseReport_I_Delete] on [dbo].[OutbreakCaseReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([OutBreakCaseReportUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [OutBreakCaseReportUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [OutBreakCaseReportUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[OutbreakCaseReport] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[OutBreakCaseReportUID] = b.[OutBreakCaseReportUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_OutbreakSpeciesParameter_A_Update] on [dbo].[OutbreakSpeciesParameter]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(OutbreakSpeciesParameterUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_OutbreakSpeciesParameter_I_Delete] on [dbo].[OutbreakSpeciesParameter]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([OutbreakSpeciesParameterUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [OutbreakSpeciesParameterUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [OutbreakSpeciesParameterUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.OutbreakSpeciesParameter as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[OutbreakSpeciesParameterUID] = b.[OutbreakSpeciesParameterUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_SecurityPolicyConfiguration_A_Update] on [dbo].[SecurityPolicyConfiguration]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(SecurityPolicyConfigurationUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_SecurityPolicyConfiguration_I_Delete] on [dbo].[SecurityPolicyConfiguration]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([SecurityPolicyConfigurationUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [SecurityPolicyConfigurationUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [SecurityPolicyConfigurationUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.SecurityPolicyConfiguration as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[SecurityPolicyConfigurationUID] = b.[SecurityPolicyConfigurationUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_SystemPreference_A_Update] ON [dbo].[SystemPreference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(SystemPreferenceUID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_SystemPreference_I_Delete] on [dbo].[SystemPreference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([SystemPreferenceUID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [SystemPreferenceUID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [SystemPreferenceUID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateUser = SYSTEM_USER,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[SystemPreference] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[SystemPreferenceUID] = b.[SystemPreferenceUID];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasAggregateFunction_A_Update] ON [dbo].[tasAggregateFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsAggregateFunction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasFieldSourceForTable_A_Update] ON [dbo].[tasFieldSourceForTable]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsSearchField) OR UPDATE(idfUnionSearchTable)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglLayout_A_Update] ON [dbo].[tasglLayout]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsLayout))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglLayoutFolder_A_Update] ON [dbo].[tasglLayoutFolder]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsLayoutFolder))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglLayoutSearchField_A_Update] ON [dbo].[tasglLayoutSearchField]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfLayoutSearchField))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglLayoutToMapImage_A_Update] ON [dbo].[tasglLayoutToMapImage]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfLayoutToMapImage))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglMapImage_A_Update] ON [dbo].[tasglMapImage]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMapImage))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglQuery_A_Update] ON [dbo].[tasglQuery]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsQuery))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglQueryConditionGroup_A_Update] ON [dbo].[tasglQueryConditionGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQueryConditionGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglQuerySearchField_A_Update] ON [dbo].[tasglQuerySearchField]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchField))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglQuerySearchFieldCondition_A_Update] ON [dbo].[tasglQuerySearchFieldCondition]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchFieldCondition))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglQuerySearchObject_A_Update] ON [dbo].[tasglQuerySearchObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglView_A_Update] ON [dbo].[tasglView]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfView) OR UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglViewBand_A_Update] ON [dbo].[tasglViewBand]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfViewBand))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasglViewColumn_A_Update] ON [dbo].[tasglViewColumn]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfViewColumn))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasLayout_A_Update] ON [dbo].[tasLayout]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idflLayout))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasLayoutFolder_A_Update] ON [dbo].[tasLayoutFolder]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idflLayoutFolder))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasLayoutSearchField_A_Update] ON [dbo].[tasLayoutSearchField]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfLayoutSearchField))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasLayoutToMapImage_A_Update] ON [dbo].[tasLayoutToMapImage]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfLayoutToMapImage))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasMainTableForObject_A_Update] ON [dbo].[tasMainTableForObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsSearchObject) OR UPDATE(idfMainSearchTable)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasMapImage_A_Update] ON [dbo].[tasMapImage]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMapImage))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasQuery_A_Update] ON [dbo].[tasQuery]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idflQuery))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasQueryConditionGroup_A_Update] ON [dbo].[tasQueryConditionGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQueryConditionGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasQuerySearchField_A_Update] ON [dbo].[tasQuerySearchField]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchField))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasQuerySearchFieldCondition_A_Update] ON [dbo].[tasQuerySearchFieldCondition]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchFieldCondition))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasQuerySearchObject_A_Update] ON [dbo].[tasQuerySearchObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchField_A_Update] ON [dbo].[tasSearchField]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSearchField))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchField_I_Delete] on [dbo].[tasSearchField]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSearchField]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchField] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchField] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tasSearchField as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSearchField = b.idfsSearchField;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSearchField]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchField] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchField] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSearchField;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchFieldsWithRelatedValues_A_Update] ON [dbo].[tasSearchFieldsWithRelatedValues]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSearchFieldsWithRelatedValues))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchFieldToFFParameter_A_Update] ON [dbo].[tasSearchFieldToFFParameter]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSearchFieldToFFParameter))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchFieldToPersonalDataGroup_A_Update] ON [dbo].[tasSearchFieldToPersonalDataGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsSearchField) OR UPDATE(idfPersonalDataGroup)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchObject_A_Update] ON [dbo].[tasSearchObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSearchObject))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchObject_I_Delete] on [dbo].[tasSearchObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSearchObject]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchObject] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchObject] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tasSearchObject as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSearchObject = b.idfsSearchObject;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSearchObject]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchObject] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSearchObject] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSearchObject;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchObjectToSearchObject_A_Update] ON [dbo].[tasSearchObjectToSearchObject]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsRelatedSearchObject) OR UPDATE(idfsParentSearchObject)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchObjectToSystemFunction_A_Update] ON [dbo].[tasSearchObjectToSystemFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsSearchObject) OR UPDATE(idfsSystemFunction)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchTable_A_Update] ON [dbo].[tasSearchTable]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSearchTable))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasSearchTableJoinRule_A_Update] ON [dbo].[tasSearchTableJoinRule]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfMainSearchTable) OR UPDATE(idfSearchTable)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasView_A_Update] ON [dbo].[tasView]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfView) OR UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasViewBand_A_Update] ON [dbo].[tasViewBand]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfViewBand))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tasViewColumn_A_Update] ON [dbo].[tasViewColumn]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfViewColumn))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tauDataAuditEvent_I_Delete] on [dbo].[tauDataAuditEvent]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDataAuditEvent]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDataAuditEvent] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDataAuditEvent] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datEnteringDate = getdate(),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tauDataAuditEvent as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDataAuditEvent = b.idfDataAuditEvent;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tdeDataExport_A_Update] ON [dbo].[tdeDataExport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDataExport))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tdeDataExportDetail_A_Update] ON [dbo].[tdeDataExportDetail]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDataExportDetail))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tdeDataExportDiagnosis_A_Update] ON [dbo].[tdeDataExportDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsDiagnosis) OR UPDATE(idfDataExport)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tdeDataExportFFReference_A_Update] ON [dbo].[tdeDataExportFFReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsParameter) OR UPDATE(idfCustomizationPackage) OR UPDATE(strType) OR UPDATE(strAlias)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tdeDataExportProblem_A_Update] ON [dbo].[tdeDataExportProblem]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDataExportProblem))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflAggrCaseFiltered_A_Update] ON [dbo].[tflAggrCaseFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrCaseFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflBasicSyndromicSurveillanceAggregateHeaderFiltered_A_Update] ON [dbo].[tflBasicSyndromicSurveillanceAggregateHeaderFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBasicSyndromicSurveillanceAggregateHeaderFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflBasicSyndromicSurveillanceFiltered_A_Update] ON [dbo].[tflBasicSyndromicSurveillanceFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBasicSyndromicSurveillanceFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflBatchTestFiltered_A_Update] ON [dbo].[tflBatchTestFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBatchTestFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflDataAuditEventFiltered_A_Update] ON [dbo].[tflDataAuditEventFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDataAuditEventFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflFarmFiltered_A_Update] ON [dbo].[tflFarmFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfFarmFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflGeoLocationFiltered_A_Update] ON [dbo].[tflGeoLocationFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfGeoLocationFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflHumanCaseFiltered_A_Update] ON [dbo].[tflHumanCaseFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfHumanCaseFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflHumanFiltered_A_Update] ON [dbo].[tflHumanFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfHumanFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflMonitoringSessionFiltered_A_Update] ON [dbo].[tflMonitoringSessionFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflNotificationFiltered_A_Update] ON [dbo].[tflNotificationFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfNotificationFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflObservationFiltered_A_Update] ON [dbo].[tflObservationFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfObservationFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflOutbreakFiltered_A_Update] ON [dbo].[tflOutbreakFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfOutbreakFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflSite_A_Update] ON [dbo].[tflSite]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSite))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflSite_I_Delete] on [dbo].[tflSite]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsSite]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSite] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSite] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[tflSite] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfsSite] = b.[idfsSite];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflSiteGroup_A_Update] ON [dbo].[tflSiteGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSiteGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflSiteGroup_I_Delete] on [dbo].[tflSiteGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfSiteGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSiteGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSiteGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[tflSiteGroup] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfSiteGroup] = b.[idfSiteGroup];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflSiteGroupRelation_A_Update] ON [dbo].[tflSiteGroupRelation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSiteGroupRelation))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflSiteToSiteGroup_A_Update] ON [dbo].[tflSiteToSiteGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSiteToSiteGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflTransferOutFiltered_A_Update] ON [dbo].[tflTransferOutFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTransferOutFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflVectorSurveillanceSessionFiltered_A_Update] ON [dbo].[tflVectorSurveillanceSessionFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVectorSurveillanceSessionFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tflVetCaseFiltered_A_Update] ON [dbo].[tflVetCaseFiltered]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVetCaseFiltered))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbActivityParameters_A_Update] ON [dbo].[tlbActivityParameters]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfActivityParameters))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbActivityParameters_I_Delete] on [dbo].[tlbActivityParameters]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfActivityParameters]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfActivityParameters] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfActivityParameters] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbActivityParameters as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfActivityParameters = b.idfActivityParameters;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrCase_A_Update] ON [dbo].[tlbAggrCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrCase))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrCase_I_Delete] on [dbo].[tlbAggrCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggrCase]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrCase] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrCase] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrCase as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggrCase = b.idfAggrCase;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva S.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: 2014-05-13'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtAggrCaseReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbAggrCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfAggrCase = nID.idfKey1	where  nID.strTableName = ''''tlbAggrCase''''	insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			''''tlbAggrCase'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfAggrCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup	from  inserted as ins		inner join dbo.tflSiteToSiteGroup as stsg		on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				inner join dbo.tflSiteGroup sg		on	sg.idfSiteGroup = stsg.idfSiteGroup			and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			and sg.idfsCentralSite is null			and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					left join dbo.tflAggrCaseFiltered as acf		on  acf.idfAggrCase = ins.idfAggrCase			and acf.idfSiteGroup = sg.idfSiteGroup	where  acf.idfAggrCaseFiltered is null	insert into dbo.tflAggrCaseFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfAggrCaseFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfAggrCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfAggrCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2	from  inserted as ins		inner join dbo.tflNewID as nID		on  nID.strTableName = ''''tlbAggrCase''''			and nID.idfKey1 = ins.idfAggrCase			and nID.idfKey2 is not null		left join dbo.tflAggrCaseFiltered as acf		on   acf.idfAggrCaseFiltered = nID.NewID	where  acf.idfAggrCaseFiltered is null	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfAggrCase = nID.idfKey1	where  nID.strTableName = ''''tlbAggrCase'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrDiagnosticActionMTX_A_Update] ON [dbo].[tlbAggrDiagnosticActionMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrDiagnosticActionMTX))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrDiagnosticActionMTX_I_Delete] on [dbo].[tlbAggrDiagnosticActionMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggrDiagnosticActionMTX]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrDiagnosticActionMTX] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrDiagnosticActionMTX] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrDiagnosticActionMTX as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggrDiagnosticActionMTX = b.idfAggrDiagnosticActionMTX;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrHumanCaseMTX_A_Update] ON [dbo].[tlbAggrHumanCaseMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrHumanCaseMTX))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrHumanCaseMTX_I_Delete] on [dbo].[tlbAggrHumanCaseMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggrHumanCaseMTX]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrHumanCaseMTX] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrHumanCaseMTX] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrHumanCaseMTX as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggrHumanCaseMTX = b.idfAggrHumanCaseMTX;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrMatrixVersionHeader_A_Update] ON [dbo].[tlbAggrMatrixVersionHeader]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVersion))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrMatrixVersionHeader_I_Delete] on [dbo].[tlbAggrMatrixVersionHeader]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVersion]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVersion] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVersion] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrMatrixVersionHeader as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVersion = b.idfVersion;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrProphylacticActionMTX_A_Update] ON [dbo].[tlbAggrProphylacticActionMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrProphylacticActionMTX))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrProphylacticActionMTX_I_Delete] on [dbo].[tlbAggrProphylacticActionMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggrProphylacticActionMTX]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrProphylacticActionMTX] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrProphylacticActionMTX] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrProphylacticActionMTX as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggrProphylacticActionMTX = b.idfAggrProphylacticActionMTX;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrSanitaryActionMTX_A_Update] ON [dbo].[tlbAggrSanitaryActionMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrSanitaryActionMTX))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrSanitaryActionMTX_I_Delete] on [dbo].[tlbAggrSanitaryActionMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggrSanitaryActionMTX]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrSanitaryActionMTX] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrSanitaryActionMTX] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrSanitaryActionMTX as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggrSanitaryActionMTX = b.idfAggrSanitaryActionMTX;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrVetCaseMTX_A_Update] ON [dbo].[tlbAggrVetCaseMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggrVetCaseMTX))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAggrVetCaseMTX_I_Delete] on [dbo].[tlbAggrVetCaseMTX]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggrVetCaseMTX]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrVetCaseMTX] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggrVetCaseMTX] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAggrVetCaseMTX as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggrVetCaseMTX = b.idfAggrVetCaseMTX;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAnimal_A_Update] ON [dbo].[tlbAnimal]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAnimal))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAnimal_I_Delete] on [dbo].[tlbAnimal]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAnimal]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAnimal] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAnimal] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAnimal as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAnimal = b.idfAnimal;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAntimicrobialTherapy_A_Update] ON [dbo].[tlbAntimicrobialTherapy]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAntimicrobialTherapy))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbAntimicrobialTherapy_I_Delete] on [dbo].[tlbAntimicrobialTherapy]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAntimicrobialTherapy]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAntimicrobialTherapy] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAntimicrobialTherapy] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbAntimicrobialTherapy as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAntimicrobialTherapy = b.idfAntimicrobialTherapy;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBasicSyndromicSurveillance_A_Update] ON [dbo].[tlbBasicSyndromicSurveillance]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBasicSyndromicSurveillance))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBasicSyndromicSurveillance_I_Delete] on [dbo].[tlbBasicSyndromicSurveillance]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfBasicSyndromicSurveillance]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfBasicSyndromicSurveillance] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfBasicSyndromicSurveillance] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbBasicSyndromicSurveillance as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfBasicSyndromicSurveillance = b.idfBasicSyndromicSurveillance;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: 2013-09-24'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtBasicSyndromicSurveillanceReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbBasicSyndromicSurveillance]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfBasicSyndromicSurveillance = nID.idfKey1	where  nID.strTableName = ''''tflBasicSyndromicSurveillanceFiltered''''	insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			''''tflBasicSyndromicSurveillanceFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfBasicSyndromicSurveillance,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup	from  inserted as ins		inner join dbo.tflSiteToSiteGroup as stsg		on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				inner join dbo.tflSiteGroup sg		on	sg.idfSiteGroup = stsg.idfSiteGroup			and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			and sg.idfsCentralSite is null			and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					left join dbo.tflBasicSyndromicSurveillanceFiltered as bsshf		on  bsshf.idfBasicSyndromicSurveillance = ins.idfBasicSyndromicSurveillance			and bsshf.idfSiteGroup = sg.idfSiteGroup	where  bsshf.idfBasicSyndromicSurveillanceFiltered is null	insert into dbo.tflBasicSyndromicSurveillanceFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfBasicSyndromicSurveillanceFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfBasicSyndromicSurveillance,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfBasicSyndromicSurveillance,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2	from  inserted as ins		inner join dbo.tflNewID as nID		on  nID.strTableName = ''''tflBasicSyndromicSurveillanceFiltered''''			and nID.idfKey1 = ins.idfBasicSyndromicSurveillance			and nID.idfKey2 is not null		left join dbo.tflBasicSyndromicSurveillanceFiltered as bsshf		on   bsshf.idfBasicSyndromicSurveillanceFiltered = nID.NewID	where  bsshf.idfBasicSyndromicSurveillanceFiltered is null	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfBasicSyndromicSurveillance = nID.idfKey1	where  nID.strTableName = ''''tflBasicSyndromicSurveillanceFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBasicSyndromicSurveillanceAggregateDetail_A_Update] ON [dbo].[tlbBasicSyndromicSurveillanceAggregateDetail]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggregateDetail))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBasicSyndromicSurveillanceAggregateDetail_I_Delete] on [dbo].[tlbBasicSyndromicSurveillanceAggregateDetail]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggregateDetail]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggregateDetail] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggregateDetail] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggregateDetail = b.idfAggregateDetail;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBasicSyndromicSurveillanceAggregateHeader_A_Update] ON [dbo].[tlbBasicSyndromicSurveillanceAggregateHeader]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAggregateHeader))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBasicSyndromicSurveillanceAggregateHeader_I_Delete] on [dbo].[tlbBasicSyndromicSurveillanceAggregateHeader]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfAggregateHeader]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggregateHeader] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfAggregateHeader] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfAggregateHeader = b.idfAggregateHeader;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: 2013-09-24'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtBasicSyndromicSurveillanceAggregateHeaderReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbBasicSyndromicSurveillanceAggregateHeader]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfAggregateHeader = nID.idfKey1	where  nID.strTableName = ''''tflBasicSyndromicSurveillanceAggregateHeaderFiltered''''	insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			''''tflBasicSyndromicSurveillanceAggregateHeaderFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfAggregateHeader,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup	from  inserted as ins		inner join dbo.tflSiteToSiteGroup as stsg		on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				inner join dbo.tflSiteGroup sg		on	sg.idfSiteGroup = stsg.idfSiteGroup			and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			and sg.idfsCentralSite is null			and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					left join dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered as bsshf		on  bsshf.idfAggregateHeader = ins.idfAggregateHeader			and bsshf.idfSiteGroup = sg.idfSiteGroup	where  bsshf.idfBasicSyndromicSurveillanceAggregateHeaderFiltered is null	insert into dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfBasicSyndromicSurveillanceAggregateHeaderFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfAggregateHeader,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfAggregateHeader,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2	from  inserted as ins		inner join dbo.tflNewID as nID		on  nID.strTableName = ''''tflBasicSyndromicSurveillanceAggregateHeaderFiltered''''			and nID.idfKey1 = ins.idfAggregateHeader			and nID.idfKey2 is not null		left join dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered as bsshf		on   bsshf.idfBasicSyndromicSurveillanceAggregateHeaderFiltered = nID.NewID	where  bsshf.idfBasicSyndromicSurveillanceAggregateHeaderFiltered is null	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfAggregateHeader = nID.idfKey1	where  nID.strTableName = ''''tflBasicSyndromicSurveillanceAggregateHeaderFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBatchTest_A_Update] ON [dbo].[tlbBatchTest]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBatchTest))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbBatchTest_I_Delete] on [dbo].[tlbBatchTest]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfBatchTest]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfBatchTest] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfBatchTest] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbBatchTest as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfBatchTest = b.idfBatchTest;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: 2013-09-24'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtBatchTestReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbBatchTest]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfBatchTest = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflBatchTestFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflBatchTestFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfBatchTest,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflBatchTestFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfBatchTest = ins.idfBatchTest'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfBatchTestFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflBatchTestFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfBatchTestFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfBatchTest,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfBatchTest,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflBatchTestFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfBatchTest'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflBatchTestFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfBatchTestFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfBatchTestFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfBatchTest = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflBatchTestFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbCampaign_A_Update] ON [dbo].[tlbCampaign]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfCampaign))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbCampaign_I_Delete] on [dbo].[tlbCampaign]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfCampaign]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfCampaign] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfCampaign] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbCampaign as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfCampaign = b.idfCampaign;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbChangeDiagnosisHistory_A_Update] ON [dbo].[tlbChangeDiagnosisHistory]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfChangeDiagnosisHistory))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbChangeDiagnosisHistory_I_Delete] on [dbo].[tlbChangeDiagnosisHistory]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfChangeDiagnosisHistory]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfChangeDiagnosisHistory] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfChangeDiagnosisHistory] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbChangeDiagnosisHistory as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfChangeDiagnosisHistory = b.idfChangeDiagnosisHistory;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbContactedCasePerson_A_Update] ON [dbo].[tlbContactedCasePerson]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfContactedCasePerson))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbContactedCasePerson_I_Delete] on [dbo].[tlbContactedCasePerson]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfContactedCasePerson]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfContactedCasePerson] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfContactedCasePerson] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbContactedCasePerson as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfContactedCasePerson = b.idfContactedCasePerson;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbDepartment_A_Update] ON [dbo].[tlbDepartment]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDepartment))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbDepartment_I_Delete] on [dbo].[tlbDepartment]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDepartment]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDepartment] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDepartment] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbDepartment as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDepartment = b.idfDepartment;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbEmployee_A_Update] ON [dbo].[tlbEmployee]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfEmployee))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbEmployee_I_Delete] on [dbo].[tlbEmployee]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfEmployee]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbEmployee as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfEmployee = b.idfEmployee;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbEmployeeGroup_A_Update] ON [dbo].[tlbEmployeeGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfEmployeeGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbEmployeeGroup_I_Delete] on [dbo].[tlbEmployeeGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfEmployeeGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployeeGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployeeGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbEmployeeGroup as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfEmployeeGroup = b.idfEmployeeGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfEmployeeGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployeeGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployeeGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbEmployee as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfEmployee = b.idfEmployeeGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbEmployeeGroupMember_A_Update] ON [dbo].[tlbEmployeeGroupMember]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfEmployee) OR UPDATE(idfEmployeeGroup)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbEmployeeGroupMember_I_Delete] on [dbo].[tlbEmployeeGroupMember]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfEmployee], [idfEmployeeGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee], [idfEmployeeGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfEmployee], [idfEmployeeGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbEmployeeGroupMember as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfEmployee = b.idfEmployee'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfEmployeeGroup = b.idfEmployeeGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFarm_A_Update] ON [dbo].[tlbFarm]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfFarm))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFarm_I_Delete] on [dbo].[tlbFarm]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfFarm]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFarm] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFarm] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbFarm as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfFarm = b.idfFarm;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:42PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtFarmReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbFarm]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfFarm = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflFarmFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflFarmFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfFarm,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflFarmFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfFarm = ins.idfFarm'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfFarmFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflFarmFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfFarmFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfFarm,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfFarm,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflFarmFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfFarm'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflFarmFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfFarmFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfFarmFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfFarm = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflFarmFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFarmActual_A_Update] ON [dbo].[tlbFarmActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfFarmActual))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFarmActual_I_Delete] on [dbo].[tlbFarmActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfFarmActual]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFarmActual] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFarmActual] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbFarmActual as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfFarmActual = b.idfFarmActual;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFreezer_A_Update] ON [dbo].[tlbFreezer]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfFreezer))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFreezer_I_Delete] on [dbo].[tlbFreezer]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfFreezer]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFreezer] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFreezer] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbFreezer as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfFreezer = b.idfFreezer;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFreezerSubdivision_A_Update] ON [dbo].[tlbFreezerSubdivision]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSubdivision))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbFreezerSubdivision_I_Delete] on [dbo].[tlbFreezerSubdivision]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSubdivision]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSubdivision] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSubdivision] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbFreezerSubdivision as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSubdivision = b.idfSubdivision;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocation_A_Insert] ON [dbo].[tlbGeoLocation]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
DECLARE @okToUpdate BIT = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF EXISTS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
SET @okToUpdate = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF ((TRIGGER_NESTLEVEL()<2) AND (dbo.FN_GBL_TriggersWork()=1)) AND @okToUpdate = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	UPDATE tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tgl.strAddressString = dbo.FN_GBL_GeoLocationString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tgl.strShortAddressString = dbo.FN_GBL_GeoLocationShortAddressString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM dbo.tlbGeoLocation AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE ISNULL(tgl.strAddressString, '''''''') <> dbo.FN_GBL_GeoLocationString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	OR ISNULL(tgl.strShortAddressString, '''''''') <> dbo.FN_GBL_GeoLocationShortAddressString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT INTO dbo.tlbGeoLocationTranslation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	(idfGeoLocation, idfsLanguage, strTextString, strShortAddressString)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tgl.idfGeoLocation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tltc.idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		dbo.FN_GBL_GeoLocationString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strTextString,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		dbo.FN_GBL_GeoLocationShortAddressString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strShortAddressString'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM dbo.tlbGeoLocation AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	CROSS JOIN trtLanguageToCP tltc	JOIN trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN tlbGeoLocationTranslation tglt ON	tglt.idfGeoLocation = tgl.idfGeoLocation AND tglt.idfsLanguage = tltc.idfsLanguage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = tltc.idfCustomizationPackage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE tcp1.idfsCountry = dbo.FN_GBL_CustomizationCountry()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND tglt.idfGeoLocation IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
SET ANSI_NULLS ON'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocation_A_Update] ON [dbo].[tlbGeoLocation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @okToUpdate BIT = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF EXISTS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	 ('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @okToUpdate = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1) AND @okToUpdate = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF(UPDATE(idfGeoLocation))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ELSE IF @okToUpdate = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				UPDATE tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				SET	strAddressString = dbo.FN_GBL_GeoLocationString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					tgl.strShortAddressString = dbo.FN_GBL_GeoLocationShortAddressString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				FROM dbo.tlbGeoLocation AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				WHERE ISNULL(tgl.strAddressString, '''''''') <> dbo.FN_GBL_GeoLocationString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				OR ISNULL(tgl.strShortAddressString, '''''''') <> dbo.FN_GBL_GeoLocationShortAddressString(''''en-US'''', i.idfGeoLocation, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				MERGE dbo.tlbGeoLocationTranslation AS [target]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				USING (				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
							tgl.idfGeoLocation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
							tltc.idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
							dbo.FN_GBL_GeoLocationString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strTextString,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
							dbo.FN_GBL_GeoLocationShortAddressString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strShortAddressString'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						FROM dbo.tlbGeoLocation AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						CROSS JOIN dbo.trtLanguageToCP tltc	JOIN trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						JOIN dbo.tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = tltc.idfCustomizationPackage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						WHERE tcp1.idfsCountry = dbo.FN_GBL_CustomizationCountry()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					) AS [source]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ON ([target].idfGeoLocation = [source].idfGeoLocation AND [target].idfsLanguage = [source].idfsLanguage)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				WHEN MATCHED AND ('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
									ISNULL([target].strTextString, '''''''') <> ISNULL([source].strTextString, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
									OR ISNULL([target].strShortAddressString, '''''''') <> ISNULL([source].strShortAddressString, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
								)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				THEN UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					 SET strTextString = [source].strTextString,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						 strShortAddressString = [source].strShortAddressString;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocation_I_Delete] on [dbo].[tlbGeoLocation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfGeoLocation]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfGeoLocation] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfGeoLocation] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbGeoLocation as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfGeoLocation = b.idfGeoLocation;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:42PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtGeoLocationReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbGeoLocation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfGeoLocation = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflGeoLocationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflGeoLocationFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfGeoLocation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflGeoLocationFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfGeoLocation = ins.idfGeoLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfGeoLocationFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflGeoLocationFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfGeoLocationFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfGeoLocation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfGeoLocation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflGeoLocationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfGeoLocation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflGeoLocationFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfGeoLocationFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfGeoLocationFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfGeoLocation = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflGeoLocationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_tlbGeoLocationShared_A_Insert] ON [dbo].[tlbGeoLocationShared]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF ((TRIGGER_NESTLEVEL()<2) AND (dbo.FN_GBL_TriggersWork()=1))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	UPDATE tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tgl.strAddressString = dbo.FN_GBL_GeoLocationSharedString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tgl.strShortAddressString = dbo.FN_GBL_GeoLocationSharedShortAddressString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM dbo.tlbGeoLocationShared AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN inserted AS i ON tgl.idfGeoLocationShared = i.idfGeoLocationShared'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE ISNULL(tgl.strAddressString, '''''''') <> dbo.FN_GBL_GeoLocationSharedString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	OR ISNULL(tgl.strShortAddressString, '''''''') <> dbo.FN_GBL_GeoLocationSharedShortAddressString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT INTO dbo.tlbGeoLocationSharedTranslation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfGeoLocationShared,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		strTextString,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		strShortAddressString'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tgl.idfGeoLocationShared,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tltc.idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		dbo.FN_GBL_GeoLocationSharedString(tbr.strBaseReferenceCode, i.idfGeoLocationShared, i.idfsGeoLocationType),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		dbo.FN_GBL_GeoLocationSharedShortAddressString(tbr.strBaseReferenceCode, i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM dbo.tlbGeoLocationShared AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN inserted AS i ON tgl.idfGeoLocationShared = i.idfGeoLocationShared'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	CROSS JOIN dbo.trtLanguageToCP tltc	JOIN trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN dbo.tlbGeoLocationSharedTranslation tglt ON tglt.idfGeoLocationShared = tgl.idfGeoLocationShared AND tglt.idfsLanguage = tltc.idfsLanguage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN dbo.tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = tltc.idfCustomizationPackage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE tcp1.idfsCountry = dbo.FN_GBL_CustomizationCountry()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND tglt.idfGeoLocationShared IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
SET ANSI_NULLS ON'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocationShared_A_Update] ON [dbo].[tlbGeoLocationShared]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF(UPDATE(idfGeoLocationShared))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET	tgl.strAddressString = dbo.fnGeoLocationSharedString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				tgl.strShortAddressString = dbo.fnGeoLocationSharedShortAddressString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbGeoLocationShared AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			JOIN inserted AS i ON tgl.idfGeoLocationShared = i.idfGeoLocationShared'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHERE ISNULL(tgl.strAddressString, '''''''') <> dbo.fnGeoLocationSharedString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			OR ISNULL(tgl.strShortAddressString, '''''''') <> dbo.fnGeoLocationSharedShortAddressString(''''en-US'''', i.idfGeoLocationShared, i.idfsGeoLocationType)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			MERGE dbo.tlbGeoLocationSharedTranslation AS [target]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			USING ('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						tgl.idfGeoLocationShared,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						tltc.idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						dbo.FN_GBL_GeoLocationSharedString(tbr.strBaseReferenceCode, i.idfGeoLocationShared, i.idfsGeoLocationType) as strTextString,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						dbo.FN_GBL_GeoLocationShortAddressString(tbr.strBaseReferenceCode, i.idfGeoLocationShared, i.idfsGeoLocationType) as strShortAddressString'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					FROM dbo.tlbGeoLocationShared AS tgl'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					JOIN inserted AS i ON tgl.idfGeoLocationShared = i.idfGeoLocationShared'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					CROSS JOIN dbo.trtLanguageToCP tltc	JOIN dbo.trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					JOIN dbo.tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = tltc.idfCustomizationPackage'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					WHERE tcp1.idfsCountry = dbo.FN_GBL_CustomizationCountry()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				) AS [source]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON ([target].idfGeoLocationShared = [source].idfGeoLocationShared AND [target].idfsLanguage = [source].idfsLanguage)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN MATCHED AND ('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
								ISNULL([target].strTextString, '''''''') <> ISNULL([source].strTextString, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
								OR ISNULL([target].strShortAddressString, '''''''') <> ISNULL([source].strShortAddressString, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
							)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			THEN UPDATE SET strTextString = [source].strTextString	,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
							strShortAddressString = [source].strShortAddressString;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocationShared_I_Delete] on [dbo].[tlbGeoLocationShared]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfGeoLocationShared]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfGeoLocationShared] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfGeoLocationShared] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbGeoLocationShared as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfGeoLocationShared = b.idfGeoLocationShared;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocationSharedTranslation_A_Update] ON [dbo].[tlbGeoLocationSharedTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfGeoLocationShared) OR UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbGeoLocationTranslation_A_Update] ON [dbo].[tlbGeoLocationTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfGeoLocation) OR UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHerd_A_Update] ON [dbo].[tlbHerd]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfHerd))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHerd_I_Delete] on [dbo].[tlbHerd]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfHerd]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHerd] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHerd] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbHerd as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfHerd = b.idfHerd;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHerdActual_A_Update] ON [dbo].[tlbHerdActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfHerdActual))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHerdActual_I_Delete] on [dbo].[tlbHerdActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfHerdActual]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHerdActual] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHerdActual] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbHerdActual as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfHerdActual = b.idfHerdActual;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHuman_A_Update] ON [dbo].[tlbHuman]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF(UPDATE(idfHuman))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE -- calculate name'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			IF  UPDATE(strLastName) or UPDATE(strSecondName) or UPDATE(strFirstName)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  SET strCalculatedHumanName = ISNULL(HumanFromCase.strLastName + '''' '''', '''''''') + ISNULL(HumanFromCase.strFirstName + '''' '''', '''''''') + ISNULL(HumanFromCase.strSecondName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  FROM tlbMaterial a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  INNER JOIN inserted HumanFromCase ON  HumanFromCase.idfHuman=a.idfHuman'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  WHERE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  EXISTS (SELECT idfAnimal FROM dbo.tlbAnimal b WHERE b.idfAnimal = a.idfAnimal AND b.intRowStatus = 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  OR'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  EXISTS (SELECT c.idfSpecies FROM dbo.tlbSpecies c WHERE c.idfSpecies = a.idfSpecies AND c.intRowStatus =0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  OR'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  EXISTS (SELECT d.idfSpecies FROM dbo.tlbAnimal d WHERE d.idfSpecies = a.idfSpecies AND  d.intRowStatus  =0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  OR'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  EXISTS (SELECT e.idfHerd FROM dbo.tlbSpecies e WHERE e.idfHerd = a.idfSpecies AND e.intRowStatus = 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  OR'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				  EXISTS (SELECT f.idfFarm FROM dbo.tlbFarm f WHERE f.idfHuman = a.idfHuman)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHuman_I_Delete] on [dbo].[tlbHuman]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfHuman]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHuman] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHuman] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbHuman as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfHuman = b.idfHuman;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:44PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtHumanReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbHuman]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfHuman = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflHumanFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflHumanFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfHuman,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflHumanFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfHuman = ins.idfHuman'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfHumanFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflHumanFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfHumanFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfHuman,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfHuman,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflHumanFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfHuman'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflHumanFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfHumanFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfHumanFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfHuman = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflHumanFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHumanActual_A_Update] ON [dbo].[tlbHumanActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfHumanActual))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHumanActual_I_Delete] on [dbo].[tlbHumanActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfHumanActual]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHumanActual] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHumanActual] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbHumanActual as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfHumanActual = b.idfHumanActual;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHumanCase_A_Update] ON [dbo].[tlbHumanCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfHumanCase))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_tlbHumanCase_ChangeArchiveDate] on [dbo].[tlbHumanCase]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT, UPDATE, DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @dateModify DATETIME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfOutbreakOld BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfOutbreakNew BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfOutbreakOld = ISNULL(idfOutbreak, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfOutbreakNew = ISNULL(idfOutbreak, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM INSERTED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @dateModify = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfOutbreakOld > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfOutbreak = @idfOutbreakOld'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfOutbreakNew > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfOutbreak = @idfOutbreakNew'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbHumanCase_I_Delete] on [dbo].[tlbHumanCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfHumanCase]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHumanCase] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfHumanCase] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbHumanCase as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfHumanCase = b.idfHumanCase;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:43PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtHumanCaseReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbHumanCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfHumanCase = nID.idfKey1	where  nID.strTableName = ''''tflHumanCaseFiltered''''	insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			''''tflHumanCaseFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfHumanCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup	from  inserted as ins		inner join dbo.tflSiteToSiteGroup as stsg		on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				inner join dbo.tflSiteGroup sg		on	sg.idfSiteGroup = stsg.idfSiteGroup			and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			and sg.idfsCentralSite is null			and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					left join dbo.tflHumanCaseFiltered as btf		on  btf.idfHumanCase = ins.idfHumanCase			and btf.idfSiteGroup = sg.idfSiteGroup	where  btf.idfHumanCaseFiltered is null	insert into dbo.tflHumanCaseFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfHumanCaseFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfHumanCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfHumanCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2	from  inserted as ins		inner join dbo.tflNewID as nID		on  nID.strTableName = ''''tflHumanCaseFiltered''''			and nID.idfKey1 = ins.idfHumanCase			and nID.idfKey2 is not null		left join dbo.tflHumanCaseFiltered as btf		on   btf.idfHumanCaseFiltered = nID.NewID	where  btf.idfHumanCaseFiltered is null	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfHumanCase = nID.idfKey1	where  nID.strTableName = ''''tflHumanCaseFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMaterial_A_Update] ON [dbo].[tlbMaterial]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMaterial))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMaterial_Calculate]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
ON [dbo].[tlbMaterial]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT, UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    IF dbo.FN_GBL_TriggersWork() = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
       AND ('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 UPDATE(idfHumanCase)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 OR UPDATE(idfVetCase)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 OR UPDATE(idfMonitoringSession)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 OR UPDATE(idfVectorSurveillanceSession)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 SET strCalculatedCaseID = CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  WHEN a.idfMonitoringSession IS NOT NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      dbo.tlbMonitoringSession.strMonitoringSessionID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  WHEN a.idfVectorSurveillanceSession IS NOT NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      dbo.tlbVectorSurveillanceSession.strSessionID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  WHEN a.idfHumanCase IS NOT NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   WHEN dbo.tlbHumanCase.idfOutbreak IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
       dbo.tlbHumanCase.strCaseID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
       humOCR.strOutbreakCaseID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  WHEN a.idfVetCase IS NOT NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   WHEN dbo.tlbVetCase.idfOutbreak IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
       dbo.tlbVetCase.strCaseID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
       vetOCR.strOutbreakCaseID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 FROM dbo.tlbMaterial a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     INNER JOIN inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON inserted.idfMaterial = a.idfMaterial'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON tlbHumanCase.idfHumanCase = a.idfHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbHumanCase.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.OutbreakCaseReport humOCR'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON humOCR.idfHumanCase = dbo.tlbHumanCase.idfHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON tlbVetCase.idfVetCase = a.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbVetCase.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.OutbreakCaseReport vetOCR'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON vetOCR.idfVetCase = dbo.tlbVetCase.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON dbo.tlbMonitoringSession.idfMonitoringSession = a.idfMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbMonitoringSession.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON dbo.tlbVectorSurveillanceSession.idfVectorSurveillanceSession = a.idfVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbVectorSurveillanceSession.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 SET strCalculatedHumanName = CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     WHEN a.idfSpecies IS NOT NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   AND a.idfVetCase IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   AND a.idfMonitoringSession IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      WHEN dbo.tlbFarm.idfHuman IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   WHEN dbo.tlbFarm.strNationalName IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strFarmCode'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strNationalName'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      WHEN HumanFromCase.strLastName IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   WHEN dbo.tlbFarm.strNationalName IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strFarmCode'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strNationalName'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ISNULL(HumanFromCase.strLastName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   + ISNULL('''', '''' + HumanFromCase.strFirstName + '''' '''', '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   + ISNULL(HumanFromCase.strSecondName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    WHEN a.idfSpecies IS NOT NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   AND a.idfVetCase IS NOT NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   OR a.idfMonitoringSession IS NOT NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   CASE WHEN dbo.tlbFarm.idfHuman IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   WHEN dbo.tlbFarm.strNationalName IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strFarmCode'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strNationalName'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      WHEN HumanFromCase.strLastName IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   CASE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   WHEN dbo.tlbFarm.strNationalName IS NULL THEN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strFarmCode'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    dbo.tlbFarm.strNationalName'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
      ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ISNULL(HumanFromCase.strLastName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   + ISNULL('''', '''' + HumanFromCase.strFirstName + '''' '''', '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   + ISNULL(HumanFromCase.strSecondName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ISNULL(HumanFromCase.strLastName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  + ISNULL('''', '''' + HumanFromCase.strFirstName + '''' '''', '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  + ISNULL(HumanFromCase.strSecondName, '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 FROM dbo.tlbMaterial a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     INNER JOIN inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON inserted.idfMaterial = a.idfMaterial'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbAnimal'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON dbo.tlbAnimal.idfAnimal = a.idfAnimal'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbAnimal.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbSpecies'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON ('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     dbo.tlbSpecies.idfSpecies = a.idfSpecies'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     OR dbo.tlbSpecies.idfSpecies = dbo.tlbAnimal.idfSpecies'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 )'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbSpecies.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbHerd'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON dbo.tlbHerd.idfHerd = dbo.tlbSpecies.idfHerd'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbHerd.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbFarm'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON dbo.tlbFarm.idfFarm = dbo.tlbHerd.idfFarm'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 AND dbo.tlbFarm.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
     LEFT JOIN dbo.tlbHuman HumanFromCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
  ON HumanFromCase.idfHuman = tlbFarm.idfHuman'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
 OR HumanFromCase.idfHuman = a.idfHuman'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
    END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_tlbMaterial_ChangeArchiveDate] on [dbo].[tlbMaterial]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT, UPDATE, DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork() =1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @dateModify DATETIME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfHumanCase BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfVetCase BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfMonitoringSession BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfVectorSurveillanceSession BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (SELECT COUNT(*) FROM INSERTED) > 0	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfHumanCase = ISNULL(idfHumanCase, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfVetCase = ISNULL(idfVetCase, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfMonitoringSession = ISNULL(idfMonitoringSession, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfVectorSurveillanceSession = ISNULL(idfVectorSurveillanceSession, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM INSERTED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfHumanCase = ISNULL(idfHumanCase, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfVetCase = ISNULL(idfVetCase, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfMonitoringSession = ISNULL(idfMonitoringSession, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfVectorSurveillanceSession = ISNULL(idfVectorSurveillanceSession, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @dateModify = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfHumanCase > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfHumanCase = @idfHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfVetCase > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfVetCase = @idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfMonitoringSession > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfMonitoringSession = @idfMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfVectorSurveillanceSession > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfVectorSurveillanceSession = @idfVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMaterial_I_Delete] on [dbo].[tlbMaterial]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMaterial]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMaterial] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMaterial] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datEnteringDate = getdate(),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMaterial as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMaterial = b.idfMaterial;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSession_A_Update] ON [dbo].[tlbMonitoringSession]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfMonitoringSession)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbMonitoringSession AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INNER JOIN inserted AS b ON a.idfMonitoringSession = b.idfMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSession_I_Delete] on [dbo].[tlbMonitoringSession]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMonitoringSession]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSession] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSession] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMonitoringSession as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMonitoringSession = b.idfMonitoringSession;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:45PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtMonitoringSessionReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbMonitoringSession]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfMonitoringSession = nID.idfKey1	where  nID.strTableName = ''''tflMonitoringSessionFiltered''''	insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			''''tflMonitoringSessionFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfMonitoringSession,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup	from  inserted as ins		inner join dbo.tflSiteToSiteGroup as stsg		on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				inner join dbo.tflSiteGroup sg		on	sg.idfSiteGroup = stsg.idfSiteGroup			and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			and sg.idfsCentralSite is null			and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					left join dbo.tflMonitoringSessionFiltered as btf		on  btf.idfMonitoringSession = ins.idfMonitoringSession			and btf.idfSiteGroup = sg.idfSiteGroup	where  btf.idfMonitoringSessionFiltered is null	insert into dbo.tflMonitoringSessionFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfMonitoringSessionFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfMonitoringSession,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)	select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfMonitoringSession,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2	from  inserted as ins		inner join dbo.tflNewID as nID		on  nID.strTableName = ''''tflMonitoringSessionFiltered''''			and nID.idfKey1 = ins.idfMonitoringSession			and nID.idfKey2 is not null		left join dbo.tflMonitoringSessionFiltered as btf		on   btf.idfMonitoringSessionFiltered = nID.NewID	where  btf.idfMonitoringSessionFiltered is null	delete  nID	from  dbo.tflNewID as nID		inner join inserted as ins		on   ins.idfMonitoringSession = nID.idfKey1	where  nID.strTableName = ''''tflMonitoringSessionFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionAction_A_Update] ON [dbo].[tlbMonitoringSessionAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionAction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionAction_I_Delete] on [dbo].[tlbMonitoringSessionAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMonitoringSessionAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMonitoringSessionAction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMonitoringSessionAction = b.idfMonitoringSessionAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummary_A_Update] ON [dbo].[tlbMonitoringSessionSummary]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionSummary))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummary_I_Delete] on [dbo].[tlbMonitoringSessionSummary]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMonitoringSessionSummary]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionSummary] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionSummary] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMonitoringSessionSummary as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummaryDiagnosis_A_Update] ON [dbo].[tlbMonitoringSessionSummaryDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionSummary))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummaryDiagnosis_I_Delete] on [dbo].[tlbMonitoringSessionSummaryDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMonitoringSessionSummary], [idfsDiagnosis]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionSummary], [idfsDiagnosis] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionSummary], [idfsDiagnosis] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMonitoringSessionSummaryDiagnosis as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsDiagnosis = b.idfsDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummarySample_A_Update] ON [dbo].[tlbMonitoringSessionSummarySample]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfMonitoringSessionSummary) OR UPDATE(idfsSampleType)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummarySample_I_Delete] on [dbo].[tlbMonitoringSessionSummarySample]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMonitoringSessionSummary], [idfsSampleType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionSummary], [idfsSampleType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionSummary], [idfsSampleType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMonitoringSessionSummarySample as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsSampleType = b.idfsSampleType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionToDiagnosis_A_Update] ON [dbo].[tlbMonitoringSessionToDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionToDiagnosis))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionToDiagnosis_I_Delete] on [dbo].[tlbMonitoringSessionToDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMonitoringSessionToDiagnosis]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionToDiagnosis] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMonitoringSessionToDiagnosis] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbMonitoringSessionToDiagnosis as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbObservation_A_Update] ON [dbo].[tlbObservation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfObservation))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbObservation_I_Delete] on [dbo].[tlbObservation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfObservation]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfObservation] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfObservation] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbObservation as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfObservation = b.idfObservation;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:47PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtObservationReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbObservation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfObservation = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflObservationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflObservationFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfObservation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflObservationFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfObservation = ins.idfObservation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfObservationFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflObservationFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfObservationFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfObservation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfObservation,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflObservationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfObservation'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflObservationFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfObservationFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfObservationFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfObservation = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflObservationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOffice_A_Update] ON [dbo].[tlbOffice]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfOffice))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOffice_I_Delete] on [dbo].[tlbOffice]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfOffice]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOffice] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOffice] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbOffice as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfOffice = b.idfOffice;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOutbreak_A_Update] ON [dbo].[tlbOutbreak]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfOutbreak)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbOutbreak AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INNER JOIN INSERTED AS b ON a.idfOutbreak = b.idfOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOutbreak_I_Delete] ON [dbo].[tlbOutbreak]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfOutbreak]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOutbreak] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOutbreak] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET	intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM	 dbo.tlbOutbreak AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfOutbreak = b.idfOutbreak;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:47PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger FOR correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication AND checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtOutbreakReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbOutbreak]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   FOR INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--SET @context = dbo.FN_GBL_CONTEXT_GET()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DELETE  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM	dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		ins.idfOutbreak = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE  nID.strTableName = ''''tflOutbreakFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INTO	dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			''''tflOutbreakFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfOutbreak,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflSiteToSiteGroup AS stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND		sg.idfsRayon IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND		sg.idfsCentralSite IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND		sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN dbo.tflOutbreakFiltered AS btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		btf.idfOutbreak = ins.idfOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND		btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE	btf.idfOutbreakFiltered IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INTO	dbo.tflOutbreakFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfOutbreakFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfOutbreak,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfOutbreak,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		nID.strTableName = ''''tflOutbreakFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND		nID.idfKey1 = ins.idfOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND		nID.idfKey2 IS not NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN dbo.tflOutbreakFiltered AS btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		btf.idfOutbreakFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE	btf.idfOutbreakFiltered IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DELETE  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM	dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON		ins.idfOutbreak = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE	nID.strTableName = ''''tflOutbreakFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOutbreakCaseMonitoring_A_Update] ON [dbo].[tlbOutbreakCaseMonitoring]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE([idfOutbreakCaseMonitoring]))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOutbreakCaseMonitoring_I_Delete] on [dbo].[tlbOutbreakCaseMonitoring]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfOutbreakCaseMonitoring]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOutbreakCaseMonitoring] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOutbreakCaseMonitoring] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[tlbOutbreakCaseMonitoring] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfOutbreakCaseMonitoring] = b.[idfOutbreakCaseMonitoring];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOutbreakNote_A_Update] ON [dbo].[tlbOutbreakNote]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfOutbreakNote))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbOutbreakNote_I_Delete] on [dbo].[tlbOutbreakNote]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfOutbreakNote]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOutbreakNote] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfOutbreakNote] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.[tlbOutbreakNote] as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.[idfOutbreakNote] = b.[idfOutbreakNote];'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbPensideTest_A_Update] ON [dbo].[tlbPensideTest]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfPensideTest))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbPensideTest_I_Delete] on [dbo].[tlbPensideTest]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfPensideTest]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPensideTest] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPensideTest] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbPensideTest as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfPensideTest = b.idfPensideTest;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbPerson_A_Update] ON [dbo].[tlbPerson]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfPerson))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbPerson_I_Delete] on [dbo].[tlbPerson]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfPerson]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPerson] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPerson] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbPerson as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfPerson = b.idfPerson;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfPerson]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPerson] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPerson] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbEmployee as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfEmployee = b.idfPerson;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbPostalCode_A_Update] ON [dbo].[tlbPostalCode]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfPostalCode))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbPostalCode_I_Delete] on [dbo].[tlbPostalCode]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfPostalCode]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPostalCode] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPostalCode] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbPostalCode as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfPostalCode = b.idfPostalCode;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbReportForm_A_Update] ON [dbo].[tlbReportForm]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfReportForm))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbReportForm_I_Delete] ON [dbo].[tlbReportForm]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords(idfReportForm) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT idfReportForm FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT idfReportForm FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbReportForm AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfReportForm = b.idfReportForm;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbSpecies_A_Update] ON [dbo].[tlbSpecies]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSpecies))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbSpecies_I_Delete] on [dbo].[tlbSpecies]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSpecies]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpecies] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpecies] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbSpecies as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSpecies = b.idfSpecies;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbSpeciesActual_A_Update] ON [dbo].[tlbSpeciesActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSpeciesActual))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbSpeciesActual_I_Delete] on [dbo].[tlbSpeciesActual]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSpeciesActual]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesActual] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesActual] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbSpeciesActual as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSpeciesActual = b.idfSpeciesActual;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbStatistic_A_Update] ON [dbo].[tlbStatistic]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfStatistic))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbStatistic_I_Delete] on [dbo].[tlbStatistic]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfStatistic]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfStatistic] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfStatistic] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbStatistic as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfStatistic = b.idfStatistic;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbStreet_A_Update] ON [dbo].[tlbStreet]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfStreet))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbStreet_I_Delete] on [dbo].[tlbStreet]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfStreet]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfStreet] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfStreet] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbStreet as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfStreet = b.idfStreet;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTestAmendmentHistory_A_Update] ON [dbo].[tlbTestAmendmentHistory]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTestAmendmentHistory))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTestAmendmentHistory_I_Delete] on [dbo].[tlbTestAmendmentHistory]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfTestAmendmentHistory]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestAmendmentHistory] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestAmendmentHistory] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbTestAmendmentHistory as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfTestAmendmentHistory = b.idfTestAmendmentHistory;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTesting_A_Update] ON [dbo].[tlbTesting]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTesting))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTesting_ChangeArchiveDate] ON [dbo].[tlbTesting]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT, UPDATE, DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfMaterial BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfBatchTest BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @dateModify DATETIME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (SELECT COUNT(*) FROM INSERTED) > 0	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfMaterial = ISNULL(idfMaterial, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfBatchTest = ISNULL(@idfBatchTest, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM INSERTED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfMaterial = ISNULL(idfMaterial, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			@idfBatchTest = ISNULL(@idfBatchTest, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfHumanCase BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfVetCase BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfMonitoringSession BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfVectorSurveillanceSession BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfHumanCase = ISNULL(idfHumanCase, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfVetCase = ISNULL(idfVetCase, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfMonitoringSession = ISNULL(idfMonitoringSession, 0),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfVectorSurveillanceSession = ISNULL(idfVectorSurveillanceSession, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM tlbMaterial'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE idfMaterial = @idfMaterial		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @dateModify = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfHumanCase > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfHumanCase = @idfHumanCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfVetCase > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfVetCase = @idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfMonitoringSession > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfMonitoringSession = @idfMonitoringSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfVectorSurveillanceSession > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfVectorSurveillanceSession = @idfVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfBatchTest > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbBatchTest'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfBatchTest = @idfBatchTest'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		AND ISNULL(CONVERT(nvarchar(8), datModificationForArchiveDate, 112), '''''''') <> ISNULL(CONVERT(nvarchar(8), @dateModify, 112), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTesting_I_Delete] on [dbo].[tlbTesting]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfTesting]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTesting] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTesting] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbTesting as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfTesting = b.idfTesting;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTestValidation_A_Update] ON [dbo].[tlbTestValidation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTestValidation))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTestValidation_I_Delete] on [dbo].[tlbTestValidation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfTestValidation]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestValidation] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestValidation] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbTestValidation as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfTestValidation = b.idfTestValidation;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTransferOUT_A_Update] ON [dbo].[tlbTransferOUT]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfTransferOut)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET datModificationForArchiveDate = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbTransferOUT AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INNER JOIN inserted AS b ON a.idfTransferOut = b.idfTransferOut'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTransferOUT_I_Delete] on [dbo].[tlbTransferOUT]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfTransferOut]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTransferOut] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTransferOut] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbTransferOUT as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfTransferOut = b.idfTransferOut;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  3:05PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtTransferOutReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbTransferOUT]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfTransferOut = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflTransferOutFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflTransferOutFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfTransferOut,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflTransferOutFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfTransferOut = ins.idfTransferOut'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfTransferOutFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflTransferOutFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfTransferOutFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfTransferOut,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfTransferOut,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflTransferOutFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfTransferOut'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflTransferOutFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfTransferOutFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfTransferOutFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfTransferOut = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflTransferOutFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTransferOutMaterial_A_Update] ON [dbo].[tlbTransferOutMaterial]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfTransferOut) OR UPDATE(idfMaterial)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbTransferOutMaterial_I_Delete] on [dbo].[tlbTransferOutMaterial]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMaterial], [idfTransferOut]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMaterial], [idfTransferOut] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMaterial], [idfTransferOut] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbTransferOutMaterial as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMaterial = b.idfMaterial'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		and a.idfTransferOut = b.idfTransferOut;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVaccination_A_Update] ON [dbo].[tlbVaccination]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVaccination))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVaccination_I_Delete] on [dbo].[tlbVaccination]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVaccination]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVaccination] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVaccination] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVaccination as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVaccination = b.idfVaccination;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVector_A_Update] ON [dbo].[tlbVector]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVector))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVector_I_Delete] on [dbo].[tlbVector]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVector]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVector] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVector] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVector as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVector = b.idfVector;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_A_Update] ON [dbo].[tlbVectorSurveillanceSession]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfVectorSurveillanceSession)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET datModificationForArchiveDate = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbVectorSurveillanceSession AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INNER JOIN INSERTED AS b ON a.idfVectorSurveillanceSession = b.idfVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_ChangeArchiveDate] ON [dbo].[tlbVectorSurveillanceSession]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT, UPDATE, DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @dateModify DATETIME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfOutbreakOld BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfOutbreakNew BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfOutbreakOld = ISNULL(idfOutbreak, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfOutbreakNew = ISNULL(idfOutbreak, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM INSERTED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @dateModify = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfOutbreakOld > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfOutbreak = @idfOutbreakOld'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfOutbreakNew > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfOutbreak = @idfOutbreakNew'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSession_I_Delete] ON [dbo].[tlbVectorSurveillanceSession]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVectorSurveillanceSession]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVectorSurveillanceSession] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVectorSurveillanceSession] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVectorSurveillanceSession AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVectorSurveillanceSession = b.idfVectorSurveillanceSession;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  3:06PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	TRIGGER for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication AND checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtVectorSurveillanceSessionReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbVectorSurveillanceSession]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	--SET @context = dbo.FN_GBL_CONTEXT_GET()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DELETE  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ON   ins.idfVectorSurveillanceSession = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE  nID.strTableName = ''''tflVectorSurveillanceSessionFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INTO	 dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT	''''tflVectorSurveillanceSessionFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfVectorSurveillanceSession,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflSiteToSiteGroup AS stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ON   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ON	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND sg.idfsRayon IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND sg.idfsCentralSite IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN	dbo.tflVectorSurveillanceSessionFiltered AS btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON			btf.idfVectorSurveillanceSession = ins.idfVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND			btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE		btf.idfVectorSurveillanceSessionFiltered IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT INTO dbo.tflVectorSurveillanceSessionFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfVectorSurveillanceSessionFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfVectorSurveillanceSession,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT 	nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ins.idfVectorSurveillanceSession,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN	dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON			nID.strTableName = ''''tflVectorSurveillanceSessionFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND			nID.idfKey1 = ins.idfVectorSurveillanceSession'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	AND			nID.idfKey2 IS NOT NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN	dbo.tflVectorSurveillanceSessionFiltered AS btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON			btf.idfVectorSurveillanceSessionFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE  btf.idfVectorSurveillanceSessionFiltered IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DELETE		nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM		dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN	INSERTED AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	ON			ins.idfVectorSurveillanceSession = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE		nID.strTableName = ''''tflVectorSurveillanceSessionFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSessionSummary_A_Update] ON [dbo].[tlbVectorSurveillanceSessionSummary]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsVSSessionSummary))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSessionSummary_I_Delete] ON [dbo].[tlbVectorSurveillanceSessionSummary]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsVSSessionSummary]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVSSessionSummary] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVSSessionSummary] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVectorSurveillanceSessionSummary AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsVSSessionSummary = b.idfsVSSessionSummary;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSessionSummaryDiagnosis_A_Update]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
ON [dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsVSSessionSummaryDiagnosis))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVectorSurveillanceSessionSummaryDiagnosis_I_Delete] ON [dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsVSSessionSummaryDiagnosis]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVSSessionSummaryDiagnosis] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVSSessionSummaryDiagnosis] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVectorSurveillanceSessionSummaryDiagnosis AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsVSSessionSummaryDiagnosis = b.idfsVSSessionSummaryDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_tlbVetCase_A_Insert] ON [dbo].[tlbVetCase]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF ((TRIGGER_NESTLEVEL()<2) AND (dbo.FN_GBL_TriggersWork ()=1))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	UPDATE tvc'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET strDefaultDisplayDiagnosis = dbo.FN_GBL_DiagnosisString(''''xx'''', i.idfVetCase)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM dbo.tlbVetCase AS tvc'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN inserted AS i ON tvc.idfVetCase = i.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT INTO dbo.tlbVetCaseDisplayDiagnosis'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	(idfVetCase, idfsLanguage, strDisplayDiagnosis)		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tvc.idfVetCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		tltc.idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		dbo.FN_GBL_DiagnosisString(tbr.strBaseReferenceCode, i.idfVetCase) AS DisplayDiagnosis'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM dbo.tlbVetCase AS tvc'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN inserted AS i ON tvc.idfVetCase = i.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	CROSS JOIN dbo.trtLanguageToCP tltc	JOIN dbo.tstLocalSiteOptions tlso ON tlso.strName = ''''SiteID'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		JOIN dbo.tstSite ts ON ts.idfsSite = tlso.strValue AND ts.idfCustomizationPackage = tltc.idfCustomizationPackage AND ts.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	JOIN dbo.trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVetCase_A_Update] ON [dbo].[tlbVetCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfVetCase)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET datModificationForArchiveDate = GETDATE(),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				a.AuditCreateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbVetCase AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INNER JOIN INSERTED AS b ON a.idfVetCase = b.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE tvc'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET strDefaultDisplayDiagnosis = dbo.FN_GBL_DiagnosisString(''''xx'''', i.idfVetCase)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tlbVetCase AS tvc'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			JOIN inserted AS i ON'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				tvc.idfVetCase = i.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHERE ISNULL(tvc.strDefaultDisplayDiagnosis, '''''''') <> ISNULL(dbo.fnDiagnosisString(''''xx'''', i.idfVetCase), '''''''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			MERGE dbo.tlbVetCaseDisplayDiagnosis AS [target]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			USING (				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						tvc.idfVetCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						tltc.idfsLanguage,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						dbo.fnDiagnosisString(tbr.strBaseReferenceCode, tvc.idfVetCase) as DisplayDiagnosis'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					FROM dbo.tlbVetCase AS tvc'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					JOIN inserted AS i ON tvc.idfVetCase = i.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					CROSS JOIN dbo.trtLanguageToCP tltc	JOIN dbo.tstLocalSiteOptions tlso ON tlso.strName = ''''SiteID'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					JOIN dbo.tstSite ts ON ts.idfsSite = tlso.strValue AND ts.idfCustomizationPackage = tltc.idfCustomizationPackage AND ts.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
					JOIN dbo.trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				 ) AS [source]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON ([target].idfVetCase = [source].idfVetCase AND [target].idfsLanguage = [source].idfsLanguage)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			WHEN MATCHED AND (ISNULL([target].strDisplayDiagnosis, '''''''') <> ISNULL([source].DisplayDiagnosis, ''''''''))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			THEN UPDATE	SET strDisplayDiagnosis = [source].DisplayDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE  TRIGGER [dbo].[TR_tlbVetCase_ChangeArchiveDate] on [dbo].[tlbVetCase]	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR INSERT, UPDATE, DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @dateModify DATETIME'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfOutbreakOld BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DECLARE @idfOutbreakNew BIGINT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfOutbreakOld = ISNULL(idfOutbreak, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM DELETED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		@idfOutbreakNew = ISNULL(idfOutbreak, 0)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM INSERTED'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET @dateModify = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
						'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfOutbreakOld > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfOutbreak = @idfOutbreakOld'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF @idfOutbreakNew > 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE tlbOutbreak'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datModificationForArchiveDate = @dateModify,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AuditUpdateDTM = @dateModify'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE idfOutbreak = @idfOutbreakNew'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVetCase_I_Delete] on [dbo].[tlbVetCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVetCase]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVetCase] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVetCase] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = getdate()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVetCase as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVetCase = b.idfVetCase;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  3:07PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_VetCaseReplicationUp_A_Insert]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tlbVetCase]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   FOR INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DELETE nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN inserted AS ins ON ins.idfVetCase = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE nID.strTableName = ''''tflVetCaseFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT INTO dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		''''tflVetCaseFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ins.idfVetCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM inserted AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflSiteToSiteGroup AS stsg ON stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflSiteGroup sg ON sg.idfSiteGroup = stsg.idfSiteGroup AND sg.idfsRayon IS NULL AND sg.idfsCentralSite IS NULL AND sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN dbo.tflVetCaseFiltered AS btf ON  btf.idfVetCase = ins.idfVetCase	AND btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE  btf.idfVetCaseFiltered IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INSERT INTO dbo.tflVetCaseFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfVetCaseFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfVetCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SELECT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ins.idfVetCase,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  inserted AS ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN dbo.tflNewID AS nID ON  nID.strTableName = ''''tflVetCaseFiltered'''' AND nID.idfKey1 = ins.idfVetCase AND nID.idfKey2 IS NOT NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	LEFT JOIN dbo.tflVetCaseFiltered AS btf ON btf.idfVetCaseFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE  btf.idfVetCaseFiltered IS NULL'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	DELETE nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	FROM  dbo.tflNewID AS nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER JOIN inserted AS ins ON ins.idfVetCase = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	WHERE  nID.strTableName = ''''tflVetCaseFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVetCaseDisplayDiagnosis_A_Update] ON [dbo].[tlbVetCaseDisplayDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsLanguage) OR UPDATE(idfVetCase)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVetCaseDisplayDiagnosis_I_Delete] on [dbo].[tlbVetCaseDisplayDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVetCase], [idfsLanguage]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVetCase], [idfsLanguage] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVetCase], [idfsLanguage] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVetCaseDisplayDiagnosis as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVetCase = b.idfVetCase'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsLanguage = b.idfsLanguage;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVetCaseLog_A_Update] ON [dbo].[tlbVetCaseLog]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVetCaseLog))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tlbVetCaseLog_I_Delete] on [dbo].[tlbVetCaseLog]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfVetCaseLog]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVetCaseLog] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfVetCaseLog] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tlbVetCaseLog as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfVetCaseLog = b.idfVetCaseLog;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtAttributeType_A_Update] ON [dbo].[trtAttributeType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfAttributeType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBaseReference_A_Update] ON [dbo].[trtBaseReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsBaseReference))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET a.AuditUpdateDTM = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN inserted AS b ON a.idfsBaseReference = b.idfsBaseReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET a.AuditUpdateUser = SUSER_NAME()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN inserted AS b ON a.idfsBaseReference = b.idfsBaseReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WHERE NOT UPDATE(AuditUpdateUser)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBaseReference_I_Delete] on [dbo].[trtBaseReference]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF  delete'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
if((TRIGGER_NESTLEVEL()<2) AND (dbo.FN_GBL_TriggersWork()=1))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	update a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	set  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	from dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	INNER join deleted as b on a.idfsBaseReference = b.idfsBaseReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
delete a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
from dbo.trtBaseReference as a inner join deleted as b on a.idfsBaseReference = b.idfsBaseReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBaseReferenceAttribute_A_Update] ON [dbo].[trtBaseReferenceAttribute]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBaseReferenceAttribute))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBaseReferenceAttributeToCP_A_Update] ON [dbo].[trtBaseReferenceAttributeToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfBaseReferenceAttribute) OR UPDATE(idfCustomizationPackage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBaseReferenceToCP_A_Update] ON [dbo].[trtBaseReferenceToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsBaseReference) OR UPDATE(idfCustomizationPackage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBssAggregateColumns_A_Update] ON [dbo].[trtBssAggregateColumns]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsBssAggregateColumn))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtBssAggregateColumns_I_Delete] on [dbo].[trtBssAggregateColumns]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsBssAggregateColumn]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsBssAggregateColumn] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsBssAggregateColumn] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBssAggregateColumns as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBssAggregateColumn = b.idfsBssAggregateColumn;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsBssAggregateColumn]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsBssAggregateColumn] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsBssAggregateColumn] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsBssAggregateColumn;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtCaseClassification_A_Update] ON [dbo].[trtCaseClassification]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsCaseClassification))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtCollectionMethodForVectorType_A_Update] ON [dbo].[trtCollectionMethodForVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfCollectionMethodForVectorType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtCollectionMethodForVectorType_I_Delete] on [dbo].[trtCollectionMethodForVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfCollectionMethodForVectorType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfCollectionMethodForVectorType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfCollectionMethodForVectorType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtCollectionMethodForVectorType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfCollectionMethodForVectorType = b.idfCollectionMethodForVectorType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtCollectionMethodForVectorTypeToCP_A_Update] ON [dbo].[trtCollectionMethodForVectorTypeToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfCollectionMethodForVectorType) OR UPDATE(idfCollectionMethodForVectorType)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDerivativeForSampleType_A_Update] ON [dbo].[trtDerivativeForSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDerivativeForSampleType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDerivativeForSampleType_I_Delete] on [dbo].[trtDerivativeForSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDerivativeForSampleType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDerivativeForSampleType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDerivativeForSampleType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtDerivativeForSampleType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDerivativeForSampleType = b.idfDerivativeForSampleType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDerivativeForSampleTypeToCP_A_Update] ON [dbo].[trtDerivativeForSampleTypeToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfDerivativeForSampleType]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosis_A_Update] ON [dbo].[trtDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsDiagnosis))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosis_I_Delete] on [dbo].[trtDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsDiagnosis]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosis] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosis] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtDiagnosis as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsDiagnosis = b.idfsDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsDiagnosis]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosis] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosis] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroup_A_Update] ON [dbo].[trtDiagnosisAgeGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsDiagnosisAgeGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroup_I_Delete] on [dbo].[trtDiagnosisAgeGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsDiagnosisAgeGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosisAgeGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosisAgeGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtDiagnosisAgeGroup as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsDiagnosisAgeGroup = b.idfsDiagnosisAgeGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsDiagnosisAgeGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosisAgeGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsDiagnosisAgeGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsDiagnosisAgeGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroupToDiagnosis_A_Update] ON [dbo].[trtDiagnosisAgeGroupToDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDiagnosisAgeGroupToDiagnosis))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroupToDiagnosis_I_Delete] on [dbo].[trtDiagnosisAgeGroupToDiagnosis]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDiagnosisAgeGroupToDiagnosis]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDiagnosisAgeGroupToDiagnosis] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDiagnosisAgeGroupToDiagnosis] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtDiagnosisAgeGroupToDiagnosis as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDiagnosisAgeGroupToDiagnosis = b.idfDiagnosisAgeGroupToDiagnosis;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroupToDiagnosisToCP_A_Update] ON [dbo].[trtDiagnosisAgeGroupToDiagnosisToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfDiagnosisAgeGroupToDiagnosis]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroupToStatisticalAgeGroup_A_Update] ON [dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDiagnosisAgeGroupToStatisticalAgeGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroupToStatisticalAgeGroup_I_Delete] on [dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDiagnosisAgeGroupToStatisticalAgeGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDiagnosisAgeGroupToStatisticalAgeGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDiagnosisAgeGroupToStatisticalAgeGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtDiagnosisAgeGroupToStatisticalAgeGroup as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDiagnosisAgeGroupToStatisticalAgeGroup = b.idfDiagnosisAgeGroupToStatisticalAgeGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_A_Update] ON [dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroupToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfDiagnosisAgeGroupToStatisticalAgeGroup]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisToDiagnosisGroup_A_Update] ON [dbo].[trtDiagnosisToDiagnosisGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDiagnosisToDiagnosisGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisToDiagnosisGroup_I_Delete] on [dbo].[trtDiagnosisToDiagnosisGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfDiagnosisToDiagnosisGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDiagnosisToDiagnosisGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfDiagnosisToDiagnosisGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtDiagnosisToDiagnosisGroup as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfDiagnosisToDiagnosisGroup = b.idfDiagnosisToDiagnosisGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisToDiagnosisGroupToCP_A_Update] ON [dbo].[trtDiagnosisToDiagnosisGroupToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfDiagnosisToDiagnosisGroup]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtDiagnosisToGroupForReportType_A_Update] ON [dbo].[trtDiagnosisToGroupForReportType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfDiagnosisToGroupForReportType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtEventType_A_Update] ON [dbo].[trtEventType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsEventTypeID))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtEventType_I_Delete] on [dbo].[trtEventType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsEventTypeID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsEventTypeID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsEventTypeID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtEventType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsEventTypeID = b.idfsEventTypeID;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsEventTypeID]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsEventTypeID] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsEventTypeID] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsEventTypeID;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtFFObjectForCustomReport_A_Update] ON [dbo].[trtFFObjectForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfFFObjectForCustomReport))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtFFObjectForCustomReport_I_Delete] on [dbo].[trtFFObjectForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfFFObjectForCustomReport]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFFObjectForCustomReport] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFFObjectForCustomReport] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtFFObjectForCustomReport as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfFFObjectForCustomReport = b.idfFFObjectForCustomReport;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtFFObjectToDiagnosisForCustomReport_A_Update] ON [dbo].[trtFFObjectToDiagnosisForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfFFObjectToDiagnosisForCustomReport))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtFFObjectToDiagnosisForCustomReport_I_Delete] on [dbo].[trtFFObjectToDiagnosisForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfFFObjectToDiagnosisForCustomReport]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFFObjectToDiagnosisForCustomReport] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfFFObjectToDiagnosisForCustomReport] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtFFObjectToDiagnosisForCustomReport as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfFFObjectToDiagnosisForCustomReport = b.idfFFObjectToDiagnosisForCustomReport;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtGISBaseReferenceAttribute_A_Update] ON [dbo].[trtGISBaseReferenceAttribute]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfGISBaseReferenceAttribute]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtGISObjectForCustomReport_A_Update] ON [dbo].[trtGISObjectForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfGISObjectForCustomReport]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtHACodeList_A_Update] ON [dbo].[trtHACodeList]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(intHACode))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtHACodeList_I_Delete] on [dbo].[trtHACodeList]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([intHACode]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [intHACode] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [intHACode] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtHACodeList as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.intHACode = b.intHACode;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtLanguageToCP_A_Update] ON [dbo].[trtLanguageToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsLanguage]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtMaterialForDisease_A_Update] ON [dbo].[trtMaterialForDisease]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMaterialForDisease))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtMaterialForDisease_I_Delete] on [dbo].[trtMaterialForDisease]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfMaterialForDisease]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMaterialForDisease] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfMaterialForDisease] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtMaterialForDisease as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfMaterialForDisease = b.idfMaterialForDisease;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtMaterialForDiseaseToCP_A_Update] ON [dbo].[trtMaterialForDiseaseToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfMaterialForDisease]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtMatrixColumn_A_Update] ON [dbo].[trtMatrixColumn]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsMatrixColumn]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtMatrixType_A_Update] ON [dbo].[trtMatrixType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsMatrixType]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtObjectTypeToObjectOperation_A_Update] ON [dbo].[trtObjectTypeToObjectOperation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsObjectType]) OR UPDATE([idfsObjectOperation])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtObjectTypeToObjectType_A_Update] ON [dbo].[trtObjectTypeToObjectType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsParentObjectType]) OR UPDATE([idfsRelatedObjectType])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestForDisease_A_Update] ON [dbo].[trtPensideTestForDisease]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfPensideTestForDisease))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestForDisease_I_Delete] on [dbo].[trtPensideTestForDisease]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfPensideTestForDisease]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPensideTestForDisease] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPensideTestForDisease] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtPensideTestForDisease as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfPensideTestForDisease = b.idfPensideTestForDisease;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestForDiseaseToCP_A_Update] ON [dbo].[trtPensideTestForDiseaseToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfPensideTestForDisease]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestTypeForVectorType_A_Update] ON [dbo].[trtPensideTestTypeForVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfPensideTestTypeForVectorType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestTypeForVectorType_I_Delete] on [dbo].[trtPensideTestTypeForVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfPensideTestTypeForVectorType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPensideTestTypeForVectorType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfPensideTestTypeForVectorType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtPensideTestTypeForVectorType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfPensideTestTypeForVectorType = b.idfPensideTestTypeForVectorType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestTypeForVectorTypeToCP_A_Update] ON [dbo].[trtPensideTestTypeForVectorTypeToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfPensideTestTypeForVectorType]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestTypeToTestResult_A_Update] ON [dbo].[trtPensideTestTypeToTestResult]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsPensideTestName) OR UPDATE(idfsPensideTestResult)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestTypeToTestResult_I_Delete] on [dbo].[trtPensideTestTypeToTestResult]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsPensideTestName], [idfsPensideTestResult]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsPensideTestName], [idfsPensideTestResult] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsPensideTestName], [idfsPensideTestResult] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtPensideTestTypeToTestResult as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsPensideTestName = b.idfsPensideTestName'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsPensideTestResult = b.idfsPensideTestResult;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtPensideTestTypeToTestResultToCP_A_Update] ON [dbo].[trtPensideTestTypeToTestResultToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsPensideTestName]) OR UPDATE([idfsPensideTestResult]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtProphilacticAction_A_Update] ON [dbo].[trtProphilacticAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsProphilacticAction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtProphilacticAction_I_Delete] on [dbo].[trtProphilacticAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsProphilacticAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsProphilacticAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsProphilacticAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtProphilacticAction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsProphilacticAction = b.idfsProphilacticAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsProphilacticAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsProphilacticAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsProphilacticAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsProphilacticAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtReferenceType_A_Update] ON [dbo].[trtReferenceType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsReferenceType]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtReferenceType_I_Delete] on [dbo].[trtReferenceType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsReferenceType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReferenceType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReferenceType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtReferenceType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsReferenceType = b.idfsReferenceType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsReferenceType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReferenceType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReferenceType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsReferenceType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtReportDiagnosisGroup_A_Update] ON [dbo].[trtReportDiagnosisGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsReportDiagnosisGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtReportDiagnosisGroup_I_Delete] on [dbo].[trtReportDiagnosisGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsReportDiagnosisGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReportDiagnosisGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReportDiagnosisGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtReportDiagnosisGroup as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsReportDiagnosisGroup = b.idfsReportDiagnosisGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsReportDiagnosisGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReportDiagnosisGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsReportDiagnosisGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsReportDiagnosisGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtReportRows_A_Update] ON [dbo].[trtReportRows]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfReportRows))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtReportRows_I_Delete] on [dbo].[trtReportRows]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfReportRows]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfReportRows] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfReportRows] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtReportRows as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfReportRows = b.idfReportRows;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResource_A_Update] ON [dbo].[trtResource]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsResource))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResource_I_Delete] ON [dbo].[trtResource]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsResource]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResource] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResource] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtResource AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfsResource = b.idfsResource;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSet_A_Update] ON [dbo].[trtResourceSet]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsResourceSet))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSet_I_Delete] ON [dbo].[trtResourceSet]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsResourceSet]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResourceSet] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResourceSet] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtResourceSet AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfsResourceSet = b.idfsResourceSet;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSetHierarchy_A_Update] ON [dbo].[trtResourceSetHierarchy]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfResourceHierarchy))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSetHierarchy_I_Delete] ON [dbo].[trtResourceSetHierarchy]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfResourceHierarchy]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfResourceHierarchy] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfResourceHierarchy] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtResourceSetHierarchy AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfResourceHierarchy = b.idfResourceHierarchy;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSetToResource_A_Update] ON [dbo].[trtResourceSetToResource]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsResourceSet) AND UPDATE(idfsResource)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSetToResource_I_Delete] ON [dbo].[trtResourceSetToResource]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsResourceSet], [idfsResource]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResourceSet], [idfsResource] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResourceSet], [idfsResource] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtResourceSetToResource AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows AS b ON a.idfsResourceSet = b.idfsResourceSet	AND a.idfsResource = b.idfsResource;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSetTranslation_A_Update] ON [dbo].[trtResourceSetTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsResourceSet) AND UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceSetTranslation_I_Delete] ON [dbo].[trtResourceSetTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsResourceSet], [idfsLanguage]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResourceSet], [idfsLanguage] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResourceSet], [idfsLanguage] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtResourceSetTranslation AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsResourceSet = b.idfsResourceSet'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsLanguage = b.idfsLanguage;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceTranslation_A_Update] ON [dbo].[trtResourceTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsResource) AND UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtResourceTranslation_I_Delete] ON [dbo].[trtResourceTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsResource], [idfsLanguage]) AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResource], [idfsLanguage] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsResource], [idfsLanguage] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtResourceTranslation AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows AS b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsResource = b.idfsResource'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsLanguage = b.idfsLanguage;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSampleType_A_Update] ON [dbo].[trtSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSampleType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSampleType_I_Delete] on [dbo].[trtSampleType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSampleType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSampleType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSampleType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSampleType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSampleType = b.idfsSampleType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSampleType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSampleType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSampleType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSampleType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSampleTypeForVectorType_A_Update] ON [dbo].[trtSampleTypeForVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSampleTypeForVectorType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSampleTypeForVectorType_I_Delete] on [dbo].[trtSampleTypeForVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSampleTypeForVectorType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSampleTypeForVectorType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSampleTypeForVectorType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSampleTypeForVectorType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSampleTypeForVectorType = b.idfSampleTypeForVectorType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSampleTypeForVectorTypeToCP_A_Update] ON [dbo].[trtSampleTypeForVectorTypeToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfSampleTypeForVectorType]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSanitaryAction_A_Update] on [dbo].[trtSanitaryAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSanitaryAction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSanitaryAction_I_Delete] on [dbo].[trtSanitaryAction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSanitaryAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSanitaryAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSanitaryAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSanitaryAction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSanitaryAction = b.idfsSanitaryAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSanitaryAction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSanitaryAction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSanitaryAction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSanitaryAction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesContentInCustomReport_A_Update] ON [dbo].[trtSpeciesContentInCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSpeciesContentInCustomReport))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesContentInCustomReport_I_Delete] on [dbo].[trtSpeciesContentInCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSpeciesContentInCustomReport]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesContentInCustomReport] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesContentInCustomReport] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSpeciesContentInCustomReport as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSpeciesContentInCustomReport = b.idfSpeciesContentInCustomReport;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesGroup_A_Update] ON [dbo].[trtSpeciesGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSpeciesGroup))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesGroup_I_Delete] on [dbo].[trtSpeciesGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsSpeciesGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSpeciesGroup as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSpeciesGroup = b.idfsSpeciesGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsSpeciesGroup]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesGroup] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesGroup] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSpeciesGroup;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesToGroupForCustomReport_A_Update] ON [dbo].[trtSpeciesToGroupForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSpeciesToGroupForCustomReport))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesToGroupForCustomReport_I_Delete] on [dbo].[trtSpeciesToGroupForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfSpeciesToGroupForCustomReport]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesToGroupForCustomReport] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesToGroupForCustomReport] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSpeciesToGroupForCustomReport as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSpeciesToGroupForCustomReport = b.idfSpeciesToGroupForCustomReport;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesType_A_Update] ON [dbo].[trtSpeciesType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSpeciesType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesType_I_Delete] on [dbo].[trtSpeciesType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSpeciesType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSpeciesType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSpeciesType = b.idfsSpeciesType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsSpeciesType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSpeciesType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSpeciesType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesTypeToAnimalAge_A_Update] ON [dbo].[trtSpeciesTypeToAnimalAge]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSpeciesTypeToAnimalAge))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesTypeToAnimalAge_I_Delete] on [dbo].[trtSpeciesTypeToAnimalAge]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfSpeciesTypeToAnimalAge]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesTypeToAnimalAge] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfSpeciesTypeToAnimalAge] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSpeciesTypeToAnimalAge as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfSpeciesTypeToAnimalAge = b.idfSpeciesTypeToAnimalAge;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSpeciesTypeToAnimalAgeToCP_A_Update] ON [dbo].[trtSpeciesTypeToAnimalAgeToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfSpeciesTypeToAnimalAge]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtStatisticDataType_A_Update] ON [dbo].[trtStatisticDataType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsStatisticDataType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtStatisticDataType_I_Delete] on [dbo].[trtStatisticDataType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsStatisticDataType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsStatisticDataType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsStatisticDataType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtStatisticDataType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsStatisticDataType = b.idfsStatisticDataType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsStatisticDataType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsStatisticDataType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsStatisticDataType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsStatisticDataType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtStringNameTranslation_A_Update] ON [dbo].[trtStringNameTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsBaseReference) AND UPDATE(idfsLanguage)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtStringNameTranslation_I_Delete] on [dbo].[trtStringNameTranslation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsBaseReference], [idfsLanguage]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsBaseReference], [idfsLanguage] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsBaseReference], [idfsLanguage] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtStringNameTranslation as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsBaseReference'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsLanguage = b.idfsLanguage;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtStringNameTranslationToCP_A_Update] ON [dbo].[trtStringNameTranslationToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsBaseReference]) OR UPDATE([idfsLanguage]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSystemFunction_A_Update] ON [dbo].[trtSystemFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsSystemFunction))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSystemFunction_I_Delete] on [dbo].[trtSystemFunction]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsSystemFunction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSystemFunction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSystemFunction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtSystemFunction as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsSystemFunction = b.idfsSystemFunction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfsSystemFunction]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSystemFunction] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsSystemFunction] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsSystemFunction;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtSystemFunctionOperation_A_Update] ON [dbo].[trtSystemFunctionOperation]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsSystemFunctionOperation]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestForDisease_A_Update] ON [dbo].[trtTestForDisease]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTestForDisease))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestForDisease_I_Delete] on [dbo].[trtTestForDisease]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfTestForDisease]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestForDisease] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestForDisease] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtTestForDisease as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfTestForDisease = b.idfTestForDisease;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestForDiseaseToCP_A_Update] ON [dbo].[trtTestForDiseaseToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfTestForDisease]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestTypeForCustomReport_A_Update] ON [dbo].[trtTestTypeForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTestTypeForCustomReport))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestTypeForCustomReport_I_Delete] on [dbo].[trtTestTypeForCustomReport]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRows([idfTestTypeForCustomReport]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestTypeForCustomReport] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfTestTypeForCustomReport] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtTestTypeForCustomReport as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRows as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfTestTypeForCustomReport = b.idfTestTypeForCustomReport;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestTypeToTestResult_A_Update] ON [dbo].[trtTestTypeToTestResult]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsTestName) OR UPDATE(idfsTestResult)))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestTypeToTestResult_I_Delete] on [dbo].[trtTestTypeToTestResult]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsTestName], [idfsTestResult]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsTestName], [idfsTestResult] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsTestName], [idfsTestResult] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtTestTypeToTestResult as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsTestName = b.idfsTestName'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfsTestResult = b.idfsTestResult'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtTestTypeToTestResultToCP_A_Update] ON [dbo].[trtTestTypeToTestResultToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsTestName]) OR UPDATE([idfsTestResult]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtVectorSubType_A_Update] ON [dbo].[trtVectorSubType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsVectorSubType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtVectorSubType_I_Delete] on [dbo].[trtVectorSubType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsVectorSubType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorSubType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorSubType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtVectorSubType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsVectorSubType = b.idfsVectorSubType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsVectorSubType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorSubType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorSubType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsVectorSubType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtVectorType_A_Update] ON [dbo].[trtVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsVectorType))'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_trtVectorType_I_Delete] on [dbo].[trtVectorType]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsVectorType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtVectorType as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsVectorType = b.idfsVectorType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsVectorType]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorType] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsVectorType] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		DELETE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.trtBaseReference as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsBaseReference = b.idfsVectorType;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstAggrSetting_A_Update] ON [dbo].[tstAggrSetting]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsAggrCaseType]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstAggrSetting_I_Delete] on [dbo].[tstAggrSetting]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfsAggrCaseType], [idfCustomizationPackage]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsAggrCaseType], [idfCustomizationPackage] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfsAggrCaseType], [idfCustomizationPackage] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET  intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tstAggrSetting as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfsAggrCaseType = b.idfsAggrCaseType'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			AND a.idfCustomizationPackage = b.idfCustomizationPackage;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstBarcodeLayout_A_Update] ON [dbo].[tstBarcodeLayout]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsNumberName]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstCheckConstraints_A_Update] ON [dbo].[tstCheckConstraints]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfCheckConstraints]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstCheckTables_A_Update] ON [dbo].[tstCheckTables]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfCheckTable]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstCustomizationPackage_A_Update] ON [dbo].[tstCustomizationPackage]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfCustomizationPackage]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstCustomizationPackageSettings_A_Update] ON [dbo].[tstCustomizationPackageSettings]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfCustomizationPackage]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstEvent_A_Update] ON [dbo].[tstEvent]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfEventID]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstEventActive_A_Update] ON [dbo].[tstEventActive]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfEventID]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstEventClient_A_Update] ON [dbo].[tstEventClient]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([strClient]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstEventSubscription_A_Update] ON [dbo].[tstEventSubscription]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsEventTypeID]) OR UPDATE([strClient])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstGeoLocationFormat_A_Update] ON [dbo].[tstGeoLocationFormat]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsCountry]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstGlobalSiteOptions_A_Update] ON [dbo].[tstGlobalSiteOptions]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([strName]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstInvalidObjects_A_Update] ON [dbo].[tstInvalidObjects]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfKey]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstInvisibleFields_A_Update] ON [dbo].[tstInvisibleFields]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfInvisibleField]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstInvisibleFieldsToCP_A_Update] ON [dbo].[tstInvisibleFieldsToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfInvisibleField]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstLocalClient_A_Update] ON [dbo].[tstLocalClient]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([strClient]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstLocalConnectionContext_A_Update] ON [dbo].[tstLocalConnectionContext]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([strConnectionContext]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstLocalSamplesTestsPreferences_A_Update] ON [dbo].[tstLocalSamplesTestsPreferences]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfSamplesTestsPreferences]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstLocalSiteOptions_A_Update] ON [dbo].[tstLocalSiteOptions]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([strName]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstMandatoryFields_A_Update] ON [dbo].[tstMandatoryFields]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfMandatoryField]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstMandatoryFieldsToCP_A_Update] ON [dbo].[tstMandatoryFieldsToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfMandatoryField]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstNextNumbers_A_Update] ON [dbo].[tstNextNumbers]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfsNumberName]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstNotification_A_Update] ON [dbo].[tstNotification]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF(dbo.FN_GBL_TriggersWork ()=1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfNotification)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ELSE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SET datModificationForArchiveDate = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			FROM dbo.tstNotification AS a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			INNER JOIN inserted AS b ON a.idfNotification = b.idfNotification'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstNotification_I_Delete] on [dbo].[tstNotification]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfNotification]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfNotification] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfNotification] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET datEnteringDate = GETDATE(),'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			datModificationForArchiveDate = GETDATE()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tstNotification as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfNotification = b.idfNotification;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Author:		Romasheva Svetlana'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Create date: May 19 2014  2:46PM'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- Description:	Trigger for correct problems'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
--       with replication and checkin in the same time'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
-- ============================================='''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[trtNotificationReplicationUp]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   ON  [dbo].[tstNotification]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   for INSERT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
   NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT ON;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	declare @FilterListedRecordsOnly bit = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	-- get value of global option FilterListedRecordsOnly'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if exists (select * from tstGlobalSiteOptions tgso where tgso.strName = ''''FilterListedRecordsOnly'''' and tgso.strValue = ''''1'''')'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	else'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		set @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	if @FilterListedRecordsOnly = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	begin'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--DECLARE @context VARCHAR(50)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		--SET @context = dbo.fnGetContext()'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfNotification = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflNotificationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				strTableName,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey1,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				''''tflNotificationFiltered'''','''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfNotification,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteToSiteGroup as stsg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   stsg.idfsSite = ins.idfsSite'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflSiteGroup sg'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on	sg.idfSiteGroup = stsg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsRayon is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.idfsCentralSite is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and sg.intRowStatus = 0'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflNotificationFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  btf.idfNotification = ins.idfNotification'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and btf.idfSiteGroup = sg.idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfNotificationFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		insert into dbo.tflNotificationFiltered'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfNotificationFiltered,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfNotification,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				idfSiteGroup'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		select'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.NewID,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				ins.idfNotification,'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				nID.idfKey2'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on  nID.strTableName = ''''tflNotificationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey1 = ins.idfNotification'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				and nID.idfKey2 is not null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			left join dbo.tflNotificationFiltered as btf'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   btf.idfNotificationFiltered = nID.NewID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  btf.idfNotificationFiltered is null'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		delete  nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		from  dbo.tflNewID as nID'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			inner join inserted as ins'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			on   ins.idfNotification = nID.idfKey1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		where  nID.strTableName = ''''tflNotificationFiltered'''''''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	end'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	SET NOCOUNT OFF;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
				'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstNotificationShared_A_Update] ON [dbo].[tstNotificationShared]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfNotificationShared]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstNotificationStatus_A_Update] ON [dbo].[tstNotificationStatus]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfNotification]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstObjectAccess_A_Update] ON [dbo].[tstObjectAccess]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF dbo.FN_GBL_TriggersWork ()=1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfObjectAccess)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstObjectAccess_I_Delete] on [dbo].[tstObjectAccess]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
INSTEAD OF DELETE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		WITH cteOnlyDeletedRecords([idfObjectAccess]) as'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		('''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfObjectAccess] FROM deleted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			EXCEPT'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			SELECT [idfObjectAccess] FROM inserted'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		UPDATE a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		SET intRowStatus = 1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		FROM dbo.tstObjectAccess as a'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		INNER JOIN cteOnlyDeletedRecords as b'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ON a.idfObjectAccess = b.idfObjectAccess;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstPersonalDataGroup_A_Update] ON [dbo].[tstPersonalDataGroup]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfPersonalDataGroup]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstPersonalDataGroupToCP_A_Update] ON [dbo].[tstPersonalDataGroupToCP]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfPersonalDataGroup]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstRayonToReportSite_A_Update] ON [dbo].[tstRayonToReportSite]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfRayonToReportSite]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstSecurityAudit_A_Update] ON [dbo].[tstSecurityAudit]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfSecurityAudit]))  -- update to Primary Key is not allowed.'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1);'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		ROLLBACK TRANSACTION;'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstSecurityConfiguration_A_Update] ON [dbo].[tstSecurityConfiguration]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
FOR UPDATE'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
NOT FOR REPLICATION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
AS'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	IF dbo.FN_GBL_TriggersWork ()=1'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		IF UPDATE(idfSecurityConfiguration)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		BEGIN'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			RAISERROR(''''Update Trigger: Not allowed to update PK.'''',16,1)'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
			ROLLBACK TRANSACTION'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
		END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
	END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
END'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''


-------

set @cmd = @cmd + N' exec [' + @DbName + '].sys.sp_executesql @cmd
' execute sp_executesql @cmd


--

set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_NULLS ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd set @cmd = N'' 

SET QUOTED_IDENTIFIER ON
'' exec [' + @DbName + '].sys.sp_executesql @cmd
set @cmd = N''''
'


-------

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''
CREATE TRIGGER [dbo].[TR_tstSecurityConfiguration_I_Delete] on [dbo].[tstSecurityConfiguration]'''

set @cmd = @cmd + N'
set @cmd = @cmd + N''


