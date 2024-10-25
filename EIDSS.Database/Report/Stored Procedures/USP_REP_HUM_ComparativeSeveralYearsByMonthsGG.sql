



-- This stored proc is to be used for the report:
--
--	Comparative Report of Several Years by Months
--
--  Mark Wilson updated for EIDSS7 standards
--

/*
--Example of a call of procedure:

EXEC report.USP_REP_HUM_ComparativeSeveralYearsByMonthsGG 'en', 2014, 2015, '2'

EXEC report.USP_REP_HUM_ComparativeSeveralYearsByMonthsGG 'en', 2017, 2018, '1'

EXEC report.USP_REP_HUM_ComparativeSeveralYearsByMonthsGG 'en', 2017, 2018, '1,2', '52490230000000,9842300000000,57972080000000,57972090000000'

*/ 
 
CREATE PROCEDURE [Report].[USP_REP_HUM_ComparativeSeveralYearsByMonthsGG]
(
	@LangID AS VARCHAR(36),
	@FirstYear AS INT = 2016, 
	@SecondYear AS INT = 2017, 
	@intCounter AS NVARCHAR(20),  -- 1 = Absolute number, 2 = percent
	@Diagnosis	AS NVARCHAR(MAX) = NULL,
	@RegionID AS BIGINT = NULL,
	@RayonID AS BIGINT = NULL,
	@SiteID	AS BIGINT = NULL,
	@UseArchiveData	AS BIT = 0 --if User selected Use Archive Data then 1
)
AS
BEGIN

	-- Variables - start
	DECLARE	@ReportTable TABLE	
	(
		strkey VARCHAR(200) NOT NULL PRIMARY KEY,   -- let it be intYear + '_' + intCounter
		intYear	INT NOT NULL,
		intCounter	INT NOT NULL,
		intJanuary FLOAT NOT NULL,
		intFebruary FLOAT NOT NULL,
		intMarch FLOAT NOT NULL,
		intApril FLOAT NOT NULL,
		intMay FLOAT NOT NULL,
		intJune FLOAT NOT NULL,
		intJuly FLOAT NOT NULL,
		intAugust FLOAT NOT NULL,
		intSeptember FLOAT NOT NULL,
		intOctober FLOAT NOT NULL,
		intNovember FLOAT NOT NULL,
		intDecember FLOAT NOT NULL,
		intTotal FLOAT NOT NULL
		
	)

	DECLARE

		@idfsLanguage BIGINT,
		@CountryID BIGINT = (SELECT report.FN_GBL_CurrentCountry_Get()),
		@idfsSite BIGINT,
		@StartDate DATETIME,	 
		@FinishDate DATETIME,
		@iDiagnosis INT,
		@intYear INT,
		@idfsCustomReportType BIGINT,
		@idfAttributeType BIGINT
	
	DECLARE @Years TABLE 
	(
		intYear INT NOT NULL PRIMARY KEY
	)

	DECLARE @Counter TABLE 
	(
		intCounter INT NOT NULL
	)

	-- Fill and set initial input parameters - start		
	set @intYear = @FirstYear
	
	WHILE @intYear <= @SecondYear
	BEGIN
		INSERT INTO @Years(intYear) VALUES(@intYear)
		SET @intYear = @intYear + 1
	END		
		
	SET @StartDate = (CAST(@FirstYear AS VARCHAR(4)) + '01' + '01')
	SET @FinishDate = DATEADD(YEAR, 1, (CAST(@SecondYear AS VARCHAR(4)) + '01' + '01'))
	
	SET @idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)	
	
	SET @idfsSite = ISNULL(@SiteID, report.FN_SiteID_GET())
	SET	@idfsCustomReportType = 10290053 /*GG Comparative Report of several years by months*/

	SELECT		@idfAttributeType = at.idfAttributeType
	FROM		trtAttributeType at
	WHERE		at.strAttributeTypeName = N'RDG to SDG' COLLATE Cyrillic_General_CI_AS

	IF OBJECT_ID('tempdb.dbo.#ReportDiagnoses') IS NOT NULL 
	DROP TABLE #ReportDiagnoses

	CREATE TABLE #ReportDiagnoses
	(	
		idfID BIGINT NOT NULL IDENTITY (1, 1),
		idfsDiagnosis BIGINT NOT NULL,
		idfsDiagnosisReportGroup BIGINT NOT NULL,
		idfsDiagnosisGroup BIGINT NULL,
		PRIMARY KEY	(
			idfsDiagnosis ASC,
			idfsDiagnosisReportGroup ASC
		)
	)

	IF @Diagnosis IS NOT NULL
	BEGIN

		INSERT INTO #ReportDiagnoses 
		(
			idfsDiagnosis,
			idfsDiagnosisReportGroup
			--,idfsDiagnosisGroup
		)

		SELECT DISTINCT
			DGFRT.idfsDiagnosis,
			DGFRT.idfsReportDiagnosisGroup
			--,DDG.idfsDiagnosisGroup     //Commented by Srini to eliminate Primary key violation

		FROM dbo.trtDiagnosisToGroupForReportType DGFRT
		LEFT JOIN dbo.trtBaseReference GR ON GR.idfsBaseReference = DGFRT.idfsReportDiagnosisGroup
		LEFT JOIN dbo.trtBaseReference DR ON DR.idfsBaseReference = DGFRT.idfsDiagnosis
		LEFT JOIN dbo.trtDiagnosis D ON D.idfsDiagnosis = DGFRT.idfsDiagnosis
		LEFT JOIN dbo.trtDiagnosisToDiagnosisGroup DDG ON DDG.idfsDiagnosis = DGFRT.idfsDiagnosis

		WHERE DGFRT.idfsDiagnosis IN (SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@Diagnosis, 1, ','))
		AND DGFRT.idfsCustomReportType = @idfsCustomReportType
		AND DR.intRowStatus = 0
		AND GR.intRowStatus = 0
		
		--ORDER BY					//Commented by Srini to Distinct not allowing
		--	GR.strDefault,
		--	DR.strDefault

	END

	IF @intCounter IS NOT NULL
	BEGIN

		INSERT INTO @Counter
		SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@intCounter, 1, ',')
	
	END
	-- Fill and set initial input parameters - end

	-- Calculations - start

	IF EXISTS(SELECT * FROM report.HumComparativeSeveralYearsByMonthsGG) 
		DELETE FROM report.HumComparativeSeveralYearsByMonthsGG

	DECLARE @month TABLE (intMonth INT PRIMARY KEY)

	INSERT INTO @month (intMonth) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)

	INSERT INTO report.HumComparativeSeveralYearsByMonthsGG (intYear, intMonth, intTotal)
	SELECT
		y.intYear,
		m.intMonth, 
		0
	FROM		@Years y
	CROSS JOIN	@month m

	DECLARE cur CURSOR LOCAL FORWARD_ONLY FOR 
	SELECT y.intYear
	FROM @Years y

	OPEN cur

	FETCH NEXT FROM cur INTO @intYear

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @StartDate = (CAST(@intYear AS VARCHAR(4)) + '01' + '01')
		SET @FinishDate = DATEADD(dd, -1, DATEADD(yyyy, 1, @StartDate))
		
		EXEC report.[USP_REP_HUM_ComparativeSeveralYearsByMonthsGG_Calculations] @CountryID, @StartDate, @FinishDate, @RegionID, @RayonID

		FETCH NEXT FROM cur INTO @intYear
	END	

	INSERT INTO	@ReportTable

	SELECT 
		CAST(pvt.intYear AS VARCHAR(10)) + '_' + CAST(ISNULL(c.intCounter, 1) AS VARCHAR(10)) COLLATE Cyrillic_General_CI_AS,
		pvt.intYear,
		ISNULL(c.intCounter, 1),

		CASE WHEN ISNULL(c.intCounter, 1) = 1
				THEN ISNULL([1],0)
			 WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([1],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			 ELSE 0.0
		END AS intJanuary,
		
		CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([2],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([2],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intFebruary,
		  
		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([3],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([3],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intMarch,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([4],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([4],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intApril,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([5],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([5],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intMay,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([6],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([6],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intJune,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([7],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([7],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intJuly,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([8],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([8],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intAugust,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([9],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([9],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intSeptember,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([10],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([10],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intOctober,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([11],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([11],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intNovember,

		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([12],0)
			WHEN ISNULL(c.intCounter, 1) = 2 AND ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0) <> 0
				THEN ISNULL([12],0) * 100.0 / (ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0))
			ELSE 0.0
		  END AS intDecember,
		  
		  CASE
			WHEN ISNULL(c.intCounter, 1) = 1 THEN ISNULL([1],0) + ISNULL([2],0)+ ISNULL([3],0)+ ISNULL([4],0)+ ISNULL([5],0)+ ISNULL([6],0)+ ISNULL([7],0)+ ISNULL([8],0)+ ISNULL([9],0)+ ISNULL([10],0)+ ISNULL([11],0)+ ISNULL([12],0)
			WHEN ISNULL(c.intCounter, 1) = 2 THEN 100.0
		  END AS intTotal	

	FROM 
		(	
			SELECT 
				y.intYear, 
				rt.intMonth, 
				rt.intTotal

			FROM @Years y
			LEFT JOIN report.HumComparativeSeveralYearsByMonthsGG rt ON rt.intYear = y.intYear
		) AS p

		PIVOT
		(	
			SUM(intTotal)
			FOR intMonth IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
		) AS pvt
		LEFT JOIN @Counter c ON c.intCounter in (1, 2)
		ORDER BY 
			pvt.intYear, 
			ISNULL(c.intCounter, 1)

	SELECT 
		intYear,
		intCounter,
		CASE WHEN intCounter = 2 THEN CAST(intJanuary AS DECIMAL(12,2)) ELSE intJanuary END AS intJanuary,
		CASE WHEN intCounter = 2 THEN CAST(intFebruary AS DECIMAL(12,2)) ELSE intFebruary END AS intFebruary,
		CASE WHEN intCounter = 2 THEN CAST(intMarch AS DECIMAL(12,2)) ELSE intMarch END AS intMarch,
		CASE WHEN intCounter = 2 THEN CAST(intApril AS DECIMAL(12,2)) ELSE intApril END AS intApril,
		CASE WHEN intCounter = 2 THEN CAST(intMay AS DECIMAL(12,2)) ELSE intMay END AS intMay,
		CASE WHEN intCounter = 2 THEN CAST(intJune AS DECIMAL(12,2)) ELSE intJune END AS intJune,
		CASE WHEN intCounter = 2 THEN CAST(intJuly AS DECIMAL(12,2)) ELSE intJuly END AS intJuly,
		CASE WHEN intCounter = 2 THEN CAST(intAugust AS DECIMAL(12,2)) ELSE intAugust END AS intAugust,
		CASE WHEN intCounter = 2 THEN CAST(intSeptember AS DECIMAL(12,2)) ELSE intSeptember END AS intSeptember,
		CASE WHEN intCounter = 2 THEN CAST(intOctober AS DECIMAL(12,2)) ELSE intOctober END AS intOctober,
		CASE WHEN intCounter = 2 THEN CAST(intNovember AS DECIMAL(12,2)) ELSE intNovember END AS intNovember,
		CASE WHEN intCounter = 2 THEN CAST(intDecember AS DECIMAL(12,2)) ELSE intDecember END AS intDecember,
		intTotal
	
	FROM @ReportTable

	-- Drop the diagnosis table.  Leave the report table for the Chart dataset
	IF OBJECT_ID('tempdb.dbo.#ReportDiagnoses') IS NOT NULL 
	DROP TABLE #ReportDiagnoses

END
	

