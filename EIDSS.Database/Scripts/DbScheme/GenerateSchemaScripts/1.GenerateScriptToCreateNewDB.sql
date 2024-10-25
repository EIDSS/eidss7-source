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

select 
    @InstanceDefaultDataPath = cast(serverproperty('InstanceDefaultDataPath') as nvarchar(max)),
    @InstanceDefaultLogPath = cast(serverproperty('InstanceDefaultLogPath') as nvarchar(max))

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


---------------------------------------------------------
-- End block - Fill in system information on DB schema --
---------------------------------------------------------


----------------------------------------------
-- Start block - Generate Sql based on info --
----------------------------------------------

update		df
set			df.strSql =			
				case
					when	df.[file_type] = N'ROWS' collate Latin1_General_CI_AS
						then	N'
'
					when	df.[file_type] = N'LOG' collate Latin1_General_CI_AS
						then	N'
LOG ON
'
					when	df.[file_type] = N'FILESTREAM' collate Latin1_General_CI_AS
						then	N',
 FILEGROUP [' + isnull(df.[file_group_name], N'MainFileGroup') + N'] CONTAINS FILESTREAM  DEFAULT
 '
					else	N''
				end +
				N'( NAME = N''' + replace(df.logical_name, N'''', N'''''') + N''', FILENAME = N''' + 
				case
					when	df.[file_type] = N'ROWS' collate Latin1_General_CI_AS
						then	N'#UserDataPath#\#DbNameNoSpecialCharacters#'
					when	df.[file_type] = N'LOG' collate Latin1_General_CI_AS
						then	N'#UserLogPath#\#DbNameNoSpecialCharacters#_LOG'
					when	df.[file_type] = N'FILESTREAM' collate Latin1_General_CI_AS
						then	N'#UserDataPath#\MainFSFile_#DbNameNoSpecialCharacters#'
					else	N''
				end +
				df.file_extension + N''' , ' +
				case
					when	df.[file_type] = N'ROWS' collate Latin1_General_CI_AS
							or	df.[file_type] = N'LOG' collate Latin1_General_CI_AS
						then	N'SIZE = ' + cast(df.size as nvarchar(20)) + N'KB , ' collate Latin1_General_CI_AS
					else	N''
				end +
				case
					when	df.max_size > 0
						then	N'MAXSIZE = ' + cast(df.max_size as nvarchar(20)) + N'MB' collate Latin1_General_CI_AS
					else	N'MAXSIZE = UNLIMITED'
				end +
				case
					when	df.growth > 0 and df.percent_growth = 1
						then	N', FILEGROWTH = ' + cast(df.growth as nvarchar(20)) + N'%' collate Latin1_General_CI_AS
					when	df.growth > 0 and df.percent_growth = 0
						then	N', FILEGROWTH = ' + cast(df.growth as nvarchar(20)) + N'MB' collate Latin1_General_CI_AS
					else	N''
				end +
				N')' collate Latin1_General_CI_AS
from		@DbFile df

declare @strFileSql nvarchar(max) = 
replace
(	(	select		df.strSql collate Latin1_General_CI_AS
		from		@DbFile df
		where		df.strSql is not null
		order by	df.intOrder
		for xml path(N'')
	),
	N'&#x0D;', N''
)


select		N'
CREATE DATABASE [#DbName#]
 CONTAINMENT = ' + d.[containment] + N'
 ON  PRIMARY ' + @strFileSql + N'
 COLLATE ' + d.collation_name + N'
GO
', N' 
IF (FULLTEXTSERVICEPROPERTY(''IsFullTextInstalled'') = 1)
begin
	EXEC [#DbName#].[dbo].[sp_fulltext_database] @action = ''' + replace(replace(cast(d.[fulltext_enabled] as nvarchar(1)), N'0', N'disabled'), N'1', N'enabled') + N'''
end
GO
', N'
ALTER DATABASE [#DbName#] SET ANSI_NULL_DEFAULT ' + replace(replace(cast(d.[ansi_null_default] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ANSI_NULLS ' + replace(replace(cast(d.[ansi_nulls] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ANSI_PADDING ' + replace(replace(cast(d.[ansi_padding] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ANSI_WARNINGS ' + replace(replace(cast(d.[ansi_warnings] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ARITHABORT ' + replace(replace(cast(d.[arithabort] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET AUTO_CLOSE ' + replace(replace(cast(d.[auto_close] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET AUTO_SHRINK ' + replace(replace(cast(d.[auto_shrink] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET AUTO_UPDATE_STATISTICS ' + replace(replace(cast(d.[auto_update_stats] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET CURSOR_CLOSE_ON_COMMIT ' + replace(replace(cast(d.[cursor_close_on_commit] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET CURSOR_DEFAULT ' + replace(replace(cast(d.[local_cursor_default] as nvarchar(1)), N'0', N'GLOBAL'), N'1', N'LOCAL') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET CONCAT_NULL_YIELDS_NULL ' + replace(replace(cast(d.[concat_null_yields_null] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET NUMERIC_ROUNDABORT ' + replace(replace(cast(d.[numeric_roundabort] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET QUOTED_IDENTIFIER ' + replace(replace(cast(d.[quoted_identifier] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET RECURSIVE_TRIGGERS ' + replace(replace(cast(d.[recursive_triggers] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ' + replace(replace(cast(d.[broker_enabled] as nvarchar(1)), N'0', N'DISABLE'), N'1', N'ENABLE') + N'_BROKER 
GO
', N'
ALTER DATABASE [#DbName#] SET AUTO_UPDATE_STATISTICS_ASYNC ' + replace(replace(cast(d.[auto_update_stats_async] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET DATE_CORRELATION_OPTIMIZATION ' + replace(replace(cast(d.[date_correlation] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET TRUSTWORTHY ' + replace(replace(cast(d.[thrustworthy] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ALLOW_SNAPSHOT_ISOLATION ' + d.[snapshot_isolation] + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET PARAMETERIZATION ' + replace(replace(cast(d.[parameterization] as nvarchar(1)), N'0', N'SIMPLE'), N'1', N'FORCED') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET READ_COMMITTED_SNAPSHOT ' + replace(replace(cast(d.[read_commited_snapshot] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET HONOR_BROKER_PRIORITY ' + replace(replace(cast(d.[honor_broker_priority] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET RECOVERY ' + d.[recovery_model] + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET ' + d.[user_access] + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET PAGE_VERIFY ' + d.[page_verify_option] + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET DB_CHAINING ' + replace(replace(cast(d.[db_changing] as nvarchar(1)), N'0', N'OFF'), N'1', N'ON') + N' 
GO
', N'
ALTER DATABASE [#DbName#] SET FILESTREAM( NON_TRANSACTED_ACCESS = ' + d.filestream_non_transact_access +
case when d.[filestream_directory] is not null then N', DIRECTORY_NAME = N''' + d.[filestream_directory] + N'''' collate Latin1_General_CI_AS else N'' end + N' ) 
GO
', N'
ALTER DATABASE [#DbName#] SET TARGET_RECOVERY_TIME = ' + cast(d.[target_recovery_time] as nvarchar(20)) + N' SECONDS 
GO
', N'
ALTER DATABASE [#DbName#] SET ' + replace(replace(cast(d.[read_only] as nvarchar(1)), N'0', N'READ_WRITE'), N'1', N'READ_ONLY') + N' 
GO
'
from		@DbInfo d

--------------------------------------------
-- End block - Generate Sql based on info --
--------------------------------------------

set nocount off