
--*************************************************************************
-- Name 				: report.USP_REP_Years_GET
-- Description			: Get the List of Years form 2000 to current year
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
--
--EXEC report.USP_REP_Years_GET 
--*************************************************************************

CREATE PROCEDURE [Report].[USP_REP_Years_GET]
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @FromYear INT
			,@PreviousYears int
	SET @FromYear =2000
	SET @PreviousYears = 2100
	
    ;WITH yearlist AS 
    (
        SELECT @FromYear AS Year
        union all
        SELECT yl.Year + 1 AS Year
        FROM yearlist yl
        WHERE yl.Year + 1 <= @PreviousYears
    )
    
    SELECT Year FROM yearlist ORDER BY year DESC;
END
