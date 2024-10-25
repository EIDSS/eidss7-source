-- =============================================
-- Author:		Steven L. Verner
-- Create date: 08.26.2020
-- Description:	Retrieves a list of HMIS settlements
-- =============================================
CREATE PROCEDURE [dbo].[USP_HMISSettlementGetList] 
	-- Add the parameters for the stored procedure here
	 @langID nvarchar(50) 
	,@rayonID bigint = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT	
	settlement.idfsReference AS idfsSettlement, 
	settlement.name AS strSettlementName,
	hmisSettlement.strHmisSettlement,
	settlement.ExtendedName AS strSettlementExtendedName,
	gisSettlement.idfsRayon,
	gisSettlement.idfsRegion,
	gisSettlement.idfsCountry,
	settlementType.name AS strSettlementType,
	settlement.intRowStatus,
	country.name AS strCountryName,
	region.ExtendedName AS strRegionExtendedName,
	rayon.ExtendedName AS strRayonExtendedName
FROM dbo.fnGisExtendedReferenceRepair(@LangID,19000004) settlement
JOIN 	gisSettlement ON	settlement.idfsReference = gisSettlement.idfsSettlement 
JOIN hmisSettlement ON idfsReference = hmisSettlement.idfsSettlement
JOIN tstCustomizationPackage tcpac ON tcpac.idfsCountry = gisSettlement.idfsCountry
JOIN tstSite ON tstSite.idfCustomizationPackage=tcpac.idfCustomizationPackage AND tstSite.idfsSite=dbo.fnSiteID()
LEFT JOIN fnGisReference(@LangID, 19000005) settlementType ON settlementType.idfsReference = gisSettlement.idfsSettlementType
LEFT JOIN dbo.fnGisExtendedReferenceRepair(@LangID,19000003) region ON region.idfsReference = gisSettlement.idfsRegion
LEFT JOIN dbo.fnGisExtendedReferenceRepair(@LangID,19000002) rayon ON rayon.idfsReference = gisSettlement.idfsRayon
LEFT JOIN dbo.fnGisReferenceRepair(@LangID,19000001) country ON country.idfsReference = gisSettlement.idfsCountry
WHERE ( @RayonID IS NULL OR gisSettlement.idfsRayon = @RayonID )
ORDER BY strSettlementName
END
