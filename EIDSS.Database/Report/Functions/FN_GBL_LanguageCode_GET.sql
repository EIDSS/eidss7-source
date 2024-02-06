
--*************************************************************
-- Name 				: report.FN_GBL_LanguageCode_GET
-- Description			: Returns idfsLanguage  
--						
-- Author               : Mark Wilson
-- Revision History
--
--		Name       Date       Change Detail
--
-- Testing code:
--
-- SELECT report.FN_GBL_LanguageCode_GET('en-US')
-- SELECT * FROM dbo.trtBaseReference WHERE idfsReferenceType=19000049
--*************************************************************

CREATE FUNCTION [Report].[FN_GBL_LanguageCode_GET]
(
	@LangID  NVARCHAR(50)
)
RETURNS BIGINT
AS
BEGIN
  DECLARE @LanguageCode BIGINT
  SET @LanguageCode = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE strBaseReferenceCode = @LangID AND idfsReferenceType = 19000049)
  RETURN @LanguageCode
END
