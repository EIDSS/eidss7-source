
--=====================================================================================================
-- Name: USP_REF_STATISTICDATATYPE_GETDetail
-- Author:		Ricky Moss
-- Description:	Returns a statistical data type given a language id 
--
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		04/15/2020  Initial Release
-- 
-- Test Code:
-- EXEC USP_REF_STATISTICDATATYPE_GETDetail 'en', 39850000000
-- 
--=====================================================================================================

CREATE PROCEDURE [dbo].[USP_REF_STATISTICDATATYPE_GETDetail]
(
	@LangID		NVARCHAR(50),
	@idfsStatisticDataType BIGINT
)
AS
BEGIN
BEGIN TRY
	SELECT
		sdt.[idfsStatisticDataType],
		sdt.[idfsReferenceType],
		sdtpt.[name] as strParameterType,
		sdtbr.strDefault as [strDefault],
		sdtbr.[name] as [strName],
		ISNULL(sdt.[blnRelatedWithAgeGroup], 0) as [blnStatisticalAgeGroup],  -- statistical age group info needed per use case SAUC49
		sdt.[idfsStatisticPeriodType],
		sptbr.[name] as [strStatisticPeriodType], 
		sdt.[idfsStatisticAreaType],
		satbr.[name] as [strStatisticalAreaType]

	FROM [trtStatisticDataType] as sdt -- Statistic Data Type
	INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000090) sdtbr -- Statistic Data Type base reference
	ON sdt.idfsStatisticDataType = sdtbr.idfsReference
	LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000076) sdtpt 
	ON sdt.idfsReferenceType = sdtpt.idfsReference
	INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000091) sptbr -- Statistic Period Type
	ON sdt.idfsStatisticPeriodType = sptbr.idfsReference
	INNER JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000089) satbr -- Statistic Area Type
	ON sdt.idfsStatisticAreaType = satbr.idfsReference
	WHERE sdt.[intRowStatus] = 0 AND idfsStatisticDataType = @idfsStatisticDataType;
END TRY
BEGIN CATCH
	THROW
END CATCH
END
