
/*
--*************************************************************
-- Name 				: FN_SiteID_GET
-- Description			: Funtion to return userid 
--          
-- Author               : Mandar Kulkarni
-- Revision History
--
-- Name			  Date		   Change Detail
-- Mark Wilson	  07-Nov-2019  removed fnGetContext
--
-- usage
--
-- SELECT dbo.FN_SiteID_GET()
--
*/
CREATE FUNCTION [dbo].[FN_SiteID_GET]()
RETURNS BIGINT
AS
BEGIN
	DECLARE @ret BIGINT
	
	SELECT 
		@ret = CAST(strValue AS BIGINT)
	FROM dbo.tstLocalSiteOptions
	
	WHERE strName = 'SiteID'
	
	RETURN @ret

END

