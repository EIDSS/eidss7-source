

---*************************************************************************
-- Name 				: report.FN_AggregateSettings_GET
-- Description			: returns table with system aggregate settings.
--          
-- Author               : Mark Wilson - converted to E7
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:-##SUMMARY Returns table with system aggregate settings

/*
--Example of function call:
DECLARE @idfsAggrCaseType bigint
SET  @idfsAggrCaseType = 10102001
SELECT * FROM report.FN_AggregateSettings_GET(@idfsAggrCaseType)

*/

CREATE FUNCTION [Report].[FN_AggregateSettings_GET]
(
	@idfsAggrCaseType BIGINT --##PARAM @idfsAggrCaseType - aggregate case Type
)
RETURNS TABLE
AS
RETURN(

SELECT 
	ACT.idfsReference AS idfsAggrCaseType,
	tcp1.idfCustomizationPackage,
	tcp1.idfsCountry,
	ISNULL(TAS.idfsStatisticAreaType,10089004/*Settlement*/) AS idfsStatisticAreaType,
	ISNULL(TAS.idfsStatisticPeriodType,10091002/*Day*/) AS idfsStatisticPeriodType

FROM dbo.FN_GBL_Reference_GETList('en-US',19000102 /*Aggregate case Type*/) ACT
LEFT OUTER JOIN tstAggrSetting TAS ON ACT.idfsReference = TAS.idfsAggrCaseType AND TAS.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
INNER JOIN tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
WHERE 
	(@idfsAggrCaseType IS NULL OR ACT.idfsReference = @idfsAggrCaseType)
)











