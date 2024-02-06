-- =============================================
-- Author:		Edgard Torres
-- Create date: 11/10/2022
-- Description:	Returns LanguageID for EIDSS 7
-- =============================================
CREATE FUNCTION [dbo].[fnGetLanguageID_E7] 
(
	-- Add the parameters for the function here
	@LanguageID varchar(36)
)
RETURNS varchar(36)
AS
BEGIN
	-- Return variables
	DECLARE @E7LanguageID varchar(36)

	-- Select equivalent LanguageID from trtBaseReference 
	SELECT @E7LanguageID =  strBaseReferenceCode
	FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000049 AND intRowStatus = 0 AND strBaseReferenceCode like @LanguageID + '%'

	IF (@E7LanguageID = '' OR @E7LanguageID IS NULL) SELECT @E7LanguageID = 'en-US'

	-- Return new value
	RETURN @E7LanguageID

END
GO


