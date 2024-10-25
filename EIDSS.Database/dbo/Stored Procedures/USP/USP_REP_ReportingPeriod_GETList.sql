

--*************************************************************************
-- Name 				: dbo.USP_REP_ReportingPeriod_GETList
-- DescriptiON			: To get Reporting Periods.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC dbo.USP_REP_ReportingPeriod 'en','2020','Year'
EXEC dbo.USP_REP_ReportingPeriod 'ru','2020','Half-year'
EXEC dbo.USP_REP_ReportingPeriod 'en','2020','Quarter'
EXEC dbo.USP_REP_ReportingPeriod 'az-L','2020','Month'
*/

CREATE PROCEDURE [dbo].[USP_REP_ReportingPeriod_GETList]
    (
		@LangID AS NVARCHAR(10) 
        ,@Year AS VARCHAR(4)
		,@ReportingPeriodType AS VARCHAR(20)
    )
AS
BEGIN
	SELECT PeriodType,ID,TextValue
	FROM
	(
		SELECT @Year as OrderID,'Year' as PeriodType,@Year as ID,@Year as TextValue
		UNION
		SELECT 1 as OrderID,'Half-year' as PeriodType,'1' as ID,'I' as TextValue
		UNION
		SELECT 2 as OrderID,'Half-year' as PeriodType,'2' as ID,'II' as TextValue
		UNION
		SELECT 3 as OrderID,'Quarter' as PeriodType,'1' as ID,'1' as TextValue
		UNION
		SELECT 4 as OrderID,'Quarter' as PeriodType,'2' as ID,'2' as TextValue
		UNION
		SELECT 5 as OrderID,'Quarter' as PeriodType,'3' as ID,'3' as TextValue
		UNION
		SELECT 6 as OrderID,'Quarter' as PeriodType,'4' as ID,'4' as TextValue
		UNION
		SELECT intOrder AS OrderID,
			   'Month' AS PeriodType,
			   CAST(intOrder AS VARCHAR) AS ID,
			   a.strTextString AS TextValue
		FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000132) a
		WHERE  a.strDefault in ('January','February','March','April','May','June','July','August','September','October','November','December')
	) A
	WHERE PeriodType=@ReportingPeriodType
	ORDER BY OrderID 
END

