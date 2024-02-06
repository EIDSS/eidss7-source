-- ================================================================================================
-- Name: USP_GBL_ReportForm_GetList
--
-- Description: Get list of weekly reports that fit search criteria entered.
--          
-- Author: Manickandan Govindarajan

-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Manickandan Govindarajan 03/06/2022 Updated USING Locatin Hieracy Denormalized table
-- Michael Brown	        03/05/2022 Added SentByPersonName, and EnteredByPersonName to select 
--                                     statement at end of proc.
-- Mark Wilson		        04/06/2022 Updated to use new location function.
-- Stephen Long             06/09/2023 Fix to only use location hierarchy function.
-- Ann Xiong		        06/14/2023 Updated to use week end date instead of @EndDate to return records whose datFinishDate is week end date.
--
-- Testing code:
--
/*

EXECUTE [dbo].[USP_GBL_ReportForm_GetList] 
	@LanguageID = 'en-US',
	@pageNo = 1,
	@PageSize = 10,
	@SortColumn = 'EIDSSReportID',
	@SortOrder = 'asc',
	@SiteID = 5,
	@ReportFormTypeID = NULL,
	@EIDSSReportID = NULL,
	@AdministrativeUnitTypeID = NULL, 
	@TimeIntervalTypeID = NULL,
	@StartDate = NULL,
	@EndDate = NULL,
	@AdministrativeLevelID = 3330000000,
	@OrganizationID = NULL,
	@SiteList = NULL,
	@SelectAllIndicator = 0,
	@ApplySiteFiltrationIndicator = 0
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_ReportForm_GetList]
(
    @LanguageID AS NVARCHAR(50),
    @pageNo INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'EIDSSReportID',
    @SortOrder NVARCHAR(4) = 'ASC',
    @SiteID BIGINT,
    @ReportFormTypeID AS BIGINT = NULL,
    @EIDSSReportID AS NVARCHAR(400) = NULL,
    @AdministrativeUnitTypeID AS BIGINT = NULL,
    @TimeIntervalTypeID AS BIGINT = NULL,
    @StartDate AS DATETIME = NULL,
    @EndDate AS DATETIME = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @OrganizationID BIGINT = NULL,
    @SiteList VARCHAR(MAX) = NULL,
    @SelectAllIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID),
            @firstRec INT = (@pageNo - 1) * @pagesize,
            @lastRec INT = (@pageNo * @pageSize + 1);
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
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

        IF @SelectAllIndicator = 1
        BEGIN
            SET @PageSize = 100000;
            SET @PageNo = 1;
        END;

        -- ========================================================================================
        -- NO SITE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT ac.idfReportForm,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbReportForm ac
                INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = ac.idfsAdministrativeUnit
                       AND lh.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.trtStringNameTranslation per
                    ON per.idfsBaseReference = CASE
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091002 /* Day */
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6 THEN
                                                       10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
                                                   WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091001 /* Month */
                                                   WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091003 /* Quarter */
                                                   WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091005 /* Year */
                                               END
                       AND per.idfsLanguage = @LanguageCode
            WHERE ac.intRowStatus = 0
                  AND (
                          ac.idfsReportFormType = @ReportFormTypeID
                          OR @ReportFormTypeID IS NULL
                      )
                  AND (
                          ac.idfSentByOffice = @OrganizationID
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          (
                              lh.AdminLevel1ID = @AdministrativeLevelID
                              OR lh.AdminLevel2ID = @AdministrativeLevelID
                              OR lh.AdminLevel3ID = @AdministrativeLevelID
                              OR lh.AdminLevel4ID = @AdministrativeLevelID
                              OR lh.AdminLevel5ID = @AdministrativeLevelID
                              OR lh.AdminLevel6ID = @AdministrativeLevelID
                              OR lh.AdminLevel7ID = @AdministrativeLevelID
                          )
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          per.idfsBaseReference = @TimeIntervalTypeID
                          OR @TimeIntervalTypeID IS NULL
                      )
                  AND (
                          ac.datStartDate >= @StartDate
                          OR @StartDate IS NULL
                      )
                  AND (
                          ac.datFinishDate <= @EndDate
                          OR @EndDate IS NULL
                      )
                  AND (
                          ac.strReportFormID LIKE '%' + @EIDSSReportID + '%'
                          OR @EIDSSReportID IS NULL
                      );
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
            -- DEFAULT SITE FILTRATION RULES
            --
            -- Apply non-configurable site filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            --
            -- Weekly report data shall be available to all sites' organizations 
            -- connected to the particular report.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 16;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Entered by and notification received by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT a.idfReportForm,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbReportForm a
                WHERE a.intRowStatus = 0
                      AND (
                              a.idfEnteredByOffice = @OrganizationID
                              OR a.idfSentByOffice = @OrganizationID
                          );
            END;

            --
            -- Weekly report data shall be available to all sites of the same 
            -- administrative level specified in the rule.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 16;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 16;

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

                -- Administrative level specified in the rule of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfReportForm,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbReportForm ac
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = ac.idfsAdministrativeUnit
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 16
                WHERE ac.intRowStatus = 0
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
                          )
                      AND ac.idfReportForm NOT IN (
                                                      SELECT ID FROM @FilteredResults
                                                  );

                -- Administrative level of the settlement of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfReportForm,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbReportForm ac
                    INNER JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement
                        ON settlement.idfsReference = ac.idfsAdministrativeUnit
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 16
                WHERE ac.intRowStatus = 0
                      AND (ac.idfReportForm NOT IN (
                                                       SELECT ID FROM @FilteredResults
                                                   )
                          );
            END;

            -- =======================================================================================
            -- CONFIGURABLE SITE FILTRATION RULES
            -- 
            -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the non-configurable rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @SiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @SiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @SiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND sgs.idfsSite = ag.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfReportForm,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbReportForm ag
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @SiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.intRowStatus = 0
                  AND a.GrantingActorSiteID = ag.idfsSite;
        END;

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
            SELECT rf.idfReportForm
            FROM dbo.tlbReportForm rf
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = rf.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE rf.intRowStatus = 0
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
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
        SELECT rf.idfReportForm,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbReportForm rf
        WHERE rf.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = rf.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbReportForm rf
                ON rf.idfReportForm = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = rf.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        (
            ID,
            ReadPermissionIndicator,
            AccessToPersonalDataPermissionIndicator,
            AccessToGenderAndAgeDataPermissionIndicator,
            WritePermissionIndicator,
            DeletePermissionIndicator
        )
        SELECT rf.idfReportForm,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = rf.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbReportForm rf
        WHERE rf.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = rf.idfsSite
        );

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT rf.idfReportForm
                        FROM dbo.tlbReportForm rf
                            INNER JOIN @UserSitePermissions usp
                                ON usp.SiteID = rf.idfsSite
                        WHERE usp.Permission = 4 -- Deny permission
                              AND usp.PermissionTypeID = 10059003 -- Read permission
                    );

        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @sortColumn = 'EIDSSReportID'
                                                        AND @SortOrder = 'asc' THEN
                                                       ac.idfReportForm
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'EIDSSReportID'
                                                        AND @SortOrder = 'desc' THEN
                                                       ac.idfReportForm
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'StartDate'
                                                        AND @SortOrder = 'asc' THEN
                                                       ac.datStartDate
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'StartDate'
                                                        AND @SortOrder = 'desc' THEN
                                                       ac.datStartDate
                                               END DESC,
                                               CASE
                                                   WHEN @sortColumn = 'EndDate'
                                                        AND @SortOrder = 'asc' THEN
                                                       ac.datFinishDate
                                               END ASC,
                                               CASE
                                                   WHEN @sortColumn = 'EndDate'
                                                        AND @SortOrder = 'desc' THEN
                                                       ac.datFinishDate
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   ac.idfReportForm AS ReportFormID,
                   ac.idfsReportFormType AS ReportFormTypeID,
                   ac.idfsAdministrativeUnit AS AdministrativeUnitID,
                   ac.idfSentByOffice AS SentByOrganizationID,
                   SentByOffice.AbbreviatedName AS SentByOrganizationName,
                   ac.idfSentByPerson AS SentByPersonID,
                   ac.idfEnteredByOffice AS EnteredByOrganizationID,
                   EnteredByOffice.AbbreviatedName AS EnteredByOrganizationName,
                   ac.idfEnteredByPerson AS EnteredByPersonID,
                   dbo.FN_GBL_ConcatFullName(
                                                EnteredByPerson.strFamilyName,
                                                EnteredByPerson.strFirstName,
                                                EnteredByPerson.strSecondName
                                            ) AS SentByPersonName,
                   EnteredByPerson.strFamilyName + ', ' + EnteredByPerson.strFirstName AS EnteredByPersonName,
                   dbo.FN_GBL_FormatDate(ac.datSentByDate, 'mm/dd/yyyy') AS SentByDate,
                   ac.datSentByDate AS DisplaySentByDate,
                   dbo.FN_GBL_FormatDate(ac.datEnteredByDate, 'mm/dd/yyyy') AS EnteredByDate,
                   ac.datEnteredByDate AS DisplayEnteredByDate,
                   dbo.FN_GBL_FormatDate(ac.datStartDate, 'mm/dd/yyyy') AS StartDate,
                   ac.datStartDate AS DisplayStartDate,
                   dbo.FN_GBL_FormatDate(ac.datFinishDate, 'mm/dd/yyyy') AS FinishDate,
                   ac.datFinishDate AS DisplayFinishDate,
                   ac.strReportFormID AS EIDSSReportID,
                   lh.LevelType AS AdministrativeUnitTypeName,
                   ac.idfsDiagnosis,
                   br.strDefault AS diseaseDefaultName,
                   ISNULL(diagnosis.strTextString, br.strDefault) AS diseaseName,
                   diagnosis.strTextString AS Diagnosis,
                   ac.Total,
                   ac.Notified,
                   ac.Comments,
                   lh.Level1ID AS AdminLevel0,
                   lh.Level1Name AS AdminLevel0Name,
                   lh.Level2ID AS AdminLevel1,
                   lh.Level2Name AS AdminLevel1Name,
                   lh.Level3ID AS AdminLevel2,
                   lh.Level3Name AS AdminLevel2Name,
                   lh.Level4ID AS idfsSettlement,
                   lh.Level4Name AS SettlementName,
                   per.idfsBaseReference AS PeriodTypeID,
                   per.strTextString AS PeriodTypeName,
                   '0' AS RowSelectionIndicator
            FROM dbo.tlbReportForm ac
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) EnteredByOffice
                    ON ac.idfEnteredByOffice = EnteredByOffice.idfOffice
                LEFT JOIN dbo.tlbPerson EnteredByPerson
                    ON ac.idfEnteredByPerson = EnteredByPerson.idfPerson
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) SentByOffice
                    ON ac.idfSentByOffice = SentByOffice.idfOffice
                INNER JOIN dbo.gisLocationDenormalized lh
                    ON lh.idfsLocation = ac.idfsAdministrativeUnit
                       AND lh.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.trtStringNameTranslation per
                    ON per.idfsBaseReference = CASE
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091002 /* Day */
                                                   WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6 THEN
                                                       10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
                                                   WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091001 /* Month */
                                                   WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091003 /* Quarter */
                                                   WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0 THEN
                                                       10091005 /* Year */
                                               END
                       AND per.idfsLanguage = @LanguageCode
                JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = ac.idfsDiagnosis
                LEFT JOIN dbo.trtStringNameTranslation diagnosis
                    ON diagnosis.idfsBaseReference = ac.idfsDiagnosis
                       AND diagnosis.idfsLanguage = @LanguageCode
            WHERE ac.intRowStatus = 0
                  AND (
                          ac.idfsReportFormType = @ReportFormTypeID
                          OR @ReportFormTypeID IS NULL
                      )
                  AND (
                          ac.idfSentByOffice = @OrganizationID
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          per.idfsBaseReference = @TimeIntervalTypeID
                          OR @TimeIntervalTypeID IS NULL
                      )
                  AND (
                          ac.datStartDate >= @StartDate
                          OR @StartDate IS NULL
                      )
                  AND (
                          ac.datFinishDate <= DATEADD(DAY, 7 - DATEPART(WEEKDAY, @EndDate), CAST(@EndDate AS DATE))
                          OR @EndDate IS NULL
                      )
                  AND (
                          (
                              lh.Level1ID = @AdministrativeLevelID
                              OR lh.Level2ID = @AdministrativeLevelID
                              OR lh.Level3ID = @AdministrativeLevelID
                              OR lh.Level4ID = @AdministrativeLevelID
                              OR lh.Level5ID = @AdministrativeLevelID
                              OR lh.Level6ID = @AdministrativeLevelID
                              OR lh.Level7ID = @AdministrativeLevelID
                          )
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ac.strReportFormID LIKE '%' + @EIDSSReportID + '%'
                          OR @EIDSSReportID IS NULL
                      )
           )
        SELECT TotalRowCount,
               ReportFormId,
               ReportFormTypeID,
               AdministrativeUnitID,
               SentByOrganizationID,
               SentByOrganizationName,
               SentByPersonID,
               SentByPersonName,
               EnteredByOrganizationID,
               EnteredByOrganizationName,
               EnteredByPersonID,
               EnteredByPersonName,
               SentByDate,
               DisplaySentByDate,
               EnteredByDate,
               DisplayEnteredByDate,
               StartDate,
               DisplayStartDate,
               FinishDate,
               DisplayFinishDate,
               EIDSSReportID,
               NULL AS AdministrativeUnitTypeID,
               AdministrativeUnitTypeName,
               idfsDiagnosis,
               diseaseDefaultName,
               diseaseName,
               Diagnosis Total,
               Notified,
               Comments,
               AdminLevel0,
               AdminLevel0Name,
               AdminLevel1,
               AdminLevel1Name,
               AdminLevel2,
               AdminLevel2Name,
               idfsSettlement,
               SettlementName,
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
