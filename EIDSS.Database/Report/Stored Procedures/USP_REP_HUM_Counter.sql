

--*************************************************************************
-- Name 				: report.USP_REP_HUM_Counter
-- DescriptiON			: To get Counters.  --Refer report.USP_REP_ReportingPeriodType
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_HUM_Counter @LangID=N'en-US'
EXEC report.USP_REP_HUM_Counter @LangID=N'ru'
EXEC report.USP_REP_HUM_Counter @LangID=N'az-Latn-AZ'
*/

CREATE PROCEDURE [Report].[USP_REP_HUM_Counter]
    (
        @LangID AS NVARCHAR(10)
    )
AS
BEGIN
	SELECT StrLabel,StrValue
	FROM
	(
		SELECT N'Absolute number' StrLabel,'1' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'For 10.000 population' StrLabel,'2' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'For 100.000 population' StrLabel,'3' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'For 1.000.000 population' StrLabel,'4' strValue, 'en-US' [LangID]
		UNION ALL
		SELECT N'Абсолютное число' StrLabel,'1' strValue, 'ru' [LangID]
		UNION ALL
		SELECT N'На 10.000 населения' StrLabel,'2' strValue, 'ru' [LangID]
		UNION ALL
		SELECT N'На 100.000 населения' StrLabel,'3' strValue, 'ru' [LangID]
		UNION ALL
		SELECT N'На 1.000.000 населения' StrLabel,'4' strValue, 'ru' [LangID]
		UNION ALL
		SELECT N'Mütləq qiymət' StrLabel,'1' strValue, 'az-Latn-AZ' [LangID]
		UNION ALL
		SELECT N'10.000 əhaliyə görə' StrLabel,'2' strValue, 'az-Latn-AZ' [LangID]
		UNION ALL
		SELECT N'100.000 əhaliyə görə' StrLabel,'3' strValue, 'az-Latn-AZ' [LangID]
		UNION ALL
		SELECT N'1.000.000 əhaliyə görə' StrLabel,'4' strValue, 'az-Latn-AZ' [LangID]
	) A
	WHERE [LangID]=@LangID
END

