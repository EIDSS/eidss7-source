

--*************************************************************************
-- Name 				: report.USP_REP_HUM_Comparative
-- Description			: This procedure returns data for AJ - Comparative Report
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_HUM_Comparative 'en', 2011, 2016, 1, 12, null, null, null, NULL, null, 1

EXEC report.USP_REP_HUM_Comparative 'en', 2011, 2012, 1, 12, null, null, null, NULL, 867, 1
EXEC report.USP_REP_HUM_Comparative 'en', 2011, 2012, 1, 12, null, null, null, NULL, 868, 1
EXEC report.USP_REP_HUM_Comparative 'en', 2011, 2012, 1, 12, null, null, null, NULL, 869, 1

EXEC report.USP_REP_HUM_Comparative 'en', 2012, 2012, 1, 12, null, null, null, NULL, null, 2
EXEC report.USP_REP_HUM_Comparative 'en', 2012, 2012, 1, 12, 1344330000000, 1344440000000, null, NULL, null, 1

EXEC report.USP_REP_HUM_Comparative 'az-l', 2012, 2014, 1, 12, 1344330000000, 1344440000000, null, NULL, null, 4 -- Baku, Yasamal (Baku)
*/

CREATE PROCEDURE [Report].[USP_REP_HUM_Comparative]
	@LangID				AS VARCHAR(36),
	@FirstYear			AS INT, 
	@SecondYear			AS INT, 
	@StartMonth			AS INT = NULL,
	@EndMonth			AS INT = NULL,
	@FirstRegionID		AS BIGINT = NULL,
	@FirstRayonID		AS BIGINT = NULL,
	@SecondRegionID		AS BIGINT = NULL,
	@SecondRayonID		AS BIGINT = NULL,
	@OrganizationID		AS BIGINT = NULL, -- idfsSiteID!!
	@Counter			AS INT,  -- 1 = Absolute number, 2 = For 10.000 population, 3 = For 100.000 population, 4 = For 1.000.000 population
	@SiteID				AS BIGINT = NULL

AS
BEGIN
	DECLARE	@ReportTable	TABLE
	(	  idfsBaseReference			BIGINT NOT NULL PRIMARY KEY
		, intRowNumber				INT NULL
		, strDisease				NVARCHAR(300) collate database_default NOT NULL 
		, strICD10					NVARCHAR(200) collate database_default NULL	
		, strAdministrativeUnit1	NVARCHAR(2000) collate database_default NOT NULL 
		, intTotal_1_Y1				DECIMAL(8,2) NOT NULL
		, intTotal_1_Y2				DECIMAL(8,2) NOT NULL
		, intTotal_1_Percent		DECIMAL(8,2) NOT NULL
		, intChildren_1_Y1			DECIMAL(8,2) NOT NULL
		, intChildren_1_Y2			DECIMAL(8,2) NOT NULL
		, intChildren_1_Percent		DECIMAL(10,2) NOT NULL
		, strAdministrativeUnit2	NVARCHAR(2000) COLLATE database_default NOT NULL 
		, intTotal_2_Y1				DECIMAL(8,2) NOT NULL
		, intTotal_2_Y2				DECIMAL(8,2) NOT NULL
		, intTotal_2_Percent		DECIMAL(10,2) NOT NULL
		, intChildren_2_Y1			DECIMAL(8,2) NOT NULL
		, intChildren_2_Y2			DECIMAL(8,2) NOT NULL
		, intChildren_2_Percent		DECIMAL(10,2) NOT NULL
		, intOrder					INT NOT NULL
	)


 DECLARE 		
	@StartDate1	DATETIME,	 
	@FinishDate1 DATETIME,
	@StartDate2	DATETIME,	 
	@FinishDate2 DATETIME,
	@idfsLanguage BIGINT,
	@idfsCustomReportType BIGINT,	
	@strAdministrativeUnit1 NVARCHAR(2000),
	@strAdministrativeUnit2 NVARCHAR(2000),

	@CountryID BIGINT,
	@idfsSite BIGINT,
	@idfsSiteType BIGINT,

	@StatisticsForFirstYearFirstArea INT,
	@StatisticsForSecondYearFirstArea INT,
	@StatisticsForFirstYearSecondArea INT,
	@StatisticsForSecondYearSecondArea INT,
	
	@Statistics17ForFirstYearFirstArea INT,
	@Statistics17ForSecondYearFirstArea INT,
	@Statistics17ForFirstYearSecondArea INT,
	@Statistics17ForSecondYearSecondArea INT,	
	
	@idfsStatType_Population BIGINT,
	@idfsStatType_Population17 BIGINT,
	
	@idfsRegionOtherRayons BIGINT,
	@idfsRegionBaku BIGINT,
	@isWeb BIGINT,
	@strRepublic NVARCHAR(100)
	  

	DECLARE @FilteredRayons TABLE
	(idfsRayon BIGINT PRIMARY KEY)

	DECLARE @RayonsForStatistics TABLE
	(idfsRayon BIGINT PRIMARY KEY,
	 maxYear1 INT,
	 maxYear2 INT,
	 maxYear171 INT,
	 maxYear172 INT
	)
	  
	SET @idfsCustomReportType = 10290001 /*Comparative Report*/

	SET @idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)		

	IF @StartMonth IS NULL
	BEGIN
		  SET @StartDate1 = (CAST(@FirstYear AS VARCHAR(4)) + '01' + '01')
		  SET @FinishDate1 = DATEADD(yyyy, 1, @StartDate1)
	  	
		  SET @StartDate2 = (CAST(@SecondYear AS VARCHAR(4)) + '01' + '01')
		  SET @FinishDate2 = DATEADD(yyyy, 1, @StartDate2)
	END
	ELSE
	BEGIN	
	  IF @StartMonth < 10	BEGIN
			  SET @StartDate1 = (CAST(@FirstYear AS VARCHAR(4)) + '0' +CAST(@StartMonth AS VARCHAR(2)) + '01')
			  SET @StartDate2 = (CAST(@SecondYear AS VARCHAR(4)) + '0' +CAST(@StartMonth AS VARCHAR(2)) + '01')
		END	
	  ELSE BEGIN				
			  SET @StartDate1 = (CAST(@FirstYear AS VARCHAR(4)) + CAST(@StartMonth AS VARCHAR(2)) + '01')
			  SET @StartDate2 = (CAST(@SecondYear AS VARCHAR(4)) + CAST(@StartMonth AS VARCHAR(2)) + '01')
		END
			
	  IF (@EndMonth IS NULL) OR (@StartMonth = @EndMonth) BEGIN
			  SET @FinishDate1 = DATEADD(mm, 1, @StartDate1)
			  SET @FinishDate2 = DATEADD(mm, 1, @StartDate2)
		END	
	  ELSE	BEGIN
			IF @EndMonth < 10	BEGIN
				  SET @FinishDate1 = (CAST(@FirstYear AS VARCHAR(4)) + '0' +CAST(@EndMonth AS VARCHAR(2)) + '01')
				  SET @FinishDate2 = (CAST(@SecondYear AS VARCHAR(4)) + '0' +CAST(@EndMonth AS VARCHAR(2)) + '01')
				END
			  ELSE BEGIN
				  SET @FinishDate1 = (CAST(@FirstYear AS VARCHAR(4)) + CAST(@EndMonth AS VARCHAR(2)) + '01')
				  SET @FinishDate2 = (CAST(@SecondYear AS VARCHAR(4)) + CAST(@EndMonth AS VARCHAR(2)) + '01')
				END  
				
			  SET @FinishDate1 = DATEADD(mm, 1, @FinishDate1)
			  SET @FinishDate2 = DATEADD(mm, 1, @FinishDate2)
	  END
	END	

	SET	@CountryID = 170000000
	
	SET @idfsSite = ISNULL(@SiteID, report.FN_GBL_SiteID_GET())
  
	SELECT @isWeb = ISNULL(ts.blnIsWEB, 0) 
	FROM tstSite ts
	WHERE ts.idfsSite = report.FN_GBL_SiteID_GET()  
				
	SELECT @idfsSiteType = ts.idfsSiteType
	FROM tstSite ts
	WHERE ts.idfsSite = @SiteID
	IF @idfsSiteType IS NULL SET @idfsSiteType = 10085001
  				
				
	--SET @idfsStatType_Population = 39850000000  -- Population
	SELECT @idfsStatType_Population = tbra.idfsBaseReference
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType at
		ON at.strAttributeTypeName = N'Statistical Data Type'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Population'
	
	--SET @idfsStatType_Population17 = 000  -- Population under 17
	SELECT @idfsStatType_Population17 = tbra.idfsBaseReference
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType at
		ON at.strAttributeTypeName = N'Statistical Data Type'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Population under 17'	
					
	--1344340000000 --Other rayons
	SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType at
		ON at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Other rayons'			
	
	--1344330000000 --Baku
	SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType at
		ON at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Baku'
	
	--@strRepublic
	SELECT @strRepublic = tsnt.strTextString
 	FROM trtBaseReference tbr 
 		INNER JOIN trtStringNameTranslation tsnt
 		ON tsnt.idfsBaseReference = tbr.idfsBaseReference
 		AND tsnt.idfsLanguage = @idfsLanguage
 	WHERE tbr.idfsReferenceType = 19000132 /*additional report text*/
 	AND tbr.strDefault = 'Republic'
			
	SET @strRepublic = ISNULL(@strRepublic, 'Republic')

	SET @strAdministrativeUnit1 = ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*rftRayon*/) WHERE idfsReference = @FirstRayonID),'') 
							+
							CASE WHEN @FirstRayonID IS NOT NULL AND @FirstRegionID IS NOT NULL AND @FirstRegionID <> @idfsRegionOtherRayons -- Other rayons
							THEN ', '
							ELSE ''
							END
							+
							CASE WHEN @FirstRegionID IS NOT NULL AND (@FirstRayonID IS NULL OR @FirstRegionID <> @idfsRegionOtherRayons) -- Other rayons
								THEN ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*rftRegion*/) WHERE idfsReference = @FirstRegionID),'') 
								ELSE ''
							END
							+
							CASE WHEN @FirstRayonID IS NULL AND @FirstRegionID IS NULL 
								THEN @strRepublic --CASE WHEN @LangID = 'az-l' THEN 'Respublika' WHEN @LangID = 'ru' THEN 'Республика' ELSE 'Republic' END
								ELSE ''
							END
						
					

	SET @strAdministrativeUnit2 = ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*rftRayon*/) WHERE idfsReference = @SecondRayonID),'') 
						   +
						   CASE WHEN @SecondRayonID IS NOT NULL AND @SecondRegionID IS NOT NULL AND @SecondRegionID <> @idfsRegionOtherRayons -- Other rayons
							THEN
								', '
							ELSE ''
						   END
						   +
						   CASE WHEN @SecondRegionID IS NOT NULL AND (@SecondRayonID IS NULL OR @SecondRegionID <> @idfsRegionOtherRayons) -- Other rayons
							THEN
								ISNULL((SELECT [name] FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*rftRegion*/) WHERE idfsReference = @SecondRegionID),'') 
							ELSE ''
						   END
            						+
						   CASE WHEN @SecondRayonID IS NULL AND @SecondRegionID IS NULL AND @OrganizationID IS NULL
							THEN @strRepublic --CASE WHEN @LangID = 'az-l' THEN 'Respublika' WHEN @LangID = 'ru' THEN 'Республика' else 'Republic' END
							ELSE ''
						   END
						   +
							CASE WHEN  @OrganizationID IS NOT NULL
								THEN ISNULL((SELECT TOP 1 fi.[name] 
												FROM report.FN_REP_InstitutionRepair(@LangID) fi 
												INNER JOIN tstSite ts
												ON ts.idfOffice = fi.idfOffice
												WHERE ts.idfsSite = @OrganizationID), '')
								ELSE ''
							END	

-----------------------------------------------------------------------------------------------
IF @Counter > 1 -- 1 = Absolute number
BEGIN

-- get statistic
IF @idfsSiteType NOT IN (10085001, 10085002) OR @isWeb <> 1
BEGIN
    INSERT INTO @FilteredRayons (idfsRayon)
    SELECT r.idfsRayon
    FROM  tstSite s
		INNER JOIN	tstCustomizationPackage cp
		ON			cp.idfCustomizationPackage = s.idfCustomizationPackage	
					AND cp.idfsCountry = @CountryID
		
		INNER JOIN	tlbOffice o
		ON			o.idfOffice = s.idfOffice
					AND o.intRowStatus = 0
					
		INNER JOIN	tlbGeoLocationShared gls
		ON			gls.idfGeoLocationShared = o.idfLocation
		
		INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
          ON		r.idfsRayon = gls.idfsRayon
					AND r.intRowStatus = 0
		
		INNER JOIN	tflSiteToSiteGroup sts
			INNER JOIN	tflSiteGroup tsg
			ON			tsg.idfSiteGroup = sts.idfSiteGroup
						AND tsg.idfsRayon IS NULL
		ON			sts.idfsSite = s.idfsSite
		
		INNER JOIN	tflSiteGroupRelation sgr
		ON			sgr.idfSenderSiteGroup = sts.idfSiteGroup
		
		INNER JOIN	tflSiteToSiteGroup stsr
			INNER JOIN	tflSiteGroup tsgr
			ON			tsgr.idfSiteGroup = stsr.idfSiteGroup
						AND tsgr.idfsRayon IS NULL
		ON			sgr.idfReceiverSiteGroup =stsr.idfSiteGroup
					AND stsr.idfsSite = ISNULL(@SiteID, report.FN_GBL_SiteID_GET())
	WHERE  gls.idfsRayon IS NOT NULL
	
	-- + border area
	INSERT INTO @FilteredRayons (idfsRayon)
	SELECT DISTINCT
		osr.idfsRayon
	FROM @FilteredRayons fr
		INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
          ON r.idfsRayon = fr.idfsRayon
          AND r.intRowStatus = 0
          
        INNER JOIN	tlbGeoLocationShared gls
		ON			gls.idfsRayon = r.idfsRayon
	
		INNER JOIN	tlbOffice o
		ON			gls.idfGeoLocationShared = o.idfLocation
					AND o.intRowStatus = 0
		
		INNER JOIN tstSite s
			INNER JOIN	tstCustomizationPackage cp
			ON			cp.idfCustomizationPackage = s.idfCustomizationPackage	
		ON s.idfOffice = o.idfOffice
		
		INNER JOIN tflSiteGroup tsg_cent 
		ON tsg_cent.idfsCentralSite = s.idfsSite
		AND tsg_cent.idfsRayon IS NULL
		AND tsg_cent.intRowStatus = 0	
		
		INNER JOIN tflSiteToSiteGroup tstsg
		ON tstsg.idfSiteGroup = tsg_cent.idfSiteGroup
		
		INNER JOIN tstSite ts
		ON ts.idfsSite = tstsg.idfsSite
		
		INNER JOIN tlbOffice os
		ON os.idfOffice = ts.idfOffice
		AND os.intRowStatus = 0
		
		INNER JOIN tlbGeoLocationShared ogl
		ON ogl.idfGeoLocationShared = o.idfLocation
		
		INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) osr
		ON osr.idfsRayon = ogl.idfsRayon
		AND ogl.intRowStatus = 0				
		
		LEFT JOIN @FilteredRayons fr2 
		on	osr.idfsRayon = fr2.idfsRayon
	WHERE fr2.idfsRayon IS NULL
	
END

-- Get statictics for first Rayon-region
INSERT INTO @RayonsForStatistics (idfsRayon)
SELECT idfsRayon FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/)
WHERE (
      idfsRayon = @FirstRayonID OR
      (idfsRegion = @FirstRegionID AND @FirstRayonID IS NULL) OR
      (idfsCountry = @CountryID AND @FirstRayonID IS NULL AND @FirstRegionID IS NULL)
      ) 
      AND 
      (
		  @idfsSiteType  IN (10085001, 10085002) --sitCDR, sitEMS
		  OR
		  @isWeb = 1
		  OR 
		  idfsRayon IN (SELECT idfsRayon FROM @FilteredRayons)
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
    
UPDATE	rfstat SET
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
    SELECT @StatisticsForFirstYearFirstArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea 
         AND s.intRowStatus = 0 
         AND s.idfsStatisticDataType = @idfsStatType_Population  
         AND s.datStatisticStartDate = CAST(rfs.maxYear1 AS varchar(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @StatisticsForFirstYearFirstArea = 0       

IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear171 IS NULL)
BEGIN
    SELECT @Statistics17ForFirstYearFirstArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea 
         AND s.intRowStatus = 0 
         AND s.idfsStatisticDataType = @idfsStatType_Population17  
         AND s.datStatisticStartDate = CAST(rfs.maxYear171 AS varchar(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @Statistics17ForFirstYearFirstArea = 0  

      
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
    SELECT @StatisticsForSecondYearFirstArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population  
         AND s.datStatisticStartDate = CAST(rfs.maxYear2 AS varchar(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @StatisticsForSecondYearFirstArea = 0    

IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear172 IS NULL)
BEGIN
    SELECT @Statistics17ForSecondYearFirstArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population17  
         AND s.datStatisticStartDate = CAST(rfs.maxYear172 AS varchar(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @Statistics17ForSecondYearFirstArea = 0   

-- Get statictics for second Rayon-region
DELETE FROM @RayonsForStatistics

INSERT INTO @RayonsForStatistics (idfsRayon)
SELECT idfsRayon FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/)
WHERE (
      idfsRayon = @SecondRayonID OR
      (idfsRegion = @SecondRegionID AND @SecondRayonID IS NULL) OR
      (idfsCountry = @CountryID AND @SecondRayonID IS NULL AND @SecondRegionID IS NULL)
      ) 
      AND 
      (
		@idfsSiteType  in (10085001, 10085002)--sitCDR, sitEMS
		or
		@isWeb = 1
		OR 
		idfsRayon in (SELECT idfsRayon FROM @FilteredRayons)
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
    SELECT @StatisticsForFirstYearSecondArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population 
         AND s.datStatisticStartDate = CAST(rfs.maxYear1 AS varchar(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @StatisticsForFirstYearSecondArea = 0 

IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear171 IS NULL)
BEGIN
    SELECT @Statistics17ForFirstYearSecondArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population17  
         AND s.datStatisticStartDate = CAST(rfs.maxYear171 AS varchar(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @Statistics17ForFirstYearSecondArea = 0       

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
    SELECT @StatisticsForSecondYearSecondArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population  
         AND s.datStatisticStartDate = CAST(rfs.maxYear2 AS VARCHAR(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @StatisticsForSecondYearSecondArea = 0    

IF NOT EXISTS (SELECT * FROM @RayonsForStatistics WHERE maxYear172 IS NULL)
BEGIN
    SELECT @Statistics17ForSecondYearSecondArea = SUM(CAST(s.sumValue AS INT))
    FROM (
    SELECT SUM(CAST(varValue AS INT)) AS sumValue
    FROM dbo.tlbStatistic s
      INNER JOIN @RayonsForStatistics rfs
      ON rfs.idfsRayon = s.idfsArea AND
         s.intRowStatus = 0 AND
         s.idfsStatisticDataType = @idfsStatType_Population17  
         AND s.datStatisticStartDate = CAST(rfs.maxYear2 AS VARCHAR(4)) + '-01-01' 
    GROUP BY rfs.idfsRayon ) AS s
END    
ELSE SET @Statistics17ForSecondYearSecondArea = 0  


-- end of get statistics
END --if @Counter > 1 BEGIN
-----------------------------------------------------------------------------------------------


INSERT INTO @ReportTable (
		idfsBaseReference
		, intRowNumber
	
		, strDisease
		, strICD10
		
		, strAdministrativeUnit1
		, intTotal_1_Y1
		, intTotal_1_Y2
		, intTotal_1_Percent
		, intChildren_1_Y1
		, intChildren_1_Y2
		, intChildren_1_Percent
		
		, strAdministrativeUnit2
		, intTotal_2_Y1
		, intTotal_2_Y2
		, intTotal_2_Percent
		, intChildren_2_Y1
		, intChildren_2_Y2
		, intChildren_2_Percent
		, intOrder

) 
SELECT 
  rr.idfsDiagnosisOrReportDiagnosisGroup,
  CASE
	WHEN	ISNULL(br.idfsReferenceType, -1) = 19000130	-- Diagnosis Group
			AND ISNULL(br.strDefault, N'') = N'Total'
		THEN	null
	ELSE	rr.intRowOrder
  END,
  CASE
	WHEN	ISNULL(br.idfsReferenceType, -1) = 19000130	-- Diagnosis Group
			AND ISNULL(br.strDefault, N'') = N'Total'
		THEN	ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault) + N'*'
	ELSE	ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault)
  END,
  ISNULL(d.strIDC10, dg.strCode),
  
  @strAdministrativeUnit1,
  0,
  0,
  0.00,
  0,
  0,
  0.00,
  
  @strAdministrativeUnit2,
  0,
  0,
  0.00,
  0,
  0,
  0.00,
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
SELECT DISTINCT
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
SELECT DISTINCT
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
-- @FirstRegionID, @FirstRayonID 
----------------------------------------------------------------------------------------
EXEC report.USP_REP_HUM_Comparative_Calculations @CountryID, @StartDate1, @FinishDate1, @FirstRegionID, @FirstRayonID, @OrganizationID

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
			ft.intTotal_1_Y1 = fdt.intTotal,	
			ft.intChildren_1_Y1 = fdt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
			ft.intTotal_1_Y1 = fdgt.intTotal,	
			ft.intChildren_1_Y1 = fdgt.intAge_0_17
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
	

EXEC report.USP_REP_HUM_Comparative_Calculations @CountryID, @StartDate2, @FinishDate2, @FirstRegionID, @FirstRayonID, @OrganizationID

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
  ft.intTotal_1_Y2 = fdt.intTotal,	
	ft.intChildren_1_Y2 = fdt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
  ft.intTotal_1_Y2 = fdgt.intTotal,	
	ft.intChildren_1_Y2 = fdgt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	@ReportDiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	




----------------------------------------------------------------------------------------
-- @StartDate1 - @FinishDate1
-- @SecondRegionID, @SecondRayonID 
----------------------------------------------------------------------------------------
UPDATE #ReportDiagnosisTable
SET 	
	intTotal = 0,
	intAge_0_17 = 0
	
DELETE FROM @ReportDiagnosisGroupTable
	

EXEC report.USP_REP_HUM_Comparative_Calculations @CountryID, @StartDate1, @FinishDate1, @SecondRegionID, @SecondRayonID, @OrganizationID

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
			ft.intTotal_2_Y1 = fdt.intTotal,	
			ft.intChildren_2_Y1 = fdt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
			ft.intTotal_2_Y1 = fdgt.intTotal,	
			ft.intChildren_2_Y1 = fdgt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	@ReportDiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	




----------------------------------------------------------------------------------------
-- @StartDate2 - @FinishDate2
-- @SecondRegionID, @SecondRayonID 
----------------------------------------------------------------------------------------
UPDATE #ReportDiagnosisTable
SET 	
	intTotal = 0,
	intAge_0_17 = 0
	
DELETE FROM @ReportDiagnosisGroupTable
	

EXEC report.USP_REP_HUM_Comparative_Calculations  @CountryID, @StartDate2, @FinishDate2, @SecondRegionID, @SecondRayonID, @OrganizationID

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
			ft.intTotal_2_Y2 = fdt.intTotal,	
			ft.intChildren_2_Y2 = fdt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
			ft.intTotal_2_Y2 = fdgt.intTotal,	
			ft.intChildren_2_Y2 = fdgt.intAge_0_17
FROM		@ReportTable ft
INNER JOIN	@ReportDiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference	




IF @Counter > 1
BEGIN
	IF @Counter = 2 SET @Counter = 10000.00
	ELSE
	IF @Counter = 3 SET @Counter = 100000.00
	ELSE
	IF @Counter = 4 SET @Counter = 1000000

	UPDATE @ReportTable SET 
	intTotal_1_Y1 = CASE ISNULL(@StatisticsForFirstYearFirstArea, 0) WHEN 0 THEN 0 ELSE (intTotal_1_Y1 / @StatisticsForFirstYearFirstArea) * @Counter END,
	intTotal_1_Y2 = CASE ISNULL(@StatisticsForSecondYearFirstArea, 0) WHEN 0 THEN 0 ELSE (intTotal_1_Y2 / @StatisticsForSecondYearFirstArea) * @Counter END,

	intChildren_1_Y1 = CASE ISNULL(@Statistics17ForFirstYearFirstArea, 0) WHEN 0 THEN 0 ELSE (intChildren_1_Y1 / @Statistics17ForFirstYearFirstArea) * @Counter END,
	intChildren_1_Y2 = CASE ISNULL(@Statistics17ForSecondYearFirstArea, 0) WHEN 0 THEN 0 ELSE (intChildren_1_Y2 / @Statistics17ForSecondYearFirstArea) * @Counter END,

	intTotal_2_Y1 = CASE ISNULL(@StatisticsForFirstYearSecondArea, 0) WHEN 0 THEN 0 ELSE (intTotal_2_Y1 / @StatisticsForFirstYearSecondArea) * @Counter END,
	intTotal_2_Y2 = CASE ISNULL(@StatisticsForSecondYearSecondArea, 0) WHEN 0 THEN 0 ELSE (intTotal_2_Y2 / @StatisticsForSecondYearSecondArea) * @Counter END,

	intChildren_2_Y1 = CASE ISNULL(@Statistics17ForFirstYearSecondArea, 0) WHEN 0 THEN 0 ELSE (intChildren_2_Y1 / @Statistics17ForFirstYearSecondArea) * @Counter END,
	intChildren_2_Y2 = CASE ISNULL(@Statistics17ForFirstYearSecondArea, 0) WHEN 0 THEN 0 ELSE (intChildren_2_Y2 / @Statistics17ForSecondYearSecondArea) * @Counter END
END

--- calculate %
--update @ReportTable set
--intTotal_1_Percent = case when intTotal_1_Y1  = 0 then 0.00 else (1.00 * (intTotal_1_Y2 - intTotal_1_Y1)) / intTotal_1_Y1 end,
--intChildren_1_Percent = case when intChildren_1_Y1 = 0 then 0.00 else (1.00 * (intChildren_1_Y2 - intChildren_1_Y1 )) / intChildren_1_Y1 end,


--intTotal_2_Percent = case when intTotal_2_Y1 = 0 then 0.00 else (1.00 * (intTotal_2_Y2 - intTotal_2_Y1)) / intTotal_2_Y1 end,
--intChildren_2_Percent = case when intChildren_2_Y1 = 0 then 0.00 else (1.00 * (intChildren_2_Y2 - intChildren_2_Y1)) / intChildren_2_Y1 end

update @ReportTable set
intTotal_1_Percent = case when intTotal_1_Y2  = 0 then 0.00 else (100.00 * (intTotal_1_Y1 - intTotal_1_Y2)) / intTotal_1_Y2 end,
intChildren_1_Percent = case when intChildren_1_Y2 = 0 then 0.00 else (100.00 * (intChildren_1_Y1 - intChildren_1_Y2 )) / intChildren_1_Y2 end,


intTotal_2_Percent = case when intTotal_2_Y2 = 0 then 0.00 else (100.00 * (intTotal_2_Y1 - intTotal_2_Y2)) / intTotal_2_Y2 end,
intChildren_2_Percent = case when intChildren_2_Y2 = 0 then 0.00 else (100.00 * (intChildren_2_Y1 - intChildren_2_Y2)) / intChildren_2_Y2 end

	
IF 	@Counter in (10000.00, 100000.00)
	SELECT * FROM 	@ReportTable
	ORDER BY intOrder
ELSE
	SELECT 
		 idfsBaseReference	
		, intRowNumber
		, strDisease
		, strICD10		
		, strAdministrativeUnit1 
		, intTotal_1_Y1 intTotal_1_Y1
		, intTotal_1_Y2 intTotal_1_Y2
		, intTotal_1_Percent 
		, intChildren_1_Y1 intChildren_1_Y1
		, intChildren_1_Y2 intChildren_1_Y2
		, intChildren_1_Percent 
		, strAdministrativeUnit2 
		, intTotal_2_Y1  intTotal_2_Y1
		, intTotal_2_Y2  intTotal_2_Y2
		, intTotal_2_Percent 
		, intChildren_2_Y1 intChildren_2_Y1
		, intChildren_2_Y2  intChildren_2_Y2
		, intChildren_2_Percent 
		, intOrder			
	FROM @ReportTable	
ORDER BY intOrder

END
	

