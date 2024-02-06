



--*************************************************************************
-- Name 				: report.USP_REP_CurrentCountry_GET
-- Description			: To Get CurrentCountry Details
--						  - used in Reports to Get CurrentCountry
--          
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--
-- Testing code:
--
-- EXEC report.USP_REP_CurrentCountry_GET 'ka'
-- EXEC report.USP_REP_CurrentCountry_GET 'en'
--*************************************************************************



CREATE PROCEDURE  [Report].[USP_REP_CurrentCountry_GET]
	 @LangID NVARCHAR(50)
AS
BEGIN
	DECLARE @Country TABLE
		(
			CountryID BIGINT,
			strCountry NVARCHAR(100)

		)

		INSERT INTO @Country

		SELECT 
			report.FN_GBL_CurrentCountry_GET() AS CountryID,
			R.[name] AS strCountry

		FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000001) R
		WHERE R.idfsReference= report.FN_GBL_CurrentCountry_GET()

		SELECT * FROM @Country
END


