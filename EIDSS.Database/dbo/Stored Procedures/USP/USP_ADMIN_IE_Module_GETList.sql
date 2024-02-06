
--*************************************************************
-- Name 				:USP_ADMIN_IE_Module_GETList
-- Description			:Returns the top level hierarchies from 
--							trtResourceSets.  These top level hierarchies
--							are known as "Modules" in the interface editor
--          
-- Author               : Mike Kornegay
--
-- Revision History
--	Name			Date		Change Detail
--	Mike Kornegay	6/21/2021	Original
--  Mike Kornegay	11/15/2021	Added idfResourceSet and 
--								and changed default name to use strResourceSetUnique
--
-- Testing code:
/*
	EXEC [dbo].[USP_ADMIN_IE_Module_GETList] 'en'
	EXEC [dbo].[USP_ADMIN_IE_Module_GETList] 'ar-JO'
	EXEC [dbo].[USP_ADMIN_IE_Module_GETList] 'ru'
	EXEC [dbo].[USP_ADMIN_IE_Module_GETList] 'ka-GE'
	EXEC [dbo].[USP_ADMIN_IE_Module_GETList] 'az-Latn-AZ'
*/
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ADMIN_IE_Module_GETList]
(
	@langId NVARCHAR(24)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT 
					RS.strResourceSet AS DefaultName,
					RH.idfResourceHierarchy,
					RH.idfsResourceSet,
					RH.ResourceSetNode.ToString() AS ResourceSetNode,
					RH.ResourceSetNode.GetLevel() AS [Level],
					ISNULL(RST.strTextString, RS.strResourceSet) AS TranslatedName
					
		FROM		dbo.trtResourceSetHierarchy RH
		INNER JOIN	dbo.trtResourceSet RS ON RS.idfsResourceSet = RH.idfsResourceSet
		LEFT JOIN	dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RS.idfsResourceSet
					AND RST.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)
		WHERE		RH.ResourceSetNode.GetLevel() = 1

		ORDER BY 
			RS.idfsResourceSet
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
