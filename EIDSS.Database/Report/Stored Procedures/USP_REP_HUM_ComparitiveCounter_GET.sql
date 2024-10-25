


/*
--*************************************************************
-- Name 				: report.USP_REP_HUM_ComparitiveCounter_GET
-- Description			: Procedure to return Value and ID for Dropdown 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- EXEC [report].[USP_REP_HUM_ComparitiveCounter_GET] 'en'
-- EXEC [report].[USP_REP_HUM_ComparitiveCounter_GET] 'az-L'
-- EXEC [report].[USP_REP_HUM_ComparitiveCounter_GET] 'ru'
--*************************************************************
*/
CREATE PROCEDURE [Report].[USP_REP_HUM_ComparitiveCounter_GET]
(
	@LangID NVARCHAR(50)
)
AS
	 
	  SELECT 
		  CAST(ID as INT) ID ,
		  CAST(Value AS NVARCHAR(250)) Value
	  FROM [report].[FN_REP_HUM_ComparitiveCounter_GET](@LangID) 

