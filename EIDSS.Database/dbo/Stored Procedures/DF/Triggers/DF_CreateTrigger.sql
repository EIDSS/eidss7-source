-- Examples:
/*
	EXEC [dbo].[DF_CreateTrigger] @DBTable=N'tlbAggrCase',@PrintCmd=0,@ExecCmd=1
	EXEC [dbo].[DF_CreateTrigger] @DBTable=N'tlbVectorSurveillanceSession',@PrintCmd=1,@ExecCmd=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CreateTrigger] 
(
	@DBTable nvarchar(200),
	@PrintCmd bit = 1,
	@ExecCmd bit = 0
)
AS
set nocount on
set XACT_ABORT on

declare	@cmd nvarchar(max)
declare @TriggerToCreate nvarchar(200) = N'TR_' + @DBTable + '_Insert_DF'
declare	@TflTable nvarchar(200)
declare @PKFieldDBTable nvarchar(200)
declare	@PKFieldTflTable nvarchar(200)
declare	@FKFieldTflTable nvarchar(200)


select		@PKFieldDBTable = pk_col.[name]
from		sys.tables t
left join	sys.indexes i
	inner join	sys.objects pk
	on			i.[name] = pk.[name] collate Latin1_General_CI_AS
				and pk.[type] = 'PK' collate Latin1_General_CI_AS
	inner join	sys.key_constraints kc
	on			kc.[object_id] = pk.[object_id]
				and kc.[parent_object_id] = i.[object_id]
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1
outer apply
(		select	top 1 c.[column_id], c.[name]
		from	sys.index_columns ic
		join	sys.columns c
		on		c.[object_id] = ic.[object_id]
				and c.[column_id] = ic.[column_id]
		where	ic.[object_id] = i.[object_id]
				and ic.[index_id] = i.[index_id]
		order by	ic.[index_column_id], c.[column_id]
) pk_col
where	t.[object_id] = object_id(@DBTable, N'U')

select		@TflTable = fk.strTflTableName,
			@FKFieldTflTable = fk.strTflTableFKField
from		sys.tables t_ref
outer apply
(	select	top 1
			t_source.[object_id], t_source.[name] as strTflTableName, c_source.[column_id], c_source.[name] as strTflTableFKField
	from	sys.foreign_keys fk
	join	sys.tables t_source
	on		t_source.[object_id] = fk.parent_object_id
	join	sys.tables t_ref
	on		t_ref.[object_id] = fk.referenced_object_id

	join	sys.foreign_key_columns fkc
	on		fkc.constraint_object_id = fk.[object_id]
			and fkc.parent_object_id = fk.parent_object_id
			and fkc.referenced_object_id = t_ref.[object_id]
	join	sys.columns c_source
	on		c_source.[object_id] = fkc.parent_object_id
			and c_source.[column_id] = fkc.parent_column_id
	join	sys.columns c_ref
	on		c_ref.[object_id] = fkc.referenced_object_id
			and c_ref.[column_id] = fkc.referenced_column_id
	where	fk.referenced_object_id = object_id(@DBTable, N'U')
			and c_ref.[name] = @PKFieldDBTable collate Cyrillic_General_CI_AS
			and t_source.[name] like N'tfl%Filtered' collate Cyrillic_General_CI_AS
) fk
where	t_ref.[object_id] = object_id(@DBTable, N'U')


select		@PKFieldTflTable = pk_col.[name]
from		sys.tables t
left join	sys.indexes i
	inner join	sys.objects pk
	on			i.[name] = pk.[name] collate Latin1_General_CI_AS
				and pk.[type] = 'PK' collate Latin1_General_CI_AS
	inner join	sys.key_constraints kc
	on			kc.[object_id] = pk.[object_id]
				and kc.[parent_object_id] = i.[object_id]
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1
outer apply
(		select	top 1 c.[column_id], c.[name]
		from	sys.index_columns ic
		join	sys.columns c
		on		c.[object_id] = ic.[object_id]
				and c.[column_id] = ic.[column_id]
		where	ic.[object_id] = i.[object_id]
				and ic.[index_id] = i.[index_id]
		order by	ic.[index_column_id], c.[column_id]
) pk_col
where	t.[object_id] = object_id(@TflTable, N'U')


if	object_id(@DBTable, N'U') is not null
	and object_id(@TflTable, N'U') is not null
	and LEN(LTRIM(RTRIM(ISNULL(@TriggerToCreate, N'')))) > 0
	and @PKFieldDBTable is not null
	and @PKFieldTflTable is not null
	and @FKFieldTflTable is not null
begin
	set	@cmd = N'
declare	@cmd nvarchar(max)
if	object_id(N''' + replace(@DBTable, N'''', N'''''') + N''', N''U'') is not null
begin
	print	N''/*CREATED/ALTERED TRIGGER [' + replace(@TriggerToCreate, N'''', N'''''') + N']*/''
	set	@cmd = N''

CREATE OR ALTER TRIGGER [dbo].[' + replace(@TriggerToCreate, N'''', N'''''') + N'] 
   ON  [dbo].[' + replace(@DBTable, N'''', N'''''') + N']
   for INSERT
   NOT FOR REPLICATION
AS 
BEGIN
	SET NOCOUNT ON;

	declare @guid uniqueidentifier = newid()
	declare @strTableName nvarchar(128) = N''''' + replace(@DBTable, N'''', N'') + N''''' + cast(@guid as nvarchar(36)) collate Cyrillic_General_CI_AS

	insert into [dbo].[tflNewID] 
		(
			[strTableName], 
			[idfKey1], 
			[idfKey2]
		)
	select  
			@strTableName, 
			ins.[' + replace(@PKFieldDBTable, N'''', N'''''') + N'], 
			sg.[idfSiteGroup]
	from  inserted as ins
		inner join [dbo].[tflSiteToSiteGroup] as stsg with(nolock)
		on   stsg.[idfsSite] = ins.[idfsSite]
		
		inner join [dbo].[tflSiteGroup] sg with(nolock)
		on	sg.[idfSiteGroup] = stsg.[idfSiteGroup]
			and sg.[idfsRayon] is null
			and sg.[idfsCentralSite] is null
			and sg.[intRowStatus] = 0
			
		left join [dbo].[' + replace(@TflTable, N'''', N'''''') + N'] as cf
		on  cf.[' + replace(@FKFieldTflTable, N'''', N'''''') + N'] = ins.[' + replace(@PKFieldDBTable, N'''', N'''''') + N']
			and cf.[idfSiteGroup] = sg.[idfSiteGroup]
	where  cf.[' + replace(@PKFieldTflTable, N'''', N'''''') + N'] is null

	insert into [dbo].[' + replace(@TflTable, N'''', N'''''') + N']
		(
			[' + replace(@PKFieldTflTable, N'''', N'''''') + N'], 
			[' + replace(@FKFieldTflTable, N'''', N'''''') + N'], 
			[idfSiteGroup]
		)
	select 
			nID.[NewID], 
			ins.[' + replace(@PKFieldDBTable, N'''', N'''''') + N'], 
			nID.[idfKey2]
	from  inserted as ins
		inner join [dbo].[tflNewID] as nID
		on  nID.[strTableName] = @strTableName collate Cyrillic_General_CI_AS
			and nID.[idfKey1] = ins.[' + replace(@PKFieldDBTable, N'''', N'''''') + N']
			and nID.[idfKey2] is not null
		left join [dbo].[' + replace(@TflTable, N'''', N'''''') + N'] as cf
		on   cf.[' + replace(@PKFieldTflTable, N'''', N'''''') + N'] = nID.[NewID]
	where  cf.[' + replace(@PKFieldTflTable, N'''', N'''''') + N'] is null

	SET NOCOUNT OFF;
END
''
	exec sp_executesql @cmd
end
else begin
	print ''Table [' + replace(@DBTable, N'''', N'''''') + '] is not found''
end
'
	if @PrintCmd = 1
	begin
		print @cmd
	end
	if @PrintCmd = 1 and @ExecCmd = 1
		print N'--------------------------------------------------------------------------------------'
	if @ExecCmd = 1
	begin
		print	N'CREATED/ALTERED TRIGGER [' + replace(@TriggerToCreate, N'''', N'''''') + N']'
		set @cmd = REPLACE(@cmd, 'print	N''/*CREATED/ALTERED TRIGGER [' + replace(@TriggerToCreate, N'''', N'''''') + N']*/''', '')
		exec sp_executesql @cmd
	end
	if isnull(@PrintCmd, 0) = 0 and isnull(@ExecCmd, 0) = 0
		print	N'No output (print or execution) of Stored Procedure is expected'
end
else begin
	if object_id(@DBTable, N'U') is null
		print N'Table not found'
	else if object_id(@TflTable, N'U') is null
		print N'Corresponding Filtration Table is not found'
	else if @PKFieldTflTable is null
		print N'Cannot determine PK of corresponding Filtration Table'
end