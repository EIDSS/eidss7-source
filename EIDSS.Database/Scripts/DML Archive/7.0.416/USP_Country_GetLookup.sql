

--
--
-- renamed spCountry_SelectLookup to usp_Country_GetLookup by MCW
--
--


--exec usp_Country_SelectLookup 'en'

CREATE OR ALTER PROCEDURE [dbo].[USP_Country_GetLookup]
    @LangID As nvarchar(50),
    @NameFilter As nvarchar(100)
AS
DECLARE
    @skipNameFilter BIT = IIF(@NameFilter IS NULL OR LTRIM(RTRIM(@NameFilter)) = '', 1, 0)

SELECT	country.idfsReference	as idfsCountry,
          country.name			as strCountryName,
          country.ExtendedName	as strCountryExtendedName,
          gisCountry.strCode		as strCountryCode,
          country.intRowStatus

FROM	dbo.fnGisExtendedReferenceRepairLng(@LangID,19000001)  country --'rftCountry'
JOIN	gisCountry on country.idfsReference = gisCountry.idfsCountry
WHERE   @skipNameFilter = 1 OR country.name LIKE ('%' + @NameFilter + '%')

ORDER BY strCountryName






