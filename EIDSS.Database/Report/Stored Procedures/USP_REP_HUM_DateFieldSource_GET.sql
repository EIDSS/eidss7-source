



--*************************************************************************
-- Name 				: report.USP_REP_HUM_DateFieldSource_GET
-- Description			: To Get HUM DateFieldSource Details
--						  - used in Reports to Get HUM DateFieldSource
--          
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--
-- Testing code:
--
-- EXEC report.USP_REP_HUM_DateFieldSource_GET 'ka-GE'
-- EXEC report.USP_REP_HUM_DateFieldSource_GET 'en-US'
-- EXEC report.USP_REP_HUM_DateFieldSource_GET 'ru-RU'
-- EXEC report.USP_REP_HUM_DateFieldSource_GET 'az-Latn-AZ'
--*************************************************************************



CREATE PROCEDURE  [Report].[USP_REP_HUM_DateFieldSource_GET]
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
		N'Date of Symptoms Onset' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'Notification Date' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'Diagnosis Date' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'Date of Changed Diagnosis' AS strDateFieldSource,
		N'en-US' AS [LangID]
	UNION ALL
	SELECT 
		5 AS intDateFieldSource,
		N'Date Entered' AS strDateFieldSource,
		N'en-US' AS [LangID]
	--Georgian
	UNION ALL
	SELECT 
		1 AS intDateFieldSource,
		N'სიმპტომების დაწყების თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'შეტყობინების თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'დიაგნოზის დასმის თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'დიაგნოზის შეცვლის თარიღი' AS strDateFieldSource,
		'ka-GE' AS [LangID]
	UNION ALL
	SELECT 
		5 AS intDateFieldSource,
		N'შეყვანის თარიღი' AS strDateFieldSource,
		N'ka-GE' AS [LangID]
	--Russian
	UNION ALL
	SELECT 
		1 AS intDateFieldSource,
		N'Дата появления симптомов' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'Дата извещения' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'Дата текущего диагноза' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'Дата изменения диагноза' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	UNION ALL
	SELECT 
		5 AS intDateFieldSource,
		N'Дата ввода' AS strDateFieldSource,
		N'ru-RU' AS [LangID]
	--Azerbajan
	UNION ALL
		SELECT 
		1 AS intDateFieldSource,
		N'Simptomların başlanma tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		2 AS intDateFieldSource,
		N'Bildiriş tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		3 AS intDateFieldSource,
		N'Diaqnozun qoyulma tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		4 AS intDateFieldSource,
		N'Dəyişdirilmiş diaqnozun tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
	UNION ALL
	SELECT 
		5 AS intDateFieldSource,
		N'Daxil olma tarixi' AS strDateFieldSource,
		N'az-Latn-AZ' AS [LangID]
)


SELECT intDateFieldSource,strDateFieldSource FROM DateOptions WHERE [LangID]=IIF((SELECT COUNT(1) FROM DateOptions WHERE [LangID]=@LangID)=0 ,'en-US',@LangID)
END


