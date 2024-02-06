

----------------------------------------------------------------------------
-- Name 				: FN_GBL_CustomizationPackage_GET
-- Description			: Get the id for the current Customizatino Package
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    10-Nov-2017   Convert EIDSS 6 to EIDSS 7 standards and 
--                              changed name FN_GBL_CustomizationPackage_GET
--
-- Testing code:
-- SELECT report.FN_GBL_CustomizationPackage_GET()
----------------------------------------------------------------------------

CREATE FUNCTION [Report].[FN_GBL_CustomizationPackage_GET]()
RETURNS BIGINT
AS
BEGIN
	DECLARE @idfsCustomizationPackage BIGINT
	
	SELECT	@idfsCustomizationPackage = CAST(strValue AS BIGINT)
	FROM	dbo.tstGlobalSiteOptions o
	WHERE	o.strName = 'CustomizationPackage'

	IF @idfsCustomizationPackage IS NULL			
		SELECT	@idfsCustomizationPackage = ts.idfCustomizationPackage
		FROM dbo.tstLocalSiteOptions tlso
		JOIN dbo.tstSite ts ON ts.idfsSite = CAST(tlso.strValue AS BIGINT)
		WHERE tlso.strName = 'SiteID'

	RETURN @idfsCustomizationPackage
END


