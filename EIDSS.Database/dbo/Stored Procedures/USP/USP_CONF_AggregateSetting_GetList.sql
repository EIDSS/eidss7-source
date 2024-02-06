
/*******************************************************
NAME						: USP_CONF_AggregateSetting_GetList		


Description					: Retreives Entries from [tstAggrSetting] based on Customization Package

Author						: Lamont Mitchell

Revision History
		
			Name							Date				Change Detail
			Lamont Mitchell					11/27/2018			Initial Created
			Lamont Mitchel					1/10/19				Added check for IntrowStatus = 0 in Where Clause
			Steven Verner					5/16/2021			Paging enabled
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_AggregateSetting_GetList]
(	
	 @idfCustomizationPackage			BIGINT
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'idfsAggrCaseType' 
	,@sortOrder NVARCHAR(4) = 'asc'     			
)
AS BEGIN
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	DECLARE @idfsReferenceType			BIGINT ;

	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			 idfsAggrCaseType bigint
			,idfCustomizationPackage bigint
			,idfsStatisticAreaType bigint
			,idfsStatisticPeriodType bigint
		)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T

		SELECT 		
			 [idfsAggrCaseType]
			,[idfCustomizationPackage]
			,[idfsStatisticAreaType]
			,[idfsStatisticPeriodType]
		FROM dbo.[tstAggrSetting]
		WHERE [idfCustomizationPackage] = @idfCustomizationPackage AND  [intRowStatus] =0
		;		
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsAggrCaseType' AND @SortOrder = 'asc' THEN idfsAggrCaseType END ASC,
				CASE WHEN @sortColumn = 'idfsAggrCaseType' AND @SortOrder = 'desc' THEN idfsAggrCaseType END DESC,
				CASE WHEN @sortColumn = 'idfCustomizationPackage' AND @SortOrder = 'asc' THEN idfCustomizationPackage END ASC,
				CASE WHEN @sortColumn = 'idfCustomizationPackage' AND @SortOrder = 'desc' THEN idfCustomizationPackage END DESC,
				CASE WHEN @sortColumn = 'idfsStatisticAreaType' AND @SortOrder = 'asc' THEN idfsStatisticAreaType END ASC,
				CASE WHEN @sortColumn = 'idfsStatisticAreaType' AND @SortOrder = 'desc' THEN idfsStatisticAreaType END DESC,
				CASE WHEN @sortColumn = 'idfsStatisticPeriodType' AND @SortOrder = 'asc' THEN idfsStatisticPeriodType END ASC,
				CASE WHEN @sortColumn = 'idfsStatisticPeriodType' AND @SortOrder = 'desc' THEN idfsStatisticPeriodType END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
			 TotalRowCount
			,idfsAggrCaseType
			,idfCustomizationPackage
			,idfsStatisticAreaType
			,idfsStatisticPeriodType
			FROM @T
		)	
			SELECT
			 TotalRowCount
			,idfsAggrCaseType
			,idfCustomizationPackage
			,idfsStatisticAreaType
			,idfsStatisticPeriodType
			,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
			,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

		END TRY
	BEGIN CATCH
			THROW
	END CATCH
END



