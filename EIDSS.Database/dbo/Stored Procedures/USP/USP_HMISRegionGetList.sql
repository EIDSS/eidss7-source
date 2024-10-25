-- =============================================
-- Author:		Steven L. Verner
-- Create date: 08.26.2020
-- Description:	Retrieves a list of HMIS Regions
-- =============================================
CREATE PROCEDURE [dbo].[USP_HMISRegionGetList] 
	-- Add the parameters for the stored procedure here
	 @langID nvarchar(50) 
	,@countryID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	
		region.idfsReference as idfsRegion, 
		region.[name] as strRegionName, 
		hmisRegion.strHmisRegion,
		region.[ExtendedName] as strRegionExtendedName, 
		gisRegion.strCode as strRegionCode, 
		gisRegion.idfsCountry, 
		region.intRowStatus,
		country.name AS strCountryName
	FROM dbo.fnGisExtendedReferenceRepair(@LangID,19000003) region--'rftRegion'
	JOIN hmisRegion ON idfsReference = hmisRegion.idfsRegion
	JOIN gisRegion ON idfsReference = gisRegion.idfsRegion 
	JOIN dbo.fnGisReferenceRepair(@LangID,19000001) country ON  country.idfsReference = gisRegion.idfsCountry
	WHERE	
		gisRegion.idfsCountry = ISNULL(@CountryID, gisRegion.idfsCountry)
		and gisRegion.idfsCountry in (SELECT DISTINCT idfsCountry FROM tstSite)
	ORDER BY strRegionName
END
