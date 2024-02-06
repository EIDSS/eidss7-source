

--*************************************************************
-- Name 				: FN_GBL_CurrentCountry_GET
-- Description			: Returns idfsCountry 
--						
-- Author               : Maheshwar Deo
-- Revision History
--
--		Name       Date       Change Detail
-- Mark Wilson   27-Apr-2019  Updated to use FN_GBL_SiteID_GET
-- Mark Wilson	 13-June-2019 Updated to use report schema
--
--
-- Testing code:
-- 
--*************************************************************

CREATE FUNCTION [Report].[FN_GBL_CurrentCountry_GET]()

RETURNS BIGINT

AS

BEGIN

	DECLARE @idfsCountry BIGINT

	SELECT @idfsCountry = tcp1.idfsCountry
	FROM dbo.tstSite ts
	LEFT JOIN dbo.tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = ts.idfCustomizationPackage
	WHERE ts.idfsSite = report.FN_GBL_SITEID_GET()

	RETURN @idfsCountry

END


