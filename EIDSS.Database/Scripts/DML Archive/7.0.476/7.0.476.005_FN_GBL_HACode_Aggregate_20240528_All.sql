set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.476.005'

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

		set @cmd = N'
CREATE OR ALTER FUNCTION [dbo].[FN_GBL_HACode_Aggregate]
(
	@idfsLanguage	BIGINT,
	@HACode		BIGINT
)
RETURNS TABLE
AS

	RETURN(
		SELECT	STRING_AGG(cast(hcl.intHACode AS nvarchar(4)), N'','') AS HACodeIds,
				STRING_AGG(COALESCE(snt.[strTextString], br.[strDefault], N''''), N'','') AS HACodeNames
		FROM		[dbo].[trtHACodeList] AS hcl
		INNER JOIN	[dbo].[trtBaseReference] AS br
			ON hcl.[idfsCodeName] = br.[idfsBaseReference]
		LEFT JOIN	[dbo].[trtStringNameTranslation] AS snt
			ON hcl.[idfsCodeName] = snt.[idfsBaseReference]
				AND snt.[idfsLanguage] = @idfsLanguage
		WHERE		(	(	(	hcl.[intHACode] <> 0
								AND hcl.intHACode <> 510
							)
							AND ((@HACode & hcl.[intHACode]) = hcl.[intHACode])
						)
						OR	(	hcl.[intHACode] = 0
								and not exists
										(	select	1 
											from	[dbo].[trtHACodeList] AS hcl_other 
											where	((hcl_other.[intHACode] & @HACode) = hcl_other.[intHACode]) 
													and hcl_other.intRowStatus = 0
													and hcl_other.[intHACode] <> 0 
													and hcl_other.[intHACode] <> 510
										)
							)
					)
					AND hcl.intRowStatus = 0
					AND @HACode IS NOT NULL
		)
'
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
