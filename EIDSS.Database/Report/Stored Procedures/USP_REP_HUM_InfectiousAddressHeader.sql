

--*************************************************************************
-- Name 				: report.USP_REP_HUM_InfectiousAddressHeader
-- Description			: This procedure returns Header for Human Disease Intermediate reports
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
/*
EXEC report.USP_REP_HUM_InfectiousAddressHeader 'en', 37020000000, 3260000000
*/ 
--*************************************************************************
  
CREATE PROCEDURE [Report].[USP_REP_HUM_InfectiousAddressHeader]
	@LangID			as varchar(36),
	@RegionID		as bigint = null,
	@RayonID		as bigint = null
AS
BEGIN
	DECLARE @CountryID BIGINT
	SELECT		@CountryID = tcp1.idfsCountry
	FROM tstCustomizationPackage tcp1
	JOIN tstSite s ON
		s.idfCustomizationPackage = tcp1.idfCustomizationPackage
	INNER JOIN	tstLocalSiteOptions lso
	ON			lso.strName = N'SiteID'
	AND			lso.strValue = cast(s.idfsSite as nvarchar(20))

	SELECT   
		ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*rftCountry*/) WHERE idfsReference = @CountryID),'') +
		CASE WHEN @RegionID IS NOT NULL
			THEN ', '
			ELSE ''
		END +
		ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*rftRegion*/) WHERE idfsReference = @RegionID),'')+
		CASE WHEN @RayonID IS NOT NULL
			THEN ', '
			ELSE ''
		END +
		ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*rftRayon*/) WHERE idfsReference = @RayonID),'')
	AS strLocation		
END


