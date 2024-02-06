



--*************************************************************************
-- Name 				: report.USP_REP_GBL_Facilities_GET
-- Description			: List of Spacific Facilities
--						  - to select on or all facilities
--          
-- Author               : Mark Wilson
-- Revision History
--		Name			Date       Change Detail
-- -------------------- ---------- ---------------------------------------
-- Stephen Long         05/08/2023 Changed from institution repair to min.
--
-- Testing code:
--
-- EXEC report.USP_REP_GBL_Facilities_GET 'ka'
-- EXEC report.USP_REP_GBL_Facilities_GET 'en', 2
--*************************************************************************
CREATE PROCEDURE [Report].[USP_REP_GBL_Facilities_GET] 
(
	@LangID NVARCHAR(50) = 'en-US',	--##PARAM @LangID - language ID
	@intHACode INT = NULL
)
AS	
BEGIN	
	SELECT 
		idfOffice,
		AbbreviatedName AS OfficeName
	FROM dbo.FN_GBL_Institution_Min(@LangID)
	WHERE @intHACode IN (SELECT CAST(intHACode AS INT) FROM dbo.FN_GBL_SplitHACode(intHACode,510))	
	OR @intHACode IS NULL;
END




