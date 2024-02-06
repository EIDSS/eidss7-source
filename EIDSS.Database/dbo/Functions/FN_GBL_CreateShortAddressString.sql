
--*************************************************************
-- Name 				: FN_GBL_CreateShortAddressString
-- Description			: Builds short address string from passed compound parts basing on template specific for current customization country.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--
-- Testing code:
/*
--Example of function call:

SELECT dbo.FN_GBL_CreateShortAddressString (
  '111111'
  ,'Gugashvily street'
  ,'h'
  ,'b'
  ,'a'
  ,0
)

*/

CREATE FUNCTION [dbo].[FN_GBL_CreateShortAddressString]	
(
	@PostCode		NVARCHAR(200) = '', --##PARAM @PostCode - Postal Code
	@Street			NVARCHAR(200) = '', --##PARAM @Street - Street
	@House			NVARCHAR(200) = '', --##PARAM @House - House number
	@Building		NVARCHAR(200) = '', --##PARAM @Building - Building number
	@Apartment		NVARCHAR(200) = '', --##PARAM @Appartment - Appartment number
	@blnForeignAddress BIT		  = 0
)
RETURNS NVARCHAR(1000)
AS
BEGIN
	
	declare @TempStr nvarchar(1000) = ''

	IF (@blnForeignAddress = 0)
	BEGIN
		SELECT 
			@TempStr = strShortAddress 
		FROM dbo.tstGeoLocationFormat 
		WHERE idfsCountry = dbo.FN_GBL_CustomizationCountry()
	
		IF @TempStr = ''
			SELECT 
				@TempStr = strShortAddress
			FROM dbo.tstGeoLocationFormat
			WHERE idfsCountry = 2340000000 /*The USA*/
	END
	
			IF 	LEN(@PostCode)>0 
				OR LEN(@Street)>0 
				OR LEN(@House)>0 
				OR LEN(@Building)>0 
				OR LEN(@Apartment)>0 
			BEGIN 
			SET @TempStr = REPLACE(@TempStr, '@PostCode', @PostCode)
			SET @TempStr = REPLACE(@TempStr, '@Street', @Street)
			SET @TempStr = REPLACE(@TempStr, '@House', @House)
			SET @TempStr = REPLACE(@TempStr, '@Building', @Building)
			SET @TempStr = REPLACE(@TempStr, '@Apartment', @Apartment)

			SET	@TempStr = LTRIM(RTRIM(REPLACE(@TempStr, N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N'- -', N'-'), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N'--', N'-'), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', -', N' -'), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',-', N'-'), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', ,', N','), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', ,', N','), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',,', N','), N'  ', N' ')))
			SET	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',,', N','), N'  ', N' ')))

			IF	@TempStr LIKE N', %' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 3, LEN(@TempStr) - 2)))
			IF	@TempStr LIKE N',%' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 2, LEN(@TempStr) - 1)))
			IF	@TempStr LIKE N'%-' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 1, LEN(@TempStr) - 1)))
			IF	@TempStr LIKE N'%,' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 1, LEN(@TempStr) - 1)))
			END
			ELSE
			SET @TempStr = ''

			-- @PostCode, @Street @House-@Building-@Appartment
	
	RETURN @TempStr
END

