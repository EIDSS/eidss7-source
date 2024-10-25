
--- This stored proc is to be used the report:
--
--	ILI Aberration Analysis
--
--  Mark Wilson updated for EIDSS7 standards and added calculations
-- for average, standard deviation, and CUSUM
--

/*

50815390000000	 � 0-4
50815400000000	 � 5-14
50815410000000	 �15-29
50815420000000	 �30-64
50815430000000	 >= 65
50815440000000	 Total ILI
*/


/*
--Example of a call of procedure:

DECLARE	@return_value int

EXEC	@return_value = [report].[USP_REP_HUM_ILI_AberrationAnalysis]

		@LangID	= N'en', 
		@SD = '2015-01-01',
		@ED = '2018-12-31',
		@GroupAge = N'50815440000000',
		@idfsRegion = NULL,
		@idfsRayon = NULL,
		@Hospital = N'0',
		-- Analysis Parms
		@Threshold = 2.5,
		@MinTimeInterval = '10091004', -- TimeUnit
		@Baseline = 4,
		@Lag = 1

GO

exec report.USP_REP_HUM_ILI_AberrationAnalysis 
	@LangID=N'en',
	@SD='2015-01-01',
	@ED='2018-12-31',
	@GroupAge=N'50815440000000',
	@idfsRegion=NULL,
	@idfsRayon=NULL,
	@Hospital=N'0',
	@Threshold=N'2.5',
	@MinTimeInterval='10091004',
	@Baseline=4,
	@Lag=1

*/

CREATE PROCEDURE [Report].[USP_REP_HUM_ILI_AberrationAnalysis]
(
	@LangID		AS NVARCHAR(10), 
	@SD			AS NVARCHAR(20),
	@ED			AS NVARCHAR(20),
	@GroupAge	AS BIGINT,
	@idfsRegion	AS NVARCHAR(100) = NULL,
	@idfsRayon	AS NVARCHAR(100) = NULL,
	@Hospital	AS NVARCHAR(100) = NULL,

	-- Analysis Parms
	@Threshold AS NUMERIC(10,2),
	@MinTimeInterval AS NVARCHAR(100), -- TimeUnit
	@Baseline AS BIGINT,
	@Lag AS INT

)
AS	

DECLARE @returnCode INT = 0 
DECLARE	@returnMsg NVARCHAR(MAX) = 'SUCCESS' 
DECLARE @Start INT = @Lag + @Baseline -- Start Period
DECLARE @End INT = @Lag + 1 -- End Period

BEGIN

/*

50815390000000	 � 0-4
50815400000000	 � 5-14
50815410000000	 �15-29
50815420000000	 �30-64
50815430000000	 >= 65
50815440000000	 Total ILI
*/

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @RegionID BIGINT = CAST(@idfsRegion AS BIGINT)
			DECLARE @RayonID BIGINT = CAST(@idfsRayon AS BIGINT)
			DECLARE @HospitalID BIGINT = CAST(@Hospital AS BIGINT)

			DECLARE @RawReportTable TABLE
			(
				 [ident] BIGINT,
				 [date]	DATETIME,
				 ILI_Count INT
			)

			DECLARE @ReportTable TABLE
			(
				CaseDate DATETIME,
				Observed INT,
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

			DECLARE @StartDate AS DATETIME,
					@FinishDate AS DATETIME

			SET @StartDate=report.FN_GBL_MinMaxTime_GET(CAST(@SD AS DATETIME),0)
			SET @FinishDate=report.FN_GBL_MinMaxTime_GET(CAST(@ED AS DATETIME),1)


			DECLARE @idfsLanguage BIGINT
			SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET (@LangID)

			SET @FinishDate=DATEADD(day, 1, @FinishDate)

			SELECT @StartDate = CASE DATEPART(WEEKDAY, @StartDate) WHEN 1 THEN DATEADD(DAY, 1-DATEPART(WEEKDAY, @StartDate), @StartDate) 
																   ELSE DATEADD(DAY, 8-DATEPART(WEEKDAY, @StartDate), @StartDate) END
			SELECT @FinishDate = DATEADD(DAY, 1-DATEPART(WEEKDAY, @FinishDate), @FinishDate)
	
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
			------------------------------------------------------------------------------------
				INSERT INTO @RawReportTable
				SELECT 
					ad.idfAggregateDetail,
					ah.datStartDate,
					CASE
						WHEN CAST(@GroupAge AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000163 AND strDefault LIKE '%0-4') THEN ad.intAge0_4
						WHEN CAST(@GroupAge AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000163 AND strDefault LIKE '%5-14') THEN ad.intAge5_14
						WHEN CAST(@GroupAge AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000163 AND strDefault LIKE '%15-29') THEN ad.intAge15_29
						WHEN CAST(@GroupAge AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000163 AND strDefault LIKE '%30-64') THEN ad.intAge30_64
						WHEN CAST(@GroupAge AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000163 AND strDefault LIKE '%>= 65') THEN ad.intAge65
						WHEN CAST(@GroupAge AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000163 AND strDefault LIKE '%Total ILI') THEN ad.inTotalILI
					END
				FROM tlbBasicSyndromicSurveillanceAggregateHeader ah
    			INNER JOIN tlbBasicSyndromicSurveillanceAggregateDetail ad ON ah.idfAggregateHeader = ad.idfAggregateHeader AND ad.intRowStatus = 0
      			INNER JOIN tlbOffice o ON o.idfOffice = ad.idfHospital	and o.intRowStatus = 0
      			LEFT OUTER JOIN tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared AND gl.intRowStatus = 0

				WHERE @StartDate <= ah.datStartDate AND @FinishDate > ah.datFinishDate --dates
				AND (@HospitalID = 0 OR  ad.idfHospital = @HospitalID) --hospital
				AND (@RegionID IS NULL OR (@HospitalID = 0 AND gl.idfsRegion is NOT NULL AND gl.idfsRegion = @RegionID))	-- region-rayon
				AND (@RayonID IS NULL OR (@HospitalID = 0 AND gl.idfsRayon is not null AND gl.idfsRayon = @RayonID)) 
				AND ah.intRowStatus = 0

				
				IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Month') --'MONTH'
				BEGIN
				
					;WITH nm AS 
					(
  						SELECT TOP (DATEDIFF(MONTH, @StartDate, @FinishDate)) 
    						nm = ROW_NUMBER() OVER (ORDER BY object_id)
  						FROM sys.all_objects
					),

					cte_month AS
					(
					SELECT 
						CONVERT(NVARCHAR(20), DATEADD(MONTH, nm-1, @StartDate), 120) AS CaseDate, 
						ISNULL(SUM(r.ILI_Count),0)  AS Observed, 
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
						RowID,
						StartPeriod,
						EndPeriod
					)
					SELECT * FROM cte_month 

				END

				
				IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Week') --'WEEK'
				BEGIN
				
					;WITH nw AS 
					(
  						SELECT TOP (DATEDIFF(WEEK, @StartDate, @FinishDate)) 
    						nw = ROW_NUMBER() OVER (ORDER BY object_id)
  						FROM sys.all_objects
					),

					cte_week AS
					(
					SELECT 
						CONVERT(NVARCHAR(20), DATEADD(WEEK, nw-1, @StartDate), 120) AS CaseDate, 
						ISNULL(SUM(r.ILI_Count),0) AS Observed, 
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
						RowID,
						StartPeriod,
						EndPeriod
					)
					SELECT * FROM cte_week 

				END

				IF CAST(@MinTimeInterval AS BIGINT) = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000091 AND strDefault = 'Day') -- Day
				BEGIN
				
					;WITH nd AS 
					(
  						SELECT TOP (DATEDIFF(DAY, @StartDate, @FinishDate)) 
    						nd = ROW_NUMBER() OVER (ORDER BY object_id)
  						FROM sys.all_objects
					),

					cte_day AS
					(
					SELECT 
						CONVERT(NVARCHAR(20), DATEADD(DAY, nd-1, @StartDate), 120) AS CaseDate, 
						ISNULL(SUM(r.ILI_Count),0) AS Observed, 
						nd AS RowID,
						nd-1-(@Baseline + @Lag) AS StartPeriod,
						nd-1-@Lag AS EndPeriod

					FROM nd
					LEFT OUTER JOIN @RawReportTable r ON DATEADD(DAY, nd-1, @StartDate) <= [date] AND DATEADD(DAY, nd, @StartDate) > [date]
					GROUP BY 
						DATEADD(DAY, nd-1, @StartDate),
						nd
					)

					INSERT INTO @ReportTable
					(
						CaseDate,
						Observed,
						RowID,
						StartPeriod,
						EndPeriod
					)

					SELECT * FROM cte_day 

				END
				
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
				  
					AS CUSUM,
					@Threshold AS Threshold
				
				FROM @FinalReport R
				LEFT JOIN @FinalReport Previous ON Previous.RowID = R.RowID - 1
				LEFT JOIN @FinalReport PPrev ON PPrev.RowID = R.RowID - 2

			END

		IF @@TRANCOUNT > 0 AND @returnCode = 0
			COMMIT

		SELECT @returnCode, @returnMsg
		
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

