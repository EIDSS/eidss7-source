

--*************************************************************
-- Name 				: FN_GBL_CreateExactPointString
-- Description			: Builds exact point geoplocation string from passed compound parts basing on template specific for current customization country.
--						: This function is designed for maximum speed execution so it assumes that passed compound parts is NOT NULL.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--
--*************************************************************
/*
--Example of function call:

SELECT dbo.FN_GBL_CreateExactPointString (
  'Georgia'
  ,'Imereti'
  ,'Khoni'
  ,'Settlement'
  ,'hhh'
  ,'20,1'
  ,'46,345')


SELECT dbo.FN_GBL_CreateExactPointString (
  'Georgia'
  ,''
  ,''
  ,''
  ,''
  ,'1'
  ,'46,345')
  
*/

CREATE FUNCTION [dbo].[FN_GBL_CreateExactPointString]
(
	@Country		NVARCHAR(200) = '', --##PARAM @Country - Country name
	@Region			NVARCHAR(200) = '', --##PARAM @Region - Region name
	@Rayon			NVARCHAR(200) = '', --##PARAM @Rayon - Rayon name
	@SettlementType	NVARCHAR(200) = '', --##PARAM @SettlementType - Settlement Type
	@Settlement		NVARCHAR(200) = '', --##PARAM @Settlement - Settlement name
	@Latitude		NVARCHAR(200) = '', --##PARAM @Latitude - Latitude
	@Longitude		NVARCHAR(200) = '' --##PARAM @Longitude - Longitude
)
RETURNS NVARCHAR(1000)
AS
BEGIN
	
	DECLARE @TempStr NVARCHAR(1000) = ''

	SELECT
		@TempStr = strExactPointString
	FROM	dbo.tstGeoLocationFormat
	WHERE	idfsCountry = dbo.FN_GBL_CustomizationCountry()

	IF @TempStr = ''
	SELECT
		@TempStr = strExactPointString
	FROM dbo.tstGeoLocationFormat
	WHERE idfsCountry = 2340000000 /*The USA*/

	IF LEN(@Latitude) = 0 OR LEN(@Longitude) = 0 
	BEGIN
		SET @Latitude = '' 
		SET @Longitude = ''
	END

	IF (	LEN(@Country) > 0 OR
			LEN(@Region) > 0 OR 
			LEN(@Rayon) > 0 OR 
			LEN(@SettlementType) > 0 OR
			LEN(@Settlement) > 0 OR
			(LEN(@Latitude) > 0 AND LEN(@Longitude) > 0) 
		) 
	BEGIN 
		SET @TempStr = REPLACE(@TempStr, '@Country', @Country)
		SET @TempStr = REPLACE(@TempStr, '@Region', @Region)
		SET @TempStr = REPLACE(@TempStr, '@Rayon', @Rayon)
		SET @TempStr = REPLACE(@TempStr, '@SettlementType', @SettlementType)
		SET @TempStr = REPLACE(@TempStr, '@Settlement', @Settlement)
		SET @TempStr = REPLACE(@TempStr, '@Latitude', @Latitude)
		SET @TempStr = REPLACE(@TempStr, '@Longitude', @Longitude)

		SET	@TempStr = LTRIM(RTRIM(REPLACE(@TempStr, N'  ', N' ')))
		SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', ,', N','), N'  ', N' ')))
		SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', ,', N','), N'  ', N' ')))
		SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',,', N','), N'  ', N' ')))
		SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',,', N','), N'  ', N' ')))
		SET @TempStr = LTRIM(RTRIM(REPLACE(@TempStr, N' (, )', N' '))) 
		SET @TempStr = LTRIM(RTRIM(REPLACE(@TempStr, N', (', N' ('))) 


		IF	@TempStr LIKE N', %' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 3, LEN(@TempStr) - 2)))
		IF	@TempStr LIKE N',%' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 2, LEN(@TempStr) - 1)))
		IF	@TempStr LIKE N'%,' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 1, LEN(@TempStr) - 1)))
	END
	ELSE
		SET @TempStr = ''

	RETURN  LTRIM(RTRIM(@TempStr))

END

