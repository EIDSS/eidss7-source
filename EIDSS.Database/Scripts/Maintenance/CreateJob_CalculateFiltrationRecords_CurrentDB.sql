
set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

declare @server_name sysname = @@SERVERNAME
declare @db_name sysname = DB_NAME()


if @db_name is null or @db_name = N'' or @db_name = N'master' or @db_name = N'masdb' or @db_name = N'tempdb' or @db_name = N'model'
begin
	print N'No Calculate Filtration Records job will be created for the system database [' + @db_name + N']!'
end
else if @db_name like N'%_Archive' collate Latin1_General_CI_AS
begin
	print N'No Calculate Filtration Records job will be created for the archive database [' + @db_name + N']!'
end
else begin
	print N'Calculate Filtration Records job will be created/updated for the database [' + @db_name + N']'


declare	@job_name sysname = N'cfrd' + @db_name collate Latin1_General_CI_AS
declare	@sch_name sysname = N'sch_cfrd' + @db_name collate Latin1_General_CI_AS
declare	@Today datetime = getdate()
declare @active_start_date int = year(@Today)*10000 + month(@Today)*100 + day(@Today)
declare @active_start_time_int int = 1000

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

exec msdb.dbo.sp_add_jobstep @job_name=@job_name, @step_name=N'Calculate Filtration Records', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
declare	@StartDate datetime = dateadd(DAY, -2, cast(getdate() as date))
exec [dbo].[DF_CalculateRecords_All] 
	@UsePredefinedData=0,
	@StartDate=@StartDate,
	@MaxNumberOfProcessedObjects=1000000,
	@MaxNumberOfNewFiltrationRecords=1000000,
	@CalculateHumanData=1,
	@CalculateVetData=1,
	@CalculateVSSData=1,
	@CalculateBSSData=1,
	@ApplyCFRules=1
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
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
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



