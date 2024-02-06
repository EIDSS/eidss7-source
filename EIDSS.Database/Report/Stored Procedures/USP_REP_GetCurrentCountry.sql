

--*************************************************************************
-- Name 				: report.USP_REP_GetCurrentCountry
-- DescriptiON			: To get Reporting Period Types.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_GetCurrentCountry @LangID=N'en-US'
EXEC report.USP_REP_GetCurrentCountry @LangID=N'ru'
EXEC report.USP_REP_GetCurrentCountry @LangID=N'az-Latn-AZ'
*/

CREATE PROCEDURE [Report].[USP_REP_GetCurrentCountry]
    (
        @LangID AS NVARCHAR(10)
    )
AS
BEGIN
	SELECT idfsReference,Name AS CountryName
	FROM dbo.FN_GBL_GIS_Reference(@LangID,19000001)
	WHERE idfsReference= (SELECT [dbo].[FN_GBL_CURRENTCOUNTRY_GET]())
END

