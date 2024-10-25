



--*************************************************************************
-- Name 				: report.USP_REP_VET_DateFieldSource_GET
-- Description			: To Get VET DateFieldSource Details
--						  - used in Reports to Get VET DateFieldSource
--          
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--
-- Testing code:
--
-- EXEC report.USP_REP_VET_DateFieldSource_GET 'ka-GE'
-- EXEC report.USP_REP_VET_DateFieldSource_GET 'en-US'
-- EXEC report.USP_REP_VET_DateFieldSource_GET 'ru-RU'
-- EXEC report.USP_REP_VET_DateFieldSource_GET 'az-Latn-AZ'
--*************************************************************************



CREATE PROCEDURE  [Report].[USP_REP_VET_DateFieldSource_GET]
	 @LangID NVARCHAR(50) 
AS
BEGIN
DECLARE @strLangID NVARCHAR(5)	
DECLARE @DateFieldSource TABLE
(
	intDateFieldSource INT,
	strstrDateFieldSource NVARCHAR(20),
	[LangID] NVARCHAR(5)

)

;WITH DateOptions (intDateFieldSource, strDateFieldSource,[LangID]) AS
(
	SELECT 
		1 AS intDateFieldSource,
		N'Data Entry Date' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'Date of Diagnosis' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'Initial Report Date' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'Investigation Date' AS strDateFieldSource,
		N'en-US' AS [LangID]
	--Georgian
	UNION ALL
	SELECT 
		1 AS intDateFieldSource,
		N'შეყვანის თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'დიაგნოზის დასმის თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'საწყისი შეტყობინების თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'მოკვლევის დასრულების თარიღი' AS strDateFieldSource,
		'ka-GE' AS [LangID]
	--Russian
	UNION ALL
	SELECT 
		1 AS intDateFieldSource,
		N'Дата ввода данных' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'Дата постановки диагноза' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'Дата сообщения' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'Дата расследования' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	--Azerbajan
	UNION ALL
		SELECT 
		1 AS intDateFieldSource,
		N'Məlumatın daxil edilmə tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'Diaqnoz tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'İlkin hesabat tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'Tədqiqat aparılma tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]

)


SELECT intDateFieldSource,strDateFieldSource FROM DateOptions WHERE [LangID]=IIF((SELECT COUNT(1) FROM DateOptions WHERE [LangID]=@LangID)=0 ,'en-US',@LangID)
END


