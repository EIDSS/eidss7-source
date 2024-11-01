SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Name: USP_EMPLOYEEGROUP_GETLIST
-- Description: 
-- Author: Ricky Moss
--
-- History of changes
--
-- Name					Date			Change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			11/25/2019		Initial Release
-- Ricky Moss			12/03/2019		Added Pagination
-- Ricky Moss			12/11/2019		Added idfsEmployeeGroupName
-- Ann Xiong			05/18/2021		Added paging
-- Mandar Kularni		07/01/2021		Replaced parameter @user with @idfsSite
-- Ann Xiong            03/01/2023	    Added intRowStaus = 0 in tlbEmployeeGroup eg
-- Olga Mirnaya			11/08/2023		Removed filtration by site
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_GETLIST 'Human', NULL, 'en', 1, 1, 10, 'strDefault' , 'asc'
-- EXEC USP_ADMIN_EMPLOYEEGROUP_GETLIST 'La', null, 'ru', 871, 1, 10, 'strDefault' , 'asc'
-- ===============================================================================================================
CREATE or ALTER PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_GETLIST]
(

		@strName NVARCHAR(500),
		@strDescription NVARCHAR(1000),
		@langId NVARCHAR(50)
		,@idfsSite BIGINT
		,@pageNo INT = 1
		,@pageSize INT = 10 
		,@sortColumn NVARCHAR(30) = 'strDefault' 
		,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfEmployeeGroup bigint,
			idfsEmployeeGroupName bigint,
			strDefault nvarchar(2000), 
			strName nvarchar(2000),
			strDescription nvarchar(2000) 
			)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT	eg.idfEmployeeGroup, 
				eg.idfsEmployeeGroupName, 
				egbr.strDefault, 
				egbr.[name] as strName, 
				eg.strDescription 
		FROM	tlbEmployeeGroup eg
				JOIN FN_GBL_ReferenceRepair(@langId, 19000022) egbr
					ON eg.idfsEmployeeGroupName = egbr.idfsReference
		WHERE	ISNULL(strDefault, '') LIKE IIF(@strName IS NOT NULL, '%' + @strName + '%', ISNULL(strDefault,'')) 
		AND		ISNULL(strDescription, '') LIKE IIF(@strDescription IS NOT NULL, '%' + @strDescription + '%', ISNULL(strDescription,''))
		AND eg.intRowStatus =0 and egbr.intRowStatus=0 and eg.idfsEmployeeGroupName != -506 and eg.idfEmployeeGroup != -506 and eg.idfEmployeeGroup != -1
		--AND		eg.idfsSite =  @idfsSite
		--AND		(eg.idfsSite =  @idfsSite or @idfsSite IS NULL)

		ORDER BY strDefault 		
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfEmployeeGroup' AND @SortOrder = 'asc' THEN idfEmployeeGroup END ASC,
				CASE WHEN @sortColumn = 'idfEmployeeGroup' AND @SortOrder = 'desc' THEN idfEmployeeGroup END DESC,
				CASE WHEN @sortColumn = 'idfsEmployeeGroupName' AND @SortOrder = 'asc' THEN idfsEmployeeGroupName END ASC,
				CASE WHEN @sortColumn = 'idfsEmployeeGroupName' AND @SortOrder = 'desc' THEN idfsEmployeeGroupName END DESC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strDescription' AND @SortOrder = 'asc' THEN strDescription END ASC,
				CASE WHEN @sortColumn = 'strDescription' AND @SortOrder = 'desc' THEN strDescription END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfEmployeeGroup,
				idfsEmployeeGroupName,
				strDefault,
				strName,
				strDescription
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfEmployeeGroup,
				idfsEmployeeGroupName,
				strDefault,
				strName,
				strDescription,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
