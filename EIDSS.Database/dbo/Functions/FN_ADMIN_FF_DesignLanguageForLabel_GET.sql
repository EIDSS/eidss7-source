

-- ================================================================================================
-- Name: FN_ADMIN_DesignLanguageForLabel_GET
-- Description: Returns the Design Language for the label
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Kishore Kodru	1/11/2019  Updated old references. 
-- Mark Wilson		7/22/2021  Updated to use basereference code for @LangID
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_ADMIN_FF_DesignLanguageForLabel_GET]
(
	@LangID NVARCHAR(50),
	@idfDecorElement BIGINT
)
RETURNS BIGINT
AS
BEGIN

	--
	DECLARE @Result BIGINT
	SET @Result = dbo.FN_GBL_LanguageCode_GET(@LangID);  
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.ffDecorElement WHERE [idfDecorElement] = @idfDecorElement AND idfsLanguage = @Result AND intRowStatus = 0) 
	BEGIN
		SET @LangID = (SELECT strBaseReferenceCode FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000049 AND strDefault = 'English')
		SET @Result = dbo.FN_GBL_LanguageCode_GET(@LangID);
	END		
		
	RETURN	@Result;
END


