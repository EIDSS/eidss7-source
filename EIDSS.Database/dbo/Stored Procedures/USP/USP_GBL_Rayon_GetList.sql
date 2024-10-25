


--=====================================================================================================
-- Name: [usp_Rayon_GetList]
--
-- Description: Select lookup list of Rayons from 
--              tables: gisRayon; gisCountry; 
--              Functions: fnGisExtendedReferenceRepair;fnGisReferenceRepair

--  [usp_Rayon_GetList] 'en',780000000,37020000000


CREATE PROCEDURE [dbo].[USP_GBL_Rayon_GetList]
	@LangID		AS NVARCHAR(50),
	@CountryId  AS BIGINT,
	@RegionID	AS BIGINT = NULL ,
	@ID			AS BIGINT = NULL

AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
			@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT	
				rayon.idfsReference AS idfsRayon,
				rayon.name AS strRayonName,
				rayon.LongName AS strRayonExtendedName,
				gisRayon.idfsRegion,
				gisRayon.idfsCountry,
				rayon.intRowStatus,
				region.LongName AS strRegionExtendedName,
				country.name AS strCountryName

		FROM dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000002) rayon--'rftRayon' 
		JOIN gisRayon ON rayon.idfsReference = gisRayon.idfsRayon 
		JOIN gisCountry ON gisRayon.idfsCountry = gisCountry.idfsCountry
		JOIN dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000003) region ON region.idfsReference = gisRayon.idfsRegion
		JOIN dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000001) country ON country.idfsReference = gisRayon.idfsCountry
		WHERE	
			gisRayon.idfsRegion = ISNULL(@RegionID, gisRayon.idfsRegion)
			AND ( (NOT @RegionID IS NULL) OR  (@ID IS NULL) OR (gisRayon.idfsRegion = @ID) )
			AND gisRayon.idfsCountry = @CountryId

		ORDER BY strRayonName

	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;

	
END
