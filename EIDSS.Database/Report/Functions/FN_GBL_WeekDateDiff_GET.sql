
----------------------------------------------------------------------------
-- Name 				: FN_GBL_WeekDateDiff_GET
-- Description			: the return value of this function depends on the value 
--						  that is set by using SET DATEFIRST
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    23-Apr-2019   Convert EIDSS 6 to EIDSS 7 standards and 
--                              changed name FN_GBL_WeekDateDiff_GET
--
-- Testing code:
-- SELECT report.FN_GBL_WeekDateDiff_GET('23-Apr-2019', '23-May-2019')  -- returns number of weeks between the dates
----------------------------------------------------------------------------

CREATE FUNCTION [Report].[FN_GBL_WeekDateDiff_GET] 
(
	@StartDate DATETIME, 
	@EndDate DATETIME
)

RETURNS INT
AS
BEGIN

	DECLARE @SDate DATETIME
	DECLARE @EDate DATETIME
	DECLARE @sgn INT

	IF @StartDate > @EndDate
	BEGIN
		SET @sgn = -1
		SET @SDate = @EndDate
		SET @EDate = @StartDate
	END
	ELSE
	BEGIN
		SET @sgn = 1
		SET @SDate = @StartDate
		SET @EDate = @EndDate
	END

	-- move to the last "first week day"
	SET @SDate = DATEADD(DAY, 1 - DATEPART(dw, @SDate) , @SDate)
	SET @EDate = DATEADD(DAY, 1 - DATEPART(dw, @EDate) , @EDate)

	RETURN @sgn * DATEDIFF(wk, @SDate, @EDate)
END

