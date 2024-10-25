
/*
SELECT report.FN_CustomizationCountry()
*/
CREATE FUNCTION [Report].[FN_CustomizationCountry]
(
)
RETURNS BIGINT
AS
BEGIN
	DECLARE @idfsCountry BIGINT
		
	SELECT
		@idfsCountry = tcp1.idfsCountry
	FROM tstCustomizationPackage tcp1
	WHERE tcp1.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
	
	RETURN @idfsCountry
END

