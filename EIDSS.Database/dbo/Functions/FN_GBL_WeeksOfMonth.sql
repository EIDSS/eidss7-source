
--*************************************************************
-- Name 				: FN_GBL_WeeksOfMonth
-- Description			: returns the week span 
--						  for all weeks in a month 
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*

SELECT * FROM FN_GBL_WeeksOfMonth('01-01-2020')

*/
--*************************************************************

CREATE FUNCTION [dbo].[FN_GBL_WeeksOfMonth] 
(
	@date DATE
) 
RETURNS TABLE 
AS RETURN 
(


	WITH n AS 
	(
		SELECT 
			n 
		FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) t(n)
	), 
	
	dates AS 
	(
	  SELECT 
		TOP (DATEDIFF(DAY, @date, DATEADD(MONTH, DATEDIFF(MONTH, 0, @date )+1, 0))) 
		[DateValue]=CONVERT(DATE, DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) -1, @date))
	  FROM n 
	  CROSS JOIN n AS n2
	)
	SELECT 
		WeekOfMonth = ROW_NUMBER() OVER (ORDER BY DATEPART (WEEK, DateValue)),
		Week = DATEPART (WEEK, DateValue),
		WeekStart = MIN(DateValue),
		WeekEnd = MAX(DateValue)
	FROM dates
	GROUP BY DATEPART(WEEK,DateValue)
);
