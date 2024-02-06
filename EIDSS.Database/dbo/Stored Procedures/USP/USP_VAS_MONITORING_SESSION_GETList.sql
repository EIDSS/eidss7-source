-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_GETList
--
-- Description: Gets a list of veterinary active surveillance sessions for the veterinary module 
-- based on search criteria provided.
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mandar Kulkarni            Initial release.
-- Stephen Long    06/06/2018 Added campaign ID parameter and additional where clause check.
-- Stephen Long    11/18/2018 Renamed with correct module name, and updated parameter names and 
--                            result name field names.
-- Stephen Long    12/31/2018 Added pagination logic.
-- Stephen Long    05/01/2019 Removed additional field parameters to sync with use case, and 
--                            added campaign and monitoring session ID parameters.
-- Stephen Long    06/25/2019 Corrected session category type.
-- Stephen Long    07/06/2019 Added EIDSSCampaignID to the select.
-- Stephen Long    08/28/2019 Corrected date entered from and to when null dates are passed in on 
--                            one of the dates and the other has data.
-- Stephen Long    09/13/2019 Added settlement ID parameter and where clause.
-- Stephen Long    12/18/2019 Added legacy session ID parameter and where clause.
-- Stephen Long    01/22/2020 Added site list parameter for site filtration.
-- Stephen Long    02/02/2020 Added non-configurable filtration rules.
-- Stephen Long    02/20/2020 Added additional non-configurable rules.
-- Stephen Long    03/25/2020 Added if/else for first-level and second-level site types to bypass 
--                            non-configurable rules.
-- Stephen Long    04/17/2020 Changed join from FN_GBL_INSTITUTION to tstSite as not all sites have 
--                            organizations.
-- Stephen Long    05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long    06/22/2020 Added where criteria to the query when no site filtration is 
--                            required.
-- Stephen Long    07/07/2020 Added trim to EIDSS identifier like criteria.
-- Stephen Long    09/23/2020 Added descending to the order by clause.
-- Stephen Long    11/18/2020 Renamed organization ID and name to site ID and name.
-- Stephen Long    11/25/2020 Added configurable site filtration rules.
-- Stephen Long    12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long    12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long    12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long    01/28/2021 Added order by clause to handle user selected sorting across 
--                            pagination sets.
-- Stephen Long    04/02/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay   12/16/2021 Added tlbMonitoringSessionToDiagnosis to all joins involving 
--                            idfsDiagnosis and changed
--                            location hieararchy to use FN_GBL_LocationHierarchy_Flattened
-- Stephen Long    01/26/2022 Added the disease identifiers and names fields to the query.
-- Mike Kornegay   01/31/2022 Removed the left join on tlbMonitoringSessionToDiagnosis because it 
--                            was replaced
--							  by the new disease functions.
-- Mike Kornegay   03/10/2022 Added SessionStatusTypeID and ReportTypeID to return fields.
-- Mike Kornegay   03/20/2022 Corrected date comparisons to use binary compare instead of between.
-- Mike Kornegay   03/25/2022 Further changes to date comparisons to prevent sql overflow.
-- Stephen Long    03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Mike Kornegay   05/16/2022 Correct returned location levels to be country, region, rayon, 
--                            settlement
-- Mike Kornegay   05/19/2022 Correct location search to use node descendants instead of particular 
--                            idfsLocation
-- Stephen Long    06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay   06/13/2022 Changed ReportTypeID and ReportTypeName to point to the new SessionCategoryID - this
--							   field now stores the report type of the vet surveillance session so we do not depend 
--							   on the diagnosis list to determine type.
-- Mike Kornegay   07/27/2022 Changed CTE for paging and sorting.
-- Stephen Long    08/13/2022 Added session category type ID parameter and where criteria.
-- Stephen Long    09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Mike Kornegay   09/24/2022 Testing stored proc change.
-- Stephen Long    01/09/2023 Updated for site filtration queries.
-- Stephen Long    06/07/2023 Fix to use location de-normalized table.
-- Stephen Long    07/05/2023 Fix on site permission deletion query.
--
-- Testing Code:
--EXEC	@return_value = [dbo].[USP_VAS_MONITORING_SESSION_GETList]
--		@LanguageID = N'en-US',
--		@SessionID = NULL,
--		@LegacySessionID = NULL,
--		@CampaignID = NULL,
--		@CampaignKey = NULL,
--		@SessionStatusTypeID = NULL,
--		@DateEnteredFrom = NULL,
--		@DateEnteredTo = NULL,
--		@AdministrativeLevelID = 349690000000,
--		@DiseaseID = NULL,
--		@UserSiteID = 1100,
--		@UserOrganizationID = 709150000000,
--		@UserEmployeeID = 155568340001298,
--		@ApplySiteFiltrationIndicator = 0,
--		@SortColumn = N'SessionID',
--		@SortOrder = N'desc',
--		@PageNumber = 1,
--		@PageSize = 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_GETList]
(
    @LanguageID NVARCHAR(50),
    @SessionID NVARCHAR(200) = NULL,
    @LegacySessionID NVARCHAR(50) = NULL,
    @CampaignID NVARCHAR(200) = NULL,
    @CampaignKey BIGINT = NULL,
    @SessionStatusTypeID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @SessionCategoryTypeID BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'SessionID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize, 
            @LastRec INT = (@PageNumber * @PageSize + 1),
            @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IDX_1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
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

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any configurable filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT ms.idfMonitoringSession,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbMonitoringSession ms
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.intRowStatus = 0
                  AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                  AND (
                          ms.idfCampaign = @CampaignKey
                          OR @CampaignKey IS NULL
                      )
                  AND (
                          ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                          OR @SessionStatusTypeID IS NULL
                      )
                  AND (
                          msd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          (CAST(ms.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                          OR @LegacySessionID IS NULL
                      )
                  AND (
                          ms.SessionCategoryID = @SessionCategoryTypeID
                          OR @SessionCategoryTypeID IS NULL
                      )
            GROUP BY ms.idfMonitoringSession;
        END
        ELSE
        BEGIN
            INSERT INTO @Results
            SELECT ms.idfMonitoringSession,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbMonitoringSession ms
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.intRowStatus = 0
                  AND ms.idfsSite = @UserSiteID
                  AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session
                  AND (
                          ms.idfCampaign = @CampaignKey
                          OR @CampaignKey IS NULL
                      )
                  AND (
                          ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                          OR @SessionStatusTypeID IS NULL
                      )
                  AND (
                          msd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          (CAST(ms.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                          OR @LegacySessionID IS NULL
                      )
                  AND (
                          ms.SessionCategoryID = @SessionCategoryTypeID
                          OR @SessionCategoryTypeID IS NULL
                      )
            GROUP BY ms.idfMonitoringSession;

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply non-configurable filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            --
            -- Session data shall be available to all sites of the same administrative level.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537015;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537015;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the session was created.
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tstSite s
                        ON ms.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537015
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfMonitoringSession = ms.idfMonitoringSession
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537015
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );
            END;

            --
            -- Session data is always distributed across the sites where the disease reports are 
            -- linked to the session.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537016;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfParentMonitoringSession = ms.idfMonitoringSession
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537016
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND v.idfsSite = @UserSiteID;
            END;

            --
            -- Session data shall be available to all sites' organizations connected to the particular 
            -- session where samples were transferred out.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537017;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Samples transferred collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbMaterial m
                        ON ms.idfMonitoringSession = m.idfMonitoringSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT tout
                        ON toutm.idfTransferOut = tout.idfTransferOut
                           AND tout.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537017
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND tout.idfSendToOffice = @UserOrganizationID;

                INSERT INTO @FilteredResults
                SELECT ms.idfMonitoringSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMonitoringSession ms
                    INNER JOIN dbo.tlbMaterial m
                        ON ms.idfMonitoringSession = m.idfMonitoringSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537017
                WHERE ms.intRowStatus = 0
                      AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          );
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
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
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ms.idfsSite
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
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND sgs.idfsSite = ms.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
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
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ms.idfMonitoringSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbMonitoringSession ms
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
            WHERE ms.intRowStatus = 0
                  AND a.GrantingActorSiteID = ms.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = ID
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                    ON msd.idfMonitoringSession = ms.idfMonitoringSession
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = ms.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            WHERE ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
                  AND (
                          ms.idfCampaign = @CampaignKey
                          OR @CampaignKey IS NULL
                      )
                  AND (
                          ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                          OR @SessionStatusTypeID IS NULL
                      )
                  AND (
                          msd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (CAST(ms.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                          OR @LegacySessionID IS NULL
                      )
                  AND (
                          ms.SessionCategoryID = @SessionCategoryTypeID
                          OR @SessionCategoryTypeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END;

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = msd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ms.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
        GROUP BY ms.idfMonitoringSession;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMonitoringSession ms
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = msd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ms.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
        GROUP BY ms.idfMonitoringSession;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT ms.idfMonitoringSession
                        FROM dbo.tlbMonitoringSession ms
                            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                                ON msd.idfMonitoringSession = ms.idfMonitoringSession
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = msd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE ms.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = @UserEmployeeID
                    );

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT ms.idfMonitoringSession
            FROM dbo.tlbMonitoringSession ms
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = ms.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE ms.intRowStatus = 0
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
        SELECT ms.idfMonitoringSession,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbMonitoringSession ms
        WHERE ms.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = ms.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = ms.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ms.idfMonitoringSession,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ms.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbMonitoringSession ms
        WHERE ms.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = ms.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = ms.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
            INNER JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = res.ID
            LEFT JOIN dbo.tlbMonitoringSessionToDiagnosis msd
                ON msd.idfMonitoringSession = ms.idfMonitoringSession
            LEFT JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ms.idfCampaign
                   AND c.intRowStatus = 0
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = ms.idfsLocation
                   AND g.idfsLanguage = @LanguageCode
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND ms.SessionCategoryID IN ( 10502002, 10502009 ) -- Veterinary Active Surveillance Session (Avian and Livestock)
              AND (
                      ms.idfCampaign = @CampaignKey
                      OR @CampaignKey IS NULL
                  )
              AND (
                      ms.idfsMonitoringSessionStatus = @SessionStatusTypeID
                      OR @SessionStatusTypeID IS NULL
                  )
              AND (
                      msd.idfsDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      g.Level1ID = @AdministrativeLevelID
                      OR g.Level2ID = @AdministrativeLevelID
                      OR g.Level3ID = @AdministrativeLevelID
                      OR g.Level4ID = @AdministrativeLevelID
                      OR g.Level5ID = @AdministrativeLevelID
                      OR g.Level6ID = @AdministrativeLevelID
                      OR g.Level7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      (CAST(ms.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
              AND (
                      c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                      OR @CampaignID IS NULL
                  )
              AND (
                      LegacySessionID LIKE '%' + TRIM(@LegacySessionID) + '%'
                      OR @LegacySessionID IS NULL
                  )
              AND (
                      ms.SessionCategoryID = @SessionCategoryTypeID
                      OR @SessionCategoryTypeID IS NULL
                  )
        GROUP BY ID;

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'SessionID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ms.strMonitoringSessionID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ms.strMonitoringSessionID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       sessionStatus.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       sessionStatus.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ms.datEnteredDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ms.datEnteredDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.Level2Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.Level2Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.Level3Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.Level3Name
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS RecordCount,
                   res.ID AS SessionKey,
                   ms.strMonitoringSessionID AS SessionID,
                   ms.idfCampaign AS CampaignKey,
                   c.strCampaignID AS CampaignID,
                   sessionStatus.idfsReference AS SessionStatusTypeID,
                   ms.SessionCategoryID AS ReportTypeID,
                   ISNULL(reportType.name, reportType.strDefault) AS ReportTypeName,
                   sessionStatus.name AS SessionStatusTypeName,
                   ms.datStartDate AS StartDate,
                   ms.datEndDate AS EndDate,
                   diseaseIDs.diseaseIDs AS DiseaseIdentifiers,
                   diseaseNames.diseaseNames AS DiseaseNames,
                   '' AS DiseaseName,
                   lh.Level1Name AS AdministrativeLevel0Name,
                   lh.Level2Name AS AdministrativeLevel1Name,
                   lh.Level3Name AS AdministrativeLevel2Name,
                   lh.Level4Name AS SettlementName,
                   ms.datEnteredDate AS EnteredDate,
                   ISNULL(p.strFirstName, '') + ' ' + ISNULL(p.strFamilyName, '') AS EnteredByPersonName,
                   ms.idfsSite AS SiteKey,
                   s.strSiteName AS SiteName,
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
                   (
                       SELECT COUNT(*)
                       FROM dbo.tlbMonitoringSession
                       WHERE intRowStatus = 0
                             AND SessionCategoryID = 10502002 -- Veterinary Avian Active Surveillance Session
                             OR SessionCategoryID = 10502009 -- Veterinary Livestock Active Surveillance Session
                   ) AS TotalCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = res.ID
                LEFT JOIN dbo.MonitoringSessionToSampleType mss
                    ON ms.idfMonitoringSession = mss.idfMonitoringSession
                CROSS APPLY
            (
                SELECT dbo.FN_GBL_SESSION_DISEASEIDS_GET(ms.idfMonitoringSession) diseaseIDs
            ) diseaseIDs
                CROSS APPLY
            (
                SELECT dbo.FN_GBL_SESSION_DISEASE_NAMES_GET(ms.idfMonitoringSession, @LanguageID) diseaseNames
            ) diseaseNames
                LEFT JOIN dbo.tstSite s
                    ON s.idfsSite = ms.idfsSite
                LEFT JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = ms.idfCampaign
                       AND c.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000117) sessionStatus
                    ON sessionStatus.idfsReference = ms.idfsMonitoringSessionStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000502) reportType
                    ON reportType.idfsReference = ms.SessionCategoryID
                INNER JOIN dbo.gisLocationDenormalized lh
                    ON lh.idfsLocation = ms.idfsLocation
                       AND lh.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = ms.idfPersonEnteredBy
            WHERE ms.intRowStatus = 0
           )
        SELECT SessionKey,
               SessionID,
               CampaignKey,
               CampaignID,
               SessionStatusTypeID,
               ReportTypeID,
               ReportTypeName,
               SessionStatusTypeName,
               StartDate,
               EndDate,
               DiseaseIdentifiers,
               DiseaseNames,
               DiseaseName,
               AdministrativeLevel0Name,
               AdministrativeLevel1Name,
               AdministrativeLevel2Name,
               SettlementName,
               EnteredDate,
               EnteredByPersonName,
               SiteKey,
               SiteName,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator,
               RecordCount,
               TotalCount,
               CurrentPage = @PageNumber,
               TotalPages = (RecordCount / @PageSize) + IIF(RecordCount % @PageSize > 0, 1, 0)
        FROM paging
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
