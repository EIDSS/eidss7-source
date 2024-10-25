

/*
--*************************************************************
-- Name 				: report.FN_REP_HUM_ComparitiveCounter_GET_GG
-- Description			: Funtion to return Counter Value and ID for Dropdown in Georgian Reports
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- SELECT ID,Value FROM [report].[FN_REP_HUM_ComparitiveCounter_GET_GG]('en-US')  
-- SELECT ID,Value FROM [report].[FN_REP_HUM_ComparitiveCounter_GET_GG]('ka-GE') 
-- SELECT ID,Value FROM [report].[FN_REP_HUM_ComparitiveCounter_GET_GG]('ru-RU') 
--*************************************************************
*/
CREATE FUNCTION [Report].[FN_REP_HUM_ComparitiveCounter_GET_GG]
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
	    SELECT 2 as ID, N'Percentage' Value,'en-US' as LangID
	    UNION
	    SELECT 1 as ID, N'Абсолютное число' Value,'ru-RU' as LangID
	    UNION
	    SELECT 2 as ID, N'Процент' Value,'ru-RU' as LangID
	    UNION
	    SELECT 1 as ID, N'აბსოლუტური რიცხვი' Value,'ka-GE' as LangID
	    UNION
	    SELECT 2 as ID, N'პროცენტი' Value,'ka-GE' as LangID
	    ) A
	    WHERE LangID=@LangID 
		)

