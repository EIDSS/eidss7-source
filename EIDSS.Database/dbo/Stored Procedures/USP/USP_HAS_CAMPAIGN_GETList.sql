-- ================================================================================================
-- Name: USP_HAS_CAMPAIGN_GETList
--
-- Description: Gets data for active surveillance campaign search for the human module.
--          
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       07/06/2019 Initial release.
-- Stephen Long       01/26/2020 Added site list parameter for site filtration.
-- Ann Xiong		  02/19/2020 Added script to search by Region and Rayon
-- Stephen Long       05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long       06/18/2020 Added where criteria to the query when no site filtration is 
--                               required.
-- Stephen Long       07/07/2020 Added trim to EIDSS identifier like criteria.
-- Stephen Long       11/18/2020 Added site ID to the query.
-- Stephen Long       11/27/2020 Added configurable site filtration rules.
-- Stephen Long       12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long       12/14/2020 Corrected where criteria on site list in the final query.
-- Stephen Long       12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long       12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long       04/08/2021 Added updated pagination and location hierarchy.
-- Lamont Mitchell    07/01/2021 
-- Mark Wilson		  08/10/2021 added join to tlbCampaignToDiagnosis to pull diagnosis
-- Mark Wilson		  08/26/2021 added Select Distinct to remove dupes
-- Mark Wilson		  08/27/2021 added @CampaignTypeID to total count
-- Stephen Long       06/01/2022 Fix to filtration on the site ID for first and second level sites.
-- Stephen Long       09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_CAMPAIGN_GETList] (
	@LanguageID AS NVARCHAR(50)
	,@CampaignID AS NVARCHAR(200) = NULL
	,@CampaignName AS NVARCHAR(200) = NULL
	,@CampaignTypeID AS BIGINT = NULL
	,@CampaignStatusTypeID AS BIGINT = NULL
	,@StartDateFrom AS DATETIME = NULL
	,@StartDateTo AS DATETIME = NULL
	,@DiseaseID AS BIGINT = NULL
	,@AdministrativeLevelID AS BIGINT = NULL
	,@UserSiteID BIGINT
	,@UserOrganizationID BIGINT
	,@UserEmployeeID BIGINT
	,@ApplySiteFiltrationIndicator BIT = 0
	,@SortColumn NVARCHAR(30) = 'CampaignID'
	,@SortOrder NVARCHAR(4) = 'DESC'
	,@Page INT = 1
	,@PageSize INT = 10
	)
AS
BEGIN
	SET NOCOUNT ON;

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

		IF @AdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @AdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @AdministrativeLevelID;
		END;

		INSERT INTO @Results
		SELECT C.idfCampaign
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbCampaign C
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign
		LEFT JOIN dbo.tstSite s ON s.idfsSite = c.idfsSite AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice AND o.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		WHERE c.intRowStatus = 0
			AND c.CampaignCategoryID = 10501001 -- Human Active Surveillance Campaign
			AND (
				(
					c.idfsSite = @UserSiteID
					AND @ApplySiteFiltrationIndicator = 1
					)
				OR (
					@ApplySiteFiltrationIndicator = 0
					)
				)
			AND (
				strCampaignName = @CampaignName
				OR @CampaignName IS NULL
				)
			AND (
				idfsCampaignType = @CampaignTypeID
				OR @CampaignTypeID IS NULL
				)
			AND (
				idfsCampaignStatus = @CampaignStatusTypeID
				OR @CampaignStatusTypeID IS NULL
				)
			AND (
				CD.idfsDiagnosis = @DiseaseID
				OR @DiseaseID IS NULL
				)
			AND (
				(
					datCampaignDateStart BETWEEN @StartDateFrom
						AND @StartDateTo
					)
				OR (@StartDateFrom IS NULL)
				)
			AND (
				g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
				OR @AdministrativeLevelID IS NULL
				)
			AND (
				strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
				OR @CampaignID IS NULL
				);

		-- =======================================================================================
		-- CONFIGURABLE SITE FILTRATION RULES
		-- 
		-- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
		-- overlap the non-configurable rules.
		-- =======================================================================================
		IF @ApplySiteFiltrationIndicator = 1
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

			--
			-- Apply at the user's site group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = c.idfsSite
			INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup ON userSiteGroup.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = c.idfsSite
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's employee group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = c.idfsSite
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's ID level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = c.idfsSite
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tflSiteToSiteGroup sgs ON sgs.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND sgs.idfsSite = c.idfsSite;

			-- 
			-- Apply at the user's site level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteID = c.idfsSite;

			-- 
			-- Apply at the user's employee group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteID = c.idfsSite;

			-- 
			-- Apply at the user's ID level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT c.idfCampaign
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbCampaign c
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE c.intRowStatus = 0
				AND a.GrantingActorSiteID = c.idfsSite;

			-- Copy filtered results to results and use search criteria
			INSERT INTO @Results
			SELECT 
				ID,
				ReadPermissionIndicator,
				AccessToPersonalDataPermissionIndicator,
				AccessToGenderAndAgeDataPermissionIndicator,
				WritePermissionIndicator,
				DeletePermissionIndicator

			FROM @FilteredResults
			INNER JOIN dbo.tlbCampaign C ON C.idfCampaign = ID
			INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign AND CD.intRowStatus = 0
			LEFT JOIN dbo.tstSite s ON s.idfsSite = C.idfsSite AND s.intRowStatus = 0
			LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice AND o.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
			WHERE c.CampaignCategoryID = 10501001 -- Human Active Surveillance Campaign
				AND (
					strCampaignName = @CampaignName
					OR @CampaignName IS NULL
					)
				AND (
					idfsCampaignType = @CampaignTypeID
					OR @CampaignTypeID IS NULL
					)
				AND (
					idfsCampaignStatus = @CampaignStatusTypeID
					OR @CampaignStatusTypeID IS NULL
					)
				AND (
					idfsDiagnosis = @DiseaseID
					OR @DiseaseID IS NULL
					)
				AND (
					(
						datCampaignDateStart BETWEEN @StartDateFrom
							AND @StartDateTo
						)
					OR (@StartDateFrom IS NULL)
					)
				AND (
					g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
					OR @AdministrativeLevelID IS NULL
					)
				AND (
					strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
					OR @CampaignID IS NULL
					);
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
		DELETE
		FROM @Results
		WHERE ID IN (
				SELECT 
					C.idfCampaign
				FROM dbo.tlbCampaign C
				INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign AND CD.intRowStatus = 0
				INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = CD.idfsDiagnosis	AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1 AND oa.idfsObjectType = 10060001 AND oa.idfActor = - 506 -- Default role
				);

		--
		-- Apply level 1 disease filtration rules for an employee's associated user group(s).  
		-- Allows and denies will supersede level 0.
		--
		INSERT INTO @Results
		SELECT C.idfCampaign
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbCampaign C
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign AND CD.intRowStatus = 0
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = CD.idfsDiagnosis AND oa.intRowStatus = 0
		INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID AND egm.intRowStatus = 0
		LEFT JOIN dbo.tstSite s ON s.idfsSite = C.idfsSite AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice AND o.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		WHERE oa.intPermission = 2 -- Allow permission
			AND C.intRowStatus = 0
			AND oa.idfsObjectType = 10060001 -- Disease
			AND oa.idfActor = egm.idfEmployeeGroup
			AND C.CampaignCategoryID = 10501001 -- Human Active Surveillance Campaign
			AND (
				strCampaignName = @CampaignName
				OR @CampaignName IS NULL
				)
			AND (
				idfsCampaignType = @CampaignTypeID
				OR @CampaignTypeID IS NULL
				)
			AND (
				idfsCampaignStatus = @CampaignStatusTypeID
				OR @CampaignStatusTypeID IS NULL
				)
			AND (
				CD.idfsDiagnosis = @DiseaseID
				OR @DiseaseID IS NULL
				)
			AND (
				(
					datCampaignDateStart BETWEEN @StartDateFrom
						AND @StartDateTo
					)
				OR (@StartDateFrom IS NULL)
				)
			AND (
				g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
				OR @AdministrativeLevelID IS NULL
				)
			AND (
				strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
				OR @CampaignID IS NULL
				);

		DELETE res
		FROM @Results res
		INNER JOIN dbo.tlbCampaign c ON c.idfCampaign = ID
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign AND CD.intRowStatus = 0
		INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID AND egm.intRowStatus = 0
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = CD.idfsDiagnosis AND oa.intRowStatus = 0
		WHERE oa.intPermission = 1 -- Deny permission
		AND oa.idfsObjectType = 10060001 -- Disease
		AND oa.idfActor = egm.idfEmployeeGroup;

		--
		-- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
		-- will supersede level 1.
		--
		INSERT INTO @Results
		SELECT c.idfCampaign
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbCampaign c
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = c.idfCampaign AND CD.intRowStatus = 0
		INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = CD.idfsDiagnosis	AND oa.intRowStatus = 0
		LEFT JOIN dbo.tstSite s ON s.idfsSite = c.idfsSite AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice AND o.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gl.idfsLocation
		WHERE oa.intPermission = 2 -- Allow permission
			AND c.intRowStatus = 0
			AND oa.idfsObjectType = 10060001 -- Disease
			AND oa.idfActor = @UserEmployeeID
			AND c.CampaignCategoryID = 10501001 -- Human Active Surveillance Campaign
			AND (
				c.strCampaignName = @CampaignName
				OR @CampaignName IS NULL
				)
			AND (
				c.idfsCampaignType = @CampaignTypeID
				OR @CampaignTypeID IS NULL
				)
			AND (
				c.idfsCampaignStatus = @CampaignStatusTypeID
				OR @CampaignStatusTypeID IS NULL
				)
			AND (
				CD.idfsDiagnosis = @DiseaseID
				OR @DiseaseID IS NULL
				)
			AND (
				(
					c.datCampaignDateStart BETWEEN @StartDateFrom
						AND @StartDateTo
					)
				OR (@StartDateFrom IS NULL)
				)
			AND (
				g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
				OR @AdministrativeLevelID IS NULL
				)
			AND (
				c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
				OR @CampaignID IS NULL
				);

		DELETE
		FROM @Results
		WHERE ID IN (
				SELECT c.idfCampaign
				FROM dbo.tlbCampaign c
				INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = c.idfCampaign AND CD.intRowStatus = 0
				INNER JOIN dbo.tstObjectAccess oa ON oa.idfsObjectID = CD.idfsDiagnosis
					AND oa.intRowStatus = 0
				WHERE oa.intPermission = 1 -- Deny permission
				AND oa.idfActor = @UserEmployeeID
				);

		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		WITH paging
		AS (
			SELECT 
				ID,
				c = COUNT(*) OVER ()
			FROM @Results res
			INNER JOIN dbo.tlbCampaign c ON c.idfCampaign = res.ID
			INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = c.idfCampaign AND CD.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000115) campaignStatus ON c.idfsCampaignStatus = campaignStatus.idfsReference
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType ON c.idfsCampaignType = campaignType.idfsReference
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease ON CD.idfsDiagnosis = disease.idfsReference
			ORDER BY CASE 
					WHEN @SortColumn = 'CampaignID'
						AND @SortOrder = 'ASC'
						THEN c.strCampaignID
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignID'
						AND @SortOrder = 'DESC'
						THEN c.strCampaignID
					END DESC
				,CASE 
					WHEN @SortColumn = 'CampaignName'
						AND @SortOrder = 'ASC'
						THEN c.strCampaignName
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignName'
						AND @SortOrder = 'DESC'
						THEN c.strCampaignName
					END DESC
				,CASE 
					WHEN @SortColumn = 'CampaignTypeName'
						AND @SortOrder = 'ASC'
						THEN campaignType.name
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignTypeName'
						AND @SortOrder = 'DESC'
						THEN campaignType.name
					END DESC
				,CASE 
					WHEN @SortColumn = 'CampaignStatusTypeName'
						AND @SortOrder = 'ASC'
						THEN campaignStatus.name
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignStatusTypeName'
						AND @SortOrder = 'DESC'
						THEN campaignStatus.name
					END DESC
				,CASE 
					WHEN @SortColumn = 'StartDate'
						AND @SortOrder = 'ASC'
						THEN c.datCampaignDateStart
					END ASC
				,CASE 
					WHEN @SortColumn = 'StartDate'
						AND @SortOrder = 'DESC'
						THEN c.datCampaignDateStart
					END DESC
				,CASE 
					WHEN @SortColumn = 'DiseaseName'
						AND @SortOrder = 'ASC'
						THEN disease.name
					END ASC
				,CASE 
					WHEN @SortColumn = 'DiseaseName'
						AND @SortOrder = 'DESC'
						THEN disease.name
					END DESC OFFSET @PageSize * ( @Page - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
			)
		SELECT 
			DISTINCT
			c.idfCampaign AS CampaignKey,
			c.strCampaignID AS CampaignID,
			campaignType.name AS CampaignTypeName,
			campaignStatus.name AS CampaignStatusTypeName,
			disease.name AS DiseaseName,
			SampleTypesList = STUFF((
					SELECT ', ' + sampleType.name
					FROM dbo.tlbCampaignToDiagnosis CD
					INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) AS sampleType ON sampleType.idfsReference = CD.idfsSampleType
					WHERE CD.idfCampaign = c.idfCampaign
					GROUP BY sampleType.name
					FOR XML PATH('')
						,TYPE
					).value('.[1]', 'NVARCHAR(MAX)'), 1, 2, ''),
			c.datCampaignDateStart AS CampaignStartDate,
			c.datCampaignDateEND AS CampaignEndDate,
			c.strCampaignName AS CampaignName,
			c.strCampaignAdministrator AS CampaignAdministrator,
			c.AuditCreateDTM AS EnteredDate,
			c.idfsSite AS SiteID,
			res.ReadPermissionIndicator,
			res.AccessToPersonalDataPermissionIndicator,
			res.AccessToGenderAndAgeDataPermissionIndicator,
			res.WritePermissionIndicator,
			res.DeletePermissionIndicator,
			c AS RecordCount,
			(
				SELECT COUNT(*)
				FROM dbo.tlbCampaign
				WHERE intRowStatus = 0
					AND CampaignCategoryID = 10501001 -- Human Active Surveillance Campaign
					AND idfsCampaignType = @CampaignTypeID
			) AS TotalCount,
			CurrentPage =  @Page,
			TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
		FROM @Results res
		INNER JOIN paging ON paging.ID = res.ID
		INNER JOIN dbo.tlbCampaign c ON c.idfCampaign = res.ID
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = c.idfCampaign AND CD.intRowStatus = 0
		INNER JOIN dbo.tstSite s ON s.idfsSite = c.idfsSite
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000115) campaignStatus ON c.idfsCampaignStatus = campaignStatus.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType ON c.idfsCampaignType = campaignType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease ON CD.idfsDiagnosis = disease.idfsReference
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
