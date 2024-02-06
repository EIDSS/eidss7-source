
--=====================================================================================================
-- Created by:				Srini Goli
-- Last modified date:		
-- Last modified by:		
-- Description:				
--     
-- Change Log:
-- Name                  Date       Description
-- --------------------- ---------- --------------------------------------------------------------

--
-- Testing code:
/*
----testing code:
JL: no data return for gisSettlement only contains GG 780000000 data but fnSiteID restricting for 1
EXEC usp_Settlement_GetLookup 'ru'
EXEC usp_Settlement_GetLookup 'en', 1344700000000	
*/
--=====================================================================================================
CREATE PROCEDURE [dbo].[usp_Settlement_GetLookup] @LangID AS NVARCHAR(50), --##PARAM @LangID - language ID
	@RayonID AS BIGINT = NULL, --##PARAM @idfsRayon - settlement rayon. If NULL is passed, entire list of settlements is returned
	@ID AS BIGINT = NULL --##PARAM @ID - ID of specific settlement. If not null, returns only this specific settlement, in other case entire list is returned
AS
SELECT s.idfsSettlement AS idfsSettlement,
	s.name AS strSettlementName,
	s.ExtendedName AS strSettlementExtendedName,
	s.idfsRayon,
	s.idfsRegion,
	s.idfsCountry,
	s.idfsGISReferenceType,
	s.idfsType AS SettlementType,
	s.intRowStatus,
	s.intOrder AS intElevation
FROM dbo.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
WHERE (
		@RayonID IS NULL
		OR s.idfsRayon = @RayonID
		)
	AND (
		(NOT @RayonID IS NULL)
		OR (@ID IS NULL)
		OR (s.idfsSettlement = @ID)
		)
ORDER BY name;

