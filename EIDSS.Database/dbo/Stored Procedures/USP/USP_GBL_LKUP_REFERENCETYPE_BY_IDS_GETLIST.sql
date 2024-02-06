
--=============================================================================================================================================+++++++++++
-- NAME: USP_GBL_LKUP_REFERENCETYPE_GETLIST
-- DESCRIPTION: Returns a list of base reference types by Ids acan pass in Multiple
-- AUTHOR: Lamont Mitchell
--
-- HISTORY OF CHANGE:
-- Name				Date				Change Description
/* -------------------------------------------------------------------------------------------------------------------------------------------
-- Lamont Mitchell		12/20/2019			Initial Release
-- Lamont Mitchell		04/06/2020			Added intHaCode
-- Lamont Mitchell		4/15/2020			Switched posistions in function wtih IntHaCode and Input Parameter @IntHaCode :"
											--AND intHaCode in  (SELECT value from String_Split([dbo].[FN_GBL_HACode_ToCSV](@languageId,@intHACode),','))"
 Lamont Mitchell        5/12/2020 		Modified HA CODE replaced Or with AND
 Lamont Mitchell		09/16/2020		add isnull filter
-- EXEC USP_GBL_LKUP_REFERENCETYPE_BY_IDS_GETLIST 'en'
--=============================================================================================================================================+++++++++++
*/
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_REFERENCETYPE_BY_IDS_GETLIST]
(
	@referenceTypeIds NVARCHAR(MAX),
	@languageId NVARCHAR(50),
	@intHACode INT = null
)
AS
BEGIN
	BEGIN TRY
		SELECT br.idfsBaseReference AS idfsBaseReference, 
			br.idfsReferenceType, 
			br.strDefault, 
			NULL AS strName, 
			--(CASE WHEN snt.strTextString IS NULL THEN strDefault ELSE snt.strTextString END) AS strName, 
			br.intHACode, 
			br.intOrder 
		FROM dbo.trtBaseReference br
			JOIN dbo.trtReferenceType ON
				dbo.trtReferenceType.idfsReferenceType = br.idfsReferenceType 
			--LEFT JOIN dbo.trtStringNameTranslation AS snt ON snt.idfsBaseReference = br.idfsBaseReference 
			--	AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@languageId) 
			--		AND snt.intRowStatus = 0
		WHERE dbo.trtReferenceType.idfsReferenceType IN (SELECT * FROM STRING_SPLIT(@referenceTypeIds,','))
			AND dbo.trtReferenceType.intRowStatus=0 
			AND br.intRowStatus = 0
			AND (br.intHaCode IN (SELECT value FROM String_Split([dbo].[FN_GBL_HACode_ToCSV](@languageId,@intHACode),','))
				OR @intHACode IS NULL)
		ORDER BY 
			br.strDefault ASC;

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
