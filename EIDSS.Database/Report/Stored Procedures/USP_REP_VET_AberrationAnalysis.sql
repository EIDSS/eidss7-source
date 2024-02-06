

--- This stored proc is to be used the report:
--
--	Vet Aberration Analysis Report
--
--  Mark Wilson updated for EIDSS7 standards and added calculations
-- for average, standard deviation, and CUSUM
--

/*
--Example of a call of procedure:

DECLARE	@return_value int

EXEC	@return_value = [report].[USP_REP_VET_AberrationAnalysis]
		@LangID = N'en',
		@SD = N'1/1/2019',
		@ED = N'8/28/2020',
		@idfsRegion = NULL,
		@idfsRayon = NULL,
		@idfsSettlement = NULL,
		@idfsDiagnosis = '9842700000000,9843300000000,9843770000000,9843120000000,52490280000000,9842700000000,9843560000000,9842400000000,9843750000000,9842490000000,52490290000000,9842600000000,9842620000000,9842610000000,9842700000000,52490260000000,9842560000000,9842530000000,9842520000000,52490250000000,9842440000000,9842790000000',
		@VetCaseType = N'10012003', -- Livestock
		@ReportType = N'50815490000000', -- Both (Active, Passive)
		@CaseClassif = '350000000,360000000,370000000,380000000,12137920000000',
		@DateOptions = N'1,2,3,4',
		
		-- Analysis Parms
		@AnalysisMethod	= 1,			-- 1='CUSUM',2='HLDM'
		@Threshold = 2.5,
		@MinTimeInterval = 10091001,
		@Baseline = 4,
		@Lag = 1


DECLARE	@return_value int

EXEC	@return_value = Report.USP_REP_VET_AberrationAnalysis
		@LangID = N'en',
		@SD = N'1/1/2019',
		@ED = N'8/28/2020',
		@idfsRegion = NULL,
		@idfsRayon = NULL,
		@idfsSettlement = NULL,
		@idfsDiagnosis = '9842700000000,9843300000000,9843770000000,9843120000000,52490280000000,9842700000000,9843560000000,9842400000000,9843750000000,9842490000000,52490290000000,9842600000000,9842620000000,9842610000000,9842700000000,52490260000000,9842560000000,9842530000000,9842520000000,52490250000000,9842440000000,9842790000000',
		@VetCaseType = N'10012003', -- Livestock
		@ReportType = N'50815490000000', -- Both (Active, Passive)
		@CaseClassif = '350000000,360000000,370000000,380000000,12137920000000',
		@DateOptions = N'1,2,3,4',
		
		-- Analysis Parms
		@AnalysisMethod	= 1,			-- 1='CUSUM',2='HLDM'
		@Threshold = 2.5,
		@MinTimeInterval = '10091004',
		@Baseline = 8,
		@Lag = 1

GO

*/

CREATE PROCEDURE [Report].[USP_REP_VET_AberrationAnalysis]
(
	@LangID		AS NVARCHAR(10), 
	@SD			AS NVARCHAR(20),
	@ED			AS NVARCHAR(20),
	@idfsRegion	AS NVARCHAR(100) = NULL,
	@idfsRayon	AS NVARCHAR(100) = NULL,
	@idfsSettlement	AS NVARCHAR(100) = NULL,
	@idfsDiagnosis	AS NVARCHAR(MAX),
	@VetCaseType AS NVARCHAR(100),
	@ReportType AS NVARCHAR(100),
	@CaseClassif AS NVARCHAR(MAX),
	@DateOptions AS NVARCHAR(100), -- 1-Date of Entry, 2-Date of Diagnosis, 3-Initial Report Date, 4-Investigation Date

	-- Analysis Parms
	@AnalysisMethod	As INT	= 1,			-- 1='CUSUM',2='HLDM'
	@Threshold AS NUMERIC(10,2),
	@MinTimeInterval AS NVARCHAR(100), -- TimeUnit
	@Baseline AS INT,
	@Lag AS INT

)
AS	

DECLARE @returnCode INT = 0 
DECLARE	@returnMsg NVARCHAR(MAX) = 'SUCCESS' 
DECLARE @Start INT = @Lag + @Baseline -- Start Period
DECLARE @End INT = @Lag + 1 -- End Period

BEGIN

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @RegionID BIGINT = CAST(@idfsRegion AS BIGINT)
			DECLARE @RayonID BIGINT = CAST(@idfsRayon AS BIGINT)
			DECLARE @SettlementID BIGINT = CAST(@idfsSettlement AS BIGINT)
			DECLARE @VCType BIGINT = CAST(@VetCaseType AS BIGINT)
			DECLARE @RepType BIGINT = CAST(@ReportType AS BIGINT)

			DECLARE @Classification TABLE 
			(
				Classification BIGINT
			)

			DECLARE @Diagnosis TABLE 
			(
				Diagnosis BIGINT
			)

			DECLARE @DateValues TABLE 
			(
				DateTypes BIGINT
			)

			INSERT INTO @Classification
			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@CaseClassif, 1, ',')

			INSERT INTO @Diagnosis
			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@idfsDiagnosis, 1, ',')

			INSERT INTO @DateValues
			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@DateOptions, 1, ',')

			DECLARE @RawReportTable TABLE
			(
				 [ident] BIGINT,
				 [date]	DATETIME
			)

			DECLARE @ReportTable TABLE
			(
				CaseDate DATETIME,
				Observed INT,
				intSum BIGINT,
				FullSum BIGINT,
				RowID INT,
				StartPeriod INT,
				EndPeriod INT,
				Expected DECIMAL(10,2),
				StandardDeviation DECIMAL(10,2)
			)

			DECLARE @FinalReport TABLE
			(
				RowID INT,
				CaseDate DATETIME,
				CaseYear INT,
				CaseMonth VARCHAR(20),
				Expected DECIMAL(10,2),
				Observed INT,
				StandardDeviation DECIMAL(10,2)
			)

			DECLARE 
			  @StartDate DATETIME = report.FN_GBL_MinMaxTime_GET(CAST(@SD AS DATETIME), 0),
			  @FinishDate DATETIME = report.FN_GBL_MinMaxTime_GET(CAST(@ED AS DATETIME), 1)

			DECLARE @sum INT,
					@fullsum INT

			DECLARE @idfsLanguage BIGINT
			SET @idfsLanguage = report.FN_GBL_LanguageCode_GET (@LangID)

			SET @FinishDate=DATEADD(day, 1, @FinishDate)
	
			IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Month') --'MONTH'
			BEGIN
				IF @StartDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, @StartDate), 0)
					SELECT @StartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @StartDate) + 1, 0)

				IF @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate)+1, 0)
					SELECT @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate), 0)

				ELSE
					SELECT @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate) + 1, 0)
			END

			ELSE IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Week') --'Week'
			BEGIN
				SELECT @StartDate = CASE DATEPART(WEEKDAY, @StartDate) 
									WHEN 1 THEN DATEADD(DAY, 1-DATEPART(WEEKDAY, @StartDate), @StartDate) 
									ELSE DATEADD(DAY, 8-DATEPART(WEEKDAY, @StartDate), @StartDate) END

				SELECT @FinishDate = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @FinishDate), @FinishDate)
			END
	
			IF (@StartDate >= @FinishDate OR @StartDate > '20990101' OR @FinishDate > '20990101')
				SELECT 
					CONVERT(NVARCHAR(20), [date], 120) AS CaseDate, 
					0 AS Observed, 
					0 AS intSum, 
					0 AS fullsum, 
					[ident] AS Rowid

				FROM @RawReportTable

			ELSE

			BEGIN

				INSERT INTO @RawReportTable

				SELECT 
					vc.idfVetCase,
					COALESCE (	CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN vc.datEnteredDate ELSE NULL END,
								CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN vc.datFinalDiagnosisDate ELSE NULL END,
								CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN vc.datReportDate ELSE NULL END,
								CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN vc.datInvestigationDate ELSE NULL END)

				FROM dbo.tlbVetCase vc
    			INNER JOIN @Diagnosis diag ON diag.Diagnosis = vc.idfsShowDiagnosis
    			INNER JOIN @Classification class ON class.Classification = ISNULL(vc.idfsCaseClassification, 0)
      			LEFT OUTER JOIN tlbFarm as tFarm ON vc.idfFarm = tFarm.idfFarm AND tFarm.intRowStatus = 0
      			LEFT OUTER JOIN tlbHuman as tHuman ON tHuman.idfHuman = tFarm.idfHuman AND tHuman.intRowStatus = 0
      			LEFT OUTER JOIN tlbGeoLocation gl ON tFarm.idfFarmAddress = gl.idfGeoLocation AND gl.intRowStatus = 0

				WHERE 	--dates		
					(	@StartDate <= COALESCE (	CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN vc.datEnteredDate ELSE NULL END,
													CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN vc.datFinalDiagnosisDate ELSE NULL END,
													CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN vc.datReportDate ELSE NULL END,
													CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN vc.datInvestigationDate ELSE NULL END)

					   AND @FinishDate > COALESCE (	CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN vc.datEnteredDate ELSE NULL END,
													CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN vc.datFinalDiagnosisDate ELSE NULL END,
													CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN vc.datReportDate ELSE NULL END,
													CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN vc.datInvestigationDate ELSE NULL END)

					)

				-- Avian / Livestock
				AND vc.idfsCaseType = @VCType

				-- region-rayon-settlement
				AND (@RegionID IS NULL OR (gl.idfsRegion IS NOT NULL AND gl.idfsRegion = @RegionID))
				AND (@RayonID IS NULL OR (gl.idfsRayon IS NOT NULL AND gl.idfsRayon = @RayonID)) 
				AND (@SettlementID IS NULL OR (gl.idfsSettlement IS NOT NULL AND gl.idfsSettlement = @SettlementID))

				-- report type
				AND (vc.idfsCaseReportType = @RepType 
						or @RepType = 50815490000000	-- Both
					)

	      		AND vc.intRowStatus = 0

				SELECT 
					@sum = COUNT(*)
				FROM @RawReportTable

				SELECT
					@fullsum=count(*)

				FROM dbo.tlbVetCase vc
    			INNER JOIN @Diagnosis diag ON diag.Diagnosis = vc.idfsShowDiagnosis
    			INNER JOIN @Classification class ON class.Classification = ISNULL(vc.idfsCaseClassification, 0)

				WHERE 	--dates		
					(	@StartDate <= COALESCE (	CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN vc.datEnteredDate ELSE NULL END,
													CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN vc.datFinalDiagnosisDate ELSE NULL END,
													CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN vc.datReportDate ELSE NULL END,
													CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN vc.datInvestigationDate ELSE NULL END)

					   AND @FinishDate > COALESCE (	CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN vc.datEnteredDate ELSE NULL END,
													CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN vc.datFinalDiagnosisDate ELSE NULL END,
													CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN vc.datReportDate ELSE NULL END,
													CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN vc.datInvestigationDate ELSE NULL END)

					)
				AND vc.idfsCaseType = @VCType
				AND (vc.idfsCaseReportType = @RepType 
						or @RepType = 50815490000000	-- Both
					)

	      		AND vc.intRowStatus = 0

				IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Month') --'MONTH'
				BEGIN
					;WITH nm AS 
					(
  						SELECT 
							TOP (DATEDIFF(MONTH, @StartDate, @FinishDate) + 1) nm = ROW_NUMBER() OVER (ORDER BY [object_id])
  						FROM sys.all_objects
					),

					cte AS
					(
					SELECT 
						CONVERT(NVARCHAR(20), DATEADD(MONTH, nm-1, @StartDate), 120) AS CaseDate, 
						COUNT(r.ident) AS Observed, 
						@sum AS intSum, 
						@fullsum AS fullsum, 
						nm AS RowID,
						nm-1-(@Baseline + @Lag) AS StartPeriod,
						nm-1-@Lag AS EndPeriod

					FROM nm
					LEFT OUTER JOIN @RawReportTable r ON DATEADD(MONTH, nm-1, @StartDate) <= [date] AND DATEADD(MONTH, nm, @StartDate) > [date]
					GROUP BY 
						DATEADD(MONTH, nm-1, @StartDate),
						nm
					)

					INSERT INTO @ReportTable
					(
						CaseDate,
						Observed,
						intSum,
						fullSum,
						RowID,
						StartPeriod,
						EndPeriod
					)
					SELECT * FROM cte 

				END

				ELSE IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Week') --'Week'
				BEGIN
	
					;WITH nw AS 
					(
  						SELECT TOP (DATEDIFF(WEEK, @StartDate, @FinishDate)) nw = ROW_NUMBER() OVER (ORDER BY [object_id])
  						FROM sys.all_objects
					),
					cte AS
					(
						SELECT 
							CONVERT(NVARCHAR(20), DATEADD(WEEK, nw-1, @StartDate), 120) AS CaseDate, 
							COUNT(r.ident) AS Observed, 
							@sum AS intSum, 
							@fullsum AS fullsum, 
							nw AS RowID,
							nw-1-(@Baseline + @Lag) AS StartPeriod,
							nw-1-@Lag AS EndPeriod

						FROM nw
						LEFT OUTER JOIN @RawReportTable r ON DATEADD(WEEK, nw-1, @StartDate) <= [date] AND DATEADD(WEEK, nw, @StartDate) > [date]
						GROUP BY 
							DATEADD(WEEK, nw-1, @StartDate), 
							nw
					)

					INSERT INTO @ReportTable
					(
						CaseDate,
						Observed,
						intSum,
						fullSum,
						RowID,
						StartPeriod,
						EndPeriod
					)
					SELECT * FROM cte 

				END

				ELSE IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Day') --'Day'	      
				BEGIN

					;WITH nd AS 
					(
  						SELECT TOP (DATEDIFF(DAY, @StartDate, @FinishDate) + 1) nd = ROW_NUMBER() OVER (ORDER BY [object_id])
  						FROM sys.all_objects
					)
					INSERT INTO @ReportTable
					(
						CaseDate,
						Observed,
						intSum,
						FullSum,
						RowID,
						StartPeriod,
						EndPeriod
					)
					SELECT 
						CONVERT(NVARCHAR(20), DATEADD(DAY, nd-1, @StartDate), 120) AS CaseDate, 
						COUNT(r.ident) as Observed, 
						@sum AS intSum, 
						@fullsum as fullsum, 
						nd as Rowid,
						nd-1-(@Baseline + @Lag) AS StartPeriod,
						nd-1-@Lag AS EndPeriod

					FROM nd
					LEFT OUTER JOIN @RawReportTable r ON DATEADD(DAY, nd-1, @StartDate) = DATEADD(DAY, DATEDIFF(DAY, 0, [date]), 0)
					GROUP BY 
						DATEADD(DAY, nd-1, @StartDate),
						nd;

				END;

				INSERT INTO @FinalReport

				SELECT 
					RT.RowID,
					RT.CaseDate,
					YEAR(RT.CaseDate) AS CaseYear,
							CASE MONTH(RT.CaseDate)
								WHEN 1 THEN 'January'
								WHEN 2 THEN 'February'
								WHEN 3 THEN 'March'
								WHEN 4 THEN 'April'
								WHEN 5 THEN 'May'
								WHEN 6 THEN 'June'
								WHEN 7 THEN 'July'
								WHEN 8 THEN 'August'
								WHEN 9 THEN 'September'
								WHEN 10 THEN 'October'
								WHEN 11 THEN 'November'
								WHEN 12 THEN 'December'
								ELSE NULL
							END AS CaseMonth,
					(SELECT CAST(AVG(CAST(b.Observed AS DECIMAL(12,2))) AS DECIMAL(12,2)) FROM @ReportTable b WHERE b.RowID BETWEEN RT.RowID - @Start AND RT.RowID - @End) AS Expected,
					RT.Observed,
					(SELECT CAST(STDEV(CAST(s.Observed AS DECIMAL(12,2))) AS DECIMAL(12,2)) FROM @ReportTable s WHERE s.RowID BETWEEN RT.RowID - @Start AND RT.RowID - @End) AS RollingSTDEV

				FROM @ReportTable RT

				SELECT 
					R.*,
						CAST(CASE WHEN 
							(CASE WHEN R.RowID <=2 THEN 0 
								 ELSE
											CASE WHEN 
														ISNULL(CASE WHEN (@Threshold * Previous.StandardDeviation) > (@Threshold * Previous.StandardDeviation/2) 
															 THEN @Threshold * Previous.StandardDeviation
															 ELSE @Threshold * Previous.StandardDeviation/2 END,0)
					 
													  <= 0
												  THEN 0 ELSE 
															CASE WHEN (@Threshold * Previous.StandardDeviation) > (@Threshold * Previous.StandardDeviation/2) 
															 THEN @Threshold * Previous.StandardDeviation
															 ELSE @Threshold * Previous.StandardDeviation/2 END 
												  END
											END
										  + R.Observed -(CASE WHEN R.StandardDeviation = 0 THEN 0 ELSE R.Expected -((0.5 * R.StandardDeviation)/R.StandardDeviation) END) 
				  
								) <= 0 THEN 0 
		
								ELSE CASE WHEN R.RowID <=2 THEN 0 
								 ELSE
											CASE WHEN 
														ISNULL(CASE WHEN (@Threshold * Previous.StandardDeviation) > (@Threshold * Previous.StandardDeviation/2) 
															 THEN @Threshold * Previous.StandardDeviation
															 ELSE @Threshold * Previous.StandardDeviation/2 END,0)
					 
													  <= 0
												  THEN 0 ELSE 
															CASE WHEN (@Threshold * Previous.StandardDeviation) > (@Threshold * Previous.StandardDeviation/2) 
															 THEN @Threshold * Previous.StandardDeviation
															 ELSE @Threshold * Previous.StandardDeviation/2 END 
												  END
											END
										  + R.Observed -(CASE WHEN R.StandardDeviation = 0 THEN 0 ELSE R.Expected -((0.5 * R.StandardDeviation)/R.StandardDeviation) END) END AS DECIMAL(10,2))
				  
					AS CUSUM_New,
					@Threshold AS Threshold
				
				FROM @FinalReport R
				LEFT JOIN @FinalReport Previous ON Previous.RowID = R.RowID - 1
				LEFT JOIN @FinalReport PPrev ON PPrev.RowID = R.RowID - 2

			END

		IF @@TRANCOUNT > 0 AND @returnCode = 0
			COMMIT
	
	END TRY
	BEGIN CATCH
		IF @@Trancount = 1 
			ROLLBACK
			SET @returnCode = ERROR_NUMBER()
			SET @returnMsg = 
			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
			+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
			+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
			+ ' ErrorMessage: '+ ERROR_MESSAGE()

			SELECT @returnCode, @returnMsg

	END CATCH

END

