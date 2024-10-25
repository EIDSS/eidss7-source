

--*************************************************************************
-- Name 				: report.USP_REP_ADM_UniEventLog
-- Description			: Select event log records.
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
/*

EXEC report.USP_REP_ADM_UniEventLog 'en','01/01/16','01/01/20'

*/

CREATE  PROCEDURE [Report].[USP_REP_ADM_UniEventLog]
	(@LangID AS NVARCHAR(50),
	 @SD AS NVARCHAR(20), 
	 @ED AS NVARCHAR(20))
AS	

	DECLARE @SDDate AS DATETIME
	DECLARE @EDDate AS DATETIME

	SET @SDDate=report.FN_GBL_MinMaxTime_GET(CAST(@SD AS DATETIME),0)
	SET @EDDate=report.FN_GBL_MinMaxTime_GET(CAST(@ED AS DATETIME),1)

	SELECT		* 
	FROM		report.FN_Event_SelectList (@LangID) AS a
	WHERE		datEventDatatime between @SDDate and @EDDate
	ORDER BY	datEventDatatime



