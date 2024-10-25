

--*************************************************************
-- Name 				: FN_GBL_NextNumbers_GetList
-- Description			: The FUNCTION returns next idf values 
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
-- Mark Wilson   11/06/2020   updated to use FN_GBL_AlphNumeric_GET
--
-- Testing code:
-- SELECT * FROM FN_GBL_NextNumbers_GetList('ru')
-- SELECT * FROM FN_GBL_NextNumbers_GetList('en')
--*************************************************************


CREATE FUNCTION [dbo].[FN_GBL_NextNumbers_GetList]
(
	@LangID as nvarchar(50)--##PARAM @LangID - language ID
)
RETURNS TABLE 
AS
RETURN

	SELECT
		nn.[idfsNumberName], 
		nn.[strPrefix], 
 		intNumberValue =
		CASE ISNULL(nn.blnUseAlphaNumericValue, 0)
			WHEN 0 THEN CAST(ISNULL(nn.[intNumberValue], 0) AS VARCHAR(100))
			WHEN 1 THEN dbo.FN_GBL_AlphNumeric_GET(ISNULL(nn.[intNumberValue], 0), ISNULL(intMinNumberLength,4))
		END,
		nn.[intMinNumberLength], 
		NumberingType.[name] AS strObjectName

	FROM dbo.tstNextNumbers nn

	LEFT JOIN FN_GBL_ReferenceRepair(@LangID, 19000057) NumberingType ON NumberingType.idfsReference = nn.idfsNumberName

