
--- This stored proc is to be used the report:
--
--	Comparative Report on Infectious Diseases/Conditions (by MONTHS)
--
--  Mark Wilson updated for EIDSS7 standards
--
-- 02Apr2020 MCW Updated to add ReportType (Active, Passive) as a parameter
-- 25Sep2020 MCW Updated to use base reference values for time intervals

/*
--Example of a call of procedure:

DECLARE	@return_value int

EXEC	@return_value = [report].[USP_REP_HUM_AberrationAnalysis]
		@LangID = N'en',
		@SD = N'01-01-2019',
		@ED = N'12-31-2020',
		@idfsDiagnosis = N'779090000000,52490230000000,9842300000000,57972080000000,56161350000000,57972090000000,9842390000000,9842440000000,9842450000000,9842460000000,9842470000000,9842480000000,57972100000000,9842610000000,9842700000000,9842710000000,9842720000000,9842730000000,9842750000000,9842760000000,9842800000000,9842870000000,9842880000000,9842960000000,9842980000000,9842990000000,57972120000000,57972130000000,57972140000000,57972150000000,9843110000000,9843200000000,9843220000000,9843230000000,10019001,9843260000000,57972210000000,9843310000000,9843360000000,9843380000000,9843420000000,9843430000000,9843460000000,9843470000000,9843480000000,9843490000000,56161390000000,9843510000000,9843520000000,9843550000000,57972220000000,57972230000000,57972260000000,9843620000000,9843660000000,9843670000000,9843680000000,9843710000000,57972270000000,9843760000000,9843770000000,9843780000000,9843820000000,57972280000000,57972290000000,57972300000000,57972310000000,57972320000000,57972330000000,57972340000000,57972350000000,10019002,57972360000000,57972370000000,57972380000000,57972390000000,57972400000000,9843900000000,9843910000000,18158770001101,58218970000037,9843990000000,9844010000000,9844030000000,9844050000000,9844060000000,9844080000000,9844090000000,9844100000000,9844110000000,9844120000000,9844130000000,9844140000000,9844230000000',
		@StartAge = NULL,
		@FinishAge = NULL,
		@idfsRegion = NULL, --N'37030000000',
		@idfsRayon = NULL, --N'1343010000000',
		@idfsSettlement = NULL,
		@idfsGender = NULL,
		@idfsCaseClassification = N'350000000,360000000,380000000',
		@DateOptions = '1,2,3,4,5',
		@ReportType = NULL, --4578940000001,

		@Threshold = 2.4,
		@MinTimeInterval = '10091004',
		@Baseline = 4,
		@Lag = 1

SELECT	'Return Value' = @return_value

GO

*/

CREATE PROCEDURE [Report].[USP_REP_HUM_AberrationAnalysis]
(
	@LangID		AS NVARCHAR(10), 
	@SD			AS DATETIME,
	@ED			AS DATETIME,	
	@idfsRegion	AS NVARCHAR(100) = NULL,
	@idfsRayon	AS NVARCHAR(100) = NULL,
	@idfsSettlement	AS NVARCHAR(100) = NULL,
	@idfsDiagnosis	AS NVARCHAR(MAX),
	@idfsGender		AS NVARCHAR(100) = NULL,
	@StartAge	AS INT = NULL,
	@FinishAge	AS INT = NULL,
	@idfsCaseClassification	AS NVARCHAR(MAX),
	@DateOptions AS NVARCHAR(100),
	@ReportType BIGINT = NULL, -- 4578940000001 = Active, 4578940000002 = Passive
	@idfsOrganization AS NVARCHAR(MAX) = NULL,

	-- Analysis Parms
	@AnalysisMethod	AS INT	= 1,			-- 1='CUSUM',2='HLDM'
	@Threshold AS NUMERIC(10,2),
	@MinTimeInterval AS NVARCHAR(100), -- TimeUnit
	@Baseline AS INT,
	@Lag AS INT = NULL

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
			DECLARE @idfsDiseaseReportType BIGINT = CAST(@ReportType AS BIGINT)
			DECLARE @Gender TABLE 
			(
				Gender BIGINT

			)

			INSERT INTO @Gender
			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@idfsGender, 1, ',')

			DECLARE @Classification TABLE 
			(
				Classification BIGINT

			)

			DECLARE @DateValues TABLE 
			(
				DateTypes BIGINT

			)

			DECLARE @Diagnosis TABLE 
			(
				idfsDiagnosis BIGINT

			)

			INSERT INTO @Classification
			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@idfsCaseClassification, 1, ',')

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
					SELECT @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate)-1, 0)
			END

			IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Week') --'WEEK'
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
					hc.idfHumanCase,
					COALESCE(CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN hc.datOnSetDate ELSE NULL END,
								CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN hc.datNotiFicationDate ELSE NULL END,
								CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN  hc.datTentativeDiagnosisDate ELSE NULL END,
								CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN  hc.datFinalDiagnosisDate ELSE NULL END,
								CASE WHEN 5 IN (SELECT * FROM  @DateValues) THEN hc.datEnteredDate ELSE NULL END) 
				FROM dbo.tlbHumanCASE hc
				INNER JOIN dbo.tlbHuman h ON hc.idfHuman = h.idfHuman AND h.intRowStatus = 0
				LEFT OUTER JOIN dbo.tlbGeoLocation gl ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
				LEFT JOIN @Diagnosis D ON D.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

				WHERE 	--dates		
				(	@StartDate <= COALESCE(CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN hc.datOnSetDate ELSE NULL END,
											CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN hc.datNotiFicationDate ELSE NULL END,
											CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN  hc.datTentativeDiagnosisDate ELSE NULL END,
											CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN  hc.datFinalDiagnosisDate ELSE NULL END,
											CASE WHEN 5 IN (SELECT * FROM  @DateValues) THEN hc.datEnteredDate ELSE NULL END)

					AND  @FinishDate > COALESCE(CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN hc.datOnSetDate ELSE NULL END,
												CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN hc.datNotiFicationDate ELSE NULL END,
												CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN  hc.datTentativeDiagnosisDate ELSE NULL END,
												CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN  hc.datFinalDiagnosisDate ELSE NULL END,
												CASE WHEN 5 IN (SELECT * FROM  @DateValues) THEN hc.datEnteredDate ELSE NULL END)

				)

					-- region-rayon-settlement
				AND (@RegionID is NULL or (gl.idfsRegion is not NULL AND gl.idfsRegion = @RegionID))
				AND (@RayonID is NULL or (gl.idfsRayon is not NULL AND gl.idfsRayon = @RayonID)) 
				AND (@SettlementID is NULL or (gl.idfsSettlement is not NULL AND gl.idfsSettlement = @SettlementID))
				AND ((hc.DiseaseReportTypeID = @idfsDiseaseReportType) OR (@idfsDiseaseReportType IS NULL))

			-- gender
				AND (h.idfsHumanGender IN (SELECT * FROM @Gender) OR NOT EXISTS(SELECT 1 FROM @Gender))

				-- Age
				AND (@StartAge IS NULL OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042003 AND ISNULL(hc.intPatientAge, -1) >= @StartAge) -- Years 
						
										OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042004 AND  CAST(ISNULL(hc.intPatientAge, -1) / 52 AS INT) >= @StartAge) -- Weeks

										OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042002 AND CAST(ISNULL(hc.intPatientAge, -1) / 12 AS INT) >= @StartAge) -- MONTHS

										OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042001 AND CAST(ISNULL(hc.intPatientAge, -1) / 365 AS INT) >= @StartAge) -- Days
						
					)
				AND (@FinishAge IS NULL OR @FinishAge=0 OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042003 AND ISNULL(hc.intPatientAge, -1) <= @FinishAge) -- Years 
						
										OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042004 AND  CAST(ISNULL(hc.intPatientAge, -1) / 52 AS INT) <= @FinishAge) -- Weeks

										OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042002 AND CAST(ISNULL(hc.intPatientAge, -1) / 12 AS INT) <= @FinishAge) -- MONTHS

										OR (ISNULL(hc.idfsHumanAgeType, -1) = 10042001 AND CAST(ISNULL(hc.intPatientAge, -1) / 365 AS INT) <= @FinishAge) -- Days
						
					)
				AND COALESCE(hc.idfsFinalCaseStatus, hc.idfsInitialCaseStatus, 0) IN (SELECT * FROM @Classification)
				AND COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) IN (SELECT * FROM @Diagnosis)
				AND hc.intRowStatus = 0

				--------------------------------------------------------------------------		
				SELECT 
					@sum = COUNT(*)
				FROM @RawReportTable

				SELECT 
					@fullsum = COUNT(*)
				FROM dbo.tlbHumanCase hc

				WHERE 	--dates		
					(@StartDate <= COALESCE(CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN hc.datOnSetDate ELSE NULL END,
											CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN hc.datNotiFicationDate ELSE NULL END,
											CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN  hc.datTentativeDiagnosisDate ELSE NULL END,
											CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN  hc.datFinalDiagnosisDate ELSE NULL END,
											CASE WHEN 5 IN (SELECT * FROM  @DateValues) THEN hc.datEnteredDate ELSE NULL END)

						AND  @FinishDate > COALESCE(CASE WHEN 1 IN (SELECT * FROM  @DateValues) THEN hc.datOnSetDate ELSE NULL END,
													CASE WHEN 2 IN (SELECT * FROM  @DateValues) THEN hc.datNotiFicationDate ELSE NULL END,
													CASE WHEN 3 IN (SELECT * FROM  @DateValues) THEN  hc.datTentativeDiagnosisDate ELSE NULL END,
													CASE WHEN 4 IN (SELECT * FROM  @DateValues) THEN  hc.datFinalDiagnosisDate ELSE NULL END,
													CASE WHEN 5 IN (SELECT * FROM  @DateValues) THEN hc.datEnteredDate ELSE NULL END)

					)
				AND COALESCE(hc.idfsFinalCaseStatus, hc.idfsInitialCaseStatus, 0) IN (SELECT * FROM @Classification)
				AND  COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) IN (SELECT idfsDiagnosis FROM @Diagnosis) 
				AND hc.intRowStatus = 0
				AND ((hc.DiseaseReportTypeID = @idfsDiseaseReportType) OR (@idfsDiseaseReportType IS NULL))


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
				ELSE IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Day') --'Oneday'	      
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
						COUNT(r.ident) AS Observed, 
						@sum AS intSum, 
						@fullsum AS fullsum, 
						nd AS Rowid,
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


