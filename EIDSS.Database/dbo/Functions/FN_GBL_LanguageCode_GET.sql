

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: FN_GBL_LanguageCode_GET
-- Description			: Function to return Language code
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    10-Nov-2017   Convert EIDSS 6 to EIDSS 7 standards and 
--                              renamed to FN_GBL_LanguageCode_GET
-- Stephen Long   29-Jun-2021   Updated to use full culture code on 
--                              Azeri, Arabic-Jordan, Georgian and Thai.
-- Mark Wilson    01-Jul-2021   Updated to select from trtBaseReference 
-- Mark Wilson    08-Jul-2021   added idfsReferenceType in filter 

-- Testing code:
--
/*
	select dbo.FN_GBL_LanguageCode_GET('en-US')
	select dbo.FN_GBL_LanguageCode_GET('az-Latn-AZ')
	select dbo.FN_GBL_LanguageCode_GET('ka-GE')

*/ 

CREATE FUNCTION [dbo].[FN_GBL_LanguageCode_GET](@LangID  NVARCHAR(50))
RETURNS BIGINT
AS
BEGIN
  DECLARE @LanguageCode BIGINT
  SET @LanguageCode = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE strBaseReferenceCode = @LangID AND idfsReferenceType = 19000049 AND intRowStatus =0)
  RETURN @LanguageCode
END



