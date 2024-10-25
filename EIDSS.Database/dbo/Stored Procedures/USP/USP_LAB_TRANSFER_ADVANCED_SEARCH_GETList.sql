-- ================================================================================================
-- Name: USP_LAB_TRANSFER_ADVANCED_SEARCH_GETList
--
-- Description:	Get transferred advanced search list for the laboratory module use case LUC13.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/18/2019 Initial relase.
-- Stephen Long     07/10/2019 Corrected accession condition/sample status case on un-accessioned.
-- Stephen Long     10/07/2019 Removed @CampaignID variable; just use EIDSSReportCampaignSessionID.
-- Stephen Long     10/21/2019 Added accession indicator and test status type ID to the list of 
--                             fields.
-- Stephen Long     01/22/2020 Converted site ID to site list for site filtration.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     04/07/2020 Added test name type ID to the model.
-- Stephen Long     04/15/2020 Changed select from table to tlbTransferOUT instead of tlbMaterial.
-- Stephen Long     04/23/2020 Correction on disease ID and disease name; add vector surveillance 
--                             session.
-- Stephen Long     04/26/2020 Added sent to organization ID to the model.
-- Stephen Long     05/06/2020 Added test started date and test category type name to the model.
-- Stephen Long     06/24/2020 Added external test check to the test left join.
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
-- Stephen Long     02/10/2022 Replaced joins for monitoring session and vector session
--                             disease references to improve performance.
-- Stephen Long     03/24/2022 Removed primary key from final results table variable.
-- Stephen Long     05/17/2022 Removed primary key from monitoring and vector session disease 
--                             table variables.
-- Stephen Long     05/20/2022 Added string agg to session diseases.
-- Mike Kornegay	06/14/2022 Added new additional SessionCategoryID for Vet Avian / Vet Livestock 
--                             breakout.
-- Stephen Long     07/26/2022 Updated case statement on disease id and name.
-- Stephen Long     08/11/2022 Changed monitoring session disease join from inner to left.
-- Stephen Long     08/24/2022 Added test name type name parameter and where criteria against test 
--                             requested.
-- Stephen Long     08/26/2022 Added additional checks on accession and entered date range checks.
-- Stephen Long     10/14/2022 Changed monitoring session disease function to monitoring session
--                             to sample disease function.
-- Stephen Long     10/18/2022 Added test disease ID to the query.
-- Stephen Long     12/29/2022 Removed sorting and pagination logic; business decision so records
--                             pending save could be shown at the top of the list prior to saving.
-- Stephen Long     01/12/2023 Updated for site filtration queries.
-- Stephen Long     01/31/2023 Added coalesce on collection and entered dates.
-- Stephen Long     02/03/2023 Added filtration indicator logic.
-- Stephen Long     03/02/2023 Added sent to organization sent to site ID and where criteria.
-- Stephen Long     03/14/2023 Fix on default sort order.
-- Stephen Long     04/24/2023 Bug fix for item 5738.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_TRANSFER_ADVANCED_SEARCH_GETList]
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
    @TestNameTypeName NVARCHAR(200) = NULL,
    @DiseaseID BIGINT = NULL,
    @TestStatusTypeID BIGINT = NULL,
    @TestResultTypeID BIGINT = NULL,
    @TestResultDateFrom DATETIME = NULL,
    @TestResultDateTo DATETIME = NULL,
    @PatientName NVARCHAR(200) = NULL,
    @FarmOwnerName NVARCHAR(200) = NULL,
    @SpeciesTypeID BIGINT = NULL,
    @TransferList VARCHAR(MAX) = NULL,
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
        DiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @VectorSessionDiseases TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
        DiseaseNames NVARCHAR(MAX) NOT NULL
    );
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL,
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
        ID BIGINT NOT NULL,
        SampleID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
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
    DECLARE @SampleStatusTypeListTable TABLE (ID BIGINT NOT NULL PRIMARY KEY);

    DECLARE @Favorites XML;

    BEGIN TRY
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

        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               1,
               CASE
                   WHEN tr.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN tr.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN tr.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN tr.idfsSite = @UserSiteID
                        OR @FiltrationIndicator = 0 THEN
                       1
                   ELSE
                       0
               END
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
        WHERE tr.intRowStatus = 0
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
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = tr.idfsSite
            INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                ON userSiteGroup.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = tr.idfsSite
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = tr.idfsSite
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
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = tr.idfsSite
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
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
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
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND sgs.idfsSite = tr.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = tr.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
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
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = tr.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
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
        WHERE tr.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)))
              AND a.GrantingActorSiteID = tr.idfsSite;

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
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               tom.idfMaterial,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
        WHERE tr.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = tr.idfsSite
        )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = tr.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT tr.idfTransferOut,
               tom.idfMaterial,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = tr.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbTransferOUT tr
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
        WHERE tr.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = tr.idfsSite
        )
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.datSampleStatusDate
              BETWEEN @DateFrom AND DATEADD(SECOND, -1, (DATEADD(DAY, 1, @DateTo)));

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT tr.idfTransferOut
            FROM dbo.tlbTransferOUT tr
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = tr.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        INSERT INTO @FinalResults
        SELECT tr.idfTransferOut,
               m.idfMaterial,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator),
               0
        FROM @Results res
            INNER JOIN dbo.tlbTransferOUT tr
                ON tr.idfTransferOut = res.ID
            INNER JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfTransferOut = tr.idfTransferOut
                   AND tom.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = tom.idfMaterial
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
                   AND t.blnExternalTest = 1
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = m.idfMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                   AND msd.intRowStatus = 0
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.tlbSpecies species
                ON species.idfSpecies = m.idfSpecies
                   AND species.intRowStatus = 0
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      (tr.idfTransferOut IN (
                                                SELECT CAST([Value] AS BIGINT)
                                                FROM dbo.FN_GBL_SYS_SplitList(@TransferList, NULL, ',')
                                            )
                      )
                      OR (@TransferList IS NULL)
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
                      tr.idfSendToOffice = @TransferredToOrganizationID
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
                      OR tr.TestRequested LIKE '%' + @TestNameTypeName + '%'
                      OR @TestNameTypeName IS NULL
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
                      (m.strCalculatedHumanName LIKE '%' + @PatientName + '%')
                      OR (@PatientName IS NULL)
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
                      tr.strBarcode LIKE '%' + @EIDSSTransferID + '%'
                      OR @EIDSSTransferID IS NULL
                  )
              AND (
                      m.strBarcode LIKE '%' + @EIDSSLaboratorySampleID + '%'
                      OR @EIDSSLaboratorySampleID IS NULL
                  )
        GROUP BY tr.idfTransferOut,
                 m.idfMaterial
        OPTION (RECOMPILE);

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        DECLARE @InProgressCount INT,
                @RecordCount INT = (
                                       SELECT COUNT(ID) FROM @FinalResults
                                   );

        IF @RecordCount > 10000
        BEGIN
            INSERT INTO @NarrowResults
            SELECT TOP 10000
                ID,
                SampleID,
                res.ReadPermissionIndicator,
                res.AccessToPersonalDataPermissionIndicator,
                res.AccessToGenderAndAgeDataPermissionIndicator,
                res.WritePermissionIndicator,
                res.DeletePermissionIndicator,
                99
            FROM @FinalResults res;

            SET @InProgressCount =
            (
                SELECT TOP 10000
                    COUNT(res.ID)
                FROM @NarrowResults res
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
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
                   fa.FunctionalAreaName,
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
                   IIF(
                      (
                          SELECT COUNT(t2.idfTesting)
                          FROM dbo.tlbTesting t2
                          WHERE t2.idfsTestStatus IN (   10001003,
                                                                  --In Progress
                                                         10001004,
                                                                  --Preliminary
                                                         10001005 --Not Started
                                                     )
                                AND t2.idfMaterial = m.idfMaterial
                      ) > 0,
                      1,
                      0) AS TestAssignedIndicator,
                   (CASE
                        WHEN transferredToOrganization.idfsSite IS NULL THEN
                            1
                        ELSE
                            0
                    END
                   ) AS NonEIDSSLaboratoryIndicator,
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
                   @InProgressCount AS InProgressCount,
                   10000 AS TotalRowCount
            FROM @NarrowResults res
                INNER JOIN dbo.tlbTransferOUT tr
                    ON tr.idfTransferOut = res.ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.SampleID
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
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
                LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) transferredToOrganization
                    ON transferredToOrganization.idfOffice = tr.idfSendToOffice
                       AND transferredToOrganization.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN @FunctionalAreas fa
                    ON fa.DepartmentID = m.idfInDepartment
                LEFT JOIN @SampleStatusTypes sampleStatusType
                    ON sampleStatusType.ID = m.idfsSampleStatus
                LEFT JOIN @AccessionConditionTypes accessionConditionType
                    ON accessionConditionType.ID = m.idfsAccessionCondition
            ORDER BY tr.strBarcode DESC
            OPTION (RECOMPILE);
        END
        ELSE
        BEGIN
            SET @InProgressCount =
            (
                SELECT COUNT(res.ID)
                FROM @FinalResults res
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
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
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
                   fa.FunctionalAreaName,
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
                   IIF(
                      (
                          SELECT COUNT(t2.idfTesting)
                          FROM dbo.tlbTesting t2
                          WHERE t2.idfsTestStatus IN (   10001003,
                                                                  --In Progress
                                                         10001004,
                                                                  --Preliminary
                                                         10001005 --Not Started
                                                     )
                                AND t2.idfMaterial = m.idfMaterial
                      ) > 0,
                      1,
                      0) AS TestAssignedIndicator,
                   (CASE
                        WHEN transferredToOrganization.idfsSite IS NULL THEN
                            1
                        ELSE
                            0
                    END
                   ) AS NonEIDSSLaboratoryIndicator,
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
                   @InProgressCount AS InProgressCount,
                   COUNT(*) OVER () AS TotalRowCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbTransferOUT tr
                    ON tr.idfTransferOut = res.ID
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.SampleID
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
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
                LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) transferredToOrganization
                    ON transferredToOrganization.idfOffice = tr.idfSendToOffice
                       AND transferredToOrganization.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                LEFT JOIN @FunctionalAreas fa
                    ON fa.DepartmentID = m.idfInDepartment
                LEFT JOIN @SampleStatusTypes sampleStatusType
                    ON sampleStatusType.ID = m.idfsSampleStatus
                LEFT JOIN @AccessionConditionTypes accessionConditionType
                    ON accessionConditionType.ID = m.idfsAccessionCondition
            ORDER BY tr.strBarcode DESC
            OPTION (RECOMPILE);
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
