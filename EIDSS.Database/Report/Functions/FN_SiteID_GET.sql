
----------------------------------------------------------------------------
-- Name 				: report.FN_SiteID_GET
-- Description			: Get the siteID
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson	  13-June-2019  Converted to E7 standards and updated to report schema
--
-- usage
--
-- SELECT report.FN_SiteID_GET()
--
CREATE FUNCTION [Report].[FN_SiteID_GET]()
RETURNS BIGINT
AS
BEGIN
	DECLARE @ret BIGINT
	
	SELECT 
		@ret = CAST(S.strValue AS BIGINT)
	
	FROM dbo.tstLocalSiteOptions S
	
	WHERE S.strName = 'SiteID'
	
	RETURN @ret

END


