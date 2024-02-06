
-- ================================================================================================
-- Name: FN_GBL_CURRENTCOUNTRY_Node_GET
--
-- Description: Returns country node for current database 
--						
-- Author: Mark Wilson
--
-- 
-- Testing code:
-- 
-- 
/*
	SELECT dbo.FN_GBL_CURRENTCOUNTRY_Node_GET()
*/
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_CURRENTCOUNTRY_Node_GET] ()
RETURNS HIERARCHYID
AS
BEGIN
	DECLARE @idfsCountry BIGINT;
	DECLARE @Node HIERARCHYID

	SELECT @idfsCountry = tcp1.idfsCountry
	FROM dbo.tstSite ts
	JOIN dbo.tstCustomizationPackage tcp1
		ON tcp1.idfCustomizationPackage = ts.idfCustomizationPackage
	WHERE ts.idfsSite = dbo.FN_GBL_SITEID_GET();

	SELECT @Node = node
	FROM dbo.gisLocation WHERE idfsLocation = @idfsCountry
	
	RETURN @Node;
END
