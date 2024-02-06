-- ================================================================================================
-- Name: USP_VCTS_SURVEILLANCE_SESSION_GetList
--
-- Description: Gets a list of vector surveillance sessions filtered by various criteria.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/31/2018 Added additional search parameters
-- Maheshwar Deo	03/08/2019 Fixed filter for @DiseaseID
-- Stephen Long     07/19/2019 Added summary disease ID and join.
-- Stephen Long     01/22/2020 Converted site ID to site list for site filtration.
-- Stephen Long     02/19/2020 Added non-configurable site filtration rules.
-- Stephen Long     02/26/2020 Corrected all criteria where clauses; returned incorrect results.
-- Stephen Long     03/25/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to EIDSS identifier like criteria.
-- Doug Albanese	10/16/2020 Added Outbreak's EIDSS ID
-- Doug Albanese	10/16/2020 Added Outbreak's Session Start Date
-- Doug Albanese	11/11/2020 Modified secondary filtering
-- Doug Albanese	11/20/2020 Added dblAlignment (Direction)
-- Stephen Long     11/27/2020 Added configurable site filtration rules.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Added intRowStatus check on disease filtration insert rules.
-- Doug Albanese	01/21/2021 Change the WHERE claus to detect shared vector types so that it is 
--                             no so strict on records being returned.
-- Stephen Long     04/02/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay	11/05/2021 Added group by surveillance session id to filtration 
--							   intermediate results so final cte join is correct.
-- Stephen Long     11/05/2021 Added vector type ID's and disease ID's to the query.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay	07/04/2022 Fixed sorting by pointing to correct location tables in final query.
-- Mike Kornegay	07/05/2022 Fixed search by disease and vector type.
-- Mike Kornegay	08/03/2022 Add order by in final select and change location tables back to 
--                             inner join.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Mike Kornegay	10/06/2022 Move order by back to CTE row number partition for performance and 
--                             correct date clauses.
-- Stephen Long     01/09/2023 Updated for site filtration queries.
-- Mike Kornegay	01/31/2023 Correct joins in final result query.
-- Stephen Long     06/15/2023 Fix on location hierarchy on site filtration rule.
-- Stephen Long     07/05/2023 Fix on site permission deletion query.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VCTS_SURVEILLANCE_SESSION_GetList]
(
    @LanguageID NVARCHAR(50),
    @SessionID NVARCHAR(200) = NULL,
    @FieldSessionID NVARCHAR(200) = NULL,
    @StatusTypeID BIGINT = NULL,
    @VectorTypeID NVARCHAR(MAX) = NULL,
    @SpeciesTypeID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @DiseaseGroupID NVARCHAR(MAX) = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @StartDateFrom DATETIME = NULL,
    @StartDateTo DATETIME = NULL,
    @EndDateFrom DATETIME = NULL,
    @EndDateTo DATETIME = NULL,
    @OutbreakKey BIGINT = NULL,
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
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                             ));
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
            SELECT vss.idfVectorSurveillanceSession,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbVectorSurveillanceSession vss
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = vss.idfLocation
                       AND gl.intRowStatus = 0
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = gl.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPEIDS_GET(vss.idfVectorSurveillanceSession) vectorTypeIDs
            ) vectorTypeIDs
                LEFT JOIN dbo.tlbVector v
                    ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                       AND v.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000141) vectorSubType
                    ON vectorSubType.idfsReference = v.idfsVectorSubType
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESIDS_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseaseIDs
            ) diseaseIDs
            WHERE vss.intRowStatus = 0
                  AND (
                          vss.idfsVectorSurveillanceStatus = @StatusTypeID
                          OR @StatusTypeID IS NULL
                      )
                  AND (
                          CHARINDEX(@VectorTypeID, vectorTypeIDs) > 0
                          OR @VectorTypeID IS NULL
                      )
                  AND (
                          vectorSubType.idfsReference = @SpeciesTypeID
                          OR @SpeciesTypeID IS NULL
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
                          vss.idfOUtBreak = @OutbreakKey
                          OR @OutbreakKey IS NULL
                      )
                  AND (
                          (
                              (
                                  CAST(vss.datStartDate AS DATE) >= @StartDateFrom
                                  AND @StartDateTo IS NULL
                              )
                              OR (
                                     CAST(vss.datStartDate AS DATE) <= @StartDateTo
                                     AND @StartDateFrom IS NULL
                                 )
                              OR (CAST(vss.datStartDate AS DATE)
                  BETWEEN @StartDateFrom AND @StartDateTo
                                 )
                          )
                          OR (
                                 @StartDateFrom IS NULL
                                 AND @StartDateTo IS NULL
                             )
                      )
                  AND (
                          (
                              (
                                  CAST(vss.datCloseDate AS DATE) >= @EndDateFrom
                                  AND @EndDateTo IS NULL
                              )
                              OR (
                                     CAST(vss.datCloseDate AS DATE) <= @EndDateTo
                                     AND @EndDateFrom IS NULL
                                 )
                              OR (CAST(vss.datCloseDate AS DATE)
                  BETWEEN @EndDateFrom AND @EndDateTo
                                 )
                          )
                          OR (
                                 @EndDateFrom IS NULL
                                 AND @EndDateTo IS NULL
                             )
                      )
                  AND (
                          vss.strSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          vss.strFieldSessionID LIKE '%' + TRIM(@FieldSessionID) + '%'
                          OR @FieldSessionID IS NULL
                      )
                  AND (
                          CHARINDEX(CAST(@DiseaseID AS NVARCHAR(2000)), diseaseIDs) > 0
                          OR @DiseaseID IS NULL
                      )
            GROUP BY vss.idfVectorSurveillanceSession;
        END
        ELSE
        BEGIN
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
            -- Session data shall be available to all sites' organizations connected to the particular 
            -- session.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537019;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Collected and identified by organizations for any vectors/pools
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbVector v
                        ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE vss.intRowStatus = 0
                      AND (
                              v.idfCollectedByOffice = @UserOrganizationID
                              OR v.idfIdentifiedByOffice = @UserOrganizationID
                          );

                -- Collected by and sent to organizations for any samples
                INSERT INTO @FilteredResults
                SELECT m.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVectorSurveillanceSession vss
                        ON vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
                           AND vss.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Tested by organization for any laboratory test
                INSERT INTO @FilteredResults
                SELECT m.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVectorSurveillanceSession vss
                        ON vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
                           AND vss.intRowStatus = 0
                    INNER JOIN dbo.tlbTesting t
                        ON t.idfMaterial = m.idfMaterial
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE m.intRowStatus = 0
                      AND t.idfTestedByOffice = @UserOrganizationID
                GROUP BY m.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Tested by organization for any field test
                INSERT INTO @FilteredResults
                SELECT m.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVectorSurveillanceSession vss
                        ON vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
                           AND vss.intRowStatus = 0
                    INNER JOIN dbo.tlbPensideTest p
                        ON p.idfMaterial = m.idfMaterial
                           AND p.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE m.intRowStatus = 0
                      AND p.idfTestedByOffice = @UserOrganizationID
                GROUP BY m.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Sent to organizations for any sample transfers
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537021;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbMaterial m
                        ON vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT tout
                        ON toutm.idfTransferOut = tout.idfTransferOut
                           AND tout.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537021
                WHERE vss.intRowStatus = 0
                      AND tout.idfSendToOffice = @UserOrganizationID
                GROUP BY vss.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Session data shall be available to all sites of the same administrative level.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537018;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537018;

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
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tstSite s
                        ON vss.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.intRowStatus = 0
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

                -- Administrative level specified in the rule of the session location, if completed
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = vss.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.intRowStatus = 0
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

                -- Administrative level specified in the rule of any vector location, if completed.
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbVector v
                        ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = v.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.intRowStatus = 0
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

                -- Administration level specified in the rule of the location of any session summary record, if completed.
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                        ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                           AND vsss.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = vsss.idfGeoLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.intRowStatus = 0
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

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the non-configurable rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
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
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
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
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.intRowStatus = 0
                  AND sgs.idfsSite = vss.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteID = vss.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
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
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteID = vss.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
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
            WHERE vss.intRowStatus = 0
                  AND a.GrantingActorSiteID = vss.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbVectorSurveillanceSession vss
                    ON vss.idfVectorSurveillanceSession = ID
                LEFT JOIN tlbGeoLocation gl
                    ON gl.idfGeoLocation = vss.idfLocation
                       AND gl.intRowStatus = 0
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = gl.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPEIDS_GET(vss.idfVectorSurveillanceSession) vectorTypeIds
            ) vectorTypeIds
                LEFT JOIN dbo.tlbVector v
                    ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                       AND v.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000141) vectorSubType
                    ON vectorSubType.idfsReference = v.idfsVectorSubType
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESIDS_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseaseIDs
            ) diseaseIDs
            WHERE (
                      vss.idfsVectorSurveillanceStatus = @StatusTypeID
                      OR @StatusTypeID IS NULL
                  )
                  AND (
                          CHARINDEX(@VectorTypeID, vectorTypeIds) > 0
                          OR @VectorTypeID IS NULL
                      )
                  AND (
                          vectorSubType.idfsReference = @SpeciesTypeID
                          OR @SpeciesTypeID IS NULL
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
                          vss.idfOUtBreak = @OutbreakKey
                          OR @OutbreakKey IS NULL
                      )
                  AND (
                          (
                              (
                                  CAST(vss.datStartDate AS DATE) >= @StartDateFrom
                                  AND @StartDateTo IS NULL
                              )
                              OR (
                                     CAST(vss.datStartDate AS DATE) <= @StartDateTo
                                     AND @StartDateFrom IS NULL
                                 )
                              OR (CAST(vss.datStartDate AS DATE)
                  BETWEEN @StartDateFrom AND @StartDateTo
                                 )
                          )
                          OR (
                                 @StartDateFrom IS NULL
                                 AND @StartDateTo IS NULL
                             )
                      )
                  AND (
                          (
                              (
                                  CAST(vss.datCloseDate AS DATE) >= @EndDateFrom
                                  AND @EndDateTo IS NULL
                              )
                              OR (
                                     CAST(vss.datCloseDate AS DATE) <= @EndDateTo
                                     AND @EndDateFrom IS NULL
                                 )
                              OR (CAST(vss.datCloseDate AS DATE)
                  BETWEEN @EndDateFrom AND @EndDateTo
                                 )
                          )
                          OR (
                                 @EndDateFrom IS NULL
                                 AND @EndDateTo IS NULL
                             )
                      )
                  AND (
                          vss.strSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
                  AND (
                          vss.strFieldSessionID LIKE '%' + TRIM(@FieldSessionID) + '%'
                          OR @FieldSessionID IS NULL
                      )
                  AND (
                          CHARINDEX(CAST(@DiseaseID AS NVARCHAR(2000)), diseaseIDs) > 0
                          OR @DiseaseID IS NULL
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
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT vss.idfVectorSurveillanceSession
                        FROM dbo.tlbVectorSurveillanceSession vss
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                                   AND vsss.intRowStatus = 0
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                                   AND vssd.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = vssd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE vss.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVectorSurveillanceSession vss
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vssd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND vss.intRowStatus = 0
              AND oa.idfActor = egm.idfEmployeeGroup;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vssd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVectorSurveillanceSession vss
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vssd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND vss.intRowStatus = 0
              AND oa.idfActor = @UserEmployeeID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT vss.idfVectorSurveillanceSession
                        FROM dbo.tlbVectorSurveillanceSession vss
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                                   AND vsss.intRowStatus = 0
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                                   AND vssd.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = vssd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE vss.intRowStatus = 0
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
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vss.idfVectorSurveillanceSession
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vss.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vss.intRowStatus = 0
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
        SELECT vss.idfVectorSurveillanceSession,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVectorSurveillanceSession vss
        WHERE vss.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vss.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vss.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVectorSurveillanceSession vss
        WHERE vss.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vss.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = vss.idfsSite
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
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = res.ID
            LEFT JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            LEFT JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            LEFT JOIN tlbGeoLocation gl
                ON gl.idfGeoLocation = vss.idfLocation
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = gl.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
            CROSS APPLY
        (
            SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPEIDS_GET(vss.idfVectorSurveillanceSession) vectorTypeIDs
        ) vectorTypeIDs
            LEFT JOIN dbo.tlbVector v
                ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND v.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000141) vectorSubType
                ON vectorSubType.idfsReference = v.idfsVectorSubType
            CROSS APPLY
        (
            SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESIDS_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseaseIDs
        ) diseaseIDs
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      vss.idfsVectorSurveillanceStatus = @StatusTypeID
                      OR @StatusTypeID IS NULL
                  )
              AND (
                      CHARINDEX(@VectorTypeID, vectorTypeIDs) > 0
                      OR @VectorTypeID IS NULL
                  )
              AND (
                      vectorSubType.idfsReference = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
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
                      vss.idfOUtBreak = @OutbreakKey
                      OR @OutbreakKey IS NULL
                  )
              AND (
                      (
                          (
                              CAST(vss.datStartDate AS DATE) >= @StartDateFrom
                              AND @StartDateTo IS NULL
                          )
                          OR (
                                 CAST(vss.datStartDate AS DATE) <= @StartDateTo
                                 AND @StartDateFrom IS NULL
                             )
                          OR (CAST(vss.datStartDate AS DATE)
              BETWEEN @StartDateFrom AND @StartDateTo
                             )
                      )
                      OR (
                             @StartDateFrom IS NULL
                             AND @StartDateTo IS NULL
                         )
                  )
              AND (
                      (
                          (
                              CAST(vss.datCloseDate AS DATE) >= @EndDateFrom
                              AND @EndDateTo IS NULL
                          )
                          OR (
                                 CAST(vss.datCloseDate AS DATE) <= @EndDateTo
                                 AND @EndDateFrom IS NULL
                             )
                          OR (CAST(vss.datCloseDate AS DATE)
              BETWEEN @EndDateFrom AND @EndDateTo
                             )
                      )
                      OR (
                             @EndDateFrom IS NULL
                             AND @EndDateTo IS NULL
                         )
                  )
              AND (
                      vss.strSessionID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
              AND (
                      vss.strFieldSessionID LIKE '%' + TRIM(@FieldSessionID) + '%'
                      OR @FieldSessionID IS NULL
                  )
              AND (
                      CHARINDEX(CAST(@DiseaseID AS NVARCHAR(2000)), diseaseIDs) > 0
                      OR @DiseaseID IS NULL
                  )
        GROUP BY ID;

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'SessionID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       vss.strSessionID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       vss.strSessionID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       sessionStatusType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SessionStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       sessionStatusType.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'StartDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       vss.datStartDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'StartDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       vss.datStartDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'CloseDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       vss.datCloseDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'CloseDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       vss.datCloseDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel2Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel2Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel3Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel3Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'VectorType'
                                                        AND @SortOrder = 'ASC' THEN
                                                       vectorTypes.vectorTypes
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'VectorType'
                                                        AND @SortOrder = 'DESC' THEN
                                                       vectorTypes.vectorTypes
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Disease'
                                                        AND @SortOrder = 'ASC' THEN
                                                       diseases.diseases
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Disease'
                                                        AND @SortOrder = 'DESC' THEN
                                                       diseases.diseases
                                               END DESC
                                     ) AS ROWNUM,
                   idfVectorSurveillanceSession AS SessionKey,
                   strSessionID AS SessionID,
                   vss.strFieldSessionID AS FieldSessionID,
                   vss.idfOUtBreak AS OutbreakKey,
                   o.strOutbreakID AS OutbreakID,
                   o.datStartDate AS OutbreakStartDate,
                   vectorTypeIDs.vectorTypeIDs AS VectorTypeIDs,
                   vectorTypes.vectorTypes AS Vectors,
                   diseaseIDs.diseaseIDs AS DiseaseIDs,
                   diseases.diseases AS Diseases,
                   statusType.name AS StatusTypeName,
                   lh.AdminLevel2Name AS AdministrativeLevel1Name,
                   lh.AdminLevel3Name AS AdministrativeLevel2Name,
                   lh.AdminLevel4Name AS SettlementName,
                   gl.dblLatitude AS Latitude,
                   gl.dblLongitude AS Longitude,
                   vss.datStartDate AS StartDate,
                   vss.datCloseDate AS CloseDate,
                   vss.idfsSite AS SiteID,
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
                   COUNT(*) OVER () AS RecordCount,
                   (
                       SELECT COUNT(*)
                       FROM dbo.tlbVectorSurveillanceSession
                       WHERE intRowStatus = 0
                   ) AS TotalCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbVectorSurveillanceSession vss
                    ON vss.idfVectorSurveillanceSession = res.ID
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000133) sessionStatusType
                    ON sessionStatusType.idfsReference = vss.idfsVectorSurveillanceStatus
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = vss.idfLocation
                INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESNAMES_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseases
            ) diseases
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPENAMES_GET(vss.idfVectorSurveillanceSession, @LanguageID) vectorTypes
            ) vectorTypes
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESIDS_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseaseIDs
            ) diseaseIDs
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPEIDS_GET(vss.idfVectorSurveillanceSession) vectorTypeIDs
            ) vectorTypeIDs
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000133) statusType
                    ON statusType.idfsReference = vss.idfsVectorSurveillanceStatus
                LEFT JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = vss.idfOutbreak
                       AND o.intRowStatus = 0
           )
        SELECT SessionKey,
               SessionID,
               FieldSessionID,
               OutbreakKey,
               OutbreakID,
               OutbreakStartDate,
               VectorTypeIDs,
               Vectors,
               DiseaseIDs,
               Diseases,
               StatusTypeName,
               AdministrativeLevel1Name,
               AdministrativeLevel2Name,
               SettlementName,
               Latitude,
               Longitude,
               StartDate,
               CloseDate,
               SiteID,
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
              AND RowNum < @LastRec
        ORDER BY CASE
                     WHEN @SortColumn = 'SessionID'
                          AND @SortOrder = 'ASC' THEN
                         SessionID
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'SessionID'
                          AND @SortOrder = 'DESC' THEN
                         SessionID
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'SessionStatusTypeName'
                          AND @SortOrder = 'ASC' THEN
                         StatusTypeName
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'SessionStatusTypeName'
                          AND @SortOrder = 'DESC' THEN
                         StatusTypeName
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'StartDate'
                          AND @SortOrder = 'ASC' THEN
                         StartDate
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'StartDate'
                          AND @SortOrder = 'DESC' THEN
                         StartDate
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'CloseDate'
                          AND @SortOrder = 'ASC' THEN
                         CloseDate
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'CloseDate'
                          AND @SortOrder = 'DESC' THEN
                         CloseDate
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'AdministrativeLevel1Name'
                          AND @SortOrder = 'ASC' THEN
                         AdministrativeLevel2Name
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'AdministrativeLevel1Name'
                          AND @SortOrder = 'DESC' THEN
                         AdministrativeLevel2Name
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'AdministrativeLevel2Name'
                          AND @SortOrder = 'ASC' THEN
                         SettlementName
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'AdministrativeLevel2Name'
                          AND @SortOrder = 'DESC' THEN
                         SettlementName
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'VectorType'
                          AND @SortOrder = 'ASC' THEN
                         Vectors
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'VectorType'
                          AND @SortOrder = 'DESC' THEN
                         Vectors
                 END DESC,
                 CASE
                     WHEN @SortColumn = 'Disease'
                          AND @SortOrder = 'ASC' THEN
                         Diseases
                 END ASC,
                 CASE
                     WHEN @SortColumn = 'Disease'
                          AND @SortOrder = 'DESC' THEN
                         Diseases
                 END DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
