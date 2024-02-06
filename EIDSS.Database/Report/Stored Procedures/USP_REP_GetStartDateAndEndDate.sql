
--*************************************************************************
-- Name 				: report.USP_REP_GetStartDateAndEndDate
-- DescriptiON			: To get Start Date and End Date based on Year,Reporting Period Type and Reporting Period.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_GetStartDateAndEndDate '2020','Year','2020'
EXEC report.USP_REP_GetStartDateAndEndDate '2020','Half-year','2'
EXEC report.USP_REP_GetStartDateAndEndDate '2020','Quarter','3'
EXEC report.USP_REP_GetStartDateAndEndDate '2020','Month','12'
*/

CREATE PROCEDURE [Report].[USP_REP_GetStartDateAndEndDate]
    (
		@Year AS VARCHAR(4)
		,@ReportingPeriodType AS VARCHAR(20)
		,@ReportingPeriod AS VARCHAR(20)
    )
AS
BEGIN

	SELECT StartDate,EndDate
	FROM
	(
		SELECT @Year as YearID,'Year' as PeriodType,@Year  as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Half-Year' as PeriodType,'1' as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('06/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Half-Year' as PeriodType,'2' as ID,'06/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Quarter' as PeriodType,'1' as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('03/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Quarter' as PeriodType,'2' as ID,'04/01/'+@Year as StartDate,FORMAT(EOMONTH('06/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Quarter' as PeriodType,'3' as ID,'07/01/'+@Year as StartDate,FORMAT(EOMONTH('09/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Quarter' as PeriodType,'4' as ID,'10/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'1' as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('01/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'2' as ID,'02/01/'+@Year as StartDate,FORMAT(EOMONTH('02/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'3' as ID,'03/01/'+@Year as StartDate,FORMAT(EOMONTH('03/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'4' as ID,'04/01/'+@Year as StartDate,FORMAT(EOMONTH('04/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'5' as ID,'05/01/'+@Year as StartDate,FORMAT(EOMONTH('05/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'6' as ID,'06/01/'+@Year as StartDate,FORMAT(EOMONTH('06/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'7' as ID,'07/01/'+@Year as StartDate,FORMAT(EOMONTH('07/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'8' as ID,'08/01/'+@Year as StartDate,FORMAT(EOMONTH('08/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'9' as ID,'09/01/'+@Year as StartDate,FORMAT(EOMONTH('09/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'10' as ID,'10/01/'+@Year as StartDate,FORMAT(EOMONTH('10/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'11' as ID,'11/01/'+@Year as StartDate,FORMAT(EOMONTH('11/01/'+@Year),'MM/dd/yyyy') as EndDate
		UNION
		SELECT @Year as YearID,'Month' as PeriodType,'12' as ID,'12/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
	) A
	WHERE YearID=@Year
		  AND PeriodType=@ReportingPeriodType
		  ANd ID=@ReportingPeriod
		  
END
