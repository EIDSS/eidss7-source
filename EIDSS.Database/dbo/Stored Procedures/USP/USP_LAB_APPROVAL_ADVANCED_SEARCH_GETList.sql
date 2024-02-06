-- ================================================================================================
-- Name: USP_LAB_APPROVAL_ADVANCED_SEARCH_GETList
--
-- Description:	Get approval advanced search list for the laboratory module use case LUC13.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/27/2019 Initial relase.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     10/07/2019 Removed @CampaignID variable; just use EIDSSReportCampaignSessionID.
-- Stephen Long     01/21/2020 Converted site ID to site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/16/2020 Added sample and test list parameters and where clause criteria.
-- Stephen Long     04/20/2020 Removed farm and herd left joins.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     08/25/2020 Added criteria to ignore time on date betweens.
-- Stephen Long     09/02/2020 Changed accessioned indicator from int to varchar to handle searches
--                             with un-accessioned and accessioned samples in the same query.
-- Stephen Long     10/30/2020 Remove unneeded joins.
-- Stephen Long     11/30/2020 Changed site list to site ID and bigint and made required.
-- Stephen Long     12/16/2020 Changed join for vector surveillance session diseases to the sample
--                             table.
-- Stephen Long     12/23/2020 Correction on accession indicator list where criteria.
-- Stephen Long     12/31/2020 Change function on reference data to handle inactive records.
-- Stephen Long     01/03/2020 Added option recompile to select queries.
-- Stephen Long     01/21/2021 Changed counts to use group by in sub-query instead of count 
--                             distinct and added with recompile to handle number of nullable 
--                             parameters.
-- Stephen Long     01/24/2021 Correct where criteria on accession indicator list.
-- Stephen Long     09/25/2021 Added new pagination and order by.
-- Stephen Long     10/14/2021 Changed report or session type ID to bigint.
-- Stephen Long     11/18/2021 Added action requested ID to the query.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     12/15/2021 Added configurable filtration rules.
-- Stephen Long     01/03/2022 Corrected sample status type to use the correct field.
-- Stephen Long     02/10/2022 Removed unneeded joins on the disease fields.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Mike Kornegay	06/14/2022 Added new additional SessionCategoryID for Vet Avian / Vet Livestock 
--                             breakout.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/11/2022 Changed monitoring session disease join from inner to left.
-- Stephen Long     08/12/2022 Removed where criteria for surveillance type of both; de-activated 
--                             base reference record.
-- Stephen Long     08/26/2022 Added additional checks on accession and entered date range checks.
-- Stephen Long     09/28/2022 Added translated value for action requested name.
-- Stephen Long     10/11/2022 Added check for closed batch test status to display test records 
--                             ready for validation.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     10/23/2022 Added check for non-laboratory test indicator of false.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/11/2023 Updated for site filtration queries.
-- Stephen Long     01/31/2023 Added coalesce on collection and entered dates.
-- Stephen Long     02/20/2023 Added sent to organization sent to site ID and where criteria.
-- Stephen Long     03/15/2023 Added narrow search criteria logic.
-- Stephen Long     04/24/2023 Bug fix for item 5738.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_APPROVAL_ADVANCED_SEARCH_GETList]
(
    @LanguageID NVARCHAR(50),
    @ReportOrSessionTypeID BIGINT = NULL,
    @SurveillanceTypeID BIGINT = NULL,
    @SampleStatusTypeList VARCHAR(MAX) = NULL,
    @AccessionedIndicatorList VARCHAR(3) = NULL,
    @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
    @EIDSSReportCampaignOrSessionID NVARCHAR(200) = NULL,
    @SentToOrganizationID BIGINT,
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
    @SampleList VARCHAR(MAX) = NULL,
    @TestList VARCHAR(MAX) = NULL,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteGroupID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

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
    DECLARE @Results TABLE
    (
        ID INT NOT NULL IDENTITY,
        SampleID BIGINT NOT NULL INDEX c NONCLUSTERED,
        TestID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID INT NOT NULL IDENTITY,
        SampleID BIGINT NOT NULL INDEX c NONCLUSTERED,
        TestID BIGINT NULL,
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
        ID INT NOT NULL IDENTITY,
        SampleID BIGINT NOT NULL INDEX c NONCLUSTERED,
        TestID BIGINT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        RowAction INT NOT NULL
            DEFAULT 99
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
    DECLARE @LanguageCode BIGINT,
            @SampleDeletion NVARCHAR(MAX),
            @SampleDestruction NVARCHAR(MAX),
            @TestDeletion NVARCHAR(MAX),
            @Validation NVARCHAR(MAX);
    DECLARE @SampleStatusTypeListTable TABLE (ID BIGINT NOT NULL PRIMARY KEY);
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

        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND (
                      m.idfsSampleStatus = 10015002 --Marked for Deletion 
                      OR m.idfsSampleStatus = 10015003 --Marked for Destruction
                  )
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
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
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
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
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
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
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
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
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
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup sgs
                ON sgs.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND sgs.idfsSite = m.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
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
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
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
        WHERE m.intRowStatus = 0
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
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
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
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = m.idfsSite
        )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = m.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               NULL,
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
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = m.idfsSite
        )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE FROM @Results
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
        SELECT m.idfMaterial,
               NULL,
               MAX(ReadPermissionIndicator),
               MAX(AccessToPersonalDataPermissionIndicator),
               MAX(AccessToGenderAndAgeDataPermissionIndicator),
               MAX(WritePermissionIndicator),
               MAX(DeletePermissionIndicator),
               0
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.SampleID
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = m.idfMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.tlbSpecies species
                ON species.idfSpecies = m.idfSpecies
                   AND species.intRowStatus = 0
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      (m.idfMaterial IN (
                                            SELECT CAST([Value] AS BIGINT)
                                            FROM dbo.FN_GBL_SYS_SplitList(@SampleList, NULL, ',')
                                        )
                      )
                      OR (@SampleList IS NULL)
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
                      msd.idfsDiagnosis = @DiseaseID
                      OR m.DiseaseID = @DiseaseID
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
                      (m.strCalculatedHumanName LIKE '%' + @FarmOwnerName + '%')
                      OR (@FarmOwnerName IS NULL)
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
        GROUP BY m.idfMaterial;

        DELETE FROM @Results;

        -- Test Approvals --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND (
                      m.idfSendToOffice = @SentToOrganizationID
                      AND m.idfsSite = @SentToOrganizationSiteID
                      OR @SentToOrganizationID IS NULL
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
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND sgs.idfsSite = m.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               t.idfTesting,
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
            LEFT JOIN dbo.tlbBatchTest b
                ON b.idfBatchTest = t.idfBatchTest
                   AND b.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND t.blnNonLaboratoryTest = 0
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
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
        SELECT m.idfMaterial,
               t.idfTesting,
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
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
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
        SELECT m.idfMaterial,
               t.idfTesting,
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
              AND t.idfsTestStatus IN (   10001004, --Preliminary 
                                          10001008
                                      ) --Marked for Deletion
              AND (
                      t.idfBatchTest IS NULL
                      OR (
                             t.idfBatchTest IS NOT NULL
                             AND b.idfsBatchStatus = 10001001
                         ) -- Closed
                  )
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
        SELECT m.idfMaterial,
               t.idfTesting,
               MAX(ReadPermissionIndicator),
               MAX(AccessToPersonalDataPermissionIndicator),
               MAX(AccessToGenderAndAgeDataPermissionIndicator),
               MAX(WritePermissionIndicator),
               MAX(DeletePermissionIndicator),
               0
        FROM @Results res
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = res.TestID
            INNER JOIN dbo.tlbMaterial m
                ON t.idfMaterial = m.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = m.idfMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            LEFT JOIN @VectorSessionDiseases vsDiseases
                ON vsDiseases.ID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.tlbSpecies species
                ON species.idfSpecies = m.idfSpecies
                   AND species.intRowStatus = 0
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      t.idfTesting IN (
                                          SELECT CAST([Value] AS BIGINT)
                                          FROM dbo.FN_GBL_SYS_SplitList(@TestList, NULL, ',')
                                      )
                      OR @TestList IS NULL
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
                      msd.idfsDiagnosis = @DiseaseID
                      OR m.DiseaseID = @DiseaseID
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
              BETWEEN @TestResultDateFrom AND @TestResultDateTo
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
        GROUP BY t.idfTesting,
                 m.idfMaterial;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        DECLARE @RecordCount INT = (
                                       SELECT COUNT(ID) FROM @FinalResults
                                   );

        IF @RecordCount > 10000
        BEGIN
            INSERT INTO @NarrowResults
            SELECT TOP 10000
                SampleID,
                TestID,
                res.ReadPermissionIndicator,
                res.AccessToPersonalDataPermissionIndicator,
                res.AccessToGenderAndAgeDataPermissionIndicator,
                res.WritePermissionIndicator,
                res.DeletePermissionIndicator,
                99
            FROM @FinalResults res;

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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
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
                   10000 AS TotalRowCount
            FROM @NarrowResults res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.TestID
                       AND t.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
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
        END
        ELSE
        BEGIN
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
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
                   @RecordCount AS TotalRowCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.SampleID
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.TestID
                       AND t.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
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
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
