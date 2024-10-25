-- =======================================================================================================================================
-- Name: USP_REF_SearchDuplicates_GetList
-- Description: Gets a list of reference items, for checking against duplicate entries. Filtering of all characters, except alpha, numeric, and spaces.
-- Name				Date		Change Detail
-- Doug Albanese	9/16/2020	Initial release
-- Doug Albanese	9/30/2020	Added fields for reference id and type
-- =======================================================================================================================================

CREATE PROCEDURE [dbo].[USP_REF_SearchDuplicates_GetList] 
	@LangId					NVARCHAR(50),
	@idfsBaseReferenceType	BIGINT,
	@strDefault				NVARCHAR(200)
AS
BEGIN

	DECLARE	@returnCode		INT = 0;
	DECLARE @returnMsg		NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @records		INT

	BEGIN TRY
		SELECT
			DISTINCT 
			idfsBaseReference,
			idfsReferenceType,
			strDefault, 
			AlphaOnly=[dbo].FN_GBL_RemoveNonAlphaCharacters(strDefault,3,1)
		FROM 
			trtBaseReference
		WHERE
			idfsReferenceType = @idfsBaseReferenceType AND
			[dbo].FN_GBL_RemoveNonAlphaCharacters(strDefault,3,1) = [dbo].FN_GBL_RemoveNonAlphaCharacters(@strDefault,3,1)
		

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		Throw;
	END CATCH
END
