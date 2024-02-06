
--=====================================================================================================
-- Author:		Original Author Unknown
-- Description:	Returns two (2) result sets.
--
-- 1) Selects detail data for statistic types
-- 2) the return code and message.
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		10/12/2018  Initial Release
-- Ricky Moss		12/20/2018	Removed return codes
-- Doug Albanese	06/07/2021	Removed idfs values from Advanced Search
-- Doug Albanese	06/07/2021	Use case calls for A - Z ordering on 'Default' column
-- Doug Albanese	08/02/2021	Now I'm being asked to sort by National Value
-- Doug Albanese	08/03/2021	Removed unneccesarry ordering, and added a CTE expression to cover for a second column of sorting on intOrder
-- Doug Albanese	08/09/2021	Added comment to denote which reference type belonged to 19000076
-- Doug Albanese	08/12/2021	Sort column for strStatisticalAreaType, was misspelled and causing sort issues on that field
-- LAMONT MITCHELL	3/30 NEW  COPIED FROM PREVIOUS . ADDED FILTER idfsStatisticDataType
-- Test Code:
-- EXEC USP_REF_STATISTICDATATYPE_GETList 'en-us'
-- 
--=====================================================================================================

CREATE PROCEDURE [dbo].[USP_REF_STATISTICDATATYPE_BY_ STATISTICALDATATYPE_GETList]
(
	 @langID		NVARCHAR(50)
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strName' 
	,@sortOrder NVARCHAR(4) = 'asc'
	,@idfsStatisticDataType BIGINT 
)
AS
BEGIN
BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsStatisticDataType bigint, 
			idfsReferenceType bigint,
			strParameterType nvarchar(2000),
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			blnStatisticalAgeGroup bit,
			idfsStatisticPeriodType bigint,
			strStatisticPeriodType nvarchar(2000),
			idfsStatisticAreaType bigint,
			strStatisticalAreaType nvarchar(2000)
			)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		IF( @advancedSearch IS NOT NULL )
			INSERT INTO @T
			SELECT
				sdt.[idfsStatisticDataType],
				sdt.[idfsReferenceType],
				sdtpt.[name] as strParameterType,
				sdtbr.strDefault as [strDefault],
				sdtbr.[name] as [strName],
				ISNULL(sdt.[blnRelatedWithAgeGroup], 0) as [blnStatisticalAgeGroup],  -- statistical age group info needed per use case SAUC49
				sdt.[idfsStatisticPeriodType],
				sptbr.[name] as [strStatisticPeriodType], 
				sdt.[idfsStatisticAreaType],
				satbr.[name] as [strStatisticalAreaType]
			FROM [trtStatisticDataType] as sdt -- Statistic Data Type
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000090) sdtbr -- Statistic Data Type base reference
			ON sdt.idfsStatisticDataType = sdtbr.idfsReference
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000076) sdtpt -- Reference Type Name
			ON sdt.idfsReferenceType = sdtpt.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000091) sptbr -- Statistic Period Type
			ON sdt.idfsStatisticPeriodType = sptbr.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000089) satbr -- Statistic Area Type
			ON sdt.idfsStatisticAreaType = satbr.idfsReference
			WHERE sdt.[intRowStatus] = 0 AND  idfsStatisticDataType = @idfsStatisticDataType
			
		ELSE
			INSERT INTO @T		
			SELECT
				sdt.[idfsStatisticDataType],
				sdt.[idfsReferenceType],
				sdtpt.[name] as strParameterType,
				sdtbr.strDefault as [strDefault],
				sdtbr.[name] as [strName],
				ISNULL(sdt.[blnRelatedWithAgeGroup], 0) as [blnStatisticalAgeGroup],  -- statistical age group info needed per use case SAUC49
				sdt.[idfsStatisticPeriodType],
				sptbr.[name] as [strStatisticPeriodType], 
				sdt.[idfsStatisticAreaType],
				satbr.[name] as [strStatisticalAreaType]
			FROM [trtStatisticDataType] as sdt -- Statistic Data Type
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000090) sdtbr -- Statistic Data Type base reference
			ON sdt.idfsStatisticDataType = sdtbr.idfsReference
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000076) sdtpt  -- Reference Type Name
			ON sdt.idfsReferenceType = sdtpt.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000091) sptbr -- Statistic Period Type
			ON sdt.idfsStatisticPeriodType = sptbr.idfsReference
			INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000089) satbr -- Statistic Area Type
			ON sdt.idfsStatisticAreaType = satbr.idfsReference
			WHERE sdt.[intRowStatus] = 0;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsStatisticDataType' AND @SortOrder = 'asc' THEN idfsStatisticDataType END ASC,
				CASE WHEN @sortColumn = 'idfsStatisticDataType' AND @SortOrder = 'desc' THEN idfsStatisticDataType END DESC,
				CASE WHEN @sortColumn = 'idfsReferenceType' AND @SortOrder = 'asc' THEN idfsReferenceType END ASC,
				CASE WHEN @sortColumn = 'idfsReferenceType' AND @SortOrder = 'desc' THEN idfsReferenceType END DESC,
				CASE WHEN @sortColumn = 'strParameterType' AND @SortOrder = 'asc' THEN strParameterType END ASC,
				CASE WHEN @sortColumn = 'strParameterType' AND @SortOrder = 'desc' THEN strParameterType END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'blnStatisticalAgeGroup' AND @SortOrder = 'asc' THEN blnStatisticalAgeGroup END ASC,
				CASE WHEN @sortColumn = 'blnStatisticalAgeGroup' AND @SortOrder = 'desc' THEN blnStatisticalAgeGroup END DESC,
				CASE WHEN @sortColumn = 'idfsStatisticPeriodType' AND @SortOrder = 'asc' THEN idfsStatisticPeriodType END ASC,
				CASE WHEN @sortColumn = 'idfsStatisticPeriodType' AND @SortOrder = 'desc' THEN idfsStatisticPeriodType END DESC,
				CASE WHEN @sortColumn = 'strStatisticPeriodType' AND @SortOrder = 'asc' THEN strStatisticPeriodType END ASC,
				CASE WHEN @sortColumn = 'strStatisticPeriodType' AND @SortOrder = 'desc' THEN strStatisticPeriodType END DESC,
				CASE WHEN @sortColumn = 'idfsStatisticAreaType' AND @SortOrder = 'asc' THEN idfsStatisticAreaType END ASC,
				CASE WHEN @sortColumn = 'idfsStatisticAreaType' AND @SortOrder = 'desc' THEN idfsStatisticAreaType END DESC,
				CASE WHEN @sortColumn = 'strStatisticAreaType' AND @SortOrder = 'asc' THEN strStatisticalAreaType END ASC,
				CASE WHEN @sortColumn = 'strStatisticAreaType' AND @SortOrder = 'desc' THEN strStatisticalAreaType END DESC
				,IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfsStatisticDataType,
				idfsReferenceType,
				strParameterType,
				strdefault,
				strName,
				blnStatisticalAgeGroup,
				idfsStatisticPeriodType,
				strStatisticPeriodType,
				idfsStatisticAreaType,
				strStatisticalAreaType
			FROM @T
		)
			SELECT
				TotalRowCount,
				idfsStatisticDataType,
				idfsReferenceType,
				strParameterType,
				strdefault,
				strName,
				blnStatisticalAgeGroup,
				idfsStatisticPeriodType,
				strStatisticPeriodType,
				idfsStatisticAreaType,
				strStatisticalAreaType,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	
END TRY
BEGIN CATCH
	THROW
END CATCH
END
