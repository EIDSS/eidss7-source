
--*************************************************************************
-- Name 				: report.USP_REP_VET_NameOfInvestigationOrMeasureSelectLookup
-- Description			: Used in Summary Veterinary Report to get Name Of Investigation/Measure
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_NameOfInvestigationOrMeasureSelectLookup 'en'
*/ 
 
CREATE PROCEDURE [Report].[USP_REP_VET_NameOfInvestigationOrMeasureSelectLookup]
	@LangID AS VARCHAR(36)
AS
BEGIN
	
	SELECT
		idfsReference
		, strName
		, ROW_NUMBER() OVER (ORDER BY a, intOrder, strName) AS intOrder
	FROM (
		SELECT 
				0 AS idfsReference
				,'' AS strName
				,0 AS intOrder
				,0 AS a
		UNION ALL
		SELECT 
			idfsReference 
			, [name] AS strName
			, intOrder
			, 1 a
		FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000021 /*Diagnostic Investigation List*/)
		UNION ALL
		SELECT 
			idfsReference 
			, [name] AS strName
			, intOrder
			, 2
		FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000074 /*Prophylactic Measure List*/)
	) x

END

