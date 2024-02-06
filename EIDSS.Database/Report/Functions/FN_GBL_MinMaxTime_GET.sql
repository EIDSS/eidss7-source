

--*************************************************************
-- Name 				: FN_GBL_MinMaxTime_GET
-- Description			: Returns minimum or maximum datetime for a date. 
--						
-- Author               : Maheshwar Deo
-- Revision History
--
-- Testing code:
/*
-- Pass 0 for minimum time, 1 for maximum time

select report.FN_GBL_MinMaxTime_GET ('12/03/2009 12:01:43', 0) -- min
select report.FN_GBL_MinMaxTime_GET ('12/03/2009 12:01:43', 1) -- max
*/

CREATE FUNCTION [Report].[FN_GBL_MinMaxTime_GET] (@InputDate AS DATETIME, @MaxTime AS BIT) 
RETURNS DATETIME
AS
BEGIN
	DECLARE @time AS VARCHAR(10)
  
	IF (@MaxTime = 0)
		SET @time = ' 00:00:00'
	ELSE
		SET @time = ' 23:59:59'

	RETURN CONVERT(DATETIME, STR(YEAR(@InputDate)) + '-' + STR(MONTH(@InputDate)) + '-' + STR(DAY(@InputDate)) + @time, 20)

END


