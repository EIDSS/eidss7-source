


--*************************************************************
-- Name 				: USP_ADMIN_STAT_GetList
-- Description			: ISatistical Data List
--          
-- Author               : Maheshwar D Deo
-- Revision History
--		Name       Date       Change Detail
-- Ricky Moss	  08/06/2019	Refactoring for API Method accommodation
-- Ricky Moss	  08/30/2019	Date query fix-- 
-- Ricky Moss	  11/15/2019	Added parameters to pull a certain number of fields at a time.
-- Ricky Moss	  01/21/2020	Added Region and Rayon fields to search
-- Ricky Moss	  03/18/2020	Add settlement search field
-- Ricky Moss	  04/20/2020	Refactored @idfsStatisticalDataType search capability
-- Lamont Mitchell	3/21/22   Refactored
-- Lamont Mitchell	4/26/22   Refactored Paging
--LAMONT		4-30-22		ADDED LOCATION HIERARCHY
--LAMONT		5-18-22		Removed View and replaced with Location Hierarchy Flattened. (View Used Country Name)
--Lamont Mitchell 7-6-2022	Add Case Statement to results to display Combinations of Areas according to use case and tfs bug 4464 
-- Testing code:
-- exec USP_ADMIN_STAT_GetList 'en-US', 129909620006865, null, '01/01/1992', '07/19/2022', null,  null, null, 10, 1, 1
--*************************************************************

CREATE  PROCEDURE	[dbo].[USP_ADMIN_STAT_GetList]
(
	  @LangID						NVARCHAR(50),
	  @idfsStatisticalDataType		BIGINT = NULL,
	  @idfsArea						BIGINT = NULL,
	  @datStatisticStartDateFrom	DATETIME = NULL,
	  @datStatisticStartDateTo		DATETIME = NULL,
	  @idfsRegion					BIGINT = NULL,
	  @idfsRayon					BIGINT = NULL,
	  @idfsSettlement				BIGINT = NULL,
	  @pageSize						INT = 10 ,
	  @pageNo				INT = 1,
	  @sortColumn NVARCHAR(30) = 'strName',
	  @sortOrder NVARCHAR(4) = 'asc'

)

AS
BEGIN	
	BEGIN TRY
	DECLARE @firstRec INT
	DECLARE @lastRec INT

	DECLARE @idfsLocation BIGINT = COALESCE(@idfsSettlement, @idfsRayon, @idfsRegion)

	DECLARE @t TABLE
	(
		idfStatistic bigint,
		idfsStatisticDataType bigint,
		idfsStatisticAreaType bigint,
		idfsStatisticalAgeGroup bigint,
		strStatisticalAgeGroup nvarchar(100),
		defDataTypeName nvarchar(100),
		varValue nvarchar(100),
		idfsMainBASeReference bigint,
		idfsStatisticPeriodType bigint,
		idfsArea  bigint,
		datStatisticStartDate datetime,
		setnDataTypeName nvarchar(100),
		ParameterType nvarchar(100),
		idfsParameterType bigint, 
		defParameterName nvarchar(100),
		setnParameterName nvarchar(100),
		idfsParameterName bigint,
		defAreaTypeName nvarchar(100),
		setnAreaTypeName nvarchar(100),
		defPeriodTypeName nvarchar(100),
		setnPeriodTypeName nvarchar(100),
		idfsCountry bigint,
		idfsRegion bigint,
		idfsRayon bigint,
		idfsSettlement bigint,
		setnArea nvarchar(100),
		AuditCreateDTM datetime,
		AdminLevel0Value BIGINT,
		AdminLevel0Text nvarchar(100),
		AdminLevel1Value BIGINT,
		AdminLevel1Text nvarchar(100),
		AdminLevel2Value BIGINT,
		AdminLevel2Text nvarchar(100),
		AdminLevel3Value BIGINT,
		AdminLevel3Text nvarchar(100),
		AdminLevel4Value BIGINT,
		AdminLevel4Text nvarchar(100),
		AdminLevel5Value BIGINT,
		AdminLevel5Text nvarchar(100),
		AdminLevel6Value BIGINT ,
		AdminLevel6Text nvarchar(100)
	)
	
	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)
	
	INSERT INTO @T
	SELECT	
		S.idfStatistic,
		S.idfsStatisticDataType,
		S.idfsStatisticAreaType,
		S.idfsStatisticalAgeGroup,
		StatisticalAgeGroup.NAME AS strStatisticalAgeGroup,
		DataType.strDefault AS defDataTypeName,
		CAST(S.[varValue] AS FLOAT) AS varValue,
		S.idfsMainBASeReference,
		S.idfsStatisticPeriodType,
		S.idfsArea AS idfsArea,
		dbo.FN_GBL_FormatDate(S.datStatisticStartDate, 'mm/dd/yyyy') As datStatisticStartDate,
		DataType.name AS setnDataTypeName,
		ParamType.name AS ParameterType,
		ParamType.idfsReference AS idfsParameterType, 
		Main.strDefault AS defParameterName,
		ISNULL(cMain.strTextString, Main.strDefault) AS setnParameterName,
		Main.idfsBASeReference AS idfsParameterName,
		AreaType.strDefault AS defAreaTypeName,
		AreaType.name AS setnAreaTypeName,
		PeriodType.strDefault AS defPeriodTypeName,
		PeriodType.name AS setnPeriodTypeName,
		gil.AdminLevel1ID as  idfsCountry,
		gil.AdminLevel2ID as  idfsRegion,
		gil.AdminLevel3ID as  idfsRayon,
		gil.AdminLevel4ID as  idfsSettlement,
		gil.AdminLevel1Name  AS setnArea,
		S.AuditCreateDTM,
		gil.AdminLevel1ID   AdminLevel0Value,
		gil.AdminLevel1Name  AS AdminLevel0Text,
		gil.AdminLevel2ID   AS AdminLevel1Value,
		gil.AdminLevel2Name  AS AdminLevel1Text,
		gil.AdminLevel3ID   AS AdminLevel2Value,
		gil.AdminLevel3Name AS AdminLevel2Text,
		gil.AdminLevel4ID   AS AdminLevel3Value,
		gil.AdminLevel4Name  AS AdminLevel3Text,
		gil.AdminLevel5ID   AS AdminLevel4Value,
		gil.AdminLevel5Name  AS AdminLevel4Text,
		gil.AdminLevel6ID   AS AdminLevel5Value,
		gil.AdminLevel6Name  AS AdminLevel5Text,
		gil.AdminLevel7ID   AS AdminLevel6Value,
		gil.AdminLevel7Name  AS AdminLevel6Text
	FROM dbo.tlbStatistic S
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID,19000090) DataType on DataType.idfsReference = S.idfsStatisticDataType
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID,19000089) AreaType on AreaType.idfsReference = S.idfsStatisticAreaType
	LEFT JOIN dbo.FN_GBL_Reference_GetList(@LangID, 19000091) PeriodType ON PeriodType.idfsReference = S.idfsStatisticPeriodType
	LEFT JOIN dbo.trtReferenceType rt ON rt.idfsReferenceType = DataType.idfsReferenceType
	LEFT JOIN dbo.FN_GBL_Reference_GetList(@LangID, 19000145) StatisticalAgeGroup	ON StatisticalAgeGroup.[idfsReference] = S.[idfsStatisticalAgeGroup]
	LEFT JOIN (dbo.trtBaseReference Main LEFT JOIN dbo.trtStringNameTranslation cMain ON Main.idfsBaseReference = cMain.idfsBASeReference
							AND cMain.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
					)
	ON Main.idfsBaseReference = S.[idfsMainBASeReference] AND ISNULL(Main.intRowStatus, 0) = 0
     JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) gil ON gil.idfsLocation = S.[idfsArea]
	LEFT JOIN dbo.trtStatisticDataType sdt ON sdt.idfsStatisticDataType = S.idfsStatisticDataType
	LEFT JOIN dbo.FN_GBL_Reference_GetList(@LangID, 19000076) ParamType ON ParamType.idfsReference = sdt.idfsReferenceType
	
	WHERE S.intRowStatus = 0 				
	AND 
	(
		(S.datStatisticStartDate <= @datStatisticStartDateTo AND S.datStatisticStartDate >= @datStatisticStartDateFrom AND S.datStatisticStartDate BETWEEN @datStatisticStartDateFrom AND @datStatisticStartDateTo)
		 OR
		(S.datStatisticFinishDate >= @datStatisticStartDateFrom AND S.datStatisticFinishDate <= @datStatisticStartDateTo AND S.datStatisticFinishDate BETWEEN @datStatisticStartDateFrom AND @datStatisticStartDateTo)
	)

	AND (S.idfsStatisticDataType = @idfsStatisticalDataType OR @idfsStatisticalDataType IS NULL)
	AND (S.idfsArea = @idfsArea OR @idfsArea IS NULL);

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfStatistic' AND @SortOrder = 'asc' THEN idfStatistic END ASC,
				CASE WHEN @sortColumn = 'idfStatistic' AND @SortOrder = 'desc' THEN idfStatistic END DESC,
				CASE WHEN @sortColumn = 'varValue' AND @SortOrder = 'asc' THEN varValue END ASC,
				CASE WHEN @sortColumn = 'varValue' AND @SortOrder = 'desc' THEN varValue END DESC,
				CASE WHEN @sortColumn = 'strStatisticalAgeGroup' AND @SortOrder = 'asc' THEN strStatisticalAgeGroup END ASC,
				CASE WHEN @sortColumn = 'strStatisticalAgeGroup' AND @SortOrder = 'desc' THEN strStatisticalAgeGroup END DESC,
				CASE WHEN @sortColumn = 'ParameterType' AND @SortOrder = 'asc' THEN ParameterType END ASC,
				CASE WHEN @sortColumn = 'ParameterType' AND @SortOrder = 'desc' THEN ParameterType END DESC,
				CASE WHEN @sortColumn = 'setnParameterName' AND @SortOrder = 'asc' THEN setnParameterName END ASC,
				CASE WHEN @sortColumn = 'setnParameterName' AND @SortOrder = 'desc' THEN setnParameterName END DESC,
				CASE WHEN @sortColumn = 'setnPeriodTypeName' AND @SortOrder = 'asc' THEN setnPeriodTypeName END ASC,
				CASE WHEN @sortColumn = 'setnPeriodTypeName' AND @SortOrder = 'desc' THEN setnPeriodTypeName END DESC,
				CASE WHEN @sortColumn = 'datStatisticStartDate' AND @SortOrder = 'asc' THEN datStatisticStartDate END ASC,
				CASE WHEN @sortColumn = 'datStatisticStartDate' AND @SortOrder = 'desc' THEN datStatisticStartDate END DESC,
				CASE WHEN @sortColumn = 'setnAreaTypeName' AND @SortOrder = 'asc' THEN setnAreaTypeName END ASC,
				CASE WHEN @sortColumn = 'setnAreaTypeName' AND @SortOrder = 'desc' THEN setnAreaTypeName END DESC,
				CASE WHEN @sortColumn = 'setnArea' AND @SortOrder = 'asc' THEN setnArea END ASC,
				CASE WHEN @sortColumn = 'setnArea' AND @SortOrder = 'desc' THEN setnArea END DESC,
				CASE WHEN @sortColumn = 'idfStatistic' AND @SortOrder = 'asc' THEN idfStatistic END ASC,
				CASE WHEN @sortColumn = 'idfStatistic' AND @SortOrder = 'desc' THEN idfStatistic END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount 
				,idfStatistic
				,idfsStatisticDataType
				,idfsStatisticAreaType
				,idfsStatisticalAgeGroup
				,strStatisticalAgeGroup
				,defDataTypeName
				,varValue
				,idfsMainBASeReference
				,idfsStatisticPeriodType
				,idfsArea
				,datStatisticStartDate
				,setnDataTypeName
				,ParameterType
				,idfsParameterType
				,defParameterName
				,setnParameterName
				,idfsParameterName
				,defAreaTypeName
				,setnAreaTypeName
				,defPeriodTypeName
				,setnPeriodTypeName
				,idfsCountry
				,idfsRegion
				,idfsRayon
				,idfsSettlement
				--,setnArea
				,CASE
				WHEN defAreaTypeName = 'Country' THEN AdminLevel0Text
				WHEN defAreaTypeName = 'Region' THEN AdminLevel1Text 
				WHEN defAreaTypeName = 'Rayon' THEN AdminLevel1Text + ',' +  AdminLevel2Text 
				WHEN defAreaTypeName = 'Settlement' THEN AdminLevel1Text + ',' +  AdminLevel2Text + ',' +  AdminLevel3Text + ',' + AdminLevel4Text + ',' + AdminLevel5Text + ',' +   AdminLevel6Text
				ELSE ''
				END AS setnArea
				,AuditCreateDTM,
				AdminLevel0Value,
				AdminLevel0Text,
				AdminLevel1Value,
				AdminLevel1Text,
				AdminLevel2Value,
				AdminLevel2Text,
				AdminLevel3Value,
				AdminLevel3Text,
				AdminLevel4Value,
				AdminLevel4Text,
				AdminLevel5Value,
				AdminLevel5Text,
				AdminLevel6Value,
				AdminLevel6Text
			FROM @T
		)
		SELECT
				TotalRowCount 
				,idfStatistic
				,idfsStatisticDataType
				,idfsStatisticAreaType
				,idfsStatisticalAgeGroup
				,strStatisticalAgeGroup
				,defDataTypeName
				,varValue
				,idfsMainBASeReference
				,idfsStatisticPeriodType
				,idfsArea
				,datStatisticStartDate
				,setnDataTypeName
				,ParameterType
				,idfsParameterType
				,defParameterName
				,setnParameterName
				,idfsParameterName
				,defAreaTypeName
				,setnAreaTypeName
				,defPeriodTypeName
				,setnPeriodTypeName
				,idfsCountry
				,idfsRegion
				,idfsRayon
				,idfsSettlement
				,setnArea
				,AuditCreateDTM,
				AdminLevel0Value,
				AdminLevel0Text,
				AdminLevel1Value,
				AdminLevel1Text,
				AdminLevel2Value,
				AdminLevel2Text,
				AdminLevel3Value,
				AdminLevel3Text,
				AdminLevel4Value,
				AdminLevel4Text,
				AdminLevel5Value,
				AdminLevel5Text,
				AdminLevel6Value,
				AdminLevel6Text
				,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
				,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY  

	BEGIN CATCH 
			THROW
	END CATCH;
END
