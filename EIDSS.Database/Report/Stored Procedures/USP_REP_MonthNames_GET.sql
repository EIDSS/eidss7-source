
--*************************************************************************
-- Name 				: report.USP_REP_MonthNames_GET
-- Description			: To Get Month Names for Dropdown List 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_MonthNames_GET 'en-US' 
*/
    
CREATE PROCEDURE [Report].[USP_REP_MonthNames_GET]
	@LangID AS NVARCHAR(50)
AS
BEGIN
SELECT 0 as idfsReference,
       '' as strDefault,
       '' as strTextString,
       0 as intOrder
UNION
SELECT a.idfsReference,
	   a.strDefault,
	   a.strTextString,
	   intOrder
FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000132) a
WHERE a.strDefault in ('January','February','March','April','May','June','July','August','September','October','November','December')
ORDER BY intOrder
END
