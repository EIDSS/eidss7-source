
----------------------------------------------------------------------------
-- Name 				: FN_GBL_ReferenceValue_GET
-- Description			: Returns value for the base reference value for a given language code
--          
-- Author               : Mandar Kulkarni
-- 
-- Revision History
-- Name				Date		Change Detail
--
--
-- Testing code:-- SELECT dbo.FN_GBL_ReferenceValue_GET(10049003,19000040)
----------------------------------------------------------------------------
----------------------------------------------------------------------------

CREATE FUNCTION [dbo].[FN_GBL_ReferenceValue_GET](@LangIDCode  BIGINT, @idfsBaseReference BIGINT)
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @strReferenceValue NVARCHAR(500)

	IF @LangIDCode = 10049003 -- If the language code passed in is for English get the value from trtBaseReference table
		BEGIN
			SET @strReferenceValue = (	SELECT	a.strDefault
										FROM	dbo.trtBASeReference AS a with(index=IX_trtBASeReference_RR)
										WHERE idfsBaseReference = @idfsBaseReference
									)
		END
	ELSE -- If the language code passed in is other than English get the translated value from trtStringNameTranslation table
		BEGIN
			SET @strReferenceValue = (	SELECT	a.strTextString
										FROM	dbo.trtStringNameTranslation a
										WHERE idfsBaseReference = @idfsBaseReference
										AND   idfsLanguage = @LangIDCode
									)
		END
	RETURN @strReferencevalue	
END


