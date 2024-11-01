
set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

declare @server_name sysname = @@SERVERNAME
declare @db_name sysname = DB_NAME()


if @db_name is null or @db_name = N'' or @db_name = N'master' or @db_name = N'masdb' or @db_name = N'tempdb' or @db_name = N'model'
begin
	print N'No rebuild/reorganize job will be created for the system database [' + @db_name + N']!'
end
else begin
	print N'Rebuild/reorganize job will be created/updated for the database [' + @db_name + N']'


declare	@job_name sysname = N'ri' + @db_name collate Latin1_General_CI_AS
declare	@sch_name sysname = N'sch_ri' + @db_name collate Latin1_General_CI_AS
declare	@Today datetime = getdate()
declare @active_start_date int = year(@Today)*10000 + month(@Today)*100 + day(@Today)
declare @active_start_time_int int = 20000
if @db_name like N'%_Archive' collate Cyrillic_General_CI_AS
	set	@active_start_time_int = 23000

declare	@job_id uniqueidentifier
select	@job_id = j.job_id
from	msdb.dbo.sysjobs_view j
where	j.[name]=@job_name collate Latin1_General_CI_AS

if @job_id is not null
begin
	exec msdb.dbo.sp_delete_job @job_id=@job_id, @delete_unused_schedule=1
end

IF not exists (select 1 from msdb.dbo.syscategories where [name]=N'[Uncategorized (Local)]' collate Latin1_General_CI_AS AND category_class=1)
begin
	exec msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
end

exec  msdb.dbo.sp_add_job @job_name=@job_name, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id=null


exec msdb.dbo.sp_add_jobserver @job_name=@job_name, @server_name=@server_name

exec msdb.dbo.sp_add_jobstep @job_name=@job_name, @step_name=N'Rebuild/Reorganize indexes', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
-- Script rebuilds or reorganizes all database indexes and updates statistics.
-- Execute this script on correct database.
SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @partitioncount bigint;
DECLARE @schemaname sysname;
DECLARE @objectname sysname;
DECLARE @indexname sysname;
DECLARE @partitionnum bigint;
DECLARE @partitions bigint;
DECLARE @frag float;
DECLARE @command varchar(8000);
-- ensure the temporary table does not exist
IF EXISTS (SELECT name FROM sys.objects WHERE name = ''work_to_do'')
    DROP TABLE dbo.work_to_do;
-- conditionally select from the function, converting object and index IDs to names.
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO dbo.work_to_do
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, ''LIMITED'')
WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;
-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR SELECT * FROM dbo.work_to_do;

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
FETCH NEXT
   FROM partitions
   INTO @objectid, @indexid, @partitionnum, @frag;

WHILE @@FETCH_STATUS = 0
    BEGIN;
        SELECT @objectname = o.name, @schemaname = s.name
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.[schema_id] = o.[schema_id]
        WHERE o.[object_id] = @objectid;

        SELECT @indexname = name 
        FROM sys.indexes
        WHERE  [object_id] = @objectid AND index_id = @indexid;

        SELECT @partitioncount = count (*) 
        FROM sys.partitions
        WHERE [object_id] = @objectid AND index_id = @indexid;

-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding
IF @frag < 30.0 and @indexname not like ''%geomShape%''
    BEGIN;
    SELECT @command = ''
SET QUOTED_IDENTIFIER ON;
ALTER INDEX ['' + @indexname + ''] ON '' + @schemaname + ''.'' + @objectname + '' REORGANIZE'';
    IF @partitioncount > 1
        SELECT @command = @command + '' PARTITION='' + CONVERT (CHAR, @partitionnum);
	--PRINT @command
    EXEC (@command);
    END;

IF @frag >= 30.0 and @indexname not like ''%geomShape%''
    BEGIN;
    SELECT @command = ''
SET QUOTED_IDENTIFIER ON;
ALTER INDEX ['' + @indexname +''] ON '' + @schemaname + ''.'' + @objectname + '' REBUILD'';
    IF @partitioncount > 1
        SELECT @command = @command + '' PARTITION='' + CONVERT (CHAR, @partitionnum);
	--PRINT @command
    EXEC (@command);
    END;
--PRINT ''Executed '' + @command;

FETCH NEXT FROM partitions INTO @objectid, @indexid, @partitionnum, @frag;
END;
-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- drop the temporary table
IF EXISTS (SELECT name FROM sys.objects WHERE name = ''work_to_do'')
    DROP TABLE dbo.work_to_do;
GO

exec sp_updatestats
', 
		@database_name=@db_name, 
		@flags=0

exec msdb.dbo.sp_update_job @job_name=@job_name, 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''

exec msdb.dbo.sp_add_jobschedule @job_name=@job_name, @name=@sch_name, 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=@active_start_date, 
		@active_end_date=99991231, 
		@active_start_time=@active_start_time_int, 
		@active_end_time=235959, @schedule_id=null
end

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	declare	@err_number int
	declare	@err_severity int
	declare	@err_state int
	declare	@err_line int
	declare	@err_procedure	nvarchar(200)
	declare	@err_message	nvarchar(MAX)
	
	select	@err_number = ERROR_NUMBER(),
			@err_severity = ERROR_SEVERITY(),
			@err_state = ERROR_STATE(),
			@err_line = ERROR_LINE(),
			@err_procedure = ERROR_PROCEDURE(),
			@err_message = ERROR_MESSAGE()

	set	@err_message = N'An error occurred during script execution.
' + N'Msg ' + cast(isnull(@err_number, 0) as nvarchar(20)) + 
N', Level ' + cast(isnull(@err_severity, 0) as nvarchar(20)) + 
N', State ' + cast(isnull(@err_state, 0) as nvarchar(20)) + 
N', Line ' + cast(isnull(@err_line, 0) as nvarchar(20)) + N'
' + isnull(@err_message, N'Unknown error')

	raiserror	(	@err_message,
					17,
					@err_state
				) with SETERROR

END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

set XACT_ABORT off
set nocount off



