--********************************************************************************************************
-- Name 				: USP_REP_HUM_DataQualityIndicators
-- Description			: This procedure returns resultset for Main indicators of AFP surveillance report
--          
-- Author               : Mandar Kulkarni
--
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- -----------------------------------------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
--Example of a call of procedure:

--SELECT td.idfsDiagnosis, tbr.strDefault, tsnt.strTextString, tsnt.idfsLanguage, td.idfsUsingType
--  FROM trtDiagnosis td
--INNER JOIN trtBaseReference tbr
--ON tbr.idfsBaseReference = td.idfsDiagnosis
--INNER JOIN trtStringNameTranslation tsnt
--ON tsnt.idfsBaseReference = tbr.idfsBaseReference

--WHERE
--tbr.strDefault like '%Acute intestinal infection %'
--AND tbr.intRowStatus = 0

/*
 EXEC report.USP_REP_HUM_DataQualityIndicators 
 'en', 
'7718070000000,7718060000000',
 2016,
 1,
 12
 */
--********************************************************************************************************
CREATE PROCEDURE [Report].[USP_REP_HUM_DataQualityIndicators]
(
    @LangID AS NVARCHAR(50),
    @Diagnosis AS NVARCHAR(MAX),
    @Year AS INT,
    @StartMonth AS INT = NULL,
    @EndMonth AS INT = NULL,
    @RegionID AS BIGINT = NULL,
    @RayonID AS BIGINT = NULL,
    @SiteID AS BIGINT = NULL
)
AS
SET NOCOUNT ON

DECLARE @CountryID BIGINT,
        @iDiagnosis INT,
        @SDDate DATETIME,
        @EDDate DATETIME,
        @idfsLanguage BIGINT,
        @idfsCustomReportType BIGINT,
        @Ind_1_Notification NUMERIC(4, 2),
        @Ind_2_CaseInvestigation NUMERIC(4, 2),
        @Ind_3_TheResultsOfLabTestsAndInterpretation NUMERIC(4, 2),
        @Ind_N1_CaseStatus NUMERIC(4, 2),
        @Ind_N1_DateofCompletionPF NUMERIC(4, 2),
        @Ind_N1_NameofEmployer NUMERIC(4, 2),
        @Ind_N1_CurrentLocationPatient NUMERIC(4, 2),
        @Ind_N1_NotifDateTime NUMERIC(4, 2),
        @Ind_N2_NotifDateTime NUMERIC(4, 2),
        @Ind_N3_NotifDateTime NUMERIC(4, 2),
        @Ind_N1_NotifSentByName NUMERIC(4, 2),
        @Ind_N1_NotifReceivedByFacility NUMERIC(4, 2),
        @Ind_N1_NotifReceivedByName NUMERIC(4, 2),
        @Ind_N1_TimelinessOfDataEntryDTEN NUMERIC(4, 2),
        @Ind_N2_TimelinessOfDataEntryDTEN NUMERIC(4, 2),
        @Ind_N3_TimelinessOfDataEntryDTEN NUMERIC(4, 2),
        @Ind_N1_DIStartingDTOfInvestigation NUMERIC(4, 2),
        @Ind_N2_DIStartingDTOfInvestigation NUMERIC(4, 2),
        @Ind_N3_DIStartingDTOfInvestigation NUMERIC(4, 2),
        @Ind_N1_DIOccupation NUMERIC(4, 2),
        @Ind_N1_CIInitCaseClassification NUMERIC(4, 2),
        @Ind_N1_CILocationOfExposure NUMERIC(4, 2),
        @Ind_N1_CIAntibioticTherapyAdministratedBSC NUMERIC(4, 2),
        @Ind_N1_SamplesCollection NUMERIC(4, 2),
        @Ind_N1_ContactLisAddContact NUMERIC(4, 2),
        @Ind_N1_CaseClassificationCS NUMERIC(4, 2),
        @Ind_N1_EpiLinksRiskFactorsByEpidCard NUMERIC(4, 2),
        @Ind_N2_EpiLinksRiskFactorsByEpidCard NUMERIC(4, 2),
        @Ind_N3_EpiLinksRiskFactorsByEpidCard NUMERIC(4, 2),
        @Ind_N1_FCCOBasisOfDiagnosis NUMERIC(4, 2),
        @Ind_N1_FCCOOutcome NUMERIC(4, 2),
        @Ind_N1_FCCOIsThisCaseRelatedToOutbreak NUMERIC(4, 2),
        @Ind_N1_FCCOEpidemiologistName NUMERIC(4, 2),
        @Ind_N1_ResultsOfLabTestsTestsConducted NUMERIC(4, 2),
        @Ind_N1_ResultsOfLabTestsResultObservation NUMERIC(4, 2),
        @idfsRegionBaku BIGINT,
        @idfsRegionOtherRayons BIGINT,
        @idfsRegionNakhichevanAR BIGINT

DECLARE @DiagnosisTABLE TABLE
(
    intRowNumber INT IDENTITY(1, 1) PRIMARY KEY,
    [key] NVARCHAR(300),
    [value] NVARCHAR(300),
    intNotificationToCHE INT,
    intStartingDTOfInvestigation INT,
    blnLaboratoryConfirmation BIT,
    intQuantityOfMandatoryFieldCS INT,
    intQuantityOfMandatoryFieldCSForDC INT,
    intEPILincsAndFactors INT
)

DECLARE @ReportTABLE TABLE
(
    idfsBaseReference BIGINT IDENTITY NOT NULL PRIMARY KEY,
    idfsRegion BIGINT NOT NULL,
/*1*/
    strRegion NVARCHAR(200) NOT NULL,
    intRegionOrder INT NULL,
    idfsRayon BIGINT NOT NULL,
/*2*/
    strRayon NVARCHAR(200) NOT NULL,
    strAZRayon NVARCHAR(200) NOT NULL,
    intRayonOrder INT NULL,
    intCaseCount INT NOT NULL,
    idfsDiagnosis BIGINT NOT NULL,
/*3*/
    strDiagnosis NVARCHAR(300) COLLATE database_default NOT NULL,

/*6(1+2+3+5+6+8+9+10)*/
    dbl_1_Notification FLOAT NULL,
/*7(1)*/
    dblCaseStatus FLOAT NULL,
/*8(2)*/
    dblDateOfCompletionOfPaperForm FLOAT NULL,
/*9(3)*/
    dblNameOfEmployer FLOAT NULL,
/*11(5)*/
    dblCurrentLocationOfPatient FLOAT NULL,
/*12(6)*/
    dblNotificationDateTime FLOAT NULL,
/*13(7)*/
    dbldblNotificationSentByName FLOAT NULL,
/*14(8)*/
    dblNotificationReceivedByFacility FLOAT NULL,
/*15(9)*/
    dblNotificationReceivedByName FLOAT NULL,
/*16(10)*/
    dblTimelinessofDataEntry FLOAT NULL,

/*17(11..23)*/
    dbl_2_CaseInvestigation FLOAT NULL,
/*18(11)*/
    dblDemographicInformationStartingDateTimeOfInvestigation FLOAT NULL,
/*19(12)*/
    dblDemographicInformationOccupation FLOAT NULL,
/*20(13)*/
    dblClinicalInformationInitialCaseClassification FLOAT NULL,
/*21(14)*/
    dblClinicalInformationLocationOfExposure FLOAT NULL,
/*22(15)*/
    dblClinicalInformationAntibioticAntiviralTherapy FLOAT NULL,
/*23(16)*/
    dblSamplesCollectionSamplesCollected FLOAT NULL,
/*24(17)*/
    dblContactListAddContact FLOAT NULL,
/*25(18)*/
    dblCaseClassificationClinicalSigns FLOAT NULL,
/*26(19)*/
    dblEpidemiologicalLinksAndRiskFactors FLOAT NULL,
/*27(20)*/
    dblFinalCaseClassificationBasisOfDiagnosis FLOAT NULL,
/*28(21)*/
    dblFinalCaseClassificationOutcome FLOAT NULL,
/*29(22)*/
    dblFinalCaseClassificationIsThisCaseOutbreak FLOAT NULL,
/*30(23)*/
    dblFinalCaseClassificationEpidemiologistName FLOAT NULL,

/*31(24+25)*/
    dbl_3_TheResultsOfLaboratoryTests FLOAT NULL,
/*32(24)*/
    dblTheResultsOfLaboratoryTestsTestsConducted FLOAT NULL,
/*33(25)*/
    dblTheResultsOfLaboratoryTestsResultObservation FLOAT NULL,

/*34*/
    dblSummaryScoreByIndicators FLOAT NULL
)

IF @StartMonth IS NULL
BEGIN
    SET @SDDate = (CAST(@Year AS VARCHAR(4)) + '01' + '01')
    SET @EDDate = dateADD(yyyy, 1, @SDDate)
END
ELSE
BEGIN
    IF @StartMonth < 10
        SET @SDDate = (CAST(@Year AS VARCHAR(4)) + '0' + CAST(@StartMonth AS VARCHAR(2)) + '01')
    ELSE
        SET @SDDate = (CAST(@Year AS VARCHAR(4)) + CAST(@StartMonth AS VARCHAR(2)) + '01')

    IF (@EndMonth is NULL)
       or (@StartMonth = @EndMonth)
        SET @EDDate = DATEADD(mm, 1, @SDDate)
    ELSE
    BEGIN
        IF @EndMonth < 10
            SET @EDDate = (CAST(@Year AS VARCHAR(4)) + '0' + CAST(@EndMonth AS VARCHAR(2)) + '01')
        ELSE
            SET @EDDate = (CAST(@Year AS VARCHAR(4)) + CAST(@EndMonth AS VARCHAR(2)) + '01')

        SET @EDDate = DATEADD(mm, 1, @EDDate)
    END
END

SET @CountryID = 170000000
SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
SET @idfsCustomReportType = 10290021

INSERT INTO @DiagnosisTABLE
(
    [key]
)
SELECT CAST([Value] AS BIGINT)
FROM report.FN_GBL_SYS_SplitList(@Diagnosis, 1, ',')

-- IF @Diagnosis is blank, fill to @DiagnosisTABLE all diagnosis
IF
(
    SELECT COUNT(*) FROM @DiagnosisTABLE
) = 0
BEGIN
    INSERT INTO @DiagnosisTABLE
    (
        [key],
        [value]
    )
    SELECT tbr.idfsBaseReference,
           tbr.strBaseReferenceCode
    FROM dbo.trtBaseReference tbr
        INNER JOIN dbo.trtBaseReferenceToCP tbrtc
            ON tbrtc.idfsBaseReference = tbr.idfsBaseReference
        INNER JOIN dbo.tstCustomizationPackage cp
            ON cp.idfCustomizationPackage = tbrtc.idfCustomizationPackage
               AND cp.idfsCountry = @CountryID
        INNER JOIN dbo.trtBaseReferenceAttribute tbra3
            INNER JOIN dbo.trtAttributeType tat3
                ON tat3.idfAttributeType = tbra3.idfAttributeType
                   AND tat3.strAttributeTypeName = 'QI Laboratory Confirmation'
            ON tbra3.idfsBaseReference = tbr.idfsBaseReference
    WHERE tbr.idfsReferenceType = 19000019 /*diagnosis*/
          AND tbr.intRowStatus = 0
          AND (tbr.intHACode & 2) > 1
END
ELSE
BEGIN
    UPDATE @DiagnosisTABLE
    SET [value] = b.strBaseReferenceCode
    FROM @DiagnosisTABLE a
        INNER JOIN trtBaseReference b
            ON a.[key] = b.idfsBaseReference
END

-- new !
UPDATE dt
SET dt.intNotificationToCHE = CASE
                                  WHEN SQL_VARIANT_PROPERTY(tbra1.varValue, 'BaseType') in ( 'BIGINT', 'decimal',
                                                                                             'FLOAT', 'INT', 'NUMERIC',
                                                                                             'real', 'smallint',
                                                                                             'tinyint'
                                                                                           ) THEN
                                      CAST(tbra1.varValue AS INT)
                                  ELSE
                                      NULL
                              END,
    dt.intStartingDTOfInvestigation = CASE
                                          WHEN SQL_VARIANT_PROPERTY(tbra2.varValue, 'BaseType') in ( 'BIGINT',
                                                                                                     'decimal',
                                                                                                     'FLOAT', 'INT',
                                                                                                     'NUMERIC', 'real',
                                                                                                     'smallint',
                                                                                                     'tinyint'
                                                                                                   ) THEN
                                              CAST(tbra2.varValue AS INT)
                                          ELSE
                                              NULL
                                      END,
    dt.blnLaboratoryConfirmation = CASE
                                       WHEN SQL_VARIANT_PROPERTY(tbra3.varValue, 'BaseType') in ( 'BIGINT', 'decimal',
                                                                                                  'FLOAT', 'INT',
                                                                                                  'NUMERIC', 'real',
                                                                                                  'smallint', 'tinyint'
                                                                                                ) THEN
                                           CAST(tbra3.varValue AS INT)
                                       ELSE
                                           NULL
                                   END,
    dt.intQuantityOfMandatoryFieldCS = CASE
                                           WHEN SQL_VARIANT_PROPERTY(tbra5.varValue, 'BaseType') in ( 'BIGINT',
                                                                                                      'decimal',
                                                                                                      'FLOAT', 'INT',
                                                                                                      'NUMERIC',
                                                                                                      'real',
                                                                                                      'smallint',
                                                                                                      'tinyint'
                                                                                                    ) THEN
                                               CAST(tbra5.varValue AS INT)
                                           ELSE
                                               NULL
                                       END,
    dt.intQuantityOfMandatoryFieldCSForDC = CASE
                                                WHEN SQL_VARIANT_PROPERTY(tbra6.varValue, 'BaseType') in ( 'BIGINT',
                                                                                                           'decimal',
                                                                                                           'FLOAT',
                                                                                                           'INT',
                                                                                                           'NUMERIC',
                                                                                                           'real',
                                                                                                           'smallint',
                                                                                                           'tinyint'
                                                                                                         ) THEN
                                                    CAST(tbra6.varValue AS INT)
                                                ELSE
                                                    NULL
                                            END,
    dt.intEPILincsAndFactors = CASE
                                   WHEN SQL_VARIANT_PROPERTY(tbra7.varValue, 'BaseType') in ( 'BIGINT', 'decimal',
                                                                                              'FLOAT', 'INT',
                                                                                              'NUMERIC', 'real',
                                                                                              'smallint', 'tinyint'
                                                                                            ) THEN
                                       CAST(tbra7.varValue AS INT)
                                   ELSE
                                       NULL
                               END
FROM @DiagnosisTABLE dt
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra1
        INNER JOIN dbo.trtAttributeType tat1
            ON tat1.idfAttributeType = tbra1.idfAttributeType
               AND tat1.strAttributeTypeName = 'QI Transmission of Emergency Notification to CHE'
        ON tbra1.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra2
        INNER JOIN dbo.trtAttributeType tat2
            ON tat2.idfAttributeType = tbra2.idfAttributeType
               AND tat2.strAttributeTypeName = 'QI Starting date, time of investigation'
        ON tbra2.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra3
        INNER JOIN dbo.trtAttributeType tat3
            ON tat3.idfAttributeType = tbra3.idfAttributeType
               AND tat3.strAttributeTypeName = 'QI Laboratory Confirmation'
        ON tbra3.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra5
        INNER JOIN dbo.trtAttributeType tat5
            ON tat5.idfAttributeType = tbra5.idfAttributeType
               AND tat5.strAttributeTypeName = 'QI Quantity of mandatory fields of Clinical Signs'
        ON tbra5.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra6
        INNER JOIN dbo.trtAttributeType tat6
            ON tat6.idfAttributeType = tbra6.idfAttributeType
               AND tat6.strAttributeTypeName = 'QI Quantity of mandatory fields of Clinical Signs that’s nesessary for diagnosis confirmation by Clinical Signs ("Yes")'
        ON tbra6.idfsBaseReference = dt.[key]
    LEFT JOIN dbo.trtBaseReferenceAttribute tbra7
        INNER JOIN dbo.trtAttributeType tat7
            ON tat7.idfAttributeType = tbra7.idfAttributeType
               AND tat7.strAttributeTypeName = 'QI Epidemiological Links AND Risk Factors - Minimum quantity logically filled fields.'
        ON tbra7.idfsBaseReference = dt.[key]

-- new
--1.
SELECT @Ind_1_Notification = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.1.
SELECT @Ind_N1_CaseStatus = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.1. CASE Status'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.2.
SELECT @Ind_N1_DateofCompletionPF = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.2. Date of Completion of Paper form'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.3.
SELECT @Ind_N1_NameofEmployer = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.3. Name of Employer'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.5.
SELECT @Ind_N1_CurrentLocationPatient = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.5. Current location of patient'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.6.
SELECT @Ind_N1_NotifDateTime = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.6. Notification date, time'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_NotifDateTime = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.6. Notification date, time'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_NotifDateTime = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.6. Notification date, time'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.8.
SELECT @Ind_N1_NotifSentByName = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.8. Notification sent by: Name'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.9.
SELECT @Ind_N1_NotifReceivedByFacility = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.9. Notification received by: Facility'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.10.
SELECT @Ind_N1_NotifReceivedByName = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.10. Notification received by: Name'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--1.11.
SELECT @Ind_N1_TimelinessOfDataEntryDTEN = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_TimelinessOfDataEntryDTEN = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_TimelinessOfDataEntryDTEN = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.
SELECT @Ind_2_CaseInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2. CASE Investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.1.1.
SELECT @Ind_N1_DIStartingDTOfInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_DIStartingDTOfInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_DIStartingDTOfInvestigation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.1.2.
SELECT @Ind_N1_DIOccupation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.1.2. Demographic Information – Occupation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.2.1.
SELECT @Ind_N1_CIInitCaseClassification = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.2.1. Clinical information - Initial CASE Classification'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.2.2.
SELECT @Ind_N1_CILocationOfExposure = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.2.2. Clinical information - Location of Exposure IF it known'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.2.3.
SELECT @Ind_N1_CIAntibioticTherapyAdministratedBSC = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.2.3. Clinical information - Antibiotic/Antiviral therapy administrated before samples collection'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.3.1.
SELECT @Ind_N1_SamplesCollection = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.3.1. Samples Collection  - Samples collected'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.4.1.
SELECT @Ind_N1_ContactLisAddContact = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.4.1. Contact List  - Add Contact'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.5.
SELECT @Ind_N1_CaseClassificationCS = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.5. CASE Classification (Clinical signs)'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.6.1.
SELECT @Ind_N1_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N2_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N2'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

SELECT @Ind_N3_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N3'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )


--2.7.3.
SELECT @Ind_N1_FCCOBasisOfDiagnosis = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.3. Final CASE Classification AND Outcome - Basis of Diagnosis'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.7.4.
SELECT @Ind_N1_FCCOOutcome = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.4. Final CASE Classification AND Outcome – Outcome'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.7.5.
SELECT @Ind_N1_FCCOIsThisCaseRelatedToOutbreak = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.5. Final CASE Classification AND Outcome - Is this CASE related to an outbreak'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--2.7.6.
SELECT @Ind_N1_FCCOEpidemiologistName = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '2.7.6. Final CASE Classification AND Outcome - Epidemiologist name'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--3.
SELECT @Ind_3_TheResultsOfLabTestsAndInterpretation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '3.The results of Laboratory Tests AND  Interpretation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--3.1.
SELECT @Ind_N1_ResultsOfLabTestsTestsConducted = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '3.1. The results of Laboratory Tests AND Interpretation - Tests Conducted'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )

--3.2.
SELECT @Ind_N1_ResultsOfLabTestsResultObservation = CAST(tbra.varValue AS NUMERIC(4, 2))
FROM dbo.trtBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType tat
        ON tat.idfAttributeType = tbra.idfAttributeType
           AND tat.strAttributeTypeName = 'Indicators Max Score N'
WHERE tbra.idfsBaseReference = @idfsCustomReportType
      AND tbra.strAttributeItem = '3.2. The results of Laboratory Tests AND Interpretation - Result/Observation'
      AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ( 'BIGINT', 'decimal', 'FLOAT', 'INT', 'NUMERIC', 'real',
                                                               'smallint', 'tinyint'
                                                             )



--Transport CHE
DECLARE @TransportCHE BIGINT

SELECT @TransportCHE = frr.idfsReference
FROM dbo.FN_GBL_ReferenceRepair('en', 19000020) frr
WHERE frr.name = 'Transport CHE'
print @TransportCHE


--1344330000000 --Baku
SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
FROM dbo.trtGISBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType at
        ON at.strAttributeTypeName = N'AZ Region'
WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Baku'

--1344340000000 --Other rayons
SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
FROM dbo.trtGISBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType at
        ON at.strAttributeTypeName = N'AZ Region'
WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Other rayons'


--1344350000000 --Nakhichevan AR
SELECT @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
FROM dbo.trtGISBaseReferenceAttribute tbra
    INNER JOIN dbo.trtAttributeType at
        ON at.strAttributeTypeName = N'AZ Region'
WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Nakhichevan AR'


-------------------------------------------
DECLARE @isTLVL BIGINT
SET @isTLVL = 0

SELECT @isTLVL = CASE
                     WHEN ts.idfsSiteType = 10085007 THEN
                         1
                     ELSE
                         0
                 END
FROM tstSite ts
WHERE ts.idfsSite = ISNULL(@SiteID, dbo.fnSiteID())

DECLARE @isWeb BIGINT
SET @isWeb = 0

SELECT @isWeb = ISNULL(ts.blnIsWEB, 0)
FROM tstSite ts
WHERE ts.idfsSite = dbo.fnSiteID()
-------------------------------------------

IF OBJECT_ID('tempdb.dbo.#FilteredRayonsTABLE') is NOT NULL
    DROP TABLE #FilteredRayonsTABLE
CREATE TABLE #FilteredRayonsTABLE
(
    idfsRegion BIGINT,
    idfsRayon BIGINT,
    PRIMARY KEY
    (
        idfsRegion,
        idfsRayon
    )
)

--DECLARE #ReportDataTABLE TABLE
IF OBJECT_ID('tempdb.dbo.#ReportDataTABLE') is NOT NULL
    DROP TABLE #ReportDataTABLE
CREATE TABLE #ReportDataTABLE
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    IdRegion BIGINT,
    strRegion NVARCHAR(2000) COLLATE database_default,
    IdRayon BIGINT,
    strRayon NVARCHAR(2000) COLLATE database_default,
    strAZRayon NVARCHAR(2000) COLLATE database_default,
    IdDiagnosis BIGINT,
    Diagnosis NVARCHAR(2000) COLLATE database_default,
    intRegionOrder INT,
    intRayonOrder INT,
    CountCasesForDiag INT
)

--DECLARE #ReportCaseTABLE TABLE
IF OBJECT_ID('tempdb.dbo.#ReportCaseTABLE') is NOT NULL
    DROP TABLE #ReportCaseTABLE
CREATE TABLE #ReportCaseTABLE
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    idfCase BIGINT,
    IdRegion BIGINT,
    strRegion NVARCHAR(2000) COLLATE database_default,
    IdRayon BIGINT,
    strRayon NVARCHAR(2000) COLLATE database_default,
    strAZRayon NVARCHAR(2000) COLLATE database_default,
    intRegionOrder INT,
    intRayonOrder INT,
    idfsShowDiagnosis BIGINT,
    Diagnosis NVARCHAR(2000) COLLATE database_default,
    idfsShowDiagnosisFromCase BIGINT,

/*7(1)*/
    IndCaseStatus FLOAT,
/*8(2)*/
    IndDateOfCompletionPaperFormDate FLOAT,
/*9(3)*/
    IndNameOfEmployer FLOAT,
/*11(5)*/
    IndCurrentLocation FLOAT,
/*12(6)*/
    IndNotificationDate FLOAT,
/*13(7)*/
    IndNotificationSentByName FLOAT,
/*14(8)*/
    IndNotificationReceivedByFacility FLOAT,
/*15(9)*/
    IndNotificationReceivedByName FLOAT,
/*16(10)*/
    IndDateAndTimeOfTheEmergencyNotification FLOAT,

/*18(11)*/
    IndInvestigationStartDate FLOAT,
/*19(12)*/
    IndOccupationType FLOAT,
/*20(13)*/
    IndInitialCaseClassification FLOAT,
/*21(14)*/
    IndLocationOfExplosure FLOAT,
/*22(15)*/
    IndAATherapyAdmBeforeSamplesCollection FLOAT,
/*23(16)*/
    IndSamplesCollected FLOAT,
/*24(17)*/
    IndAddcontact FLOAT,
/*25(18)*/
    IndClinicalSigns FLOAT,
/*26(19)*/
    IndEpidemiologicalLinksAndRiskFactors FLOAT,

/*27(20)*/
    IndBasisOfDiagnosis FLOAT,
/*28(21)*/
    IndOutcome FLOAT,
/*29(22)*/
    IndISThisCaseRelatedToOutbreak FLOAT,
/*30(23)*/
    IndEpidemiologistName FLOAT,

/*32(24)*/
    IndResultsTestsConducted FLOAT,
/*33(25)*/
    IndResultsResultObservation FLOAT
)

IF OBJECT_ID('tempdb.dbo.#ReportCaseTABLE_CountForDiagnosis') is NOT NULL
    DROP TABLE #ReportCaseTABLE_CountForDiagnosis
CREATE TABLE #ReportCaseTABLE_CountForDiagnosis
(
    CountCase INT,
    IdRegion BIGINT,
    IdRayon BIGINT,
    idfsShowDiagnosis BIGINT
        PRIMARY KEY
        (
            IdRegion,
            IdRayon,
            idfsShowDiagnosis
        )
)

INSERT INTO #FilteredRayonsTABLE
SELECT CASE
           WHEN s_current.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               @TransportCHE
           ELSE
               gls.idfsRegion
       END AS idfsRegion,
       CASE
           WHEN s_current.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               s_current.idfsSite
           ELSE
               gls.idfsRayon
       END AS idfsRayon
FROM dbo.tstSite s_current
    INNER JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = s_current.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    INNER JOIN dbo.tlbOffice o_current
        ON o_current.idfOffice = s_current.idfOffice
           AND o_current.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared gls
        ON gls.idfGeoLocationShared = o_current.idfLocation
WHERE s_current.idfsSite = ISNULL(@SiteID, dbo.fnSiteID())
      AND gls.idfsRayon is NOT NULL
UNION
SELECT CASE
           WHEN s.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               @TransportCHE
           ELSE
               gls.idfsRegion
       END AS idfsRegion,
       CASE
           WHEN s.intFlags = 1
                AND cp.idfsCountry = @CountryID THEN
               s.idfsSite
           ELSE
               gls.idfsRayon
       END AS idfsRayon
FROM dbo.tstSite s
    INNER JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = s.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    INNER JOIN dbo.tlbOffice o
        ON o.idfOffice = s.idfOffice
           AND o.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared gls
        ON gls.idfGeoLocationShared = o.idfLocation
    INNER JOIN dbo.tflSiteToSiteGROUP sts
        INNER JOIN dbo.tflSiteGROUP tsg
            ON tsg.idfSiteGROUP = sts.idfSiteGROUP
               AND tsg.idfsRayon is NULL
        ON sts.idfsSite = s.idfsSite
    INNER JOIN dbo.tflSiteGROUPRelation sgr
        ON sgr.idfSenderSiteGROUP = sts.idfSiteGROUP
    INNER JOIN dbo.tflSiteToSiteGROUP stsr
        INNER JOIN dbo.tflSiteGROUP tsgr
            ON tsgr.idfSiteGROUP = stsr.idfSiteGROUP
               AND tsgr.idfsRayon IS NULL
        ON sgr.idfReceiverSiteGROUP = stsr.idfSiteGROUP
           AND stsr.idfsSite = ISNULL(@SiteID, dbo.fnSiteID())
WHERE gls.idfsRayon is NOT NULL

-- + border area
INSERT INTO #FilteredRayonsTABLE
(
    idfsRayon
)
SELECT DISTINCT
    osr.idfsRayon
FROM #FilteredRayonsTABLE fr
    INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
        ON r.idfsRayon = fr.idfsRayon
           AND r.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared gls
        ON gls.idfsRayon = r.idfsRayon
    INNER JOIN dbo.tlbOffice o
        ON gls.idfGeoLocationShared = o.idfLocation
           AND o.intRowStatus = 0
    INNER JOIN dbo.tstSite s
        INNER JOIN dbo.tstCustomizationPackage cp
            ON cp.idfCustomizationPackage = s.idfCustomizationPackage
        ON s.idfOffice = o.idfOffice
    INNER JOIN dbo.tflSiteGROUP tsg_cent
        ON tsg_cent.idfsCentralSite = s.idfsSite
           AND tsg_cent.idfsRayon is NULL
           AND tsg_cent.intRowStatus = 0
    INNER JOIN dbo.tflSiteToSiteGROUP tstsg
        ON tstsg.idfSiteGROUP = tsg_cent.idfSiteGROUP
    INNER JOIN dbo.tstSite ts
        ON ts.idfsSite = tstsg.idfsSite
    INNER JOIN dbo.tlbOffice os
        ON os.idfOffice = ts.idfOffice
           AND os.intRowStatus = 0
    INNER JOIN dbo.tlbGeoLocationShared ogl
        ON ogl.idfGeoLocationShared = o.idfLocation
    INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) osr
        ON osr.idfsRayon = ogl.idfsRayon
           AND ogl.intRowStatus = 0
    LEFT JOIN #FilteredRayonsTABLE fr2
        ON osr.idfsRayon = fr2.idfsRayon
WHERE fr2.idfsRayon is NULL

INSERT INTO #ReportDataTABLE
(
    IdRegion,
    strRegion,
    IdRayon,
    strRayon,
    strAZRayon,
    IdDiagnosis,
    Diagnosis,
    intRegionOrder,
    intRayonOrder
)
SELECT reg.idfsRegion AS IdRegion,
       refReg.[name] AS strRegion,
       ray.idfsRayon AS IdRayon,
       refRay.[name] AS strRayon,
       refRayAZ.[name] AS strAZRayon,
       0 AS IdDiagnosis,
       '' AS Diagnosis,
       CASE reg.idfsRegion
           WHEN @idfsRegionBaku --1344330000000 --Baku
       THEN
               1
           WHEN @idfsRegionOtherRayons --1344340000000 --Other rayons
       THEN
               2
           WHEN @idfsRegionNakhichevanAR --1344350000000 --Nakhichevan AR
       THEN
               3
           ELSE
               0
       END AS intRegionOrder,
       0 AS intRayonOrder
FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000003 /*rftRegion*/) AS refReg
        ON reg.idfsRegion = refReg.idfsReference
           AND reg.idfsCountry = @CountryID
    JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray
        ON ray.idfsRegion = reg.idfsRegion
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*rftRayon*/) AS refRay
        ON ray.idfsRayon = refRay.idfsReference
    JOIN dbo.FN_GBL_GIS_Reference('az-l', 19000002 /*rftRayon*/) AS refRayAZ
        ON ray.idfsRayon = refRayAZ.idfsReference
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = reg.idfsRegion
           AND frt.idfsRayon = ray.idfsRayon
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          )
UNION ALL
SELECT tbr.idfsGISBaseReference AS IdRegion,
       frr.[name] AS strRegion,
       ts.idfsSite AS IdRayon,
       fir.AbbreviatedName AS strRayon,
       firAZ.AbbreviatedName AS strAZRayon,
       0 AS IdDiagnosis,
       '' AS Diagnosis,
       4 AS intRegionOrder,
       tbr1.intOrder AS intRayonOrder
FROM dbo.gisBaseReference tbr --TransportCHE
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000020) frr
        ON frr.idfsReference = tbr.idfsGISBaseReference
           AND tbr.idfsGISBaseReference = @TransportCHE
    CROSS JOIN dbo.tstSite ts
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = @TransportCHE
           AND frt.idfsRayon = ts.idfsSite
    JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = ts.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    JOIN dbo.FN_GBL_Institution_Min(@LangID) fir
        ON fir.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.FN_GBL_Institution_Min('az-l') firAZ
        ON firAZ.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.trtBaseReference tbr1
        ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation
WHERE CAST(@Diagnosis AS NVARCHAR(max)) = '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          )
UNION ALL
SELECT reg.idfsRegion AS IdRegion,
       refReg.[name] AS strRegion,
       ray.idfsRayon AS IdRayon,
       refRay.[name] AS strRayon,
       refRayAZ.[name] AS strAZRayon,
       CAST(dt.[key] AS BIGINT) AS IdDiagnosis,
       refDiag.name AS Diagnosis,
       CASE reg.idfsRegion
           WHEN @idfsRegionBaku --1344330000000 --Baku
       THEN
               1
           WHEN @idfsRegionOtherRayons --1344340000000 --Other rayons
       THEN
               2
           WHEN @idfsRegionNakhichevanAR --1344350000000 --Nakhichevan AR
       THEN
               3
           ELSE
               0
       END AS intRegionOrder,
       0 AS intRayonOrder
FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000003 /*rftRegion*/) AS refReg
        ON reg.idfsRegion = refReg.idfsReference
           AND reg.idfsCountry = @CountryID
    JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray
        ON ray.idfsRegion = reg.idfsRegion
    JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*rftRayon*/) AS refRay
        ON ray.idfsRayon = refRay.idfsReference
    JOIN dbo.FN_GBL_GIS_Reference('az-l', 19000002 /*rftRayon*/) AS refRayAZ
        ON ray.idfsRayon = refRayAZ.idfsReference
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = reg.idfsRegion
           AND frt.idfsRayon = ray.idfsRayon
    CROSS JOIN @DiagnosisTABLE AS dt
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) AS refDiag
        ON dt.[key] = refDiag.idfsReference
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          )
UNION ALL
SELECT tbr.idfsGISBaseReference AS IdRegion,
       frr.[name] AS strRegion,
       ts.idfsSite AS IdRayon,
       fir.AbbreviatedName AS strRayon,
       firAZ.AbbreviatedName AS strAZRayon,
       CAST(dt.[key] AS BIGINT) AS IdDiagnosis,
       refDiag.name AS Diagnosis,
       4 AS intRegionOrder,
       tbr1.intOrder AS intRayonOrder
FROM dbo.gisBaseReference tbr --TransportCHE
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000020) frr
        ON frr.idfsReference = tbr.idfsGISBaseReference
           AND tbr.idfsGISBaseReference = @TransportCHE
    CROSS JOIN dbo.tstSite ts
    LEFT JOIN #FilteredRayonsTABLE frt
        ON frt.idfsRegion = @TransportCHE
           AND frt.idfsRayon = ts.idfsSite
    JOIN dbo.tstCustomizationPackage cp
        ON cp.idfCustomizationPackage = ts.idfCustomizationPackage
           AND cp.idfsCountry = @CountryID
    JOIN dbo.FN_GBL_Institution_Min(@LangID) fir
        ON fir.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.FN_GBL_Institution_Min('az-l') firAZ
        ON firAZ.idfOffice = ts.idfOffice
           AND ts.intFlags = 1
    JOIN dbo.trtBaseReference tbr1
        ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation
    CROSS JOIN @DiagnosisTABLE AS dt
    JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) AS refDiag
        ON dt.[key] = refDiag.idfsReference
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND (
              @isTLVL = 0
              or frt.idfsRayon is NOT NULL
              or @isWeb = 1
          );

DECLARE @EPI TABLE
(
    idfHumanCase BIGINT PRIMARY KEY,
    countEPI INT
)

INSERT INTO @EPI
(
    idfHumanCase,
    countEPI
)
SELECT hcs.idfHumanCase,
       COUNT(tap.idfActivityParameters) AS countEPI
FROM dbo.tlbHumanCase hcs
    INNER JOIN dbo.tlbObservation obs
        ON obs.idfObservation = hcs.idfEpiObservation
           AND obs.intRowStatus = 0
    INNER JOIN dbo.ffFormTemplate fft
        ON fft.idfsFormTemplate = obs.idfsFormTemplate
           AND idfsFormType = 10034011 /*Human Epi Investigations*/
    INNER JOIN dbo.ffParameterForTemplate pft
        ON pft.idfsFormTemplate = obs.idfsFormTemplate
           AND pft.intRowStatus = 0
    INNER JOIN dbo.ffParameter fp
        INNER JOIN dbo.ffParameterType fpt
            ON fpt.idfsParameterType = fp.idfsParameterType
               AND fpt.idfsReferenceType is NOT NULL
               AND fpt.intRowStatus = 0
        ON fp.idfsParameter = pft.idfsParameter
           AND fp.idfsFormType = 10034011 /*Human Epi Investigations*/
           --AND fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
           AND fp.intRowStatus = 0
    INNER JOIN dbo.tlbActivityParameters tap
        ON tap.idfObservation = obs.idfObservation
           AND tap.idfsParameter = fp.idfsParameter
           AND (
                   fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
                   AND CAST(tap.varValue AS NVARCHAR) in ( N'25460000000' /*pfv_YNU_yes*/, N'25640000000' /*pfv_YNU_no*/ )
                   or fp.idfsParameterType <> 217140000000
                      AND tap.varValue is NOT NULL
               )
           AND tap.intRowStatus = 0
WHERE hcs.intRowStatus = 0
      AND hcs.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= hcs.datFinalCaseClassificationDate
              AND hcs.datFinalCaseClassificationDate < @EDDate
          )
GROUP by hcs.idfHumanCase

DECLARE @CS TABLE
(
    idfHumanCase BIGINT PRIMARY KEY,
    countCS INT,
    blnUNI BIT
)

INSERT INTO @CS
(
    idfHumanCase,
    countCS,
    blnUNI
)
SELECT hcs.idfHumanCase,
       COUNT(tap.idfActivityParameters) AS countCS,
       fft.blnUNI
FROM dbo.tlbHumanCase hcs
    INNER JOIN dbo.tlbObservation obs
        ON obs.idfObservation = hcs.idfCSObservation
           AND obs.intRowStatus = 0
    INNER JOIN dbo.ffParameterForTemplate pft
        ON pft.idfsFormTemplate = obs.idfsFormTemplate
           AND pft.idfsEditMode = 10068003 /*Mandatory*/
           AND pft.idfsFormTemplate = obs.idfsFormTemplate
           AND pft.intRowStatus = 0
    INNER JOIN dbo.ffFormTemplate fft
        ON fft.idfsFormTemplate = pft.idfsFormTemplate
    LEFT JOIN dbo.ffParameter fp
        ON fp.idfsParameter = pft.idfsParameter
           AND (
                   fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
                   or fp.idfsParameterType = 10071045 /*text - parString*/
               )
           AND fp.idfsFormType = 10034010 /*Human Clinical Signs*/
           AND fp.intRowStatus = 0
    INNER JOIN dbo.tlbActivityParameters tap
        ON tap.idfObservation = obs.idfObservation
           AND tap.idfsParameter = fp.idfsParameter
           AND tap.intRowStatus = 0
           AND (
                   (
                       CAST(tap.varValue AS NVARCHAR) = N'25460000000' /*pfv_YNU_yes,	Yes*/
                       AND fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
                       AND fft.blnUNI = 0
                   )
                   or (
                          fft.blnUNI = 1
                          AND fp.idfsParameterType = 10071045 /*text - parString*/
                          AND CAST(tap.varValue AS NVARCHAR(500)) <> ''
                      )
               )
WHERE hcs.intRowStatus = 0
      AND hcs.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= hcs.datFinalCaseClassificationDate
              AND hcs.datFinalCaseClassificationDate < @EDDate
          )
GROUP by hcs.idfHumanCase,
         fft.blnUNI

--SELECT cs.idfHumanCase, cs.countCS, thc.strCaseID FROM @CS cs
--INNER JOIN tlbHumanCase thc
--ON thc.idfHumanCase = cs.idfHumanCase

--INNER JOIN tlbHuman th
--ON th.idfHuman = thc.idfHuman

--INNER JOIN tlbGeoLocation tgl
--ON tgl.idfGeoLocation = th.idfCurrentResidenceAddress
--AND tgl.idfsRayon = 1344420000000
--WHERE thc.strCaseID = 'HWEB00154695'

IF OBJECT_ID('tempdb.dbo.#CCP') is NOT NULL
    DROP TABLE #CCP
CREATE TABLE #CCP
(
    idfHumanCase BIGINT PRIMARY KEY,
    countCCP INT
)

INSERT INTO #CCP
(
    idfHumanCase,
    countCCP
)
SELECT tccp.idfHumanCase,
       COUNT(tccp.idfContactedCasePerson) AS CountContacts
FROM dbo.tlbContactedCasePerson tccp
    INNER JOIN dbo.tlbHumanCase thc
        ON thc.idfHumanCase = tccp.idfHumanCase
WHERE thc.intRowStatus = 0
      AND thc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= thc.datFinalCaseClassificationDate
              AND thc.datFinalCaseClassificationDate < @EDDate
          )
      AND tccp.intRowStatus = 0
GROUP by tccp.idfHumanCase

IF OBJECT_ID('tempdb.dbo.#CTR') IS NOT NULL
    DROP TABLE #CTR
CREATE TABLE #CTR
(
    idfHumanCase BIGINT PRIMARY KEY,
    countCTR INT
)

INSERT INTO #CTR
(
    idfHumanCase,
    countCTR
)
SELECT m.idfHumanCase,
       COUNT(tt.idfTesting) AS CountTestResults
FROM dbo.tlbMaterial m
    INNER JOIN dbo.tlbTesting tt
        ON tt.idfMaterial = m.idfMaterial
           AND tt.intRowStatus = 0
           AND tt.idfsTestResult is NOT NULL
    INNER JOIN dbo.tlbHumanCase thc
        ON thc.idfHumanCase = m.idfHumanCase
WHERE thc.intRowStatus = 0
      AND thc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
      AND (
              @SDDate <= thc.datFinalCaseClassificationDate
              AND thc.datFinalCaseClassificationDate < @EDDate
          )
      AND m.intRowStatus = 0
      AND m.idfHumanCase is NOT NULL
GROUP by m.idfHumanCase

INSERT INTO #ReportCaseTABLE
(
    idfCase,
    IdRegion,
    strRegion,
    IdRayon,
    strRayon,
    strAZRayon,
    intRegionOrder,
    intRayonOrder,
    idfsShowDiagnosis,
    Diagnosis,
    idfsShowDiagnosisFromCase,

/*7(1)*/
    IndCaseStatus,
/*8(2)*/
    IndDateOfCompletionPaperFormDate,
/*9(3)*/
    IndNameOfEmployer,
/*11(5)*/
    IndCurrentLocation,
/*12(6)*/
    IndNotificationDate,
/*13(7)*/
    IndNotificationSentByName,
/*14(8)*/
    IndNotificationReceivedByFacility,
/*15(9)*/
    IndNotificationReceivedByName,
/*16(10)*/
    IndDateAndTimeOfTheEmergencyNotification,

/*18(11)*/
    IndInvestigationStartDate,
/*19(12)*/
    IndOccupationType,
/*20(13)*/
    IndInitialCaseClassification,
/*21(14)*/
    IndLocationOfExplosure,
/*22(15)*/
    IndAATherapyAdmBeforeSamplesCollection,
/*23(16)*/
    IndSamplesCollected,
/*24(17)*/
    IndAddcontact,
/*25(18)*/
    IndClinicalSigns,
/*26(19)*/
    IndEpidemiologicalLinksAndRiskFactors,

/*27(20)*/
    IndBasisOfDiagnosis,
/*28(21)*/
    IndOutcome,
/*29(22)*/
    IndISThisCaseRelatedToOutbreak,
/*30(23)*/
    IndEpidemiologistName,

/*32(24)*/
    IndResultsTestsConducted,
/*33(25)*/
    IndResultsResultObservation
)
SELECT hc.idfHumanCase AS idfCase,
       fdt.IdRegion,
       fdt.strRegion,
       fdt.IdRayon,
       fdt.strRayon,
       fdt.strAZRayon,
       fdt.intRegionOrder,
       fdt.intRayonOrder,
       ISNULL(fdt.IdDiagnosis, '') AS idfsShowDiagnosis,
       ISNULL(fdt.Diagnosis, '') AS Diagnosis,
       ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) AS idfsShowDiagnosisFromCase,

                                                      /*7(1)*/
       CASE
           WHEN hc.idfsCaseProgressStatus = 10109002 /*Closed*/
       THEN
               @Ind_N1_CaseStatus
           ELSE
               0.00
       END AS IndCaseStatus,

                                                      /*8(2)*/
       CASE
           WHEN ISNULL(hc.datCompletionPaperFormDate, '') <> '' THEN
               @Ind_N1_DateofCompletionPF
           ELSE
               0.00
       END AS IndDateOfCompletionPaperFormDate,

                                                      /*9(3)*/
       CASE
           WHEN ISNULL(h.strEmployerName, '') <> '' THEN
               @Ind_N1_NameofEmployer
           ELSE
               0.00
       END AS IndNameOfEmployer,

                                                      /*11(5)*/
       CASE
           WHEN ISNULL(hc.idfsHospitalizationStatus, 0) <> 0 THEN
               @Ind_N1_CurrentLocationPatient
           ELSE
               0.00
       END AS IndCurrentLocation,

                                                      /*12(6)*/
       CASE
           WHEN (
                    ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                    AND hc.datCompletionPaperFormDate = hc.datNotificationDate
                )
                OR (
                       ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                       AND ISNULL(hc.datNotificationDate, '') <> ''
                       AND CAST(hc.datNotificationDate - hc.datCompletionPaperFormDate AS FLOAT) < 1
                   ) THEN
               @Ind_N1_NotifDateTime
           WHEN ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datCompletionPaperFormDate) AS FLOAT)
                between 1 AND 2 THEN
               @Ind_N2_NotifDateTime
           WHEN ISNULL(hc.datCompletionPaperFormDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datCompletionPaperFormDate) AS FLOAT) > 2 THEN
               @Ind_N3_NotifDateTime
           ELSE
               0.00
       END AS IndNotificationDate,


                                                      /*13(7)*/
       CASE
           WHEN ISNULL(hc.idfSentByPerson, '') <> '' THEN
               @Ind_N1_NotifSentByName
           ELSE
               0.00
       END AS IndNotificationSentByName,

                                                      /*14(8)*/
       CASE
           WHEN ISNULL(hc.idfReceivedByOffice, '') <> '' THEN
               @Ind_N1_NotifReceivedByFacility
           ELSE
               0.00
       END AS IndNotificationReceivedByFacility,

                                                      /*15(9)*/
       CASE
           WHEN ISNULL(hc.idfReceivedByPerson, '') <> '' THEN
               @Ind_N1_NotifReceivedByName
           ELSE
               0.00
       END AS IndNotificationReceivedByName,

                                                      /*16(10)*/
       CASE
           WHEN ISNULL(hc.datEnteredDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) AS FLOAT) < 1 THEN
               @Ind_N1_TimelinessOfDataEntryDTEN
           WHEN ISNULL(hc.datEnteredDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) AS FLOAT)
                between 1 AND 2 THEN
               @Ind_N2_TimelinessOfDataEntryDTEN
           WHEN ISNULL(hc.datEnteredDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) AS FLOAT) > 2 THEN
               @Ind_N3_TimelinessOfDataEntryDTEN
           ELSE
               0.00
       END AS IndDateAndTimeOfTheEmergencyNotification,

                                                      /*18(11)*/
       CASE
           WHEN ISNULL(hc.datInvestigationStartDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) AS FLOAT) < 1 THEN
               @Ind_N1_DIStartingDTOfInvestigation
           WHEN ISNULL(hc.datInvestigationStartDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) AS FLOAT)
                between 1 AND 2 THEN
               @Ind_N2_DIStartingDTOfInvestigation
           WHEN ISNULL(hc.datInvestigationStartDate, '') <> ''
                AND ISNULL(hc.datNotificationDate, '') <> ''
                AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) AS FLOAT) > 2 THEN
               @Ind_N3_DIStartingDTOfInvestigation
           ELSE
               0.00
       END AS IndInvestigationStartDate,

                                                      /*19(12)*/
       CASE
           WHEN ISNULL(h.idfsOccupationType, '') <> '' THEN
               @Ind_N1_DIOccupation
           ELSE
               0.00
       END AS IndOccupationType,                      --20(13)
       CASE
           WHEN ISNULL(hc.idfsInitialCaseStatus, '') = 380000000 /*Suspect*/
                OR ISNULL(hc.idfsInitialCaseStatus, '') = 360000000 /*Probable CASE*/
       THEN
               @Ind_N1_CIInitCaseClassification
           ELSE
               0.00
       END AS IndInitialCaseClassification,           --21(14)
       CASE
           WHEN ISNULL(tgl.idfsRegion, 0) <> 0
                AND ISNULL(tgl.idfsRayon, 0) <> 0
                AND ISNULL(tgl.idfsSettlement, 0) <> 0 THEN
               @Ind_N1_CILocationOfExposure
           ELSE
               0.00
       END AS IndLocationOfExplosure,                 --22(15)
       CASE
           WHEN ISNULL(hc.idfsYNAntimicrobialTherapy, '') <> '' THEN
               @Ind_N1_CIAntibioticTherapyAdministratedBSC
           ELSE
               0.00
       END AS IndAATherapyAdmBeforeSamplesCollection, --23(16)


       CASE
           WHEN (
                    dt.blnLaboratoryConfirmation = 1
                    AND hc.idfsYNSpecimenCollected = 10100001 /*Yes*/
                )
                or dt.blnLaboratoryConfirmation = 0 THEN
               @Ind_N1_SamplesCollection
           ELSE
               0.00
       END AS IndSamplesCollected,                    -- 24(17)


       CASE
           WHEN CCP.CountCCP > 0 THEN
               @Ind_N1_ContactLisAddContact
           ELSE
               0.00
       END AS IndAddcontact,                          -- 25(18)
       CASE
           WHEN dt.intQuantityOfMandatoryFieldCSForDC = 0
                or (
                       dt.intQuantityOfMandatoryFieldCSForDC = 1
                       AND CS.blnUNI = 1
                       AND CS.countCS >= 1
                   )
                or (
                       dt.intQuantityOfMandatoryFieldCSForDC > 0
                       AND CS.blnUNI = 0
                       AND CS.countCS >= dt.intQuantityOfMandatoryFieldCSForDC
                   ) THEN
               @Ind_N1_CaseClassificationCS
           ELSE
               0.00
       END AS IndClinicalSigns,                       -- 26(19)
       CASE
           WHEN (
                    dt.intEPILincsAndFactors > 0
                    AND EPI.countEPI > 0.8 * dt.intEPILincsAndFactors
                )
                or dt.intEPILincsAndFactors = 0 THEN
               @Ind_N1_EpiLinksRiskFactorsByEpidCard
           WHEN dt.intEPILincsAndFactors > 0
                AND EPI.countEPI > 0.5 * dt.intEPILincsAndFactors
                AND EPI.countEPI <= 0.8 * dt.intEPILincsAndFactors THEN
               @Ind_N2_EpiLinksRiskFactorsByEpidCard
           WHEN dt.intEPILincsAndFactors > 0
                AND EPI.countEPI <= 0.5 * dt.intEPILincsAndFactors THEN
               @Ind_N3_EpiLinksRiskFactorsByEpidCard
           ELSE
               0.00
       END AS IndEpidemiologicalLinksAndRiskFactors,  --27(20)

       CASE
           WHEN ISNULL(hc.blnClinicalDiagBasis, '') = 1
                OR ISNULL(hc.blnLabDiagBasis, '') = 1
                OR ISNULL(hc.blnEpiDiagBasis, '') = 1 THEN
               @Ind_N1_FCCOBasisOfDiagnosis
           ELSE
               0.00
       END AS IndBasisOfDiagnosis,                    --30(23)
       CASE
           WHEN ISNULL(hc.idfsOutcome, '') <> '' THEN
               @Ind_N1_FCCOOutcome
           ELSE
               0.00
       END AS IndOutcome,                             --31(24)
       CASE
           WHEN ISNULL(hc.idfsYNRelatedToOutbreak, '') = 10100001 /*Yes*/
                OR ISNULL(hc.idfsYNRelatedToOutbreak, '') = 10100002 /*No*/
       THEN
               @Ind_N1_FCCOIsThisCaseRelatedToOutbreak
           ELSE
               0.00
       END AS IndISThisCaseRelatedToOutbreak,         --32(25)
       CASE
           WHEN ISNULL(hc.idfInvestigatedByPerson, '') <> '' THEN
               @Ind_N1_FCCOEpidemiologistName
           ELSE
               00.00
       END AS IndEpidemiologistName,                  --33(26)
       CASE
           WHEN (
                    dt.blnLaboratoryConfirmation = 1
                    AND hc.idfsYNTestsConducted = 10100001 /*Yes*/
                )
                or dt.blnLaboratoryConfirmation = 0 THEN
               @Ind_N1_ResultsOfLabTestsTestsConducted
           ELSE
               0.00
       END AS IndResultsTestsConducted,               --35(27)
       CASE
           WHEN (
                    dt.blnLaboratoryConfirmation = 1
                    AND CTR.CountCTR > 0
                )
                or dt.blnLaboratoryConfirmation = 0 THEN
               @Ind_N1_ResultsOfLabTestsResultObservation
           ELSE
               0.00
       END AS IndResultsResultObservation             --36(28)

FROM
(
    SELECT *
    FROM #ReportDataTABLE AS rt
    WHERE (
              rt.IdRegion = @RegionID
              or @RegionID is NULL
          )
          AND (
                  rt.IdRayon = @RayonID
                  or @RayonID is NULL
              )
) fdt
    LEFT JOIN dbo.tlbHumanCase hc
        JOIN dbo.tstSite ts
            ON ts.idfsSite = hc.idfsSite
        JOIN dbo.tlbHuman h
            ON hc.idfHuman = h.idfHuman
               AND h.intRowStatus = 0
        JOIN dbo.tlbGeoLocation gl
            ON h.idfCurrentResidenceAddress = gl.idfGeoLocation
               AND gl.intRowStatus = 0
        LEFT JOIN dbo.tlbGeoLocation tgl
            ON tgl.idfGeoLocation = hc.idfPointGeoLocation
               AND tgl.intRowStatus = 0
        ON hc.intRowStatus = 0
           AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
           AND (
                   @SDDate <= hc.datFinalCaseClassificationDate
                   AND hc.datFinalCaseClassificationDate < @EDDate
               )
           AND (
                   (
                       ISNULL(ts.intFlags, 0) = 0
                       AND fdt.IdRegion = gl.idfsRegion
                       AND fdt.IdRayon = gl.idfsRayon
                   )
                   or (
                          ts.intFlags = 1
                          AND fdt.IdRegion = @TransportCHE
                          AND fdt.IdRayon = hc.idfsSite
                      )
               )
           AND fdt.IdDiagnosis = CASE
                                     WHEN CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>' THEN
                                         ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
                                     ELSE
                                         fdt.IdDiagnosis
                                 END
    LEFT JOIN @DiagnosisTABLE dt
        ON dt.[key] = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
    LEFT JOIN @CS AS CS
        ON CS.idfHumanCase = hc.idfHumanCase
    LEFT JOIN @EPI AS EPI
        ON EPI.idfHumanCase = hc.idfHumanCase
    LEFT JOIN #CCP AS CCP
        ON CCP.idfHumanCase = hc.idfHumanCase
    LEFT JOIN #CTR AS CTR
        ON CTR.idfHumanCase = hc.idfHumanCase

INSERT INTO #ReportCaseTABLE_CountForDiagnosis
SELECT COUNT(*) AS CountCase,
       IdRegion,
       IdRayon,
       idfsShowDiagnosis
FROM #ReportCaseTABLE rct
    LEFT JOIN @DiagnosisTABLE dt
        ON dt.[key] = rct.idfsShowDiagnosisFromCase
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND rct.idfCase is NOT NULL
GROUP by IdRegion,
         strRegion,
         intRegionOrder,
         IdRayon,
         strRayon,
         intRayonOrder,
         idfsShowDiagnosis,
         Diagnosis,
         blnLaboratoryConfirmation,
         intQuantityOfMandatoryFieldCSForDC
UNION ALL
SELECT 0 AS CountCase,
       IdRegion,
       IdRayon,
       idfsShowDiagnosis
FROM #ReportCaseTABLE rct
    LEFT JOIN @DiagnosisTABLE dt
        ON dt.[key] = rct.idfsShowDiagnosisFromCase
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
      AND rct.idfCase is NULL
GROUP by IdRegion,
         strRegion,
         intRegionOrder,
         IdRayon,
         strRayon,
         intRayonOrder,
         idfsShowDiagnosis,
         Diagnosis,
         blnLaboratoryConfirmation,
         intQuantityOfMandatoryFieldCSForDC;
WITH ReportSumCaseTABLE
AS (SELECT rct.IdRegion,
           rct.strRegion,
           rct.IdRayon,
           rct.strRayon,
           rct.strAZRayon,
           rct.idfsShowDiagnosis,
           rct.Diagnosis,
           rct.intRegionOrder,
           rct.intRayonOrder,
           rct_count.CountCase AS intCaseCount,
           /*7(1)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndCaseStatus) / rct_count.CountCase
           END AS IndCaseStatus,
           /*8(2)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateOfCompletionPaperFormDate) / rct_count.CountCase
           END AS IndDateOfCompletionPaperFormDate,
           /*9(3)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNameOfEmployer) / rct_count.CountCase
           END AS IndNameOfEmployer,
           /*11(5)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndCurrentLocation) / rct_count.CountCase
           END AS IndCurrentLocation,
           /*12(6)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationDate) / rct_count.CountCase
           END AS IndNotificationDate,
           /*13(7)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationSentByName) / rct_count.CountCase
           END AS IndNotificationSentByName,
           /*14(8)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByFacility) / rct_count.CountCase
           END AS IndNotificationReceivedByFacility,
           /*15(9)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByName) / rct_count.CountCase
           END AS IndNotificationReceivedByName,
           /*16(10)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateAndTimeOfTheEmergencyNotification) / rct_count.CountCase
           END AS IndDateAndTimeOfTheEmergencyNotification,
           /*18(11)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndInvestigationStartDate) / rct_count.CountCase
           END AS IndInvestigationStartDate,
           /*19(12)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndOccupationType) / rct_count.CountCase
           END AS IndOccupationType,
           /*20(13)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndInitialCaseClassification) / rct_count.CountCase
           END AS IndInitialCaseClassification,
           /*21(14)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndLocationOfExplosure) / rct_count.CountCase
           END AS IndLocationOfExplosure,
           /*22(15)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndAATherapyAdmBeforeSamplesCollection) / rct_count.CountCase
           END AS IndAATherapyAdmBeforeSamplesCollection,
           /*23(16)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndSamplesCollected) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndSamplesCollected,
           /*24(17)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndAddcontact) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndAddcontact,
           /*25(18)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndClinicalSigns) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndClinicalSigns,
           /*26(19)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologicalLinksAndRiskFactors) / rct_count.CountCase
           END AS IndEpidemiologicalLinksAndRiskFactors,
           /*27(20)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndBasisOfDiagnosis) / rct_count.CountCase
           END AS IndBasisOfDiagnosis,
           /*28(21)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndOutcome) / rct_count.CountCase
           END AS IndOutcome,
           /*29(22)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndISThisCaseRelatedToOutbreak) / rct_count.CountCase
           END AS IndISThisCaseRelatedToOutbreak,
           /*30(23)*/
           CASE
               WHEN rct_count.CountCase = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologistName) / rct_count.CountCase
           END AS IndEpidemiologistName,
           /*32(24)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndResultsTestsConducted) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndResultsTestsConducted,
           /*33(25)*/
           CASE
               WHEN rct_count.CountCase > 0 THEN
                   SUM(IndResultsResultObservation) / rct_count.CountCase
               ELSE
                   0.00
           END AS IndResultsResultObservation
    FROM #ReportCaseTABLE rct
        INNER JOIN #ReportCaseTABLE_CountForDiagnosis rct_count
            ON rct.IdRegion = rct_count.IdRegion
               AND rct.IdRayon = rct_count.IdRayon
               AND rct.idfsShowDiagnosis = rct_count.idfsShowDiagnosis
        LEFT JOIN @DiagnosisTABLE dt
            ON dt.[key] = rct.idfsShowDiagnosisFromCase
    WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
    GROUP by rct.IdRegion,
             rct.strRegion,
             rct.intRegionOrder,
             rct.IdRayon,
             rct.strRayon,
             rct.strAZRayon,
             rct.intRayonOrder,
             rct.idfsShowDiagnosis,
             rct.Diagnosis,
             dt.blnLaboratoryConfirmation,
             dt.intQuantityOfMandatoryFieldCSForDC,
             rct_count.CountCase
   ),
     ReportSumCaseTABLEForRayons
AS (SELECT IdRegion,
           strRegion,
           IdRayon,
           strRayon,
           strAZRayon,
           idfsShowDiagnosis,
           Diagnosis,
           intRegionOrder,
           intRayonOrder,
           /*7(1)*/
           SUM(IndCaseStatus) AS IndCaseStatus,
           /*8(2)*/
           SUM(IndDateOfCompletionPaperFormDate) AS IndDateOfCompletionPaperFormDate,
           /*9(3)*/
           SUM(IndNameOfEmployer) AS IndNameOfEmployer,
           /*11(5)*/
           SUM(IndCurrentLocation) AS IndCurrentLocation,
           /*12(6)*/
           SUM(IndNotificationDate) AS IndNotificationDate,
           /*13(7)*/
           SUM(IndNotificationSentByName) AS IndNotificationSentByName,
           /*14(8)*/
           SUM(IndNotificationReceivedByFacility) AS IndNotificationReceivedByFacility,
           /*15(9)*/
           SUM(IndNotificationReceivedByName) AS IndNotificationReceivedByName,
           /*16(10)*/
           SUM(IndDateAndTimeOfTheEmergencyNotification) AS IndDateAndTimeOfTheEmergencyNotification,

           /*18(11)*/
           SUM(IndInvestigationStartDate) AS IndInvestigationStartDate,
           /*19(12)*/
           SUM(IndOccupationType) AS IndOccupationType,
           /*20(13)*/
           SUM(IndInitialCaseClassification) AS IndInitialCaseClassification,
           /*21(14)*/
           SUM(IndLocationOfExplosure) AS IndLocationOfExplosure,
           /*22(15)*/
           SUM(IndAATherapyAdmBeforeSamplesCollection) AS IndAATherapyAdmBeforeSamplesCollection,

           /*23(16)*/
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   SUM(IndSamplesCollected)
               ELSE
                   0.00
           END AS IndSamplesCollected,
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndSamplesCollected,
           /*24(17)*/
           SUM(IndAddcontact) AS IndAddcontact,
           /*25(18)*/
           CASE
               WHEN dt.intQuantityOfMandatoryFieldCSForDC > 0 THEN
                   SUM(IndClinicalSigns)
               ELSE
                   0.00
           END AS IndClinicalSigns,
           CASE
               WHEN dt.intQuantityOfMandatoryFieldCSForDC > 0 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndClinicalSigns,
           /*26(19)*/
           SUM(IndEpidemiologicalLinksAndRiskFactors) AS IndEpidemiologicalLinksAndRiskFactors,

           /*27(20)*/
           SUM(IndBasisOfDiagnosis) AS IndBasisOfDiagnosis,
           /*28(21)*/
           SUM(IndOutcome) AS IndOutcome,
           /*29(22)*/
           SUM(IndISThisCaseRelatedToOutbreak) AS IndISThisCaseRelatedToOutbreak,
           /*30(23)*/
           SUM(IndEpidemiologistName) AS IndEpidemiologistName,
           /*32(24)*/
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   SUM(IndResultsTestsConducted)
               ELSE
                   0.00
           END AS IndResultsTestsConducted,
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndResultsTestsConducted,
           /*33(25)*/
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   SUM(IndResultsResultObservation)
               ELSE
                   0.00
           END AS IndResultsResultObservation,
           CASE
               WHEN dt.blnLaboratoryConfirmation = 1 THEN
                   COUNT(idfCase)
               ELSE
                   0.00
           END AS CountIndResultsResultObservation,
           COUNT(idfCase) AS CountRecForDiag
    FROM #ReportCaseTABLE rct
        LEFT JOIN @DiagnosisTABLE dt
            ON dt.[key] = rct.idfsShowDiagnosisFromCase
    WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'
    GROUP by IdRegion,
             strRegion,
             intRegionOrder,
             IdRayon,
             strRayon,
             strAZRayon,
             intRayonOrder,
             idfsShowDiagnosis,
             Diagnosis,
             blnLaboratoryConfirmation,
             intQuantityOfMandatoryFieldCSForDC
   ),
     ReportSumCaseTABLEForRayons_Summary
AS (SELECT IdRegion,
           strRegion,
           IdRayon,
           strRayon,
           strAZRayon,
           '' AS idfsShowDiagnosis,
           '' AS Diagnosis,
           intRegionOrder,
           intRayonOrder,
           SUM(CountRecForDiag) AS intCaseCount, -- UPDATE 29.11.14
                                                 /*7(1)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndCaseStatus) / SUM(CountRecForDiag)
           END AS IndCaseStatus,
                                                 /*8(2)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateOfCompletionPaperFormDate) / SUM(CountRecForDiag)
           END AS IndDateOfCompletionPaperFormDate,
                                                 /*9(3)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNameOfEmployer) / SUM(CountRecForDiag)
           END AS IndNameOfEmployer,
                                                 /*11(5)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndCurrentLocation) / SUM(CountRecForDiag)
           END AS IndCurrentLocation,
                                                 /*12(6)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationDate) / SUM(CountRecForDiag)
           END AS IndNotificationDate,
                                                 /*13(7)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationSentByName) / SUM(CountRecForDiag)
           END AS IndNotificationSentByName,
                                                 /*14(8)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByFacility) / SUM(CountRecForDiag)
           END AS IndNotificationReceivedByFacility,
                                                 /*15(9)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndNotificationReceivedByName) / SUM(CountRecForDiag)
           END AS IndNotificationReceivedByName,
                                                 /*16(10)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndDateAndTimeOfTheEmergencyNotification) / SUM(CountRecForDiag)
           END AS IndDateAndTimeOfTheEmergencyNotification,

                                                 /*18(11)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndInvestigationStartDate) / SUM(CountRecForDiag)
           END AS IndInvestigationStartDate,
                                                 /*19(12)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndOccupationType) / SUM(CountRecForDiag)
           END AS IndOccupationType,
                                                 /*20(13)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndInitialCaseClassification) / SUM(CountRecForDiag)
           END AS IndInitialCaseClassification,
                                                 /*21(14)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndLocationOfExplosure) / SUM(CountRecForDiag)
           END AS IndLocationOfExplosure,
                                                 /*22(15)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndAATherapyAdmBeforeSamplesCollection) / SUM(CountRecForDiag)
           END AS IndAATherapyAdmBeforeSamplesCollection,

                                                 /*23(16)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndSamplesCollected) = 0 THEN
                   0.00
               ELSE
                   SUM(IndSamplesCollected) / SUM(CountIndSamplesCollected)
           END AS IndSamplesCollected,
                                                 /*24(17)*/
           CASE
               WHEN SUM(CountRecForDiag) = 0 THEN
                   0.00
               ELSE
                   SUM(IndAddcontact) / SUM(CountRecForDiag)
           END AS IndAddcontact,
                                                 /*25(18)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndClinicalSigns) = 0 THEN
                   0.00
               ELSE
                   SUM(IndClinicalSigns) / SUM(CountIndClinicalSigns)
           END AS IndClinicalSigns,
                                                 /*26(19)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologicalLinksAndRiskFactors) / SUM(CountRecForDiag)
           END AS IndEpidemiologicalLinksAndRiskFactors,

                                                 /*27(20)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndBasisOfDiagnosis) / SUM(CountRecForDiag)
           END AS IndBasisOfDiagnosis,
                                                 /*28(21)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndOutcome) / SUM(CountRecForDiag)
           END AS IndOutcome,
                                                 /*29(22)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndISThisCaseRelatedToOutbreak) / SUM(CountRecForDiag)
           END AS IndISThisCaseRelatedToOutbreak,
                                                 /*30(23)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               ELSE
                   SUM(IndEpidemiologistName) / SUM(CountRecForDiag)
           END AS IndEpidemiologistName,

                                                 /*32(24)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndResultsTestsConducted) = 0 THEN
                   0.00
               ELSE
                   SUM(IndResultsTestsConducted) / SUM(CountIndResultsTestsConducted)
           END AS IndResultsTestsConducted,
                                                 /*33(25)*/
           CASE
               WHEN SUM(ISNULL(CountRecForDiag, 0)) = 0 THEN
                   0.00
               WHEN SUM(CountIndResultsResultObservation) = 0 THEN
                   0.00
               ELSE
                   SUM(IndResultsResultObservation) / SUM(CountIndResultsResultObservation)
           END AS IndResultsResultObservation
    FROM ReportSumCaseTABLEForRayons rct
    WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'
    GROUP by IdRegion,
             strRegion,
             intRegionOrder,
             IdRayon,
             strRayon,
             strAZRayon,
             intRayonOrder --, CountRecForDiag -- UPDATE 29.11.14
   )
INSERT INTO @ReportTABLE
(
    idfsRegion,
    strRegion,
    intRegionOrder,
    idfsRayon,
    strRayon,
    strAZRayon,
    intRayonOrder,
    intCaseCount,
    idfsDiagnosis,
    strDiagnosis,
    dbl_1_Notification,
    dblCaseStatus,
    dblDateOfCompletionOfPaperForm,
    dblNameOfEmployer,
    dblCurrentLocationOfPatient,
    dblNotificationDateTime,
    dbldblNotificationSentByName,
    dblNotificationReceivedByFacility,
    dblNotificationReceivedByName,
    dblTimelinessofDataEntry,
    dbl_2_CaseInvestigation,
    dblDemographicInformationStartingDateTimeOfInvestigation,
    dblDemographicInformationOccupation,
    dblClinicalInformationInitialCaseClassification,
    dblClinicalInformationLocationOfExposure,
    dblClinicalInformationAntibioticAntiviralTherapy,
    dblSamplesCollectionSamplesCollected,
    dblContactListAddContact,
    dblCaseClassificationClinicalSigns,
    dblEpidemiologicalLinksAndRiskFactors,
    dblFinalCaseClassificationBasisOfDiagnosis,
    dblFinalCaseClassificationOutcome,
    dblFinalCaseClassificationIsThisCaseOutbreak,
    dblFinalCaseClassificationEpidemiologistName,
    dbl_3_TheResultsOfLaboratoryTests,
    dblTheResultsOfLaboratoryTestsTestsConducted,
    dblTheResultsOfLaboratoryTestsResultObservation,
    dblSummaryScoreByIndicators
)
SELECT IdRegion,
       strRegion,
       intRegionOrder,
       IdRayon,
       strRayon,
       strAZRayon,
       intRayonOrder,
       intCaseCount,
       idfsShowDiagnosis,
       Diagnosis,

/*6(1+2+3+5+6+8+9+10)*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification AS IndNotification,

/*7(1)*/
       IndCaseStatus AS IndCaseStatus,
/*8(2)*/
       IndDateOfCompletionPaperFormDate AS IndDateOfCompletionPaperFormDate,
/*9(3)*/
       IndNameOfEmployer AS IndNameOfEmployer,
/*11(5)*/
       IndCurrentLocation AS IndCurrentLocation,
/*12(6)*/
       IndNotificationDate AS IndNotificationDate,
/*13(7)*/
       IndNotificationSentByName AS IndNotificationSentByName,
/*14(8)*/
       IndNotificationReceivedByFacility AS IndNotificationReceivedByFacility,
/*15(9)*/
       IndNotificationReceivedByName AS IndNotificationReceivedByName,
/*16(10)*/
       IndDateAndTimeOfTheEmergencyNotification AS IndDateAndTimeOfTheEmergencyNotification,


/*17(11..23)*/
/*18(11)*/
       IndInvestigationStartDate + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification
       + /*21(14)*/ IndLocationOfExplosure + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection
       + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact + /*25(18)*/ IndClinicalSigns
       + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome
       + /*29(22)*/ IndISThisCaseRelatedToOutbreak + /*30(23)*/ IndEpidemiologistName AS IndCaseInvestigation,

/*18(11)*/
       IndInvestigationStartDate AS IndInvestigationStartDate,
/*19(12)*/
       IndOccupationType AS IndOccupationType,
/*20(13)*/
       IndInitialCaseClassification AS IndInitialCaseClassification,
/*21(14)*/
       IndLocationOfExplosure AS IndLocationOfExplosure,
/*22(15)*/
       IndAATherapyAdmBeforeSamplesCollection AS IndAATherapyAdmBeforeSamplesCollection,
/*23(16)*/
       IndSamplesCollected AS IndSamplesCollected,
/*24(17)*/
       IndAddcontact AS IndAddcontact,
/*25(18)*/
       IndClinicalSigns AS IndClinicalSigns,
/*26(19)*/
       IndEpidemiologicalLinksAndRiskFactors AS IndEpidemiologicalLinksAndRiskFactors,
/*27(20)*/
       IndBasisOfDiagnosis AS IndBasisOfDiagnosis,
/*28(21)*/
       IndOutcome AS IndOutcome,
/*29(22)*/
       IndISThisCaseRelatedToOutbreak AS IndISThisCaseRelatedToOutbreak,
/*30(23)*/
       IndEpidemiologistName AS IndEpidemiologistName,


/*31(24+25)*/
/*32(24)*/
       IndResultsTestsConducted + /*33(25)*/ IndResultsResultObservation AS IndResults,
/*32(24)*/
       IndResultsTestsConducted AS IndResultsTestsConducted,
/*33(25)*/
       IndResultsResultObservation AS IndResultsResultObservation,

/*34*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification + /*18(11)*/ IndInvestigationStartDate
       + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification + /*21(14)*/ IndLocationOfExplosure
       + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact
       + /*25(18)*/ IndClinicalSigns + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors
       + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome + /*29(22)*/ IndISThisCaseRelatedToOutbreak
       + /*30(23)*/ IndEpidemiologistName + /*32(24)*/ IndResultsTestsConducted
       + /*33(25)*/ IndResultsResultObservation AS SummaryScoreByIndicators
FROM ReportSumCaseTABLE
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) <> '<ItemList/>'
union all
SELECT IdRegion,
       strRegion,
       intRegionOrder,
       IdRayon,
       strRayon,
       strAZRayon,
       intRayonOrder,
       intCaseCount,
       idfsShowDiagnosis,
       Diagnosis,

/*6(1+2+3+5+6+8+9+10)*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification AS IndNotification,

/*7(1)*/
       IndCaseStatus AS IndCaseStatus,
/*8(2)*/
       IndDateOfCompletionPaperFormDate AS IndDateOfCompletionPaperFormDate,
/*9(3)*/
       IndNameOfEmployer AS IndNameOfEmployer,
/*11(5)*/
       IndCurrentLocation AS IndCurrentLocation,
/*12(6)*/
       IndNotificationDate AS IndNotificationDate,
/*13(7)*/
       IndNotificationSentByName AS IndNotificationSentByName,
/*14(8)*/
       IndNotificationReceivedByFacility AS IndNotificationReceivedByFacility,
/*15(9)*/
       IndNotificationReceivedByName AS IndNotificationReceivedByName,
/*16(10)*/
       IndDateAndTimeOfTheEmergencyNotification AS IndDateAndTimeOfTheEmergencyNotification,

/*17(11..23)*/
/*18(11)*/
       IndInvestigationStartDate + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification
       + /*21(14)*/ IndLocationOfExplosure + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection
       + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact + /*25(18)*/ IndClinicalSigns
       + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome
       + /*29(22)*/ IndISThisCaseRelatedToOutbreak + /*30(23)*/ IndEpidemiologistName AS IndCaseInvestigation,

/*18(11)*/
       IndInvestigationStartDate AS IndInvestigationStartDate,
/*19(12)*/
       IndOccupationType AS IndOccupationType,
/*20(13)*/
       IndInitialCaseClassification AS IndInitialCaseClassification,
/*21(14)*/
       IndLocationOfExplosure AS IndLocationOfExplosure,
/*22(15)*/
       IndAATherapyAdmBeforeSamplesCollection AS IndAATherapyAdmBeforeSamplesCollection,
/*23(16)*/
       IndSamplesCollected AS IndSamplesCollected,
/*24(17)*/
       IndAddcontact AS IndAddcontact,
/*25(18)*/
       IndClinicalSigns AS IndClinicalSigns,
/*26(19)*/
       IndEpidemiologicalLinksAndRiskFactors AS IndEpidemiologicalLinksAndRiskFactors,
/*27(20)*/
       IndBasisOfDiagnosis AS IndBasisOfDiagnosis,
/*28(21)*/
       IndOutcome AS IndOutcome,
/*29(22)*/
       IndISThisCaseRelatedToOutbreak AS IndISThisCaseRelatedToOutbreak,
/*30(23)*/
       IndEpidemiologistName AS IndEpidemiologistName,

/*31(24+25)*/
/*32(24)*/
       IndResultsTestsConducted + /*33(25)*/ IndResultsResultObservation AS IndResults,
/*32(24)*/
       IndResultsTestsConducted AS IndResultsTestsConducted,
/*33(25)*/
       IndResultsResultObservation AS IndResultsResultObservation,

/*34*/
/*7(1)*/
       IndCaseStatus + /*8(2)*/ IndDateOfCompletionPaperFormDate + /*9(3)*/ IndNameOfEmployer
       + /*11(5)*/ IndCurrentLocation + /*12(6)*/ IndNotificationDate + /*13(7)*/ IndNotificationSentByName
       + /*14(8)*/ IndNotificationReceivedByFacility + /*15(9)*/ IndNotificationReceivedByName
       + /*16(10)*/ IndDateAndTimeOfTheEmergencyNotification + /*18(11)*/ IndInvestigationStartDate
       + /*19(12)*/ IndOccupationType + /*20(13)*/ IndInitialCaseClassification + /*21(14)*/ IndLocationOfExplosure
       + /*22(15)*/ IndAATherapyAdmBeforeSamplesCollection + /*23(16)*/ IndSamplesCollected + /*24(17)*/ IndAddcontact
       + /*25(18)*/ IndClinicalSigns + /*26(19)*/ IndEpidemiologicalLinksAndRiskFactors
       + /*27(20)*/ IndBasisOfDiagnosis + /*28(21)*/ IndOutcome + /*29(22)*/ IndISThisCaseRelatedToOutbreak
       + /*30(23)*/ IndEpidemiologistName + /*32(24)*/ IndResultsTestsConducted
       + /*33(25)*/ IndResultsResultObservation AS SummaryScoreByIndicators
FROM ReportSumCaseTABLEForRayons_Summary
WHERE CAST(@Diagnosis AS NVARCHAR(MAX)) = '<ItemList/>'

SELECT -1 AS idfsBaseReference,
       -1 AS idfsRegion,
       '' AS strRegion,
       -1 AS intRegionOrder,
       -1 AS idfsRayon,
       '' AS strRayon,
       '' AS strAZRayon,
       -1 AS intRayonOrder,
       0 AS intCaseCount,
       -1 AS idfsDiagnosis,
       '' AS strDiagnosis,
       @Ind_1_Notification AS dbl_1_Notification,
       @Ind_N1_CaseStatus AS dblCaseStatus,
       @Ind_N1_DateofCompletionPF AS dblDateOfCompletionOfPaperForm,
       @Ind_N1_NameofEmployer AS dblNameOfEmployer,
       @Ind_N1_CurrentLocationPatient AS dblCurrentLocationOfPatient,
       @Ind_N1_NotifDateTime AS dblNotificationDateTime,
       @Ind_N1_NotifSentByName AS dbldblNotificationSentByName,
       @Ind_N1_NotifReceivedByFacility AS dblNotificationReceivedByFacility,
       @Ind_N1_NotifReceivedByName AS dblNotificationReceivedByName,
       @Ind_N1_TimelinessOfDataEntryDTEN AS dblTimelinessofDataEntry,
       @Ind_2_CaseInvestigation AS dbl_2_CaseInvestigation,
       @Ind_N1_DIStartingDTOfInvestigation AS dblDemographicInformationStartingDateTimeOfInvestigation,
       @Ind_N1_DIOccupation AS dblDemographicInformationOccupation,
       @Ind_N1_CIInitCaseClassification AS dblClinicalInformationInitialCaseClassification,
       @Ind_N1_CILocationOfExposure AS dblClinicalInformationLocationOfExposure,
       @Ind_N1_CIAntibioticTherapyAdministratedBSC AS dblClinicalInformationAntibioticAntiviralTherapy,
       @Ind_N1_SamplesCollection AS dblSamplesCollectionSamplesCollected,
       @Ind_N1_ContactLisAddContact AS dblContactListAddContact,
       @Ind_N1_CaseClassificationCS AS dblCaseClassificationClinicalSigns,
       @Ind_N1_EpiLinksRiskFactorsByEpidCard AS dblEpidemiologicalLinksAndRiskFactors,
       @Ind_N1_FCCOBasisOfDiagnosis AS dblFinalCaseClassificationBasisOfDiagnosis,
       @Ind_N1_FCCOOutcome AS dblFinalCaseClassificationOutcome,
       @Ind_N1_FCCOIsThisCaseRelatedToOutbreak AS dblFinalCaseClassificationIsThisCaseOutbreak,
       @Ind_N1_FCCOEpidemiologistName AS dblFinalCaseClassificationEpidemiologistName,
       @Ind_3_TheResultsOfLabTestsAndInterpretation AS dbl_3_TheResultsOfLaboratoryTests,
       @Ind_N1_ResultsOfLabTestsTestsConducted AS dblTheResultsOfLaboratoryTestsTestsConducted,
       @Ind_N1_ResultsOfLabTestsResultObservation AS dblTheResultsOfLaboratoryTestsResultObservation,
       @Ind_1_Notification + @Ind_2_CaseInvestigation + @Ind_3_TheResultsOfLabTestsAndInterpretation AS dblSummaryScoreByIndicators
UNION ALL
SELECT rt.idfsBaseReference,
       rt.idfsRegion,
       rt.strRegion,
       rt.intRegionOrder,
       rt.idfsRayon,
       rt.strRayon,
       rt.strAZRayon,
       rt.intRayonOrder,
       rt.intCaseCount,
       rt.idfsDiagnosis,
       rt.strDiagnosis,

/*6(1+2+3+5+6+8+9+10)*/
       rt.dbl_1_Notification,
/*7(1)*/
       rt.dblCaseStatus,
/*8(2)*/
       rt.dblDateOfCompletionOfPaperForm,
/*9(3)*/
       rt.dblNameOfEmployer,
/*11(5)*/
       rt.dblCurrentLocationOfPatient,
/*12(6)*/
       rt.dblNotificationDateTime,
/*13(7)*/
       rt.dbldblNotificationSentByName,
/*14(8)*/
       rt.dblNotificationReceivedByFacility,
/*15(9)*/
       rt.dblNotificationReceivedByName,
/*16(10)*/
       rt.dblTimelinessofDataEntry,

/*17(11..23)*/
       rt.dbl_2_CaseInvestigation,
/*18(11)*/
       rt.dblDemographicInformationStartingDateTimeOfInvestigation,
/*19(12)*/
       rt.dblDemographicInformationOccupation,
/*20(13)*/
       rt.dblClinicalInformationInitialCaseClassification,
/*21(14)*/
       rt.dblClinicalInformationLocationOfExposure,
/*22(15)*/
       rt.dblClinicalInformationAntibioticAntiviralTherapy,
/*23(16)*/
       rt.dblSamplesCollectionSamplesCollected,
/*24(17)*/
       rt.dblContactListAddContact,
/*25(18)*/
       rt.dblCaseClassificationClinicalSigns,
/*26(19)*/
       rt.dblEpidemiologicalLinksAndRiskFactors,
/*27(20)*/
       rt.dblFinalCaseClassificationBasisOfDiagnosis,
/*28(21)*/
       rt.dblFinalCaseClassificationOutcome,
/*29(22)*/
       rt.dblFinalCaseClassificationIsThisCaseOutbreak,
/*30(23)*/
       rt.dblFinalCaseClassificationEpidemiologistName,

/*31(24+25)*/
       rt.dbl_3_TheResultsOfLaboratoryTests,
/*32(24)*/
       rt.dblTheResultsOfLaboratoryTestsTestsConducted,
/*33(25)*/
       rt.dblTheResultsOfLaboratoryTestsResultObservation,

/*35*/
       rt.dblSummaryScoreByIndicators
FROM @ReportTABLE rt
ORDER BY intRegionOrder,
         strRegion,
         strRayon,
         idfsDiagnosis