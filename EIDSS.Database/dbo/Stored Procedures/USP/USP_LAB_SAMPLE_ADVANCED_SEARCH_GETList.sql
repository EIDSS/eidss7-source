-- ================================================================================================
-- Name: USP_LAB_SAMPLE_ADVANCED_SEARCH_GETList
--
-- Description:	Get sample advanced search list for the laboratory module use case LUC13.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     01/14/2019 Initial relase.
-- Stephen Long     01/30/2019 Added sample disease reference join, and removed the vector 
--                             surveillance session joins as they are not needed.
-- Stephen Long     02/11/2019 Changed sample status type ID from bigint to nvarchar(max).  Can 
--                             have multiple sample status types.
-- Stephen Long     02/21/2019 Renamed parameters to be consistent with other objects.
-- Stephen Long     03/28/2019 Removed test status 'Not Started' as criteria to pull back in the 
--                             test assigned indicator.
-- Stephen Long     07/01/2019 Corrected reference type on monitoring session category.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     08/29/2019 Added accession condition type field as one of the where clauses.
-- Stephen Long     10/07/2019 Removed @CampaignID variable; just use EIDSSReportCampaignSessionID.
-- Stephen Long     11/04/2019 Corrected tlbSpecies join; joined to tlbMaterial instead of tlbHerd.
-- Stephen Long     01/16/2020 Corrected where clause on sample status type for defect 5699.
-- Stephen Long     01/21/2020 Converted site ID to site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/08/2020 Added sample list parameter and where clause criteria.
-- Stephen Long     04/16/2020 Removed un-needed joins for farm, herd and species type.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     07/06/2020 Added lab module source indicator to the model.
-- Stephen Long     08/25/2020 Added criteria to ignore time on date betweens.
-- Stephen Long     09/02/2020 Changed accessioned indicator from int to varchar to handle searches
--                             with un-accessioned and accessioned samples in the same query.
-- Stephen Long     10/28/2020 Removed site left joins as not needed.
-- Stephen Long     10/30/2020 Remove test assigned indicator; use test assigned count instead.
--                             Added EIDSS freezer ID.
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
-- Stephen Long     02/10/2021 Remove unneeded joins and add check for blnShowInLabList.
-- Stephen Long     06/28/2021 Applied new pagination parameters.
-- Mark Wilson		08/11/2021 updated to join tlbMonitoringSessionToDiagnosis
-- Stephen Long     09/18/2021 Removed unneeded fields and joins to improve performance.
-- Stephen Long     10/14/2021 Changed report or session type ID to bigint.
-- Stephen Long     12/08/2021 Changed pagination logic and removed option recompile.
-- Stephen Long     12/11/2021 Split out query to get initial results using required date range.
-- Stephen Long     12/14/2021 Added sample status date to the query.
-- Stephen Long     12/15/2021 Added configurable filtration rules.
-- Stephen Long     02/08/2022 Removed unneeded joins.
-- Stephen Long     03/10/2022 Changed note to comment and transfer count to transferred count.
-- Stephen Long     03/24/2022 Removed primary key from results and final results table variables.
-- Stephen Long     03/30/2022 Remove show in lab list from where criteria.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Mike Kornegay	06/14/2022 Added new additional SessionCategoryID for Vet Avian / Vet Livestock 
--                             breakout.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/12/2022 Removed where criteria for surveillance type of both; de-activated 
--                             base reference record.
-- Stephen Long     08/26/2022 Added additional checks on accession and entered date range checks.
-- Stephen Long     09/28/2022 Bug fix on item 5117.
-- Stephen Long     10/21/2022 Added display disease names separated by comma.
-- Stephen Long     12/16/2022 Fix on initial query to use sent to organization and not user 
--                             organization.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/11/2023 Updated for site filtration queries for SAUC29.
-- Stephen Long     01/31/2023 Added coalesce on collection and entered dates.
-- Stephen Long     02/03/2023 Added filtration indicator logic.
-- Stephen Long     02/20/2023 Added sent to organization sent to site ID and where criteria.
-- Stephen Long     03/14/2023 Added narrow search criteria, and fixed default sort order.
-- Stephen Long     03/28/2023 Bug fix for item 5818 and 5819.
-- Stephen Long     04/24/2023 Bug fix for item 5738.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_ADVANCED_SEARCH_GETList]
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
    @SampleList VARCHAR(MAX) = NULL,
    @TestUnassignedIndicator BIT = NULL,
    @TestCompletedIndicator BIT = NULL,
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
        ID BIGINT NOT NULL INDEX c NONCLUSTERED,
        ReadPermissionIndicator BIT NOT NULL INDEX r CLUSTERED,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @NarrowResults TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        AccessionedIndicator BIT NOT NULL,
        AccessionConditionTypeID BIGINT NULL
    );
    DECLARE @RecordCount INT = 0,
            @UnaccessionedCount INT = 0,
            @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
    DECLARE @FunctionalAreas TABLE
    (
        DepartmentID BIGINT NOT NULL PRIMARY KEY,
        DepartmentNameID BIGINT NULL,
        FunctionalAreaName NVARCHAR(200) NULL
    );
    DECLARE @SampleStatusTypes TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL
    );
    DECLARE @AccessionConditionTypes TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL
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
    DECLARE @SampleListTable TABLE (ID BIGINT NOT NULL);
    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL INDEX IDX1 CLUSTERED,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL INDEX IDX1 CLUSTERED,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @Favorites XML,
            @LanguageCode BIGINT;

    IF @SampleList IS NOT NULL
    BEGIN
        INSERT INTO @SampleListTable
        SELECT CAST([Value] AS BIGINT)
        FROM dbo.FN_GBL_SYS_SplitList(@SampleList, NULL, ',');
    END

    DECLARE @SampleStatusTypeListTable TABLE (ID BIGINT NOT NULL PRIMARY KEY);

    IF @SampleStatusTypeList IS NOT NULL
        INSERT INTO @SampleStatusTypeListTable
        SELECT CAST([Value] AS BIGINT)
        FROM dbo.FN_GBL_SYS_SplitList(@SampleStatusTypeList, NULL, ',');

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

        INSERT INTO @FunctionalAreas
        SELECT d.idfDepartment,
               idfsReference,
               name
        FROM dbo.tlbDepartment d
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164)
                ON d.idfsDepartmentName = idfsReference;

        INSERT INTO @SampleStatusTypes
        SELECT idfsReference,
               name
        FROM dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015);

        INSERT INTO @AccessionConditionTypes
        SELECT idfsReference,
               name
        FROM dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110);

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

        INSERT INTO @Results
        SELECT m.idfMaterial,
               1,
               CASE
                   WHEN
                   (
                       COALESCE(m.idfsCurrentSite, m.idfsSite) = @UserSiteID
                       OR m.idfSendToOffice = @UserOrganizationID
                       OR @FiltrationIndicator = 0
                   ) THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN COALESCE(m.idfsCurrentSite, m.idfsSite) = @UserSiteID
                        OR m.idfSendToOffice = @UserOrganizationID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN COALESCE(m.idfsCurrentSite, m.idfsSite) = @UserSiteID
                        OR m.idfSendToOffice = @UserOrganizationID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN COALESCE(m.idfsCurrentSite, m.idfsSite) = @UserSiteID
                        OR m.idfSendToOffice = @UserOrganizationID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND m.blnReadOnly = 0
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
        -- overlap the default rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND sgs.idfsSite = m.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
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
              AND m.blnReadOnly = 0
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
              AND m.blnReadOnly = 0
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
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = m.idfsSite
        )
              AND m.blnReadOnly = 0
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
        SELECT res.ID,
               1,
               MAX(AccessToPersonalDataPermissionIndicator),
               MAX(AccessToGenderAndAgeDataPermissionIndicator),
               MAX(WritePermissionIndicator),
               MAX(DeletePermissionIndicator)
        FROM @Results res
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = res.ID
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = res.ID
                   AND t.intRowStatus = 0
                   AND t.blnNonLaboratoryTest = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = m.idfMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = res.ID
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbSpecies species
                ON species.idfSpecies = m.idfSpecies
                   AND species.intRowStatus = 0
        WHERE ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      (
                          @ReportOrSessionTypeID = 10012001 --Human 
                          AND (
                                  m.idfHumanCase IS NOT NULL
                                  OR (
                                         m.idfMonitoringSession IS NOT NULL
                                         AND ms.SessionCategoryID = 10502001 --Human Active Surveillance Session
                                     )
                              )
                      )
                      OR (
                             @ReportOrSessionTypeID = 10012006 --Vector
                             AND m.idfVectorSurveillanceSession IS NOT NULL
                         )
                      OR (
                             @ReportOrSessionTypeID = 10012005 --Veterinary
                             AND (
                                     m.idfVetCase IS NOT NULL
                                     OR (
                                            m.idfMonitoringSession IS NOT NULL
                                            AND ms.SessionCategoryID IN ( 10502002, 10502009 ) --Veterinary Active Surveillance Session (Avian and Livestock)
                                        )
                                 )
                         )
                      OR @ReportOrSessionTypeID IS NULL
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
                      OR @SurveillanceTypeID IS NULL
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
              AND (
                      (
                          m.blnAccessioned = 1
                          AND m.datAccession IS NOT NULL
                          AND m.strBarcode IS NOT NULL
                          AND (
                                  m.idfsAccessionCondition IS NOT NULL
                                  AND m.idfsAccessionCondition <> 10108003
                              ) -- Rejected
                          AND m.idfsSampleStatus = 10015007 -- In Repository
                          AND m.TestUnassignedIndicator = 1
                          AND @TestUnassignedIndicator = 1
                      )
                      OR @TestUnassignedIndicator IS NULL
                  )
              AND (
                      (
                          m.blnAccessioned = 1
                          AND m.datAccession IS NOT NULL
                          AND m.strBarcode IS NOT NULL
                          AND (
                                  m.idfsAccessionCondition IS NOT NULL
                                  AND m.idfsAccessionCondition <> 10108003
                              ) -- Rejected
                          AND m.idfsSampleStatus = 10015007 -- In Repository
                          AND m.TestCompletedIndicator = 1
                          AND @TestCompletedIndicator = 1
                      )
                      OR @TestCompletedIndicator IS NULL
                  )
        GROUP BY res.ID
        OPTION (RECOMPILE);

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @RecordCount =
        (
            SELECT COUNT(ID) FROM @FinalResults
        );

        IF @RecordCount > 10000
        BEGIN
            INSERT INTO @NarrowResults
            SELECT TOP 10000
                res.ID,
                1,
                AccessToPersonalDataPermissionIndicator,
                AccessToGenderAndAgeDataPermissionIndicator,
                WritePermissionIndicator,
                DeletePermissionIndicator,
                m.blnAccessioned,
                m.idfsAccessionCondition
            FROM @FinalResults res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.ID
            ORDER BY m.blnAccessioned,
                     m.idfsSampleStatus DESC,
                     m.idfsAccessionCondition,
                     COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate) DESC;

            SET @UnaccessionedCount =
            (
                SELECT TOP 10000
                    COUNT(res.ID)
                FROM @NarrowResults res
                WHERE res.AccessionedIndicator = 0
                      AND res.AccessionConditionTypeID IS NULL
            );

            SELECT res.ID AS SampleID,
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
                   m.idfSpecies AS SpeciesID,
                   m.idfAnimal AS AnimalID,
                   a.strAnimalCode AS EIDSSAnimalID,
                   m.idfVector AS VectorID,
                   m.idfMonitoringSession AS MonitoringSessionID,
                   m.idfVectorSurveillanceSession AS VectorSessionID,
                   m.idfHumanCase AS HumanDiseaseReportID,
                   m.idfVetCase AS VeterinaryDiseaseReportID,
                   m.strCalculatedCaseID AS EIDSSReportOrSessionID,
                   m.TestCompletedIndicator,
                   CASE
                       WHEN m.DiseaseID IS NOT NULL THEN
                           CAST(m.DiseaseID AS NVARCHAR(MAX))
                       WHEN m.idfMonitoringSession IS NOT NULL THEN
                           msDiseases.DiseaseIdentifiers
                       WHEN m.idfVectorSurveillanceSession IS NOT NULL THEN
                           vsDiseases.DiseaseIdentifiers
                       ELSE
                           ''
                   END AS DiseaseID,
                   CASE
                       WHEN m.DiseaseID IS NOT NULL THEN
                           diseaseName.name
                       WHEN m.idfMonitoringSession IS NOT NULL THEN
                           msDiseases.DiseaseNames
                       WHEN m.idfVectorSurveillanceSession IS NOT NULL THEN
                           vsDiseases.DiseaseNames
                       ELSE
                           ''
                   END AS DiseaseName,
                   CASE
                       WHEN m.DiseaseID IS NOT NULL THEN
                           diseaseName.name
                       WHEN m.idfMonitoringSession IS NOT NULL THEN
                           msDiseases.DisplayDiseaseNames
                       WHEN m.idfVectorSurveillanceSession IS NOT NULL THEN
                           vsDiseases.DisplayDiseaseNames
                       ELSE
                           ''
                   END AS DisplayDiseaseName,
                   m.idfInDepartment AS FunctionalAreaID,
                   fa.FunctionalAreaName,
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
                   accessionConditionType.name AS AccessionConditionTypeName,
                   m.datAccession AS AccessionDate,
                   m.idfsAccessionCondition AS AccessionConditionTypeID,
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
                   sampleStatusType.name AS SampleStatusTypeName,
                   m.idfAccesionByPerson AS AccessionByPersonID,
                   m.idfsSampleStatus AS SampleStatusTypeID,
                   m.datSampleStatusDate AS SampleStatusDate,
                   m.strCondition AS AccessionComment,
                   m.idfsDestructionMethod AS DestructionMethodTypeID,
                   m.datDestructionDate AS DestructionDate,
                   m.idfDestroyedByPerson AS DestroyedByPersonID,
                   CASE
                       WHEN m.TestUnassignedIndicator = 1 THEN
                           0
                       ELSE
                           1
                   END AS TestAssignedCount,
                   m.TransferIndicator AS TransferredCount,
                   m.strNote AS Comment,
                   m.idfsCurrentSite AS CurrentSiteID,
                   m.idfsBirdStatus AS BirdStatusTypeID,
                   m.idfMainTest AS MainTestID,
                   m.idfsSampleKind AS SampleKindTypeID,
                   m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
                   m.LabModuleSourceIndicator,
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
                   99 AS RowAction,
                   0 AS RowSelectionIndicator,
                   10000 AS TotalRowCount,
                   @UnaccessionedCount AS UnaccessionedSampleCount
            FROM @NarrowResults res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.ID
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
                LEFT JOIN
                (
                    SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                    FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
                ) f
                    ON f.SampleID = res.ID
                LEFT JOIN dbo.tlbAnimal a
                    ON a.idfAnimal = m.idfAnimal
                       AND a.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                    ON diseaseName.idfsReference = m.DiseaseID
                LEFT JOIN @MonitoringSessionDiseases msDiseases
                    ON msDiseases.ID = m.idfMonitoringSession
                LEFT JOIN @VectorSessionDiseases vsDiseases
                    ON vsDiseases.ID = m.idfVectorSurveillanceSession
                LEFT JOIN @FunctionalAreas fa
                    ON fa.DepartmentID = m.idfInDepartment
                LEFT JOIN @SampleStatusTypes sampleStatusType
                    ON sampleStatusType.ID = m.idfsSampleStatus
                LEFT JOIN @AccessionConditionTypes accessionConditionType
                    ON accessionConditionType.ID = m.idfsAccessionCondition
            OPTION (RECOMPILE);
        END
        ELSE
        BEGIN
            SET @UnaccessionedCount =
            (
                SELECT COUNT(res.ID)
                FROM @FinalResults res
                    INNER JOIN dbo.tlbMaterial m
                        ON m.idfMaterial = res.ID
                WHERE m.blnAccessioned = 0
                      AND m.idfsAccessionCondition IS NULL
            );

            SELECT res.ID AS SampleID,
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
                   m.idfSpecies AS SpeciesID,
                   m.idfAnimal AS AnimalID,
                   a.strAnimalCode AS EIDSSAnimalID,
                   m.idfVector AS VectorID,
                   m.idfMonitoringSession AS MonitoringSessionID,
                   m.idfVectorSurveillanceSession AS VectorSessionID,
                   m.idfHumanCase AS HumanDiseaseReportID,
                   m.idfVetCase AS VeterinaryDiseaseReportID,
                   m.strCalculatedCaseID AS EIDSSReportOrSessionID,
                   m.TestCompletedIndicator,
                   CASE
                       WHEN m.DiseaseID IS NOT NULL THEN
                           CAST(m.DiseaseID AS NVARCHAR(MAX))
                       WHEN m.idfMonitoringSession IS NOT NULL THEN
                           msDiseases.DiseaseIdentifiers
                       WHEN m.idfVectorSurveillanceSession IS NOT NULL THEN
                           vsDiseases.DiseaseIdentifiers
                       ELSE
                           ''
                   END AS DiseaseID,
                   CASE
                       WHEN m.DiseaseID IS NOT NULL THEN
                           diseaseName.name
                       WHEN m.idfMonitoringSession IS NOT NULL THEN
                           msDiseases.DiseaseNames
                       WHEN m.idfVectorSurveillanceSession IS NOT NULL THEN
                           vsDiseases.DiseaseNames
                       ELSE
                           ''
                   END AS DiseaseName,
                   CASE
                       WHEN m.DiseaseID IS NOT NULL THEN
                           diseaseName.name
                       WHEN m.idfMonitoringSession IS NOT NULL THEN
                           msDiseases.DisplayDiseaseNames
                       WHEN m.idfVectorSurveillanceSession IS NOT NULL THEN
                           vsDiseases.DisplayDiseaseNames
                       ELSE
                           ''
                   END AS DisplayDiseaseName,
                   m.idfInDepartment AS FunctionalAreaID,
                   fa.FunctionalAreaName,
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
                   accessionConditionType.name AS AccessionConditionTypeName,
                   m.datAccession AS AccessionDate,
                   m.idfsAccessionCondition AS AccessionConditionTypeID,
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
                   sampleStatusType.name AS SampleStatusTypeName,
                   m.idfAccesionByPerson AS AccessionByPersonID,
                   m.idfsSampleStatus AS SampleStatusTypeID,
                   m.datSampleStatusDate AS SampleStatusDate,
                   m.strCondition AS AccessionComment,
                   m.idfsDestructionMethod AS DestructionMethodTypeID,
                   m.datDestructionDate AS DestructionDate,
                   m.idfDestroyedByPerson AS DestroyedByPersonID,
                   CASE
                       WHEN m.TestUnassignedIndicator = 1 THEN
                           0
                       ELSE
                           1
                   END AS TestAssignedCount,
                   m.TransferIndicator AS TransferredCount,
                   m.strNote AS Comment,
                   m.idfsCurrentSite AS CurrentSiteID,
                   m.idfsBirdStatus AS BirdStatusTypeID,
                   m.idfMainTest AS MainTestID,
                   m.idfsSampleKind AS SampleKindTypeID,
                   m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
                   m.LabModuleSourceIndicator,
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
                   0 AS RowAction,
                   0 AS RowSelectionIndicator,
                   COUNT(*) OVER () AS TotalRowCount,
                   @UnaccessionedCount AS UnaccessionedSampleCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.ID
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
                LEFT JOIN
                (
                    SELECT SampleID = UserPref.value('@SampleID', 'BIGINT')
                    FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
                ) f
                    ON f.SampleID = res.ID
                LEFT JOIN dbo.tlbAnimal a
                    ON a.idfAnimal = m.idfAnimal
                       AND a.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                    ON diseaseName.idfsReference = m.DiseaseID
                LEFT JOIN @MonitoringSessionDiseases msDiseases
                    ON msDiseases.ID = m.idfMonitoringSession
                LEFT JOIN @VectorSessionDiseases vsDiseases
                    ON vsDiseases.ID = m.idfVectorSurveillanceSession
                LEFT JOIN @FunctionalAreas fa
                    ON fa.DepartmentID = m.idfInDepartment
                LEFT JOIN @SampleStatusTypes sampleStatusType
                    ON sampleStatusType.ID = m.idfsSampleStatus
                LEFT JOIN @AccessionConditionTypes accessionConditionType
                    ON accessionConditionType.ID = m.idfsAccessionCondition
            ORDER BY m.blnAccessioned,
                     m.idfsSampleStatus DESC,
                     m.idfsAccessionCondition,
                     COALESCE(m.datAccession, m.datFieldCollectionDate, m.datEnteringDate) DESC
            OPTION (RECOMPILE);
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
