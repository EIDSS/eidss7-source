
--*************************************************************
-- Name 				:USP_ADMIN_IE_Section_GETList
-- Description			:Returns the level 2 hierarchies from 
--							trtResourceSets.  These level 2 hierarchies
--							are known as "Sections" in the interface editor
--          
-- Author               : Mike Kornegay
--
-- Revision History
--	Name			Date		Change Detail
--	Mike Kornegay	6/22/2021	Original
--  Mike Kornegay	11/15/2021	Change where clause to get all descendents, 
--								changed default name to use strResourceSetUnique,
--								and added group by so resource sets are rolled up
--
-- Testing code:
/*
	EXEC USP_ADMIN_IE_Section_GETList '/4/', 'en-US'
	EXEC USP_ADMIN_IE_Section_GETList '/4/', 'ar-JO'
	EXEC USP_ADMIN_IE_Section_GETList '/4/', 'ru'
	EXEC USP_ADMIN_IE_Section_GETList '/4/', 'en-US'
	EXEC USP_ADMIN_IE_Section_GETList '/4/', 'az-Latn-AZ'
*/
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ADMIN_IE_Section_GETList]
(
	@parentNode NVARCHAR(4000),
	@langId NVARCHAR(10)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @parent HIERARCHYID = (SELECT ResourceSetNode FROM dbo.trtResourceSetHierarchy WHERE ResourceSetNode.ToString() = @parentNode)

SELECT 
					RS.strResourceSet AS DefaultName,
					RS.strResourceSetUnique,
					min(RH.idfResourceHierarchy) as idfResourceHierarchy,
					min(RH.ResourceSetNode.ToString()) AS ResourceSetNode,
					@parentNode AS ParentSetNode,
					min(RH.ResourceSetNode.GetLevel()) AS [Level],
					RS.idfsResourceSet,
					ISNULL(RST.strTextString, RS.strResourceSetUnique) AS TranslatedName
					
		FROM		dbo.trtResourceSetHierarchy RH
		INNER JOIN	dbo.trtResourceSet RS ON RS.idfsResourceSet = RH.idfsResourceSet
		LEFT JOIN	dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RS.idfsResourceSet
					AND RST.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)
		WHERE		RH.ResourceSetNode.IsDescendantOf(@parentNode) = 1 
					AND RH.ResourceSetNode.GetLevel() > 1
		GROUP BY	RS.strResourceSet,
					RS.strResourceSetUnique,
					RS.idfsResourceSet,
					ISNULL(RST.strTextString, RS.strResourceSetUnique)
		ORDER BY 
			ISNULL(RST.strTextString, RS.strResourceSetUnique)
		
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
