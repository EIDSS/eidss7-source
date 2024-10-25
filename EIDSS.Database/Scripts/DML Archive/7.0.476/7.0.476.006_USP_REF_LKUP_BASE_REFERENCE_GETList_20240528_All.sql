set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.476.006'

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
	delete from tstLocalSiteOptions where strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS

    -- Check if script has already been applied by means of database version
    IF EXISTS (SELECT * FROM tstLocalSiteOptions tlso WHERE tlso.strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS)
    begin
      print	'Script with version ' + @Version + ' has already been applied to the database ' + DB_NAME() + N' on the server ' + @@servername + N'.'
    end
    else begin
		-- Common part

		set @cmd = N'
CREATE OR ALTER PROCEDURE [dbo].[USP_REF_LKUP_BASE_REFERENCE_GETList]
	 @idfsReferenceType	   BIGINT
	,@langID			   NVARCHAR(50)
	,@advancedSearch	   NVARCHAR(100) = NULL
	,@pageNo			   INT = 1
	,@pageSize			   INT = 10 
	,@sortColumn		   NVARCHAR(30) = ''strName'' 
	,@sortOrder			   NVARCHAR(4) = ''ASC''

AS
BEGIN	
    SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_Get(@LangID)
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @T TABLE
		( 
			idfsBaseReference BIGINT, 
			idfsReferenceType BIGINT, 
			strDefault		  NVARCHAR(2000), 
			strName			  NVARCHAR(2000),
			intHACode		  INT,
			strHACode		  NVARCHAR(4000),
			strHACodeNames	  NVARCHAR(4000),
			intOrder		  INT,
			LOINC			  NVARCHAR(200)
		)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		IF( @advancedSearch IS NOT NULL )
		BEGIN
			SET @advancedSearch = REPLACE(@advancedSearch, ''%'', ''[%]'');
			SET @advancedSearch = REPLACE(@advancedSearch, ''_'', ''[_]'');

			INSERT INTO @T
			SELECT 
				br.idfsBaseReference, 
				br.idfsReferenceType, 
				br.strDefault, 
				ISNULL(snt.strTextString, br.strDefault) AS strName,
				br.intHACode, 
				hcl.HACodeIds AS strHACode,			
				hcl.HACodeNames AS strHACodeNames,
				br.intOrder,
				lcm.LOINC_NUM AS LOINC
			FROM  dbo.trtBaseReference br
			LEFT JOIN dbo.trtStringNameTranslation snt ON snt.idfsBaseReference = br.idfsBaseReference and snt.idfsLanguage = @idfsLanguage
			LEFT JOIN dbo.LOINCEidssMapping lcm ON lcm.idfsBaseReference = br.idfsBaseReference and lcm.intRowStatus = 0
			OUTER APPLY dbo.[FN_GBL_HACode_Aggregate] (@idfsLanguage, br.intHACode) hcl
			WHERE 
				br.intRowStatus = 0
				AND br.idfsReferenceType = @idfsReferenceType
				AND br.idfsBaseReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
												19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
												19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
												19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,
												19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
												19000140)
				AND (	snt.strTextString LIKE ''%'' + @advancedSearch + ''%'' collate Cyrillic_General_CI_AS
						OR	(	snt.strTextString IS NULL
								AND br.strDefault LIKE ''%'' + @advancedSearch + ''%'' collate Cyrillic_General_CI_AS
							)
					)
		END ELSE
		BEGIN
			INSERT INTO @T
			SELECT 
				br.idfsBaseReference, 
				br.idfsReferenceType, 
				br.strDefault, 
				ISNULL(snt.strTextString, br.strDefault) AS strName,
				br.intHACode, 
				hcl.HACodeIds AS strHACode,			
				hcl.HACodeNames AS strHACodeNames,
				br.intOrder,
				lcm.LOINC_NUM AS LOINC
			FROM  dbo.trtBaseReference br
			LEFT JOIN dbo.trtStringNameTranslation snt ON snt.idfsBaseReference = br.idfsBaseReference and snt.idfsLanguage = @idfsLanguage
			LEFT JOIN dbo.LOINCEidssMapping lcm ON lcm.idfsBaseReference = br.idfsBaseReference and lcm.intRowStatus = 0
			OUTER APPLY dbo.[FN_GBL_HACode_Aggregate] (@idfsLanguage, br.intHACode) hcl
			WHERE 
				br.intRowStatus = 0
				AND br.idfsReferenceType = @idfsReferenceType
				AND br.idfsBaseReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
												19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
												19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
												19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,
												19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
												19000140)
		END;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = ''idfsBaseReference'' AND @SortOrder = ''asc'' THEN idfsBaseReference END ASC,
				CASE WHEN @sortColumn = ''idfsBaseReference'' AND @SortOrder = ''desc'' THEN idfsBaseReference END DESC,
				CASE WHEN @sortColumn = ''idfsReferenceType'' AND @SortOrder = ''asc'' THEN idfsReferenceType END ASC,
				CASE WHEN @sortColumn = ''idfsReferenceType'' AND @SortOrder = ''desc'' THEN idfsReferenceType END DESC,
				CASE WHEN @sortColumn = ''strdefault'' AND @SortOrder = ''asc'' THEN strdefault END ASC,
				CASE WHEN @sortColumn = ''strdefault'' AND @SortOrder = ''desc'' THEN strdefault END DESC,
				CASE WHEN @sortColumn = ''strName'' AND @SortOrder = ''asc'' THEN strName END ASC,
				CASE WHEN @sortColumn = ''strName'' AND @SortOrder = ''desc'' THEN strName END DESC,
				CASE WHEN @sortColumn = ''intHACode'' AND @SortOrder = ''asc'' THEN intHACode END ASC,
				CASE WHEN @sortColumn = ''intHACode'' AND @SortOrder = ''desc'' THEN intHACode END DESC,
				CASE WHEN @sortColumn = ''strHACode'' AND @SortOrder = ''asc'' THEN strHACode END ASC,
				CASE WHEN @sortColumn = ''strHACode'' AND @SortOrder = ''desc'' THEN strHACode END DESC,
				CASE WHEN @sortColumn = ''strHACodeNames'' AND @SortOrder = ''asc'' THEN strHACodeNames END ASC,
				CASE WHEN @sortColumn = ''strHACodeNames'' AND @SortOrder = ''desc'' THEN strHACodeNames END DESC,
				CASE WHEN @sortColumn = ''intorder'' AND @SortOrder = ''asc'' THEN intOrder END ASC,
				CASE WHEN @sortColumn = ''intorder'' AND @SortOrder = ''desc'' THEN intOrder END DESC,
				CASE WHEN @sortColumn = ''LOINC'' AND @SortOrder = ''asc'' THEN LOINC END ASC,
				CASE WHEN @sortColumn = ''LOINC'' AND @SortOrder = ''desc'' THEN LOINC END DESC
				,IIF( @sortColumn = ''intOrder'',strName,cast(idfsBaseReference as nvarchar(20))) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfsBaseReference AS KeyId, 
				idfsBaseReference, 
				idfsReferenceType, 
				strDefault, 
				strName,
				intHACode, 
				strHACode,			
				strHACodeNames,
				intOrder,
				LOINC
			FROM @T
		)
			SELECT
				TotalRowCount,
				idfsBaseReference AS KeyId, 
				idfsBaseReference, 
				idfsReferenceType, 
				strDefault, 
				strName,
				intHACode, 
				strHACode,			
				strHACodeNames,
				intOrder,
				LOINC,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec;
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
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
