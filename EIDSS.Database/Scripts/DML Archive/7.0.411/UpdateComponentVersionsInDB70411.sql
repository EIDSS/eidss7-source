  set nocount on

  declare @dbVersion nvarchar(100) = N'7.0.411'
  declare @apiCompatibleVersion nvarchar(100) = N'1.0.0'
  declare @webCompatibleVersion nvarchar(100) = N'7.0.411'

  if exists(select 1 from tstVersionCompare where strModuleVersion like N'6.%')
	delete from tstVersionCompare
	where strModuleVersion like N'6.%'


  if @dbVersion is not null and @dbVersion like N'7.%.%'
  begin
	  declare @Now datetime
	  set @Now = getutcdate()
	  declare @SystemUser nvarchar(200) = N'SYSTEM'

	  delete from tstVersionCompare where strModuleName = 'eidss.db' and (strModuleVersion <> @dbVersion or strDatabaseVersion <> @dbVersion)
	  if not exists (select 1 from tstVersionCompare vc where vc.strModuleName = 'eidss.db')
		insert into tstVersionCompare (strModuleName, strModuleVersion, strDatabaseVersion, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
		select	N'eidss.db', 
				@dbVersion, 
				@dbVersion, 
				10519001 /*Record Source: EIDSS7*/, 
				N'[{"strModuleName":"eidss.db","strModuleVersion":"' + isnull(@dbVersion, N'null') + N',"strDatabaseVersion":"' + isnull(@dbVersion, N'null') + N'}]',
				@SystemUser,
				@Now,
				null,
				null


	  if not exists (select 1 from tstLocalSiteOptions lso where lso.strName = 'DatabaseVersion')
		insert into tstLocalSiteOptions (strName, strValue, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
		select	N'DatabaseVersion', 
				@dbVersion, 
				10519001 /*Record Source: EIDSS7*/, 
				N'[{"strName":"DatabaseVersion"}]',
				@SystemUser,
				@Now,
				null,
				null
	  else
		update tstLocalSiteOptions
		set strValue = @dbVersion,
			SourceSystemNameID = 10519001 /*Record Source: EIDSS7*/, 
			SourceSystemKeyValue =N'[{"strName":"DatabaseVersion"}]',
			AuditUpdateUser=@SystemUser,
			AuditUpdateDTM=@Now
		where strName = N'DatabaseVersion'
			  and (strValue is null or strValue <> @dbVersion)

	  if @apiCompatibleVersion is not null and @apiCompatibleVersion like N'%.%.%'
		and not exists (select 1 from tstVersionCompare vc where strModuleName = 'eidss.api' and vc.strModuleVersion = @apiCompatibleVersion and vc.strDatabaseVersion = @dbVersion)
		insert into tstVersionCompare (strModuleName, strModuleVersion, strDatabaseVersion, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
		select	N'eidss.api', 
				@apiCompatibleVersion, 
				@dbVersion, 
				10519001 /*Record Source: EIDSS7*/, 
				N'[{"strModuleName":"eidss.api","strModuleVersion":"' + isnull(@apiCompatibleVersion, N'null') + N',"strDatabaseVersion":"' + isnull(@dbVersion, N'null') + N'}]',
				@SystemUser,
				@Now,
				null,
				null

			
	  if @webCompatibleVersion is not null and @webCompatibleVersion like N'%.%.%'
		and not exists (select 1 from tstVersionCompare vc where strModuleName = 'eidss.web' and vc.strModuleVersion = @webCompatibleVersion and vc.strDatabaseVersion = @dbVersion)
		insert into tstVersionCompare (strModuleName, strModuleVersion, strDatabaseVersion, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
		select	N'eidss.web', 
				@webCompatibleVersion, 
				@dbVersion, 
				10519001 /*Record Source: EIDSS7*/, 
				N'[{"strModuleName":"eidss.web","strModuleVersion":"' + isnull(@webCompatibleVersion, N'null') + N',"strDatabaseVersion":"' + isnull(@dbVersion, N'null') + N'}]',
				@SystemUser,
				@Now,
				null,
				null
  end
  else print 'Specify correct DB Version'

  set nocount off
