-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- report.FN_REP_LastDayOfMonth
--
-- created by Mark Wilson to generate a last day of month for reports where parms
-- are given as year and month
--
/*
	DECLARE @DATE DATE = '20190310'

	SELECT report.FN_REP_LastDayOfMonth(@Date)

*/
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

CREATE FUNCTION [Report].[FN_REP_LastDayOfMonth] 
(
    @Date DATETIME
)
RETURNS DATETIME
AS
BEGIN

    RETURN DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @Date) + 1, 0))

END

