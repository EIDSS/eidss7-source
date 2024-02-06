

--- This stored proc is to be used the report:
--
--	Generate dataset for the Outbreak EpiCurve chart
--
--  Mark Wilson created for Outbreak Module
--

/*
--Example of a call of procedure:


DECLARE	@return_value INT

EXEC	@return_value = [report].[USP_REP_OutbreakEPI_Curve]
		@LangID = N'en',
		@SD = N'01-01-2018',
		@ED = N'12-31-2020',
		@Outbreak = N'23',
		@TimeInterval = '10042004'

SELECT	'Return Value' = @return_value

GO

*/

CREATE PROCEDURE [Report].[USP_REP_OutbreakEPI_Curve]
(
	@LangID		AS NVARCHAR(10) = 'en', 
	@SD			AS DATETIME,
	@ED			AS DATETIME,	
	@Outbreak AS NVARCHAR(100),
	
	-- Analysis Parms
	@TimeInterval AS NVARCHAR(100) -- TimeUnit: 10042001 = Days, 10042002 = Weeks, 10042004 = Months

)
AS	

DECLARE @returnCode INT = 0 
DECLARE	@returnMsg NVARCHAR(MAX) = 'SUCCESS' 

BEGIN

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @Interval BIGINT = (SELECT CAST(@TimeInterval AS BIGINT))


			DECLARE @OutbreakCaseReport TABLE
			(
				idfCase BIGINT,
				HumanVet VARCHAR(3),
				datOnsetDate DATETIME

			)

			DECLARE @ReportTable TABLE
			(
				StartDate DATETIME,
				EndDate DATETIME,
				EpiYear INT,
				EpiMonth INT,
				OutbreakCount BIGINT
			)

			DECLARE @idfOutbreak BIGINT = CAST(@Outbreak AS BIGINT)

			INSERT INTO @OutbreakCaseReport
			(
				idfCase,
				HumanVet
			)
			
			SELECT 
				CASE WHEN idfVetCase IS NULL THEN idfHumanCase ELSE idfVetCase END,
				CASE WHEN idfVetCase IS NULL THEN 'H' ELSE 'V' END
			
			FROM dbo.OutbreakCaseReport 
			WHERE idfOutbreak = @idfOutbreak

			-- Update Outbreak case report for Human cases
			UPDATE O

			SET O.datOnsetDate = HC.datOnsetDate

			FROM @OutbreakCaseReport O
			JOIN dbo.tlbHumanCase HC ON HC.idfHumanCase = O.idfCase
			WHERE O.HumanVet = 'H'

			-- Update Outbreak case report for Vet cases
			UPDATE O

			SET O.datOnsetDate = VC.datEnteredDate

			FROM @OutbreakCaseReport O
			JOIN dbo.tlbVetCase VC ON VC.idfVetCase = O.idfCase
			WHERE O.HumanVet = 'V'

			DECLARE 
			  @StartDate DATETIME = report.FN_GBL_MinMaxTime_GET(CAST(@SD AS DATETIME), 0),
			  @FinishDate DATETIME = report.FN_GBL_MinMaxTime_GET(CAST(@ED AS DATETIME), 1)

			DECLARE @idfsLanguage BIGINT
			SET @idfsLanguage = report.FN_GBL_LanguageCode_GET (@LangID)

			IF @Interval = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000042 AND strDefault = 'Month') --'MONTH'
			BEGIN
				IF @StartDate > DATEADD(MONTH, DATEDIFF(MONTH, 0, @StartDate), 0)
					SELECT @StartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @StartDate) + 1, 0)

				IF @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate)+1, 0)
					SELECT @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate), 0)

				ELSE
					SELECT @FinishDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @FinishDate)-1, 0)
			END

			ELSE IF @Interval = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000042 AND strDefault = 'Weeks') --'Week'
			BEGIN
				SELECT @StartDate = CASE DATEPART(WEEKDAY, @StartDate) 
									WHEN 1 THEN DATEADD(DAY, 1-DATEPART(WEEKDAY, @StartDate), @StartDate) 
									ELSE DATEADD(DAY, 8-DATEPART(WEEKDAY, @StartDate), @StartDate) END

				SELECT @FinishDate = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @FinishDate), @FinishDate)
			END
	
			IF (@StartDate >= @FinishDate OR @StartDate > '20990101' OR @FinishDate > '20990101')
				SELECT 
					0 AS StartDate,
					0 AS EndDate, 
					0 AS EpiYear,
					0 AS EpiMonth,
					0 AS OutbreakCount

			ELSE

			BEGIN

				IF @Interval = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000042 AND strDefault = 'Month') --'MONTH'
				BEGIN
					;WITH nm AS 
					(
						  SELECT 
							CONVERT(VARCHAR(10), @SD, 120) StartDate, 
							CONVERT(VARCHAR(10), DATEADD(DAY, -1, DATEADD(MONTH, 1, @SD)), 120) EndDate
   
						  UNION ALL
  
						  SELECT
							CONVERT(VARCHAR(10), DATEADD(MONTH, 1, StartDate), 120),
							CONVERT(VARCHAR(10), DATEADD(DAY, -1, DATEADD(MONTH, 2, StartDate)), 120)
						  FROM nm
						  WHERE DATEADD(MONTH, 1, StartDate)<=  @ED
					)

					INSERT INTO @ReportTable

					SELECT 
						StartDate,
						EndDate,
						YEAR(StartDate) AS EpiYear,
						MONTH(StartDate) AS EpiMonth,
						0
							
					FROM nm 

				END

				ELSE IF @Interval = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000042 AND strDefault = 'Weeks') --'Week'
				BEGIN
	
					;WITH nw AS 
					(
						  SELECT 
							CONVERT(VARCHAR(10), @SD,120) StartDate, 
							CONVERT(VARCHAR(10), DATEADD(WEEK, DATEDIFF(WEEK, 1, @SD), 7), 120) EndDate

						  UNION ALL
  
						  SELECT
							CONVERT(VARCHAR(10), DATEADD(WEEK, 1, StartDate), 120),
							CONVERT(VARCHAR(10), DATEADD(WEEK, 1, EndDate), 120)
						  FROM nw
						  WHERE DATEADD(WEEK, 1, StartDate) <=  @ED

					)

					INSERT INTO @ReportTable

					SELECT 
						StartDate,
						EndDate,
						YEAR(StartDate) AS EpiYear,
						MONTH(StartDate) AS EpiMonth,
						0
							
					FROM nw 
					OPTION (maxrecursion 0)
				END

				ELSE IF @Interval = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE idfsReferenceType = 19000042 AND strDefault = 'Days') --'Day'	      
				BEGIN

					;WITH nd AS 
					(
  						SELECT TOP (DATEDIFF(DAY, @StartDate, @FinishDate) + 1) nd = ROW_NUMBER() OVER (ORDER BY [object_id])
  						FROM sys.all_objects
					),
					cte AS
					(
						SELECT 
							CONVERT(NVARCHAR(20), DATEADD(DAY, nd-1, @StartDate), 120) AS EpiDate, 
							DATEADD(DAY, nd-1, @StartDate) AS StartDate,
							DATEADD(ms, -2, DATEADD(DAY, nd, @StartDate)) AS EndDate

						FROM nd

					)

					INSERT INTO @ReportTable

					SELECT 
						StartDate,
						EndDate,
						YEAR(EpiDate) AS EpiYear,
						MONTH(EpiDate) AS EpiMonth,
						0
							
					FROM cte 

				END

			END
		
			UPDATE @ReportTable 

			SET OutbreakCount = (SELECT COUNT(*) 
								 FROM @OutbreakCaseReport 
								 
								 WHERE (datOnsetDate BETWEEN StartDate AND EndDate)
								 AND datOnsetDate IS NOT NULL
								)
			
			SELECT * FROM @ReportTable

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

