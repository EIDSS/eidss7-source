﻿

--##SUMMARY Builds address geoplocation string from passed compound parts basing on template specific for current customization country.
--##SUMMARY This function is designed for maximum speed execution so it assumes that passed compound parts is NOT NULL.
--##SUMMARY The statement that calls this function must provide NOT NULL values for address compound parts,
--##SUMMARY in other case NULL will be returned


--Mark Wilson Converted to EIDSS7 standards

/*
--Example of function call:

SELECT report.FN_REP_CreateAddressString (
  'Georgia'
  ,'Imereti'
  ,'Khoni'
  ,''
  ,''
  ,'Khoni'
  ,'Gugashvily street'
  ,'1'
  ,''
  ,'2'
  , 0
  , ''
)

*/

CREATE FUNCTION [Report].[FN_REP_CreateAddressString]	(
					@Country		NVARCHAR(200) = '', --##PARAM @Country - Country name
					@Region			NVARCHAR(200) = '', --##PARAM @Region - Region name
					@Rayon			NVARCHAR(200) = '', --##PARAM @Rayon - Rayon name
					@PostCode		NVARCHAR(200) = '', --##PARAM @PostCode - Postal Code
					@SettlementType	NVARCHAR(200) = '', --##PARAM @SettlementType - Settlement Type
					@Settlement		NVARCHAR(200) = '', --##PARAM @Settlement -Settlement
					@Street			NVARCHAR(200) = '', --##PARAM @Street - Street
					@House			NVARCHAR(200) = '', --##PARAM @House - House number
					@Building		NVARCHAR(200) = '', --##PARAM @Building - Building number
					@Apartment		NVARCHAR(200) = '', --##PARAM @Appartment - Appartment number
					@blnForeignAddress BIT		  = 0,
					@strForeignAddress	NVARCHAR(200) = ''
								)
RETURNS NVARCHAR(1000)
AS
BEGIN
	
declare @TempStr nvarchar(1000) = ''

IF (@blnForeignAddress = 1)
BEGIN
	SELECT 
		@TempStr = strForeignAddress 
	FROM tstGeoLocationFormat 
	WHERE idfsCountry = report.FN_CustomizationCountry()
	
	IF @TempStr = ''
		SELECT 
			@TempStr = strForeignAddress
		FROM	tstGeoLocationFormat
		WHERE	idfsCountry = 2340000000 /*The USA*/
		
	set @TempStr = REPLACE(@TempStr, '@Country', @Country)
	set @TempStr = REPLACE(@TempStr, '@Region', @Region)
	set @TempStr = REPLACE(@TempStr, '@Rayon', @Rayon)
	set @TempStr = REPLACE(@TempStr, '@SettlementType', @SettlementType)
	set @TempStr = REPLACE(@TempStr, '@Settlement', @Settlement)
	set @TempStr = REPLACE(@TempStr, '@PostCode', @PostCode)
	set @TempStr = REPLACE(@TempStr, '@Street', @Street)
	set @TempStr = REPLACE(@TempStr, '@House', @House)
	set @TempStr = REPLACE(@TempStr, '@Building', @Building)
	set @TempStr = REPLACE(@TempStr, '@Apartment', @Apartment)
	set @TempStr = REPLACE(@TempStr, '@AddressString', @strForeignAddress)

	set	@TempStr = LTRIM(RTRIM(REPLACE(@TempStr, N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N'- -', N'-'), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N'--', N'-'), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', -', N' -'), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',-', N'-'), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', ,', N','), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N', ,', N','), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',,', N','), N'  ', N' ')))
	set	@TempStr = LTRIM(RTRIM(REPLACE(REPLACE(@TempStr, N',,', N','), N'  ', N' ')))

	if	@TempStr like N', %' set @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 3, LEN(@TempStr) - 2)))
	if	@TempStr like N',%' set @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 2, LEN(@TempStr) - 1)))
	if	@TempStr like N'%-' set @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 1, LEN(@TempStr) - 1)))
	IF	@TempStr LIKE N'%,' SET @TempStr = LTRIM(RTRIM(SUBSTRING(@TempStr, 1, LEN(@TempStr) - 1)))
END
ELSE
	BEGIN
		SELECT 
			@TempStr = strAddressString
		FROM	tstGeoLocationFormat
		WHERE	idfsCountry = report.FN_CustomizationCountry()

		IF @TempStr = ''
			SELECT 
				@TempStr = strAddressString
			FROM	tstGeoLocationFormat
			WHERE	idfsCountry = 2340000000 /*The USA*/
				
		IF (LEN(@Region)>0 
			OR LEN(@Rayon)>0 
			OR LEN(@SettlementType)>0 
			OR LEN(@Settlement)>0 
			OR LEN(@PostCode)>0 
			OR LEN(@Street)>0 
			OR LEN(@House)>0 
			OR LEN(@Building)>0 
			OR LEN(@Apartment)>0 
			OR LEN(@strForeignAddress)>0)
		BEGIN 
		SET @TempStr = REPLACE(@TempStr, '@Country', @Country)
		SET @TempStr = REPLACE(@TempStr, '@Region', @Region)
		SET @TempStr = REPLACE(@TempStr, '@Rayon', @Rayon)
		SET @TempStr = REPLACE(@TempStr, '@SettlementType', @SettlementType)
		SET @TempStr = REPLACE(@TempStr, '@Settlement', @Settlement)
		SET @TempStr = REPLACE(@TempStr, '@PostCode', @PostCode)
		SET @TempStr = REPLACE(@TempStr, '@Street', @Street)
		SET @TempStr = REPLACE(@TempStr, '@House', @House)
		SET @TempStr = REPLACE(@TempStr, '@Building', @Building)
		SET @TempStr = REPLACE(@TempStr, '@Apartment', @Apartment)
		SET @TempStr = REPLACE(@TempStr, '@AddressString', @strForeignAddress)

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

		-- @PostCode, @Country, @Region, @Rayon, @SettlementType @Settlement, @Street @House-@Building-@Appartment
	END
	
RETURN @TempStr
END

