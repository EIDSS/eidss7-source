
-- ================================================================================================
-- Name: USP_GBL_Department_GetList
--
-- Description:	Get department list filterable by organization and department identifiers.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Joan Li          05/02/2017 Initial release; based on V6 spDepartment_SelectLookup.
-- Stephen Long     11/19/2018 Renamed for global use; used by multiple modules.
-- Ricky Moss		06/27/2018 Check for active intRowStatus
-- Stephen Long     06/24/2020 Replaced old 6.1 function call fnDepartment.
-- Stephen Long     04/25/2021 Renamed department name to default and national names, and added 
--                             pagination.
-- Stephen Long     06/14/2021 Added order, row action, record count, pages and total row count.
-- Steven Verner	03/04/2022 Modified to use default paging
--
-- Testing Code:
--
-- EXEC USP_GBL_Department_GetList 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_Department_GetList] @LanguageID NVARCHAR(50)
	,@OrganizationID BIGINT = NULL
	,@DepartmentID BIGINT = NULL
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'DepartmentNameNationalValue'
	,@SortOrder NVARCHAR(4) = 'ASC'
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfDepartment bigint,
			idfOrganization bigint,
			DepartmentNameDefaultValue NVARCHAR(255),
			DepartmentNameNationalValue NVARCHAR(255),
			[Order] INT,
			[RowStatus] INT,
			RowAction NVARCHAR(10))
	
		SET @firstRec = (@PageNumber-1)* @pagesize
		SET @lastRec = (@PageNumber*@pageSize+1)

		INSERT INTO @t
		SELECT d.idfDepartment 
			,d.idfOrganization 
			,r.strDefault 
			,ISNULL(s.strTextString, r.strDefault) 
			,r.intOrder 
			,d.intRowStatus 
			,'R' 
		FROM dbo.tlbDepartment d
		LEFT JOIN dbo.trtBaseReference r ON d.idfsDepartmentName = r.idfsBaseReference
		LEFT JOIN dbo.trtStringNameTranslation s ON d.idfsDepartmentName = s.idfsBaseReference
			AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageID)
		WHERE d.intRowStatus = 0
			AND (
				@OrganizationID IS NULL
				OR d.idfOrganization = @OrganizationID
				)
			AND (
				@DepartmentID IS NULL
				OR @DepartmentID = d.idfDepartment
				);
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfDepartment' AND @SortOrder = 'asc' THEN idfDepartment END ASC,
				CASE WHEN @sortColumn = 'idfDepartment' AND @SortOrder = 'desc' THEN idfDepartment END DESC,
				CASE WHEN @sortColumn = 'idfOrganization' AND @SortOrder = 'asc' THEN idfOrganization END ASC,
				CASE WHEN @sortColumn = 'idfOrganization' AND @SortOrder = 'desc' THEN idfOrganization END DESC,
				CASE WHEN @sortColumn = 'DepartmentNameDefaultValue' AND @SortOrder = 'asc' THEN DepartmentNameDefaultValue END ASC,
				CASE WHEN @sortColumn = 'DepartmentNameDefaultValue' AND @SortOrder = 'desc' THEN DepartmentNameDefaultValue END DESC,
				CASE WHEN @sortColumn = 'DepartmentNameNationalValue' AND @SortOrder = 'asc' THEN DepartmentNameNationalValue END ASC,
				CASE WHEN @sortColumn = 'DepartmentNameNationalValue' AND @SortOrder = 'desc' THEN DepartmentNameNationalValue END DESC,
				CASE WHEN @sortColumn = 'Order' AND @SortOrder = 'asc' THEN [Order] END ASC,
				CASE WHEN @sortColumn = 'Order' AND @SortOrder = 'desc' THEN [Order] END DESC,
				CASE WHEN @sortColumn = 'RowStatus' AND @SortOrder = 'asc' THEN RowStatus END ASC,
				CASE WHEN @sortColumn = 'RowStatus' AND @SortOrder = 'desc' THEN RowStatus END DESC,
				CASE WHEN @sortColumn = 'RowAction' AND @SortOrder = 'asc' THEN RowAction END ASC,
				CASE WHEN @sortColumn = 'RowAction' AND @SortOrder = 'desc' THEN RowAction END DESC						
			) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfDepartment,
				idfOrganization,
				DepartmentNameDefaultValue,
				DepartmentNameNationalValue,
				[Order],
				RowStatus,
				RowAction
			FROM @T

		)
			SELECT 
				TotalRowCount, 
				idfDepartment DepartmentID,
				idfOrganization OrganizationID,
				DepartmentNameDefaultValue,
				DepartmentNameNationalValue,
				[Order],
				RowStatus,
				RowAction,
				TotalRowCount RecordCount,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @PageNumber 
			FROM CTEResults
			WHERE RowNum > @firstRec AND RowNum < @lastRec

		--WITH paging
		--AS (
		--	SELECT d.idfDepartment AS DepartmentID
		--		,c = COUNT(*) OVER ()
		--	FROM dbo.tlbDepartment d
		--	LEFT JOIN dbo.trtBaseReference r ON d.idfsDepartmentName = r.idfsBaseReference
		--	LEFT JOIN dbo.trtStringNameTranslation s ON d.idfsDepartmentName = s.idfsBaseReference
		--		AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageID)
		--	ORDER BY CASE 
		--			WHEN @SortColumn = 'DepartmentID'
		--				AND @SortOrder = 'ASC'
		--				THEN d.idfDepartment
		--			END ASC
		--		,CASE 
		--			WHEN @SortColumn = 'DepartmentID'
		--				AND @SortOrder = 'DESC'
		--				THEN d.idfDepartment
		--			END DESC
		--		,CASE 
		--			WHEN @SortColumn = 'DepartmentNameDefaultValue'
		--				AND @SortOrder = 'ASC'
		--				THEN r.strDefault
		--			END ASC
		--		,CASE 
		--			WHEN @SortColumn = 'DepartmentNameDefaultValue'
		--				AND @SortOrder = 'DESC'
		--				THEN r.strDefault
		--			END DESC
		--		,CASE 
		--			WHEN @SortColumn = 'intOrder'
		--				AND @SortOrder = 'ASC'
		--				THEN r.intOrder
		--			END ASC
		--		,CASE 
		--			WHEN @SortColumn = 'intOrder'
		--				AND @SortOrder = 'DESC'
		--				THEN r.intOrder
		--			END DESC
		--		,CASE 
		--			WHEN @SortColumn = 'DepartmentNameNationalValue'
		--				AND @SortOrder = 'ASC'
		--				THEN ISNULL(s.strTextString, r.strDefault)
		--			END ASC
		--		,CASE 
		--			WHEN @SortColumn = 'DepartmentNameNationalValue'
		--				AND @SortOrder = 'DESC'
		--				THEN ISNULL(s.strTextString, r.strDefault)
		--			END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
		--	)
		--SELECT d.idfDepartment AS DepartmentID
		--	,d.idfOrganization AS OrganizationID
		--	,r.strDefault AS DepartmentNameDefaultValue
		--	,ISNULL(s.strTextString, r.strDefault) AS DepartmentNameNationalValue
		--	,r.intOrder AS [Order]
		--	,d.intRowStatus AS RowStatus
		--	,'R' AS RowAction
		--	,c AS RecordCount
		--	,(
		--		SELECT COUNT(idfDepartment)
		--		FROM dbo.tlbDepartment
		--		WHERE intRowStatus = 0
		--		) AS TotalRowCount
		--	,TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
		--	,CurrentPage = @PageNumber
		--FROM dbo.tlbDepartment d
		--INNER JOIN paging ON paging.DepartmentID = d.idfDepartment
		--LEFT JOIN dbo.trtBaseReference r ON d.idfsDepartmentName = r.idfsBaseReference
		--LEFT JOIN dbo.trtStringNameTranslation s ON d.idfsDepartmentName = s.idfsBaseReference
		--	AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageID)
		--WHERE d.intRowStatus = 0
		--	AND (
		--		@OrganizationID IS NULL
		--		OR d.idfOrganization = @OrganizationID
		--		)
		--	AND (
		--		@DepartmentID IS NULL
		--		OR @DepartmentID = d.idfDepartment
		--		);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
