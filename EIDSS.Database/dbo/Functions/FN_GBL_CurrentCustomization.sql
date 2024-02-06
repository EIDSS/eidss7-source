
CREATE FUNCTION [dbo].[FN_GBL_CurrentCustomization]()

RETURNS BIGINT
AS
BEGIN
	DECLARE @idfsCustomization BIGINT

	SELECT
		@idfsCustomization = ts.idfCustomizationPackage

	FROM dbo.tstSite ts
	WHERE ts.idfsSite = dbo.FN_GBL_SITEID_GET()
	
	RETURN @idfsCustomization
END

