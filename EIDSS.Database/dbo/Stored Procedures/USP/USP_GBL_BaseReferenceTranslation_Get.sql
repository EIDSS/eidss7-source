/*******************************************************
NAME						: [USP_GBL_BaseReferenceTranslation_Get]		
Description					: Retreives Entries For List of Species
Author						: Doug Albanese

Revision History
Name					Date			Change Detail
Doug Albanese			06/17/2022		Initial Creation
*******************************************************/
CREATE PROCEDURE [dbo].[USP_GBL_BaseReferenceTranslation_Get]
	@LanguageID				VARCHAR(5) = NULL,
	@idfsBaseReference			BIGINT = NULL
AS BEGIN

SET NOCOUNT ON;

	BEGIN TRY
			SELECT		
				b.strDefault, 
				ISNULL(c.strTextString, b.strDefault) AS [name],
				ISNULL(c.strTextString, b.strDefault) AS LongName
			FROM
				dbo.trtBaseReference AS b WITH(INDEX=IX_trtBaseReference_RR)
			LEFT JOIN dbo.trtStringNameTranslation AS c WITH(INDEX=IX_trtStringNameTranslation_BL)
			ON b.idfsBaseReference = c.idfsBaseReference AND 
				c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			WHERE b.idfsBaseReference = @idfsBaseReference 
				AND b.intRowStatus = 0
	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
