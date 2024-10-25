

--*************************************************************************
-- Name 				: report.USP_REP_HUM_ExternalComparative
-- Description			: This procedure returns data for AJ - External Comparative Report
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_HUM_ExternalComparative 'az-L', 2011, 2016 
EXEC report.USP_REP_HUM_ExternalComparative 'en', 2011, 2014 
EXEC report.USP_REP_HUM_ExternalComparative 'ru', 2011, 2012 
EXEC report.USP_REP_HUM_ExternalComparative 'az-L', 2013, 2014
*/

CREATE PROCEDURE [Report].[USP_REP_HUM_ExternalComparative]
	@LangID				AS VARCHAR(36),
	@FirstYear			AS INT, 
	@SecondYear			AS INT, 
	@EndMonth			AS INT = NULL,
	@RegionID			AS BIGINT = NULL,
	@RayonID			AS BIGINT = NULL,
	@SiteID				AS BIGINT = NULL

AS
BEGIN
	DECLARE	@ResultTable	TABLE
	(	  idfsBaseReference			BIGINT NOT NULL PRIMARY KEY
		, intRowNumber				INT NULL
	
		, strDisease				NVARCHAR(300) COLLATE database_default NOT NULL 
		, blnIsSubdisease			BIT NULL	
		
		--, strAdministrativeUnit		NVARCHAR(2000) COLLATE database_default NOT NULL 
		
		, intTotal_Abs_Y1			    INT    NULL
		, dblTotal_By100000_Y1			DECIMAL(10,2)  NULL
		, intChildren_Abs_Y1			INT    NULL
		, dblChildren_By100000_Y1		DECIMAL(10,2)  NULL
		
		, intTotal_Abs_Y2			    INT    NULL
		, dblTotal_By100000_Y2			DECIMAL(10,2)  NULL
		, intChildren_Abs_Y2			INT    NULL
		, dblChildren_By100000_Y2		DECIMAL(10,2)  NULL
		
		--, dblTotal_Growth			    DECIMAL(10,2)   NULL
		--, dblChildren_Growth			DECIMAL(10,2)   NULL
		
		--, intStatisticsForFirstYear		INT NULL
		--, intStatisticsForSecondYear	INT NULL
		
		--, intStatistics17ForFirstYear	INT NULL
		--, intStatistics17ForSecondYear	INT NULL		
		, intOrder INT
	)
	
  DECLARE	@ReportTable	TABLE
	(	  idfsBaseReference				BIGINT NOT NULL PRIMARY KEY
		, intRowNumber					INT NULL
	
		, strDisease					NVARCHAR(300) COLLATE database_default NOT NULL 
		, blnIsSubdisease				BIT NULL	
		
		--, strAdministrativeUnit			NVARCHAR(2000) COLLATE database_default NOT NULL 
		
		, intTotal_Abs_Y1			    INT    NULL
		, dblTotal_By100000_Y1			DECIMAL(10,2)  NULL
		, intChildren_Abs_Y1			INT    NULL
		, dblChildren_By100000_Y1		DECIMAL(10,2)  NULL
		
		, intTotal_Abs_Y2			    INT    NULL
		, dblTotal_By100000_Y2			DECIMAL(10,2)  NULL
		, intChildren_Abs_Y2			INT    NULL
		, dblChildren_By100000_Y2		DECIMAL(10,2)  NULL
		
		--, dblTotal_Growth			    DECIMAL(10,2)   NULL
		--, dblChildren_Growth			DECIMAL(10,2)   NULL
		
		,	intOrder INT
	)

		
	DECLARE 		
		@StartDate1					DATETIME,	 
		@FinishDate1				DATETIME,

		@StartDate2					DATETIME,	 
		@FinishDate2				DATETIME,
		
		@idfsLanguage				BIGINT,
	  
		@idfsCustomReportType		BIGINT,	
	  
		@strAdministrativeUnit		NVARCHAR(2000),
	  
		@CountryID					BIGINT,
		@idfsSite					BIGINT,
		@idfsSiteType				BIGINT,

	  
		@StatisticsForFirstYear		INT,
		@StatisticsForSecondYear	INT,
	
		@Statistics17ForFirstYear	INT,
		@Statistics17ForSecondYear	INT,
		
		@strStartMonth				NVARCHAR(2),
		@strEndMonth				NVARCHAR(2),

		@idfsStatType_Population BIGINT,
		@idfsStatType_Population17 BIGINT,
			
		@isWeb BIGINT,
		@idfsRegionOtherRayons BIGINT,
		
		--@strAzerbaijanRepublic NVARCHAR(100),
		
 		@TransportCHE BIGINT
	
	
	
	DECLARE @RayonsForStatistics TABLE
	(
		idfsRayon BIGINT PRIMARY KEY,
		 maxYear1 INT,
		 maxYear2 INT,
		 maxYear171 INT,
		 maxYear172 INT		 
	)
		  
	
	SET @idfsCustomReportType = 10290019 /*External Comparative Report*/
	SET @idfsLanguage = report.FN_GBL_LanguageCode_GET (@LangID)		

	DECLARE @StartMonth INT
	IF @StartMonth IS NULL SET @StartMonth = 1
	IF @EndMonth IS NULL SET @EndMonth = 12


	SET @strStartMonth = CASE WHEN 	@StartMonth	BETWEEN 1 AND 9 THEN '0' + CAST(@StartMonth as NVARCHAR) ELSE CAST(@StartMonth as NVARCHAR) END
	SET @strEndMonth = CASE WHEN @EndMonth	BETWEEN 1 AND 9 THEN '0' + CAST(@EndMonth as NVARCHAR) ELSE CAST(@EndMonth as NVARCHAR) END	
		
	SET @StartDate1  = (CAST(@FirstYear AS VARCHAR(4)) + @strStartMonth + '01')
	SET @FinishDate1  = DATEADD(mm, 1, (CAST(@FirstYear AS VARCHAR(4)) + @strEndMonth + '01'))

	SET @StartDate2  = (CAST(@SecondYear AS VARCHAR(4)) + @strStartMonth + '01')
	SET @FinishDate2  = DATEADD(mm, 1, (CAST(@SecondYear AS VARCHAR(4)) + @strEndMonth + '01'))	
	
	
	
	
	SET	@CountryID = 170000000
	
	SET @idfsSite = ISNULL(@SiteID, report.FN_SiteID_GET())
  
	SELECT @isWeb = ISNULL(ts.blnIsWEB, 0) 
	FROM tstSite ts
	WHERE ts.idfsSite = report.FN_SiteID_GET()  
	
	SELECT @idfsSiteType = ts.idfsSiteType
	FROM tstSite ts
	WHERE ts.idfsSite = @SiteID
	IF @idfsSiteType IS NULL SET @idfsSiteType = 10085001
			
	--SET @idfsStatType_Population = 39850000000  -- Population
	SELECT @idfsStatType_Population = tbra.idfsBaseReference
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'Statistical Data Type'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Population'
	
	--SET @idfsStatType_Population17 = 000  -- Population under 17
	SELECT @idfsStatType_Population17 = tbra.idfsBaseReference
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'Statistical Data Type'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Population under 17'	
					
	SELECT @TransportCHE = frr.idfsReference
 	FROM report.FN_GBL_GIS_ReferenceRepair_GET('en', 19000020) frr
 	WHERE frr.name =  'Transport CHE'
 	--print @TransportCHE
 	
	--1344340000000 --Other rayons
	SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Other rayons'		
	
	----@strAzerbaijanRepublic
	--SELECT @strAzerbaijanRepublic = tsnt.strTextString
 --	FROM trtBaseReference tbr 
 --		INNER JOIN trtStringNameTranslation tsnt
 --		on tsnt.idfsBaseReference = tbr.idfsBaseReference
 --		AND tsnt.idfsLanguage = @idfsLanguage
 --	WHERE tbr.idfsReferenceType = 19000132 /*additional report text*/
 --	AND tbr.strDefault = 'Azerbaijan Republic'
 	
 --	SET @strAzerbaijanRepublic = ISNULL(@strAzerbaijanRepublic, 'Azerbaijan Republic')		
			
	--SET @strAdministrativeUnit = ISNULL((SELECT [name] FROM fnGisReference(@LangID, 19000002 /*rftRayon*/) WHERE idfsReference = @RayonID),'') 
 --                      +
 --                      CASE WHEN @RayonID IS NOT NULL AND @RegionID IS NOT NULL AND @RegionID <> 1344340000000 -- Other rayons
 --                       THEN
 --                           ', '
 --                       ELSE ''
 --                      END
 --                      +
 --                      CASE WHEN @RegionID IS NOT NULL AND (@RayonID IS NULL OR @RegionID <> 1344340000000) -- Other rayons
 --                       THEN
 --                           ISNULL((SELECT [name] FROM fnGisReference(@LangID, 19000003 /*rftRegion*/) WHERE idfsReference = @RegionID),'') 
 --                       ELSE ''
 --                      END
 --           					+  @strAzerbaijanRepublic   
                       
            					
	
	
-- get statistic
	
	
-- Get statictics for Rayon-region
INSERT INTO @RayonsForStatistics (idfsRayon)
SELECT idfsRayon FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/)
WHERE (
      idfsRayon = @RayonID OR
      (idfsRegion = @RegionID AND @RayonID IS NULL) OR
      (idfsCountry = @CountryID AND @RayonID IS NULL AND @RegionID IS NULL) OR
	  (idfsCountry = @CountryID AND @RegionID = @TransportCHE)
      ) 
      AND intRowStatus = 0
			

	  
		  			
-- first year
-- определяем для каждого района максимальный год (меньший или равный отчетному году), за который есть статистика.
UPDATE rfstat SET
   rfstat.maxYear1 = maxYear
FROM @RayonsForStatistics rfstat
INNER JOIN (
    SELECT MAX(YEAR(stat.datStatisticStartDate)) AS maxYear, rfs.idfsRayon
    FROM @RayonsForStatistics  rfs    
      INNER JOIN dbo.tlbStatistic stat
      ON stat.idfsArea = rfs.idfsRayon 
      AND stat.intRowStatus = 0
      AND stat.idfsStatisticDataType = @idfsStatType_Population
      AND YEAR(stat.datStatisticStartDate) <= @FirstYear
    GROUP BY  idfsRayon
    ) AS mrfs
    ON rfstat.idfsRayon = mrfs.idfsRayon
    
UPDATE rfstat SET
   rfstat.maxYear171 = maxYear
FROM @RayonsForStatistics rfstat
INNER JOIN (
    SELECT MAX(YEAR(stat.datStatisticStartDate)) AS maxYear, rfs.idfsRayon
    FROM @RayonsForStatistics  rfs    
      INNER JOIN dbo.tlbStatistic stat
      ON stat.idfsArea = rfs.idfsRayon 
      AND stat.intRowStatus = 0
      AND stat.idfsStatisticDataType = @idfsStatType_Population17 
      AND YEAR(stat.datStatisticStartDate) <= @FirstYear
    GROUP BY  idfsRayon
    ) AS mrfs
    ON rfstat.idfsRayon = mrfs.idfsRayon    
                                      	
--если статистика есть по каждому району, то суммируем ее. 
--Иначе считаем статистику не полной и вообще не считаем для данного года-региона
IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear1 IS NULL)
BEGIN
    SELECT @StatisticsForFirstYear = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population AND
         s.datStatisticStartDate = CAST(rfs.maxYear1 AS VARCHAR(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @StatisticsForFirstYear = 0      

IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear171 IS NULL)
BEGIN
    SELECT @Statistics17ForFirstYear = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) as sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population17 AND
         s.datStatisticStartDate = CAST(rfs.maxYear171 AS VARCHAR(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @Statistics17ForFirstYear = 0    

      
-- second year
-- определяем для каждого района максимальный год (меньший или равный отчетному году), за который есть статистика.
UPDATE rfstat SET
   rfstat.maxYear2 = maxYear
FROM @RayonsForStatistics rfstat
INNER JOIN (
    SELECT MAX(YEAR(stat.datStatisticStartDate)) AS maxYear, rfs.idfsRayon
    FROM @RayonsForStatistics  rfs    
      INNER JOIN dbo.tlbStatistic stat
      ON stat.idfsArea = rfs.idfsRayon 
      AND stat.intRowStatus = 0
      AND stat.idfsStatisticDataType = @idfsStatType_Population
      AND YEAR(stat.datStatisticStartDate) <= @SecondYear
    GROUP BY  idfsRayon
    ) AS mrfs
    ON rfstat.idfsRayon = mrfs.idfsRayon
    
UPDATE rfstat SET
   rfstat.maxYear172 = maxYear
FROM @RayonsForStatistics rfstat
INNER JOIN (
    SELECT MAX(YEAR(stat.datStatisticStartDate)) AS maxYear, rfs.idfsRayon
    FROM @RayonsForStatistics  rfs    
      INNER JOIN dbo.tlbStatistic stat
      ON stat.idfsArea = rfs.idfsRayon 
      AND stat.intRowStatus = 0
      AND stat.idfsStatisticDataType = @idfsStatType_Population17
      AND YEAR(stat.datStatisticStartDate) <= @SecondYear
    GROUP BY  idfsRayon
    ) AS mrfs
    ON rfstat.idfsRayon = mrfs.idfsRayon    
                                      	
--если статистика есть по каждому району, то суммируем ее. 
--Иначе считаем статистику не полной и вообще не считаем для данного года-региона
IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear2 IS NULL)
BEGIN
    SELECT @StatisticsForSecondYear = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population AND 
         s.datStatisticStartDate = CAST(rfs.maxYear2 AS VARCHAR(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @StatisticsForSecondYear = 0    

	
IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear172 IS NULL)
BEGIN
    SELECT @Statistics17ForSecondYear = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population17 AND 
         s.datStatisticStartDate = CAST(rfs.maxYear172 AS VARCHAR(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @Statistics17ForSecondYear = 0  		
		
		
		
INSERT INTO @ReportTable (
      idfsBaseReference
		, intRowNumber
		, strDisease
		, blnIsSubdisease
		--, strAdministrativeUnit

    , intTotal_Abs_Y1			    
		, dblTotal_By100000_Y1		
		, intChildren_Abs_Y1		  
		, dblChildren_By100000_Y1	
		
		, intTotal_Abs_Y2			    
		, dblTotal_By100000_Y2		
		, intChildren_Abs_Y2		  
		, dblChildren_By100000_Y2	
		
		, intOrder
) 
SELECT 
	rr.idfsDiagnosisOrReportDiagnosisGroup, --idfsBaseReference
	rr.intRowOrder, --intRowNumber
	ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault), --strDisease
	CASE WHEN rr.intNullValueInsteadZero & 1 > 0 THEN 1 ELSE 0 END, --blnIsSubdisease

	--@strAdministrativeUnit, --strAdministrativeUnit
  
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
    LEFT JOIN trtBaseReference br
        LEFT JOIN trtStringNameTranslation snt
        ON br.idfsBaseReference = snt.idfsBaseReference
			  AND snt.idfsLanguage = @idfsLanguage
			  
        LEFT OUTER JOIN trtDiagnosis d
        ON br.idfsBaseReference = d.idfsDiagnosis
			  
        LEFT OUTER JOIN trtReportDiagnosisGroup dg
        ON br.idfsBaseReference = dg.idfsReportDiagnosisGroup
    ON rr.idfsDiagnosisOrReportDiagnosisGroup = br.idfsBaseReference
   
    -- additional text
    LEFT OUTER JOIN trtBaseReference br1
        LEFT OUTER JOIN trtStringNameTranslation snt1
        ON br1.idfsBaseReference = snt1.idfsBaseReference
			  AND snt1.idfsLanguage = @idfsLanguage
    ON rr.idfsReportAdditionalText = br1.idfsBaseReference
WHERE rr.idfsCustomReportType = @idfsCustomReportType
		AND rr.intRowStatus = 0
ORDER BY rr.intRowOrder  


IF OBJECT_ID('tempdb.dbo.#ReportDiagnosisTable') IS NOT NULL 
DROP TABLE #ReportDiagnosisTable

CREATE TABLE 	#ReportDiagnosisTable
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
	blnIsAggregate		BIT,
	intTotal			INT NOT NULL,
	intAge_0_17			INT NOT NULL
)

INSERT INTO #ReportDiagnosisTable (
	idfsDiagnosis,
	blnIsAggregate,
	intTotal,
	intAge_0_17
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
    INNER JOIN trtDiagnosis trtd
    ON trtd.idfsDiagnosis = fdt.idfsDiagnosis 
WHERE  fdt.idfsCustomReportType = @idfsCustomReportType 

       
INSERT INTO #ReportDiagnosisTable (
	idfsDiagnosis,
	blnIsAggregate,
	intTotal,
	intAge_0_17
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
    INNER JOIN trtBaseReference br
    ON br.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
        AND br.idfsReferenceType = 19000019 --'rftDiagnosis'
    INNER JOIN trtDiagnosis trtd
    ON trtd.idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup 
--        AND trtd.intRowStatus = 0
WHERE  rr.idfsCustomReportType = @idfsCustomReportType 
       AND  rr.intRowStatus = 0 
       AND NOT EXISTS 
       (
       SELECT * FROM #ReportDiagnosisTable
       WHERE idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup
       )      


DECLARE	@ReportDiagnosisGroupTable	TABLE
(	idfsDiagnosisGroup	BIGINT NOT NULL PRIMARY KEY,
	intTotal			INT NOT NULL,
	intAge_0_17			INT NOT NULL
)

	
----------------------------------------------------------------------------------------
-- @StartDate1 - @FinishDate1
----------------------------------------------------------------------------------------
EXEC report.USP_REP_HUM_ExternalComparative_Calculations @CountryID, @StartDate1, @FinishDate1, @RegionID, @RayonID 

DELETE FROM @ReportDiagnosisGroupTable

INSERT INTO	@ReportDiagnosisGroupTable
(	idfsDiagnosisGroup,
	intTotal,
	intAge_0_17
)
SELECT		dtg.idfsReportDiagnosisGroup,
	    SUM(intTotal),	
	    SUM(intAge_0_17)
FROM		#ReportDiagnosisTable fdt
INNER JOIN	dbo.trtDiagnosisToGroupForReportType dtg
ON			dtg.idfsDiagnosis = fdt.idfsDiagnosis
			AND dtg.idfsCustomReportType = @idfsCustomReportType
GROUP BY	dtg.idfsReportDiagnosisGroup

   		
UPDATE		ft
SET	
	ft.intTotal_Abs_Y1 = fdt.intTotal,	
	ft.intChildren_Abs_Y1 = fdt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
	ft.intTotal_Abs_Y1 = fdgt.intTotal,	
	ft.intChildren_Abs_Y1 = fdgt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	@ReportDiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	


----------------------------------------------------------------------------------------
-- @StartDate2 - @FinishDate2
-- @FirstRegionID, @FirstRayonID 
----------------------------------------------------------------------------------------
UPDATE #ReportDiagnosisTable
SET 	
	intTotal = 0,
	intAge_0_17 = 0
	
DELETE FROM @ReportDiagnosisGroupTable
	

EXEC report.USP_REP_HUM_ExternalComparative_Calculations @CountryID, @StartDate2, @FinishDate2, @RegionID, @RayonID 


INSERT INTO	@ReportDiagnosisGroupTable
(	idfsDiagnosisGroup,
	intTotal,
	intAge_0_17
)
SELECT		dtg.idfsReportDiagnosisGroup,
	    SUM(intTotal),	
	    SUM(intAge_0_17)
FROM		#ReportDiagnosisTable fdt
INNER JOIN	dbo.trtDiagnosisToGroupForReportType dtg
ON			dtg.idfsDiagnosis = fdt.idfsDiagnosis
			AND dtg.idfsCustomReportType = @idfsCustomReportType
GROUP BY	dtg.idfsReportDiagnosisGroup

UPDATE		ft
SET	
  ft.intTotal_Abs_Y2 = fdt.intTotal,	
	ft.intChildren_Abs_Y2 = fdt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
  ft.intTotal_Abs_Y2 = fdgt.intTotal,	
	ft.intChildren_Abs_Y2 = fdgt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	@ReportDiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	
	

--------------------------------

	
	
UPDATE 	rt		SET  

		dblTotal_By100000_Y1	  = CASE WHEN ISNULL(@StatisticsForFirstYear, 0) > 0 
		                                THEN (intTotal_Abs_Y1 * 100000.00) / @StatisticsForFirstYear 
		                                ELSE NULL
									END,  
		
		
		dblChildren_By100000_Y1	= CASE WHEN ISNULL(@Statistics17ForFirstYear, 0) > 0 
		                                THEN (intChildren_Abs_Y1 * 100000.00) / @Statistics17ForFirstYear 
		                                ELSE NULL
		                          END,      
		 			    
		dblTotal_By100000_Y2		= CASE WHEN ISNULL(@StatisticsForSecondYear, 0) > 0 
		                                THEN (intTotal_Abs_Y2 * 100000.00) / @StatisticsForSecondYear 
		                                ELSE NULL
		                          END,
		
				  
		dblChildren_By100000_Y2 =	CASE WHEN ISNULL(@Statistics17ForSecondYear, 0) > 0 
		                                THEN (intChildren_Abs_Y2 * 100000.00) / @Statistics17ForSecondYear 
		                                ELSE NULL
		                            END
		--dblTotal_Growth =			CASE WHEN intTotal_Abs_Y1 > 0 AND intTotal_Abs_Y2 > 0 AND @StatisticsForFirstYear> 0 AND @StatisticsForSecondYear>0
		--									THEN
		--										CASE WHEN 
		--											((intTotal_Abs_Y1 * 100000.00	/ @StatisticsForFirstYear) * 100.00 / 
		--											(intTotal_Abs_Y2 * 100000.00	/ @StatisticsForSecondYear) - 100.00) > 100
		--											THEN 
		--												((intTotal_Abs_Y1 * 100000.00	/ @StatisticsForFirstYear) * 100.00 / 
		--												(intTotal_Abs_Y2 * 100000.00	/ @StatisticsForSecondYear) - 100.00) / 100.00
		--											ELSE
		--												((intTotal_Abs_Y1 * 100000.00	/ @StatisticsForFirstYear) * 100.00 / 
		--												(intTotal_Abs_Y2 * 100000.00	/ @StatisticsForSecondYear) - 100.00)
		--										END
		--									ELSE NULL
		--							END,
		--dblChildren_Growth =			CASE WHEN intChildren_Abs_Y1 > 0 AND intChildren_Abs_Y2 > 0 AND @Statistics17ForFirstYear > 0 AND @Statistics17ForSecondYear > 0
		--									THEN
		--										CASE WHEN 
		--											((intChildren_Abs_Y1 * 100000.00	/ @Statistics17ForFirstYear) * 100.00 / 
		--											(intChildren_Abs_Y2 * 100000.00	/ @Statistics17ForSecondYear) - 100.00) > 100
		--											THEN 
		--												((intChildren_Abs_Y1 * 100000.00	/ @Statistics17ForFirstYear) * 100.00 / 
		--												(intChildren_Abs_Y2 * 100000.00	/ @Statistics17ForSecondYear) - 100.00) / 100.00
		--											ELSE
		--												((intChildren_Abs_Y1 * 100000.00	/ @Statistics17ForFirstYear) * 100.00 / 
		--												(intChildren_Abs_Y2 * 100000.00	/ @Statistics17ForSecondYear) - 100.00)
		--										END
		--									ELSE NULL
		--							END

FROM 		@ReportTable rt
	
	



INSERT INTO	@ResultTable
	(	  idfsBaseReference
		, intRowNumber
	
		, strDisease
		, blnIsSubdisease
		
		--, strAdministrativeUnit
		
		, intTotal_Abs_Y1
		, dblTotal_By100000_Y1
		, intChildren_Abs_Y1
		, dblChildren_By100000_Y1
		, intTotal_Abs_Y2
		, dblTotal_By100000_Y2
		, intChildren_Abs_Y2
		, dblChildren_By100000_Y2
		
		--, intStatisticsForFirstYear
		--, intStatisticsForSecondYear	
		--, intStatistics17ForFirstYear	
		--, intStatistics17ForSecondYear	
		
		, intOrder
	)
	
SELECT 
		  idfsBaseReference	
		, intRowNumber
	
		, strDisease
		, blnIsSubdisease
		
		--, strAdministrativeUnit
		
		, CASE WHEN intTotal_Abs_Y1 = 0 THEN NULL ELSE intTotal_Abs_Y1  END
		, CASE WHEN dblTotal_By100000_Y1 = 0 THEN NULL ELSE dblTotal_By100000_Y1  END
		, CASE WHEN intChildren_Abs_Y1 = 0 THEN NULL ELSE intChildren_Abs_Y1  END
		, CASE WHEN dblChildren_By100000_Y1 = 0 THEN NULL ELSE dblChildren_By100000_Y1  END
		
		, CASE WHEN intTotal_Abs_Y2 = 0 THEN NULL ELSE intTotal_Abs_Y2  END
		, CASE WHEN dblTotal_By100000_Y2 = 0 THEN NULL ELSE dblTotal_By100000_Y2  END
		, CASE WHEN intChildren_Abs_Y2 = 0 THEN NULL ELSE intChildren_Abs_Y2 END
		, CASE WHEN dblChildren_By100000_Y2 = 0 THEN NULL ELSE dblChildren_By100000_Y2  END
		
		--, @StatisticsForFirstYear
		--, @StatisticsForSecondYear	
		--, @Statistics17ForFirstYear	
		--, @Statistics17ForSecondYear			
		
		, intOrder
		
FROM 	@ReportTable


SELECT 
	idfsBaseReference
	,intRowNumber
	,strDisease
	,blnIsSubdisease
	,ISNULL(strDisease,0) AS strDisease
	,ISNULL(blnIsSubdisease,0) AS blnIsSubdisease
	,ISNULL(intTotal_Abs_Y1,0) AS intTotal_Abs_Y1
	,ISNULL(dblTotal_By100000_Y1,0) AS dblTotal_By100000_Y1
	,ISNULL(intChildren_Abs_Y1,0) AS intChildren_Abs_Y1
	,ISNULL(dblChildren_By100000_Y1,0) AS dblChildren_By100000_Y1
	,ISNULL(intTotal_Abs_Y2,0) AS intTotal_Abs_Y2
	,ISNULL(dblTotal_By100000_Y2,0) AS dblTotal_By100000_Y2
	,ISNULL(intChildren_Abs_Y2,0) AS intChildren_Abs_Y2
	,ISNULL(dblChildren_By100000_Y2,0) AS dblChildren_By100000_Y2
	,intOrder
FROM @ResultTable
ORDER BY intOrder
	

END
	

