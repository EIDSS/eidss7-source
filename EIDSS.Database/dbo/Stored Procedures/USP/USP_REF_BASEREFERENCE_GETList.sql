-- ============================================================================
-- Name: USP_REF_MEASUREREFERENCE_GETList
-- Description:	Get the measure references for reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		02/12/2018 Initial release.
-- Mike Kornegay	03/15/2022 Removed advanced search against idfBaseReference and idfsReferenceType
--							   as this will produce unexpected results for users when searching since fields
--							   are not visible.
-- Doug Albanese	12/01/2022 Added LOINC on the return
--
-- exec USP_REF_BASEREFERENCE_GETList 19000146, 'en'
-- exec USP_REF_BASEREFERENCE_GETList 19000087, 'en'
-- exec USP_REF_BASEREFERENCE_GETList 19000145, 'en', 'Age #10'
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_BASEREFERENCE_GETList]
	 @idfsReferenceType	BIGINT
	,@langID NVARCHAR(50)
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strName' 
	,@sortOrder NVARCHAR(4) = 'asc'

AS
BEGIN	
	BEGIN TRY
		DECLARE @firstRec		 INT
		DECLARE @lastRec		 INT
		DECLARE @t TABLE( 
			idfsBaseReference	 BIGINT, 
			idfsReferenceType	 BIGINT, 
			strDefault			 NVARCHAR(2000), 
			strName				 NVARCHAR(2000),
			intHACode			 INT,
			strHACode			 NVARCHAR(4000),
			strHACodeNames		 NVARCHAR(4000),
			intOrder			 INT,
			LOINC				 NVARCHAR(200)
		 )

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		IF( @advancedSearch IS NOT NULL )
		BEGIN
			INSERT INTO @T
			SELECT * FROM
			(
			   SELECT 
			   br.[idfsBaseReference], 
			   br.[idfsReferenceType], 
			   br.[strDefault], 
			   brs.name AS strName,
			   br.[intHACode], 
			   dbo.FN_GBL_HACode_ToCSV(@LangID,br.[intHACode]) AS strHACode,			
			   dbo.FN_GBL_HACodeNames_ToCSV(@LangID,br.[intHACode]) AS strHACodeNames,
			   br.[intOrder],
			   LCM.LOINC_NUM AS LOINC
			   FROM  dbo.trtBaseReference br
			   JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @idfsReferenceType) brS
			   ON br.idfsBaseReference = brs.idfsReference 
			   LEFT JOIN LOINCEidssMapping LCM
			   on LCM.idfsBaseReference = br.idfsBaseReference
			   WHERE 
				   br.intRowStatus = 0 AND brs.intRowStatus = 0 
				
			) AS S
			WHERE 
				(
				  strDefault LIKE '%' + @advancedSearch + '%' OR
				  strName LIKE '%' + @advancedSearch + '%' OR
				  strHACode LIKE '%' + @advancedSearch + '%' OR 
				  strHACodeNames LIKE '%' + @advancedSearch + '%' 
				)
		END ELSE
			INSERT INTO @T
			SELECT 
				br.[idfsBaseReference], 
				br.[idfsReferenceType], 
				br.[strDefault], 
				brs.name AS strName,
				br.[intHACode], 
				dbo.FN_GBL_HACode_ToCSV(@LangID,br.[intHACode]) AS strHACode,			
				dbo.FN_GBL_HACodeNames_ToCSV(@LangID,br.[intHACode]) AS strHACodeNames,
				br.[intOrder],
				LCM.LOINC_NUM AS LOINC
			FROM  dbo.trtBaseReference br
			JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @idfsReferenceType) brS
			ON br.idfsBaseReference = brs.idfsReference
			LEFT JOIN LOINCEidssMapping LCM
			   on LCM.idfsBaseReference = br.idfsBaseReference
			WHERE br.[idfsReferenceType] = @idfsReferenceType AND br.intRowStatus = 0 AND brs.intRowStatus = 0;

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
				,IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
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
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
