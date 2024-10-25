

CREATE FUNCTION [Report].[FN_GBL_SiteID_GET]()
RETURNS BIGINT
AS
BEGIN
	DECLARE @ret BIGINT
	
	SELECT 
		@ret = CAST(tstLocalSiteOptions.strValue AS BIGINT)
	
	FROM tstLocalSiteOptions
	
	WHERE tstLocalSiteOptions.strName = 'SiteID'
	
	RETURN @ret

END


