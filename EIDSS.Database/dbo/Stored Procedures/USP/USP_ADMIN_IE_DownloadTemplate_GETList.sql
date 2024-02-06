--*************************************************************
-- Name 				:USP_ADMIN_IE_DownloadTemplate_GETList
-- Description			:Returns all the resources that can be 
--						 translated when uploading a new language
--						 template by module and section.
--          
-- Author               : Mike Kornegay
--
-- Revision History
--	Name			Date		Change Detail
--	Mike Kornegay	08/24/2021	Original
--  Mike Kornegay	09/01/2021	Update to remove idfsResourceType from trtResourceSetToResource
--  Mike Kornegay	05/02/2023	Fix stored proc to include module and section.
--
-- Testing code:
/*
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'en-US'
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'ar-JO'
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'ru'
	EXEC USP_ADMIN_IE_DownloadTemplate_GETList 'az-Latn-AZ'
*/
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ADMIN_IE_DownloadTemplate_GETList]
(
	@langId NVARCHAR(10)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT 
					RSTR.idfsResourceSet AS SetId,
					RS.strResourceSet AS SectionName,
					RSP.idfsResourceSet AS ModuleId,
					RSP.strResourceSet AS ModuleName,
					RSTR.idfsResource AS ResourceId,
					R.strResourceName AS ResourceDefaultName,
					R.idfsResourceType AS ResourceTypeId,
					RT.strDefault AS ResourceType
					
		FROM		dbo.trtResourceSetToResource RSTR
		INNER JOIN	dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
		INNER JOIN	dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
		INNER JOIN	dbo.trtBaseReference RT ON RT.idfsBaseReference = R.idfsResourceType
		INNER JOIN	dbo.trtResourceSetHierarchy RSH ON RSH.idfsResourceSet = RS.idfsResourceSet
		INNER JOIN	dbo.trtResourceSetHierarchy RSHP ON RSHP.ResourceSetNode = RSH.ResourceSetNode.GetAncestor(RSH.ResourceSetNode.GetLevel() - 1)
		INNER JOIN  dbo.trtResourceSet RSP ON RSP.idfsResourceSet = RSHP.idfsResourceSet
        WHERE         R.intRowStatus = 0
		ORDER BY
				RSP.strResourceSet ASC, RS.strResourceSet ASC, R.strResourceName ASC, RT.strDefault ASC
		;	
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
