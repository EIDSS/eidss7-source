

-- ================================================================================================
-- Name: USSP_GBL_BaseReference_WildcardSearch
-- Description: Performs a wild card search, based off the "name" of the idfsBasereference id.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	01/20/2021	Initial release for new API.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_BaseReference_WildcardSearch] 
(
	@LangId				NVARCHAR(50),
	@idfsBaseReference	BIGINT
)	
AS
BEGIN	
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @idfsReferenceType	BIGINT
		DECLARE @Name				NVARCHAR(MAX)

		SELECT
			@idfsReferenceType = idfsReferenceType
		FROM
			trtBaseReference
		WHERE
			idfsBaseReference = @idfsBaseReference

		SELECT
			@Name = name
		FROM
			FN_GBL_ReferenceRepair(@LangId,@idfsReferenceType)
		WHERE
			idfsReference = @idfsBaseReference

		SELECT
			idfsReference
		FROM
			FN_GBL_ReferenceRepair(@LangId,@idfsReferenceType)
		WHERE
			name like '%' + @Name + '%'
	
	END TRY 
	BEGIN CATCH   
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
END

