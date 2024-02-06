-- ================================================================================================
-- Name: USP_LAB_APPROVAL_SEARCH_GETList
--
-- Description:	Get laboratory approval list for the various lab use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/21/2019 Initial release.
-- Stephen Long     07/09/2019 Added disease to search wildcard.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     01/21/2020 Converted site ID to site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     06/07/2020 Added additional search fields to the where clause.
-- Stephen Long     09/04/2020 Updated reference value for marked for deletion test status.
-- Stephen Long     11/30/2020 Modified where clause to look at sent to organization and removed 
--                             user ID as a parameter.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2021 Moved pagination to table variable insert.
-- Stephen Long     01/05/2021 Changed where criteria strNote to strCondition.
-- Stephen Long     01/07/2021 Removed leading wildcard (%) as full table scans are performed even 
--                             with indices resulting in long query run times.  Recommend NOT 
--                             putting those back in.
-- Stephen Long     09/24/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     11/18/2021 Added action requested ID to the query.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     12/17/2021 Added group by to eliminate duplicate records.
-- Stephen Long     01/03/2022 Corrected sample status type to use the correct field.
-- Stephen Long     02/10/2022 Removed unneeded joins on the disease fields.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     09/28/2022 Bug fix on item 5111, 5115 and 5116.
-- Stephen Long     10/11/2022 Added check for closed batch test status to display test records 
--                             ready for validation.
-- Stephen Long     10/17/2022 Bug fix on item 5018 - searching by dates.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     10/23/2022 Added check for non-laboratory test indicator of false.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/14/2023 Updated for site filtration queries.
-- Stephen Long     03/29/2023 Fix on accession condition or sample status type name case.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_APPROVAL_SEARCH_GETList]
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
CREATE PROCEDURE [dbo].[USP_LAB_APPROVAL_SEARCH_GETList]
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
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @VectorSessionDiseases TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL,
        DisplayDiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @InitialResults TABLE
    (
        ID INT NOT NULL IDENTITY,
        ActionRequested NVARCHAR(MAX) NOT NULL,
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID INT NOT NULL IDENTITY,
        ActionRequested NVARCHAR(MAX) NOT NULL,
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL
    );
    DECLARE @FinalResultsDedup TABLE
    (
        SampleID BIGINT NOT NULL,
        TestID BIGINT NULL
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
            @LanguageCode BIGINT,
            @TotalRowCount INT = 0,
            @SampleDeletion NVARCHAR(MAX),
            @SampleDestruction NVARCHAR(MAX),
            @TestDeletion NVARCHAR(MAX),
            @Validation NVARCHAR(MAX);
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
        SET @SampleDeletion =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 812
        );
        SET @SampleDestruction =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 1040
        );
        SET @TestDeletion =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 4493
        );
        SET @Validation =
        (
            SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 4492
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
        SELECT CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
            THEN
                       @SampleDeletion
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
            THEN
                       @SampleDestruction
               END,
               m.idfMaterial,
               NULL
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND (
                      m.idfsSampleStatus = 10015002 --Marked for Deletion 
                      OR m.idfsSampleStatus = 10015003 --Marked for Destruction
                  )
              AND m.idfSendToOffice = @UserOrganizationID;

        INSERT INTO @InitialResults
        SELECT CASE
                   WHEN t.idfsTestStatus = 10001004 --Preliminary
            THEN
                       @Validation
                   WHEN t.idfsTestStatus = 10001008 --Marked for Deletion
            THEN
                       @TestDeletion
               END,
               m.idfMaterial,
               t.idfTesting
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON t.idfMaterial = m.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND (
                      t.idfsTestStatus = 10001004 --Preliminary 
                      OR t.idfsTestStatus = 10001008 --Marked for Deletion 
                  )
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfSendToOffice = @UserOrganizationID;

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
              AND idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @FinalResults
        SELECT ActionRequested,
               SampleID,
               TestID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = SampleID
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
                     OR (ActionRequested LIKE '%' + @SearchString + '%')
                 );

        INSERT INTO @FinalResults
        SELECT ActionRequested,
               SampleID,
               TestID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = SampleID
            INNER JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
        WHERE m.idfAnimal IS NOT NULL
              AND a.strAnimalCode LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ActionRequested,
               SampleID,
               TestID
        FROM @InitialResults
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = SampleID
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
            INSERT INTO @FinalResults
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
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
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
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
            INSERT INTO @FinalResults
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
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
            SELECT COUNT(*) FROM @FunctionalAreas
        ) > 0
        BEGIN
            INSERT INTO @FinalResults
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = SampleID
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
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
            WHERE m.DiseaseID IS NOT NULL
                  AND EXISTS
            (
                SELECT ID FROM @Diseases WHERE m.DiseaseID = ID
            );

            INSERT INTO @FinalResults
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                INNER JOIN @VectorSessionDiseases vsDiseases
                    ON vsDiseases.ID = m.idfVectorSurveillanceSession
            WHERE m.idfVectorSurveillanceSession IS NOT NULL
                  AND EXISTS
            (
                SELECT ID
                FROM @Diseases
                WHERE ID IN (
                                SELECT CAST([Value] AS BIGINT)
                                FROM dbo.FN_GBL_SYS_SplitList(vsDiseases.DiseaseIdentifiers, NULL, ',')
                            )
            );

            INSERT INTO @FinalResults
            SELECT ActionRequested,
                   SampleID,
                   TestID
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
        END

        IF
        (
            SELECT COUNT(*) FROM @TestNameTypes
        ) > 0
        BEGIN
            INSERT INTO @FinalResults
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = TestID
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
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = TestID
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
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = TestID
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
            SELECT ActionRequested,
                   SampleID,
                   TestID
            FROM @InitialResults
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = TestID
            WHERE EXISTS
            (
                SELECT ID FROM @TestStatusTypes WHERE t.idfsTestStatus = ID
            );
        END;

        INSERT INTO @FinalResultsDedup
        SELECT SampleID,
               TestID
        FROM @FinalResults
        GROUP BY SampleID,
                 TestID;

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

        DELETE res
        FROM @FinalResultsDedup res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS (
                              SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
              );

        DELETE FROM @FinalResultsDedup
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @TotalRowCount =
        (
            SELECT COUNT(*) FROM @FinalResultsDedup
        );

        SELECT CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
            THEN
                       m.idfsSampleStatus
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
            THEN
                       m.idfsSampleStatus
                   WHEN t.idfsTestStatus = 10001004 --Preliminary
            THEN
                       t.idfsTestStatus
                   WHEN t.idfsTestStatus = 10001008 --Marked for Deletion
            THEN
                       t.idfsTestStatus
               END AS ActionRequestedID,
               CASE
                   WHEN m.idfsSampleStatus = 10015002 --Marked for Deletion
               THEN
                       @SampleDeletion
                   WHEN m.idfsSampleStatus = 10015003 --Marked for Destruction
               THEN
                       @SampleDestruction
                   WHEN t.idfsTestStatus = 10001004 --Preliminary
               THEN
                       @Validation
                   WHEN t.idfsTestStatus = 10001008 --Marked for Deletion
               THEN
                       @TestDeletion
               END AS ActionRequested,
               m.idfMaterial AS SampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               a.strAnimalCode AS EIDSSAnimalID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
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
               t.idfTesting AS TestID,
               t.idfsTestName AS TestNameTypeID,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsTestResult AS TestResultTypeID,
               t.idfsTestStatus AS TestStatusTypeID,
               testNameType.name AS TestNameTypeName,
               testStatusType.name AS TestStatusTypeName,
               testResultType.name AS TestResultTypeName,
               u.idfUserID AS ResultEnteredByUserID,
               m.datAccession AS AccessionDate,
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
               t.datConcludedDate AS ResultDate,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               NULL AS PreviousTestStatusTypeID,
               m.intRowStatus AS RowStatus,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               @TotalRowCount AS TotalRowCount
        FROM @FinalResultsDedup res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN dbo.tlbTesting t
                ON t.idfTesting = res.TestID
                   AND t.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tstUserTable u
                ON u.idfPerson = t.idfResultEnteredByPerson
                   AND u.intRowStatus = 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
