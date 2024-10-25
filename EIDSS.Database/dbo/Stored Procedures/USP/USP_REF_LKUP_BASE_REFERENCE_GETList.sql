-- ================================================================================================
-- Name: USP_REF_LKUP_BASE_REFERENCE_GETList
--
-- Description:	Get the base reference records for drop down lists.
--
-- Author: Stephen Long
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		02/01/2023 Initial relase to search without HA codes and names; only the name 
--                             whether default or national value; depending on what is present.
-- Stephen Long     02/27/2023 Added Key Id.
--
/*

exec USP_REF_LKUP_BASE_REFERENCE_GETList 19000147, 'en-US', @PageSize=200
exec USP_REF_LKUP_BASE_REFERENCE_GETList 19000076, 'en-US', @PageSize=200

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_LKUP_BASE_REFERENCE_GETList]
	 @idfsReferenceType	   BIGINT
	,@langID			   NVARCHAR(50)
	,@advancedSearch	   NVARCHAR(100) = NULL
	,@pageNo			   INT = 1
	,@pageSize			   INT = 10 
	,@sortColumn		   NVARCHAR(30) = 'strName' 
	,@sortOrder			   NVARCHAR(4) = 'ASC'

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
			SET @advancedSearch = REPLACE(@advancedSearch, '%', '[%]');
			SET @advancedSearch = REPLACE(@advancedSearch, '_', '[_]');

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
				AND (	snt.strTextString LIKE '%' + @advancedSearch + '%' collate Cyrillic_General_CI_AS
						OR	(	snt.strTextString IS NULL
								AND br.strDefault LIKE '%' + @advancedSearch + '%' collate Cyrillic_General_CI_AS
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
				CASE WHEN @sortColumn = 'idfsBaseReference' AND @SortOrder = 'asc' THEN idfsBaseReference END ASC,
				CASE WHEN @sortColumn = 'idfsBaseReference' AND @SortOrder = 'desc' THEN idfsBaseReference END DESC,
				CASE WHEN @sortColumn = 'idfsReferenceType' AND @SortOrder = 'asc' THEN idfsReferenceType END ASC,
				CASE WHEN @sortColumn = 'idfsReferenceType' AND @SortOrder = 'desc' THEN idfsReferenceType END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'asc' THEN intHACode END ASC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'desc' THEN intHACode END DESC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'asc' THEN strHACode END ASC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'desc' THEN strHACode END DESC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'asc' THEN strHACodeNames END ASC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'desc' THEN strHACodeNames END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC,
				CASE WHEN @sortColumn = 'LOINC' AND @SortOrder = 'asc' THEN LOINC END ASC,
				CASE WHEN @sortColumn = 'LOINC' AND @SortOrder = 'desc' THEN LOINC END DESC
				,IIF( @sortColumn = 'intOrder',strName,cast(idfsBaseReference as nvarchar(20))) ASC
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