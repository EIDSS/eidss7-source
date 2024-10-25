

-- This stored proc is to be used the report:
--
--	Comparative Report on Infectious Diseases/Conditions (by Months)
--
--  Mark Wilson UPDATEd for EIDSS7 standards
--

/*
--Example of a call of procedure:

EXEC report.USP_REP_Hum_ComparativeGG 'en', 2015, 2017 

EXEC report.USP_REP_Hum_ComparativeGG 'ru', 2015, 2017 

*/ 

CREATE PROCEDURE [Report].[USP_REP_Hum_ComparativeGG]
	@LangID				AS VARCHAR(36),
	@FirstYear			AS INT, 
	@SecondYear			AS INT, 
	@StartMonth			AS INT = NULL,
	@EndMonth			AS INT = NULL,
	@RegionID			AS NVARCHAR(100) = NULL,
	@RayonID			AS NVARCHAR(100) = NULL,
	@SiteID				AS BIGINT = NULL,
	@UseArchiveData		AS BIT = 0 --if User selected Use Archive Data then 1

AS
BEGIN
	
	DECLARE @idfsRegion BIGINT = (SELECT CAST(@RegionID AS BIGINT))
	DECLARE @idfsRayon BIGINT = (SELECT CAST(@RayonID AS BIGINT))

	DECLARE	@ResultTable TABLE
	(	 
		idfsBaseReference BIGINT NOT NULL PRIMARY KEY,
		strDisease NVARCHAR(300) COLLATE database_default NOT NULL,
		strICD NVARCHAR(300) COLLATE database_default NULL,
		blnIsSubdisease BIT NULL,
		intTotal_Abs_Y1	INT NULL,
		dblTotal_By100000_Y1 DECIMAL(10,2)  NULL,
		intChildren_Abs_Y1 INT NULL,
		dblChildren_By100000_Y1 DECIMAL(10,2)  NULL,
		intTotal_Abs_Y2	INT NULL,
		dblTotal_By100000_Y2 DECIMAL(10,2) NULL,
		intChildren_Abs_Y2 INT NULL,
		dblChildren_By100000_Y2		DECIMAL(10,2) NULL,
		intOrder INT
	)

	DECLARE	@ReportTable	TABLE
	(	  
		idfsBaseReference BIGINT NOT NULL PRIMARY KEY,
		strDisease NVARCHAR(300) collate database_default NOT NULL,
		strICD NVARCHAR(300) collate database_default NULL,
		blnIsSubdisease BIT NULL,
		intTotal_Abs_Y1	INT NULL,
		dblTotal_By100000_Y1 DECIMAL(10,2) NULL,
		intChildren_Abs_Y1 INT NULL,
		dblChildren_By100000_Y1	DECIMAL(10,2) NULL,
		intTotal_Abs_Y2 INT NULL,
		dblTotal_By100000_Y2 DECIMAL(10,2) NULL,
		intChildren_Abs_Y2 INT NULL,
		dblChildren_By100000_Y2	DECIMAL(10,2) NULL,
		intOrder INT
	)

	DECLARE 		
		@StartDate1	DATETIME,	 
		@FinishDate1 DATETIME,
		@StartDate2 DATETIME,	 
		@FinishDate2 DATETIME,	
		@idfsLanguage BIGINT,
 		@idfsCustomReportType BIGINT,	
		@CountryID BIGINT,
		@StatisticsForFirstYear	INT,
		@StatisticsForSecondYear INT,
		@Statistics0_15ForFirstYear	INT,
		@Statistics0_15ForSecondYear INT,
		@strStartMonth NVARCHAR(2),
		@strEndMonth NVARCHAR(2),
		@idfsStatType_Population BIGINT,
		@idfsStatType_ByAgeAndGender BIGINT,
		@idfsStatType_ByAgeInRayons BIGINT
		
	DECLARE @RayonsForStatistics TABLE
	(
		idfsRayon BIGINT PRIMARY KEY,
		maxYear1 INT,
		maxYear2 INT
	)

	DECLARE @RayonsAndAgeGroupsForStatistics TABLE
	(
		idfsAgeGroup BIGINT,
		idfsRayon BIGINT,	 
		maxYear1_ByAgeInRayons INT,
		maxYear2_ByAgeInRayons INT,
		PRIMARY KEY(idfsAgeGroup, idfsRayon)
	)

	DECLARE @AgeGroupsAndGenderForStatistics TABLE
	(
		idfsAgeGroup BIGINT,
		idfsGender BIGINT,
		maxYear1_ByAgeAndGender INT,
		maxYear2_ByAgeAndGender INT,
		PRIMARY KEY(idfsAgeGroup, idfsGender)
	)

	DECLARE @AgeGroupsForStatistics TABLE
	(
		idfsAgeGroup BIGINT PRIMARY KEY,
		StatisticsForFirstYear INT,
		StatisticsForSecondYear INT
	)
	  
	DECLARE @ChildrenAgeGroups TABLE
	(
		idfsAgeGroup BIGINT PRIMARY KEY,
		strAgeGroupName NVARCHAR(100)
	)	  

	-------------------------------------------------------------------------------------------------------------
	/*Comparative Report on Infectious Diseases/Conditions (by months)*/
	-- This report (10290051) is not installed for some reason, so previous development team used
	-- the definition for /* "Intermediary Form 03 by MoLHSA Order 01-2N"*/  10290050
	--
	--SET @idfsCustomReportType = 10290051 
	SET @idfsCustomReportType = 10290050 
	SET @idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)		

	IF @StartMonth IS NULL SET @StartMonth = 1
	IF @EndMonth IS NULL SET @EndMonth = 12

	SET @strStartMonth = CASE WHEN 	@StartMonth	BETWEEN 1 AND 9 THEN '0' + CAST(@StartMonth AS NVARCHAR) ELSE CAST(@StartMonth AS NVARCHAR) END
	SET @strEndMonth = CASE WHEN @EndMonth	BETWEEN 1 AND 9 THEN '0' + CAST(@EndMonth AS NVARCHAR) ELSE CAST(@EndMonth AS NVARCHAR) END	

	SET @StartDate1  = (CAST(@FirstYear AS VARCHAR(4)) + @strStartMonth + '01')
	SET @FinishDate1  = DATEADD(ms, -2, DATEADD(mm, 1, (CAST(@FirstYear AS VARCHAR(4)) + @strEndMonth + '01')))

	SET @StartDate2  = (CAST(@SecondYear AS VARCHAR(4)) + @strStartMonth + '01')
	SET @FinishDate2  = DATEADD(ms, -2, DATEADD(mm, 1, (CAST(@SecondYear AS VARCHAR(4)) + @strEndMonth + '01')))

	SET	@CountryID = 780000000

	-- MCW changed these reference data variables to SET.  No need for query
	SET @idfsStatType_Population = 39850000000  -- Population
	SET @idfsStatType_ByAgeAndGender = 39860000000  -- Population by Age Groups and Gender
	SET @idfsStatType_ByAgeInRayons = 58040370000000 -- Population by Age Groups in Rayons
    					
	-- get childare Age Groups - "-1", "1-4", "5-9", "10-14"    					
	INSERT INTO @ChildrenAgeGroups(idfsAgeGroup, strAgeGroupName)
	SELECT 
		tbra.idfsBaseReference, 
		CAST(tbra.varValue AS NVARCHAR(100))
	FROM dbo.trtBaseReferenceAttribute tbra
	INNER JOIN dbo.trtAttributeType at ON at.strAttributeTypeName = N'Children Age groups' AND tbra.strAttributeItem = 'Children Age groups'
	
	-- get statistics
	-- Get statictics for Rayon-Region-StatisticalAgeGroups
	INSERT INTO @RayonsForStatistics (idfsRayon)
	SELECT idfsRayon
	FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/)
	WHERE 
	(
		idfsRayon = @RayonID
		OR (idfsRegion = @RegionID AND @RayonID IS NULL)
		OR (@RegionID IS NULL AND @RayonID IS NULL)
	)
	AND idfsCountry = report.FN_GBL_CurrentCountry_GET()
	AND intRowStatus = 0
			
	INSERT INTO @RayonsAndAgeGroupsForStatistics (idfsAgeGroup ,idfsRayon)
	SELECT 
		StstAG.idfsBaseReference, 
		R.idfsRayon 
	FROM @RayonsForStatistics R -- changed this to only use the Rayons that are in the report
	CROSS JOIN (SELECT StatAgeGroups.idfsBaseReference
				FROM dbo.trtBaseReference StatAgeGroups
				WHERE StatAgeGroups.idfsReferenceType = 19000145 --	rftStatisticalAgeGroup
				AND StatAgeGroups.intRowStatus = 0) AS StstAG
      
	INSERT INTO @AgeGroupsAndGenderForStatistics (idfsAgeGroup, idfsGender)
	SELECT 
		StatAG.idfsAgeGroup, 
		Gender.idfsGender
	FROM 
	(
		SELECT StatAgeGroups.idfsBaseReference as idfsAgeGroup
		FROM dbo.trtBaseReference StatAgeGroups
		WHERE StatAgeGroups.idfsReferenceType = 19000145 --	rftStatisticalAgeGroup
		AND StatAgeGroups.intRowStatus = 0
	) AS StatAG
	
	CROSS JOIN 
	(
		SELECT idfsBaseReference  AS idfsGender
		FROM dbo.trtBaseReference StatGender
		WHERE StatGender.idfsReferenceType = 19000043	--rftHumanGender
		AND StatGender.intRowStatus = 0
	) AS Gender					
      
	INSERT INTO @AgeGroupsForStatistics (idfsAgeGroup)
	SELECT StatAG.idfsAgeGroup
	FROM 
	(
		SELECT StatAgeGroups.idfsBaseReference as idfsAgeGroup
		FROM dbo.trtBaseReference StatAgeGroups
		WHERE StatAgeGroups.idfsReferenceType = 19000145 --	rftStatisticalAgeGroup
		AND StatAgeGroups.intRowStatus = 0
	) as StatAG
		  			
	-- first year
	-- we determine for each rayon the maximum year (less than or equal to the reporting year) for which there are statistics.
	UPDATE rfstat 
	SET
	   rfstat.maxYear1 = maxYear
	FROM @RayonsForStatistics rfstat
	INNER JOIN (SELECT 
					MAX(YEAR(stat.datStatisticStartDate)) AS maxYear, 
					rfs.idfsRayon
				FROM @RayonsForStatistics  rfs    
				INNER JOIN dbo.tlbStatistic stat ON stat.idfsArea = rfs.idfsRayon AND stat.intRowStatus = 0 AND stat.idfsStatisticDataType = @idfsStatType_Population
												 AND YEAR(stat.datStatisticStartDate) <= @FirstYear -- ????
				GROUP BY idfsRayon
			   ) AS mrfs ON rfstat.idfsRayon = mrfs.idfsRayon

	-- we determine for each rayon and age group the maximum year (less than or equal to the reporting year) for which there are statistics 
	UPDATE rfstat set
	   rfstat.maxYear1_ByAgeInRayons = maxYear
	FROM @RayonsAndAgeGroupsForStatistics rfstat
	INNER JOIN (SELECT 
					rfs.idfsAgeGroup, 
					rfs.idfsRayon, 
					MAX(year(stat.datStatisticStartDate)) as maxYear
				FROM @RayonsAndAgeGroupsForStatistics  rfs    
				INNER JOIN dbo.tlbStatistic stat ON stat.idfsArea = rfs.idfsRayon AND stat.idfsStatisticalAgeGroup = rfs.idfsAgeGroup
												 AND stat.intRowStatus = 0 AND stat.idfsStatisticDataType = @idfsStatType_ByAgeInRayons 
												 AND YEAR(stat.datStatisticStartDate) <= @FirstYear
				GROUP BY rfs.idfsAgeGroup, rfs.idfsRayon
			   ) AS mrfs ON rfstat.idfsRayon = mrfs.idfsRayon AND rfstat.idfsAgeGroup = mrfs.idfsAgeGroup

	-- we determine for each age group and Gender the maximum year (less than or equal to the reporting year) for which there are statistics.    
	UPDATE rfstat set
	   rfstat.maxYear1_ByAgeAndGender = maxYear
	FROM @AgeGroupsAndGenderForStatistics rfstat
	INNER JOIN (SELECT 
					MAX(YEAR(stat.datStatisticStartDate)) AS maxYear, 
					rfs.idfsAgeGroup, rfs.idfsGender
				FROM @AgeGroupsAndGenderForStatistics  rfs    
				INNER JOIN dbo.tlbStatistic stat ON stat.idfsArea = @CountryID AND stat.idfsStatisticalAgeGroup = rfs.idfsAgeGroup 
												 AND stat.idfsMainBaseReference = rfs.idfsGender AND stat.intRowStatus = 0
												 AND stat.idfsStatisticDataType = @idfsStatType_ByAgeAndGender AND YEAR(stat.datStatisticStartDate) <= @FirstYear
				GROUP BY rfs.idfsAgeGroup, rfs.idfsGender
			   ) AS mrfs ON rfstat.idfsAgeGroup = mrfs.idfsAgeGroup AND rfstat.idfsGender = mrfs.idfsGender
                                      	
	-- by rayons
	-- IF there are statistics for each rayon, THEN summarize it. 
	-- Otherwise, we consider the statistics not to be complete and generally do not count for a given year-region
	IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear1 IS NULL)
	BEGIN
		SELECT 
			@StatisticsForFirstYear = SUM(CAST(s.sumValue AS INT))
		FROM 
		(
			SELECT SUM(CAST(varValue AS INT)) as sumValue
			FROM dbo.tlbStatistic s
			INNER JOIN @RayonsForStatistics rfs ON rfs.idfsRayon = s.idfsArea 

			WHERE s.intRowStatus = 0 
			AND s.idfsStatisticDataType = @idfsStatType_Population 
			AND s.datStatisticStartDate = CAST(rfs.maxYear1 AS VARCHAR(4)) + '-01-01' 
			GROUP BY rfs.idfsRayon 
		) AS s
	END    
	ELSE SET @StatisticsForFirstYear = 0      

	-- by Rayons and Age Groups
	-- IF there is statistics for each district for the Age Group, THEN we summarize it. 
	-- Otherwise, the statistics are not complete
	UPDATE agfs 
	SET agfs.StatisticsForFirstYear = CASE WHEN NOT EXISTS (SELECT * 
															FROM @RayonsAndAgeGroupsForStatistics rafs 
															WHERE rafs.idfsAgeGroup = s.idfsAgeGroup AND rafs.maxYear1_ByAgeInRayons IS NULL
														   )
											THEN s.sumValue
											ELSE NULL 
									   END
 
	FROM @AgeGroupsForStatistics agfs
	INNER JOIN (SELECT 
					SUM(CAST(varValue AS INT)) AS sumValue, 
					rfs.idfsAgeGroup
				FROM dbo.tlbStatistic s
				INNER JOIN @RayonsAndAgeGroupsForStatistics rfs ON rfs.idfsRayon = s.idfsArea AND rfs.idfsAgeGroup = s.idfsStatisticalAgeGroup 
																AND s.intRowStatus = 0 AND s.idfsStatisticDataType = @idfsStatType_ByAgeInRayons 
																AND s.datStatisticStartDate = CAST(rfs.maxYear1_ByAgeInRayons AS VARCHAR(4)) + '-01-01' 
				GROUP BY rfs.idfsAgeGroup ) AS s ON agfs.idfsAgeGroup = s.idfsAgeGroup	
	
	-- by Gender and Age Groups
	-- IF there are statistics for each gender for each Age Group, THEN summarize it. 
	-- Otherwise, the statistics are not complete
	UPDATE agfs 
	SET agfs.StatisticsForFirstYear = CASE WHEN NOT EXISTS (SELECT * FROM @AgeGroupsAndGenderForStatistics rafs 
															WHERE rafs.idfsAgeGroup = s.idfsAgeGroup 
															AND rafs.maxYear1_ByAgeAndGender IS NULL )
										   THEN s.sumValue
										   ELSE NULL 
									  END
 
	FROM @AgeGroupsForStatistics agfs
	INNER JOIN (SELECT 
					SUM(CAST(varValue AS INT)) AS sumValue, 
					rfs.idfsAgeGroup
				FROM dbo.tlbStatistic s
				INNER JOIN @AgeGroupsAndGenderForStatistics rfs ON s.idfsArea = @CountryID AND rfs.idfsAgeGroup = s.idfsStatisticalAgeGroup 
																AND rfs.idfsGender = s.idfsMainBaseReference AND s.intRowStatus = 0 
																AND s.idfsStatisticDataType = @idfsStatType_ByAgeAndGender 
																AND s.datStatisticStartDate = CAST(rfs.maxYear1_ByAgeAndGender AS VARCHAR(4)) + '-01-01' 
				GROUP BY rfs.idfsAgeGroup) AS s ON agfs.idfsAgeGroup = s.idfsAgeGroup	
	WHERE agfs.StatisticsForFirstYear IS NULL
		
		
	-- second year
	-- we determine for each district the maximum year (less than or equal to the reporting year) for which there is statistics.
	UPDATE rfstat 
	SET rfstat.maxYear2 = maxYear
	FROM @RayonsForStatistics rfstat
	INNER JOIN (SELECT 
					MAX(year(stat.datStatisticStartDate)) AS maxYear, 
					rfs.idfsRayon
				FROM @RayonsForStatistics  rfs    
				INNER JOIN dbo.tlbStatistic stat ON stat.idfsArea = rfs.idfsRayon AND stat.idfsStatisticDataType = @idfsStatType_Population
												 AND stat.intRowStatus = 0 AND YEAR(stat.datStatisticStartDate) <= @SecondYear
				GROUP BY  rfs.idfsRayon) AS mrfs ON rfstat.idfsRayon = mrfs.idfsRayon
    
	-- we determine for each district and age group the maximum year (less than or equal to the reporting year) for which there is statistics.    
	UPDATE rfstat 
	SET rfstat.maxYear2_ByAgeInRayons = maxYear
	FROM @RayonsAndAgeGroupsForStatistics rfstat
	INNER JOIN (SELECT 
					rfs.idfsAgeGroup, 
					rfs.idfsRayon, MAX(year(stat.datStatisticStartDate)) AS maxYear
				FROM @RayonsAndAgeGroupsForStatistics  rfs    
				INNER JOIN dbo.tlbStatistic stat ON stat.idfsArea = rfs.idfsRayon AND stat.idfsStatisticalAgeGroup = rfs.idfsAgeGroup
												 AND stat.intRowStatus = 0 AND stat.idfsStatisticDataType = @idfsStatType_ByAgeInRayons 
												 AND year(stat.datStatisticStartDate) <= @SecondYear
				GROUP BY rfs.idfsAgeGroup, rfs.idfsRayon ) AS mrfs ON rfstat.idfsRayon = mrfs.idfsRayon AND rfstat.idfsAgeGroup = mrfs.idfsAgeGroup
    
	-- define for each age group and Gender the maximum year (less than or equal to the reporting year) for which there is statistics.        
	UPDATE rfstat 
	SET rfstat.maxYear2_ByAgeAndGender = maxYear
	FROM @AgeGroupsAndGenderForStatistics rfstat
	INNER JOIN (SELECT 
					MAX(year(stat.datStatisticStartDate)) AS maxYear, 
					rfs.idfsAgeGroup, rfs.idfsGender
				FROM @AgeGroupsAndGenderForStatistics  rfs    
				INNER JOIN dbo.tlbStatistic stat ON stat.idfsArea = @CountryID AND stat.idfsStatisticalAgeGroup = rfs.idfsAgeGroup AND stat.intRowStatus = 0
												 AND stat.idfsMainBaseReference = rfs.idfsGender AND stat.idfsStatisticDataType = @idfsStatType_ByAgeAndGender 
												 AND year(stat.datStatisticStartDate) <= @SecondYear
				GROUP BY rfs.idfsAgeGroup, rfs.idfsGender) AS mrfs ON rfstat.idfsAgeGroup = mrfs.idfsAgeGroup AND rfstat.idfsGender = mrfs.idfsGender

	-- by rayons
	-- IF there are statistics for each rayon, THEN  summarize it. 
	-- Otherwise, we consider the statistics not to be complete and generally do not count for a given year-rayon.
	IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear2 IS NULL)
	BEGIN
		SELECT @StatisticsForSecondYear = SUM(CAST(s.sumValue AS INT))
		FROM (SELECT SUM(CAST(varValue AS INT)) as sumValue
			  FROM dbo.tlbStatistic s
			  INNER JOIN @RayonsForStatistics rfs ON rfs.idfsRayon = s.idfsArea AND s.intRowStatus = 0 AND s.idfsStatisticDataType = @idfsStatType_Population 
												  AND s.datStatisticStartDate = CAST(rfs.maxYear2 AS VARCHAR(4)) + '-01-01' 
			  GROUP BY rfs.idfsRayon ) AS s
	END    
	ELSE SET @StatisticsForSecondYear = 0      

	-- by Rayons and Age Groups
	-- IF there are statistics for rayon for the Age Group, THEN summarize it. 
	-- Otherwise, the statistics are not complete
	UPDATE agfs 
	SET agfs.StatisticsForSecondYear = CASE WHEN NOT EXISTS (SELECT * FROM @RayonsAndAgeGroupsForStatistics rafs 
															 WHERE rafs.idfsAgeGroup = s.idfsAgeGroup AND rafs.maxYear2_ByAgeInRayons IS NULL )
											THEN s.sumValue
											ELSE NULL END
 
	FROM @AgeGroupsForStatistics agfs
	INNER JOIN (SELECT 
					SUM(CAST(varValue AS INT)) AS sumValue, 
					rfs.idfsAgeGroup
				FROM dbo.tlbStatistic s
				INNER JOIN @RayonsAndAgeGroupsForStatistics rfs ON rfs.idfsRayon = s.idfsArea AND rfs.idfsAgeGroup = s.idfsStatisticalAgeGroup AND s.intRowStatus = 0 
																AND s.idfsStatisticDataType = @idfsStatType_ByAgeInRayons 
																AND s.datStatisticStartDate = CAST(rfs.maxYear2_ByAgeInRayons AS VARCHAR(4)) + '-01-01' 
				GROUP BY rfs.idfsAgeGroup) AS s ON agfs.idfsAgeGroup = s.idfsAgeGroup	
	
	-- by Gender and Age Groups
	-- IF there are stats for gender and Age Group, THEN summarize it. 
	-- Otherwise, the statistics are not complete

	UPDATE agfs 
	SET agfs.StatisticsForSecondYear = CASE WHEN NOT EXISTS (SELECT * FROM @AgeGroupsAndGenderForStatistics rafs 
															 WHERE rafs.idfsAgeGroup = s.idfsAgeGroup AND rafs.maxYear2_ByAgeAndGender IS NULL )
											THEN s.sumValue
											ELSE NULL END
 
	FROM @AgeGroupsForStatistics agfs
	INNER JOIN (SELECT 
					SUM(CAST(varValue AS INT)) AS sumValue,
					rfs.idfsAgeGroup
				FROM dbo.tlbStatistic s
				INNER JOIN @AgeGroupsAndGenderForStatistics rfs ON s.idfsArea = @CountryID AND rfs.idfsAgeGroup = s.idfsStatisticalAgeGroup 
																AND rfs.idfsGender = s.idfsMainBaseReference AND s.intRowStatus = 0 
																AND s.idfsStatisticDataType = @idfsStatType_ByAgeAndGender 
																AND s.datStatisticStartDate = CAST(rfs.maxYear2_ByAgeAndGender AS VARCHAR(4)) + '-01-01' 
				GROUP BY rfs.idfsAgeGroup) AS s ON agfs.idfsAgeGroup = s.idfsAgeGroup	
	WHERE agfs.StatisticsForSecondYear IS NULL


	--Statistic for Children population
	SET @Statistics0_15ForFirstYear = NULL
	SELECT @Statistics0_15ForFirstYear = SUM(agfs.StatisticsForFirstYear)
	FROM @AgeGroupsForStatistics agfs
	WHERE EXISTS (SELECT * FROM @ChildrenAgeGroups cag WHERE cag.idfsAgeGroup = agfs.idfsAgeGroup) 
	AND NOT EXISTS (SELECT * FROM @AgeGroupsForStatistics ags WHERE ags.StatisticsForFirstYear IS NULL)

	SET @Statistics0_15ForFirstYear = ISNULL(@Statistics0_15ForFirstYear, 0)

	SET @Statistics0_15ForSecondYear = NULL
	SELECT @Statistics0_15ForSecondYear = SUM(agfs.StatisticsForSecondYear)
	FROM @AgeGroupsForStatistics agfs
	WHERE EXISTS (SELECT * FROM @ChildrenAgeGroups cag WHERE cag.idfsAgeGroup = agfs.idfsAgeGroup) 
	AND NOT EXISTS (SELECT * FROM @AgeGroupsForStatistics ags WHERE ags.StatisticsForSecondYear IS NULL)

	SET @Statistics0_15ForSecondYear = ISNULL(@Statistics0_15ForSecondYear, 0)

	INSERT INTO @ReportTable 
	SELECT 
		rr.idfsDiagnosisOrReportDiagnosisGroup, --idfsBaseReference
		ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault), --strDisease
		ISNULL(d.strIDC10, dg.strCode) +  ISNULL(ISNULL(' ' + snt2.strTextString, br2.strDefault), ''), -- ICD10 code
		CASE WHEN rr.intNULLValueInsteadZero & 1 > 0 THEN 1 ELSE 0 END, --blnIsSubdisease
		0,    --intTotal_Abs_Y1			    
		0.00, --dblTotal_By100000_Y1		
		0,    --intChildren_Abs_Y1		  
		0.00, --dblChildren_By100000_Y1	
		0,    --intTotal_Abs_Y2			    
		0.00, --dblTotal_By100000_Y2		
		0,    --strChildren_Abs_Y2		  
		0.00, --dblChildren_By100000_Y2	
		rr.intRowOrder
	FROM   dbo.trtReportRows rr
	LEFT JOIN dbo.trtBaseReference br 
			LEFT JOIN dbo.trtStringNameTranslation snt ON br.idfsBaseReference = snt.idfsBaseReference AND snt.idfsLanguage = @idfsLanguage
			LEFT OUTER JOIN dbo.trtDiagnosis d ON br.idfsBaseReference = d.idfsDiagnosis
			LEFT OUTER JOIN dbo.trtReportDiagnosisGroup dg ON br.idfsBaseReference = dg.idfsReportDiagnosisGroup

			ON rr.idfsDiagnosisOrReportDiagnosisGroup = br.idfsBaseReference
    
	LEFT OUTER JOIN dbo.trtBaseReference br2
			LEFT OUTER JOIN dbo.trtStringNameTranslation snt2 ON br2.idfsBaseReference = snt2.idfsBaseReference AND snt2.idfsLanguage = @idfsLanguage
			ON rr.idfsICDReportAdditionalText = br2.idfsBaseReference    
   
	-- additional text
	LEFT OUTER JOIN dbo.trtBaseReference br1
			LEFT OUTER JOIN dbo.trtStringNameTranslation snt1 ON br1.idfsBaseReference = snt1.idfsBaseReference AND snt1.idfsLanguage = @idfsLanguage
			ON rr.idfsReportAdditionalText = br1.idfsBaseReference
	WHERE rr.idfsCustomReportType = @idfsCustomReportType AND rr.intRowStatus = 0
	ORDER BY rr.intRowOrder  

	IF OBJECT_ID('tempdb.dbo.#ReportDiagnosisTable') is NOT NULL 
	DROP TABLE #ReportDiagnosisTable

	CREATE table 	#ReportDiagnosisTable
	(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
		blnIsAggregate		BIT,
		intTotal			INT NOT NULL,
		intAge_0_15			INT NOT NULL
	)

	INSERT INTO #ReportDiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal,
		intAge_0_15
	) 
	SELECT distinct
	  fdt.idfsDiagnosis,
	  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
	  END,
	  0,
	  0
	FROM dbo.trtDiagnosisToGroupForReportType fdt 
	INNER JOIN dbo.trtDiagnosis trtd ON trtd.idfsDiagnosis = fdt.idfsDiagnosis 
	WHERE fdt.idfsCustomReportType = @idfsCustomReportType 

	INSERT INTO #ReportDiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal,
		intAge_0_15
	) 
	SELECT distinct
	  trtd.idfsDiagnosis,
	  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
	  END,
	  0,
	  0

	FROM dbo.trtReportRows rr
	INNER JOIN dbo.trtBaseReference br ON br.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup	AND br.idfsReferenceType = 19000019 --'rftDiagnosis'
	INNER JOIN dbo.trtDiagnosis trtd ON trtd.idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup 
	WHERE  rr.idfsCustomReportType = @idfsCustomReportType AND  rr.intRowStatus = 0 
	AND NOT EXISTS 
			(
				SELECT * FROM #ReportDiagnosisTable
				  WHERE idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup
			)      

	DECLARE	@ReportDiagnosisGroupTable	TABLE
	(	idfsDiagnosisGroup	BIGINT NOT NULL PRIMARY KEY,
		intTotal			INT NOT NULL,
		intAge_0_15			INT NOT NULL
	)

	----------------------------------------------------------------------------------------
	-- @StartDate1 - @FinishDate1
	----------------------------------------------------------------------------------------
	EXEC report.USP_REP_Hum_ComparativeGG_Calculations @StartDate1, @FinishDate1, @RegionID, @RayonID 

	DELETE FROM @ReportDiagnosisGroupTable

	INSERT INTO	@ReportDiagnosisGroupTable

	SELECT		
		dtg.idfsReportDiagnosisGroup,
		SUM(intTotal),	
		SUM(intAge_0_15)

	FROM #ReportDiagnosisTable fdt
	INNER JOIN	dbo.trtDiagnosisToGroupForReportType dtg ON dtg.idfsDiagnosis = fdt.idfsDiagnosis AND dtg.idfsCustomReportType = @idfsCustomReportType
	
	GROUP BY dtg.idfsReportDiagnosisGroup

	UPDATE		ft
	SET	
	  ft.intTotal_Abs_Y1 = fdt.intTotal,	
	  ft.intChildren_Abs_Y1 = fdt.intAge_0_15
	FROM @ReportTable ft
	INNER JOIN #ReportDiagnosisTable fdt ON fdt.idfsDiagnosis = ft.idfsBaseReference	
		
	UPDATE		ft
	SET	
	  ft.intTotal_Abs_Y1 = fdgt.intTotal,
	  ft.intChildren_Abs_Y1 = fdgt.intAge_0_15
	FROM @ReportTable ft
	INNER JOIN @ReportDiagnosisGroupTable fdgt ON fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	

	----------------------------------------------------------------------------------------
	-- @StartDate2 - @FinishDate2
	-- @FirstRegionID, @FirstRayonID 
	----------------------------------------------------------------------------------------
	UPDATE #ReportDiagnosisTable
	SET 	
		intTotal = 0,
		intAge_0_15 = 0
	
	DELETE FROM @ReportDiagnosisGroupTable
	
	EXEC report.USP_REP_Hum_ComparativeGG_Calculations @StartDate2, @FinishDate2, @RegionID, @RayonID 

	INSERT INTO	@ReportDiagnosisGroupTable

	SELECT	
		dtg.idfsReportDiagnosisGroup,
		SUM(intTotal),
		SUM(intAge_0_15)

	FROM #ReportDiagnosisTable fdt
	INNER JOIN dbo.trtDiagnosisToGroupForReportType dtg ON dtg.idfsDiagnosis = fdt.idfsDiagnosis AND dtg.idfsCustomReportType = @idfsCustomReportType
	
	GROUP BY 
		dtg.idfsReportDiagnosisGroup

--------------------------
	UPDATE ft
	set	
	  ft.intTotal_Abs_Y2 = fdt.intTotal,	
	  ft.intChildren_Abs_Y2 = fdt.intAge_0_15

	FROM @ReportTable ft
	INNER JOIN #ReportDiagnosisTable fdt ON fdt.idfsDiagnosis = ft.idfsBaseReference	
----------------------------		
	UPDATE ft
	SET	
	  ft.intTotal_Abs_Y2 = fdgt.intTotal,
	  ft.intChildren_Abs_Y2 = fdgt.intAge_0_15

	FROM @ReportTable ft
	INNER JOIN	@ReportDiagnosisGroupTable fdgt ON fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	
	
	UPDATE 	rt		
	SET  
		dblTotal_By100000_Y1 = CASE WHEN ISNULL(@StatisticsForFirstYear, 0) > 0 THEN (intTotal_Abs_Y1 * 100000.00) / @StatisticsForFirstYear 
							   ELSE NULL END,  

		dblChildren_By100000_Y1	= CASE WHEN ISNULL(@Statistics0_15ForFirstYear, 0) > 0 THEN (intChildren_Abs_Y1 * 100000.00) / @Statistics0_15ForFirstYear 
								  ELSE NULL END,      
		 			    
		dblTotal_By100000_Y2 = CASE WHEN ISNULL(@StatisticsForSecondYear, 0) > 0 THEN (intTotal_Abs_Y2 * 100000.00) / @StatisticsForSecondYear 
							   ELSE NULL END,
				  
		dblChildren_By100000_Y2 = CASE WHEN ISNULL(@Statistics0_15ForSecondYear, 0) > 0 THEN (intChildren_Abs_Y2 * 100000.00) / @Statistics0_15ForSecondYear 
								  ELSE NULL END

	FROM @ReportTable rt
	
	INSERT INTO @ResultTable
	
	SELECT 
		idfsBaseReference,
		strDisease,
		strICD,
		blnIsSubdisease,
		intTotal_Abs_Y1,
		dblTotal_By100000_Y1,
		intChildren_Abs_Y1,
		dblChildren_By100000_Y1,
		intTotal_Abs_Y2,
		dblTotal_By100000_Y2,
		intChildren_Abs_Y2,
		dblChildren_By100000_Y2,
		intOrder
		
	FROM 	@ReportTable

	SELECT 
		*
		,
		intTotal_Abs_Y2 - intTotal_Abs_Y1 AS GrowthTotal,
		intChildren_Abs_Y2 - intChildren_Abs_Y1 AS GrowthChildren,
		
 		CASE WHEN intTotal_Abs_Y1 > 0 THEN CAST((((CAST(intTotal_Abs_Y2 AS NUMERIC(10,2)) - CAST(intTotal_Abs_Y1 AS NUMERIC(10,2)))/CAST(intTotal_Abs_Y1 AS NUMERIC(10,2)) * 100 )) AS NUMERIC(10,2))
			 WHEN intTotal_Abs_Y2 > 0 THEN CAST((((CAST(intTotal_Abs_Y2 AS NUMERIC(10,2)) - CAST(intTotal_Abs_Y1 AS NUMERIC(10,2)))/CAST(intTotal_Abs_Y2 AS NUMERIC(10,2)) * 100 )) AS NUMERIC(10,2)) 
			 ELSE CASE WHEN intTotal_Abs_Y1 = 0 AND intTotal_Abs_Y2 = 0 THEN CAST(0 AS NUMERIC(10,2)) END
		END AS GrowthPCT,

 		CASE WHEN intChildren_Abs_Y1 > 0 THEN CAST((((CAST(intChildren_Abs_Y2 AS NUMERIC(10,2)) - CAST(intChildren_Abs_Y1 AS NUMERIC(10,2)))/CAST(intChildren_Abs_Y1 AS NUMERIC(10,2)) * 100 )) AS NUMERIC(10,2))
			 WHEN intChildren_Abs_Y2 > 0 THEN CAST((((CAST(intChildren_Abs_Y2 AS NUMERIC(10,2)) - CAST(intChildren_Abs_Y1 AS NUMERIC(10,2)))/CAST(intChildren_Abs_Y2 AS NUMERIC(10,2)) * 100 )) AS NUMERIC(10,2))
			 ELSE CASE WHEN intChildren_Abs_Y1 = 0 AND intChildren_Abs_Y2 = 0 THEN CAST(0 AS NUMERIC(10,2)) END
		END AS GrowthChildrenPCT

	FROM @ResultTable
	ORDER BY intOrder

END
	

