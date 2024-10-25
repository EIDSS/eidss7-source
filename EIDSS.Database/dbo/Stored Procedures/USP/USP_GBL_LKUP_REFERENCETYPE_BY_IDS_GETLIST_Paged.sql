



--=============================================================================================================================================+++++++++++
-- NAME: USP_GBL_LKUP_REFERENCETYPE_GETLIST
-- DESCRIPTION: Returns a list of base reference types by Ids acan pass in Multiple
-- AUTHOR: Lamont Mitchell
--
-- HISTORY OF CHANGE:
-- Name				Date				Change Description
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- Lamont Mitchell		12/20/2019			Initial Release
-- Lamont Mitchell		04/06/2020			Added intHaCode
-- Lamont Mitchell		4/15/2020			Switched posistions in function wtih IntHaCode and Input Parameter @IntHaCode :"
											--AND intHaCode in  (SELECT value from String_Split([dbo].[FN_GBL_HACode_ToCSV](@languageId,@intHACode),','))"
-- Mike Kornegay		9/8/2021			Add condition to exclude base reference items where the strDefault is null
--
-- EXEC [USP_GBL_LKUP_REFERENCETYPE_BY_IDS_GETLIST_Paged] 'en'
--=============================================================================================================================================+++++++++++
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_REFERENCETYPE_BY_IDS_GETLIST_Paged]
(
	@referenceTypeIds NVARCHAR(MAX),
	@languageId NVARCHAR(50),
	@intHACode INT = NULL,
	@PaginationSet INT = 1,
	@PageSize INT = 10,
	@MaxPagesPerFetch INT = 10 ,
	@Term NVARCHAR(MAX) = NULL
)
AS
BEGIN
	BEGIN TRY
	DECLARE @TotalRecords INT;
	DECLARE @SearchString NVARCHAR(MAX) = @Term + '%';

	SELECT 
		@TotalRecords = COUNT(*) 
	FROM dbo.trtBaseReference br
	JOIN dbo.trtReferenceType RT ON RT.idfsReferenceType = br.idfsReferenceType 
	WHERE	br.idfsReferenceType IN (SELECT * FROM STRING_SPLIT(@referenceTypeIds,','))
	AND RT.intRowStatus=0 AND br.intRowStatus = 0
	AND (@intHaCode IN  (SELECT value FROM STRING_SPLIT([dbo].[FN_GBL_HACode_ToCSV](@languageId,intHACode),',')) OR @intHACode IS NULL)
	AND (br.strDefault LIKE @SearchString OR (@Term IS NULL));
		 
	SELECT 
		br.idfsBaseReference AS BaseReferenceId, 
		br.idfsReferenceType AS ReferenceTypeId, 
		strDefault AS [Default], 
		--NULL AS strName, 
		(CASE WHEN snt.strTextString IS NULL THEN strDefault ELSE snt.strTextString END) AS [Name], 
		intHACode,
		intOrder,
		@TotalRecords AS 'TotalRecords' 
	FROM dbo.trtBaseReference br
	JOIN dbo.trtReferenceType RT ON RT.idfsReferenceType = br.idfsReferenceType 
	LEFT JOIN dbo.trtStringNameTranslation AS snt ON snt.idfsBaseReference = br.idfsBaseReference 
		AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@languageId) 
			AND snt.intRowStatus = 0
	WHERE br.idfsReferenceType IN (SELECT * FROM STRING_SPLIT(@referenceTypeIds,','))
	AND RT.intRowStatus=0 AND br.intRowStatus = 0
	AND br.strDefault IS NOT NULL
	AND (@intHaCode IN  (SELECT value FROM STRING_SPLIT([dbo].[FN_GBL_HACode_ToCSV](@languageId,intHACode),',')) OR @intHACode IS NULL) 	
	AND (br.strDefault LIKE  +''+ @Term + '%' OR (@Term IS NULL))
	ORDER BY 
		br.strDefault ASC OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS

	FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
