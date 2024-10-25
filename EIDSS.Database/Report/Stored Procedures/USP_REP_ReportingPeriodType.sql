

--*************************************************************************
-- Name 				: report.USP_REP_ReportingPeriodType
-- DescriptiON			: To get Reporting Period Types.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_ReportingPeriodType @LangID=N'en-US'
EXEC report.USP_REP_ReportingPeriodType @LangID=N'ru'
EXEC report.USP_REP_ReportingPeriodType @LangID=N'az-Latn-AZ'
*/

CREATE PROCEDURE [Report].[USP_REP_ReportingPeriodType]
    (
        @LangID AS NVARCHAR(10)
    )
AS
BEGIN
	SELECT StrLabel,StrValue
	FROM
	(
		SELECT N'Year' StrLabel,'Year' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'Half-year' StrLabel,'Half-year' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'Quarter' StrLabel,'Quarter' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'Month' StrLabel,'Month' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'Год' StrLabel,'Year' strValue, 'ru-RU' [LangID]
		UNION ALL
		SELECT N'Полугодие' StrLabel,'Half-year' strValue, 'ru-RU' [LangID]
		UNION ALL
		SELECT N'Квартал' StrLabel,'Quarter' strValue, 'ru-RU' [LangID]
		UNION ALL
		SELECT N'Месяц' StrLabel,'Month' strValue, 'ru-RU' [LangID]
		UNION ALL
		SELECT N'İl' StrLabel,'Year' strValue, 'az-Latn-AZ' [LangID]
		UNION ALL
		SELECT N'Yarım il' StrLabel,'Half-year' strValue, 'az-Latn-AZ' [LangID]
		UNION ALL
		SELECT N'Rüb' StrLabel,'Quarter' strValue, 'az-Latn-AZ' [LangID]
		UNION ALL
		SELECT N'Ay' StrLabel,'Month' strValue, 'az-Latn-AZ' [LangID]
	) A
	WHERE [LangID]=@LangID
END

