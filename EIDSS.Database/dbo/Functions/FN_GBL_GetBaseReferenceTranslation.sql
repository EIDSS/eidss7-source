--*************************************************************
-- Name 				: FN_GBL_GetBaseReferenceTranslation
-- Description			: Immeidate translation of any base reference id
--          
-- Author               : Doug Albanese
-- Revision History:
-- Name			  Date			 Change Detail
-- Doug Albanese  11/02/2022	 Initial Release
--
-- Testing code:
--
--SELECT	dbo.FN_GBL_GetBaseReferenceTranslation ('en-us', 10067008)
--
--*************************************************************
CREATE FUNCTION [dbo].[FN_GBL_GetBaseReferenceTranslation]
(
	@LanguageID			   NVARCHAR(50),
	@idfsBaseReference	   BIGINT
)
Returns NVARCHAR(200)

AS

BEGIN
	  DECLARE @Translation NVARCHAR(200)

	  SELECT		
			@Translation = ISNULL(c.strTextString, b.strDefault)
	  FROM
			dbo.trtBaseReference AS b WITH(INDEX=IX_trtBaseReference_RR)
	  LEFT JOIN dbo.trtStringNameTranslation AS c WITH(INDEX=IX_trtStringNameTranslation_BL)
	  ON b.idfsBaseReference = c.idfsBaseReference AND 
			c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
	  WHERE b.idfsBaseReference = @idfsBaseReference 
			AND b.intRowStatus = 0

     RETURN @Translation
END

