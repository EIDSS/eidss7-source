-- ================================================================================================
-- Name: USP_LAB_TRANSFER_SEARCH_GETList
--
-- Description:	Get laboratory transfer list for the various laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/21/2019 Initial release.
-- Stephen Long     07/09/2019 Added disease to wildcard search.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     10/21/2019 Added accession indicator and test status type ID to the list of 
--                             fields.
-- Stephen Long     01/22/2020 Added site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/07/2020 Added test name type ID to the model.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     05/06/2020 Added test started date and test category type name to the model.
-- Stephen Long     06/07/2020 Added additional search fields to the where clause.
-- Stephen Long     06/24/2020 Added external test check to the test left join.
-- Stephen Long     11/29/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2021 Moved pagination to table variable insert.
-- Stephen Long     01/05/2021 Removed sent to organization where criteria.
-- Stephen Long     01/07/2021 Removed leading wildcard (%) as full table scans are performed even 
--                             with indices resulting in long query run times.  Recommend NOT 
--                             putting those back in.
-- Mark Wilson		08/17/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/23/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     02/10/2022 Replaced joins for monitoring session and vector session
--                             disease references to improve performance.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/04/2022 Add where criteria from the default sample listing, so only
--                             records for the simple search are filtered from the default set.
-- Stephen Long     09/28/2022 Bug fix on item 5111.
-- Stephen Long     10/14/2022 Changed monitoring session disease function to monitoring session
--                             to sample disease function.
-- Stephen Long     10/17/2022 Bug fix on item 5018 - searching by dates.
-- Stephen Long     10/18/2022 Added test disease ID to the query.
-- Stephen Long     10/24/2022 Fix for GIT item #46 - duplciate records comming back.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/14/2023 Updated for site filtration queries.
-- Stephen Long     03/14/2023 Fix on default sort order.
-- Stephen Long     03/29/2023 Fix on accession condition or sample status type name case.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TRANSFER_SEARCH_GETList]
		@LanguageID = N'en-US',
		@SearchString = N'COVID', -- Use 'Gnhnscvxb', 'Brucellosis', 'XWEB00' as other tests.
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
CREATE PROCEDURE [dbo].[USP_LAB_TRANSFER_SEARCH_GETList]
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

    DECLARE @InitialResults TABLE
    (
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL
    );
    DECLARE @DeduplicatedFinalResults TABLE
    (
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL
    );
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
    DECLARE @MonitoringSessionDiseases TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @VectorSessionDiseases TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL
    );
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
        SELECT SampleID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, '|') AS DiseaseNames
        FROM dbo.FN_LAB_MONITORING_SESSION_TO_SAMPLE_DISEASES_GET(@LanguageID)
        GROUP BY SampleID;

        INSERT INTO @VectorSessionDiseases
        SELECT VectorSurveillanceSessionID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, ';') AS DiseaseNames
        FROM dbo.FN_LAB_VECTOR_SESSION_DISEASES_GET(@LanguageID)
        GROUP BY VectorSurveillanceSessionID;

        INSERT INTO @InitialResults
        SELECT tr.idfTransferOut,
               tom.idfMaterial
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
        WHERE (
                  tr.idfSendFromOffice = @UserOrganizationID
                  OR tr.idfSendToOffice = @UserOrganizationID
              )
              AND (tr.idfsTransferStatus IN (   10001003,
                                                         --In Progress
                                                10001006 --Amended
                                            )
                  )
              AND tr.intRowStatus = 0;

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
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
                   AND m.intRowStatus = 0
        WHERE (
                  m.blnAccessioned = @AccessionedIndicator
                  AND m.idfsAccessionCondition IS NULL
                  AND m.idfsSampleStatus IS NULL
                  AND @AccessionedIndicator IS NOT NULL
              ) -- Un-accessioned samples
              OR (
                     CONVERT(NVARCHAR(MAX), FORMAT(m.datAccession, 'g', @LanguageID)) LIKE '%' + @SearchString + '%'
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
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnExternalTest = 1
        WHERE CONVERT(NVARCHAR(MAX), FORMAT(t.datConcludedDate, 'd', @LanguageID)) LIKE '%' + @SearchString + '%';


        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = ID
        WHERE CONVERT(NVARCHAR(MAX), FORMAT(tr.datSendDate, 'd', @LanguageID)) LIKE '%' + @SearchString + '%';

        IF
        (
            SELECT COUNT(*) FROM @SampleTypes
        ) > 0
        BEGIN
            INSERT INTO @FinalResults
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
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
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
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
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
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
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnExternalTest = 1
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
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
                INNER JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                       AND t.intRowStatus = 0
                       AND t.blnExternalTest = 1
            WHERE EXISTS
            (
                SELECT ID FROM @TestResultTypes WHERE t.idfsTestResult = ID
            );
        END

        IF
        (
            SELECT COUNT(*) FROM @FunctionalAreas
        ) > 0
        BEGIN
            INSERT INTO @FinalResults
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
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
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                       AND m.intRowStatus = 0
            WHERE m.DiseaseID IS NOT NULL
                  AND EXISTS
            (
                SELECT ID FROM @Diseases WHERE m.DiseaseID = ID
            );

            INSERT INTO @FinalResults
            SELECT ir.ID,
                   ir.SampleID
            FROM @InitialResults ir
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ir.SampleID
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
            SELECT ID,
                   SampleID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = SampleID
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = m.idfMonitoringSession
                       AND ms.intRowStatus = 0
                INNER JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                       AND msd.intRowStatus = 0
            WHERE EXISTS
            (
                SELECT ID FROM @Diseases WHERE msd.idfsDiagnosis = ID
            );
        END

        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
        WHERE m.idfAnimal IS NOT NULL
              AND a.strAnimalCode LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = ID
        WHERE tr.strBarcode LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = ID
        WHERE tr.TestRequested LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = SampleID
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnExternalTest = 1
        WHERE t.strContactPerson LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = ID
            INNER JOIN dbo.FN_GBL_Institution_Min(@LanguageID) transferredFromOrganization
                ON transferredFromOrganization.idfOffice = tr.idfSendFromOffice
        WHERE transferredFromOrganization.AbbreviatedName LIKE '%' + @SearchString + '%';

        INSERT INTO @FinalResults
        SELECT ID,
               SampleID
        FROM @InitialResults
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = ID
            INNER JOIN dbo.FN_GBL_Institution_Min(@LanguageID) transferredToOrganization
                ON transferredToOrganization.idfOffice = tr.idfSendToOffice
        WHERE transferredToOrganization.AbbreviatedName LIKE '%' + @SearchString + '%';

        INSERT INTO @DeduplicatedFinalResults
        SELECT ID,
               SampleID
        FROM @FinalResults
        GROUP BY ID,
                 SampleID;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @DeduplicatedFinalResults
        WHERE EXISTS
        (
            SELECT tr.idfTransferOut
            FROM dbo.tlbTransferOUT tr
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = tr.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE tr.intRowStatus = 0
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
        FROM @DeduplicatedFinalResults res
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = tr.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003 -- Read permission
              AND NOT EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = tr.idfsSite
        );

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        DELETE FROM @DeduplicatedFinalResults
        WHERE EXISTS
        (
            SELECT tr.idfTransferOut
            FROM dbo.tlbTransferOUT tr
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = tr.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        DECLARE @InProgressCount INT = (
                                           SELECT COUNT(DISTINCT res.ID)
                                           FROM @DeduplicatedFinalResults res
                                               INNER JOIN dbo.tlbTransferOUT tr
                                                   ON tr.idfTransferOut = res.ID
                                           WHERE tr.idfsTransferStatus IN (   10001003, --In Progress
                                                                              10001006  --Amended
                                                                          )
                                       );

        SELECT tr.idfTransferOut AS TransferID,
               tr.strBarcode AS EIDSSTransferID,
               m.idfMaterial AS TransferredOutSampleID,
               (
                   SELECT TOP 1
                       idfMaterial
                   FROM dbo.tlbMaterial
                   WHERE idfRootMaterial = m.idfMaterial
                         AND intRowStatus = 0
                         AND idfsSampleKind = 12675430000000 --Transferred in
               ) AS TransferredInSampleID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.strBarcode AS EIDSSLaboratorySampleID,
               tr.idfSendToOffice AS TransferredToOrganizationID,
               transferredToOrganization.[FullName] AS TransferredToOrganizationName,
               tr.idfSendFromOffice AS TransferredFromOrganizationID,
               tr.datSendDate AS TransferDate,
               tr.TestRequested,
               t.idfTesting AS TestID,
               t.idfsTestName AS TestNameTypeID,
               testNameType.name AS TestNameTypeName,
               t.idfsTestResult AS TestResultTypeID,
               testResultType.name AS TestResultTypeName,
               t.idfsTestStatus AS TestStatusTypeID,
               testStatusType.name AS TestStatusTypeName,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsDiagnosis AS TestDiseaseID,
               t.datStartedDate AS StartedDate,
               t.datConcludedDate AS ResultDate,
               t.strContactPerson AS ContactPersonName,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
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
               m.datAccession AS AccessionDate,
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.blnAccessioned AS AccessionIndicator,
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
               tr.strNote AS PurposeOfTransfer,
               tr.idfsSite AS TransferredFromOrganizationSiteID,
               m.idfSendToOffice AS SentToOrganizationID,
               tr.idfSendByPerson AS SentByPersonID,
               tr.idfsTransferStatus AS TransferStatusTypeID,
               tr.intRowStatus AS RowStatus,
               a.strAnimalCode AS EIDSSAnimalID,
               CASE
                   WHEN m.TestUnassignedIndicator = 1 THEN
                       0
                   ELSE
                       1
               END AS TestAssignedIndicator,
               CASE
                   WHEN transferredToOrganization.idfsSite IS NULL THEN
                       1
                   ELSE
                       0
               END AS NonEIDSSLaboratoryIndicator,
               1 AS ReadPermissionIndicator,
               1 AS AccessToPersonalDataPermissionIndicator,
               1 AS AccessToGenderAndAgeDataPermissionIndicator,
               1 AS WritePermissionIndicator,
               1 AS DeletePermissionIndicator,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               @InProgressCount AS InProgressCount,
               COUNT(*) OVER () AS TotalRowCount
        FROM @DeduplicatedFinalResults res
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            INNER JOIN dbo.FN_GBL_Institution(@LanguageID) transferredToOrganization
                ON transferredToOrganization.idfOffice = tr.idfSendToOffice
                   AND transferredToOrganization.intRowStatus = 0
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnExternalTest = 1
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMaterial
                   AND m.idfMonitoringSession IS NOT NULL
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            ORDER BY tr.strBarcode DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
