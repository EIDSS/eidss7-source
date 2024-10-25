


--*************************************************************
-- Name 				: FN_GBL_ReferenceRepair_GET
-- Description			: The FUNCTION returns all the reference values 
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--     Mark Wilson 16May2019  Changed call to FN_GBL_LanguageCode_GET
--
-- Testing code:
-- SELECT * FROM report.FN_GBL_ReferenceRepair_GET('ru',19000040)
--*************************************************************
-- SELECT all reference values - with deleted values
CREATE FUNCTION[Report].[FN_GBL_ReferenceRepair_GET]
(
	@LangID NVARCHAR(50), 
	@type BIGINT
 )
RETURNS TABLE
AS

	RETURN(
			SELECT		
				b.idfsBaseReference as idfsReference, 
				ISNULL(c.strTextString, b.strDefault) as [name],
				b.idfsReferenceType, 
				b.intHACode, 
				b.strDefault, 
				ISNULL(c.strTextString, b.strDefault) as LongName,
				b.intOrder,
				b.intRowStatus

			FROM dbo.trtBaseReference AS b WITH(INDEX=IX_trtBaseReference_RR)
			LEFT JOIN dbo.trtStringNameTranslation AS c WITH(INDEX=IX_trtStringNameTranslation_BL) ON b.idfsBaseReference = c.idfsBaseReference 
																								   AND c.idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)

			WHERE b.idfsReferenceType = @type AND b.intRowStatus = 0 
		)


