



--*************************************************************
-- Name 				: FN_GBL_ReferenceRepair
-- Description			: The FUNCTION returns all the reference values 
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- SELECT * FROM FN_GBL_ReferenceRepair('en-US',19000101)
--*************************************************************
-- SELECT all reference values - with deleted values
CREATE FUNCTION[dbo].[FN_GBL_ReferenceRepairSplit]
(
 @LangID	NVARCHAR(50), 
 @type		NVARCHAR(300)
 )
RETURNS TABLE
AS

	RETURN(
			SELECT		b.idfsBaseReference AS idfsReference, 
						ISNULL(c.strTextString, b.strDefault) AS [name],
						b.idfsReferenceType, 
						b.intHACode, 
						b.strDefault, 
						ISNULL(c.strTextString, b.strDefault) AS LongName,
						b.intOrder,
						b.intRowStatus

			FROM		dbo.trtBaseReference AS b WITH(INDEX=IX_trtBaseReference_RR, NOLOCK)
			LEFT JOIN	dbo.trtStringNameTranslation AS c WITH(INDEX=IX_trtStringNameTranslation_BL)
			ON			b.idfsBaseReference = c.idfsBaseReference AND c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

			WHERE		b.idfsReferenceType  IN  ( SELECT value FROM STRING_SPLIT(@type,','))
		)



