

--*************************************************************
-- Name 				: FN_ADMIN_FF_DesignLanguageForParameter_GET
-- Description			: return the LanguageID
--						
-- Author               : Mark Wilson converted to E7
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
/*

DECLARE @LangID nvarchar(100) = 'en-US',
		@idfsParameter BIGINT = 9238790000000
SELECT [dbo].[FN_ADMIN_FF_DesignLanguageForParameter_GET]( @LangID, @idfsParameter, NULL)

*/ 
--*************************************************************
-------------------------------------------------------------------------------------------
-- Converted to E7 standards
CREATE FUNCTION [dbo].[FN_ADMIN_FF_DesignLanguageForParameter_GET]
(
	@LangID NVARCHAR(50),
	@idfsParameter BIGINT,
	@idfsFormTemplate BIGINT	
)
RETURNS BIGINT
AS
BEGIN
	--
	DECLARE @Result BIGINT
	SET @Result = dbo.FN_GBL_LanguageCode_GET(@LangID);  
	IF (@idfsFormTemplate IS NULL) BEGIN	
		IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.ffParameterDesignOption WHERE [idfsParameter] =  @idfsParameter AND idfsLanguage = @Result AND idfsFormTemplate IS NULL AND intRowStatus = 0) 
			SET @Result = dbo.FN_GBL_LanguageCode_GET('en-US');
	END ELSE BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.ffParameterDesignOption WHERE [idfsParameter] =  @idfsParameter AND idfsLanguage = @Result AND idfsFormTemplate = @idfsFormTemplate AND intRowStatus = 0) 
			SET @Result = dbo.FN_GBL_LanguageCode_GET('en-US');
	END	
	
	RETURN	@Result;
END


