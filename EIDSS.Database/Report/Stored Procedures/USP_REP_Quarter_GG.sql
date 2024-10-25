

--*************************************************************************
-- Name 				: report.USP_REP_Quarter_GG
-- DescriptiON			: To get Reporting Periods.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_Quarter_GG 'en','2020'
*/

CREATE PROCEDURE [Report].[USP_REP_Quarter_GG]
    (
		@LangID AS NVARCHAR(10) 
        ,@Year AS VARCHAR(4)
    )
AS
BEGIN
	SELECT PeriodType,ID,TextValue
	FROM
	(
		SELECT 1 as OrderID,'Quarter' as PeriodType,'1' as ID,'I (01.01.'+@Year +' - '+'31.03.'+@Year+')' as TextValue
		UNION
		SELECT 2 as OrderID,'Quarter' as PeriodType,'2' as ID,'II (01.04.'+@Year +' - '+'30.06.'+@Year+')' as TextValue
		UNION
		SELECT 3 as OrderID,'Quarter' as PeriodType,'3' as ID,'III (01.07.'+@Year +' - '+'30.09.'+@Year+')' as TextValue
		UNION
		SELECT 4 as OrderID,'Quarter' as PeriodType,'4' as ID,'IV (01.10.'+@Year +' - '+'31.12.'+@Year+')' as TextValue
	) A
	ORDER BY OrderID 
END

