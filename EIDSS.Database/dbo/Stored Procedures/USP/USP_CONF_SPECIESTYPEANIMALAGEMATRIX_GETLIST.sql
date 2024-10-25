-- ===================================================================================================================================
-- NAME: USP_CONF_SPECIESTYPEANIMALAGEMATRIX_GETLIST
-- DESCRIPTION: Returns a list of species types to animal age matrices given a language id
-- AUTHOR: Ricky Moss
-- 
-- REVISION HISTORY
-- Name				Date		Description of change
-- -----------------------------------------------------------------------------------------------------------------------------------
-- Ricky Moss		04/16/2019	Initial Release
-- Ann Xiong        04/12/2021 Added paging
-- Ann Xiong        04/23/2021 Added @idfsSpeciesType
-- Ann Xiong		06/24/2021 Modified to return no record when idfsSpeciesType is NULL
--
-- EXEC USP_CONF_SPECIESTYPEANIMALAGEMATRIX_GETLIST 'ar'
-- ===================================================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SPECIESTYPEANIMALAGEMATRIX_GETLIST]
(
	@langId NVARCHAR(50)
	,@idfsSpeciesType BIGINT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strAnimalType ' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfSpeciesTypeToAnimalAge bigint,
			idfsSpeciesType bigint,
			strSpeciesType nvarchar(2000), 
			idfsAnimalAge bigint,
			strAnimalType nvarchar(2000))
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT 	idfSpeciesTypeToAnimalAge, 
				idfsSpeciesType, 
				sbr.name AS strSpeciesType, 
				idfsAnimalAge, 
				aa.name AS strAnimalType 
		FROM 	trtSpeciesTypeToAnimalAge saa
				JOIN FN_GBL_ReferenceRepair(@langId, 19000086) sbr
				ON saa.idfsSpeciesType = sbr.idfsReference
				JOIN FN_GBL_ReferenceRepair(@langId, 19000005) aa
				ON saa.idfsAnimalAge = aa.idfsReference
		WHERE 	saa.intRowStatus = 0
				AND (
						(saa.idfsSpeciesType = @idfsSpeciesType)
						--OR (@idfsSpeciesType IS NULL)
					)
		ORDER BY aa.name;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfSpeciesTypeToAnimalAge' AND @SortOrder = 'asc' THEN idfSpeciesTypeToAnimalAge END ASC,
				CASE WHEN @sortColumn = 'idfSpeciesTypeToAnimalAge' AND @SortOrder = 'desc' THEN idfSpeciesTypeToAnimalAge END DESC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'asc' THEN idfsSpeciesType END ASC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'desc' THEN idfsSpeciesType END DESC,
				CASE WHEN @sortColumn = 'strSpeciesType' AND @SortOrder = 'asc' THEN strSpeciesType END ASC,
				CASE WHEN @sortColumn = 'strSpeciesType' AND @SortOrder = 'desc' THEN strSpeciesType END DESC,
				CASE WHEN @sortColumn = 'idfsAnimalAge' AND @SortOrder = 'asc' THEN idfsAnimalAge END ASC,
				CASE WHEN @sortColumn = 'idfsAnimalAge' AND @SortOrder = 'desc' THEN idfsAnimalAge END DESC,
				CASE WHEN @sortColumn = 'strAnimalType' AND @SortOrder = 'asc' THEN strAnimalType END ASC,
				CASE WHEN @sortColumn = 'strAnimalType' AND @SortOrder = 'desc' THEN strAnimalType END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfSpeciesTypeToAnimalAge,
				idfsSpeciesType,
				strSpeciesType,
				idfsAnimalAge, 
				strAnimalType
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfSpeciesTypeToAnimalAge,
				idfsSpeciesType,
				strSpeciesType,
				idfsAnimalAge, 
				strAnimalType,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
