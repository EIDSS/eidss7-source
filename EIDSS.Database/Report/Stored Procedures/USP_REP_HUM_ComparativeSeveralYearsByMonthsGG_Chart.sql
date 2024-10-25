





-- This stored proc is to be used for the report:
--
--	Comparative Report of Several Years by Months
--
--  Mark Wilson updated for EIDSS7 standards
--
-- The USP_REP_HUM_ComparativeSeveralYearsByMonthsGG must be run prior to this to
-- create the temporary report table

/*
--Example of a call of procedure:

EXEC report.USP_REP_HUM_ComparativeSeveralYearsByMonthsGG_Chart 

*/ 
 
CREATE PROCEDURE [Report].[USP_REP_HUM_ComparativeSeveralYearsByMonthsGG_Chart]
AS
BEGIN
-- Read the table if it exists.  otherwise, drop it

	SELECT 
		RT.intYear AS [Year],
		RT.intMonth,
		CASE RT.intMonth 
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			WHEN 12 THEN 'December'
			ELSE NULL
		END AS [MonthName],
		RT.intTotal AS MonthTotal,
		CAST((RT.intTotal * 100) AS DECIMAL(12,2)) / CAST((SELECT CASE WHEN SUM(RTT.intTotal) = 0 THEN 1 ELSE SUM(RTT.intTotal) END FROM report.HumComparativeSeveralYearsByMonthsGG RTT WHERE RTT.intYear = RT.intYear) AS DECIMAL(12,2)) AS Pct
	FROM report.HumComparativeSeveralYearsByMonthsGG RT
	ORDER BY 
		RT.intYear DESC,
		RT.intMonth 

END
	

