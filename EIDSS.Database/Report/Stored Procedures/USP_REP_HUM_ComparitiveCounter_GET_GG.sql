


/*
--*************************************************************
-- Name 				: [report].USP_REP_HUM_ComparitiveCounter_GET_GG
-- Description			: Procedure to return Value and ID for Dropdown 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- EXEC [report].[USP_REP_HUM_ComparitiveCounter_GET_GG] 'en-US'
-- EXEC [report].[USP_REP_HUM_ComparitiveCounter_GET_GG] 'ka-GE'
-- EXEC [report].[USP_REP_HUM_ComparitiveCounter_GET_GG] 'ru-RU'
--*************************************************************
*/
CREATE PROCEDURE [Report].[USP_REP_HUM_ComparitiveCounter_GET_GG]
(
	@LangID NVARCHAR(50)
)
AS
	DECLARE @ReportTable table
	(
		[ID] INT NOT NULL,
		[Value] nvarchar(250) NOT NULL
	)

	 INSERT INTO @ReportTable(ID, [Value])
	 SELECT 
		  CAST(ID as INT) ID ,
		  CAST(Value AS NVARCHAR(250)) Value
	  FROM [report].[FN_REP_HUM_ComparitiveCounter_GET_GG](@LangID) 

	  SELECT ID,
			 [Value]
	  FROM @ReportTable



