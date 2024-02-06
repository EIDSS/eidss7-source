--*************************************************************
-- Name 				:USP_ADMIN_IE_Resource_GETList
-- Description			:Returns all the resources that belong to a 
--						 given resource set.  These are the resources that
--						 can be edited in the interface editor.
--          
-- Author               : Mike Kornegay
--
-- Revision History
--	Name			Date		Change Detail
--	Mike Kornegay	6/22/2021	Original
--	Mike Kornegay	6/29/2021	Add parameterized sorting
--  Mike Kornegay	7/5/2021	Add search functionality
--	Mike Kornegay	7/21/2021	Add the all modules functionality
--  Mike Kornegay	9/1/2021	Update to remove idfsResourceType from trtResourceSetToResource
--	Mike Kornegay	10/15/2021	Added TotalRowCount, TotalPages, and CurrentPage and fixed paging
--  Mike Kornegay   10/27/2021  Filter out softdeleted resources (intRowStatus = 1)
--  Leo Tracchia	11/14/2022  added return for module name on search and sorting on additional fields (DevOps #4894)
-- Testing code:
/*
	EXEC USP_ADMIN_IE_Resource_GETList 40, 'en-US'
	EXEC USP_ADMIN_IE_Resource_GETList 40, 'ar-JO'
	EXEC USP_ADMIN_IE_Resource_GETList 40, 'ru'
	EXEC USP_ADMIN_IE_Resource_GETList 40, 'en-US'
	EXEC USP_ADMIN_IE_Resource_GETList 40, 'az-Latn-AZ'
*/
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ADMIN_IE_Resource_GETList]
(
@moduleId bigint = null
	,@idfsResourceSet BIGINT = NULL
	,@langId NVARCHAR(10)
	,@sortColumn NVARCHAR(30) = 'strResourceName' 
	,@sortOrder NVARCHAR(4) = 'asc'
	,@searchString NVARCHAR(100) = NULL
	,@includedTypes NVARCHAR(2000) = NULL
	,@allModules BIT = NULL
	,@isRequired BIT = NULL
	,@isHidden BIT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE	@InterfaceEditorTypes TABLE (BaseReferenceID bigint)

		IF @includedTypes IS NOT NULL
			INSERT @InterfaceEditorTypes SELECT CONVERT(bigint, value) FROM string_split(@includedTypes, ',')
		ELSE 
			INSERT @InterfaceEditorTypes SELECT idfsReference FROM dbo.FN_GBL_Reference_GETList(@langId,19000531)

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsResourceSet bigint,
			strResourceSet nvarchar(2000),
			ModuleId bigint,
			ModuleName NVARCHAR(2000),
			idfsResource bigint,
			strResourceName nvarchar(512),
			idfsResourceType bigint,
			strResourceType nvarchar(2000),
			BaseReferenceId bigint,
			NationalName nvarchar(2000),
			LanguageId bigint,
			isHidden bit,
			isRequired bit
		)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		INSERT INTO @t
		SELECT 
					RSTR.idfsResourceSet,
					ISNULL(RSL.strTextString, RS.strResourceSet) AS strResourceSet,
					RSP.idfsResourceSet AS ModuleId,
					RSP.strResourceSet AS ModuleName,
					RSTR.idfsResource,
					R.strResourceName,
					R.idfsResourceType,
					RT.strDefault AS strResourceType,
					RT.idfsBaseReference AS BaseReferenceId,
					ISNULL(RL.strResourceString, R.strResourceName) AS NationalName,
					ISNULL(RL.idfsLanguage, dbo.FN_GBL_LanguageCode_GET(@langId)) as LanguageId,
					RSTR.isHidden,
					RSTR.isRequired
		FROM		dbo.trtResourceSetToResource RSTR
		INNER JOIN	dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
		INNER JOIN	dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
		INNER JOIN	dbo.trtBaseReference RT ON RT.idfsBaseReference = R.idfsResourceType
		INNER JOIN	dbo.trtResourceSetHierarchy RSH ON RSH.idfsResourceSet = RS.idfsResourceSet
		INNER JOIN	dbo.trtResourceSetHierarchy RSHP ON RSHP.ResourceSetNode = RSH.ResourceSetNode.GetAncestor(RSH.ResourceSetNode.GetLevel() - 1)
		INNER JOIN  dbo.trtResourceSet RSP ON RSP.idfsResourceSet = RSHP.idfsResourceSet
		LEFT JOIN	dbo.trtResourceTranslation  AS RL --WITH(INDEX=XPKtrtResourceTranslation)
					ON RL.idfsResource = RSTR.idfsResource
					AND RL.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)
		LEFT JOIN	dbo.trtResourceSetTranslation  AS RSL 
					ON RSL.idfsResourceSet = RSTR.idfsResourceSet
					AND RSL.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)
		
		WHERE		RS.idfsResourceSet = IIF(@allModules = 1, RS.idfsResourceSet, ISNULL(@idfsResourceSet, RS.idfsResourceSet))

		AND			(RSP.idfsResourceSet = @moduleId or @moduleId is null)

		AND			(R.strResourceName LIKE IIF(@searchString IS NOT NULL, '%' + @searchString + '%', R.strResourceName)
					OR ISNULL(RL.strResourceString, R.strResourceName) LIKE IIF(@searchString IS NOT NULL, '%' + @searchString + '%', ISNULL(RL.strResourceString, R.strResourceName)))
		AND			RSTR.isHidden = ISNULL(@isHidden, RSTR.isHidden)
		AND			RSTR.isRequired = ISNULL(@isRequired, RSTR.isRequired)
        AND         R.intRowStatus = 0
		AND			EXISTS (SELECT * FROM @InterfaceEditorTypes t
						WHERE (RT.idfsBaseReference = t.BaseReferenceID))
		;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY
					CASE WHEN @sortOrder = 'asc' THEN 
						CASE 
							WHEN @sortColumn = 'strResourceName' THEN  [strResourceName]
							WHEN @sortColumn = 'NationalName' THEN [NationalName]
							WHEN @sortColumn = 'ModuleName' THEN [ModuleName]
							WHEN @sortColumn = 'StrResourceSet' THEN [strResourceSet]							
						END
					END ASC,
					CASE WHEN @sortOrder = 'desc' THEN 
						CASE 
							WHEN @sortColumn = 'strResourceName' THEN  [strResourceName]
							WHEN @sortColumn = 'NationalName' THEN [NationalName]
							WHEN @sortColumn = 'ModuleName' THEN [ModuleName]
							WHEN @sortColumn = 'StrResourceSet' THEN [strResourceSet]							
						END
					END DESC

		) AS ROWNUM,
			COUNT(*) OVER () AS TotalRowCount, 
			idfsResourceSet,
			strResourceSet,
			ModuleId,
			ModuleName,
			idfsResource,
			strResourceName,
			idfsResourceType,
			strResourceType,
			BaseReferenceId,
			NationalName,
			LanguageId,
			isHidden,
			isRequired
			FROM @t
		)
		SELECT 
			TotalRowCount,
			idfsResourceSet,
			strResourceSet,
			ModuleId,
			ModuleName,
			idfsResource,
			strResourceName,
			idfsResourceType,
			strResourceType,
			BaseReferenceId,
			NationalName,
			LanguageId,
			isHidden,
			isRequired,
			TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
			CurrentPage = @pageNo
		FROM CTEResults
		WHERE ROWNUM > @firstRec AND ROWNUM < @lastRec
		
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
