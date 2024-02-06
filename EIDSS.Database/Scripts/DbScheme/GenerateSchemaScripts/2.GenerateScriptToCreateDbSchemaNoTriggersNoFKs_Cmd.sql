set nocount on

-----------------------------
-- Start block - Variables --
-----------------------------

declare @DbName nvarchar(200) = DB_NAME()

---------------------------
-- End block - Variables --
---------------------------


-----------------------------------------------------------------------
-- Start block - Declare tables with system information on DB schema --
-----------------------------------------------------------------------

declare	@DbInfo table
(	[database_id]					int not null primary key,
	strDBName						nvarchar(200) collate Latin1_General_CI_AS not null,
	[containment]					nvarchar(200) collate Latin1_General_CI_AS not null default(N'NONE'),
	collation_name					nvarchar(200) collate Latin1_General_CI_AS not null default(N'Cyrillic_General_CI_AS'),
	-- CREATE DATABASE [' + replace(@DbName, N'''', N'''''') + N']
	-- CONTAINMENT = NONE
	-- ON  PRIMARY 
	--( NAME = N'PACS__Data', FILENAME = N'D:\SQLServerData\' + replace(@DbName, N'''', N'''''') + N'.mdf' , SIZE = 49920KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
	-- LOG ON 
	--( NAME = N'PACS__Log', FILENAME = N'E:\SQLServerLogFiles\' + replace(@DbName, N'''', N'''''') + N'_log.ldf' , SIZE = 164672KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
	-- COLLATE ' + collation_name + N'
	[compatibility_level]			int not null default(110), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET COMPATIBILITY_LEVEL = 110
	[fulltext_enabled]				bit not null default(0), -- IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')) 
															 -- begin EXEC [' + replace(@DbName, N'''', N'''''') + N'].[dbo].[sp_fulltext_database] @action = 'disable' end
	[ansi_null_default]				bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] ANSI_NULL_DEFAULT OFF
	[ansi_nulls]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] ANSI_NULLS OFF
	[ansi_padding]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] ANSI_PADDING OFF
	[ansi_warnings]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] ANSI_WARNINGS OFF
	[arithabort]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] ARITHABORT OFF
	[auto_close]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET AUTO_CLOSE OFF 
	auto_create_stats				bit not null default(1), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET AUTO_CREATE_STATISTICS ON 
	[auto_shrink]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET AUTO_SHRINK OFF 
	auto_update_stats				bit not null default(1),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET AUTO_UPDATE_STATISTICS ON 
	[cursor_close_on_commit]		bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET CURSOR_CLOSE_ON_COMMIT OFF 
	[local_cursor_default]			bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET CURSOR_DEFAULT GLOBAL 
	[concat_null_yields_null]		bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET CONCAT_NULL_YIELDS_NULL OFF 
	[numeric_roundabort]			bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET NUMERIC_ROUNDABORT OFF 
	[quoted_identifier]				bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET QUOTED_IDENTIFIER OFF 
	[recursive_triggers]			bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET RECURSIVE_TRIGGERS OFF 
	[broker_enabled]				bit not null default(0),  -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET DISABLE_BROKER 
	auto_update_stats_async			bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
	[date_correlation]				bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET DATE_CORRELATION_OPTIMIZATION OFF 
	[thrustworthy]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET TRUSTWORTHY OFF 
	snapshot_isolation				nvarchar(200) collate Latin1_General_CI_AS not null default (N'OFF'), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET ALLOW_SNAPSHOT_ISOLATION OFF
	[parameterization]				bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET PARAMETERIZATION SIMPLE 
	read_commited_snapshot			bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET READ_COMMITTED_SNAPSHOT OFF
	[honor_broker_priority]			bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET HONOR_BROKER_PRIORITY OFF
	recovery_model					nvarchar(200) collate Latin1_General_CI_AS not null default (N'SIMPLE'), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET RECOVERY SIMPLE 
	user_access						nvarchar(200) collate Latin1_General_CI_AS not null default (N'MULTI_USER'), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET  MULTI_USER
	page_verify_option				nvarchar(200) collate Latin1_General_CI_AS not null default (N'TORN_PAGE_DETECTION'), -- ALTER DATABASE [[' + replace(@DbName, N'''', N'''''') + N'] SET PAGE_VERIFY TORN_PAGE_DETECTION 
	[db_changing]					bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET DB_CHAINING OFF 
	[target_recovery_time]			int not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET TARGET_RECOVERY_TIME = 0 SECONDS,
	filestream_non_transact_access	nvarchar(200) collate Latin1_General_CI_AS not null default (N'OFF'), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
	filestream_directory			nvarchar(200) collate Latin1_General_CI_AS null,
	[read_only]						bit not null default(0), -- ALTER DATABASE [' + replace(@DbName, N'''', N'''''') + N'] SET READ_WRITE
	strSql							nvarchar(max) collate Latin1_General_CI_AS null
)

declare	@InstanceDefaultDataPath nvarchar(max)
declare	@InstanceDefaultLogPath nvarchar(max)

declare	@DbFile	table
(	[file_id]				int not null primary key,
	file_type				nvarchar(200) collate Latin1_General_CI_AS not null,
	file_extension			nvarchar(200) collate Latin1_General_CI_AS null,
	logical_name			nvarchar(200) collate Latin1_General_CI_AS not null,
	[file_group_name]		nvarchar(200) collate Latin1_General_CI_AS null,
	[file_group_type]		nvarchar(200) collate Latin1_General_CI_AS null,
	physical_path			nvarchar(max) collate Latin1_General_CI_AS not null,
	size					int not null,
	max_size				int not null default(-1),
	growth					int not null,
	percent_growth			bit not null default(1),
	strSql					nvarchar(max) collate Latin1_General_CI_AS null,
	intOrder				int not null default(0)
)

declare	@DbSchema table
(	[schema_id]				int not null,
	[principal_id]			int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strPrincipalName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strSql					nvarchar(max) collate Latin1_General_CI_AS null
)


declare	@DbTableType table
(	[user_type_id]			int not null primary key,
	[type_table_object_id]	int not null,
	[PK_object_id]			int null,
	[PK_name]				nvarchar(200) collate Latin1_General_CI_AS null,
	[PK_index_type]			nvarchar(200) collate Latin1_General_CI_AS null,
	[PK_padded]				bit null default(0),
	[PK_stat_no_recompute]	bit null default(0),
	[PK_ignore_dup_key]		bit null default(0),
	[PK_allow_row_locks]	bit null default(0),
	[PK_allow_page_locks]	bit null default(0),
	[PK_fill_factor]		tinyint null,
	[schema_id]				int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableTypeName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strSql					nvarchar(max) collate Latin1_General_CI_AS null
)

declare	@DbTableTypeColumn table
(	[user_type_id]			int not null,
	[type_table_object_id]	int not null,
	[schema_id]				int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableTypeName		nvarchar(200) collate Latin1_General_CI_AS not null,
	[column_id]				int not null,
	strColumnName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strColumnType			nvarchar(200) collate Latin1_General_CI_AS not null,
	intColumnMaxLength		smallint not null default(0),
	strCollationName		nvarchar(200) collate Latin1_General_CI_AS null default(N''),
	[nullable]				bit not null default(0),
	[ansi_padded]			bit not null default(0),
	[identity]				bit not null default(0),
	[seed_value]			nvarchar(200) collate Latin1_General_CI_AS null,
	[increment_value]		nvarchar(200) collate Latin1_General_CI_AS null,
	[default_value]			nvarchar(200) collate Latin1_General_CI_AS null,
	strSql					nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[type_table_object_id]	asc,
		[column_id] asc
	)
)


declare	@DbTableTypePKColumn table
(	[user_type_id]			int not null,
	[type_table_object_id]	int not null,
	[PK_object_id]			int not null,
	[column_id]				int not null,
	[index_column_id]		int not null,
	[schema_id]				int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableTypeName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strPKName				nvarchar(200) collate Latin1_General_CI_AS not null,
	strColumnName			nvarchar(200) collate Latin1_General_CI_AS not null,
	is_descending_key		bit not null default(0),
	strSql					nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[type_table_object_id] asc,
		[index_column_id] asc
	)
)

declare	@DbFileTable table
(	[table_object_id]	int not null primary key,
	strTableName		nvarchar(200) collate Latin1_General_CI_AS not null,
	file_group_name		nvarchar(200) collate Latin1_General_CI_AS not null,
	collation_name		nvarchar(200) collate Latin1_General_CI_AS not null,
	[ansi_nulls]		bit not null default(0),
	[quoted_identifier]	bit not null default(0),
	strSql				nvarchar(max) collate Latin1_General_CI_AS null
)


declare	@DbTable table
(	[table_object_id]		int not null primary key,
	[schema_id]				int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName			nvarchar(200) collate Latin1_General_CI_AS not null,
	[PK_object_id]			int null,
	[PK_name]				nvarchar(200) collate Latin1_General_CI_AS null,
	[PK_index_type]			nvarchar(200) collate Latin1_General_CI_AS null,
	[PK_padded]				bit null default(0),
	[PK_stat_no_recompute]	bit null default(0),
	[PK_ignore_dup_key]		bit null default(0),
	[PK_allow_row_locks]	bit null default(0),
	[PK_allow_page_locks]	bit null default(0),
	[PK_fill_factor]		tinyint null,
	[ansi_nulls]			bit not null default(0),
	[quoted_identifier]		bit not null default(0),
	strSql					nvarchar(max) collate Latin1_General_CI_AS null,
	strInsert				nvarchar(max) collate Latin1_General_CI_AS null,
	strSqlAfterCreate		nvarchar(max) collate Latin1_General_CI_AS null,
	intOrder				int not null default(0)
)


declare	@DbTableColumn table
(	[table_object_id]			int not null,
	[schema_id]					int not null,
	strSchemaName				nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName				nvarchar(200) collate Latin1_General_CI_AS not null,
	[column_id]					int not null,
	strColumnName				nvarchar(200) collate Latin1_General_CI_AS not null,
	strColumnType				nvarchar(200) collate Latin1_General_CI_AS not null,
	intColumnMaxLength			smallint not null default(0),
	strCollationName			nvarchar(200) collate Latin1_General_CI_AS null default(N''),
	[nullable]					bit not null default(0),
	[ansi_padded]				bit not null default(0),
	[identity]					bit not null default(0),
	[seed_value]				nvarchar(200) collate Latin1_General_CI_AS null,
	[increment_value]			nvarchar(200) collate Latin1_General_CI_AS null,
	[is_not_for_replication]	bit not null default(0),
	[is_rowguidcol]				bit not null default(0),
	[is_computed]				bit not null default(0),
	[is_persisted]				bit not null default(0),
	[computed_col_def]			nvarchar(4000) collate Latin1_General_CI_AS null,
	[DF_name]					nvarchar(200) collate Latin1_General_CI_AS null,
	[default_value]				nvarchar(200) collate Latin1_General_CI_AS null,
	strSql						nvarchar(max) collate Latin1_General_CI_AS null,
	strDefaultConstraint		nvarchar(max) collate Latin1_General_CI_AS null,
	strAlterPadding				nvarchar(max) collate Latin1_General_CI_AS null,
	strInsert					nvarchar(max) collate Latin1_General_CI_AS null,
	strSelect					nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[table_object_id] asc,
		[column_id] asc
	)
)


declare	@DbTablePKColumn table
(	[table_object_id]	int not null,
	[PK_object_id]		int not null,
	[column_id]			int not null,
	[index_column_id]	int not null,
	[schema_id]			int not null,
	strSchemaName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strPKName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strColumnName		nvarchar(200) collate Latin1_General_CI_AS not null,
	is_descending_key	bit not null default(0),
	strSql				nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[table_object_id] asc,
		[index_column_id] asc
	)
)


declare	@DbTableUQ table
(	[table_object_id]		int not null primary key,
	[schema_id]				int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName			nvarchar(200) collate Latin1_General_CI_AS not null,
	[UQ_object_id]			int null,
	[UQ_index_id]			int null,
	[UQ_name]				nvarchar(200) collate Latin1_General_CI_AS null,
	[UQ_index_type]			nvarchar(200) collate Latin1_General_CI_AS null,
	[UQ_padded]				bit null default(0),
	[UQ_stat_no_recompute]	bit null default(0),
	[UQ_ignore_dup_key]		bit null default(0),
	[UQ_allow_row_locks]	bit null default(0),
	[UQ_allow_page_locks]	bit null default(0),
	[UQ_fill_factor]		tinyint null,
	strSql					nvarchar(max) collate Latin1_General_CI_AS null
)



declare	@DbTableUQColumn table
(	[table_object_id]	int not null,
	[UQ_object_id]		int not null,
	[UQ_index_id]		int null,
	[column_id]			int not null,
	[index_column_id]	int not null,
	[schema_id]			int not null,
	strSchemaName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strUQName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strColumnName		nvarchar(200) collate Latin1_General_CI_AS not null,
	is_descending_key	bit not null default(0),
	strSql				nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[table_object_id] asc,
		[index_column_id] asc
	)
)



declare	@DbTableColumnExtendedProperties table
(	[table_object_id]			int not null,
	[schema_id]					int not null,
	[column_id]					int not null default(0), -- 0 matches table level
	strExtendedPropertyName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strExtendedPropertyValue	nvarchar(2000) collate Latin1_General_CI_AS null,
	level0type					nvarchar(200) collate Latin1_General_CI_AS not null default(N'SCHEMA'),
	level0name					nvarchar(200) collate Latin1_General_CI_AS not null,
	level1type					nvarchar(200) collate Latin1_General_CI_AS not null default(N'TABLE'),
	level1name					nvarchar(200) collate Latin1_General_CI_AS not null,
	level2type					nvarchar(200) collate Latin1_General_CI_AS null,
	level2name					nvarchar(200) collate Latin1_General_CI_AS null,
	strSql						nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[table_object_id] asc,
		[column_id] asc,
		strExtendedPropertyName asc
	)
)


declare	@DbIndex table
(	[index_id]				int not null,
	[table_object_id]		int not null,
	[schema_id]				int not null,
	strSchemaName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strIndexName			nvarchar(200) collate Latin1_General_CI_AS not null,
	strIndexType			nvarchar(200) collate Latin1_General_CI_AS not null,
	[unique]				bit not null default(0),
	unique_constraint		bit not null default(0),
	padded					bit not null default(0),
	[disabled]				bit not null default(0),
	[ignore_dup_key]		bit not null default(0),
	has_filter				bit not null default(0),
	filter_definition		nvarchar(max) collate Latin1_General_CI_AS null,
	fill_factor				int not null default(0),
	[allow_page_locks]		bit not null default(0),
	[allow_row_locks]		bit not null default(0),
	stat_no_recompute		bit not null default(0),
	tessellation_scheme		nvarchar(200) collate Latin1_General_CI_AS null,
	bounding_box_xmin		float null,
	bounding_box_ymin		float null,
	bounding_box_xmax		float null,
	bounding_box_ymax		float null,
	level_1_grid_desc		nvarchar(200) collate Latin1_General_CI_AS null,
	level_2_grid_desc		nvarchar(200) collate Latin1_General_CI_AS null,
	level_3_grid_desc		nvarchar(200) collate Latin1_General_CI_AS null,
	level_4_grid_desc		nvarchar(200) collate Latin1_General_CI_AS null,
	cells_per_object		int null,
	strSql					nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[table_object_id] asc,
		[index_id] asc
	)
)


declare	@DbIndexColumn table
(	[index_id]			int not null,
	[table_object_id]	int not null,
	[index_column_id]	int not null,
	[column_id]			int not null,
	[schema_id]			int not null,
	strSchemaName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strTableName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strIndexName		nvarchar(200) collate Latin1_General_CI_AS not null,
	strIndexType		nvarchar(200) collate Latin1_General_CI_AS not null,
	strColumnName		nvarchar(200) collate Latin1_General_CI_AS not null,
	is_descending_key	bit not null default(0),
	is_included_column	bit not null default(0),
	col_ansi_padding	bit not null default(0),
	strSql				nvarchar(max) collate Latin1_General_CI_AS null,
	primary key
	(	[table_object_id] asc,
		[index_id] asc,
		[index_column_id] asc
	)
)


---------------------------------------------------------------------
-- End block - Declare tables with system information on DB schema --
---------------------------------------------------------------------

-----------------------------------------------------------
-- Start block - Fill in system information on DB schema --
-----------------------------------------------------------

insert into	@DbInfo
(	[database_id],
	strDBName,
	[containment],
	collation_name,
	[compatibility_level],
	[fulltext_enabled],
	[ansi_null_default],
	[ansi_nulls],
	[ansi_padding],
	[ansi_warnings],
	[arithabort],
	[auto_close],
	auto_create_stats,
	[auto_shrink],
	auto_update_stats,
	[cursor_close_on_commit],
	[local_cursor_default],
	[concat_null_yields_null],
	[numeric_roundabort],
	[quoted_identifier],
	[recursive_triggers],
	[broker_enabled],
	auto_update_stats_async,
	[date_correlation],
	[thrustworthy],
	snapshot_isolation,
	[parameterization],
	read_commited_snapshot,
	[honor_broker_priority],
	recovery_model,
	user_access,
	page_verify_option,
	[db_changing],
	[target_recovery_time],
	filestream_non_transact_access,
	filestream_directory,
	[read_only],
	strSql
)
select		d.[database_id],
			d.[name],
			d.[containment_desc],
			d.[collation_name],
			d.[compatibility_level],
			d.[is_fulltext_enabled],
			d.[is_ansi_null_default_on],
			d.[is_ansi_nulls_on],
			d.[is_ansi_padding_on],
			d.[is_ansi_warnings_on],
			d.[is_arithabort_on],
			d.[is_auto_close_on],
			d.[is_auto_create_stats_on],
			d.[is_auto_shrink_on],
			d.[is_auto_update_stats_on],
			d.[is_cursor_close_on_commit_on],
			d.[is_local_cursor_default],
			d.[is_concat_null_yields_null_on],
			d.[is_numeric_roundabort_on],
			d.[is_quoted_identifier_on],
			d.[is_recursive_triggers_on],
			d.[is_broker_enabled],
			d.[is_auto_update_stats_async_on],
			d.[is_date_correlation_on],
			d.[is_trustworthy_on],
			d.[snapshot_isolation_state_desc],
			d.[is_parameterization_forced],
			d.[is_read_committed_snapshot_on],
			d.[is_honor_broker_priority_on],
			d.[recovery_model_desc],
			d.[user_access_desc],
			d.[page_verify_option_desc],
			d.[is_db_chaining_on],
			d.[target_recovery_time_in_seconds],
			fso.non_transacted_access_desc,
			fso.directory_name,
			d.[is_read_only],
			N''
from		sys.databases d
left join	sys.database_filestream_options fso
on			fso.database_id = d.database_id
where		d.[name] = @DbName collate Latin1_General_CI_AS


insert into	@DbFile
(	[file_id],
	file_type,
	file_extension,
	[file_group_name],
	[file_group_type],
	logical_name,
	physical_path,
	size,
	max_size,
	growth,
	percent_growth,
	strSql,
	intOrder
)
select		df.[file_id],
			df.[type_desc],
			case
				when	df.[type_desc] = N'ROWS' collate Latin1_General_CI_AS
					then	N'.mdf'
				when	df.[type_desc] = N'LOG' collate Latin1_General_CI_AS
					then	N'.ldf'
				else	N''
			end,
			fg.[name],
			fg.[type_desc],
			df.[name],
			df.physical_name, 
			df.size,
			df.max_size,
			df.growth,
			df.[is_percent_growth],
			N'',
			0
from		sys.database_files df
left join	sys.filegroups fg
on			fg.data_space_id = df.data_space_id


update		df
set			df.intOrder =
			case
				when	df.file_type = N'ROWS' collate Latin1_General_CI_AS
					then	1
				when	df.file_type = N'LOG' collate Latin1_General_CI_AS
					then	df_count.intCount
				when	df.file_type = N'FILESTREAM' collate Latin1_General_CI_AS
					then	2
			end

from		@DbFile df
cross apply
(	select	count(dfc.[file_id]) as intCount
	from	@DbFile dfc
)	df_count

insert into	@DbSchema
(	[schema_id],
	[principal_id],
	strSchemaName,
	strPrincipalName,
	strSql
)
select		s.[schema_id],
			s.[principal_id],
			s.[name] as strSchemaName,
			p.[name] as strPrincipalName,
			N''
from		sys.schemas s
inner join	sys.database_principals p
on			p.[principal_id] = s.[principal_id]
			and p.[type] = N'S' /*SQL_USER*/
			and p.[name] = N'dbo'
where		s.[schema_id] > 1
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)


insert into	@DbTable
(	[table_object_id],
	[schema_id],
	[strSchemaName],
	strTableName,
	[PK_object_id],
	[PK_name],
	[PK_index_type],
	[PK_padded],
	[PK_stat_no_recompute],
	[PK_ignore_dup_key],
	[PK_allow_row_locks],
	[PK_allow_page_locks],
	[PK_fill_factor],
	[ansi_nulls],
	[quoted_identifier],
	strSql
)
select		t.[object_id] as [table_object_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name] as strTableName,
			pk.[object_id] as [PK_object_id],
			--i.[index_id] as [PK_index_id],
			pk.[name] as strPKName,
			i.[type_desc],
			i.[is_padded],
			i_stat.[no_recompute],
			i.[ignore_dup_key],
			i.[allow_row_locks],
			i.[allow_page_locks],
			i.fill_factor,
			t.[uses_ansi_nulls] as [ansi_nulls],
			1 as [quoted_identifier],
			N''
from		sys.tables t
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
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
(	select top 1
				s.no_recompute
	from		sys.stats s
	where		s.[object_id] = t.[object_id]
				and s.[name] = pk.[name] collate Latin1_General_CI_AS
				and (s.is_temporary = 0 or s.is_temporary is null)
	order by	s.[stats_id]
) i_stat
where		t.[type] = N'U' collate Latin1_General_CI_AS
			and t.is_filetable = 0
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


update	t
set		t.intOrder = -3,
		t.strSqlAfterCreate = N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
SET QUOTED_IDENTIFIER ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
/*
--*************************************************************
-- Name 				: FN_SiteID_GET
-- Description			: Funtion to return userid 
--          
-- Author               : Mandar Kulkarni
-- Revision History
--
-- Name			  Date		   Change Detail
-- Mark Wilson	  07-Nov-2019  removed fnGetContext
--
-- usage
--
-- SELECT dbo.FN_SiteID_GET()
--
*/
CREATE FUNCTION [dbo].[FN_SiteID_GET]()
RETURNS BIGINT
AS
BEGIN
	DECLARE @ret BIGINT
	
	SELECT 
		@ret = CAST(strValue AS BIGINT)
	FROM dbo.tstLocalSiteOptions
	
	WHERE strName = ''''''''SiteID''''''''
	
	RETURN @ret

END
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd 
'
from	@DbTable t
where	t.strTableName = N'tstLocalSiteOptions' collate Latin1_General_CI_AS

update	t
set		t.intOrder = -2,
		t.strSqlAfterCreate = N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
SET QUOTED_IDENTIFIER ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
--##SUMMARY During opening connection EIDSS stores ClientID string in the connection context.
--##SUMMARY This function converts connection context to string, truncates trailing zeros
--##SUMMARY and returns this processed string.


--##RETURNS string stored in the current connection context


/*
--Example of function:

EXEC spSetContext ''''''''Test''''''''
DECLARE @s varchar(50)
SELECT @s = dbo.fnGetContext()
print @s
Print LEN(@S)
*/



CREATE  function [dbo].[fnGetContext]()
returns VARCHAR(50)
as
begin

declare @ContextString VARCHAR(50)

SET @ContextString = CAST(CONTEXT_INFO() AS VARCHAR(50))
DECLARE @position int
SET @position = 1
WHILE @position <= LEN(@ContextString)
	BEGIN
		IF ASCII(SUBSTRING(@ContextString, @position, 1)) = 0 BREAK
		SET @position = @position + 1
	END
SET @ContextString = SUBSTRING(@ContextString, 1, @position - 1)
return @ContextString


end
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd
' + 
N'
set @cmd = N'' 
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
SET QUOTED_IDENTIFIER ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
CREATE     function [dbo].[fnSiteID]()
returns bigint
as
begin
	declare @ret bigint
	select		@ret=isnull(tstLocalConnectionContext.idfsSite,cast(tstLocalSiteOptions.strValue as bigint))
	from		tstLocalSiteOptions
	left join	tstLocalConnectionContext
	on			tstLocalConnectionContext.strConnectionContext=dbo.fnGetContext()
	where		tstLocalSiteOptions.strName=''''''''SiteID''''''''
	return @ret
end
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd set @cmd = N'' 
' + N'
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
SET QUOTED_IDENTIFIER ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
/*
--*************************************************************
-- Name 				: FN_GBL_SITEID_GET
-- Description			: Funtion to return userid 
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- 
--*************************************************************
*/
CREATE FUNCTION [dbo].[FN_GBL_SITEID_GET]()
RETURNS BIGINT
AS
BEGIN
	DECLARE @ret BIGINT
	SELECT		@ret=ISNULL(tstLocalConnectionContext.idfsSite,CAST(tstLocalSiteOptions.strValue as BIGINT))
	FROM		tstLocalSiteOptions
	LEFT JOIN	tstLocalConnectionContext ON			
				tstLocalConnectionContext.strConnectionContext=dbo.fnGetContext()
	WHERE		tstLocalSiteOptions.strName=''''''''SiteID''''''''

	RETURN @ret
END
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd
' collate Latin1_General_CI_AS
from	@DbTable t
where	t.strTableName = N'tstLocalConnectionContext' collate Latin1_General_CI_AS



update	t
set		t.intOrder = -1,
		t.strSqlAfterCreate = N'
set @cmd = N'' 
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
SET QUOTED_IDENTIFIER ON
'''' exec ['' + @DbName + ''].sys.sp_executesql @cmd set @cmd = N'''' 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: FN_GBL_LanguageCode_GET
-- Description			: Function to return Language code
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    10-Nov-2017   Convert EIDSS 6 to EIDSS 7 standards and 
--                              renamed to FN_GBL_LanguageCode_GET
-- Stephen Long   29-Jun-2021   Updated to use full culture code on 
--                              Azeri, Arabic-Jordan, Georgian and Thai.
-- Mark Wilson    01-Jul-2021   Updated to select from trtBaseReference 
-- Mark Wilson    08-Jul-2021   added idfsReferenceType in filter 

-- Testing code:
--
/*
	select dbo.FN_GBL_LanguageCode_GET(''''''''en-US'''''''')
	select dbo.FN_GBL_LanguageCode_GET(''''''''az-Latn-AZ'''''''')
	select dbo.FN_GBL_LanguageCode_GET(''''''''ka-GE'''''''')

*/ 

CREATE FUNCTION [dbo].[FN_GBL_LanguageCode_GET](@LangID  NVARCHAR(50))
RETURNS BIGINT
AS
BEGIN
  DECLARE @LanguageCode BIGINT
  SET @LanguageCode = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE strBaseReferenceCode = @LangID AND idfsReferenceType = 19000049 AND intRowStatus =0)
  RETURN @LanguageCode
END
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd
'
from	@DbTable t
where	t.strTableName = N'trtBaseReference' collate Latin1_General_CI_AS


insert into	@DbFileTable
(	[table_object_id],
	strTableName,
	file_group_name,
	collation_name,
	[ansi_nulls],
	[quoted_identifier],
	strSql
)
select		t.[object_id],
			t.[name],isnull(fg_filestream.[name], N'MainFileGroup'),
			d.[collation_name],
			t.[uses_ansi_nulls] as [ansi_nulls],
			1 as [quoted_identifier],
			N''
from		sys.tables t
cross join	@DbInfo d
outer apply
(	select top 1
			fg.[name]
	from	sys.filegroups fg
	where	fg.[type_desc] = N'FILESTREAM_DATA_FILEGROUP' collate Latin1_General_CI_AS
) fg_filestream
where		t.is_filetable = 1
			and t.[type] = N'U' collate Latin1_General_CI_AS


insert into	@DbTableType
(	[user_type_id],
	[type_table_object_id],
	[PK_object_id],
	[PK_name],
	[PK_index_type],
	[PK_padded],
	[PK_stat_no_recompute],
	[PK_ignore_dup_key],
	[PK_allow_row_locks],
	[PK_allow_page_locks],
	[PK_fill_factor],
	[schema_id],
	strSchemaName,
	strTableTypeName,
	strSql
)
select		tt.[user_type_id],
			tt.[type_table_object_id],
			pk.[object_id] as [PK_object_id],
			pk.[name] as strPKName,
			i.[type_desc],
			i.[is_padded],
			i_stat.[no_recompute],
			i.[ignore_dup_key],
			i.[allow_row_locks],
			i.[allow_page_locks],
			i.fill_factor,
			s.[schema_id],
			s.[name] as strSchemaName,
			tt.[name],
			N''
from		sys.table_types tt
inner join	sys.schemas s
on			s.[schema_id] = tt.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
inner join	sys.types tt_typ
on			tt_typ.[user_type_id] = tt.[user_type_id]
left join	sys.indexes i
	inner join	sys.objects pk
	on			i.[name] = pk.[name] collate Latin1_General_CI_AS
				and pk.[type] = 'PK' collate Latin1_General_CI_AS
	inner join	sys.key_constraints kc
	on			kc.[object_id] = pk.[object_id]
				and kc.[parent_object_id] = i.[object_id]
on			i.[object_id] = tt.[type_table_object_id]
			and i.is_primary_key = 1
outer apply	
(	select top 1
				s.no_recompute
	from		sys.stats s
	where		s.[object_id] = tt.[type_table_object_id]
				and s.[name] = pk.[name] collate Latin1_General_CI_AS
				and (s.is_temporary = 0 or s.is_temporary is null)
	order by	s.[stats_id]
) i_stat
where		tt.is_user_defined = 1


insert into	@DbTableTypeColumn
(	[user_type_id],
	[type_table_object_id],
	[schema_id],
	strSchemaName,
	strTableTypeName,
	[column_id],
	strColumnName,
	strColumnType,
	intColumnMaxLength,
	strCollationName,
	[nullable],
	[ansi_padded],
	[identity],
	[seed_value],
	[increment_value],
	[default_value],
	strSql
)
select		tt.[user_type_id],
			tt.[type_table_object_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			tt.[name],
			c.[column_id],
			c.[name],
			typ.[name],
			case
				when typ.[precision] <> 0 
					 or typ.[name] = N'sql_variant' collate Latin1_General_CI_AS 
					 or typ.[name] = N'sysname' collate Latin1_General_CI_AS 
					 or typ.[name] = N'hierarchyid' collate Latin1_General_CI_AS
					 or typ.[name] = N'uniqueidentifier' collate Latin1_General_CI_AS
					 or typ.[name] = N'xml' collate Latin1_General_CI_AS
					 or typ.[name] = N'geometry' collate Latin1_General_CI_AS
					 or typ.[name] = N'image' collate Latin1_General_CI_AS
					 or typ.[name] = N'text' collate Latin1_General_CI_AS
					then 0 
				when (typ.[name] = N'nvarchar' collate Latin1_General_CI_AS or typ.[name] = N'nchar' collate Latin1_General_CI_AS) and c.[max_length] > 0
					then CAST((c.[max_length]/2) as int) 
				else c.[max_length]
			end,
			c.collation_name,
			c.[is_nullable],
			c.[is_ansi_padded],
			c.[is_identity],
			cast(idc.seed_value as nvarchar),
			cast(idc.increment_value as nvarchar),
			dc.[definition],
			N''
from		sys.table_types tt
inner join	sys.schemas s
on			s.[schema_id] = tt.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
inner join	sys.types tt_typ
on			tt_typ.[user_type_id] = tt.[user_type_id]
inner join	sys.columns c
on			c.[object_id] = tt.[type_table_object_id]
left join	sys.types typ
on			typ.[user_type_id] = c.[user_type_id]
left join	sys.identity_columns idc
on			idc.[object_id] = tt.[type_table_object_id]
			and idc.[column_id] = c.[column_id]
left join	sys.objects def_val
on			def_val.[object_id] = c.[default_object_id]
left join	sys.default_constraints dc
on			dc.[object_id] = def_val.[object_id]
where		tt.is_user_defined = 1



insert into	@DbTableTypePKColumn
(	[user_type_id],
	[type_table_object_id],
	[PK_object_id],
	[column_id],
	[index_column_id],
	[schema_id],
	strSchemaName,
	strTableTypeName,
	strPKName,
	strColumnName,
	is_descending_key,
	strSql
)
select		tt_typ.[user_type_id],
			tt.[type_table_object_id],
			pk.[object_id],
			--i.[index_id],
			c.[column_id],
			ic.[index_column_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			tt.[name],
			pk.[name],
			c.[name],
			ic.is_descending_key,
			N''
from		sys.objects pk
inner join	sys.key_constraints kc
on			kc.[object_id] = pk.[object_id]
inner join	sys.indexes i
on			i.[name] = pk.[name] collate Latin1_General_CI_AS
			and i.[object_id] = kc.[parent_object_id]
			and i.is_primary_key = 1
inner join	sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	sys.columns c
on			c.[column_id] = ic.[column_id]
			and c.[object_id] = i.[object_id]
inner join	sys.table_types tt
on			tt.[type_table_object_id] = i.[object_id]
inner join	sys.schemas s
on			s.[schema_id] = tt.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
inner join	sys.types tt_typ
on			tt_typ.[user_type_id] = tt.[user_type_id]
where		pk.[type] = 'PK' collate Latin1_General_CI_AS




insert into	@DbTableColumn
(	[table_object_id],
	[schema_id],
	strSchemaName,
	strTableName,
	[column_id],
	strColumnName,
	strColumnType,
	intColumnMaxLength,
	strCollationName,
	[nullable],
	[ansi_padded],
	[identity],
	[seed_value],
	[increment_value],
	[is_not_for_replication],
	[is_rowguidcol],
	[is_computed],
	[is_persisted],
	[computed_col_def],
	[DF_name],
	[default_value],
	strSql
)
select		t.[object_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name],
			c.[column_id],
			c.[name],
			typ.[name],
			case
				when typ.[precision] <> 0 
					 or typ.[name] = N'sql_variant' collate Latin1_General_CI_AS 
					 or typ.[name] = N'sysname' collate Latin1_General_CI_AS 
					 or typ.[name] = N'hierarchyid' collate Latin1_General_CI_AS
					 or typ.[name] = N'uniqueidentifier' collate Latin1_General_CI_AS
					 or typ.[name] = N'xml' collate Latin1_General_CI_AS
					 or typ.[name] = N'geometry' collate Latin1_General_CI_AS
					 or typ.[name] = N'image' collate Latin1_General_CI_AS
					 or typ.[name] = N'text' collate Latin1_General_CI_AS
					then 0 
				when (typ.[name] = N'nvarchar' collate Latin1_General_CI_AS or typ.[name] = N'nchar' collate Latin1_General_CI_AS) and c.[max_length] > 0
					then CAST((c.[max_length]/2) as int) 
				else c.[max_length]
			end,
			c.collation_name,
			c.is_nullable,
			c.is_ansi_padded,
			c.is_identity,
			cast(idc.seed_value as nvarchar),
			cast(idc.increment_value as nvarchar),
			isnull(idc.[is_not_for_replication], 0),
			c.[is_rowguidcol],
			c.[is_computed],
			--c.is_filestream,
			--c.is_xml_document,
			--c.xml_collection_id,
			isnull(cc.[is_persisted], 0),
			cc.[definition],
			dc.[name],
			dc.[definition],
			N''
from		sys.objects obj_t
inner join	sys.tables t
on			t.[object_id] = obj_t.[object_id]
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
inner join	sys.columns c
on			c.[object_id] = t.[object_id]
left join	sys.types typ
on			typ.[user_type_id] = c.[user_type_id]
left join	sys.identity_columns idc
on			idc.[object_id] = t.[object_id]
			and idc.[column_id] = c.[column_id]
left join	sys.objects def_val
on			def_val.[object_id] = c.[default_object_id]
left join	sys.default_constraints dc
on			dc.[object_id] = def_val.[object_id]
left join	sys.computed_columns cc
on			cc.[object_id] = c.[object_id]
			and cc.[column_id] = c.[column_id]
			and c.[is_computed] = 1
where		t.is_filetable = 0
			and obj_t.[type] = 'U' collate Latin1_General_CI_AS
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
order by t.[name], c.[column_id]



insert into	@DbTablePKColumn
(	[table_object_id],
	[PK_object_id],
	[column_id],
	[index_column_id],
	[schema_id],
	strSchemaName,
	strTableName,
	strPKName,
	strColumnName,
	is_descending_key,
	strSql
)
select		t.[object_id],
			pk.[object_id],
			--i.[index_id],
			c.[column_id],
			ic.[index_column_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name],
			pk.[name],
			c.[name],
			ic.is_descending_key,
			N''
from		sys.objects pk
inner join	sys.key_constraints kc
on			kc.[object_id] = pk.[object_id]
inner join	sys.indexes i
on			i.[name] = pk.[name] collate Latin1_General_CI_AS
			and i.[object_id] = kc.[parent_object_id]
			and i.is_primary_key = 1
inner join	sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	sys.columns c
on			c.[column_id] = ic.[column_id]
			and c.[object_id] = i.[object_id]
inner join	sys.tables t
on			t.[object_id] = i.[object_id]
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
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
where		pk.[type] = 'PK' collate Latin1_General_CI_AS



insert into	@DbTableUQ
(	[table_object_id],
	[schema_id],
	strSchemaName,
	strTableName,
	[UQ_object_id],
	[UQ_index_id],
	[UQ_name],
	[UQ_index_type],
	[UQ_padded],
	[UQ_stat_no_recompute],
	[UQ_ignore_dup_key],
	[UQ_allow_row_locks],
	[UQ_allow_page_locks],
	[UQ_fill_factor],
	strSql
)
select		t.[object_id] as [table_object_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name] as strTableName,
			uq.[object_id] as [PK_object_id],
			i.[index_id] as [PK_index_id],
			uq.[name],
			i.[type_desc],
			i.[is_padded],
			i_stat.[no_recompute],
			i.[ignore_dup_key],
			i.[allow_row_locks],
			i.[allow_page_locks],
			i.fill_factor,
			N''
from		sys.tables t
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
inner join	sys.indexes i
	inner join	sys.objects uq
	on			i.[name] = uq.[name] collate Latin1_General_CI_AS
	inner join	sys.key_constraints kc
	on			kc.[object_id] = uq.[object_id]
				and kc.[parent_object_id] = i.[object_id]
on			i.[object_id] = t.[object_id]
			and i.is_unique_constraint = 1
outer apply	
(	select top 1
				s.no_recompute
	from		sys.stats s
	where		s.[object_id] = t.[object_id]
				and s.[name] = uq.[name] collate Latin1_General_CI_AS
				and (s.is_temporary = 0 or s.is_temporary is null)
	order by	s.[stats_id]
) i_stat
where		t.[type] = N'U' collate Latin1_General_CI_AS
			and t.is_filetable = 0
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



insert into	@DbTableUQColumn
(	[table_object_id],
	[UQ_object_id],
	[UQ_index_id],
	[column_id],
	[index_column_id],
	[schema_id],
	strSchemaName,
	strTableName,
	strUQName,
	strColumnName,
	is_descending_key,
	strSql
)
select		t.[object_id],
			uq.[object_id],
			i.[index_id],
			c.[column_id],
			ic.[index_column_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name],
			uq.[name],
			c.[name],
			ic.is_descending_key,
			N''
from		sys.objects uq
inner join	sys.key_constraints kc
on			kc.[object_id] = uq.[object_id]
inner join	sys.indexes i
on			i.[name] = uq.[name] collate Latin1_General_CI_AS
			and i.[object_id] = kc.[parent_object_id]
			and i.is_unique_constraint = 1
inner join	sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	sys.columns c
on			c.[column_id] = ic.[column_id]
			and c.[object_id] = i.[object_id]
inner join	sys.tables t
on			t.[object_id] = i.[object_id]
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
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]




insert into	@DbTableColumnExtendedProperties
(	strExtendedPropertyName,
	strExtendedPropertyValue,
	level0type,
	[schema_id],
	level0name,
	level1type,
	[table_object_id],
	level1name,
	level2type,
	[column_id],
	level2name,
	strSql
)
select		extp.[name] as strExtendedPropertyName,
			cast(extp.[value] as nvarchar(2000)) as strExtendedPropertyValue,
			N'SCHEMA' as level0type,
			s.[schema_id],
			s.[name] as level0name,
			N'TABLE' as level1type,
			t.[object_id] as [table_object_id],
			t.[name] as level1name,
			case when c.[column_id] is null then cast(null as nvarchar(200)) else N'COLUMN' end as level2type,
			isnull(c.[column_id], 0),
			c.[name] as level2name,
			N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
EXEC sys.sp_addextendedproperty @name=N''''''''' + replace(extp.[name], N'''', N'''''''''''''''''''''''''''''''''') + 
				N''''''''',  @value=N''''''''' + replace(cast(extp.[value] as nvarchar(2000)), N'''', N'''''''''''''''''''''''''''''''''') + 
				N''''''''',  @level0type=N''''''''SCHEMA'''''''', @level0name=N''''''''' + replace(s.[name], N'''', N'''''''''''''''''''''''''''''''''') + 
				N''''''''',  @level1type=N''''''''TABLE'''''''', @level1name=N''''''''' + replace(t.[name], N'''', N'''''''''''''''''''''''''''''''''') + N'''''''''' +
				case
					when	c.[column_id] is not null
						then	N',  @level2type=N''''''''COLUMN'''''''', @level2name=N''''''''' + replace(c.[name], N'''', N'''''''''''''''''''''''''''''''''') + N''''''''''
					else N''
				end + N'
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd
' as strSql
from		sys.extended_properties extp
inner join	sys.objects o
on			o.[object_id] = extp.[major_id]
inner join	sys.tables t
on			t.[object_id] = o.[object_id]
			and t.[type] = N'U' collate Latin1_General_CI_AS
			and t.is_filetable = 0
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
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
left join	sys.all_columns c
on			c.[object_id] = t.[object_id]
			and c.[column_id] = extp.[minor_id]
where		extp.[name] = N'MS_Description' collate Latin1_General_CI_AS



insert into	@DbIndex
(	[index_id],
	[table_object_id],
	[schema_id],
	strSchemaName,
	strTableName,
	strIndexName,
	strIndexType,
	[unique],
	unique_constraint,
	padded,
	[disabled],
	[ignore_dup_key],
	has_filter,
	filter_definition,
	fill_factor,
	[allow_page_locks],
	[allow_row_locks],
	stat_no_recompute,
	tessellation_scheme,
	bounding_box_xmin,
	bounding_box_ymin,
	bounding_box_xmax,
	bounding_box_ymax,
	level_1_grid_desc,
	level_2_grid_desc,
	level_3_grid_desc,
	level_4_grid_desc,
	cells_per_object,
	strSql
)
select		i.[index_id],
			t.[object_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name],
			i.[name],
			i.[type_desc],
			i.is_unique,
			i.is_unique_constraint,
			i.is_padded,
			i.is_disabled,
			i.[ignore_dup_key],
			i.has_filter,
			i.filter_definition,
			i.fill_factor,
			i.[allow_page_locks],
			i.[allow_row_locks],
			isnull(i_stat.[no_recompute], 0),
			--i.[data_space_id],

			si.tessellation_scheme,
			sit.bounding_box_xmin,
			sit.bounding_box_ymin,
			sit.bounding_box_xmax,
			sit.bounding_box_ymax,
			sit.level_1_grid_desc,
			sit.level_2_grid_desc,
			sit.level_3_grid_desc,
			sit.level_4_grid_desc,
			sit.cells_per_object,
			
			N''
from		sys.indexes i
inner join	sys.tables t
on			t.[object_id] = i.[object_id]
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
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
left join	sys.spatial_indexes si
	inner join	sys.spatial_index_tessellations sit
	on			sit.[object_id] = si.[object_id]
				and sit.[index_id] = si.[index_id]
				and sit.tessellation_scheme = si.tessellation_scheme collate Latin1_General_CI_AS
on			si.[object_id] = i.[object_id]
			and si.[index_id] = i.[index_id]
			and si.[type_desc] = N'SPATIAL' collate Latin1_General_CI_AS
outer apply	
(	select top 1
				s.no_recompute
	from		sys.stats s
	where		s.[object_id] = t.[object_id]
				and s.[name] = i.[name] collate Latin1_General_CI_AS
				and (s.is_temporary = 0 or s.is_temporary is null)
	order by	s.[stats_id]
) i_stat
where		i.is_primary_key = 0
			and i.is_unique_constraint = 0
			and i.[type_desc] <> N'HEAP' collate Latin1_General_CI_AS
			and i.is_hypothetical = 0
order by	t.[name], i.[type_desc], i.[name]


insert into	@DbIndexColumn
(	[index_id],
	[table_object_id],
	[index_column_id],
	[column_id],
	[schema_id],
	strSchemaName,
	strTableName,
	strIndexName,
	strIndexType,
	strColumnName,
	is_descending_key,
	is_included_column,
	col_ansi_padding,
	strSql
)
select		i.[index_id],
			t.[object_id],
			ic.[index_column_id],
			c.[column_id],
			s.[schema_id],
			s.[name] as strSchemaName,
			t.[name],
			i.[name],
			i.[type_desc],
			c.[name],
			ic.is_descending_key,
			ic.is_included_column,
			c.is_ansi_padded,
			--ic.key_ordinal,
			--ic.partition_ordinal,
			N''
from		sys.indexes i
inner join	sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	sys.columns c
on			c.[column_id] = ic.[column_id]
			and c.[object_id] = i.[object_id]
inner join	sys.tables t
on			t.[object_id] = i.[object_id]
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
inner join	sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and (	s.[name] not like N'Migr%' collate Latin1_General_CI_AS
				)
where		i.is_primary_key = 0
			and i.is_unique_constraint = 0
			and i.[type_desc] <> N'HEAP' collate Latin1_General_CI_AS
			and i.is_hypothetical = 0
order by	t.[name], i.[type_desc], i.[name], ic.index_column_id



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
  Note: (1) Database shall exist and have empty schema.
		(2) Script is not applicable for cloud-hosted databases.
		(3) Stored Procedure sp_executesql shall be enabled for the instance of SQL Server, where database schema shall be created.
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
	declare @isCleanDb bit = 0

	set @cmd = N''
	set @isCleanDbOut = 1
	if exists (select 1 from ['' + @DbName + N''].sys.tables)
		or exists (select 1 from ['' + @DbName + N''].sys.table_types)
		or exists
			(	select		1
				from		['' + @DbName + N''].sys.schemas s
				inner join	['' + @DbName + N''].sys.database_principals p
				on			p.[principal_id] = s.[principal_id]
							and p.[type] = N''''S'''' /*SQL_USER*/
							and p.[name] = N''''dbo''''
				where		s.[schema_id] > 1
			)
	begin
		set @isCleanDbOut = 0
	end
	''
	exec sp_executesql @cmd, N''@isCleanDbOut bit output'', @isCleanDbOut = @isCleanDb output

	if @isCleanDb = 0
	begin
		set @Error = 1
		set @ErrorMsg = N''Database with name ['' + isnull(@DbName, N'''') + N''] has non-empty schema. No changes will be applied. Please specify name of existing database with empty schema and execute script again.''
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

--Schemas--

'


select
N'

set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
CREATE SCHEMA [' + s.strSchemaName + N']
    AUTHORIZATION [' + s.strPrincipalName + '];
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd
'
from		@DbSchema s



select	N'

--Tables--

'


update		c
set			c.strSql = 
N'	[' + c.strColumnName + N']' + 
	case 
		when	c.[is_computed] = 1 and c.[is_persisted] = 1
			then	N' AS ' + replace(c.[computed_col_def], N'''', N'''''''''') + N' PERSISTED'
		when	c.[is_computed] = 1 and c.[is_persisted] = 0
			then	N' AS ' + replace(c.[computed_col_def], N'''', N'''''''''')
		else	N' [' + c.strColumnType + N']'
	end + 
	case 
		when	c.[is_computed] = 0 and c.intColumnMaxLength = -1 
			then	N'(max)' 
		when	c.[is_computed] = 0 and c.intColumnMaxLength > 0 
			then	N'(' + cast(c.intColumnMaxLength as nvarchar(20)) + N')' collate Latin1_General_CI_AS
		else	N'' 
	end + 
	case 
		when	c.[is_computed] = 0 and c.strCollationName <> N'' collate Latin1_General_CI_AS
			then	N' collate ' + c.strCollationName collate Latin1_General_CI_AS 
		else	N'' 
	end + 
	case 
		when	c.[is_computed] = 0 and c.[identity] = 1 and c.[is_not_for_replication] = 0
			then	N' IDENTITY(' + isnull(c.seed_value, N'') + N',' + isnull(c.increment_value, N'1') + N')' collate Latin1_General_CI_AS 
		when	c.[is_computed] = 0 and c.[identity] = 1 and c.[is_not_for_replication] = 1
			then	N' IDENTITY(' + isnull(c.seed_value, N'') + N',' + isnull(c.increment_value, N'1') + N')  NOT FOR REPLICATION' collate Latin1_General_CI_AS 
		else	N'' 
	end +
	case
		when	c.[is_computed] = 0 and c.[identity] = 0 and c.[is_rowguidcol] = 1
			then	N' ROWGUIDCOL'
		else	N''
	end +
	case 
		when	c.[nullable] = 1 and c.[is_computed] = 0
			then	N' NULL'
		when	c.[nullable] = 0
			then	N' NOT NULL'
		else	N'' 
	end +
	case 
		when	c.[column_id] < table_max_col.[column_id]
			then	N','
		else	N'' 
	end 
	collate Latin1_General_CI_AS,
			c.strDefaultConstraint =
				case
					when	c.[is_computed] = 0 and c.[DF_name] is not null
						then	N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
ALTER TABLE [' + c.strSchemaName + N'].[' + c.strTableName + N'] ADD  CONSTRAINT [' + c.[DF_name] + N']  DEFAULT ' + replace(c.[default_value], N'''', N'''''''''') + N' FOR [' + c.strColumnName + N']
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd' collate Latin1_General_CI_AS
					else	null
				end
--TODO: SET ANSI_PADDING ON/OFF 
--TODO:(SET ANSI_PADDING ON 
--TODO:GO 
--TODO:
--TODO:ALTER TABLE [TableX] ALTER COLUMN [ColumnY] VARBINARY/VARCHAR (50) NULL; 
--TODO:GO 
--TODO:
--TODO:SET ANSI_PADDING OFF 
--TODO:GO )
from		@DbTableColumn c
outer apply
(	select	max(c_max.[column_id]) as [column_id]
	from	@DbTableColumn c_max
	where	c_max.[table_object_id] = c.[table_object_id]
) table_max_col

update		pkc
set			pkc.strSql = N'
	[' + pkc.[strColumnName] + N'] ' +
case
	when	pkc.[is_descending_key] = 1
		then	N'DESC'
	else	N'ASC'
end +
	case 
		when	pkc.[index_column_id] < PK_max_col.[index_column_id]
			then	N','
		else	N'' 
	end 
	collate Latin1_General_CI_AS
from		@DbTablePKColumn pkc
outer apply
(	select	max(pkc_max.[index_column_id]) as [index_column_id]
	from	@DbTablePKColumn pkc_max
	where	pkc_max.[table_object_id] = pkc.[table_object_id]
			and pkc_max.[PK_object_id] = pkc.[PK_object_id]
) PK_max_col



update		uqc
set			uqc.strSql = N'
	[' + uqc.[strColumnName] + N'] ' +
case
	when	uqc.[is_descending_key] = 1
		then	N'DESC'
	else	N'ASC'
end +
	case 
		when	uqc.[index_column_id] < UQ_max_col.[index_column_id]
			then	N','
		else	N'' 
	end 
	collate Latin1_General_CI_AS
from		@DbTableUQColumn uqc
outer apply
(	select	max(uqc_max.[index_column_id]) as [index_column_id]
	from	@DbTableUQColumn uqc_max
	where	uqc_max.[table_object_id] = uqc.[table_object_id]
			and uqc_max.[UQ_object_id] = uqc.[UQ_object_id]
) UQ_max_col



update uq
set	uq.strSql = N' CONSTRAINT [' + uq.UQ_name + N'] UNIQUE ' + uq.[UQ_index_type]  + N'
 (' + uqColDefinition.strSql + N'
 )WITH (PAD_INDEX = ' + replace(replace(cast(uq.[UQ_padded] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 isnull(N', STATISTICS_NORECOMPUTE = ' + replace(replace(cast(uq.[UQ_stat_no_recompute] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON'), N'') +
 N', ' + N'IGNORE_DUP_KEY = ' + replace(replace(cast(uq.[UQ_ignore_dup_key] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_ROW_LOCKS = ' + replace(replace(cast(uq.[UQ_allow_row_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_PAGE_LOCKS = ' + replace(replace(cast(uq.[UQ_allow_page_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 case when uq.[UQ_fill_factor] > 0 then N', ' + N'FILLFACTOR = ' + cast(uq.[UQ_fill_factor] as nvarchar(10)) collate Latin1_General_CI_AS else N'' end + 
 N') ON [PRIMARY]'
 collate Latin1_General_CI_AS
from		@DBTableUQ uq
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + uqc.strSql collate Latin1_General_CI_AS
					from		@DbTableUQColumn uqc
					where		uqc.[table_object_id] = uq.[table_object_id]
								and uqc.[UQ_object_id] = uq.[UQ_object_id]
								and uqc.strSql is not null
					order by	uqc.[index_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) uqColDefinition




update		pkc
set			pkc.strSql = N'
	[' + pkc.[strColumnName] + N'] ' +
case
	when	pkc.[is_descending_key] = 1
		then	N'DESC'
	else	N'ASC'
end +
	case 
		when	pkc.[index_column_id] < PK_max_col.[index_column_id]
			then	N','
		else	N'' 
	end 
	collate Latin1_General_CI_AS
from		@DbTableTypePKColumn pkc
outer apply
(	select	max(pkc_max.[index_column_id]) as [index_column_id]
	from	@DbTableTypePKColumn pkc_max
	where	pkc_max.[type_table_object_id] = pkc.[type_table_object_id]
			and pkc_max.[PK_object_id] = pkc.[PK_object_id]
) PK_max_col



select
N'

set @cmd = N'' 
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ' + replace(replace(cast(t.[ansi_nulls] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
' +
N'
SET QUOTED_IDENTIFIER ' + replace(replace(cast(t.[quoted_identifier] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
' +
N'
'''' set @cmd = @cmd + N'''' 
CREATE TABLE [' + t.strSchemaName + N'].[' + t.strTableName + N'](' + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' collate Latin1_General_CI_AS,
case
	when LEN(isnull(colDefinition.strSql, N'')) > 8000
		then LEFT(isnull(colDefinition.strSql, N''), 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 4001, 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 8001, 4000) + N'''''' + N'''' collate Latin1_General_CI_AS
	when LEN(isnull(colDefinition.strSql, N'')) > 4000 and LEN(isnull(colDefinition.strSql, N'')) <= 8000
		then LEFT(isnull(colDefinition.strSql, N''), 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 4001, 4000) + N'''''' + N'''' collate Latin1_General_CI_AS
	else isnull(colDefinition.strSql, N'') + N'''''' + N'''' collate Latin1_General_CI_AS 
end,
case
	when	t.PK_object_id > 0
		then	N' 
set @cmd = @cmd + N'' set @cmd = @cmd + N''''
,
 CONSTRAINT [' + t.PK_name + N'] PRIMARY KEY ' + t.[PK_index_type]  + N'
 (' + pkColDefinition.strSql + N'
 )WITH (PAD_INDEX = ' + replace(replace(cast(t.[PK_padded] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 isnull(N', STATISTICS_NORECOMPUTE = ' + replace(replace(cast(t.[PK_stat_no_recompute] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON'), N'') +
 N', ' + N'IGNORE_DUP_KEY = ' + replace(replace(cast(t.[PK_ignore_dup_key] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_ROW_LOCKS = ' + replace(replace(cast(t.[PK_allow_row_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_PAGE_LOCKS = ' + replace(replace(cast(t.[PK_allow_page_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 case when t.[PK_fill_factor] > 0 then N', ' + N'FILLFACTOR = ' + cast(t.[PK_fill_factor] as nvarchar(10)) collate Latin1_General_CI_AS else N'' end + 
 N') ON [PRIMARY]'''''''
 collate Latin1_General_CI_AS
	else	N''
end +
ISNULL(N'
set @cmd = @cmd + N'' set @cmd = @cmd + N''''' + uqConstraint.strSql + N'''''''', N'') +
N'
set @cmd = @cmd + N'' set @cmd = @cmd + N''''
) ON [PRIMARY]' + isnull(TEXTIMAGE_ON_Property.strValue, N'') + N'
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' execute sp_executesql @cmd
', isnull(defValConstraint.strSql, N'') collate Latin1_General_CI_AS
, isnull(extProp.strSql, N'') collate Latin1_General_CI_AS
, ISNULL(t.strSqlAfterCreate, N'') collate Latin1_General_CI_AS
from		@DbTable t
cross apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strSql collate Latin1_General_CI_AS
					from		@DbTableColumn c
					where		c.[table_object_id] = t.[table_object_id]
								and c.strSql is not null
					order by	c.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) colDefinition
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + pkc.strSql collate Latin1_General_CI_AS
					from		@DbTablePKColumn pkc
					where		pkc.[table_object_id] = t.[table_object_id]
								and pkc.[PK_object_id] = t.[PK_object_id]
								and pkc.strSql is not null
					order by	pkc.[index_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) pkColDefinition
outer apply
(	select	top 1 N' TEXTIMAGE_ON [PRIMARY]' as strValue
	from	@DbTableColumn c
	where	c.[table_object_id] = t.[table_object_id]
			and (	(	(	c.strColumnType = N'varchar' collate Latin1_General_CI_AS
							or	c.strColumnType = N'nvarchar' collate Latin1_General_CI_AS
							or	c.strColumnType = N'varbinary' collate Latin1_General_CI_AS
						)
						and c.intColumnMaxLength = -1
					)
					or	c.strColumnType = N'xml' collate Latin1_General_CI_AS
					or	c.strColumnType = N'image' collate Latin1_General_CI_AS
				)
) TEXTIMAGE_ON_Property
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strDefaultConstraint collate Latin1_General_CI_AS
					from		@DbTableColumn c
					where		c.[table_object_id] = t.[table_object_id]
								and c.strDefaultConstraint is not null
					order by	c.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) defValConstraint
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + extp.strSql collate Latin1_General_CI_AS
					from		@DbTableColumnExtendedProperties extp
					where		extp.[table_object_id] = t.[table_object_id]
								and extp.strSql is not null
					order by	extp.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) extProp
outer apply
(	select	replace(replace(replace
			(	(	select		N',
' + uq.strSql collate Latin1_General_CI_AS
					from		@DbTableUQ uq
					where		uq.[table_object_id] = t.[table_object_id]
								and uq.strSql is not null
					order by	uq.[UQ_object_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) uqConstraint

where		t.intOrder < 0
order by	t.intOrder, t.strTableName





select
N'

set @cmd = N'' 
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ' + replace(replace(cast(t.[ansi_nulls] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
' +
N'
SET QUOTED_IDENTIFIER ' + replace(replace(cast(t.[quoted_identifier] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
' +
N'
'''' set @cmd = @cmd + N'''' 
CREATE TABLE [' + t.strSchemaName + N'].[' + t.strTableName + N'](' + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' collate Latin1_General_CI_AS,
case
	when LEN(isnull(colDefinition.strSql, N'')) > 8000
		then LEFT(isnull(colDefinition.strSql, N''), 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 4001, 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 8001, 4000) + N'''''' + N'''' collate Latin1_General_CI_AS
	when LEN(isnull(colDefinition.strSql, N'')) > 4000 and LEN(isnull(colDefinition.strSql, N'')) <= 8000
		then LEFT(isnull(colDefinition.strSql, N''), 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 4001, 4000) + N'''''' + N'''' collate Latin1_General_CI_AS
	else isnull(colDefinition.strSql, N'') + N'''''' + N'''' collate Latin1_General_CI_AS 
end,
case
	when	t.PK_object_id > 0
		then	N' 
set @cmd = @cmd + N'' set @cmd = @cmd + N''''
,
 CONSTRAINT [' + t.PK_name + N'] PRIMARY KEY ' + t.[PK_index_type]  + N'
 (' + pkColDefinition.strSql + N'
 )WITH (PAD_INDEX = ' + replace(replace(cast(t.[PK_padded] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 isnull(N', STATISTICS_NORECOMPUTE = ' + replace(replace(cast(t.[PK_stat_no_recompute] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON'), N'') +
 N', ' + N'IGNORE_DUP_KEY = ' + replace(replace(cast(t.[PK_ignore_dup_key] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_ROW_LOCKS = ' + replace(replace(cast(t.[PK_allow_row_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_PAGE_LOCKS = ' + replace(replace(cast(t.[PK_allow_page_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 case when t.[PK_fill_factor] > 0 then N', ' + N'FILLFACTOR = ' + cast(t.[PK_fill_factor] as nvarchar(10)) collate Latin1_General_CI_AS else N'' end + 
 N') ON [PRIMARY]'''''''
 collate Latin1_General_CI_AS
	else	N''
end +
ISNULL(N'
set @cmd = @cmd + N'' set @cmd = @cmd + N''''' + uqConstraint.strSql + N'''''''', N'') +
N'
set @cmd = @cmd + N'' set @cmd = @cmd + N''''
) ON [PRIMARY]' + isnull(TEXTIMAGE_ON_Property.strValue, N'') + N'
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' execute sp_executesql @cmd
', isnull(defValConstraint.strSql, N'') collate Latin1_General_CI_AS
, isnull(extProp.strSql, N'') collate Latin1_General_CI_AS
from		@DbTable t
cross apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strSql collate Latin1_General_CI_AS
					from		@DbTableColumn c
					where		c.[table_object_id] = t.[table_object_id]
								and c.strSql is not null
					order by	c.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) colDefinition
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + pkc.strSql collate Latin1_General_CI_AS
					from		@DbTablePKColumn pkc
					where		pkc.[table_object_id] = t.[table_object_id]
								and pkc.[PK_object_id] = t.[PK_object_id]
								and pkc.strSql is not null
					order by	pkc.[index_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) pkColDefinition
outer apply
(	select	top 1 N' TEXTIMAGE_ON [PRIMARY]' as strValue
	from	@DbTableColumn c
	where	c.[table_object_id] = t.[table_object_id]
			and (	(	(	c.strColumnType = N'varchar' collate Latin1_General_CI_AS
							or	c.strColumnType = N'nvarchar' collate Latin1_General_CI_AS
							or	c.strColumnType = N'varbinary' collate Latin1_General_CI_AS
						)
						and c.intColumnMaxLength = -1
					)
					or	c.strColumnType = N'xml' collate Latin1_General_CI_AS
					or	c.strColumnType = N'image' collate Latin1_General_CI_AS
				)
) TEXTIMAGE_ON_Property
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strDefaultConstraint collate Latin1_General_CI_AS
					from		@DbTableColumn c
					where		c.[table_object_id] = t.[table_object_id]
								and c.strDefaultConstraint is not null
					order by	c.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) defValConstraint
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + extp.strSql collate Latin1_General_CI_AS
					from		@DbTableColumnExtendedProperties extp
					where		extp.[table_object_id] = t.[table_object_id]
								and extp.strSql is not null
					order by	extp.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) extProp
outer apply
(	select	replace(replace(replace
			(	(	select		N',
' + uq.strSql collate Latin1_General_CI_AS
					from		@DbTableUQ uq
					where		uq.[table_object_id] = t.[table_object_id]
								and uq.strSql is not null
					order by	uq.[UQ_object_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) uqConstraint

where		t.intOrder >= 0
order by	t.intOrder, t.strTableName


if exists (select 1 from @DbFileTable)
begin
	select	N'

--File Table--

'

	select	N'

set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
SET ANSI_NULLS ' + replace(replace(cast(ft.[ansi_nulls] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
' +
N'
SET QUOTED_IDENTIFIER ' + replace(replace(cast(ft.[quoted_identifier] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N'
' +
N'
CREATE TABLE [dbo].[' + ft.strTableName + N'] AS FILETABLE ON [PRIMARY] FILESTREAM_ON [' + ft.file_group_name + N']
WITH' + N'
(
FILETABLE_DIRECTORY = N''''''''' + ft.strTableName + N''''''''', FILETABLE_COLLATE_FILENAME = ' + ft.[collation_name] + N'
)
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' execute sp_executesql @cmd' collate Latin1_General_CI_AS
	from		@DbFileTable ft
	order by	ft.strTableName
end

update		c
set			c.strSql = 
N'	[' + c.strColumnName + N'] [' + c.strColumnType + N']' + 
	case 
		when	c.intColumnMaxLength = -1 
			then	N'(max)' 
		when	c.intColumnMaxLength > 0 
			then	N'(' + cast(c.intColumnMaxLength as nvarchar(20)) + N')' collate Latin1_General_CI_AS
		else	N'' 
	end + 
	case 
		when	c.strCollationName <> N'' collate Latin1_General_CI_AS
			then	N' collate ' + c.strCollationName collate Latin1_General_CI_AS 
		else	N'' 
	end + 
	case 
		when	c.[identity] = 1
			then	N' IDENTITY(' + isnull(c.seed_value, N'') + N',' + isnull(c.increment_value, N'1') + N')' collate Latin1_General_CI_AS 
		else	N'' 
	end +
	case 
		when	c.[nullable] = 1
			then	N' NULL'
		else	N' NOT NULL' 
	end +
	case 
		when	c.[default_value] is not null
			then	N' DEFAULT ' + replace(c.[default_value], N'''', N'''''''''') collate Latin1_General_CI_AS
		else	N'' 
	end +
	case 
		when	c.[column_id] < table_max_col.[column_id]
			then	N','
		else	N'' 
	end 
	collate Latin1_General_CI_AS
from		@DbTableTypeColumn c
outer apply
(	select	max(c_max.[column_id]) as [column_id]
	from	@DbTableTypeColumn c_max
	where	c_max.[type_table_object_id] = c.[type_table_object_id]
) table_max_col



select	N'

--User-defined Table Types--

'


select	N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
CREATE TYPE [' + tt.strSchemaName + N'].[' + tt.strTableTypeName + N'] AS TABLE(' + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' collate Latin1_General_CI_AS,
case
	when LEN(isnull(colDefinition.strSql, N'')) > 8000
		then LEFT(isnull(colDefinition.strSql, N''), 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 4001, 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 8001, 4000) + N'''''' + N'''' collate Latin1_General_CI_AS
	when LEN(isnull(colDefinition.strSql, N'')) > 4000 and LEN(isnull(colDefinition.strSql, N'')) <= 8000
		then LEFT(isnull(colDefinition.strSql, N''), 4000) + N''''' set @cmd = @cmd + N''''' + N''' set @cmd = @cmd + N''' + SUBSTRING(isnull(colDefinition.strSql, N''), 4001, 4000) + N'''''' + N'''' collate Latin1_General_CI_AS
	else isnull(colDefinition.strSql, N'') + N'''''' + N'''' collate Latin1_General_CI_AS 
end,
case
	when	tt.PK_object_id > 0
		then	N'
set @cmd = @cmd + N'' set @cmd = @cmd + N''''
,
 PRIMARY KEY ' + tt.[PK_index_type]  + N'
 (' + pkColDefinition.strSql + N'
 )WITH (IGNORE_DUP_KEY = ' + replace(replace(cast(tt.[PK_ignore_dup_key] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N')'''''''
 collate Latin1_General_CI_AS
	else	N''
end + 
N'
set @cmd = @cmd + N'' set @cmd = @cmd + N''''
)
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' execute sp_executesql @cmd
' collate Latin1_General_CI_AS
from		@DbTableType tt
cross apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strSql collate Latin1_General_CI_AS
					from		@DbTableTypeColumn c
					where		c.[type_table_object_id] = tt.[type_table_object_id]
								and c.strSql is not null
					order by	c.[column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) colDefinition
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + pkc.strSql collate Latin1_General_CI_AS
					from		@DbTableTypePKColumn pkc
					where		pkc.[type_table_object_id] = tt.[type_table_object_id]
								and pkc.[PK_object_id] = tt.[PK_object_id]
								and pkc.strSql is not null
					order by	pkc.[index_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) pkColDefinition

order by	tt.strTableTypeName


select	N'

--Indexes--

'

update		ic
set			ic.strSql = N'	[' + ic.[strColumnName] + N']' +
case
	when	ic.[is_descending_key] = 1 and ic.is_included_column = 0 and ic.strIndexType <> N'SPATIAL' collate Latin1_General_CI_AS
		then	N' DESC'
	when	ic.[is_descending_key] = 0 and ic.is_included_column = 0 and ic.strIndexType <> N'SPATIAL' collate Latin1_General_CI_AS
		then	N' ASC'
	else	N''
end +
	case 
		when	ic.[index_column_id] < i_max_col_with_included_property.[index_column_id]
			then	N','
		else	N'' 
	end 
	collate Latin1_General_CI_AS
from		@DbIndexColumn ic
outer apply
(	select		max(ic_max.[index_column_id]) as [index_column_id]
	from		@DbIndexColumn ic_max
	where		ic_max.[table_object_id] = ic.[table_object_id]
				and ic_max.[index_id] = ic.[index_id]
				and ic_max.is_included_column = ic.is_included_column
) i_max_col_with_included_property

select	N'
set @cmd = N''
declare @cmd nvarchar(max)
set @cmd = N''''
' +	
	case
		when	i.strIndexType = N'SPATIAL' collate Latin1_General_CI_AS
			then	N'
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
'
		when	i.strIndexType <> N'SPATIAL' collate Latin1_General_CI_AS and i_col_padding_on.column_id is not null
			then	N'SET ANSI_PADDING ON
'
		else	N''
	end +
	N'CREATE' +
	case
		when	i.[unique] = 1
			then	N' UNIQUE'
		else	N''
	end +
	N' ' + i.strIndexType + N' INDEX [' + i.[strIndexName] + N'] ON [' + i.strSchemaName + N'].[' + i.strTableName + N']
(' + colDefinition.strSql + N'
)' + isnull(N'
INCLUDE
(' + includedColDefinition.strSql + N'
) ' collate Latin1_General_CI_AS, N''),
N'
' + 
 case
	when i.strIndexType = N'SPATIAL' collate Latin1_General_CI_AS
		then	isnull(N'USING  ' + i.tessellation_scheme + N'
' collate Latin1_General_CI_AS, N'')
	else N''
 end +
N'WITH (' +
 case
	when i.strIndexType = N'SPATIAL' collate Latin1_General_CI_AS
		then	isnull(N'BOUNDING_BOX =(' + cast(i.bounding_box_xmin as nvarchar(200)) + N', ' + cast(i.bounding_box_ymin as nvarchar(200)) + N', ' + cast(i.bounding_box_xmax as nvarchar(200)) + N', ' + cast(i.bounding_box_ymax as nvarchar(200)) + N'), ' + 
				N'GRIDS =(LEVEL_1 = ' + i.level_1_grid_desc + N',LEVEL_2 = ' + i.level_2_grid_desc + N',LEVEL_3 = ' + i.level_3_grid_desc + N',LEVEL_4 = ' + i.level_4_grid_desc + N'), 
CELLS_PER_OBJECT = ' + cast(i.cells_per_object as nvarchar(20)) + N', ', N'')
	else N''
 end +
 N'PAD_INDEX = ' + replace(replace(cast(i.[padded] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 isnull(N', STATISTICS_NORECOMPUTE = ' + replace(replace(cast(i.[stat_no_recompute] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON'), N'') +
 N', ' + N'SORT_IN_TEMPDB = OFF' +
 N', ' + N'IGNORE_DUP_KEY = ' + replace(replace(cast(i.[ignore_dup_key] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'DROP_EXISTING = OFF' +
 N', ' + N'ONLINE = OFF' +
 N', ' + N'ALLOW_ROW_LOCKS = ' + replace(replace(cast(i.[allow_row_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 N', ' + N'ALLOW_PAGE_LOCKS = ' + replace(replace(cast(i.[allow_page_locks] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + 
 case when i.[fill_factor] > 0 then N', ' + N'FILLFACTOR = ' + cast(i.[fill_factor] as nvarchar(10)) collate Latin1_General_CI_AS else N'' end + 
 N') ON [PRIMARY]
''''
exec ['' + @DbName + ''].sys.sp_executesql @cmd
'' exec sp_executesql @cmd
'
	collate Latin1_General_CI_AS
from		@DbIndex i
cross apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strSql collate Latin1_General_CI_AS
					from		@DbIndexColumn c
					where		c.[table_object_id] = i.[table_object_id]
								and c.[index_id] = i.[index_id]
								and c.is_included_column = 0
								and c.strSql is not null
					order by	c.[index_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) colDefinition
outer apply
(	select	replace(replace(replace
			(	(	select		N'
' + c.strSql collate Latin1_General_CI_AS
					from		@DbIndexColumn c
					where		c.[table_object_id] = i.[table_object_id]
								and c.[index_id] = i.[index_id]
								and c.is_included_column = 1
								and c.strSql is not null
					order by	c.[index_column_id]
					for xml path(N'')
				),
				N'&#x0D;', N''
			), N'&lt;', N'<'), N'&gt;', N'>') strSql
) includedColDefinition
outer apply
(	select top 1
			ic.[column_id]
	from	@DbIndexColumn ic
	where	ic.[table_object_id] = i.[table_object_id]
			and ic.[index_id] = i.[index_id]
			and ic.is_included_column = 0
			and ic.col_ansi_padding = 1
) i_col_padding_on
order by	i.strTableName, i.strIndexName

select N'

end


SET NOCOUNT OFF 
SET XACT_ABORT OFF 
'

--------------------------------------------
-- End block - Generate Sql based on info --
--------------------------------------------


set nocount off