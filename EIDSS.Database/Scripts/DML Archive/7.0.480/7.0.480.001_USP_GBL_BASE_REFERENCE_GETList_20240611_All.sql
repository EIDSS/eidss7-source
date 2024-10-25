set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.480.001'

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
CREATE OR ALTER PROCEDURE [dbo].[USP_GBL_BASE_REFERENCE_GETList] 
(
	@LangID	NVARCHAR(50),
	@ReferenceTypeName VARCHAR(400) = NULL,
	@intHACode	BIGINT = NULL 
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_Get(@LangID)


		SELECT 
			br.idfsBaseReference,
			br.idfsReferenceType,
			br.strBaseReferenceCode,
			strDefault = 
				CASE 
					WHEN @ReferenceTypeName = N''Disease'' collate Cyrillic_General_CI_AS THEN
						diag_group.strDefault
					ELSE br.strDefault
				END,
			[name] =
				CASE 
					WHEN @ReferenceTypeName = N''Disease'' collate Cyrillic_General_CI_AS THEN
						diag_group.[name]
					ELSE ISNULL(s.strTextString, br.strDefault)
				END,
			br.intHACode,
			br.intOrder,
			br.intRowStatus,
			br.blnSystem,
			rt.intDefaultHACode,
			CASE WHEN @intHACode IS NULL OR @intHACode = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode,
			isnull(rt_id.EditorSettings, rt.EditorSettings) AS EditorSettings
		FROM dbo.trtBaseReference br
		INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = @idfsLanguage

		LEFT JOIN dbo.trtReferenceType AS rt_id ON rt_id.idfsReferenceType = br.idfsBaseReference

		OUTER APPLY
		(	SELECT TOP 1 brg.strDefault, ISNULL(sg.strTextString, brg.strDefault) AS [name]
			FROM dbo.trtDiagnosisToDiagnosisGroup dg
			INNER Join dbo.trtBaseReference brg ON dg.idfsDiagnosisGroup = brg.idfsBaseReference
			LEFT JOIN dbo.trtStringNameTranslation AS sg ON brg.idfsBaseReference = sg.idfsBaseReference AND sg.idfsLanguage = @idfsLanguage
			WHERE dg.idfsDiagnosis = br.idfsBaseReference AND brg.strDefault IS NOT NULL
					AND dg.intRowStatus = 0
					AND @ReferenceTypeName = N''Disease'' collate Cyrillic_General_CI_AS
			ORDER BY dg.idfDiagnosisToDiagnosisGroup
		) diag_group

		WHERE 
			br.idfsBaseReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
												 19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
												 19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
												 19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,
												 19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
												 19000140)
			AND	br.intRowStatus = 0	
			AND (	br.intHACode & @intHACode > 0
					OR br.intHACode IS NULL
					OR @intHACode IS NULL OR @intHACode = 0
				)
		AND (	@ReferenceTypeName IS NULL
				OR rt.strReferenceTypeName = @ReferenceTypeName collate Cyrillic_General_CI_AS
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
