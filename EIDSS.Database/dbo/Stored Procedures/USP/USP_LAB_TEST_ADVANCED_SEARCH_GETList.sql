-- ================================================================================================
-- Name: USP_LAB_TEST_ADVANCED_SEARCH_GETList
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
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     10/07/2019 Removed @CampaignID variable; just use EIDSSReportCampaignSessionID.
-- Stephen Long     01/22/2020 Converted site ID to site list for site filtration.
-- Stephen Long     02/03/2020 Added non-laboratory test indicator where clause.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/16/2020 Added test list parameter and where clause criteria.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     06/06/2020 Added batch status type ID to the model.
-- Stephen Long     08/25/2020 Added criteria to ignore time on date betweens.
-- Stephen Long     09/02/2020 Changed accessioned indicator from int to varchar to handle searches
--                             with un-accessioned and accessioned samples in the same query.
-- Stephen Long     10/30/2020 Remove unneeded joins.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/23/2020 Correction on accession indicator list where criteria.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2020 Added option recompile to select queries.
-- Stephen Long     01/21/2021 Changed counts to use group by in sub-query instead of count 
--                             distinct and added with recompile to handle number of nullable 
--                             parameters.
-- Stephen Long     01/24/2021 Correct where criteria on accession indicator list.
-- Mark Wilson		08/20/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     10/14/2021 Changed report or session type ID to bigint.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     12/15/2021 Added configurable filtration rules.
-- Stephen Long     03/24/2022 Removed primary key from final results table variable.
-- Mike Kornegay	06/14/2022 Added new additional SessionCategoryID for Vet Avian / Vet Livestock 
--                             breakout.
-- Stephen Long     07/26/2022 Changed from repair to reference repair function.
-- Stephen Long     08/09/2022 Added batch test association indicator parameter.
-- Stephen Long     08/12/2022 Removed where criteria for surveillance type of both; de-activated 
--                             base reference record.
-- Stephen Long     08/26/2022 Added additional checks on accession and entered date range checks.
-- Stephen Long     10/18/2022 Fix on external test indicator to use the field on the testing 
--                             table.
-- Stephen Long     10/21/2022 Added human disease report, veterinary disease report, monitoring 
--                             session and vector identifiers to the query.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/11/2023 Updated for site filtration queries.
-- Stephen Long     01/31/2023 Added coalesce on collection and entered dates.
-- Stephen Long     02/03/2023 Added filtration indicator logic.
-- Stephen Long     02/20/2023 Added sent to organization sent to site ID and where criteria.
-- Stephen Long     03/15/2023 Fix on default sort order.
-- Stephen Long     04/24/2023 Bug fix for item 5738.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_TEST_ADVANCED_SEARCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @ReportOrSessionTypeID BIGINT = NULL,
    @SurveillanceTypeID BIGINT = NULL,
    @SampleStatusTypeList VARCHAR(MAX) = NULL,
    @AccessionedIndicatorList VARCHAR(3) = NULL,
    @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
    @EIDSSReportCampaignOrSessionID NVARCHAR(200) = NULL,
    @SentToOrganizationID BIGINT = NULL,
    @SentToOrganizationSiteID BIGINT = NULL,
    @TransferredToOrganizationID BIGINT = NULL,
    @EIDSSTransferID NVARCHAR(200) = NULL,
    @ResultsReceivedFromID BIGINT = NULL,
    @DateFrom DATETIME = NULL,
    @DateTo DATETIME = NULL,
    @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
    @SampleTypeID BIGINT = NULL,
    @TestNameTypeID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @TestStatusTypeID BIGINT = NULL,
    @TestResultTypeID BIGINT = NULL,
    @TestResultDateFrom DATETIME = NULL,
    @TestResultDateTo DATETIME = NULL,
    @PatientName NVARCHAR(200) = NULL,
    @FarmOwnerName NVARCHAR(200) = NULL,
    @SpeciesTypeID BIGINT = NULL,
    @TestList VARCHAR(MAX) = NULL,
    @BatchTestAssociationIndicator BIT = NULL,
    @FiltrationIndicator BIT = 1,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteGroupID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
            @ReturnCode INT = 0;
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX c NONCLUSTERED,
        TestStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        TestStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        RowAction INT NOT NULL
            DEFAULT 0
    );
    DECLARE @NarrowResults TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        TestStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        RowAction INT NOT NULL
            DEFAULT 0
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
    DECLARE @SampleStatusTypeListTable TABLE (ID BIGINT NOT NULL PRIMARY KEY);
    DECLARE @Favorites XML;

    BEGIN TRY
        IF @SampleStatusTypeList IS NOT NULL
            INSERT INTO @SampleStatusTypeListTable
            SELECT CAST([Value] AS BIGINT)
            FROM dbo.FN_GBL_SYS_SplitList(@SampleStatusTypeList, NULL, ',');

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

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               1,
               CASE
                   WHEN m.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN m.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN m.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN m.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND (
                      (
                          (
                              m.idfSendToOffice = @SentToOrganizationID
                              OR @SentToOrganizationID IS NULL
                          )
                          AND (
                                  (
                                      m.blnAccessioned = @AccessionedIndicatorList
                                      OR (
                                             m.blnAccessioned = 1
                                             AND m.datAccession IS NULL
                                             AND @AccessionedIndicatorList IS NOT NULL
                                         )
                                  )
                                  AND m.idfsAccessionCondition IS NULL
                                  AND m.idfsSampleStatus IS NULL
                                  AND m.datDestructionDate IS NULL
                                  OR (
                                         @AccessionedIndicatorList IS NULL
                                         AND @SampleStatusTypeList IS NULL
                                     )
                              )
                      )
                      OR (
                             (
                                 (
                                     m.idfSendToOffice = @SentToOrganizationID
                                     AND m.idfsSite = @SentToOrganizationSiteID
                                 )
                                 OR @SentToOrganizationID IS NULL
                             )
                             AND (
                                     (m.idfsSampleStatus IN (
                                                                SELECT ID FROM @SampleStatusTypeListTable
                                                            )
                                     )
                                     OR (
                                            m.idfsAccessionCondition IN (
                                                                            SELECT ID FROM @SampleStatusTypeListTable
                                                                        )
                                            AND (
                                                    m.idfsSampleStatus IS NULL
                                                    OR m.idfsSampleStatus = 10015007 --In Repository
                                                )
                                        )
                                     OR (
                                            @SampleStatusTypeList IS NULL
                                            AND @AccessionedIndicatorList IS NULL
                                        )
                                 )
                         )
                  );

        -- =======================================================================================
        -- CONFIGURABLE FILTRATION RULES
        -- 
        -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                ON userSiteGroup.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup sgs
                ON sgs.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND sgs.idfsSite = m.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
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
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = m.idfsSite
        )
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT t.idfTesting,
               t.idfsTestStatus,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = m.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
        )
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE FROM @Results
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

        INSERT INTO @FinalResults
        SELECT res.ID,
               res.TestStatusTypeID,
               MAX(ReadPermissionIndicator),
               MAX(AccessToPersonalDataPermissionIndicator),
               MAX(AccessToGenderAndAgeDataPermissionIndicator),
               MAX(WritePermissionIndicator),
               MAX(DeletePermissionIndicator),
               0
        FROM @Results res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.ID
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = m.idfMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbSpecies species
                ON species.idfSpecies = m.idfSpecies
                   AND species.intRowStatus = 0
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      (
                          t.idfBatchTest IS NULL
                          AND t.idfsTestResult IS NULL
                          AND @BatchTestAssociationIndicator = 1
                      )
                      OR @BatchTestAssociationIndicator IS NULL
                  ) -- Adding a test to a batch, so should not currently be a batch test ID.
              AND (
                      (t.idfTesting IN (
                                           SELECT CAST([Value] AS BIGINT)
                                           FROM dbo.FN_GBL_SYS_SplitList(@TestList, NULL, ',')
                                       )
                      )
                      OR (@TestList IS NULL)
                  )
              AND (
                      (
                          @ReportOrSessionTypeID = 10012001 --Human Disease Report
                          AND (
                                  (m.idfHumanCase IS NOT NULL)
                                  OR (
                                         m.idfMonitoringSession IS NOT NULL
                                         AND ms.SessionCategoryID = 10502001 --Human Active Surveillance Session
                                     )
                              )
                      )
                      OR (
                             @ReportOrSessionTypeID = 10012006 --Vector Surveillance Session
                             AND m.idfVectorSurveillanceSession IS NOT NULL
                         )
                      OR (
                             @ReportOrSessionTypeID = 10012005 --Veterinary Disease Report
                             AND (
                                     (m.idfVetCase IS NOT NULL)
                                     OR (
                                            m.idfMonitoringSession IS NOT NULL
                                            AND ms.SessionCategoryID IN ( 10502002, 10502009 ) --Veterinary Active Surveillance Session
                                        )
                                 )
                         )
                      OR (@ReportOrSessionTypeID IS NULL)
                  )
              AND (
                      (
                          @SurveillanceTypeID = 4578940000001 --Active
                          AND (
                                  m.idfMonitoringSession IS NOT NULL
                                  OR m.idfVectorSurveillanceSession IS NOT NULL
                              )
                      )
                      OR (
                             @SurveillanceTypeID = 4578940000002 --Passive
                             AND (
                                     m.idfHumanCase IS NOT NULL
                                     OR m.idfVetCase IS NOT NULL
                                 )
                         )
                      OR (@SurveillanceTypeID IS NULL)
                  )
              AND (
                      (
                          (
                              m.idfSendToOffice = @SentToOrganizationID
                              OR @SentToOrganizationID IS NULL
                          )
                          AND (
                                  (
                                      m.blnAccessioned = @AccessionedIndicatorList
                                      OR (
                                             m.blnAccessioned = 1
                                             AND m.datAccession IS NULL
                                             AND @AccessionedIndicatorList IS NOT NULL
                                         )
                                  )
                                  AND m.idfsAccessionCondition IS NULL
                                  AND m.idfsSampleStatus IS NULL
                                  AND m.datDestructionDate IS NULL
                                  OR (
                                         @AccessionedIndicatorList IS NULL
                                         AND @SampleStatusTypeList IS NULL
                                     )
                              )
                      )
                      OR (
                             (
                                 (
                                     m.idfSendToOffice = @SentToOrganizationID
                                     AND m.idfsSite = @SentToOrganizationSiteID
                                 )
                                 OR @SentToOrganizationID IS NULL
                             )
                             AND (
                                     (m.idfsSampleStatus IN (
                                                                SELECT ID FROM @SampleStatusTypeListTable
                                                            )
                                     )
                                     OR (
                                            m.idfsAccessionCondition IN (
                                                                            SELECT ID FROM @SampleStatusTypeListTable
                                                                        )
                                            AND (
                                                    m.idfsSampleStatus IS NULL
                                                    OR m.idfsSampleStatus = 10015007 --In Repository
                                                )
                                        )
                                     OR (
                                            @SampleStatusTypeList IS NULL
                                            AND @AccessionedIndicatorList IS NULL
                                        )
                                 )
                         )
                  )
              AND (
                      tro.idfSendToOffice = @TransferredToOrganizationID
                      OR @TransferredToOrganizationID IS NULL
                  )
              AND (
                      t.idfTestedByOffice = @ResultsReceivedFromID
                      OR @ResultsReceivedFromID IS NULL
                  )
              AND (
                      m.idfsSampleType = @SampleTypeID
                      OR @SampleTypeID IS NULL
                  )
              AND (
                      t.idfsTestName = @TestNameTypeID
                      OR @TestNameTypeID IS NULL
                  )
              AND (
                      t.idfsDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      t.idfsTestStatus = @TestStatusTypeID
                      OR @TestStatusTypeID IS NULL
                  )
              AND (
                      t.idfsTestResult = @TestResultTypeID
                      OR @TestResultTypeID IS NULL
                  )
              AND (
                      species.idfsSpeciesType = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
                  )
              AND (
                      (t.datConcludedDate
              BETWEEN @TestResultDateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @TestResultDateTo)))
                      )
                      OR (
                             @TestResultDateFrom IS NULL
                             OR @TestResultDateTo IS NULL
                         )
                  )
              AND (
                      (
                          m.strCalculatedCaseID LIKE '%' + @EIDSSReportCampaignOrSessionID + '%'
                          OR c.strCampaignID LIKE '%' + @EIDSSReportCampaignOrSessionID + '%'
                      )
                      OR @EIDSSReportCampaignOrSessionID IS NULL
                  )
              AND (
                      m.strCalculatedHumanName LIKE '%' + @PatientName + '%'
                      OR @PatientName IS NULL
                  )
              AND (
                      m.strCalculatedHumanName LIKE '%' + @FarmOwnerName + '%'
                      OR @FarmOwnerName IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + @EIDSSLocalOrFieldSampleID + '%'
                      OR @EIDSSLocalOrFieldSampleID IS NULL
                  )
              AND (
                      tro.strBarcode LIKE '%' + @EIDSSTransferID + '%'
                      OR @EIDSSTransferID IS NULL
                  )
              AND (
                      m.strBarcode LIKE '%' + @EIDSSLaboratorySampleID + '%'
                      OR @EIDSSLaboratorySampleID IS NULL
                  )
        GROUP BY res.ID,
                 res.TestStatusTypeID
        OPTION (RECOMPILE);

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        DECLARE @InProgressCount INT = 0,
                @RecordCount INT = (
                                       SELECT COUNT(ID) FROM @FinalResults
                                   );

        IF @RecordCount > 10000
        BEGIN
            INSERT INTO @NarrowResults
            SELECT TOP 10000
                res.ID,
                res.TestStatusTypeID,
                ReadPermissionIndicator,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator,
                0
            FROM @FinalResults res;

            SET @InProgressCount =
            (
                SELECT TOP 10000
                    COUNT(*)
                FROM @FinalResults res
                    INNER JOIN dbo.tlbTesting t
                        ON t.idfTesting = res.ID
                           AND t.intRowStatus = 0
                    LEFT JOIN dbo.tlbBatchTest b
                        ON b.idfBatchTest = t.idfBatchTest
                           AND b.intRowStatus = 0
                WHERE t.idfsTestStatus = 10001003
                      AND t.idfsTestName IS NOT NULL
                      AND t.blnNonLaboratoryTest = 0
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '**********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
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
                   CASE
                       WHEN res.ReadPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.ReadPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.ReadPermissionIndicator)
                   END AS ReadPermissionindicator,
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToPersonalDataPermissionIndicator)
                   END AS AccessToPersonalDataPermissionIndicator,
                   CASE
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToGenderAndAgeDataPermissionIndicator)
                   END AS AccessToGenderAndAgeDataPermissionIndicator,
                   CASE
                       WHEN res.WritePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.WritePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.WritePermissionIndicator)
                   END AS WritePermissionIndicator,
                   CASE
                       WHEN res.DeletePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.DeletePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.DeletePermissionIndicator)
                   END AS DeletePermissionIndicator,
                   99 AS RowAction,
                   0 AS RowSelectionIndicator,
                   10000 AS TotalRowCount,
                   @InProgressCount AS InProgressCount
            FROM @NarrowResults res
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = t.idfsDiagnosis
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
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
                LEFT JOIN dbo.tlbDepartment d
                    ON d.idfDepartment = m.idfInDepartment
                       AND d.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                    ON functionalArea.idfsReference = d.idfsDepartmentName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                    ON accessionConditionType.idfsReference = m.idfsAccessionCondition
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                    ON sampleStatusType.idfsReference = m.idfsSampleStatus
            ORDER BY m.strBarcode DESC
            OPTION (RECOMPILE);
        END
        ELSE
        BEGIN
            SET @InProgressCount =
            (
                SELECT COUNT(*)
                FROM @FinalResults res
                    INNER JOIN dbo.tlbTesting t
                        ON t.idfTesting = res.ID
                           AND t.intRowStatus = 0
                    LEFT JOIN dbo.tlbBatchTest b
                        ON b.idfBatchTest = t.idfBatchTest
                           AND b.intRowStatus = 0
                WHERE t.idfsTestStatus = 10001003
                      AND t.idfsTestName IS NOT NULL
                      AND t.blnNonLaboratoryTest = 0
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '**********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
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
                   CASE
                       WHEN res.ReadPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.ReadPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.ReadPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.ReadPermissionIndicator)
                   END AS ReadPermissionindicator,
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToPersonalDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToPersonalDataPermissionIndicator)
                   END AS AccessToPersonalDataPermissionIndicator,
                   CASE
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.AccessToGenderAndAgeDataPermissionIndicator)
                   END AS AccessToGenderAndAgeDataPermissionIndicator,
                   CASE
                       WHEN res.WritePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.WritePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.WritePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.WritePermissionIndicator)
                   END AS WritePermissionIndicator,
                   CASE
                       WHEN res.DeletePermissionIndicator = 5 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 4 THEN
                           CONVERT(BIT, 0)
                       WHEN res.DeletePermissionIndicator = 3 THEN
                           CONVERT(BIT, 1)
                       WHEN res.DeletePermissionIndicator = 2 THEN
                           CONVERT(BIT, 0)
                       ELSE
                           CONVERT(BIT, res.DeletePermissionIndicator)
                   END AS DeletePermissionIndicator,
                   res.RowAction,
                   0 AS RowSelectionIndicator,
                   @RecordCount AS TotalRowCount,
                   @InProgressCount AS InProgressCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = t.idfsDiagnosis
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
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
                LEFT JOIN dbo.tlbDepartment d
                    ON d.idfDepartment = m.idfInDepartment
                       AND d.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                    ON functionalArea.idfsReference = d.idfsDepartmentName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                    ON accessionConditionType.idfsReference = m.idfsAccessionCondition
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                    ON sampleStatusType.idfsReference = m.idfsSampleStatus
            ORDER BY m.strBarcode DESC
            OPTION (RECOMPILE);
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
