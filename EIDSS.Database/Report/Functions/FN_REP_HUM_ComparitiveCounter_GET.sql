

/*
--*************************************************************
-- Name 				: report.FN_REP_HUM_ComparitiveCounter_GET
-- Description			: Funtion to return Value and ID for Dropdown 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- SELECT ID,Value FROM [report].[FN_REP_HUM_ComparitiveCounter_GET]('en-US')  
-- SELECT ID,Value FROM [report].[FN_REP_HUM_ComparitiveCounter_GET]('az-Latn-AZ') 
--*************************************************************
*/
CREATE FUNCTION [Report].[FN_REP_HUM_ComparitiveCounter_GET]
(
	@LangID NVARCHAR(50)
)
RETURNS TABLE
AS
	
	RETURN(
        SELECT ID,Value FROM
        (
	    SELECT 1 as ID, N'Absolute number' Value,'en-US' as LangID
	    UNION
	    SELECT 2 as ID, N'For 10.000 population' Value,'en-US' as LangID
	    UNION
	    SELECT 3 as ID, N'For 100.000 population' Value,'en-US' as LangID
	    UNION
	    SELECT 4 as ID, N'For 1.000.000 population' Value,'en-US' as LangID
	    UNION
	    SELECT 1 as ID, N'Абсолютное число' Value,'ru-RU' as LangID
	    UNION
	    SELECT 2 as ID, N'Для 10.000 населения' Value,'ru-RU' as LangID
	    UNION
	    SELECT 3 as ID, N'Для 100.000 населения' Value,'ru-RU' as LangID
	    UNION
	    SELECT 4 as ID, N'Для 1.000.000 населения' Value,'ru-RU' as LangID
	    UNION
	    SELECT 1 as ID, N'Mütləq sayı' Value,'az-Latn-AZ' as LangID
	    UNION
	    SELECT 2 as ID, N'10.000 əhali üçün' Value,'az-Latn-AZ' as LangID
	    UNION
	    SELECT 3 as ID, N'100.000 əhali üçün' Value,'az-Latn-AZ' as LangID
	    UNION
	    SELECT 4 as ID, N'1.000.000 əhali üçün' Value,'az-Latn-AZ' as LangID
	    ) A
	    WHERE LangID=@LangID 
		)

