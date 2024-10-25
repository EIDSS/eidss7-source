
--*************************************************************************
-- Name 				: dbo.USP_REP_VET_SummarySurveillanceType_GetList
-- Description			: Used in Summary Veterinary Report to Populate Surveillance Type
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC dbo.USP_REP_VET_SummarySurveillanceType_GetList 'en'
EXEC dbo.USP_REP_VET_SummarySurveillanceType_GetList 'ru'
EXEC dbo.USP_REP_VET_SummarySurveillanceType_GetList 'az-L'
*/ 

CREATE PROCEDURE [dbo].[USP_REP_VET_SummarySurveillanceType_GetList]
(
	 @LangID			AS NVARCHAR(50)
)
AS

SELECT idfsSurveillance,StrName 
FROM
(
 SELECT 'en' AS [LangID],1 AS idfsSurveillance,N'Active Surveillance' AS StrName
 UNION ALL
 SELECT 'en' AS [LangID],2 AS idfsSurveillance,N'Passive Surveillance' AS StrName
 UNION ALL
 SELECT 'en' AS [LangID],3 AS idfsSurveillance,N'Aggregate actions' AS StrName
 UNION ALL
 SELECT 'ru' AS [LangID],1 AS idfsSurveillance,N'Активный надзор' AS StrName
 UNION ALL
 SELECT 'ru' AS [LangID],2 AS idfsSurveillance,N'Пассивный надзор' AS StrName
 UNION ALL
 SELECT 'ru' AS [LangID],3 AS idfsSurveillance,N'Агрегированные' AS StrName
 UNION ALL
 SELECT 'az-L' AS [LangID],1 AS idfsSurveillance,N'Fəal Müşahidə' AS StrName
 UNION ALL
 SELECT 'az-L' AS [LangID],2 AS idfsSurveillance,N'Passiv müşahidə' AS StrName
 UNION ALL
 SELECT 'az-L' AS [LangID],3 AS idfsSurveillance,N'Qrupşəkilli tədbirlər' AS StrName
 ) A
 WHERE [LangID]=@LangID 
 ORDER BY idfsSurveillance
