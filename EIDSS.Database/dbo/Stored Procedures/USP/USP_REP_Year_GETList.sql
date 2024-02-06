
--*************************************************************************
-- Name 				: dbo.USP_REP_Year_GETList
-- Description			: Get the list of years for reports
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
--
--EXEC report.USP_REP_Year_GETList 
--*************************************************************************
CREATE PROCEDURE [dbo].[USP_REP_Year_GETList]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromYear INT,
		@PreviousYears INT;

	SET @FromYear = 2000;
	SET @PreviousYears = YEAR(GETDATE()) - @FromYear;

	WITH yearlist
	AS (
		SELECT YEAR(GETDATE()) - @PreviousYears AS Year
		
		UNION ALL
		
		SELECT yl.Year + 1 AS Year
		FROM yearlist yl
		WHERE yl.Year + 1 <= YEAR(GETDATE())
		)
	SELECT Year
	FROM yearlist
	ORDER BY year DESC;
END
