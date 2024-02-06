-- =============================================
-- Author:		Steven L. Verner
-- Create date: 08.26.2020
-- Description:	Retrieves HMIS rayon data
-- =============================================
CREATE PROCEDURE [dbo].[USP_HMISRayonGetList] 
	-- Add the parameters for the stored procedure here
	 @langID nvarchar(50)
	,@regionID bigint 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 	
		 rayon.idfsReference as idfsRayon
		,rayon.[name] as strRayonName
		,hmisRayon.strHmisRayon
		,rayon.[ExtendedName] as strRayonExtendedName
		,gisRayon.idfsRegion
		,gisRayon.idfsCountry
		,rayon.intRowStatus
		,region.ExtendedName as strRegionExtendedName
		,country.name as strCountryName
	FROM dbo.fnGisExtendedReferenceRepair(@LangID,19000002) rayon
	JOIN hmisRayon ON idfsReference = hmisRayon.idfsRayon
	JOIN gisRayon ON rayon.idfsReference = gisRayon.idfsRayon 
	JOIN gisCountry ON gisRayon.idfsCountry = gisCountry.idfsCountry
	JOIN dbo.fnGisExtendedReferenceRepair(@LangID,19000003) region ON region.idfsReference = gisRayon.idfsRegion 
	JOIN dbo.fnGisReferenceRepair(@LangID,19000001) country ON country.idfsReference = gisRayon.idfsCountry
	WHERE gisRayon.idfsRegion = ISNULL(@RegionID, gisRayon.idfsRegion)
		AND gisRayon.idfsCountry IN (select distinct idfsCountry from tstCustomizationPackage)
	ORDER BY strRayonName
END
