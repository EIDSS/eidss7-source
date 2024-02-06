-- ================================================================================================
-- Name: USP_LAB_FAVORITE_SEARCH_GETList
--
-- Description:	Get laboratory favorites list for the various laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/21/2019 Initial release.
-- Stephen Long     07/09/2019 Added disease to wildcard search.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     09/05/2019 Removed transfer where clause and organization ID check.
-- Stephen Long     01/15/2020 Added transfer ID to query.
-- Stephen Long     01/22/2020 Cleaned up stored procedure.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     06/06/2020 Added batch status type ID to the model.
-- Stephen Long     06/07/2020 Added additional search fields to the where clause.
-- Stephen Long     06/14/2020 Added action requested to the model.
-- Stephen Long     06/24/2020 Added test completed indicator to the model.
-- Stephen Long     11/29/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2021 Moved pagination to table variable insert.
-- Stephen Long     01/05/2021 Removed sent to organization where criteria.
-- Stephen Long     01/07/2021 Removed leading wildcard (%) as full table scans are performed even 
--                             with indices resulting in long query run times.  Recommend NOT 
--                             putting those back in.
-- Mark Wilson		08/16/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/20/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     11/18/2021 Added action requested ID and previous test status type to the 
--                  query.
-- Stephen Long     12/07/2021 Added group by on final results.
-- Stephen Long     12/14/2021 Added sample status date to the query.
-- Stephen Long     02/10/2022 Removed unneeded joins on the disease fields.
-- Stephen Long     03/10/2022 Added note field to the query.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     09/28/2022 Bug fix on item 5111, 5112, 5113 and 5114.
-- Stephen Long     10/17/2022 Bug fix on item 5018 - searching by dates.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     10/24/2022 Bug fix on GIT #464.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/14/2023 Updated for site filtration queries.
-- Stephen Long     01/23/2023 Updated default sort order.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_FAVORITE_SEARCH_GETList]
		@LanguageID = N'en-US',
		@SearchString = N'COVID', -- Use 'Gnhnscvxb', 'Blood', 'XWEB00' as other tests.
		@TestUnassignedIndicator = NULL,
		@TestCompletedIndicator = NULL,
		@UserID = 161287150000872, -- rykermase
		@UserOrganizationID = 758210000000,
		@Page = 1,
		@PageSize = 10,
		@SortColumn = N'EIDSSLaboratorySampleID',
		@SortOrder = N'DESC'

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_FAVORITE_SEARCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @SearchString NVARCHAR(2000),
    @AccessionedIndicator BIT = NULL,
    @UserID BIGINT,
    @UserEmployeeID BIGINT, 
    @UserOrganizationID BIGINT,
    @UserSiteID BIGINT 
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );

    DECLARE @MonitoringSessionDiseases TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @VectorSessionDiseases TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @InitialResults TABLE
    (
        ID INT NOT NULL IDENTITY,
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL
    );
    DECLARE @Results TABLE
    (
        ID INT NOT NULL IDENTITY,
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL,
        BatchStatusTypeID BIGINT NULL,
        TestNameTypeID BIGINT NULL,
        TestNameTypeName NVARCHAR(MAX) NULL,
        TestStatusTypeID BIGINT NULL,
        TestStatusTypeName NVARCHAR(MAX) NULL,
        StartedDate DATETIME NULL,
        TestResultTypeID BIGINT NULL,
        TestResultTypeName NVARCHAR(MAX) NULL,
        ResultDate DATETIME NULL,
        TestCategoryTypeID BIGINT NULL,
        TestCategoryTypeName NVARCHAR(MAX) NULL,
        PreviousTestStatusID BIGINT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID INT NOT NULL IDENTITY,
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL,
        BatchStatusTypeID BIGINT NULL,
        TestNameTypeID BIGINT NULL,
        TestNameTypeName NVARCHAR(MAX) NULL,
        TestStatusTypeID BIGINT NULL,
        TestStatusTypeName NVARCHAR(MAX) NULL,
        StartedDate DATETIME NULL,
        TestResultTypeID BIGINT NULL,
        TestResultTypeName NVARCHAR(MAX) NULL,
        ResultDate DATETIME NULL,
        TestCategoryTypeID BIGINT NULL,
        TestCategoryTypeName NVARCHAR(MAX) NULL,
        PreviousTestStatusID BIGINT NULL
    );
    DECLARE @SampleTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @SampleStatusTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @AccessionConditionTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @TestNameTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @TestResultTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @TestCategoryTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @TestStatusTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @Diseases TABLE (ID BIGINT NOT NULL);
    DECLARE @FunctionalAreas TABLE (ID BIGINT NOT NULL);
    DECLARE @Favorites XML,
            @LanguageCode BIGINT;
    BEGIN TRY
        INSERT INTO @UserGroupSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       3
                   ELSE
                       2
               END
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = egm.idfEmployeeGroup;

        INSERT INTO @UserSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       5
                   ELSE
                       4
               END
        FROM dbo.tstObjectAccess oa
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = @UserEmployeeID;

        SET @LanguageCode = dbo.FN_GBL_LanguageCode_Get(@LanguageID);
        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        INSERT INTO @MonitoringSessionDiseases
        SELECT MonitoringSessionID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, '|') AS DiseaseNames,
               REPLACE(STRING_AGG(DiseaseName, '|'), '|', ', ') AS DisplayDiseaseNames
        FROM dbo.FN_LAB_MONITORING_SESSION_DISEASES_GET(@LanguageID)
        GROUP BY MonitoringSessionID;

        INSERT INTO @VectorSessionDiseases
        SELECT VectorSurveillanceSessionID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, '|') AS DiseaseNames,
               REPLACE(STRING_AGG(DiseaseName, '|'), '|', ', ') AS DisplayDiseaseNames
        FROM dbo.FN_LAB_VECTOR_SESSION_DISEASES_GET(@LanguageID)
        GROUP BY VectorSurveillanceSessionID;

        INSERT INTO @InitialResults
        SELECT m.idfMaterial,
               NULL
        FROM dbo.tlbMaterial m
            INNER JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
        WHERE m.intRowStatus = 0;

        INSERT INTO @SampleTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000087
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @SampleStatusTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000015
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @AccessionConditionTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000110
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @Diseases
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000019
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @TestNameTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000097
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @TestResultTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000096
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @TestCategoryTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000095
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @TestStatusTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000001
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @FunctionalAreas
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000164
              AND snt.idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @Results
        SELECT SampleID,
               t.idfTesting,
               b.idfsBatchStatus,
               t.idfsTestName,
               testNameType.name,
               t.idfsTestStatus,
               testStatusType.name,
               t.datStartedDate,
               t.idfsTestResult,
               testResultType.name,
               t.datConcludedDate,
               t.idfsTestCategory,
               testCategoryType.name,
               t.PreviousTestStatusID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
        WHERE (
                  m.blnAccessioned = @AccessionedIndicator
                  AND m.idfsSampleStatus IS NULL
                  AND m.datAccession IS NULL 
                  AND m.datDestructionDate IS NULL
                  AND @AccessionedIndicator IS NOT NULL
              ) -- Un-accessioned samples
              OR (
                     CONVERT(NVARCHAR(MAX), FORMAT(m.datAccession, 'g', @LanguageID)) LIKE '%' + @SearchString + '%'
                     OR CONVERT(NVARCHAR(MAX), FORMAT(t.datStartedDate, 'd', @LanguageID)) LIKE '%' + @SearchString
                                                                                                + '%'
                     OR CONVERT(NVARCHAR(MAX), FORMAT(t.datConcludedDate, 'd', @LanguageID)) LIKE '%' + @SearchString
                                                                                                  + '%'
                     OR (
                            m.strBarcode IS NOT NULL
                            AND m.strBarcode <> ''
                            AND m.strBarcode LIKE '%' + @SearchString + '%'
                        )
                     OR (
                            m.strFieldBarcode IS NOT NULL
                            AND m.strFieldBarcode <> ''
                            AND m.strFieldBarcode LIKE '%' + @SearchString + '%'
                        )
                     OR (
                            m.strCondition IS NOT NULL
                            AND m.strCondition <> ''
                            AND m.strCondition LIKE '%' + @SearchString + '%'
                        )
                     OR (
                            m.strCalculatedCaseID IS NOT NULL
                            AND m.strCalculatedCaseID <> ''
                            AND m.strCalculatedCaseID LIKE '%' + @SearchString + '%'
                        )
                     OR (
                            m.strCalculatedHumanName IS NOT NULL
                            AND m.strCalculatedHumanName <> ''
                            AND m.strCalculatedHumanName LIKE '%' + @SearchString + '%'
                        )
                 );

        INSERT INTO @Results
        SELECT SampleID,
               t.idfTesting,
               b.idfsBatchStatus,
               t.idfsTestName,
               testNameType.name,
               t.idfsTestStatus,
               testStatusType.name,
               t.datStartedDate,
               t.idfsTestResult,
               testResultType.name,
               t.datConcludedDate,
               t.idfsTestCategory,
               testCategoryType.name,
               t.PreviousTestStatusID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
            INNER JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
        WHERE m.idfAnimal IS NOT NULL
              AND a.strAnimalCode LIKE '%' + @SearchString + '%';

        INSERT INTO @Results
        SELECT SampleID,
               TestID,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL
        FROM @InitialResults
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = SampleID
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
        WHERE tro.strBarcode LIKE '%' + @SearchString + '%';

        IF
        (
            SELECT COUNT(*) FROM @SampleTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE EXISTS
            (
                SELECT ID FROM @SampleTypes WHERE m.idfsSampleType = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @SampleStatusTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE EXISTS
            (
                SELECT ID FROM @SampleStatusTypes WHERE m.idfsSampleStatus = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @AccessionConditionTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE (
                      m.idfsSampleStatus IS NULL
                      OR m.idfsSampleStatus = 10015007
                  ) --In Repository
                  AND EXISTS
            (
                SELECT ID
                FROM @AccessionConditionTypes
                WHERE m.idfsAccessionCondition = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @TestNameTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE EXISTS
            (
                SELECT ID FROM @TestNameTypes WHERE t.idfsTestName = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @TestResultTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE EXISTS
            (
                SELECT ID FROM @TestResultTypes WHERE t.idfsTestResult = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @TestCategoryTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE EXISTS
            (
                SELECT ID FROM @TestCategoryTypes WHERE t.idfsTestCategory = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @TestStatusTypes
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE EXISTS
            (
                SELECT ID FROM @TestStatusTypes WHERE t.idfsTestStatus = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @FunctionalAreas
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                INNER JOIN dbo.tlbDepartment d
                    ON d.idfDepartment = m.idfInDepartment
                       AND d.intRowStatus = 0
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE m.idfInDepartment IS NOT NULL
                  AND EXISTS
            (
                SELECT ID FROM @FunctionalAreas WHERE d.idfsDepartmentName = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @Diseases
        ) > 0
        BEGIN
            INSERT INTO @Results
            SELECT SampleID,
                   t.idfTesting,
                   b.idfsBatchStatus,
                   t.idfsTestName,
                   testNameType.name,
                   t.idfsTestStatus,
                   testStatusType.name,
                   t.datStartedDate,
                   t.idfsTestResult,
                   testResultType.name,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   testCategoryType.name,
                   t.PreviousTestStatusID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnNonLaboratoryTest = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
            WHERE m.DiseaseID IS NOT NULL
                  AND EXISTS
            (
                SELECT ID FROM @Diseases WHERE m.DiseaseID = ID
            );

            INSERT INTO @FinalResults
            SELECT ir.SampleID,
                   ir.TestID,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL
            FROM @InitialResults ir
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ir.SampleID
                INNER JOIN @VectorSessionDiseases vsDiseases
                    ON vsDiseases.ID = m.idfVectorSurveillanceSession
            WHERE m.idfVectorSurveillanceSession IS NOT NULL
                  AND m.DiseaseID IS NULL
                  AND EXISTS
            (
                SELECT ID
                FROM @Diseases
                WHERE ID IN (
                                SELECT CAST([Value] AS BIGINT)
                                FROM dbo.FN_GBL_SYS_SplitList(vsDiseases.DiseaseIdentifiers, NULL, ',')
                            )
            );

            INSERT INTO @Results
            SELECT SampleID,
                   TestID,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = m.idfMonitoringSession
                       AND ms.intRowStatus = 0
                INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                       AND msd.intRowStatus = 0
            WHERE m.idfMonitoringSession IS NOT NULL
                  AND m.DiseaseID IS NULL
                  AND EXISTS
            (
                SELECT ID FROM @Diseases WHERE msd.idfsDiagnosis = ID
            );
        END;

        INSERT INTO @FinalResults
        SELECT SampleID,
               TestID,
               BatchStatusTypeID,
               TestNameTypeID,
               TestNameTypeName,
               TestStatusTypeID,
               TestStatusTypeName,
               StartedDate,
               TestResultTypeID,
               TestResultTypeName,
               ResultDate,
               TestCategoryTypeID,
               TestCategoryTypeName,
               PreviousTestStatusID
        FROM @Results
        GROUP BY SampleID,
                 TestID,
                 BatchStatusTypeID,
                 TestNameTypeID,
                 TestNameTypeName,
                 TestStatusTypeID,
                 TestStatusTypeName,
                 StartedDate,
                 TestResultTypeID,
                 TestResultTypeName,
                 ResultDate,
                 TestCategoryTypeID,
                 TestCategoryTypeName,
                 PreviousTestStatusID;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @FinalResults
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = m.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE m.intRowStatus = 0
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        DELETE res
        FROM @FinalResults res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS (
                              SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
              );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @FinalResults
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        DECLARE @FavoriteCount AS INT = (
                                            SELECT COUNT(*)
                                            FROM @FinalResults r
                                                INNER JOIN
                                                (
                                                    SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                                                    FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
                                                ) f
                                                    ON r.SampleID = f.SampleID
                                        );

        SELECT m.idfMaterial AS SampleID,
               m.idfsSite AS SiteID,
               m.idfsCurrentSite AS CurrentSiteID,
               res.TestID AS TestID,
               tom.idfTransferOut AS TransferID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.idfsSampleType AS SampleTypeID,
               sampleType.name AS SampleTypeName,
               CASE
                   WHEN m.DiseaseID IS NOT NULL THEN
                       CAST(m.DiseaseID AS NVARCHAR(MAX))
                   WHEN (NOT ISNULL(m.idfMonitoringSession, '') = '') THEN
                       msDiseases.DiseaseIdentifiers
                   WHEN
                   (
                       m.DiseaseID IS NULL
                       AND ISNULL(m.idfVectorSurveillanceSession, '') = ''
                   ) THEN
                       vsDiseases.DiseaseIdentifiers
                   ELSE
                       ''
               END AS DiseaseID,
               CASE
                   WHEN m.DiseaseID IS NOT NULL THEN
                       diseaseName.name
                   WHEN (NOT ISNULL(m.idfMonitoringSession, '') = '') THEN
                       msDiseases.DiseaseNames
                   WHEN
                   (
                       m.DiseaseID IS NULL
                       AND ISNULL(m.idfVectorSurveillanceSession, '') = ''
                   ) THEN
                       vsDiseases.DiseaseNames
                   ELSE
                       ''
               END AS DiseaseName,
               CASE
                   WHEN m.DiseaseID IS NOT NULL THEN
                       diseaseName.name
                   WHEN (NOT ISNULL(m.idfMonitoringSession, '') = '') THEN
                       msDiseases.DisplayDiseaseNames
                   WHEN
                   (
                       m.DiseaseID IS NULL
                       AND ISNULL(m.idfVectorSurveillanceSession, '') = ''
                   ) THEN
                       vsDiseases.DisplayDiseaseNames
                   ELSE
                       ''
               END AS DisplayDiseaseName,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               m.datFieldCollectionDate AS CollectionDate,
               m.idfFieldCollectedByPerson AS CollectedByPersonID,
               m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
               m.datFieldSentDate AS SentDate,
               m.idfSendToOffice AS SentToOrganizationID,
               TestNameTypeID,
               TestNameTypeName,
               TestStatusTypeID,
               TestStatusTypeName,
               StartedDate,
               TestResultTypeID,
               TestResultTypeName,
               ResultDate,
               TestCategoryTypeID,
               TestCategoryTypeName,
               m.blnAccessioned AS AccessionIndicator,
               m.datAccession AS AccessionDate,
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.idfSubdivision AS FreezerSubdivisionID,
               m.StorageBoxPlace,
               m.datEnteringDate AS EnteredDate,
               m.datOutOfRepositoryDate AS OutOfRepositoryDate,
               m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
               m.blnReadOnly AS ReadOnlyIndicator,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               m.idfsSampleStatus AS SampleStatusTypeID,
               CASE
                   WHEN m.blnAccessioned = 0
                        AND m.idfsSampleStatus IS NULL
                        AND m.idfsAccessionCondition IS NULL THEN
                       'Un-accessioned'
                   WHEN m.idfsSampleStatus IS NULL THEN
                       accessionConditionType.name
                   WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                       accessionConditionType.name
                   ELSE
                       sampleStatusType.name
               END AS AccessionConditionOrSampleStatusTypeName,
               m.idfAccesionByPerson AS AccessionedInByPersonID,
               m.datSampleStatusDate AS SampleStatusDate,
               m.strCondition AS AccessionComment,
               m.strNote AS Comment,
               a.strAnimalCode AS EIDSSAnimalID,
               m.idfsBirdStatus AS BirdStatusTypeID,
               m.idfMainTest AS MainTestID,
               m.idfsSampleKind AS SampleKindTypeID,
               BatchStatusTypeID,
               ISNULL(   IIF(
                            (
                                SELECT COUNT(t3.idfTesting)
                                FROM dbo.tlbTesting t3
                                WHERE t3.idfsTestStatus IN (   10001003,
                                                                        --In Progress
                                                               10001004 --Preliminary
                                                           )
                                      AND t3.idfMaterial = m.idfMaterial
                                      AND t3.intRowStatus = 0
                                      AND t3.blnNonLaboratoryTest = 0
                            ) > 0,
                            1,
                            0),
                         0
                     ) AS TestAssignedIndicator,
               CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
               THEN
                       m.idfsSampleStatus
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
               THEN
                       m.idfsSampleStatus
                   WHEN TestStatusTypeID = 10001004 --Preliminary
               THEN
                       TestStatusTypeID
                   WHEN TestStatusTypeID = 10001008 --Marked for Deletion
               THEN
                       TestStatusTypeID
               END AS ActionRequestedID,
               CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
               THEN
                       'Sample Deletion'
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
               THEN
                       'Sample Destruction'
                   WHEN TestStatusTypeID = 10001004 --Preliminary
               THEN
                       'Validation'
                   WHEN TestStatusTypeID = 19000502 --Marked for Deletion
               THEN
                       'Test Deletion'
               END AS ActionRequested,
               ISNULL(   IIF(
                            (
                                SELECT COUNT(t2.idfTesting)
                                FROM dbo.tlbTesting t2
                                WHERE t2.idfsTestStatus IN (   10001001,
                                                                        --Final
                                                               10001006 --Amended
                                                           )
                                      AND t2.idfMaterial = m.idfMaterial
                                      AND t2.intRowStatus = 0
                                      AND t2.blnNonLaboratoryTest = 0
                            ) > 0,
                            1,
                            0),
                         0
                     ) AS TestCompletedIndicator,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               PreviousTestStatusID AS PreviousTestStatusTypeID,
               m.LabModuleSourceIndicator,
               m.idfHumanCase AS HumanDiseaseReportID,
               m.idfVetCase AS VeterinaryDiseaseReportID,
               m.idfMonitoringSession AS MonitoringSessionID,
               m.idfVectorSurveillanceSession AS VectorSessionID,
               m.idfVector AS VectorID,
               1 AS ReadPermissionIndicator,
               1 AS AccessToPersonalDataPermissionIndicator,
               1 AS AccessToGenderAndAgeDataPermissionIndicator,
               1 AS WritePermissionIndicator,
               1 AS DeletePermissionIndicator,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               COUNT(*) OVER () AS TotalRowCount,
               @FavoriteCount AS FavoriteCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            ORDER BY m.blnAccessioned,
                     m.idfsSampleStatus DESC,
                     m.idfsAccessionCondition,
                     COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate) DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
