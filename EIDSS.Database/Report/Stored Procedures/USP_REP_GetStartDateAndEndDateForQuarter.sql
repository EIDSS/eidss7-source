

--*************************************************************************
-- Name 				: report.USP_REP_GetStartDateAndEndDateForQuarter
-- DescriptiON			: To get Start Date and End Date based on Year,Quarter selection.
--							--Used in GG ->Veterinary->Rabies Bulletin Europe � Quarterly Surveillance Sheet report
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_GetStartDateAndEndDateForQuarter '2020','1,3,4'
EXEC report.USP_REP_GetStartDateAndEndDateForQuarter '2020','2,4'
EXEC report.USP_REP_GetStartDateAndEndDateForQuarter '2020','1,2,3,4'
EXEC report.USP_REP_GetStartDateAndEndDateForQuarter '2020','1,2,3'
EXEC report.USP_REP_GetStartDateAndEndDateForQuarter '2020','1,2,4'
*/

CREATE PROCEDURE [Report].[USP_REP_GetStartDateAndEndDateForQuarter]
    (
		@Year AS VARCHAR(4)
		,@ReportingPeriod AS VARCHAR(MAX)
    )
AS
BEGIN

	DECLARE @ReportingPeriodTable TABLE ([key] NVARCHAR(300))
	DECLARE @StartDate VARCHAR(10) = NULL
			,@EndDate VARCHAR(10) = NULL
			,@StartDate2 VARCHAR(10) = NULL
			,@EndDate2 VARCHAR(10) = NULL
	
	INSERT INTO @ReportingPeriodTable 
	SELECT CAST([Value] AS NVARCHAR) FROM report.FN_GBL_SYS_SplitList(@ReportingPeriod,1,',')
	
	
	IF (@ReportingPeriod='1,2,3,4' OR @ReportingPeriod='1,2,3' OR @ReportingPeriod='2,3,4' OR @ReportingPeriod='3,4' OR @ReportingPeriod='3' OR @ReportingPeriod='4')
	BEGIN
		SELECT @StartDate=MIN(StartDate),@EndDate=MAX(EndDate)
			FROM
			(
				SELECT @Year as YearID,'Quarter' as PeriodType,'1' as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('03/01/'+@Year),'MM/dd/yyyy') as EndDate
				UNION
				SELECT @Year as YearID,'Quarter' as PeriodType,'2' as ID,'04/01/'+@Year as StartDate,FORMAT(EOMONTH('06/01/'+@Year),'MM/dd/yyyy') as EndDate
				UNION
				SELECT @Year as YearID,'Quarter' as PeriodType,'3' as ID,'07/01/'+@Year as StartDate,FORMAT(EOMONTH('09/01/'+@Year),'MM/dd/yyyy') as EndDate
				UNION
				SELECT @Year as YearID,'Quarter' as PeriodType,'4' as ID,'10/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
				
			) A
			WHERE YearID=@Year
				  AND ID IN (SELECT [key] FROM @ReportingPeriodTable)
	END
	ELSE
	BEGIN
	
		SELECT @StartDate=MIN(StartDate),@EndDate=MAX(EndDate)
		FROM
		(
			SELECT @Year as YearID,'Quarter' as PeriodType,'1' as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('03/01/'+@Year),'MM/dd/yyyy') as EndDate
			UNION
			SELECT @Year as YearID,'Quarter' as PeriodType,'2' as ID,'04/01/'+@Year as StartDate,FORMAT(EOMONTH('06/01/'+@Year),'MM/dd/yyyy') as EndDate
			UNION
			SELECT @Year as YearID,'Quarter' as PeriodType,'3' as ID,'07/01/'+@Year as StartDate,FORMAT(EOMONTH('09/01/'+@Year),'MM/dd/yyyy') as EndDate
			UNION
			SELECT @Year as YearID,'Quarter' as PeriodType,'4' as ID,'10/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
			
		) A
		WHERE YearID=@Year
			  AND ID IN (SELECT [key] FROM @ReportingPeriodTable WHERE [key] in(1,2))
			 
		SELECT @StartDate2=MIN(StartDate),@EndDate2=MAX(EndDate)
		FROM
		(
			SELECT @Year as YearID,'Quarter' as PeriodType,'1' as ID,'01/01/'+@Year as StartDate,FORMAT(EOMONTH('03/01/'+@Year),'MM/dd/yyyy') as EndDate
			UNION
			SELECT @Year as YearID,'Quarter' as PeriodType,'2' as ID,'04/01/'+@Year as StartDate,FORMAT(EOMONTH('06/01/'+@Year),'MM/dd/yyyy') as EndDate
			UNION
			SELECT @Year as YearID,'Quarter' as PeriodType,'3' as ID,'07/01/'+@Year as StartDate,FORMAT(EOMONTH('09/01/'+@Year),'MM/dd/yyyy') as EndDate
			UNION
			SELECT @Year as YearID,'Quarter' as PeriodType,'4' as ID,'10/01/'+@Year as StartDate,FORMAT(EOMONTH('12/01/'+@Year),'MM/dd/yyyy') as EndDate
			
		) A
		WHERE YearID=@Year
			  AND ID IN (SELECT [key] FROM @ReportingPeriodTable WHERE [key] in(3,4)) 
	END
	   
	SELECT @StartDate AS StartDate,@EndDate AS EndDate, @StartDate2 AS StartDate2,@EndDate2 AS EndDate2
END

