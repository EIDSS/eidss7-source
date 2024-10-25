


--*************************************************************
-- Name 				: USP_GBL_RegionAndRayon_GetList
-- Description			: Get List of Weekly Reports that fit
--						  search criteria entered
--          
-- Author               : Mani
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
--
/*

EXECUTE [dbo].[USP_GBL_RegionAndRayon_GetList] 
	'ru',
	780000000,
	37020000000,
	3260000000
--*/
CREATE PROCEDURE [dbo].[USP_GBL_RegionAndRayon_GetList](
	@LanguageID AS NVARCHAR(50),
	@CountryID AS BIGINT,
	@RegionID as BIGINT =NULL,
	@RayonID as BIGINT =NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;
	
	BEGIN TRY

		select region.strRegionName as RegionName, rayon.strRayonName as RayonName, region.idfsRegion, rayon.idfsRayon from  dbo.gisCountry AS Country
		inner JOIN dbo.VW_GBL_REGIONS_GET AS Region
			ON Country.idfsCountry = Region.idfsCountry
				AND Region.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID) 
					and  country.idfsCountry  =@CountryID
		inner JOIN dbo.VW_GBL_RAYONS_GET AS Rayon
			ON  Region.idfsRegion = Rayon.idfsRegion
			AND Rayon.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID) 
				AND Rayon.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
				and  Rayon.idfsCountry  =@CountryID 
			and country.idfsCountry= country.idfsCountry 
		Where country.intRowStatus=0 and region.intRowStatus=0 and region.intRowStatus=0 and
				(
				region.idfsRegion =@RegionID
				OR @RegionID IS NULL
				)
				
			AND (
				rayon.idfsRayon = @RayonID
				OR @RayonID IS NULL
				)

		order by region.strRegionName, rayon.strRayonName

	SELECT @ReturnCode,
			@ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;

	
END
