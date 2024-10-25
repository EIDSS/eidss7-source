/****** Object:  StoredProcedure [dbo].[USP_AGG_REPORT_GETList_AVR]    Script Date: 11/14/2022 12:27:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name:  USP_AGG_REPORT_GETList_AVR
--
-- Description:  Returns list of aggregate reports depending on aggregate report type.
--          
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Stephen Long        07/01/2019 Initial release.
-- Stephen Long        07/09/2019 Updated gis string translation to sub selects instead of joins 
--                                for better performance.
-- Stephen Long        08/05/2019 Updated time period join, and changed the select all if/else. 
--                                Was throwing errors on POCO.
-- Stephen Long        08/08/2019 Added entered by person name.
-- Stephen Long        08/13/2019 Corrected administrative unit type id values.
-- Stephen Long        09/26/2019 Changed administrative where clause; reference TFS item
-- Stephen Long        01/22/2020 Added site list parameter for site filtration.
-- Stephen Long        02/18/2020 Added non-configurable site filtration rules.
-- Stephen Long        02/28/2020 Added "display" dates to handle different cultures.
-- Mark Wilson		   03/03/2020 Removed @DistinctIDs table parm and got rid of duplicates
-- Stephen Long        04/29/2020 Added organization statistical area type.
-- Stephen Long        06/30/2020 Made updates so POCO generator would better handle.
-- Stephen Long        07/06/2020 Added trim to EIDSS Report ID.
-- Stephen Long        09/18/2020 Added the four version ID's for the various matrices.
-- Stephen Long        09/21/2020 Added parameter administrative unit type ID and where 
--                                criteria.
-- Stephen Long        11/18/2020 Added site ID to the query.
-- Stephen Long        11/27/2020 Added configurable site filtration rules.
-- Stephen Long        12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long        04/04/2021 Added updated pagination and location hierarchy.
-- Ann Xiong	       10/23/2021 Fixed search by Organization issue
-- Stephen Long        05/17/2022 Added additional criteria for admin unit of organization.
-- Mike Kornegay	   05/19/2022 Updated to reflect new parameters.
-- Stephen Long        05/31/2022 Updated default rule for administrative level check, and added
--                                for organizations connected to the report.
-- Stephen Long        06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay	   08/01/2022 Changed CTE for paging and sorting because sorting was not correct.
-- Stephen Long        09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Ann Xiong		   09/27/2022 Added parameter LegacyReportID
-- Edgard Torres	   11/07/2022 Modified version of USP_AGG_REPORT_GETList 
--							      to return comma delimeted SiteIDs 
--
-- Legends:
/*
	Aggregate disease report types:
    Human Aggregate = 10102001
    Veterinary Aggregate Disease = 10102002
    Veterinary Aggregate Action = 10102003

	Time interval types:
    None = 0
    Month = 10091001
    Day = 10091002
    Quarter = 10091003
    Week = 10091004
    Year = 10091005

	Administrative unit types:
    None = 0
    Country/Administrative Level 1 = 10089001
	Administrative Level 2 = 10089003
    Administrative Level 3 = 10089002
    Settlement = 10089004
	Organization = 10089005

	Testing Code:
	exec USP_AGG_REPORT_GETList 'en-US', 
	@AggregateReportTypeID=10102001, 
	@UserSiteID=864, 
	@UserOrganizationID=758210000000, 
	@UserEmployeeID=420664190000872
*/
--
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_AGG_REPORT_GETList_AVR] (
	@LanguageID AS NVARCHAR(50)
	,@AggregateReportTypeID AS BIGINT = NULL
	,@ReportID AS NVARCHAR(200) = NULL
	,@LegacyReportID NVARCHAR(200) = NULL
	,@AdministrativeUnitTypeID AS BIGINT = NULL
	,@TimeIntervalTypeID AS BIGINT = NULL
	,@StartDate AS DATETIME = NULL
	,@EndDate AS DATETIME = NULL
	,@AdministrativeUnitID AS BIGINT = NULL
	,@OrganizationID BIGINT = NULL
	,@SelectAllIndicator BIT = 0
	,@UserSiteID BIGINT
	,@UserOrganizationID BIGINT
	,@UserEmployeeID BIGINT
	,@ApplySiteFiltrationIndicator BIT = 0
	,@SortColumn NVARCHAR(30) = 'ReportID'
	,@SortOrder NVARCHAR(4) = 'DESC'
	,@PageNumber INT = 1
	,@PageSize INT = 10,
	@SiteIDs NVARCHAR(MAX) OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF @SelectAllIndicator = 1
	BEGIN
		SET @PageSize = 100000;
		SET @PageNumber = 1;
	END;

	DECLARE @firstRec INT;
	DECLARE @lastRec INT;
	SET @firstRec = (@PageNumber-1)* @PageSize
	SET @lastRec = (@PageNumber*@PageSize+1);

	DECLARE @AdministrativeLevelNode AS HIERARCHYID;
	DECLARE @Results TABLE (
		ID BIGINT NOT NULL
		,ReadPermissionIndicator BIT NOT NULL
		,AccessToPersonalDataPermissionIndicator BIT NOT NULL
		,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
		,WritePermissionIndicator BIT NOT NULL
		,DeletePermissionIndicator BIT NOT NULL
		);

	BEGIN TRY
	    IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

		IF @AdministrativeUnitID IS NOT NULL
		BEGIN
			SELECT @AdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @AdministrativeUnitID;
		END;

		-- ========================================================================================
		-- NO SITE FILTRATION RULES APPLIED
		--
		-- For first and second level sites, do not apply any site filtration rules.
		-- ========================================================================================
		IF @ApplySiteFiltrationIndicator = 0
		BEGIN
			INSERT INTO @Results
			SELECT ac.idfAggrCase
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbAggrCase ac
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
			LEFT JOIN dbo.gisBaseReference br ON br.idfsGISBaseReference = ac.idfsAdministrativeUnit
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) OrganizationAdminUnit ON ac.idfOffice = OrganizationAdminUnit.idfOffice
			LEFT JOIN dbo.trtBaseReference AdminUnit ON AdminUnit.idfsBaseReference = CASE 
					WHEN ac.idfOffice IS NOT NULL
						THEN 10089005
					WHEN br.idfsGISReferenceType = 19000001
						THEN 10089001
					WHEN br.idfsGISReferenceType = 19000003
						THEN 10089003
					WHEN br.idfsGISReferenceType = 19000002
						THEN 10089002
					WHEN br.idfsGISReferenceType = 19000004
						THEN 10089004
					END
			LEFT JOIN dbo.trtStringNameTranslation AS per ON per.idfsBaseReference = CASE 
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091002 /* Day */
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6
						THEN 10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
					WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091001 /* Month */
					WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091003 /* Quarter */
					WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091005 /* Year */
					END
				AND per.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			WHERE ac.intRowStatus = 0
				AND (
					ac.idfsAggrCaseType = @AggregateReportTypeID
					OR @AggregateReportTypeID IS NULL
					)
				AND (
					ac.idfOffice = @OrganizationID
					OR @OrganizationID IS NULL
					)
				AND (
					AdminUnit.idfsBaseReference = @AdministrativeUnitTypeID
					OR @AdministrativeUnitTypeID IS NULL
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
					CASE 
						WHEN @AdministrativeUnitID IS NULL
							THEN 1
						WHEN g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
							OR (ac.idfOffice = @AdministrativeUnitID AND @AdministrativeUnitTypeID = 10089005)
							THEN 1
						ELSE 0
						END = 1
					)
				AND (
					ac.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
				AND (
					ac.strCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
					OR @LegacyReportID IS NULL
					)
					;
		END
		ELSE
		BEGIN
			DECLARE @FilteredResults TABLE (
				ID BIGINT NOT NULL
				,ReadPermissionIndicator BIT NOT NULL
				,AccessToPersonalDataPermissionIndicator BIT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
				,WritePermissionIndicator BIT NOT NULL
				,DeletePermissionIndicator BIT NOT NULL
				,INDEX IDX_ID(ID)
				);
			-- =======================================================================================
			-- DEFAULT SITE FILTRATION RULES
			--
			-- Apply non-configurable site filtration rules for third level sites.
			-- =======================================================================================
			DECLARE @RuleActiveStatus INT = 0;
			DECLARE @AdministrativeLevelTypeID INT;
			DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
			DECLARE @DefaultAccessRules AS TABLE (
				AccessRuleID BIGINT NOT NULL
				,ActiveIndicator INT NOT NULL
				,ReadPermissionIndicator BIT NOT NULL
				,AccessToPersonalDataPermissionIndicator BIT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
				,WritePermissionIndicator BIT NOT NULL
				,DeletePermissionIndicator BIT NOT NULL
				,AdministrativeLevelTypeID INT NULL
				);

			INSERT INTO @DefaultAccessRules
			SELECT AccessRuleID
			    ,a.intRowStatus
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
				,a.AdministrativeLevelTypeID
			FROM dbo.AccessRule a
			WHERE a.DefaultRuleIndicator = 1;

			--
			-- Human Aggregate Disease Report data shall be available to all sites' organizations 
			-- connected to the particular report.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537023;

			IF @RuleActiveStatus = 0
			BEGIN
				-- Entered by and notification received by and sent to organizations
				INSERT INTO @FilteredResults
				SELECT a.idfAggrCase
					,1
					,1
					,1
					,1
					,1
				FROM dbo.tlbAggrCase a
				WHERE a.intRowStatus = 0
					AND (
						a.idfEnteredByOffice = @UserOrganizationID
						OR a.idfReceivedByOffice = @UserOrganizationID
						OR a.idfSentByOffice = @UserOrganizationID
						);
			END;

			--
			-- Human Aggregate Disease Report data shall be available to all sites of the same 
			-- administrative level specified in the rule.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537005;

			IF @RuleActiveStatus = 0
			BEGIN
				SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
				FROM @DefaultAccessRules
				WHERE AccessRuleID = 10537005;

				SELECT @OrganizationAdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
				FROM dbo.tlbOffice o
				INNER JOIN dbo.tlbGeoLocationShared l ON l.idfGeoLocationShared = o.idfLocation
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				WHERE o.idfOffice = @UserOrganizationID
					AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

				-- Administrative level specified in the rule of the report administrative unit.
				INSERT INTO @FilteredResults
				SELECT ac.idfAggrCase
					,1
					,1
					,1
					,1
					,1
				FROM dbo.tlbAggrCase ac
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537005
				WHERE ac.intRowStatus = 0
				    AND ac.idfsAggrCaseType = 10102001 
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1
					AND ac.idfAggrCase NOT IN (
						SELECT ID
						FROM @FilteredResults
						);

				-- Administrative level of the settlement of the report administrative unit.
				INSERT INTO @FilteredResults
				SELECT ac.idfAggrCase
					,1
					,1
					,1
					,1
					,1
				FROM dbo.tlbAggrCase ac
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537005
				WHERE ac.intRowStatus = 0
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1
					AND (
						ac.idfAggrCase NOT IN (
							SELECT ID
							FROM @FilteredResults
							)
						);
			END;

			--
			-- Veterinary Aggregate Disease/Action Report data shall be available to all sites' organizations 
			-- connected to the particular report.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537024;

			IF @RuleActiveStatus = 0
			BEGIN
				-- Entered by and notification received by and sent to organizations
				INSERT INTO @FilteredResults
				SELECT a.idfAggrCase
					,1
					,1
					,1
					,1
					,1
				FROM dbo.tlbAggrCase a
				WHERE a.intRowStatus = 0
					AND (
						a.idfEnteredByOffice = @UserOrganizationID
						OR a.idfReceivedByOffice = @UserOrganizationID
						OR a.idfSentByOffice = @UserOrganizationID
						);
			END;

			--
			-- Veterinary Aggregate Disease/Action Report data shall be available to all sites of the same 
			-- administrative level specified in the rule.
			--
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
			WHERE AccessRuleID = 10537014;

			IF @RuleActiveStatus = 0
			BEGIN
				SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
				FROM @DefaultAccessRules
				WHERE AccessRuleID = 10537014;

				SELECT @OrganizationAdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
				FROM dbo.tlbOffice o
				INNER JOIN dbo.tlbGeoLocationShared l ON l.idfGeoLocationShared = o.idfLocation
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = l.idfsLocation
				WHERE o.idfOffice = @UserOrganizationID
					AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

				-- Administrative level specified in the rule of the report administrative unit.
				INSERT INTO @FilteredResults
				SELECT ac.idfAggrCase
					,1
					,1
					,1
					,1
					,1
				FROM dbo.tlbAggrCase ac
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537014
				WHERE ac.intRowStatus = 0
				    AND ac.idfsAggrCaseType = 10102002 OR ac.idfAggrCase = 10102003 
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1
					AND ac.idfAggrCase NOT IN (
						SELECT ID
						FROM @FilteredResults
						);

				-- Administrative level of the settlement of the report administrative unit.
				INSERT INTO @FilteredResults
				SELECT ac.idfAggrCase
					,1
					,1
					,1
					,1
					,1
				FROM dbo.tlbAggrCase ac
				INNER JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
				INNER JOIN @DefaultAccessRules a ON a.AccessRuleID = 10537014
				WHERE ac.intRowStatus = 0
					AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1
					AND (
						ac.idfAggrCase NOT IN (
							SELECT ID
							FROM @FilteredResults
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
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = ag.idfsSite
			INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup ON userSiteGroup.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = ag.idfsSite
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's employee group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = ag.idfsSite
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's ID level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = ag.idfsSite
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tflSiteToSiteGroup sgs ON sgs.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND sgs.idfsSite = ag.idfsSite;

			-- 
			-- Apply at the user's site level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteID = ag.idfsSite;

			-- 
			-- Apply at the user's employee group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteID = ag.idfsSite;

			-- 
			-- Apply at the user's ID level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT ag.idfAggrCase
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbAggrCase ag
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE ag.intRowStatus = 0
				AND a.GrantingActorSiteID = ag.idfsSite;

			-- Copy filtered results to results and use search criteria
			INSERT INTO @Results
			SELECT ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator
			FROM @FilteredResults
			INNER JOIN dbo.tlbAggrCase ac ON ac.idfAggrCase = ID
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
			LEFT JOIN dbo.gisBaseReference br ON br.idfsGISBaseReference = ac.idfsAdministrativeUnit
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) OrganizationAdminUnit ON ac.idfOffice = OrganizationAdminUnit.idfOffice
			LEFT JOIN dbo.trtBaseReference AdminUnit ON AdminUnit.idfsBaseReference = CASE 
					WHEN ac.idfOffice IS NOT NULL
						THEN 10089005
					WHEN br.idfsGISReferenceType = 19000001
						THEN 10089001
					WHEN br.idfsGISReferenceType = 19000003
						THEN 10089003
					WHEN br.idfsGISReferenceType = 19000002
						THEN 10089002
					WHEN br.idfsGISReferenceType = 19000004
						THEN 10089004
					END
			LEFT JOIN dbo.trtStringNameTranslation AS per ON per.idfsBaseReference = CASE 
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091002 /* Day */
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6
						THEN 10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
					WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091001 /* Month */
					WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091003 /* Quarter */
					WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091005 /* Year */
					END
				AND per.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			WHERE (
					ac.idfsAggrCaseType = @AggregateReportTypeID
					OR @AggregateReportTypeID IS NULL
					)
				AND (
					ac.idfSentByOffice = @OrganizationID
					OR @OrganizationID IS NULL
					)
				AND (
					AdminUnit.idfsBaseReference = @AdministrativeUnitTypeID
					OR @AdministrativeUnitTypeID IS NULL
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
					CASE 
						WHEN @AdministrativeUnitID IS NULL
							THEN 1
						WHEN g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
							OR (ac.idfOffice = @AdministrativeUnitID AND @AdministrativeUnitTypeID = 10089005)
							THEN 1
						ELSE 0
						END = 1
					)
				AND (
					ac.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
					OR @ReportID IS NULL
					)
			GROUP BY ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator;
		END;

		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		WITH paging
		AS (
			SELECT ROW_NUMBER() OVER ( ORDER BY
				CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'ASC' THEN ac.strCaseID END ASC,
				CASE WHEN @SortColumn = 'ReportID' AND @SortOrder = 'DESC' THEN ac.strCaseID END DESC,
				CASE WHEN @SortColumn = 'StartDate' AND @SortOrder = 'ASC' THEN ac.datStartDate END ASC,
				CASE WHEN @SortColumn = 'StartDate' AND @SortOrder = 'DESC' THEN ac.datStartDate END DESC,
				CASE WHEN @SortColumn = 'TimeIntervalUnitTypeName' AND @SortOrder = 'ASC' THEN per.strTextString END ASC,
				CASE WHEN @SortColumn = 'TimeIntervalUnitTypeName' AND @SortOrder = 'DESC' THEN per.strTextString END DESC,
				CASE WHEN @SortColumn = 'AdministrativeLevel1Name' AND @SortOrder = 'ASC' THEN LH.AdminLevel2Name END ASC,
				CASE WHEN @SortColumn = 'AdministrativeLevel1Name' AND @SortOrder = 'DESC' THEN LH.AdminLevel2Name END DESC,
				CASE WHEN @SortColumn = 'AdministrativeLevel2Name' AND @SortOrder = 'ASC' THEN LH.AdminLevel3Name END ASC,
				CASE WHEN @SortColumn = 'AdministrativeLevel2Name' AND @SortOrder = 'DESC' THEN LH.AdminLevel3Name END DESC,
				CASE WHEN @SortColumn = 'SettlementName' AND @SortOrder = 'ASC' THEN LH.AdminLevel4Name END ASC,
				CASE WHEN @SortColumn = 'SettlementName' AND @SortOrder = 'DESC' THEN LH.AdminLevel4Name END DESC,
				CASE WHEN @SortColumn = 'OrganizationAdministrativeName' AND @SortOrder = 'ASC' THEN organizationAdminUnit.name END ASC,
				CASE WHEN @SortColumn = 'OrganizationAdministrativeName' AND @SortOrder = 'DESC' THEN organizationAdminUnit.name END DESC 
			) AS ROWNUM,
			ac.idfsSite AS SiteID
			FROM @Results res
			INNER JOIN dbo.tlbAggrCase ac ON ac.idfAggrCase = res.ID
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) receivedByOrganization ON ac.idfReceivedByOffice = receivedByOrganization.idfOffice
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) enteredByOrganization ON ac.idfEnteredByOffice = enteredByOrganization.idfOffice
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) sentByOrganization ON ac.idfSentByOffice = sentByOrganization.idfOffice
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = ac.idfsAdministrativeUnit
			INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation= ac.idfsAdministrativeUnit
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) organizationAdminUnit ON ac.idfOffice = organizationAdminUnit.idfOffice
			LEFT JOIN dbo.trtBaseReference adminUnit ON adminUnit.idfsBaseReference = CASE 
				WHEN NOT ac.idfOffice IS NULL
					THEN 10089005
				WHEN NOT lh.AdminLevel4ID IS NULL
					THEN 10089004
				WHEN NOT lh.AdminLevel3ID IS NULL
					THEN 10089002
				WHEN NOT lh.AdminLevel2ID IS NULL
					THEN 10089003
				WHEN NOT lh.AdminLevel1Id IS NULL
					THEN   10089001
				END
			LEFT JOIN dbo.trtStringNameTranslation per ON per.idfsBaseReference = CASE 
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091002 /* Day */
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6
						THEN 10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
					WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091001 /* Month */
					WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091003 /* Quarter */
					WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091005 /* Year */
					END
				AND per.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			),

			SITEID AS
		   (
				SELECT
					DISTINCT siteID
				FROM paging

			)

		SELECT @SiteIDs = STRING_AGG(CAST(SiteID AS NVARCHAR(24)), ',') 
		FROM SITEID

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END

GO