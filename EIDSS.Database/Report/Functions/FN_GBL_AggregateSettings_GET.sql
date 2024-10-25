

----------------------------------------------------------------------------
-- Name 				: FN_GBL_AggregateSettings_GET
-- Description			: Get the Reference information, including translation
--						  for the data specified
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    23-Apr-2019   Convert EIDSS 6 to EIDSS 7 standards and 
--                              changed name FN_GBL_Reference_GET
--
----------------------------------------------------------------------------
-- Returns table with system aggregate settings
-- that defines minimal adninistrative unit and period Type for different aggregate cases types.
-- If NULL is passed as input aggregate case Type, settings for this Type only is selected.
-- In other case all settings are selected.

--Example of function call:
/*
DECLARE @idfsAggrCaseType bigint
SET  @idfsAggrCaseType = 10102001
SELECT * FROM FN_GBL_AggregateSettings_GET(@idfsAggrCaseType)
*/

CREATE FUNCTION [Report].[FN_GBL_AggregateSettings_GET]
(
	@idfsAggrCaseType BIGINT --@idfsAggrCaseType - aggregate case Type
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		R.idfsReference AS idfsAggrCaseType,
		CP.idfCustomizationPackage,
		CP.idfsCountry,
		ISNULL(T.idfsStatisticAreaType, 10089004) AS idfsStatisticAreaType, -- Settlement
		ISNULL(T.idfsStatisticPeriodType,10091002) AS idfsStatisticPeriodType -- Day

	FROM report.FN_GBL_ReferenceRepair_GET('en', 19000102) AS R -- Aggregate case Type

	LEFT OUTER JOIN dbo.tstAggrSetting AS T ON R.idfsReference = T.idfsAggrCaseType AND T.idfCustomizationPackage = report.FN_GBL_CustomizationPackage_GET()
	INNER JOIN dbo.tstCustomizationPackage CP ON CP.idfCustomizationPackage = report.FN_GBL_CustomizationPackage_GET()

	WHERE @idfsAggrCaseType IS NULL 
	OR R.idfsReference = @idfsAggrCaseType
)


