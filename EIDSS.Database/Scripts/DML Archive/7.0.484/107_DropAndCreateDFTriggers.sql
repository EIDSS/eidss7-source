set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.484.107'

	-- Command to use in the calls of the stored procedure sp_executesql in case there are GO statements that should be avoided.
	-- Each call of sp_executesql can implement execution of the script between two GO statements
	declare @cmd nvarchar(max) = N''


  -- Verify database and script versions
  if	@Version is null
  begin
    raiserror ('Script doesn''t have version', 16, 1)
  end
  else begin
	-- Workaround to apply the script multiple times
	-- delete from tstLocalSiteOptions where strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS

    -- Check if script has already been applied by means of database version
    IF EXISTS (SELECT * FROM tstLocalSiteOptions tlso WHERE tlso.strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS)
    begin
      print	'Script with version ' + @Version + ' has already been applied to the database ' + DB_NAME() + N' on the server ' + @@servername + N'.'
    end
    else begin
		-- Common part
		declare	@DBTable nvarchar(200)
		declare	@TriggerToDrop nvarchar(200)


		set	@DBTable = N'tlbAggrCase'
		set	@TriggerToDrop = N'trtAggrCaseReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbBasicSyndromicSurveillanceAggregateHeader'
		set	@TriggerToDrop = N'trtBasicSyndromicSurveillanceAggregateHeaderReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbBasicSyndromicSurveillance'
		set	@TriggerToDrop = N'trtBasicSyndromicSurveillanceReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbBatchTest'
		set	@TriggerToDrop = N'trtBatchTestReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tauDataAuditEvent'
		set	@TriggerToDrop = N'trtDataAuditEventReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end


		set	@DBTable = N'tlbFarm'
		set	@TriggerToDrop = N'trtFarmReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end


		set	@DBTable = N'tlbGeoLocation'
		set	@TriggerToDrop = N'trtGeoLocationReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end


		set	@DBTable = N'tlbHuman'
		set	@TriggerToDrop = N'trtHumanReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end


		set	@DBTable = N'tlbHumanCase'
		set	@TriggerToDrop = N'trtHumanCaseReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbMonitoringSession'
		set	@TriggerToDrop = N'trtMonitoringSessionCaseReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tstNotification'
		set	@TriggerToDrop = N'trtNotificationReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end


		set	@DBTable = N'tlbObservation'
		set	@TriggerToDrop = N'trtObservationReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end


		set	@DBTable = N'tlbOutbreak'
		set	@TriggerToDrop = N'trtOutbreakReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbTransferOut'
		set	@TriggerToDrop = N'trtTransferOutReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbVectorSurveillanceSession'
		set	@TriggerToDrop = N'trtVectorSurveillanceSessionReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end


		set	@DBTable = N'tlbVetCase'
		set	@TriggerToDrop = N'trtVetCaseReplicationUp'

		if exists (select 1 from sys.triggers tr where tr.[parent_id] = object_id(@DBTable, N'U') and tr.[object_id] = object_id(@TriggerToDrop, N'TR'))
		begin
			set	@cmd = N'DROP TRIGGER [' + replace(@TriggerToDrop, N'''', N'''''') + ']'
			print	@cmd
			exec	sp_executesql @cmd
		end

		if	object_id(@DBTable, N'U') is not null
		begin
			EXEC [dbo].[DF_CreateTrigger] @DBTable=@DBTable,@PrintCmd=0,@ExecCmd=1
		end

		exec sp_executesql @cmd

		-- Add version of the current script to the database
		if not exists (select * from tstLocalSiteOptions lso where strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS)
		  INSERT INTO tstLocalSiteOptions (strName, strValue, SourceSystemNameID, SourceSystemKeyValue, AuditCreateDTM, AuditCreateUser) 
		  VALUES ('DBScript(' + @Version + ')', CONVERT(NVARCHAR, GETDATE(), 121), 10519001 /*EIDSSv7*/, N'[{"strName":"DBScript(' + @Version + N')"}]', GETDATE(), N'SYSTEM')
	end
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

