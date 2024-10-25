-- ================================================================================================
-- Name: USP_LAB_TEST_SEARCH_GETList
--
-- Description:	Get laboratory tests list for the various lab use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/21/2019 Initial release.
-- Stephen Long     03/28/2019 Added EIDSS local/field sample ID field.
-- Stephen Long     04/27/2019 Added EIDSS batch ID, observation ID and batch status type name for 
--                             additional test information.
-- Stephen Long     07/09/2019 Added disease to wildcard search.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     01/22/2020 Added site list parameter for site filtration.
-- Stephen Long     02/03/2020 Added non-laboratory test indicator where clause.
-- Stephen Long     03/10/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     06/06/2020 Added batch status type ID to the model.
-- Stephen Long     06/07/2020 Added additional search fields to the where clause.
-- Stephen Long     10/28/2020 Added where criteria from the test get list.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2020 Moved pagination to table variable insert.
-- Stephen Long     01/05/2021 Removed sent to organization where criteria.
-- Stephen Long     01/07/2021 Removed leading wildcard (%) as full table scans are performed even 
--                             with indices resulting in long query run times.  Recommend NOT 
--                             putting those back in.
-- Stephen Long     09/24/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     12/08/2021 Changed pagination logic and removed optiont recompile.
-- Stephen Long     12/18/2021 Changed left to inner join on accession condition and sample 
--                             status types.
-- Stephen Long     07/26/2022 Changed from repair to reference repair function.
-- Stephen Long     08/04/2022 Add where criteria from the default testing listing, so only
--                             records for the simple search are filtered from the default set.
-- Stephen Long     09/28/2022 Bug fix on item 5111.
-- Stephen Long     10/17/2022 Bug fix on item 5018 - searching by dates.
-- Stephen Long     10/18/2022 Fix on external test indicator to use the field on the testing 
--                             table.
-- Stephen Long     10/21/2022 Added human disease report, veterinary disease report, monitoring 
--                             session and vector identifiers to the query.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/14/2023 Updated for site filtration queries.
-- Stephen Long     02/17/2023 Updated initial query where to use site ID instead of sent to 
--                             organization.
-- Stephen Long     03/15/2023 Fix on default sort order.
-- Stephen Long     03/29/2023 Fix on accession condition or sample status type name case.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TEST_SEARCH_GETList]
		@LanguageID = N'en-US',
		@SearchString = N'PCR', -- Use 'Gnhnscvxb', 'Brucellosis', 'SWAZ200GEDD' as other tests.
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
CREATE PROCEDURE [dbo].[USP_LAB_TEST_SEARCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @SearchString NVARCHAR(2000),
    @AccessionedIndicator BIT = NULL,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserOrganizationID BIGINT,
    @UserSiteID BIGINT,
    @DaysFromAccessionDate INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InProgressCount INT;
    DECLARE @InitialResults TABLE (ID BIGINT NOT NULL);
    DECLARE @FinalResults TABLE (ID BIGINT NOT NULL);
    DECLARE @FinalResultsDedup TABLE (ID BIGINT NOT NULL);
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

        INSERT INTO @InitialResults
        SELECT t.idfTesting
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.idfsTestName IS NOT NULL
              AND t.blnNonLaboratoryTest = 0
              AND (
                      (
                          m.idfsSite = @UserSiteID
                          AND m.idfsCurrentSite IS NULL
                      )
                      OR (m.idfsCurrentSite = @UserSiteID)
                  )
              AND (
                      GETDATE() <= DATEADD(DAY, @DaysFromAccessionDate, m.datAccession)
                      OR @DaysFromAccessionDate IS NULL
                  )
              AND (
                      (
                          t.idfBatchTest IS NULL
                          AND t.idfsTestStatus IN (   10001001, --Final
                                                      10001007, --Deleted
                                                      10001003, --In Progress
                                                      10001004, --Preliminary
                                                      10001006
                                                  ) --Amended
                      )
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001003 --In Progress
                             AND t.idfsTestStatus IN (   10001001, --Final 
                                                         10001003, -- In Progress
                                                         10001004, --Preliminary
                                                         10001006
                                                     ) --Amended
                         )
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001 --Closed
                             AND t.idfsTestStatus IN (   10001001, --Final 
                                                         10001003, -- In Progress
                                                         10001004, --Preliminary
                                                         10001006
                                                     ) --Amended
                         )
                  );

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

        INSERT INTO @FinalResults
        SELECT ID
        FROM @InitialResults
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
        WHERE (
                  m.blnAccessioned = @AccessionedIndicator
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
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

        INSERT INTO @FinalResults
        SELECT ID
        FROM @InitialResults
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
            INNER JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
        WHERE m.idfAnimal IS NOT NULL
              AND a.strAnimalCode LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ID
        FROM @InitialResults
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
            WHERE (
                      m.idfsSampleStatus IS NULL
                      OR m.idfsSampleStatus = 10015007
                  ) --In Repository
                  AND EXISTS
            (
                SELECT ID FROM @SampleStatusTypes WHERE m.idfsSampleStatus = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @AccessionConditionTypes
        ) > 0
        BEGIN
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
            WHERE EXISTS
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                INNER JOIN dbo.tlbDepartment d
                    ON d.idfDepartment = m.idfInDepartment
                       AND d.intRowStatus = 0
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
            INSERT INTO @FinalResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = ID
            WHERE t.idfsDiagnosis IS NOT NULL
                  AND EXISTS
            (
                SELECT ID FROM @Diseases WHERE t.idfsDiagnosis = ID
            );
        END

        INSERT INTO @FinalResultsDedup
        SELECT *
        FROM @FinalResults;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @FinalResultsDedup
        WHERE EXISTS
        (
            SELECT t.idfTesting
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
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
            WHERE t.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup -- Default role
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        DELETE res
        FROM @FinalResultsDedup res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
        );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @FinalResultsDedup
        WHERE EXISTS
        (
            SELECT t.idfTesting
            FROM dbo.tlbTesting t
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @InProgressCount =
        (
            SELECT COUNT(*)
            FROM @FinalResultsDedup res
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.ID
                       AND t.intRowStatus = 0
                LEFT JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = t.idfBatchTest
                       AND b.intRowStatus = 0
            WHERE (t.idfsTestStatus = 10001003)
                  AND (t.idfsTestName IS NOT NULL)
                  AND (t.blnNonLaboratoryTest = 0)
                  AND (
                          (
                              t.idfBatchTest IS NULL
                              AND (
                                      t.idfsTestStatus = 10001001 --Final
                                      OR t.idfsTestStatus = 10001003 --In Progress
                                      OR t.idfstestStatus = 10001006 --Amended
                                  )
                          )
                          OR (
                                 t.idfBatchTest IS NOT NULL
                                 AND b.idfsBatchStatus = 10001003 --In Progress
                                 AND (
                                         t.idfsTestStatus = 10001001 --Final 
                                         OR t.idfstestStatus = 10001006 --Amended
                                     )
                             )
                          OR (
                                 t.idfBatchTest IS NOT NULL
                                 AND b.idfsBatchStatus = 10001001 --Closed
                                 AND (
                                         t.idfsTestStatus = 10001001 --Final
                                         OR t.idfsTestStatus = 10001003 --In Progress
                                         OR t.idfsTestStatus = 10001004 --Preliminary
                                         OR t.idfstestStatus = 10001006 --Amended
                                     )
                             )
                      )
        );

        SELECT t.idfTesting AS TestID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.idfsSite AS SiteID,
               m.idfsCurrentSite AS CurrentSiteID,
               t.idfsTestName AS TestNameTypeID,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsTestResult AS TestResultTypeID,
               t.idfsTestStatus AS TestStatusTypeID,
               t.PreviousTestStatusID AS PreviousTestStatusTypeID,
               t.idfsDiagnosis AS DiseaseID,
               m.idfMaterial AS SampleID,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               m.idfSendToOffice AS SentToOrganizationID,
               t.idfBatchTest AS BatchTestID,
               t.idfObservation AS ObservationID,
               t.intTestNumber AS TestNumber,
               t.strNote AS Note,
               t.datStartedDate AS StartedDate,
               t.datConcludedDate AS ResultDate,
               t.idfTestedByOffice AS TestedByOrganizationID,
               t.idfTestedByPerson AS TestedByPersonID,
               t.idfResultEnteredByOffice AS ResultEnteredByOrganizationID,
               t.idfResultEnteredByPerson AS ResultEnteredByPersonID,
               t.idfValidatedByOffice AS ValidatedByOrganizationID,
               t.idfValidatedByPerson AS ValidatedByPersonID,
               t.blnReadOnly AS ReadOnlyIndicator,
               t.blnNonLaboratoryTest AS NonLaboratoryTestIndicator,
               t.blnExternalTest AS ExternalTestIndicator,
               t.idfPerformedByOffice AS PerformedByOrganizationID,
               t.datReceivedDate AS ReceivedDate,
               t.strContactPerson AS ContactPersonName,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               sampleType.name AS SampleTypeName,
               disease.name AS DiseaseName,
               m.strBarcode AS EIDSSLaboratorySampleID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               testNameType.name AS TestNameTypeName,
               testStatusType.name AS TestStatusTypeName,
               testResultType.name AS TestResultTypeName,
               testCategoryType.name AS TestCategoryTypeName,
               m.datAccession AS AccessionDate,
               functionalArea.name AS FunctionalAreaName,
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
               m.strCondition AS AccessionComment,
               a.strAnimalCode AS EIDSSAnimalID,
               ISNULL(
               (
                   SELECT COUNT(NULLIF(tom2.idfTransferOUT, 0))
                   FROM dbo.tlbTransferOutMaterial tom2
                   WHERE tom2.idfMaterial = m.idfMaterial
                         AND tom2.intRowStatus = 0
               ),
               0
                     ) AS TransferCount,
               tro.idfTransferOut AS TransferID,
               t.idfHumanCase AS HumanDiseaseReportID,
               t.idfVetCase AS VeterinaryDiseaseReportID,
               t.idfMonitoringSession AS MonitoringSessionID,
               t.idfVector AS VectorID,
               t.intRowStatus AS RowStatus,
               1 AS ReadPermissionIndicator,
               1 AS AccessToPersonalDataPermissionIndicator,
               1 AS AccessToGenderAndAgeDataPermissionIndicator,
               1 AS WritePermissionIndicator,
               1 AS DeletePermissionIndicator,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               COUNT(*) OVER () AS TotalRowCount,
               @InProgressCount AS InProgressCount
        FROM @FinalResultsDedup res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = t.idfsDiagnosis
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
            ORDER BY m.strBarcode DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
