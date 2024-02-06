--=================================================================================================
-- Name: USP_REF_VectorSubType_GETList
--
-- Description:	Returns a list of active vector sub-types.
-- 
-- Author: Ricky Moss
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/19/2018 Initial Release
-- Ricky Moss		01/17/2019 Remove return code
-- Ricky Moss		04/10/2020 Reordered base name
-- Stephen Long     04/20/2020 Made vector type nullable to support LUC10 changes.
-- Ricky Moss		05/04/2020 Added Search Capacity
-- Steven Verner	03/22/2021 Added paging
-- Ann Xiong		06/24/2021 Modified to return no record when idfsVectorType is NULL
-- Ann Xiong		07/14/2021  Fixed default sorting order.
-- Ann Xiong	08/05/2021	Updated default sorting order.

-- Test Code:
-- exec USP_REF_VectorSubType_GETList 'en', 9849200000000, 'AM';
-- exec USP_REF_VectorSubType_GETList 'en', 9849270000000, 'an';
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_VectorSubType_GETList] 
(
	 @LangID NVARCHAR(50)
	,@idfsVectorType BIGINT = NULL
	,@strVectorSubType NVARCHAR(50)
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'intOrder' 
	,@sortOrder NVARCHAR(4) = 'asc'	
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsVectorSubType bigint, 
			idfsVectorType bigint,
			idfsVectorSubTypeReferenceType bigint,
			VectorType nvarchar(2000),
			strDefault nvarchar(2000), 
			strName nvarchar(2000),
			strCode nvarchar(4000),
			intOrder int)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		IF( @advancedSearch IS NOT NULL )
			INSERT INTO @T
			SELECT vst.idfsVectorSubType,
				vst.idfsVectorType,
				vstbr.idfsReferenceType AS idfsVectorSubTypeReferenceType,
				vtbr.[name] AS VectorType,
				vstbr.strDefault,
				vstbr.[name] AS strName,
				vst.strCode,
				vstbr.intOrder
			FROM dbo.trtVectorSubType AS vst -- Vector Sub Type (aka Vector Species Type)
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000141) vstbr
				ON vst.idfsVectorSubType = vstbr.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000140) vtbr
				ON vst.idfsVectorType = vtbr.idfsReference
			WHERE vst.intRowStatus = 0
				AND (
					CAST( idfsVectorSubType AS VARCHAR(20)) LIKE '%' + @advancedSearch OR
					CAST( idfsVectorType AS VARCHAR(20)) LIKE '%' + @advancedSearch OR
					CAST( vstbr.idfsReferenceType AS VARCHAR(20)) LIKE '%' + @advancedSearch OR
					vstbr.strDefault LIKE '%' + @advancedSearch + '%' OR 
					vstbr.[name] LIKE '%' + @advancedSearch + '%' OR 
					vst.strCode LIKE '%' + @advancedSearch + '%'
					)
			--ORDER BY vstbr.strDefault
		ELSE IF @strVectorSubType IS NULL
			INSERT INTO @T
			SELECT vst.idfsVectorSubType,
				vst.idfsVectorType,
				vstbr.idfsReferenceType AS idfsVectorSubTypeReferenceType,
				vtbr.[name] AS VectorType,
				vstbr.strDefault,
				vstbr.[name] AS strName,
				vst.strCode,
				vstbr.intOrder
			FROM dbo.trtVectorSubType AS vst -- Vector Sub Type (aka Vector Species Type)
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000141) vstbr
				ON vst.idfsVectorSubType = vstbr.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000140) vtbr
				ON vst.idfsVectorType = vtbr.idfsReference
			WHERE vst.intRowStatus = 0
				AND (
					(vst.idfsVectorType = @idfsVectorType)
					--OR (@idfsVectorType IS NULL)
					)
			--ORDER BY vstbr.strDefault
		ELSE
			INSERT INTO @T
			SELECT vst.idfsVectorSubType,
				vst.idfsVectorType,
				vstbr.idfsReferenceType AS idfsVectorSubTypeReferenceType,
				vtbr.[name] AS VectorType,
				vstbr.strDefault,
				vstbr.[name] AS strName,
				vst.strCode,
				vstbr.intOrder
			FROM dbo.trtVectorSubType AS vst -- Vector Sub Type (aka Vector Species Type)
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000141) vstbr
				ON vst.idfsVectorSubType = vstbr.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000140) vtbr
				ON vst.idfsVectorType = vtbr.idfsReference
			WHERE vst.intRowStatus = 0
				AND (
					(vst.idfsVectorType = @idfsVectorType)
					--OR (@idfsVectorType IS NULL)
					)
				AND (vstbr.strDefault LIKE '%' + @strVectorSubType + '%' OR vstbr.[name] LIKE '%' + @strVectorSubType + '%' OR vst.strCode LIKE '%' + @strVectorSubType + '%')
			--ORDER BY vstbr.strDefault
			;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsVectorSubType' AND @SortOrder = 'asc' THEN idfsVectorSubType END ASC,
				CASE WHEN @sortColumn = 'idfsVectorSubType' AND @SortOrder = 'desc' THEN idfsVectorSubType END DESC,
				CASE WHEN @sortColumn = 'idfsVectorType' AND @SortOrder = 'asc' THEN idfsVectorType END ASC,
				CASE WHEN @sortColumn = 'idfsVectorType' AND @SortOrder = 'desc' THEN idfsVectorType END DESC,
				CASE WHEN @sortColumn = 'idfsVectorSubTypeReferenceType' AND @SortOrder = 'asc' THEN idfsVectorSubTypeReferenceType END ASC,
				CASE WHEN @sortColumn = 'idfsVectorSubTypeReferenceType' AND @SortOrder = 'desc' THEN idfsVectorSubTypeReferenceType END DESC,
				CASE WHEN @sortColumn = 'VectorType' AND @SortOrder = 'asc' THEN VectorType END ASC,
				CASE WHEN @sortColumn = 'VectorType' AND @SortOrder = 'desc' THEN VectorType END DESC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'asc' THEN strCode END ASC,
				CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'desc' THEN strCode END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC
				,IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfsVectorSubType,
				idfsVectorType,
				idfsVectorSubTypeReferenceType,
				VectorType,
				strDefault,
				strName,
				strCode,
				intOrder
			FROM @T
		)
			SELECT
				TotalRowCount,
				idfsVectorSubType,
				idfsVectorType,
				idfsVectorSubTypeReferenceType,
				VectorType,
				strDefault,
				strName,
				strCode,
				intOrder,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 		END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
