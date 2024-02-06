--=====================================================================================================
-- Author:		Original Author Unknown
-- Description:	Returns a list of active sample type references
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		2018/10/24	Initial Reference
-- Ricky Moss		12/13/2018	Removed return code and usp_HACode_GetCheckList Store procedure
-- Ricky Moss		05/06/2020	Orded by English Name
-- Ricky Moss		06/15/2020	Added quick search parameter field
-- Steven Verner	03/22/2021  Added paging.
-- Ann Xiong		07/14/2021  Fixed default sorting order.
-- Ann Xiong		08/05/2021	Updated default sorting order.
-- Mandar Kulkarni	08/09/2021	Updated to return LOINC NUMBER
-- Doug Albanese	11/21/2022	Swapped out FNReferenceRepair for FN_GBL_Repair
-- Doug Albanese	04/17/2023	Add a new paramter for searching against HA Codes
--
-- Test Code:
-- exec USP_REF_SAMPLETYPEREFERENCE_GETList 'en', 'ab';
-- exec USP_REF_SAMPLETYPEREFERENCE_GETList 'en', null;
--=====================================================================================================

CREATE PROCEDURE [dbo].[USP_REF_SampleTypeReference_GetList]
( 
	 @langID				  NVARCHAR(50)
	,@strSearchSampleType	  NVARCHAR(50) 
	,@advancedSearch		  NVARCHAR(100) = NULL
	,@pageNo				  INT = 1
	,@pageSize				  INT = 10 
	,@sortColumn			  NVARCHAR(30) = 'intOrder' 
	,@sortOrder				  NVARCHAR(4) = 'asc'
	,@intHACode				  INT = NULL
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec  INT
		DECLARE @lastRec   INT
		DECLARE @t		   TABLE( 
			idfsSampleType bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000),
			strSampleCode nvarchar(50),
			LOINC_NUMBER nvarchar(255),
			intHACode int,
			strHACode nvarchar(4000),
			strHACodeNames nvarchar(4000),
			intOrder int)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		IF( @advancedSearch IS NOT NULL )
		BEGIN
			INSERT INTO @T
			SELECT * FROM
				(SELECT 
				st.[idfsSampleType],
				stbr.strDefault,
				stbr.name,
				st.[strSampleCode],
				lem.LOINC_NUM AS LOINC_NUMBER,
				stbr.[intHACode],
				dbo.FN_GBL_HACode_ToCSV(@LangID, stbr.[intHACode]) as [strHACode],
				dbo.FN_GBL_HACodeNames_ToCSV(@LangID, stbr.[intHACode]) as [strHACodeNames],
				stbr.[intOrder]
			FROM dbo.[trtSampleType] as st  -- Sample Type	
			INNER JOIN dbo.FN_GBL_Repair(@LangId, 19000087)  as stbr -- Sample Type base reference
				ON st.[idfsSampleType] = stbr.[idfsReference]
			LEFT JOIN dbo.LOINCEidssMapping lem ON lem.idfsBaseReference = st.idfsSampleType
			WHERE st.[intRowStatus] = 0
			) AS S
			WHERE 
				(CAST( idfsSampleType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR
				strDefault LIKE '%'+ @advancedSearch + '%' OR 
				[name] LIKE '%' + @advancedSearch + '%' OR 
				strSampleCode LIKE '%' + @advancedSearch + '%' OR 
				strHACodeNames LIKE '%' + @advancedSearch + '%') 
				AND ((intHACode & @intHACode = @intHACode) OR @intHACode IS NULL)
		END ELSE
		IF @strSearchSampleType IS NULL
		 begin
		   INSERT INTO @T
		   SELECT 
			   st.[idfsSampleType],
			   stbr.strDefault,
			   stbr.name,
			   st.[strSampleCode],
			   LEM.LOINC_NUM AS LOINC_NUMBER,
			   stbr.[intHACode],
			   dbo.FN_GBL_HACode_ToCSV(@LangID, stbr.[intHACode]) as [strHACode],
			   dbo.FN_GBL_HACodeNames_ToCSV(@LangID, stbr.[intHACode]) as [strHACodeNames],
			   stbr.[intOrder]
		   FROM dbo.[trtSampleType] as st  -- Sample Type	
		   INNER JOIN dbo.FN_GBL_Repair(@LangId, 19000087)  as stbr -- Sample Type base reference
			   ON st.[idfsSampleType] = stbr.[idfsReference]
		   LEFT JOIN dbo.LOINCEidssMapping lem ON lem.idfsBaseReference = st.idfsSampleType
		   WHERE st.[intRowStatus] = 0	
			   AND ((intHACode & @intHACode = @intHACode) OR @intHACode IS NULL)
		 end
		ELSE
		 
		 INSERT INTO @T
		 SELECT * FROM
			(SELECT 
			st.[idfsSampleType],
			stbr.strDefault,
			stbr.name,
			st.[strSampleCode],
			LEM.LOINC_NUM AS LOINC_NUMBER,
			stbr.[intHACode],
			dbo.FN_GBL_HACode_ToCSV(@LangID, stbr.[intHACode]) AS [strHACode],
			dbo.FN_GBL_HACodeNames_ToCSV(@LangID, stbr.[intHACode]) AS [strHACodeNames],
			stbr.[intOrder]
		FROM dbo.[trtSampleType] AS st  -- Sample Type	
		INNER JOIN dbo.FN_GBL_Repair(@LangId, 19000087)  AS stbr -- Sample Type base reference
			ON st.[idfsSampleType] = stbr.[idfsReference]
		LEFT JOIN dbo.LOINCEidssMapping lem ON lem.idfsBaseReference = st.idfsSampleType
		WHERE st.[intRowStatus] = 0 
			AND ((intHACode & @intHACode = @intHACode) OR @intHACode IS NULL)
		) AS S
		WHERE strDefault LIKE '%'+ @strSearchSampleType + '%' OR [name] LIKE '%' + @strSearchSampleType + '%' OR strSampleCode LIKE '%' + @strSearchSampleType + '%' OR strHACodeNames LIKE '%' + @strSearchSampleType + '%'
		
		;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'asc' THEN idfsSampleType END ASC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'desc' THEN idfsSampleType END DESC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strSampleCode' AND @SortOrder = 'asc' THEN strSampleCode END ASC,
				CASE WHEN @sortColumn = 'strSampleCode' AND @SortOrder = 'desc' THEN strSampleCode END DESC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'asc' THEN intHACode END ASC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'desc' THEN intHACode END DESC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'asc' THEN strHACode END ASC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'desc' THEN strHACode END DESC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'asc' THEN strHACodeNames END ASC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'desc' THEN strHACodeNames END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC
				,IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfsSampleType, 
				strDefault, 
				strName,
				strSampleCode,
				LOINC_NUMBER,
				intHACode, 
				strHACode,			
				strHACodeNames,
				intOrder
			FROM @T
		)
			SELECT
				TotalRowCount,
				idfsSampleType, 
				strDefault, 
				strName,
				strSampleCode,
				LOINC_NUMBER,
				intHACode, 
				strHACode,			
				strHACodeNames,
				intOrder,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	
END TRY

BEGIN CATCH
	THROW;
END CATCH

END
