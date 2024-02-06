-- ================================================================================================
-- Name: USP_LAB_BATCH_ADVANCED_SEARCH_GETList
--
-- Description:	Get laboratory batch list for the various laboratory use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/25/2019 Initial release.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     10/07/2019 Removed @CampaignID variable; just use EIDSSReportCampaignSessionID.
-- Stephen Long     01/21/2020 Converted site ID to site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/25/2020 Added batch test list parameter and where clause criteria.
-- Stephen Long     08/25/2020 Added criteria to ignore time on date betweens.
-- Stephen Long     09/02/2020 Changed accessioned indicator from int to varchar to handle searches
--                             with un-accessioned and accessioned samples in the same query.
-- Stephen Long     10/30/2020 Remove unneeded joins.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/23/2020 Correction on accession indicator list where criteria.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2020 Added option recompile to select queries.
-- Stephen Long     01/21/2021 Changed counts to use group by in sub-query instead of count 
--                             distinct and added with recompile to handle number of nullable 
--                             parameters.
-- Stephen Long     01/24/2021 Correct where criteria on accession indicator list.
-- Mark Wilson		08/16/2021 Join tlbMonitoringSessionToDiagnosis to get diagnosis
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     10/14/2021 Changed report or session type ID to bigint.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     12/15/2021 Added configurable filtration rules.
-- Stephen Long     02/10/2022 Removed unneeded joins.
-- Stephen Long     03/25/2022 Removed primary key from final results table variable.
-- Mike Kornegay	06/14/2022 Added new additional SessionCategoryID for Vet Avian / Vet Livestock 
--                             breakout.
-- Stephen Long     07/26/2022 Changed from repair to reference repair function.
-- Stephen Long     08/12/2022 Removed where criteria for surveillance type of both; de-activated 
--                             base reference record.
-- Stephen Long     08/26/2022 Added additional checks on accession and entered date range checks.
-- Stephen Long     10/24/2022 Moved where clause check on tests count to insert of final results.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/12/2023 Updated for site filtration queries.
-- Stephen Long     01/31/2023 Added coalesce on collection and entered dates.
-- Stephen Long     02/03/2023 Added filtration indicator logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_BATCH_ADVANCED_SEARCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @ReportOrSessionTypeID BIGINT = NULL,
    @SurveillanceTypeID BIGINT = NULL,
    @SampleStatusTypeList VARCHAR(MAX) = NULL,
    @AccessionedIndicatorList VARCHAR(3) = NULL,
    @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
    @EIDSSReportCampaignOrSessionID NVARCHAR(200) = NULL,
    @SentToOrganizationID BIGINT = NULL,
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
    @BatchTestList VARCHAR(MAX),
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

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        BatchStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID INT NOT NULL,
        BatchStatusTypeID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        TestsCount INT NOT NULL
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
    DECLARE @Favorites XML,
            @InProgressCount INT = 0;

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

        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               1,
               CASE
                   WHEN b.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN b.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN b.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN b.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND t.idfsTestName IS NOT NULL
              AND m.idfsSampleType <> 10320001 --Unknown
              AND (
                      m.idfSendToOffice = @UserOrganizationID
                      OR @UserOrganizationID IS NULL
                  )
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

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
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
            INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                ON userSiteGroup.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
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
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = b.idfsSite
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
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
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
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND sgs.idfsSite = b.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
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
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = b.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
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
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = b.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
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
        WHERE b.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = b.idfsSite;

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
            SELECT b.idfBatchTest
            FROM dbo.tlbBatchTest b
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = b.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE b.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup -- Default role
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = b.idfsSite
        )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = b.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT b.idfBatchTest,
               b.idfsBatchStatus,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = b.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbBatchTest b
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE b.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = b.idfsSite
        )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT b.idfBatchTest
            FROM dbo.tlbBatchTest b
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = b.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        INSERT INTO @FinalResults
        SELECT res.ID,
               MAX(res.BatchStatusTypeID),
               MAX(ReadPermissionIndicator),
               MAX(AccessToPersonalDataPermissionIndicator),
               MAX(AccessToGenderAndAgeDataPermissionIndicator),
               MAX(WritePermissionIndicator),
               MAX(DeletePermissionIndicator),
               (
                   SELECT COUNT(idfTesting)
                   FROM dbo.tlbTesting
                   WHERE idfBatchTest = res.ID
                         AND intRowStatus = 0
               ) AS TestsCount
        FROM @Results res
            INNER JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = res.ID
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
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
                      (b.idfBatchTest IN (
                                             SELECT CAST([Value] AS BIGINT)
                                             FROM dbo.FN_GBL_SYS_SplitList(@BatchTestList, NULL, ',')
                                         )
                      )
                      OR @BatchTestList IS NULL
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
                                            AND ms.SessionCategoryID IN ( 10502002, 10502009 ) --Veterinary Active Surveillance Session (Avian and Livestock)
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
                              m.blnAccessioned = @AccessionedIndicatorList
                              AND m.idfsAccessionCondition IS NULL
                          )
                          OR (
                                 @AccessionedIndicatorList IS NULL
                                 AND @SampleStatusTypeList IS NULL
                             )
                      )
                      OR (
                             (
                                 (m.idfsSampleStatus IN (
                                                            SELECT CAST([Value] AS BIGINT)
                                                            FROM dbo.FN_GBL_SYS_SplitList(
                                                                                             @SampleStatusTypeList,
                                                                                             NULL,
                                                                                             ','
                                                                                         )
                                                        )
                                 )
                                 OR (
                                        m.idfsAccessionCondition IN (
                                                                        SELECT CAST([Value] AS BIGINT)
                                                                        FROM dbo.FN_GBL_SYS_SplitList(
                                                                                                         @SampleStatusTypeList,
                                                                                                         NULL,
                                                                                                         ','
                                                                                                     )
                                                                    )
                                        AND (
                                                m.idfsSampleStatus IS NULL
                                                OR m.idfsSampleStatus = 10015007 --In Repository
                                            )
                                    )
                             )
                             OR (
                                    @SampleStatusTypeList IS NULL
                                    AND @AccessionedIndicatorList IS NULL
                                )
                         )
                  )
              AND (
                      m.idfSendToOffice = @SentToOrganizationID
                      OR @SentToOrganizationID IS NULL
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
                      OR (@EIDSSReportCampaignOrSessionID IS NULL)
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
        GROUP by res.ID;

        DELETE FROM @FinalResults
        WHERE TestsCount = 0;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @InProgressCount =
        (
            SELECT IIF(
                       SUM(   CASE
                                  WHEN BatchStatusTypeID = 10001003 --In Progress
                              THEN
                                      1
                                  ELSE
                                      0
                              END
                          ) IS NULL,
                       0,
                       SUM(   CASE
                                  WHEN BatchStatusTypeID = 10001003 --In Progress
                              THEN
                                      1
                                  ELSE
                                      0
                              END
                          ))
            FROM @FinalResults res
                INNER JOIN dbo.tlbBatchTest b
                    ON b.idfBatchTest = res.ID
        );

        SELECT b.idfBatchTest AS BatchTestID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               b.strBarcode AS EIDSSBatchTestID,
               b.idfsBatchStatus AS BatchStatusTypeID,
               batchStatusType.name AS BatchStatusTypeName,
               b.idfPerformedByOffice AS BatchTestPerformedByOrganizationID,
               b.idfPerformedByPerson AS BatchTestPerformedByPersonID,
               b.idfsTestName AS BatchTestTestNameTypeID,
               batchTestTestNameType.name AS BatchTestTestNameTypeName,
               t.idfTesting AS TestID,
               t.idfsTestName AS TestNameTypeID,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsTestResult AS TestResultTypeID,
               t.idfsTestStatus AS TestStatusTypeID,
               t.idfsDiagnosis AS DiseaseID,
               disease.name AS DiseaseName,
               m.idfMaterial AS SampleID,
               m.idfSendToOffice AS SentToOrganizationID,
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
               m.strBarcode AS EIDSSLaboratorySampleID,
               testNameType.name AS TestNameTypeName,
               testStatusType.name AS TestStatusTypeName,
               testResultType.name AS TestResultTypeName,
               testCategoryType.name AS TestCategoryTypeName,
               m.datAccession AS AccessionDate,
               functionalArea.name AS FunctionalAreaName,
               m.idfsAccessionCondition AS SampleStatusTypeID,
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
               b.TestRequested,
               b.idfObservation AS ObservationID,
               b.idfPerformedByPerson AS PerformedByPersonID,
               b.datPerformedDate AS PerformedDate,
               b.datValidatedDate AS ValidationDate,
               b.idfsSite AS SiteID,
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
               0 AS RowAction,
               0 AS RowSelectionIndicator,
               COUNT(*) OVER () AS TotalRowCount,
               @InProgressCount AS InProgressCount,
               res.TestsCount
        FROM @FinalResults res
            INNER JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = res.ID
            INNER JOIN dbo.tlbTesting t
                ON t.idfBatchTest = b.idfBatchTest
                   AND t.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = t.idfsDiagnosis
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) batchTestTestNameType
                ON batchTestTestNameType.idfsReference = b.idfsTestName
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
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) batchStatusType
                ON batchStatusType.idfsReference = b.idfsBatchStatus;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
