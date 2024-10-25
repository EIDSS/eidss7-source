-- Purpose: This is a template for the upgrade/patch script for the database of EIDSSv7
-- Customization package: All/Georgia/Azerbaijan/...

-- Script version: 7.0.462.001
-- Script name: 7.0.462.001_UpgradeDbScriptTemplate_YYYYMMDD_All.sql

-- Script prerequisites: None

-- Instructions: Script should be applied on EIDSS database version 7.


set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.462.001'

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
	-- Check common (not country-specific) script prerequisites if any
	--else if  [Type here condition of missing prerequisites]
	--begin
	--	raiserror ('[Type here message about missing prerequisites]', 16, 1) with SETERROR
	--end
    else begin
		-- Common part
		-- [Type here script to apply on the database that belongs to any customization package]
		exec sp_executesql @cmd

		-- Customization-specific part
		declare	@idfCustomizationPackage	bigint

		select		@idfCustomizationPackage = cp.idfCustomizationPackage
		from		tstGlobalSiteOptions gso
		inner join	tstCustomizationPackage cp
		on			cast(cp.idfCustomizationPackage as nvarchar) = gso.strValue
					and cp.strCustomizationPackageName = @CustomizationPackageName collate Cyrillic_General_CI_AS
		inner join	gisCountry c
		on			c.idfsCountry = cp.idfsCountry
					and c.intRowStatus = 0
		inner join	gisBaseReference c_br
		on			c_br.idfsGISBaseReference = c.idfsCountry
					and c_br.intRowStatus = 0
		where		gso.strName = N'CustomizationPackage' collate Cyrillic_General_CI_AS
					and ISNUMERIC(gso.strValue) = 1

		if	@idfCustomizationPackage is null
			select		@idfCustomizationPackage = cp.idfCustomizationPackage
			from		tstLocalSiteOptions lso
			inner join	tstSite s
			on			cast(s.idfsSite as nvarchar(200)) = lso.strValue collate Cyrillic_General_CI_AS
						and s.intRowStatus = 0
			inner join	tstCustomizationPackage cp
			on			cp.idfCustomizationPackage = s.idfCustomizationPackage
						and cp.strCustomizationPackageName = @CustomizationPackageName collate Cyrillic_General_CI_AS
			inner join	gisCountry c
			on			c.idfsCountry = cp.idfsCountry
						and c.intRowStatus = 0
			inner join	gisBaseReference c_br
			on			c_br.idfsGISBaseReference = c.idfsCountry
						and c_br.intRowStatus = 0
			where		lso.strName = N'SiteID' collate Cyrillic_General_CI_AS
						and not exists	(
									select	*
									from	tstGlobalSiteOptions gso
									inner join	tstCustomizationPackage cp_gso
									on			cast(cp_gso.idfCustomizationPackage as nvarchar) = gso.strValue
									where		gso.strName = N'CustomizationPackage' collate Cyrillic_General_CI_AS
												and ISNUMERIC(gso.strValue) = 1
										)

		-- if local site is BV then customization-specific part shall be implemented
		if	@idfCustomizationPackage is null
			and	exists	(	
					select		*
					from		tstLocalSiteOptions lso
					inner join	tstSite s
					on			cast(s.idfsSite as nvarchar(200)) = lso.strValue collate Cyrillic_General_CI_AS
								and	s.idfsSite = 1
					where		lso.strName = N'SiteID' collate Cyrillic_General_CI_AS

						)
		begin
			select		@idfCustomizationPackage = cp.idfCustomizationPackage
			from		tstCustomizationPackage cp
			inner join	gisCountry c
			on			c.idfsCountry = cp.idfsCountry
						and c.intRowStatus = 0
			inner join	gisBaseReference c_br
			on			c_br.idfsGISBaseReference = c.idfsCountry
						and c_br.intRowStatus = 0
			where		cp.strCustomizationPackageName = @CustomizationPackageName collate Cyrillic_General_CI_AS
		end


		if @idfCustomizationPackage is not null
		begin
			-- Check country-specific script prerequisites
			--if  [Type here condition of missing prerequisites]
			--begin
			--	raiserror ('[Type here message about missing prerequisites]', 16, 1) with SETERROR
			--end
			--else begin

				-- [Type here script to apply on the database that belongs to specific customization package with name = @CustomizationPackageName]
				exec sp_executesql @cmd

			--end

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
