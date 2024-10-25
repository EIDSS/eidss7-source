
--*************************************************************
-- Name 				: FN_GBL_CreateRelativePointString
-- Description			: Builds relative point geoplocation string from passed compound parts basing on template specific for current customization country.
--						: Can be used in detail forms where there is no need to display multipe rows with geolocation string.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--
-- RETURNS String representation of relative point geolocation
--
--*************************************************************
/*
--Example of function call:

SELECT dbo.FN_GBL_CreateRelativePointString (
  'en'
  ,'Georgia'
  ,'Imereti'
  ,'Khoni'
  ,''
  ,'Khoni'
  ,'20.1'
  ,'46.345'

  )

*/



CREATE   FUNCTION [dbo].[FN_GBL_CreateRelativePointString](
	@LangID			NVARCHAR(50), --##PARAM @LangID  - language ID
	@Country		NVARCHAR(200) = '', --##PARAM @Country - Country name
	@Region			NVARCHAR(200) = '', --##PARAM @Region - Region name
	@Rayon			NVARCHAR(200) = '', --##PARAM @Rayon - Rayon name
	@SettlementType	NVARCHAR(200) = '', --##PARAM @SettlementType - Settlement Type
	@Settlement		NVARCHAR(200) = '', --##PARAM @Settlement -Settlement
	@Alignment		NVARCHAR(200) = '', --##PARAM @Alignment - Azimuth of direction from settlement
	@Distance		NVARCHAR(200) = '' --##PARAM @Distance - Distance from settlement
)
RETURNS NVARCHAR(1000)
AS
BEGIN

	DECLARE @From	nvarchar(200)
	DECLARE @Azimuth	nvarchar(200)
	DECLARE @At_distance_of	nvarchar(200)
	DECLARE @Km	nvarchar(200)

	SELECT 
		@From = frr.name 
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) frr 
	WHERE frr.idfsReference = 10300058 /*from*/

	SELECT 
		@Azimuth = frr.name 
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) frr
	WHERE frr.idfsReference = 10300059 /*Azimuth*/

	SELECT 
		@At_distance_of = frr.name 
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) frr 
	WHERE frr.idfsReference = 10300060 /*At_distance_of*/

	SELECT 
		@Km = frr.name 
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) frr 
	WHERE frr.idfsReference = 10300061 /*Km*/

	DECLARE @TempStr NVARCHAR(1000) = ''

	SELECT	
		@TempStr = strRelativePointString
	FROM	tstGeoLocationFormat
	WHERE	idfsCountry = dbo.FN_GBL_CustomizationCountry()

	IF @TempStr = ''
	SELECT	
		@TempStr = strRelativePointString
	FROM	tstGeoLocationFormat
	WHERE	idfsCountry = 2340000000 /*The USA*/

	IF (LEN(@Region)>0 AND LEN(@Rayon)>0 AND LEN(@Settlement)>0) 
	BEGIN 
		SET @TempStr = REPLACE(@TempStr, '@Country', @Country)
		SET @TempStr = REPLACE(@TempStr, '@Region', @Region)
		SET @TempStr = REPLACE(@TempStr, '@Rayon', @Rayon)
		SET @TempStr = REPLACE(@TempStr, '@SettlementType', @SettlementType)
		SET @TempStr = REPLACE(@TempStr, '@Settlement', @Settlement)
		SET @TempStr = REPLACE(@TempStr, '@Alignment', @Alignment)
		SET @TempStr = REPLACE(@TempStr, '@Distance', @Distance)
		SET @TempStr = REPLACE(@TempStr, '@From', @From)
		SET @TempStr = REPLACE(@TempStr, '@Azimuth', @Azimuth)
		SET @TempStr = REPLACE(@TempStr, '@At_distance_of', @At_distance_of)
		SET @TempStr = REPLACE(@TempStr, '@Km', @Km)
	END

	ELSE
		SET @TempStr = ''

	RETURN @TempStr

END

