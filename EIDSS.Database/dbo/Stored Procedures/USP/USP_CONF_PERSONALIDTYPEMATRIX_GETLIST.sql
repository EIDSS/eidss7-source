
-- ================================================================================================
-- Name: USP_CONF_PERSONALIDTYPEMATRIX_GETLIST
--
-- Description: RETURNS A LIST OF PERSONAL IDENTIFICATION TYPES WITH PROPERTIES
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Ricky Moss         07/10/2019 Initial Release
-- Ricky Moss         08/07/2019 Added Order By
-- Stephen Long       12/26/2019 Replaced 'en' with @LangID on reference call.
-- Ann Xiong		  12/26/2019 Modified to return all values defined in Reference Type: Personal ID Type even when this referent type has NULL FieldType or NULL Length.
--
-- USP_CONF_PERSONALIDTYPEMATRIX_GETLIST 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_PERSONALIDTYPEMATRIX_GETLIST] (
     @LangID NVARCHAR(50)
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
			idfPersonalIDType bigint,
			strPersonalIDType nvarchar(2000),
			strFieldType nvarchar(2000),
			[Length] int,
			intOrder int
		)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1);

		WITH PersonalIDTypes
		AS (
			SELECT distinct
				br.idfsReference AS idfPersonalIDType,
				br.name AS strPersonalIDType,
				(
					SELECT CAST(varValue AS NVARCHAR)
					FROM dbo.trtBaseReferenceAttribute
					WHERE idfAttributeType = 1
						AND idfsBaseReference = br.idfsReference
					) AS strFieldType,
				(
					SELECT CAST(varValue AS INT)
					FROM dbo.trtBaseReferenceAttribute
					WHERE idfAttributeType = 2
						AND idfsBaseReference = br.idfsReference
					) AS [Length],
				(
					SELECT CAST(varValue AS INT)
					FROM dbo.trtBaseReferenceAttribute
					WHERE idfAttributeType = 3
						AND idfsBaseReference = br.idfsReference
					) AS [intOrder]
			FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000148) br
			INNER JOIN trtBaseReferenceAttribute bra on bra.idfsBaseReference = br.idfsReference
			)
		INSERT INTO @t
		SELECT idfPersonalIDType,
			strPersonalIDType,
			strFieldType,
			Length,
			intOrder
		FROM PersonalIDTypes
		ORDER BY intOrder, strPersonalIDType;
		
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfPersonalIDType' AND @SortOrder = 'asc' THEN idfPersonalIDType END ASC,
				CASE WHEN @sortColumn = 'idfPersonalIDType' AND @SortOrder = 'desc' THEN idfPersonalIDType END DESC,
				CASE WHEN @sortColumn = 'strPersonalIDType' AND @SortOrder = 'asc' THEN strPersonalIDType END ASC,
				CASE WHEN @sortColumn = 'strPersonalIDType' AND @SortOrder = 'desc' THEN strPersonalIDType END DESC,
				CASE WHEN @sortColumn = 'strFieldType' AND @SortOrder = 'asc' THEN strFieldType END ASC,
				CASE WHEN @sortColumn = 'strFieldType' AND @SortOrder = 'desc' THEN strFieldType END DESC,
				CASE WHEN @sortColumn = 'Length' AND @SortOrder = 'asc' THEN Length END ASC,
				CASE WHEN @sortColumn = 'Length' AND @SortOrder = 'desc' THEN Length END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfPersonalIDType,
				strPersonalIDType,
				strFieldType,
				Length, 
				intOrder

			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfPersonalIDType,
				strPersonalIDType,
				strFieldType,
				Length, 
				intOrder,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 


	END TRY


	BEGIN CATCH
		THROW
	END CATCH
END
