set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.475.001'

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
	-- 
	delete from tstLocalSiteOptions where strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS

    -- Check if script has already been applied by means of database version
    IF EXISTS (SELECT * FROM tstLocalSiteOptions tlso WHERE tlso.strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS)
    begin
      print	'Script with version ' + @Version + ' has already been applied to the database ' + DB_NAME() + N' on the server ' + @@servername + N'.'
    end
    else begin
		-- Common part

		declare	@table_id int
		declare @column_id int
		declare @collation sysname
		declare @length int

		-- Alter HumanActualAddlInfo
		set	@table_id = OBJECT_ID(N'[dbo].[HumanActualAddlInfo]')

		--Drop index depending on the fields that shall be modified
		IF	exists (select 1 from sys.indexes i where i.[object_id] = @table_id and (i.[name] = N'IX_HumanActualAddlInfo_intRowStatus' collate Latin1_General_CI_AS))
			and (	exists
					(	select	1
						from	sys.columns s
						where	s.[object_id] = @table_id
								and (	(s.[name] = N'EIDSSPersonID' collate Latin1_General_CI_AS)
										or (s.[name] = N'PassportNbr' collate Latin1_General_CI_AS)
										or (s.[name] = N'ContactPhoneNbr' collate Latin1_General_CI_AS)
									)
								and (s.[system_type_id] = 167 /*varchar*/)
					)
				)
		BEGIN
			set @cmd = N'
			DROP INDEX [IX_HumanActualAddlInfo_intRowStatus] ON [dbo].[HumanActualAddlInfo]				'
			exec sp_executesql @cmd
		END

		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'EIDSSPersonID' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			--Drop unique index depending on the field EIDSSPersonID that shall be modified
			if exists (select 1 from sys.indexes i where i.[object_id] = @table_id and (i.[name] = N'UNIQ_HumanActualAddlInfo_EIDSSPersonID' collate Latin1_General_CI_AS))
			begin
				set @cmd = N'
			DROP INDEX [UNIQ_HumanActualAddlInfo_EIDSSPersonID] ON [dbo].[HumanActualAddlInfo]				'
				exec sp_executesql @cmd
			end

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [EIDSSPersonID] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [EIDSSPersonID] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd


			--Create unique index for the field EIDSSPersonID after modification
			if not exists (select 1 from sys.indexes i where i.[object_id] = @table_id and (i.[name] = N'UNIQ_HumanActualAddlInfo_EIDSSPersonID' collate Latin1_General_CI_AS))
			begin
				set @cmd = N'
				SET ANSI_PADDING ON

				CREATE UNIQUE NONCLUSTERED INDEX [UNIQ_HumanActualAddlInfo_EIDSSPersonID] ON [dbo].[HumanActualAddlInfo]
				(
					[EIDSSPersonID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
				'
				exec sp_executesql @cmd

				set @cmd = N'
				ALTER INDEX [UNIQ_HumanActualAddlInfo_EIDSSPersonID] ON [dbo].[HumanActualAddlInfo] REBUILD
				'
				exec sp_executesql @cmd
			end

		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 20

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'PassportNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 20

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [PassportNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'EmployerPhoneNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [EmployerPhoneNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'SchoolPhoneNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [SchoolPhoneNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'ContactPhoneNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [ContactPhoneNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'ContactPhone2Nbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo]
				ALTER COLUMN [ContactPhone2Nbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		if not exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherPhoneID' collate Latin1_General_CI_AS))
		begin
			set	@cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo] ADD [IsAnotherPhoneID] [BIGINT] NULL
			'
			exec sp_executesql @cmd

			set	@cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo] WITH CHECK ADD CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_IsAnotherPhone] FOREIGN KEY([IsAnotherPhoneID])
			REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
			'
			exec sp_executesql @cmd


			set	@cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo] CHECK CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_IsAnotherPhone]
			'
			exec sp_executesql @cmd
		end


		if not exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherAddressID' collate Latin1_General_CI_AS))
		begin
			set	@cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo] ADD [IsAnotherAddressID] [BIGINT] NULL
			'
			exec sp_executesql @cmd

			set	@cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo] WITH CHECK ADD CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_IsAnotherAddress] FOREIGN KEY([IsAnotherAddressID])
			REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
			'
			exec sp_executesql @cmd


			set	@cmd = N'
			ALTER TABLE [dbo].[HumanActualAddlInfo] CHECK CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_IsAnotherAddress]
			'
			exec sp_executesql @cmd
		end


		--Create index for the field intRowStatus including fields after modification
		if not exists (select 1 from sys.indexes i where i.[object_id] = @table_id and (i.[name] = N'IX_HumanActualAddlInfo_intRowStatus' collate Latin1_General_CI_AS))
		begin
			set @cmd = N'
			CREATE NONCLUSTERED INDEX [IX_HumanActualAddlInfo_intRowStatus] ON [dbo].[HumanActualAddlInfo]
			(
				[intRowStatus] ASC
			)
			INCLUDE([EIDSSPersonID],[ReportedAge],[PassportNbr],[ContactPhoneCountryCode],[ContactPhoneNbr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			'
			exec sp_executesql @cmd

			set @cmd = N'
			ALTER INDEX [IX_HumanActualAddlInfo_intRowStatus] ON [dbo].[HumanActualAddlInfo] REBUILD
			'
			exec sp_executesql @cmd
		end

		-- Add new fields into data audit columns dictionary
		if not exists (select 1 from dbo.tauColumn c where c.[idfTable] = 52577590000000 /*HumanActualAddlInfo*/ and c.[strName] = N'IsAnotherPhoneID' collate Cyrillic_General_CI_AS)
			and not exists (select 1 from dbo.tauColumn c where c.[idfColumn] = 51586990000124 /*Id reserved for IsAnotherPhoneID of HumanActualAddlInfo*/)
		begin
			insert into	dbo.tauColumn ([idfColumn], [idfTable], [strName], [strDescription], [SourceSystemNameID], [SourceSystemKeyValue], [AuditCreateUser], [AuditCreateDTM], [AuditUpdateUser], [AuditUpdateDTM])
			values
			(	51586990000124/*Id reserved for IsAnotherPhoneID of HumanActualAddlInfo*/, 
				52577590000000 /*HumanActualAddlInfo*/, 
				N'IsAnotherPhoneID', 
				N'Indicator whether another phone number has been provided', 
				10519001 /*EIDSSv7*/,
				N'[{"idfColumn":51586990000124}]',
				'system',
				GETDATE(),
				NULL,
				NULL
			)
		end

		if not exists (select 1 from dbo.tauColumn c where c.[idfTable] = 52577590000000 /*HumanActualAddlInfo*/ and c.[strName] = N'IsAnotherAddressID' collate Cyrillic_General_CI_AS)
			and not exists (select 1 from dbo.tauColumn c where c.[idfColumn] = 51586990000125 /*Id reserved for IsAnotherAddressID of HumanActualAddlInfo*/)
		begin
			insert into	dbo.tauColumn ([idfColumn], [idfTable], [strName], [strDescription], [SourceSystemNameID], [SourceSystemKeyValue], [AuditCreateUser], [AuditCreateDTM], [AuditUpdateUser], [AuditUpdateDTM])
			values
			(	51586990000125/*Id reserved for IsAnotherAddressID of HumanActualAddlInfo*/, 
				52577590000000 /*HumanActualAddlInfo*/, 
				N'IsAnotherAddressID', 
				N'Indicator whether another address(es) has(ve) been provided', 
				10519001 /*EIDSSv7*/,
				N'[{"idfColumn":51586990000125}]',
				'system',
				GETDATE(),
				NULL,
				NULL
			)
		end

		-- Calculate values of new fields for existing records
		if exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherPhoneID' collate Latin1_General_CI_AS))
			and exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherAddressID' collate Latin1_General_CI_AS))
		begin
			set	@cmd = N'
		update		haai
		set			haai.IsAnotherPhoneID = 
						case
							when	haai.ContactPhone2NbrTypeID is not null
									or	(	haai.ContactPhone2Nbr is not null
											and	len(ltrim(rtrim(haai.ContactPhone2Nbr))) > 0
										)
								then	10100001 /*Yes*/
							else	10100002 /*No*/
						end,
					haai.IsAnotherAddressID =
						case
							when	(	gls_alt.idfGeoLocationShared is not null
										and	gls_alt.idfsCountry is not null
										and (	gls_alt.blnForeignAddress = 1
												or gls_alt.idfsRegion is not null
											)
									)
									or	(	gls_reg.idfGeoLocationShared is not null
											and	gls_reg.idfsCountry is not null
											and (	gls_reg.blnForeignAddress = 1
													or gls_reg.idfsRegion is not null
												)
										)
								then	10100001 /*Yes*/
							else	10100002 /*No*/
						end
		from		HumanActualAddlInfo haai
		join		tlbHumanActual ha
		on			ha.idfHumanActual = haai.HumanActualAddlInfoUID
		left join	tlbGeoLocationShared gls_alt
		on			gls_alt.idfGeoLocationShared = haai.AltAddressID
		left join	tlbGeoLocationShared gls_reg
		on			gls_reg.idfGeoLocationShared = ha.idfRegistrationAddress
			'
			exec sp_executesql @cmd
		end

		-- Alter HumanAddlInfo
		set	@table_id = OBJECT_ID(N'[dbo].[HumanAddlInfo]')


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 20

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'PassportNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 20

			set @cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo]
				ALTER COLUMN [PassportNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'EmployerPhoneNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo]
				ALTER COLUMN [EmployerPhoneNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'SchoolPhoneNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo]
				ALTER COLUMN [SchoolPhoneNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'ContactPhoneNbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo]
				ALTER COLUMN [ContactPhoneNbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		set	@column_id = null
		set	@collation = N'Cyrillic_General_CI_AS'
		set	@length = 200

		select	@column_id = s.column_id,
				@collation = s.collation_name,
				@length = s.max_length
		from	sys.columns s
		where	s.[object_id] = @table_id
				and (s.[name] = N'ContactPhone2Nbr' collate Latin1_General_CI_AS)
				and (s.[system_type_id] = 167 /*varchar*/) 


		IF @column_id > 0
		BEGIN
			if @length < 0 or @length is null
				set	@length = 200

			set @cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo]
				ALTER COLUMN [ContactPhone2Nbr] NVARCHAR(' + CAST(@length as nvarchar(20)) + N') NULL
			'
			exec sp_executesql @cmd
		END


		if not exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherPhoneID' collate Latin1_General_CI_AS))
		begin
			set	@cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo] ADD [IsAnotherPhoneID] [BIGINT] NULL
			'
			exec sp_executesql @cmd

			set	@cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo] WITH CHECK ADD CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsAnotherPhone] FOREIGN KEY([IsAnotherPhoneID])
			REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
			'
			exec sp_executesql @cmd


			set	@cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo] CHECK CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsAnotherPhone]
			'
			exec sp_executesql @cmd
		end


		if not exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherAddressID' collate Latin1_General_CI_AS))
		begin
			set	@cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo] ADD [IsAnotherAddressID] [BIGINT] NULL
			'
			exec sp_executesql @cmd

			set	@cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo] WITH CHECK ADD CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsAnotherAddress] FOREIGN KEY([IsAnotherAddressID])
			REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
			'
			exec sp_executesql @cmd


			set	@cmd = N'
			ALTER TABLE [dbo].[HumanAddlInfo] CHECK CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsAnotherAddress]
			'
			exec sp_executesql @cmd
		end

		-- Add new fields into data audit columns dictionary
		if not exists (select 1 from dbo.tauColumn c where c.[idfTable] = 53577690000000 /*HumanAddlInfo*/ and c.[strName] = N'IsAnotherPhoneID' collate Cyrillic_General_CI_AS)
			and not exists (select 1 from dbo.tauColumn c where c.[idfColumn] = 51586990000126 /*Id reserved for IsAnotherPhoneID of HumanAddlInfo*/)
		begin
			insert into	dbo.tauColumn ([idfColumn], [idfTable], [strName], [strDescription], [SourceSystemNameID], [SourceSystemKeyValue], [AuditCreateUser], [AuditCreateDTM], [AuditUpdateUser], [AuditUpdateDTM])
			values
			(	51586990000126/*Id reserved for IsAnotherPhoneID of HumanAddlInfo*/, 
				53577690000000 /*HumanAddlInfo*/, 
				N'IsAnotherPhoneID', 
				N'Indicator whether another phone number has been provided', 
				10519001 /*EIDSSv7*/,
				N'[{"idfColumn":51586990000126}]',
				'system',
				GETDATE(),
				NULL,
				NULL
			)
		end

		if not exists (select 1 from dbo.tauColumn c where c.[idfTable] = 53577690000000 /*HumanAddlInfo*/ and c.[strName] = N'IsAnotherAddressID' collate Cyrillic_General_CI_AS)
			and not exists (select 1 from dbo.tauColumn c where c.[idfColumn] = 51586990000127 /*Id reserved for IsAnotherAddressID of HumanAddlInfo*/)
		begin
			insert into	dbo.tauColumn ([idfColumn], [idfTable], [strName], [strDescription], [SourceSystemNameID], [SourceSystemKeyValue], [AuditCreateUser], [AuditCreateDTM], [AuditUpdateUser], [AuditUpdateDTM])
			values
			(	51586990000127/*Id reserved for IsAnotherAddressID of HumanAddlInfo*/, 
				53577690000000 /*HumanAddlInfo*/, 
				N'IsAnotherAddressID', 
				N'Indicator whether another address(es) has(ve) been provided', 
				10519001 /*EIDSSv7*/,
				N'[{"idfColumn":51586990000127}]',
				'system',
				GETDATE(),
				NULL,
				NULL
			)
		end

		-- Calculate values of new fields for existing records
		if exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherPhoneID' collate Latin1_General_CI_AS))
			and exists (select 1 from sys.columns s where s.[object_id] = @table_id and (s.[name] = N'IsAnotherAddressID' collate Latin1_General_CI_AS))
		begin
			set	@cmd = N'
		update		hai
		set			hai.IsAnotherPhoneID = 
						case
							when	hai.ContactPhone2NbrTypeID is not null
									or	(	hai.ContactPhone2Nbr is not null
											and	len(ltrim(rtrim(hai.ContactPhone2Nbr))) > 0
										)
								then	10100001 /*Yes*/
							else	10100002 /*No*/
						end,
					hai.IsAnotherAddressID =
						case
							when	(	gl_alt.idfGeoLocation is not null
										and	gl_alt.idfsCountry is not null
										and (	gl_alt.blnForeignAddress = 1
												or gl_alt.idfsRegion is not null
											)
									)
									or	(	gl_reg.idfGeoLocation is not null
											and	gl_reg.idfsCountry is not null
											and (	gl_reg.blnForeignAddress = 1
													or gl_reg.idfsRegion is not null
												)
										)
								then	10100001 /*Yes*/
							else	10100002 /*No*/
						end
		from		HumanAddlInfo hai
		join		tlbHuman h
		on			h.idfHuman = hai.HumanAdditionalInfo
		left join	tlbGeoLocation gl_reg
		on			gl_reg.idfGeoLocation = h.idfRegistrationAddress
		left join	tlbGeoLocation gl_alt
		on			gl_alt.idfGeoLocation = hai.AltAddressID
			'
			exec sp_executesql @cmd
		end


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
