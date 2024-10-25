
--*************************************************************
-- Name 				: report.FN_REP_ReferenceRepair_GET
-- Description			: The FUNCTION returns all the reference values 
--                         for report
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--	Mark Wilson  06/28/2022   initial version
--
-- Testing code:

/*

SELECT * FROM report.FN_REP_ReferenceRepair_GET('en-US',19000040)

*/
--*************************************************************

CREATE FUNCTION[Report].[FN_REP_ReferenceRepair_GET]
(
	@LangID NVARCHAR(50), 
	@type BIGINT
 )
RETURNS TABLE
AS

	RETURN(
			SELECT		
				b.idfsBaseReference AS idfsReference, 
				ISNULL(c.strTextString, b.strDefault) AS [name],
				b.idfsReferenceType, 
				b.intHACode, 
				b.strDefault, 
				ISNULL(c.strTextString, b.strDefault) AS LongName,
				b.intOrder,
				b.intRowStatus

			FROM dbo.trtBaseReference AS b WITH (NOLOCK) -- WITH (INDEX=IX_trtBaseReference_RR)
			LEFT JOIN dbo.trtStringNameTranslation AS c WITH (NOLOCK) ON b.idfsBaseReference = c.idfsBaseReference AND c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

			--LEFT JOIN dbo.trtStringNameTranslation AS c WITH(INDEX=IX_trtStringNameTranslation_BL) ON b.idfsBaseReference = c.idfsBaseReference 
			--																					   AND c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

			WHERE b.idfsReferenceType = @type --AND b.intRowStatus = 0 
		)


