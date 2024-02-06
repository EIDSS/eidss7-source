-- ================================================================================================
-- Name: dbo.USP_REP_Month_Names_GETList
--
-- Description: Get month names list for report drop downs.
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name              Date       Change Detail
-- ----------------- ---------- ------------------------------------------------------------------
--
-- Testing code:
--
-- Example of procedure call:
-- EXEC dbo.USP_REP_MonthNames_GET 'ru' 
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REP_Month_Names_GETList] @LangID AS NVARCHAR(50)
AS
BEGIN
	SELECT a.idfsReference AS MonthID,
		a.strDefault AS DefaultText,
		a.strTextString AS TranslatedText,
		intOrder AS OrderNumber
	FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000132) a
	WHERE a.strDefault IN (
			'January',
			'February',
			'March',
			'April',
			'May',
			'June',
			'July',
			'August',
			'September',
			'October',
			'November',
			'December'
			)
	ORDER BY intOrder;
END
