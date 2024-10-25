-- ================================================================================================
-- Name: FN_GBL_CURRENTCOUNTRY_GET
--
-- Description: Returns country code 
--						
-- Author: Maheshwar Deo
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    07/07/2020 Changed 6.1 site function call to the 7.0 version.
--
-- Testing code:
-- 
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_CURRENTCOUNTRY_GET] ()
RETURNS BIGINT
AS
BEGIN
	DECLARE @idfsCountry BIGINT;

	SELECT @idfsCountry = tcp1.idfsCountry
	FROM dbo.tstSite ts
	JOIN dbo.tstCustomizationPackage tcp1
		ON tcp1.idfCustomizationPackage = ts.idfCustomizationPackage
	WHERE ts.idfsSite = dbo.FN_GBL_SITEID_GET();

	RETURN @idfsCountry;
END
