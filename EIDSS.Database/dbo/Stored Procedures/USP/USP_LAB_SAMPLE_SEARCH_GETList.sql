-- ================================================================================================
-- Name: USP_LAB_SAMPLE_SEARCH_GETList
--
-- Description:	Get sample search list for the laboratory module use case LUC13.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     01/14/2019 Initial release.
-- Stephen Long     01/30/2019 Removed joins to vector surveillance session, and added reference 
--                             to the disease reference table for the sample table.
-- Stephen Long     02/21/2019 Added organization ID parameter to narrow search.
-- Stephen Long     07/01/2019 Corrected reference type on monitoring session category.
-- Stephen Long     07/09/2019 Added disease to the wildcard search.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     08/18/2019 Removed herd left join and modified species left join to material 
--                             table.
-- Stephen Long     01/21/2020 Added site list for site filtration.
-- Stephen Long     03/09/2020 Added additional search filters to match the default get.
-- Stephen Long     03/10/2020 Removed filter on sample disease, and added disease report and 
--                             monitoring session ones.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     05/05/2020 Added transfer status type ID of final when sample status type ID 
--                             is transferred out.
-- Stephen Long     06/07/2020 Added additional search fields to the where clause.
-- Stephen Long     07/06/2020 Added lab module source indicator to the model.
-- Stephen Long     10/27/2020 Removed test assigned indicator, and split out queries for better 
--                             performance.
-- Stephen Long     10/30/2020 Added test unassigned and test completed indicators.
-- Stephen Long     10/31/2020 Correct disease report/session query where criteria; prevent dups.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2021 Moved pagination to table variable insert.
-- Stephen Long     01/05/2021 Changed over missed functions for reference data.
-- Stephen Long     01/07/2021 Removed leading wildcard (%) as full table scans are performed even 
--                             with indices resulting in long query run times.  Recommend NOT 
--                             putting those back in.
-- Stephen Long     06/28/2021 Applied new pagination parameters.
-- Stephen Long     09/20/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     12/06/2021 Correction to EIDSSReportOrSessionID alias name.
-- Stephen Long     12/14/2021 Added sample status date to the query.
-- Stephen Long     02/08/2022 Removed unneeded joins.
-- Stephen Long     02/17/2022 Fix on where criteria for test status types.
-- Stephen Long     03/10/2022 Changed note to comment and transfer count to transferred count.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Stephen Long     05/23/2022 Fix to show rejected samples on sample search.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/04/2022 Add where criteria from the default sample listing, so only
--                             records for the simple search are filtered from the default set.
-- Stephen Long     08/16/2022 Added null DaysFromAccessionDate to the where criteria.
-- Stephen Long     09/21/2022 Removed test status types of final and amended from the in 
--                             repository samples within the accession date window check.  Changed 
--                             rejected samples to use collection date or entered date against the 
--                             date window (number of days for samples to stay in the list).
-- Stephen Long     10/17/2022 Bug fix on item 5111 and 5018.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/03/2023 Added check for user's site identifier when the sent to organization 
--                             is not present.
-- Stephen Long     01/14/2023 Updated for site filtration queries.
-- Stephen Long     03/02/2023 Updated initial query where to use site ID instead of sent to 
--                             organization.
-- Stephen Long     03/14/2023 Fix on default sort order.
-- Stephen Long     03/28/2023 Bug fix for item 5818 and 5819.
-- Stephen Long     04/12/2023 Additional fix for 5818 and 5819.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_SAMPLE_SEARCH_GETList]
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
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_SEARCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @SearchString NVARCHAR(2000),
    @AccessionedIndicator BIT = NULL,
    @TestUnassignedIndicator BIT = NULL,
    @TestCompletedIndicator BIT = NULL,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserOrganizationID BIGINT,
    @UserSiteID BIGINT,
    @DaysFromAccessionDate INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InitialResults TABLE (ID BIGINT NOT NULL);
    DECLARE @FilteredResults TABLE (ID BIGINT NOT NULL);
    DECLARE @FinalResults TABLE (ID BIGINT NOT NULL);
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
    DECLARE @SampleTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @SampleStatusTypes TABLE (ID BIGINT NOT NULL);
    DECLARE @AccessionConditionTypes TABLE (ID BIGINT NOT NULL);
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

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        INSERT INTO @InitialResults
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 -- Unknown
              AND (
                      (
                          m.blnAccessioned = 0
                          AND m.idfsSampleStatus IS NULL
                          AND m.datAccession IS NULL
                          AND m.datDestructionDate IS NULL
                          AND m.idfSendToOffice = @UserOrganizationID
                      )
                      OR (
                             m.idfSendToOffice = @UserOrganizationID
                             AND m.idfsSite = @UserSiteID
                         )
                  )
              AND (
                      (
                          (
                              GETDATE() <= DATEADD(DAY, @DaysFromAccessionDate, m.datAccession)
                              OR @DaysFromAccessionDate IS NULL
                          )
                          AND m.TestUnassignedIndicator = 1
                          AND @TestUnassignedIndicator IS NOT NULL
                          AND m.blnAccessioned = 1
                          AND m.datAccession IS NOT NULL
                          AND m.strBarcode IS NOT NULL 
                          AND (m.idfsAccessionCondition IS NOT NULL AND m.idfsAccessionCondition <> 10108003) -- Rejected
                          AND m.idfsSampleStatus = 10015007 -- In Repository
                      )
                      OR (
                             (
                                 GETDATE() <= DATEADD(DAY, @DaysFromAccessionDate, m.datAccession)
                                 OR @DaysFromAccessionDate IS NULL
                             )
                             AND m.TestCompletedIndicator = 1
                             AND (m.idfsAccessionCondition IS NOT NULL AND m.idfsAccessionCondition <> 10108003) -- Rejected
                             AND @TestCompletedIndicator IS NOT NULL
                         )
                      OR (
                             m.blnAccessioned = 0
                             AND m.idfsAccessionCondition IS NULL
                             AND m.idfsSampleStatus IS NULL
                             AND @TestCompletedIndicator IS NULL
                             AND @TestUnassignedIndicator IS NULL
                         )
                      OR (
                             (
                                 GETDATE() <= DATEADD(DAY, @DaysFromAccessionDate, m.datAccession)
                                 OR @DaysFromAccessionDate IS NULL
                             )
                             AND
                             (
                                 SELECT COUNT(*)
                                 FROM dbo.tlbTesting t
                                 WHERE t.idfMaterial = m.idfMaterial
                                       AND t.intRowStatus = 0
                                       AND t.blnNonLaboratoryTest = 0
                                       AND t.idfsTestStatus IN ( 10001003, 10001004, 10001005 ) -- In Progress, Preliminary and Not Started
                             ) = 0
                             AND m.idfsSampleStatus <> 10015010 -- Transferred Out
                             AND @TestUnassignedIndicator IS NULL
                             AND @TestCompletedIndicator IS NULL
                         )
                      OR (
                             (
                                 GETDATE() <= DATEADD(DAY, @DaysFromAccessionDate, m.datAccession)
                                 OR @DaysFromAccessionDate IS NULL
                             )
                             AND m.idfsSampleStatus = 10015010 -- Transferred Out
                             AND
                             (
                                 SELECT COUNT(tr.idfTransferOut)
                                 FROM dbo.tlbTransferOutMaterial tom
                                     INNER JOIN dbo.tlbTransferOUT tr
                                         ON tr.idfTransferOut = tom.idfTransferOut
                                 WHERE tom.idfMaterial = m.idfMaterial
                                       AND tr.intRowStatus = 0
                                       AND tr.idfsTransferStatus = 10001003 -- Final
                             ) = 0
                             AND @TestCompletedIndicator IS NULL
                             AND @TestUnassignedIndicator IS NULL
                         ) -- Transferred Out and Final
                      OR (
                             GETDATE() <= DATEADD(
                                                     DAY,
                                                     @DaysFromAccessionDate,
                                                     COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate)
                                                 )
                             AND m.idfsAccessionCondition = 10108003 -- Rejected Sample
                             AND @TestCompletedIndicator IS NULL
                             AND @TestUnassignedIndicator IS NULL
                         )
                  )
        GROUP BY m.idfMaterial;

        INSERT INTO @SampleTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000087
              AND idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @SampleStatusTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000015
              AND idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @AccessionConditionTypes
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000110
              AND idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        INSERT INTO @Diseases
        SELECT snt.idfsBaseReference
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE strTextString LIKE '%' + @SearchString + '%'
              AND idfsReferenceType = 19000019
              AND idfsLanguage = @LanguageCode
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

        INSERT INTO @FilteredResults
        SELECT ID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = ID
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

        INSERT INTO @FilteredResults
        SELECT ID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = ID
            INNER JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
        WHERE m.idfAnimal IS NOT NULL
              AND a.strAnimalCode LIKE '%' + @SearchString + '%';

        INSERT INTO @FilteredResults
        SELECT ID
        FROM @InitialResults
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = ID
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
            INSERT INTO @FilteredResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ID
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
            INSERT INTO @FilteredResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ID
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
            INSERT INTO @FilteredResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ID
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
            INSERT INTO @FilteredResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ID
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
            INSERT INTO @FilteredResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ID
            WHERE m.DiseaseID IS NOT NULL
                  AND EXISTS
            (
                SELECT ID FROM @Diseases WHERE m.DiseaseID = ID
            );

            INSERT INTO @FilteredResults
            SELECT ID
            FROM @InitialResults
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = ID
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

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @FilteredResults
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
        FROM @FilteredResults res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
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
        DELETE FROM @FilteredResults
        WHERE EXISTS
        (
            SELECT m.idfMaterial
            FROM dbo.tlbMaterial m
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = m.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        INSERT INTO @FinalResults
        SELECT res.ID
        FROM @FilteredResults res
        GROUP BY res.ID;

        DECLARE @UnaccessionedSampleCount AS INT = (
                                                       SELECT COUNT(m.idfMaterial)
                                                       FROM @FinalResults res
                                                           INNER JOIN dbo.tlbMaterial m
                                                               ON m.idfMaterial = res.ID
                                                       WHERE (
                                                                 m.blnAccessioned = 0
                                                                 AND m.idfsAccessionCondition IS NULL
                                                             )
                                                   );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SELECT m.idfMaterial AS SampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               m.idfsSampleType AS SampleTypeID,
               sampleType.name AS SampleTypeName,
               m.idfHuman AS HumanID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.idfSpecies AS SpeciesID,
               m.idfAnimal AS AnimalID,
               a.strAnimalCode AS EIDSSAnimalID,
               m.idfVector AS VectorID,
               m.idfMonitoringSession AS MonitoringSessionID,
               m.idfVectorSurveillanceSession AS VectorSessionID,
               m.idfHumanCase AS HumanDiseaseReportID,
               m.idfVetCase AS VeterinaryDiseaseReportID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               ISNULL(   IIF(
                            (
                                SELECT COUNT(t2.idfTesting)
                                FROM dbo.tlbTesting t2
                                WHERE t2.idfsTestStatus IN (   10001001,
                                                                        -- Final
                                                               10001006 -- Amended
                                                           )
                                      AND t2.idfMaterial = m.idfMaterial
                                      AND t2.intRowStatus = 0
                                      AND t2.blnNonLaboratoryTest = 0
                            ) > 0,
                            1,
                            0),
                         0
                     ) AS TestCompletedIndicator,
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
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.idfSubdivision AS FreezerSubdivisionID,
               m.StorageBoxPlace,
               m.datFieldCollectionDate AS CollectionDate,
               m.idfFieldCollectedByPerson AS CollectedByPersonID,
               m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
               m.datFieldSentDate AS SentDate,
               m.idfSendToOffice AS SentToOrganizationID,
               m.idfsSite AS SiteID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               m.datEnteringDate AS EnteredDate,
               m.datOutOfRepositoryDate AS OutOfRepositoryDate,
               m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
               m.blnReadOnly AS ReadOnlyIndicator,
               m.blnAccessioned AS AccessionIndicator,
               m.datAccession AS AccessionDate,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               (CASE
                    WHEN m.blnAccessioned = 0
                         AND m.idfsAccessionCondition IS NULL THEN
                        'Un-accessioned'
                    WHEN m.idfsSampleStatus IS NULL THEN
                        accessionConditionType.name
                    WHEN m.idfsSampleStatus = 10015007 -- In Repository
               THEN
                        accessionConditionType.name
                    ELSE
                        sampleStatusType.name
                END
               ) AS AccessionConditionOrSampleStatusTypeName,
               m.idfAccesionByPerson AS AccessionByPersonID,
               m.idfsSampleStatus AS SampleStatusTypeID,
               m.datSampleStatusDate AS SampleStatusDate,
               m.strCondition AS AccessionComment,
               m.idfsDestructionMethod AS DestructionMethodTypeID,
               m.datDestructionDate AS DestructionDate,
               m.idfDestroyedByPerson AS DestroyedByPersonID,
               ISNULL(
               (
                   SELECT COUNT(NULLIF(t4.idfTesting, 0))
                   FROM dbo.tlbTesting t4
                   WHERE t4.idfsTestStatus IN (   10001003,
                                                           -- In Progress
                                                  10001004 -- Preliminary
                                              )
                         AND t4.idfMaterial = m.idfMaterial
                         AND t4.intRowStatus = 0
                         AND t4.blnNonLaboratoryTest = 0
               ),
               0
                     ) AS TestAssignedCount,
               ISNULL(
               (
                   SELECT COUNT(NULLIF(tom2.idfTransferOUT, 0))
                   FROM dbo.tlbTransferOutMaterial tom2
                   WHERE tom2.idfMaterial = m.idfMaterial
                         AND tom2.intRowStatus = 0
               ),
               0
                     ) AS TransferredCount,
               m.strNote AS Comment,
               m.idfsCurrentSite AS CurrentSiteID,
               m.idfsBirdStatus AS BirdStatusTypeID,
               m.idfMainTest AS MainTestID,
               m.idfsSampleKind AS SampleKindTypeID,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               m.LabModuleSourceIndicator,
               m.intRowStatus AS RowStatus,
               1 AS ReadPermissionIndicator,
               1 AS AccessToPersonalDataPermissionIndicator,
               1 AS AccessToGenderAndAgeDataPermissionIndicator,
               1 AS WritePermissionIndicator,
               1 AS DeletePermissionIndicator,
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               COUNT(*) OVER () AS TotalRowCount,
               @UnaccessionedSampleCount AS UnaccessionedSampleCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
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
            LEFT JOIN @MonitoringSessionDiseases msDiseases
                ON msDiseases.ID = m.idfMonitoringSession
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
        ORDER BY m.blnAccessioned,
                 m.idfsSampleStatus DESC,
                 m.idfsAccessionCondition,
                 COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate) DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
