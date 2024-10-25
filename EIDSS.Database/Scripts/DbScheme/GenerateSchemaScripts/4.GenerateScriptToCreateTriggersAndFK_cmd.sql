set nocount on

-----------------------------
-- Start block - Variables --
-----------------------------

---------------------------
-- End block - Variables --
---------------------------


-----------------------------------------------------------------------
-- Start block - Declare tables with system information on DB schema --
-----------------------------------------------------------------------

declare	@DbFK table
(	[FK_object_id]				int not null primary key,
	[source_table_object_id]	int not null,
	[source_schema_id]			int not null,
	[ref_table_object_id]		int not null,
	[ref_schema_id]				int not null,
	strFKName					nvarchar(200) collate Latin1_General_CI_AS not null,
	strSourceTableSchema		nvarchar(200) collate Latin1_General_CI_AS not null,
	strSourceTableName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strReferencedTableSchema	nvarchar(200) collate Latin1_General_CI_AS not null,
	strReferencedTableName		nvarchar(200) collate Latin1_General_CI_AS not null,
	[disabled]					bit not null default(0),
	not_trusted					bit not null default(0),
	delete_referential_action	nvarchar(200) collate Latin1_General_CI_AS null,
	update_referential_action	nvarchar(200) collate Latin1_General_CI_AS null,
	strSql						nvarchar(max) collate Latin1_General_CI_AS null
)


declare	@DbFKColumn table
(	[FK_object_id]				int not null,
	[source_table_object_id]	int not null,
	[source_schema_id]			int not null,
	[ref_table_object_id]		int not null,
	[ref_schema_id]				int not null,
	[source_column_id]			int not null,
	[ref_column_id]				int not null,
	[constraint_column_id]		int not null,
	strFKName					nvarchar(200) collate Latin1_General_CI_AS not null,
	strSourceTableSchema		nvarchar(200) collate Latin1_General_CI_AS not null,
	strSourceTableName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strReferencedTableSchema	nvarchar(200) collate Latin1_General_CI_AS not null,
	strReferencedTableName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strSourceColumnName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strReferencedColumnName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strSourceSql				nvarchar(max) collate Latin1_General_CI_AS null,
	strRefSql				nvarchar(max) collate Latin1_General_CI_AS null
)



declare	@DbTrigger table
(	[TR_object_id]			int not null primary key,
	[table_object_id]		int not null,
	[schema_id]				int not null,
	strTriggerName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableSchema			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName			nvarchar(200) collate Latin1_General_CI_AS not null,
	[disabled]				bit not null default(0),
	[not_for_replication]	bit not null default(0),
	[instead_of_trigger]	bit not null default(0),
	[definition]			nvarchar(max) collate Latin1_General_CI_AS null,
	[ansi_nulls]			bit not null default(0),
	[quoted_identifier]		bit not null default(0),
	strSql					nvarchar(max) collate Latin1_General_CI_AS null
)


---------------------------------------------------------------------
-- End block - Declare tables with system information on DB schema --
---------------------------------------------------------------------

-----------------------------------------------------------
-- Start block - Fill in system information on DB schema --
-----------------------------------------------------------



insert into	@DbFK
(	[FK_object_id],
	[source_table_object_id],
	[source_schema_id],
	[ref_table_object_id],
	[ref_schema_id],
	strFKName,
	strSourceTableSchema,
	strSourceTableName,
	strReferencedTableSchema,
	strReferencedTableName,
	[disabled],
	not_trusted,
	delete_referential_action,
	update_referential_action,
	strSql
)
select	fk.[object_id] as [FK_object_id],
		t_source.[object_id],
		t_source.[schema_id],
		t_ref.[object_id],
		t_ref.[schema_id],
		fk.[name] as strFKName,
		s_source.[name],
		t_source.[name] as strSourceTableName,
		s_ref.[name],
		t_ref.[name] as strReferencedTableName,
		fk.is_disabled,
		fk.is_not_trusted,
		--fk.is_not_for_replication,
		fk.delete_referential_action_desc,
		fk.update_referential_action_desc,
		N''
from	sys.foreign_keys fk
join	sys.tables t_source
on		t_source.[object_id] = fk.parent_object_id
		and t_source.is_filetable = 0
		and t_source.[type] = 'U' collate Latin1_General_CI_AS
		and t_source.[name] <> N'sysdiagrams' collate Latin1_General_CI_AS
		and t_source.[name] <> N'AppObjectSysFunction' collate Latin1_General_CI_AS
		and t_source.[name] <> N'LkupConfigParm' collate Latin1_General_CI_AS
		and t_source.[name] <> N'LkupCountryToStandardRoleMap' collate Latin1_General_CI_AS
		and t_source.[name] <> N'SiteToSiteAccess' collate Latin1_General_CI_AS
		and t_source.[name] <> N'tauAuditControl' collate Latin1_General_CI_AS
		and t_source.[name] <> N'tlbAdministrativeReportAudit' collate Latin1_General_CI_AS--?
		and t_source.[name] <> N'tlbEIDSSVersionControl' collate Latin1_General_CI_AS--?
		and t_source.[name] <> N'tlbEmployeeOffice' collate Latin1_General_CI_AS
		and t_source.[name] <> N'UserAccess' collate Latin1_General_CI_AS
		and t_source.[name] not like N'ZZ_%' collate Latin1_General_CI_AS
		and t_source.[name] not like N'_dmcc%' collate Latin1_General_CI_AS
join	sys.schemas s_source
on		s_source.[schema_id] = t_source.[schema_id]
		and (	s_source.[name] not like N'Migr%' collate Latin1_General_CI_AS
			)
join	sys.tables t_ref
on		t_ref.[object_id] = fk.referenced_object_id
		and t_ref.is_filetable = 0
		and t_ref.[type] = 'U' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'sysdiagrams' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'AppObjectSysFunction' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'LkupConfigParm' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'LkupCountryToStandardRoleMap' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'SiteToSiteAccess' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'tauAuditControl' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'tlbAdministrativeReportAudit' collate Latin1_General_CI_AS--?
		and t_ref.[name] <> N'tlbEIDSSVersionControl' collate Latin1_General_CI_AS--?
		and t_ref.[name] <> N'tlbEmployeeOffice' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'UserAccess' collate Latin1_General_CI_AS
		and t_ref.[name] not like N'ZZ_%' collate Latin1_General_CI_AS
		and t_ref.[name] not like N'_dmcc%' collate Latin1_General_CI_AS
join	sys.schemas s_ref
on		s_ref.[schema_id] = t_ref.[schema_id]
		and (	s_ref.[name] not like N'Migr%' collate Latin1_General_CI_AS
			)
order by	t_source.[name], fk.[name]


insert into	@DbFKColumn
(	[FK_object_id],
	[source_table_object_id],
	[source_schema_id],
	[ref_table_object_id],
	[ref_schema_id],
	[source_column_id],
	[ref_column_id],
	[constraint_column_id],
	strFKName,
	strSourceTableSchema,
	strSourceTableName,
	strReferencedTableSchema,
	strReferencedTableName,
	strSourceColumnName,
	strReferencedColumnName,
	strSourceSql,
	strRefSql
)
select	fk.[object_id] as [FK_object_id],
		t_source.[object_id],
		t_source.[schema_id],
		t_ref.[object_id],
		t_ref.[schema_id],
		c_source.[column_id],
		c_ref.[column_id],
		fkc.[constraint_column_id],
		fk.[name] as strFKName,
		s_source.[name],
		t_source.[name] as strSourceTableName,
		s_ref.[name],
		t_ref.[name] as strReferencedTableName,
		c_source.[name] as strSourceColumnName,
		c_ref.[name] as strReferencedColumnName,
		N'',
		N''
from	sys.foreign_keys fk
join	sys.tables t_source
on		t_source.[object_id] = fk.parent_object_id
		and t_source.is_filetable = 0
		and t_source.[type] = 'U' collate Latin1_General_CI_AS
		and t_source.[name] <> N'sysdiagrams' collate Latin1_General_CI_AS
		and t_source.[name] <> N'AppObjectSysFunction' collate Latin1_General_CI_AS
		and t_source.[name] <> N'LkupConfigParm' collate Latin1_General_CI_AS
		and t_source.[name] <> N'LkupCountryToStandardRoleMap' collate Latin1_General_CI_AS
		and t_source.[name] <> N'SiteToSiteAccess' collate Latin1_General_CI_AS
		and t_source.[name] <> N'tauAuditControl' collate Latin1_General_CI_AS
		and t_source.[name] <> N'tlbAdministrativeReportAudit' collate Latin1_General_CI_AS--?
		and t_source.[name] <> N'tlbEIDSSVersionControl' collate Latin1_General_CI_AS--?
		and t_source.[name] <> N'tlbEmployeeOffice' collate Latin1_General_CI_AS
		and t_source.[name] <> N'UserAccess' collate Latin1_General_CI_AS
		and t_source.[name] not like N'ZZ_%' collate Latin1_General_CI_AS
		and t_source.[name] not like N'_dmcc%' collate Latin1_General_CI_AS
join	sys.schemas s_source
on		s_source.[schema_id] = t_source.[schema_id]
		and (	s_source.[name] not like N'Migr%' collate Latin1_General_CI_AS
			)
join	sys.tables t_ref
on		t_ref.[object_id] = fk.referenced_object_id
		and t_ref.is_filetable = 0
		and t_ref.[type] = 'U' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'sysdiagrams' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'AppObjectSysFunction' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'LkupConfigParm' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'LkupCountryToStandardRoleMap' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'SiteToSiteAccess' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'tauAuditControl' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'tlbAdministrativeReportAudit' collate Latin1_General_CI_AS--?
		and t_ref.[name] <> N'tlbEIDSSVersionControl' collate Latin1_General_CI_AS--?
		and t_ref.[name] <> N'tlbEmployeeOffice' collate Latin1_General_CI_AS
		and t_ref.[name] <> N'UserAccess' collate Latin1_General_CI_AS
		and t_ref.[name] not like N'ZZ_%' collate Latin1_General_CI_AS
		and t_ref.[name] not like N'_dmcc%' collate Latin1_General_CI_AS
join	sys.schemas s_ref
on		s_ref.[schema_id] = t_ref.[schema_id]
		and (	s_ref.[name] not like N'Migr%' collate Latin1_General_CI_AS
			)
join	sys.foreign_key_columns fkc
on		fkc.constraint_object_id = fk.[object_id]
		and fkc.parent_object_id = t_source.[object_id]
		and fkc.referenced_object_id = t_ref.[object_id]
join	sys.columns c_source
on		c_source.[object_id] = fkc.parent_object_id
		and c_source.[column_id] = fkc.parent_column_id
join	sys.columns c_ref
on		c_ref.[object_id] = fkc.referenced_object_id
		and c_ref.[column_id] = fkc.referenced_column_id
order by	t_source.[name], fk.[name], fkc.constraint_column_id


insert into	@DbTrigger
(	[TR_object_id],
	[table_object_id],
	[schema_id],
	strTriggerName,
	strTableSchema,
	strTableName,
	[disabled],
	[not_for_replication],
	[instead_of_trigger],
	[definition],
	[ansi_nulls],
	[quoted_identifier],
	strSql
)
select	tr.[object_id], 
		t.[object_id],
		t.[schema_id],
		tr.[name],
		s.[name],
		t.[name],
		tr.[is_disabled],
		tr.[is_not_for_replication],
		tr.[is_instead_of_trigger],
		m.[definition],
		m.[uses_ansi_nulls],
		m.[uses_quoted_identifier],
		N''
from	sys.triggers tr
join	sys.tables t
on		t.[object_id] = tr.[parent_id]
		and t.is_filetable = 0
		and t.[type] = 'U' collate Latin1_General_CI_AS
		and t.[name] <> N'sysdiagrams' collate Latin1_General_CI_AS
		and t.[name] <> N'AppObjectSysFunction' collate Latin1_General_CI_AS
		and t.[name] <> N'LkupConfigParm' collate Latin1_General_CI_AS
		and t.[name] <> N'LkupCountryToStandardRoleMap' collate Latin1_General_CI_AS
		and t.[name] <> N'SiteToSiteAccess' collate Latin1_General_CI_AS
		and t.[name] <> N'tauAuditControl' collate Latin1_General_CI_AS
		and t.[name] <> N'tlbAdministrativeReportAudit' collate Latin1_General_CI_AS--?
		and t.[name] <> N'tlbEIDSSVersionControl' collate Latin1_General_CI_AS--?
		and t.[name] <> N'tlbEmployeeOffice' collate Latin1_General_CI_AS
		and t.[name] <> N'UserAccess' collate Latin1_General_CI_AS
		and t.[name] not like N'ZZ_%' collate Latin1_General_CI_AS
		and t.[name] not like N'_dmcc%' collate Latin1_General_CI_AS
join	sys.schemas s
on		s.[schema_id] = t.[schema_id]
		and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
			)
join	sys.sql_modules m
on		m.[object_id] = tr.[object_id]

---------------------------------------------------------
-- End block - Fill in system information on DB schema --
---------------------------------------------------------


----------------------------------------------
-- Start block - Generate Sql based on info --
----------------------------------------------


select	N'
SET XACT_ABORT ON 
SET NOCOUNT ON 

/*Specify or update name of the EIDSSv7 database here
  Note: (1) Database shall exist with schemas of the tables except triggers and foreign keys.
		(2) Script is not applicable for cloud-hosted databases.
		(3) Stored Procedure sp_executesql shall be enabled for the instance of SQL Server, where database triggers and foreign keys shall be created.
*/
declare @DbName sysname = ''EIDSS7''

declare @cmd nvarchar(max) = N''''

declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''''

if not exists (select 1 from sys.databases where [name] = @DbName collate Latin1_General_CI_AS)
begin
	set @Error = 1
	set @ErrorMsg = N''Database with name ['' + isnull(@DbName, N'''') + N''] does not exists. Please specify name of existing database with empty schema again.''
end
else begin
	declare @isDbWithTables bit = 0
	declare @isDbWithTriggersOrFKs bit = 0

	set @cmd = N''
	set @isDbWithTablesOut = 0
	if exists (select 1 from ['' + @DbName + N''].sys.tables)
	begin
		set @isDbWithTablesOut = 1
	end

	set @isDbWithTriggersOrFKsOut = 0
	if exists (select 1 from ['' + @DbName + N''].sys.triggers)
		or exists (select 1 from ['' + @DbName + N''].sys.foreign_keys)
	begin
		set @isDbWithTriggersOrFKsOut = 1
	end
	''
	exec sp_executesql 
			@cmd, 
			N''@isDbWithTablesOut bit output,  @isDbWithTriggersOrFKsOut bit output'', 
			@isDbWithTablesOut = @isDbWithTables output,
			@isDbWithTriggersOrFKsOut = @isDbWithTriggersOrFKs output

	if @isDbWithTables = 0
	begin
		set @Error = 1
		set @ErrorMsg = N''Database with name ['' + isnull(@DbName, N'''') + N''] does not have tables. No changes will be applied. Please specify name of existing database with tables and no triggers or foreign keys, and then execute script again.''
	end
	else if @isDbWithTriggersOrFKs = 1
	begin
		set @Error = 1
		set @ErrorMsg = N''Database with name ['' + isnull(@DbName, N'''') + N''] contains triggers or foreign keys. No changes will be applied. Please specify name of existing database with tables and no triggers or foreign keys, and then execute script again.''
	end
end

if @Error <> 0
begin
	raiserror(@ErrorMsg, 16, 1) with seterror;
end
else begin

set @cmd = N''''

'


select	N'

-- Triggers --

'

declare	@tr_ansi_nulls bit, @tr_quoted_identifier bit, @tr_definition nvarchar(max)

--Declare cursor and populate with data
DECLARE tr_cursor CURSOR FOR  
SELECT tr.[ansi_nulls], tr.[quoted_identifier], replace(tr.[definition], N'''', N'''''''''')
FROM @DbTrigger tr
order by tr.strTableSchema, tr.strTableName, tr.strTriggerName

--Open cursor
OPEN tr_cursor   
FETCH NEXT FROM tr_cursor INTO @tr_ansi_nulls, @tr_quoted_identifier, @tr_definition

WHILE @@FETCH_STATUS = 0   
BEGIN   

select	N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ' + replace(replace(cast(@tr_ansi_nulls as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
' +
N'
SET QUOTED_IDENTIFIER ' + replace(replace(cast(@tr_quoted_identifier as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd
set @cmd = N''''''''
''
' collate Latin1_General_CI_AS



select		case
				when	isnull(trLine.strOne, N'') = N'' collate Latin1_General_CI_AS
					then	N''
				else	N'
set @cmd = @cmd + N''
set @cmd = @cmd + N''''
' + replace(isnull(trLine.strOne, N''), CHAR(10), N'') + N'''''''' collate Latin1_General_CI_AS
			end
from		fnSplitString2(@tr_definition, CHAR(13)) trLine
where		isnull(trLine.strOne, N'') <> N'' collate Latin1_General_CI_AS
order by trLine.listpos


select	N'
set @cmd = @cmd + N'' exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' execute sp_executesql @cmd
'
    --Fetch next records
    FETCH NEXT FROM tr_cursor INTO @tr_ansi_nulls, @tr_quoted_identifier, @tr_definition
END
   
--Close and deallocate cursor
CLOSE tr_cursor   
DEALLOCATE tr_cursor




select	N'

-- Foreign Keys --

'

update		fkc
set			fkc.strSourceSql = N'[' + fkc.[strSourceColumnName] + N']' +
	case 
		when	fkc.[constraint_column_id] < fk_max_col.[constraint_column_id]
			then	N', '
		else	N'' 
	end 
	collate Latin1_General_CI_AS,
			fkc.strRefSql = N'[' + fkc.[strReferencedColumnName] + N']' +
	case 
		when	fkc.[constraint_column_id] < fk_max_col.[constraint_column_id]
			then	N', '
		else	N'' 
	end 
	collate Latin1_General_CI_AS
from		@DbFKColumn fkc
outer apply
(	select		max(fkc_max.[constraint_column_id]) as [constraint_column_id]
	from		@DbFKColumn fkc_max
	where		fkc_max.[FK_object_id] = fkc.[FK_object_id]
				and fkc_max.[source_table_object_id] = fkc.[source_table_object_id]
				and fkc_max.[ref_table_object_id] = fkc.[ref_table_object_id]
) fk_max_col


select		N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
ALTER TABLE [' + fk.strSourceTableSchema + N'].[' + fk.strSourceTableName + N'] ' + 
N' WITH NOCHECK ADD  CONSTRAINT [' + fk.strFKName + N'] FOREIGN KEY(' + colFKSource.strSql + N')' + N'
REFERENCES [' + fk.strReferencedTableSchema + N'].[' + fk.strReferencedTableName + N'] (' + colFKRef.strSql + N')' + N'
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
', N'
ALTER TABLE [' + fk.strSourceTableSchema + N'].[' + fk.strSourceTableName + N'] CHECK CONSTRAINT [' + fk.strFKName + N']
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' execute sp_executesql @cmd

' collate Latin1_General_CI_AS
from		@DbFK fk
cross apply
(	select	replace
			(	(	select		N'' + c.strSourceSql collate Latin1_General_CI_AS
					from		@DbFKColumn c
					where		c.[FK_object_id] = fk.[FK_object_id]
								and c.strSourceSql is not null
								and c.strRefSql is not null
					order by	c.[constraint_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			) strSql
) colFKSource
cross apply
(	select	replace
			(	(	select		N'' + c.strRefSql collate Latin1_General_CI_AS
					from		@DbFKColumn c
					where		c.[FK_object_id] = fk.[FK_object_id]
								and c.strSourceSql is not null
								and c.strRefSql is not null
					order by	c.[constraint_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			) strSql
) colFKRef



select N'

end


SET NOCOUNT OFF 
SET XACT_ABORT OFF 
'

--------------------------------------------
-- End block - Generate Sql based on info --
--------------------------------------------

set nocount off
