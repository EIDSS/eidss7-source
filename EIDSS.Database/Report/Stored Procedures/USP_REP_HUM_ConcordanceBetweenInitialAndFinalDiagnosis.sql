



/*
Example of a call of procedure:

EXEC report.USP_REP_HUM_ConcordanceBetweenInitialAndFinalDiagnosis
N'EN', 
2010, 
1, 
null, 
null, 
null,
'57972080000000,56161350000000,57972090000000',
'57972080000000,56161350000000,57972090000000'

EXEC report.USP_REP_HUM_ConcordanceBetweenInitialAndFinalDiagnosis
N'ka', 
2012, 
null, 
null, 
null, 
null, 
null, 
null, 
0


*/

CREATE PROCEDURE [Report].[USP_REP_HUM_ConcordanceBetweenInitialAndFinalDiagnosis]
(
	@LangID AS VARCHAR(36),
	@Year AS INT,
	@Month	AS INT = NULL,
	@RegionID AS NVARCHAR(MAX) = NULL,
	@RayonID AS NVARCHAR(MAX) = NULL,
	@SettlementID AS NVARCHAR(MAX) = NULL,
	@InitialDiagnosis AS NVARCHAR(MAX)= NULL,
	@FinalDiagnosis NVARCHAR(MAX) = NULL,
	@Concordance INT = 1,
	@UseArchiveData	AS BIT = 0 --if User selected Use Archive Data form UI then 1
)
AS

DECLARE @returnCode INT = 0 
DECLARE	@returnMsg NVARCHAR(MAX) = 'SUCCESS' 

BEGIN

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @InitialDiagnosisTable	TABLE
			(
					idfsDiagnosis BIGINT			
			)	
	
			INSERT INTO @InitialDiagnosisTable 
 
			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@InitialDiagnosis,1,',') 

			DECLARE @CntInitialDiagnosis INT = 0
			SELECT @CntInitialDiagnosis = COUNT(*) FROM @InitialDiagnosisTable
	
			DECLARE @FinalDiagnosisTable	TABLE
			(
					idfsDiagnosis BIGINT			
			)	
	
			--DECLARE @FinalDiagnosis	INT
	
			INSERT INTO @FinalDiagnosisTable 

			SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@FinalDiagnosis,1,',') 
	
			DECLARE @CntFinalDiagnosis INT = 0
			SELECT @CntFinalDiagnosis = COUNT(*) FROM @FinalDiagnosisTable

			DECLARE @idfsRegion BIGINT = (SELECT CAST(@RegionID AS BIGINT))
			DECLARE @idfsRayon BIGINT = (SELECT CAST(@RayonID AS BIGINT))
			DECLARE @idfsSettlement BIGINT = (SELECT CAST(@SettlementID AS BIGINT))

			DECLARE @TotalCount INT

			DECLARE @E7HumanCaseChange TABLE
			(
				idfsInitialDiagnosis BIGINT,
				strInitialDiagnosisName NVARCHAR(300),
				idfsFinalDiagnosis BIGINT,
				strFinalDiagnosisName NVARCHAR(300)
			)

			DECLARE @PreliminaryResult AS TABLE
			(
				strDiagnosisToDiagnosisKey	NVARCHAR(200),
				idfsInitialDiagnosis		BIGINT NOT NULL,
				strInitialDiagnosisName		NVARCHAR(200),
				idfsFinalDiagnosis			BIGINT NOT NULL,
				strFinalDiagnosisName		NVARCHAR(200)
			)

			DECLARE @Result AS TABLE
			(
				strDiagnosisToDiagnosisKey	NVARCHAR(200) NOT NULL PRIMARY KEY,
				idfsInitialDiagnosis		BIGINT NOT NULL,
				strInitialDiagnosisName		NVARCHAR(200),
				idfsFinalDiagnosis			BIGINT NOT NULL,
				strFinalDiagnosisName		NVARCHAR(200),
				intCount					INT,
				intTotalCount				INT
			)

			DROP TABLE IF EXISTS #E6Case
			CREATE TABLE #E6Case (idfHumanCase BIGINT)

			INSERT INTO #E6Case
			SELECT idfHumanCase FROM dbo.tlbHumanCase
			WHERE YEAR(COALESCE(datOnSetDate, datFinalDiagnosisDate, datTentativeDiagnosisDate, datEnteredDate)) = @Year
			AND (MONTH(COALESCE(datOnSetDate, datFinalDiagnosisDate, datTentativeDiagnosisDate, datEnteredDate)) = @Month OR @Month IS NULL)
			AND LegacyCaseID IN
			(
			SELECT LegacyCaseID
			FROM dbo.tlbHumanCase 
			WHERE YEAR(COALESCE(datOnSetDate, datFinalDiagnosisDate, datTentativeDiagnosisDate, datEnteredDate)) = @Year
			AND (MONTH(COALESCE(datOnSetDate, datFinalDiagnosisDate, datTentativeDiagnosisDate, datEnteredDate)) = @Month OR @Month IS NULL)

			GROUP BY LegacyCaseID HAVING COUNT(*) > 1
			)

			DROP TABLE IF EXISTS #E6InitialCase
			CREATE TABLE #E6InitialCase 
			(
				idfHumanCase BIGINT,
				idfsFinalDiagnosis BIGINT,
				strFinalDiagnosis NVARCHAR(300),
				idfsRegion BIGINT,
				idfsRayon BIGINT,
				idfsSettlement BIGINT,
				idfsCaseStatus BIGINT,
				DateOfRecord DATETIME,
				datOnSetDate DATETIME,
				datInvestigationDate DATETIME,
				datTentativeDiagnosisDate DATETIME,
				datFinalDiagnosisDate DATETIME,
				LegacyCaseID NVARCHAR(50),
				strCaseID NVARCHAR(50)

			)

			INSERT INTO #E6InitialCase
			SELECT 

				HC.idfHumanCase,
				HC.idfsFinalDiagnosis,
				FD.[name] AS strFinalDiagnosis,
				tgl.idfsRegion,
				tgl.idfsRayon,
				tgl.idfsSettlement,
				HC.idfsFinalCaseStatus,
				COALESCE(HC.datOnSetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datEnteredDate) AS DateOfRecord,
				HC.datOnSetDate,
				HC.datInvestigationStartDate,
				HC.datTentativeDiagnosisDate,
				HC.datFinalDiagnosisDate,
				HC.LegacyCaseID,
				HC.strCaseID

			FROM dbo.tlbHumanCase HC
			LEFT JOIN dbo.tlbHuman H ON H.idfHuman = HC.idfHuman AND H.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocation tgl ON tgl.idfGeoLocation = H.idfCurrentResidenceAddress AND tgl.intRowStatus = 0 
			LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) FD ON FD.idfsReference = HC.idfsFinalDiagnosis

			WHERE HC.idfHumanCase IN (SELECT * FROM #E6Case)
			AND YEAR(COALESCE(HC.datOnSetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datEnteredDate)) = @Year
			AND (MONTH(COALESCE(HC.datOnSetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datEnteredDate)) = @Month OR @Month IS NULL)
			AND (tgl.idfsSettlement = @idfsSettlement OR @idfsSettlement IS NULL)
			AND (tgl.idfsRayon = @idfsRayon OR @idfsRayon IS NULL)
			AND (tgl.idfsRegion = @idfsRegion OR @idfsRegion IS NULL)
			AND (HC.idfsFinalCaseStatus = 370000000 AND (HC.idfsFinalDiagnosis IN (SELECT idfsDiagnosis FROM @InitialDiagnosisTable) OR @InitialDiagnosis IS NULL))

			DROP TABLE IF EXISTS #E6FinalCase
			CREATE TABLE #E6FinalCase 
			(
				idfHumanCase BIGINT,
				idfsFinalDiagnosis BIGINT,
				strFinalDiagnosis NVARCHAR(300),
				idfsRegion BIGINT,
				idfsRayon BIGINT,
				idfsSettlement BIGINT,
				idfsCaseStatus BIGINT,
				DateOfRecord DATETIME,
				datOnSetDate DATETIME,
				datInvestigationDate DATETIME,
				datTentativeDiagnosisDate DATETIME,
				datFinalDiagnosisDate DATETIME,
				LegacyCaseID NVARCHAR(50),
				strCaseID NVARCHAR(50)

			)

			INSERT INTO #E6FinalCase
			SELECT 

				HC.idfHumanCase,
				HC.idfsFinalDiagnosis,
				FD.[name] AS strFinalDiagnosis,
				tgl.idfsRegion,
				tgl.idfsRayon,
				tgl.idfsSettlement,
				HC.idfsFinalCaseStatus,
				COALESCE(HC.datOnSetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datEnteredDate) AS DateOfRecord,
				HC.datOnSetDate,
				HC.datInvestigationStartDate,
				HC.datTentativeDiagnosisDate,
				HC.datFinalDiagnosisDate,
				HC.LegacyCaseID,
				HC.strCaseID

			FROM dbo.tlbHumanCase HC
			LEFT JOIN dbo.tlbHuman H ON H.idfHuman = HC.idfHuman AND H.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocation tgl ON tgl.idfGeoLocation = H.idfCurrentResidenceAddress AND tgl.intRowStatus = 0 AND (@SettlementID IS NULL OR tgl.idfsSettlement = @SettlementID)
			LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) FD ON FD.idfsReference = HC.idfsFinalDiagnosis

			WHERE HC.idfHumanCase IN (SELECT * FROM #E6Case)
			AND YEAR(COALESCE(HC.datOnSetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datEnteredDate)) = @Year
			AND (MONTH(COALESCE(HC.datOnSetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datEnteredDate)) = @Month OR @Month IS NULL)
			AND (tgl.idfsSettlement = @idfsSettlement OR @idfsSettlement IS NULL)
			AND (tgl.idfsRayon = @idfsRayon OR @idfsRayon IS NULL)
			AND (tgl.idfsRegion = @idfsRegion OR @idfsRegion IS NULL)
			AND (HC.idfsFinalCaseStatus <> 370000000 AND (HC.idfsFinalDiagnosis IN (SELECT idfsDiagnosis FROM @FinalDiagnosisTable) OR @FinalDiagnosis IS NULL))

			INSERT INTO @E7HumanCaseChange

			SELECT 
				OriginalHDR.idfsFinalDiagnosis AS idfsInitialDiagnosis,
				OriginalDiagnosis.[name] AS strInitialDiagnosisName,
				NewHDR.idfsFinalDiagnosis AS idfsFinalDiagnosis,
				NewDiagnosis.[name] AS strFinalDiagnosisName

			FROM dbo.HumanDiseaseReportRelationship HDRR
			LEFT JOIN dbo.tlbHumanCase OriginalHDR ON OriginalHDR.idfHumanCase = HDRR.RelateToHumanDiseaseReportID AND OriginalHDR.intRowStatus = 0
			LEFT JOIN dbo.tlbHumanCase NewHDR ON NewHDR.idfHumanCase = HDRR.HumanDiseaseReportID AND NewHDR.intRowStatus = 0
			LEFT JOIN dbo.tlbHuman H ON H.idfHuman = OriginalHDR.idfHuman AND H.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocation tgl ON tgl.idfGeoLocation = H.idfCurrentResidenceAddress AND tgl.intRowStatus = 0 
			LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) OriginalDiagnosis ON OriginalDiagnosis.idfsReference = OriginalHDR.idfsFinalDiagnosis
			LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) NewDiagnosis ON NewDiagnosis.idfsReference = NewHDR.idfsFinalDiagnosis

			WHERE YEAR(COALESCE(NewHDR.datOnSetDate, NewHDR.datFinalDiagnosisDate, NewHDR.datTentativeDiagnosisDate, NewHDR.datEnteredDate)) = @Year
			AND (MONTH(COALESCE(NewHDR.datOnSetDate, NewHDR.datFinalDiagnosisDate, NewHDR.datTentativeDiagnosisDate, NewHDR.datEnteredDate)) =  @Month OR @Month IS NULL) 
			AND (OriginalHDR.idfsFinalDiagnosis IN (SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@InitialDiagnosis,1,',')) OR @InitialDiagnosis IS NULL)
			AND (NewHDR.idfsFinalDiagnosis IN (SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@FinalDiagnosis,1,',')) OR @FinalDiagnosis IS NULL)
			AND (tgl.idfsSettlement = @idfsSettlement OR @idfsSettlement IS NULL)
			AND (tgl.idfsRayon = @idfsRayon OR @idfsRayon IS NULL)
			AND (tgl.idfsRegion = @idfsRegion OR @idfsRegion IS NULL)

			INSERT INTO @PreliminaryResult

			SELECT 
				CAST(I.idfsFinalDiagnosis AS NVARCHAR(50)) + '_' + CAST(F.idfsFinalDiagnosis AS NVARCHAR(50)),
				I.idfsFinalDiagnosis AS idfsInitialDiagnosis,
				I.strFinalDiagnosis AS strInitialDiagnosisName,
				F.idfsFinalDiagnosis AS idfsFinalDiagnosis,
				F.strFinalDiagnosis AS strFinalDiagnosisName

			FROM #E6InitialCase I
			LEFT JOIN #E6FinalCase F ON F.LegacyCaseID = I.LegacyCaseID

			WHERE F.idfsFinalDiagnosis  IS NOT NULL 
			AND I.idfsFinalDiagnosis IS NOT NULL --Added by Srini to eliminate NULL Insert.

			INSERT INTO @PreliminaryResult
			SELECT 
				CAST(idfsInitialDiagnosis AS NVARCHAR(50)) + '_' + CAST(idfsFinalDiagnosis AS NVARCHAR(50)),
				* 
			FROM @E7HumanCaseChange
			WHERE idfsFinalDiagnosis  IS NOT NULL --Added by Srini to eliminate NULL Insert.
			AND idfsInitialDiagnosis IS NOT NULL --Added by Srini to eliminate NULL Insert.

			SET @TotalCount = (SELECT COUNT(*) FROM @PreliminaryResult)
			INSERT INTO @Result
			SELECT 
				strDiagnosisToDiagnosisKey,
				idfsInitialDiagnosis,
				strInitialDiagnosisName,
				idfsFinalDiagnosis,
				strFinalDiagnosisName,
				COUNT(*),
				@TotalCount
	
			FROM @PreliminaryResult
			GROUP BY
				strDiagnosisToDiagnosisKey,
				idfsInitialDiagnosis,
				strInitialDiagnosisName,
				idfsFinalDiagnosis,
				strFinalDiagnosisName

			IF (SELECT COUNT(*) FROM @Result) = 0
				BEGIN
					SELECT
						NEWID() AS strDiagnosisToDiagnosisKey
						, 0		AS idfsInitialDiagnosis
						, ''	AS strInitialDiagnosisName
						, 0		AS idfsFinalDiagnosis
						,''		AS strFinalDiagnosisName
						,null	AS intCount
						,100	AS intTotalCount
						,null	AS Concordance
						,0		AS RowNumber
				END
			ELSE
				BEGIN
					SELECT 

						*,
						CAST(intCount AS DECIMAL(12,2)) * 100/CAST(intTotalCount AS DECIMAL(12,2))  AS Concordance,
						ROW_NUMBER() OVER (ORDER BY strInitialDiagnosisName, strFinalDiagnosisName) AS RowNumber
			
					FROM @Result

					WHERE CAST(intCount AS DECIMAL(12,2)) * 100/CAST(intTotalCount AS DECIMAL(12,2)) >= @Concordance
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
			'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
			+ ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			+ ' ErrorState: ' + convert(varchar,ERROR_STATE())
			+ ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			+ ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			+ ' ErrorMessage: '+ ERROR_MESSAGE()

			SELECT @returnCode, @returnMsg

	END CATCH

END


