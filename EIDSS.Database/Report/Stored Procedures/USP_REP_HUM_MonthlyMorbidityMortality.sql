
-- This stored proc is to be used for the report:
--
--	Human Monthly Morbidity and Mortality
--
--  Mark Wilson updated for EIDSS7 standards
--  Srini Goli: renamed to maintain similarity object names.
--  Mark Wilson updated to sort diseases by intOrder 21July2020
--  Mark Wilson updated to update counts for labtested 12Jan2023
--  Stephen Long - added additional dates for 5455 - 30Jan2023

/*
--Example of a call of procedure:
EXEC report.USP_REP_HUM_MonthlyMorbidityMortality @LangID=N'en-US', @Year=2021,@Month=5,@IsDeceased=NULL --Morbidity
EXEC report.USP_REP_HUM_MonthlyMorbidityMortality @LangID=N'en', @Year=2017,@Month=2,@IsDeceased=1 --Mortality

*/
CREATE PROCEDURE [Report].[USP_REP_HUM_MonthlyMorbidityMortality]
(
    @LangID AS NVARCHAR(50),
    @Year AS INT,
    @Month AS INT = NULL,
    @IsDeceased AS BIT = NULL,
    @UseArchiveData AS BIT = 0 --if User selected Use Archive Data then 1
)
AS
DECLARE @FinalState AS BIGINT
IF (@IsDeceased = 1)
    SET @FinalState = 10035001; /*fstDeceased*/

DECLARE @StartDate AS DATETIME,
        @EndDate AS DATETIME;

IF @Month IS NULL
BEGIN
    SET @StartDate = CAST(CAST(@Year AS VARCHAR(4)) + '0101' AS DATETIME);
    SET @EndDate = DATEADD(ms, -2, DATEADD(YEAR, 1, @StartDate));
END
ELSE
BEGIN
    SET @StartDate = DATEADD(MONTH, @Month - 1, CAST(CAST(@Year AS VARCHAR(4)) + '0101' AS DATETIME));
    SET @EndDate = DATEADD(ms, -2, DATEADD(MONTH, 1, @StartDate));
END

SELECT tDiagnosisList.idfsDiagnosis AS DiagnosisID,
       tDiagnosisList.strIDC10 AS ICD10,
       tDiagnosisList.strDiseaseName AS Disease,
       Age0_1.intCount AS Age_1,
       Age1_4.intCount AS Age1_4,
       Age5_14.intCount AS Age5_14,
       Age15_19.intCount AS Age15_19,
       Age20_29.intCount AS Age20_29,
       Age30_54.intCount AS Age30_54,
       Age55_.intCount AS Age55_,
       fnTotal.intCount AS TotalCases,
       --tLabConfirmed.intCount AS TotalLabTested,
       tLabTested.intCount AS TotalLabTested,
       tTotalConfirmed.intCount AS TotalConfirmed
FROM
(
    SELECT tDiagnosis.idfsDiagnosis,
           tDiagnosis.strIDC10,
           rfDiagnosis.name AS strDiseaseName,
           rfDiagnosis.intOrder
    FROM dbo.trtDiagnosis AS tDiagnosis
        INNER JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019 /*'rftDiagnosis' */) AS rfDiagnosis
            ON rfDiagnosis.idfsReference = tDiagnosis.idfsDiagnosis
               AND rfDiagnosis.intHACode & 2 > 0
               AND idfsUsingType = 10020001 /*Human */
) AS tDiagnosisList
    -- Get age statistics
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 0, 1, @FinalState) AS Age0_1
        ON tDiagnosisList.idfsDiagnosis = Age0_1.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 1, 4, @FinalState) AS Age1_4
        ON tDiagnosisList.idfsDiagnosis = Age1_4.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 5, 14, @FinalState) AS Age5_14
        ON tDiagnosisList.idfsDiagnosis = Age5_14.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 15, 19, @FinalState) AS Age15_19
        ON tDiagnosisList.idfsDiagnosis = Age15_19.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 20, 29, @FinalState) AS Age20_29
        ON tDiagnosisList.idfsDiagnosis = Age20_29.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 30, 54, @FinalState) AS Age30_54
        ON tDiagnosisList.idfsDiagnosis = Age30_54.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 55, 2147483647, @FinalState) AS Age55_
        ON tDiagnosisList.idfsDiagnosis = Age55_.idfsDiagnosis
    LEFT JOIN report.FN_REP_HumanCaseForAge_Get(@StartDate, @EndDate, 0, 0, @FinalState) AS fnTotal
        ON tDiagnosisList.idfsDiagnosis = fnTotal.idfsDiagnosis
    LEFT JOIN
    (
		SELECT COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis) AS idfsDiagnosis,
               COUNT(tHumanCase.idfHumanCase) AS intCount
        FROM dbo.tlbHumanCase AS tHumanCase
            INNER JOIN dbo.tlbHuman h
                LEFT OUTER JOIN dbo.tlbGeoLocation gl
                    ON h.idfCurrentResidenceAddress = gl.idfGeoLocation
                       AND gl.intRowStatus = 0
                ON tHumanCase.idfHuman = h.idfHuman
                   AND h.intRowStatus = 0 -- Added by MCW
            LEFT JOIN dbo.tlbGeoLocation cgl
                ON tHumanCase.idfPointGeoLocation = cgl.idfGeoLocation
                   AND cgl.intRowStatus = 0 -- added by MCW to ensure non-foreign address
        -- MCW changed to BETWEEN instead of >= and <
        -- SHL added additional dates for bug 5455.
		WHERE COALESCE(tHumanCase.datOnsetDate, tHumanCase.datFinalDiagnosisDate, tHumanCase.datTentativeDiagnosisDate, tHumanCase.datNotificationDate, tHumanCase.datEnteredDate) BETWEEN @StartDate AND @EndDate -- Added tHumanCase.datOnsetDate, tHumanCase.datFinalDiagnosisDate,  to COALESCE
              AND tHumanCase.intRowStatus = 0
              AND ISNULL(tHumanCase.idfsFinalCaseStatus, tHumanCase.idfsInitialCaseStatus) = 350000000 /* Confirmed*/
              AND (
                      @FinalState IS NULL
                      OR tHumanCase.idfsFinalState = @FinalState
                  )
              AND (
                      ISNULL(cgl.idfsGeoLocationType, -1) <> 10036001 --Foreign Address
                      OR cgl.idfsCountry IS NULL
                      OR cgl.idfsCountry = 780000000
                  )
              AND (
                      @IsDeceased IS NULL
                      OR @IsDeceased = 0
                      OR (
                             @IsDeceased = 1
                             AND (
                                     tHumanCase.idfsFinalState = 10035001
                                     OR (tHumanCase.idfsOutcome = 10770000000 /*Died*/ * @IsDeceased)
                                 )
                         )
                  )
        GROUP BY COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis)
    ) AS tTotalConfirmed
        ON tDiagnosisList.idfsDiagnosis = tTotalConfirmed.idfsDiagnosis
    --LEFT JOIN (			
    --			SELECT
    --				COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis) AS idfsDiagnosis,
    --				COUNT(tHumanCase.idfHumanCase) AS intCount
    --			FROM dbo.tlbHumanCase AS tHumanCase
    --			WHERE COALESCE(tHumanCase.datTentativeDiagnosisDate, tHumanCase.datNotificationDate, tHumanCase.datEnteredDate) BETWEEN @StartDate AND @EndDate
    --			AND tHumanCase.intRowStatus = 0
    --			AND tHumanCase.blnLabDiagBasis = 1
    --			AND (@FinalState IS NULL OR tHumanCase.idfsFinalState = @FinalState)
    --			GROUP BY COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis)
    --		  ) AS tLabConfirmed ON tDiagnosisList.idfsDiagnosis = tLabConfirmed.idfsDiagnosis				
    LEFT JOIN
    (
        SELECT COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis) AS idfsDiagnosis,
               COUNT(tHumanCase.idfHumanCase) AS intCount
        FROM dbo.tlbHumanCase AS tHumanCase
            INNER JOIN dbo.tlbHuman h
                LEFT OUTER JOIN dbo.tlbGeoLocation gl
                    ON h.idfCurrentResidenceAddress = gl.idfGeoLocation
                       AND gl.intRowStatus = 0
                ON tHumanCase.idfHuman = h.idfHuman
                   AND h.intRowStatus = 0 -- Added by MCW
            LEFT JOIN dbo.tlbGeoLocation cgl
                ON tHumanCase.idfPointGeoLocation = cgl.idfGeoLocation
                   AND cgl.intRowStatus = 0 -- added by MCW to ensure non-foreign address

        WHERE (
                  DATEPART(
                              MONTH,
                              COALESCE(ISNULL(tHumanCase.datOnsetDate, tHumanCase.datFinalDiagnosisDate), ISNULL(
                                                                                                                    tHumanCase.datFinalDiagnosisDate,
                                                                                                                    tHumanCase.datTentativeDiagnosisDate
                                                                                                                ), ISNULL(
                                                                                                                             tHumanCase.datTentativeDiagnosisDate,
                                                                                                                             tHumanCase.datNotificationDate
                                                                                                                         ), ISNULL(
                                                                                                                                      tHumanCase.datNotificationDate,
                                                                                                                                      tHumanCase.datEnteredDate
                                                                                                                                  ))
                          ) = @Month
                  OR @Month IS NULL
              )
              AND DATEPART(
                              YEAR,
                              COALESCE(ISNULL(tHumanCase.datOnsetDate, tHumanCase.datFinalDiagnosisDate), ISNULL(
                                                                                                                    tHumanCase.datFinalDiagnosisDate,
                                                                                                                    tHumanCase.datTentativeDiagnosisDate
                                                                                                                ), ISNULL(
                                                                                                                             tHumanCase.datTentativeDiagnosisDate,
                                                                                                                             tHumanCase.datNotificationDate
                                                                                                                         ), ISNULL(
                                                                                                                                      tHumanCase.datNotificationDate,
                                                                                                                                      tHumanCase.datEnteredDate
                                                                                                                                  ))
                          ) = @Year
              AND tHumanCase.intRowStatus = 0
              AND (
                      ISNULL(cgl.idfsGeoLocationType, -1) <> 10036001 --Foreign Address
                      OR cgl.idfsCountry IS NULL
                      OR cgl.idfsCountry = 780000000
                  )
              AND tHumanCase.idfsYNTestsConducted = 10100001 -- Added by MCW to check that tests were conducted.
              AND (
                      @IsDeceased IS NULL
                      OR @IsDeceased = 0
                      OR ( --TODO: comment if necessary - start
                             @IsDeceased = 1
                             AND
                             --TODO: comment if necessary - end
                             (
                                 tHumanCase.idfsFinalState = 10035001 /*Dead*/ --TODO: uncomment if necessary--* @IsDeceased + 10035002 /*Alive*/ * (1 - @IsDeceased)
                                 OR ( -- TODO: uncomment if not necessary - start
                                 --(	tHumanCase.idfsFinalState is null 
                                 --	or tHumanCase.idfsFinalState <> 10035001 /*Dead*/ --TODO: uncomment if necessary--* @IsDeceased + 10035002 /*Alive*/ * (1 - @IsDeceased)
                                 --)
                                 -- and 
                                 -- TODO: uncomment if not necessary - end
                                 tHumanCase.idfsOutcome = 10770000000 /*Died*/ * @IsDeceased --TODO: uncomment if necessary-- + 10760000000 /*Recovered*/ * (1 - @IsDeceased)
                                    )
                             )
                         )
                  )
              AND COALESCE(tHumanCase.idfsFinalCaseStatus, tHumanCase.idfsInitialCaseStatus, 370000000) IN ( 350000000, /*Confirmed*/
                                                                                                             360000000, /*Probable*/
                                                                                                             380000000  /*Suspect*/
                                                                                                           )
        GROUP BY COALESCE(tHumanCase.idfsFinalDiagnosis, tHumanCase.idfsTentativeDiagnosis)
    ) AS tLabTested
        ON tDiagnosisList.idfsDiagnosis = tLabTested.idfsDiagnosis
ORDER BY tDiagnosisList.strDiseaseName
OPTION (RECOMPILE);

GO