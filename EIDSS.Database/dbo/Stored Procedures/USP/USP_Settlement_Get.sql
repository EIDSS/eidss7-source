

--*************************************************************
-- Name 				: USP_Settlement_Get
-- Description			: Returns list of Settlements/translations
--                        Displays all Settlements  in the RayonID if passed
--						
-- Author               : Mark Wilson - Nov 2019
-- Revision History
--
-- Testing code:
-- 
-- Settlement Types:  
-- 730120000000 - Settlement
-- 730130000000 - Town
-- 730140000000 - Village
--
--exec dbo.USP_Settlement_Get 'en', 3790000000
--exec dbo.USP_Settlement_Get 'ru'
--exec dbo.USP_Settlement_Get 'ka', 3790000000, 730120000000

CREATE PROCEDURE [dbo].[USP_Settlement_Get]
(
	@LangID AS NVARCHAR(50),
	@RayonID BIGINT = NULL, -- optional parameter
	@SettlementType BIGINT = NULL -- optional SettlementType
)
AS
SELECT	
	Settlement.idfsSettlement AS idfsSettlement, 
	ST.[name] AS strSettlementName, 
	ST.ExtendedName AS strSettlementExtendedName, 
	STT.[name] AS strSettlementType,
	Settlement.strSettlementCode AS strSettlementCode, 
	Settlement.idfsCountry, 
	Settlement.intRowStatus,
	CT.[name] AS strCountryName

FROM dbo.gisSettlement Settlement
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) CT ON CT.idfsReference = Settlement.idfsCountry
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000004) ST ON ST.idfsReference = Settlement.idfsSettlement-- Settlement = 19000002
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000005) STT ON STT.idfsReference = Settlement.idfsSettlementType

WHERE Settlement.idfsCountry = ISNULL(dbo.FN_GBL_CurrentCountry_GET(), Settlement.idfsCountry)
AND (Settlement.idfsRayon = @RayonID OR @RayonID IS NULL)
AND (Settlement.idfsSettlementType = @SettlementType OR @SettlementType IS NULL)

ORDER BY 
	ST.[name],
	STT.[name]

