
--*************************************************************************
-- Name 				: report.USP_REP_VET_SummarySurveillanceType
-- Description			: Used in Summary Veterinary Report to Populate Surveillance Type
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_SummarySurveillanceType 'en'
EXEC report.USP_REP_VET_SummarySurveillanceType 'ru'
EXEC report.USP_REP_VET_SummarySurveillanceType 'az-L'
*/ 

CREATE PROCEDURE [Report].[USP_REP_VET_SummarySurveillanceType]
(
	 @LangID			AS NVARCHAR(50)
)
AS

SELECT idfsSurveillance,StrName 
FROM
(
 SELECT 'en-US' AS [LangID],1 AS idfsSurveillance,N'Active Surveillance' AS StrName
 UNION ALL
 SELECT 'en-US' AS [LangID],2 AS idfsSurveillance,N'Passive Surveillance' AS StrName
 UNION ALL
 SELECT 'en-US' AS [LangID],3 AS idfsSurveillance,N'Aggregate actions' AS StrName
 UNION ALL
 SELECT 'ru' AS [LangID],1 AS idfsSurveillance,N'Активный надзор' AS StrName
 UNION ALL
 SELECT 'ru' AS [LangID],2 AS idfsSurveillance,N'Пассивный надзор' AS StrName
 UNION ALL
 SELECT 'ru' AS [LangID],3 AS idfsSurveillance,N'Агрегированные' AS StrName
 UNION ALL
 SELECT 'az-Latn-AZ' AS [LangID],1 AS idfsSurveillance,N'Fəal Müşahidə' AS StrName
 UNION ALL
 SELECT 'az-Latn-AZ' AS [LangID],2 AS idfsSurveillance,N'Passiv müşahidə' AS StrName
 UNION ALL
 SELECT 'az-Latn-AZ' AS [LangID],3 AS idfsSurveillance,N'Qrupşəkilli tədbirlər' AS StrName
 ) A
 WHERE [LangID]=@LangID 
 ORDER BY idfsSurveillance

