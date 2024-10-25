
set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

declare @server_name sysname = @@SERVERNAME
declare @db_name sysname = DB_NAME()


if @db_name is null or @db_name = N'' or @db_name = N'master' or @db_name = N'masdb' or @db_name = N'tempdb' or @db_name = N'model'
begin
	print N'No Clear Ids job will be created for the system database [' + @db_name + N']!'
end
else if @db_name like N'%_Archive' collate Cyrillic_General_CI_AS
begin
	print N'No Clear Ids job will be created for the archive database [' + @db_name + N']!'
end
else begin
	print N'Clear Ids job will be created/updated for the database [' + @db_name + N']'


declare	@job_name sysname = N'cid' + @db_name collate Latin1_General_CI_AS
declare	@sch_name sysname = N'sch_cid' + @db_name collate Latin1_General_CI_AS
declare	@Today datetime = getdate()
declare @active_start_date int = year(@Today)*10000 + month(@Today)*100 + day(@Today)
declare @active_start_time_int int = 220000

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

exec msdb.dbo.sp_add_jobstep @job_name=@job_name, @step_name=N'Clear Identifiers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET NOCOUNT ON;

-- Delete generated and assigned IDs
DELETE FROM tflNewID
DELETE FROM tstNewID
DELETE FROM gisNewID

declare	@now datetime
set @now = getdate()

-- Delete obsolete Web AVR user tickets
DELETE FROM tstUserTicket
WHERE datExpirationDate < DATEADD(SECOND, -10, @now)

-- Delete obsolete Connection Contexts
DELETE FROM tstLocalConnectionContext
WHERE datLastUsed < DATEADD(HOUR, -2, @now)

-- Delete obsolete events
delete from tstEventActive
where datEventDatatime < DATEADD(DAY, -10, @now)

delete from tstEvent
where datEventDatatime < DATEADD(MONTH, -1, @now)

SET NOCOUNT OFF;
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



