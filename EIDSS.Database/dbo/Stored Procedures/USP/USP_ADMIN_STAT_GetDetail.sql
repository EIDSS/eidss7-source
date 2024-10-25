
--*************************************************************
-- Name 				: USP_ADMIN_STAT_GetDetail
-- Description			: Get Settlement details
--          
-- Author               : Maheshwar D Deo
-- Revision History
--		Name       Date       Change Detail
--LAMONT		4-30-22		ADDED LOCATION HIERARCHY
--
-- Testing code:
--EXECUTE USP_ADMIN_STAT_GetDetail 53361450000337,'en-US'
--*************************************************************

CREATE PROCEDURE [dbo].[USP_ADMIN_STAT_GetDetail]
(
 @idfStatistic	BIGINT,		--##PARAM @idfStatistic - statistic record ID
 @LangID		NVARCHAR(50) --##PARAM @LangID - languageID
)
AS
BEGIN

	BEGIN TRY  	

		SELECT	tlbStatistic.idfStatistic,
			tlbStatistic.idfsStatisticDataType,
			sdt.[idfsStatisticAreaType],
			tlbStatistic.[idfsStatisticalAgeGroup],
			StatisticalAgeGroup.NAME AS strStatisticalAgeGroup,
			DataType.[strDefault] AS defDataTypeName,
			CAST(tlbStatistic.[varValue] AS FLOAT) AS [varValue],
			tlbStatistic.[idfsMainBASeReference],
			tlbStatistic.[idfsStatisticPeriodType],
			tlbStatistic.[idfsArea],
			dbo.FN_GBL_FormatDate(tlbStatistic.datStatisticStartDate, 'mm/dd/yyyy') As datStatisticStartDate,
			DataType.[name] AS setnDataTypeName,
			ParamType.[name] AS ParameterType,
			ParamType.[idfsReference] AS idfsParameterType, 
			Main.[strDefault] AS defParameterName,
			ISNULL(cMain.strTextString, Main.strDefault) AS setnParameterName,
			Main.idfsBASeReference AS idfsParameterName,
			AreaType.[strDefault] AS defAreaTypeName,
			AreaType.[name] AS setnAreaTypeName,
			PeriodType.[strDefault] AS defPeriodTypeName,
			PeriodType.[name] AS setnPeriodTypeName,
			Area.idfsCountry,
			Area.idfsRegion,
			Area.idfsRayon,
			Area.idfsSettlement,
			Area.strAreaName  AS setnArea,
			tlbStatistic.AuditCreateDTM,
			gl.AdminLevel1ID   AdminLevel0Value,
			gl.AdminLevel1Name  AS AdminLevel0Text,
			gl.AdminLevel2ID   AS AdminLevel1Value,
			gl.AdminLevel2Name  AS AdminLevel1Text,
			gl.AdminLevel3ID   AS AdminLevel2Value,
			gl.AdminLevel3Name AS AdminLevel2Text,
			gl.AdminLevel4ID   AS AdminLevel3Value,
			gl.AdminLevel4Name  AS AdminLevel3Text,
			gl.AdminLevel5ID   AS AdminLevel4Value,
			gl.AdminLevel5Name  AS AdminLevel4Text,
			gl.AdminLevel6ID   AS AdminLevel5Value,
			gl.AdminLevel6Name  AS AdminLevel5Text,
			gl.AdminLevel7ID   AS AdminLevel6Value,
			gl.AdminLevel7Name  AS AdminLevel6Text
	FROM	tlbStatistic
	left join [trtStatisticDataType] sdt on tlbStatistic.idfsStatisticDataType = sdt.idfsStatisticDataType
    left join FN_GBL_Reference_GETList(@LangID,19000090 ) DataType on DataType.idfsReference = tlbStatistic.idfsStatisticDataType
	LEFT JOIN   fn_gbl_locationHierarchy_Flattened(@LangID) gl ON gl.idfsLocation = tlbStatistic.idfsArea  
	-- LEFT OUTER JOIN fnReferenceRepair(@LangID, 19000090/*'rftStatisticDataType'*/) DataType
	-- ON				DataType.[idfsReference] = tlbStatistic.[idfsStatisticDataType]
    left join FN_GBL_Reference_GETList(@LangID,19000089) AreaType on AreaType.idfsReference = sdt.idfsStatisticAreaType
    -- )
	-- LEFT OUTER JOIN fnReferenceRepair(@LangID, 19000089/*'rftStatisticAreaType'*/) AreaType
	-- ON				AreaType.[idfsReference] = tlbStatistic.[idfsStatisticAreaType]
	LEFT OUTER JOIN FN_GBL_Reference_GetList(@LangID, 19000091/*'rftStatisticPeriodType'*/) PeriodType ON PeriodType.[idfsReference] = tlbStatistic.[idfsStatisticPeriodType]
	LEFT OUTER JOIN trtReferenceType rt ON rt.idfsReferenceType = DataType.idfsReferenceType
	LEFT OUTER JOIN FN_GBL_Reference_GetList(@LangID, 19000076/*'rftReferenceTypeName'*/) ParamType ON ParamType.[idfsReference] = rt.idfsReferenceType
	LEFT OUTER JOIN FN_GBL_Reference_GetList(@LangID, 19000145/*'rftStatisticalAgeGroup'*/) StatisticalAgeGroup
	ON StatisticalAgeGroup.[idfsReference] = tlbStatistic.[idfsStatisticalAgeGroup]
	LEFT OUTER JOIN (
						dbo.trtBASeReference AS Main 
						LEFT JOIN dbo.trtStringNameTranslation AS cMain 
						ON			Main.idfsBASeReference = cMain.idfsBASeReference
							AND		cMain.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
					)
	ON				Main.idfsBASeReference = tlbStatistic.[idfsMainBASeReference]
					and ISNULL(Main.intRowStatus, 0) = 0
	LEFT OUTER JOIN vwAreaInfo Area 
	ON				Area.idfsArea = tlbStatistic.[idfsArea]
					and Area.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
	
	WHERE tlbStatistic.intRowStatus = 0 AND 
	tlbStatistic.idfStatistic = @idfStatistic
	END TRY  

	BEGIN CATCH 

	Throw;

	END CATCH;
END

