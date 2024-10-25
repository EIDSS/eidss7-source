/****** Object:  StoredProcedure [dbo].[USP_AS_CAMPAIGN_GETList_AVR]    Script Date: 11/14/2022 12:30:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ================================================================================================
-- Name: USP_AS_CAMPAIGN_GETList_AVR
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
-- Mark Wilson		  02/22/2022 renamed from USP_HAS_CAMPAIGN_GETList and added @CampaignCategoryID to 
--								 support both human and vet campaigns
-- Mark Wilson		  02/23/2022 removed parm @AdministrativeLevelID, redo paging and sorting
-- Manickandan Govindrajan 05/12/2022 Fixed the start and End date condition
-- Edgard Torres	  11/10/2022 Modified version of USP_AS_CAMPAIGN_GETList
--							     to return comma delimeted SiteIDs 
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_AS_CAMPAIGN_GETList_AVR] 
(
	@LanguageID AS NVARCHAR(50),
	@CampaignID AS NVARCHAR(200) = NULL,
	@LegacyCampaignID AS NVARCHAR(200) = NULL,
	@CampaignName AS NVARCHAR(200) = NULL,
	@CampaignTypeID AS BIGINT = NULL,
	@CampaignStatusTypeID AS BIGINT = NULL,
	@CampaignCategoryID AS BIGINT,
	@StartDateFrom AS DATETIME = NULL,
	@StartDateTo AS DATETIME = NULL,
	@DiseaseID AS BIGINT = NULL,
	@UserSiteID BIGINT,
	@UserEmployeeID BIGINT,
	@ApplySiteFiltrationIndicator BIT = 0,
	@SortColumn NVARCHAR(30) = 'CampaignID',
	@SortOrder NVARCHAR(4) = 'DESC',
	@Page INT = 1,
	@PageSize INT = 10,
	@SiteIDs NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
	DECLARE @firstRec INT
	DECLARE @lastRec INT

	SET @firstRec = (@page-1)* @pagesize
	SET @lastRec = (@page*@pageSize+1)
	BEGIN TRY

	DECLARE @Results TABLE (
		ID BIGINT NOT NULL
		,ReadPermissionIndicator BIT NOT NULL
		,AccessToPersonalDataPermissionIndicator BIT NOT NULL
		,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
		,WritePermissionIndicator BIT NOT NULL
		,DeletePermissionIndicator BIT NOT NULL
		);

		INSERT INTO @Results
		SELECT 
			DISTINCT C.idfCampaign,
			1,
			1,
			1,
			1,
			1
		FROM dbo.tlbCampaign C
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign
		LEFT JOIN dbo.tstSite s ON s.idfsSite = c.idfsSite AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice AND o.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared
		LEFT JOIN dbo.gisLocationDenormalized g ON g.idfsLocation = gl.idfsLocation AND g.idfsLanguage = @idfsLanguage
		WHERE c.intRowStatus = 0
		AND c.CampaignCategoryID = @CampaignCategoryID 
		AND ((c.idfsSite = @UserSiteID AND @ApplySiteFiltrationIndicator = 1) OR ((@UserSiteID IS NULL) OR (@ApplySiteFiltrationIndicator = 0)))
		AND (c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'   OR @CampaignName IS NULL) 
		AND (c.idfsCampaignType = @CampaignTypeID OR @CampaignTypeID IS NULL) 
		AND (c.idfsCampaignStatus = @CampaignStatusTypeID OR @CampaignStatusTypeID IS NULL)
		AND (CD.idfsDiagnosis = @DiseaseID OR @DiseaseID IS NULL)
		AND (((c.datCampaignDateStart BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateFrom IS NULL))
		OR ((c.datCampaignDateEnd BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateTo IS NULL)))
		AND (c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%' OR @CampaignID IS NULL)
		AND (c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%' OR @LegacyCampaignID IS NULL);


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
				DISTINCT F.ID,
				F.ReadPermissionIndicator,
				F.AccessToPersonalDataPermissionIndicator,
				F.AccessToGenderAndAgeDataPermissionIndicator,
				F.WritePermissionIndicator,
				F.DeletePermissionIndicator

			FROM @FilteredResults F
			INNER JOIN dbo.tlbCampaign C ON C.idfCampaign = F.ID
			INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign AND CD.intRowStatus = 0
			LEFT JOIN dbo.tstSite s ON s.idfsSite = C.idfsSite AND s.intRowStatus = 0
			LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice AND o.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocationShared gl ON o.idfLocation = gl.idfGeoLocationShared
			LEFT JOIN dbo.gisLocationDenormalized g ON g.idfsLocation = gl.idfsLocation AND g.idfsLanguage = @LanguageID
			WHERE c.CampaignCategoryID = @CampaignCategoryID -- Human Active Surveillance Campaign
		    AND (c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'   OR @CampaignName IS NULL) 
			AND (C.idfsCampaignType = @CampaignTypeID OR @CampaignTypeID IS NULL)
			AND (C.idfsCampaignStatus = @CampaignStatusTypeID OR @CampaignStatusTypeID IS NULL)
			AND (CD.idfsDiagnosis = @DiseaseID OR @DiseaseID IS NULL)
			AND (((c.datCampaignDateStart BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateFrom IS NULL))
			OR ((c.datCampaignDateEnd BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateTo IS NULL)))
			AND (C.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%' OR @CampaignID IS NULL)
			AND (c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%' OR @LegacyCampaignID IS NULL)
			AND F.ID NOT IN (SELECT ID FROM @Results);
		END;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
		SELECT
			DISTINCT C.idfCampaign
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
		LEFT JOIN dbo.gisLocationDenormalized g ON g.idfsLocation = gl.idfsLocation AND g.idfsLanguage = @idfsLanguage
		WHERE oa.intPermission = 2 -- Allow permission
		AND C.intRowStatus = 0
		AND oa.idfsObjectType = 10060001 -- Disease
		AND oa.idfActor = egm.idfEmployeeGroup
		AND C.CampaignCategoryID = @CampaignCategoryID -- Human Active Surveillance Campaign
		AND (c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'   OR @CampaignName IS NULL) 
		AND (C.idfsCampaignType = @CampaignTypeID OR @CampaignTypeID IS NULL)
		AND (C.idfsCampaignStatus = @CampaignStatusTypeID OR @CampaignStatusTypeID IS NULL)
		AND (CD.idfsDiagnosis = @DiseaseID OR @DiseaseID IS NULL)
		AND (((c.datCampaignDateStart BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateFrom IS NULL))
			OR ((c.datCampaignDateEnd BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateTo IS NULL)))
		AND (C.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%' OR @CampaignID IS NULL)	
		AND (c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%' OR @LegacyCampaignID IS NULL)
		AND C.idfCampaign NOT IN (SELECT ID FROM @Results);

		DELETE res
		FROM @Results res
		INNER JOIN dbo.tlbCampaign C ON C.idfCampaign = ID
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
		SELECT 
			DISTINCT c.idfCampaign
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
		LEFT JOIN dbo.gisLocationDenormalized g ON g.idfsLocation = gl.idfsLocation AND g.idfsLanguage = @idfsLanguage
		WHERE oa.intPermission = 2 -- Allow permission
		AND c.intRowStatus = 0
		AND oa.idfsObjectType = 10060001 -- Disease
		AND oa.idfActor = @UserEmployeeID
		AND c.CampaignCategoryID = @CampaignCategoryID -- Human Active Surveillance Campaign
		AND (c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'   OR @CampaignName IS NULL) 
		AND (c.idfsCampaignType = @CampaignTypeID OR @CampaignTypeID IS NULL)
		AND (c.idfsCampaignStatus = @CampaignStatusTypeID OR @CampaignStatusTypeID IS NULL)
		AND (CD.idfsDiagnosis = @DiseaseID OR @DiseaseID IS NULL)
		AND (((c.datCampaignDateStart BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateFrom IS NULL))
			OR ((c.datCampaignDateEnd BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateTo IS NULL)))
		AND (c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'	OR @CampaignID IS NULL)
		AND (c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%' OR @LegacyCampaignID IS NULL)
		AND c.idfCampaign NOT IN (SELECT ID FROM @Results);

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


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		WITH paging
		AS (
			SELECT 
				DISTINCT c.idfCampaign,
				(SELECT dbo.FN_GBL_Campaign_Disease_Names_GET(C.idfCampaign, @LanguageID)) AS DiseaseList, 
				SpeciesList = STUFF((
									SELECT ', ' + speciesType.name
									FROM dbo.tlbCampaignToDiagnosis CD
									INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) AS speciesType ON speciesType.idfsReference = CD.idfsSpeciesType
									WHERE CD.idfCampaign = c.idfCampaign
									GROUP BY speciesType.name
									FOR XML PATH('')
										,TYPE
									).value('.[1]', 'NVARCHAR(MAX)'), 1, 2, ''),
				SampleTypesList = STUFF((
											SELECT ', ' + sampleType.name
											FROM dbo.tlbCampaignToDiagnosis CD
											INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) AS sampleType ON sampleType.idfsReference = CD.idfsSampleType
											WHERE CD.idfCampaign = c.idfCampaign
											GROUP BY sampleType.name
											FOR XML PATH('')
												,TYPE
										).value('.[1]', 'NVARCHAR(MAX)'), 1, 2, ''),
				campaignType.name AS CampaignTypeName,
				campaignStatus.name AS CampaignStatus,
				c.strCampaignID,
				c.strCampaignName,
				c.datCampaignDateStart,
				c.idfsSite,
				c.datCampaignDateEnd,
				c.strCampaignAdministrator,
				c.AuditCreateDTM,
				c.CampaignCategoryID

			FROM dbo.tlbCampaign c
			LEFT JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign
			LEFT JOIN @Results res ON c.idfCampaign = res.ID
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000115) campaignStatus ON c.idfsCampaignStatus = campaignStatus.idfsReference
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType ON c.idfsCampaignType = campaignType.idfsReference
			WHERE c.CampaignCategoryID= @CampaignCategoryID AND c.intRowStatus =0
			AND ((c.idfsSite = @UserSiteID AND @ApplySiteFiltrationIndicator = 1) OR ((@UserSiteID IS NULL) OR (@ApplySiteFiltrationIndicator = 0)))
			AND (c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'   OR @CampaignName IS NULL) 
			AND (c.idfsCampaignType = @CampaignTypeID OR @CampaignTypeID IS NULL) 
			AND (c.idfsCampaignStatus = @CampaignStatusTypeID OR @CampaignStatusTypeID IS NULL)
			AND (CD.idfsDiagnosis = @DiseaseID OR @DiseaseID IS NULL)
			AND (((c.datCampaignDateStart BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateFrom IS NULL))
			OR ((c.datCampaignDateEnd BETWEEN @StartDateFrom AND @StartDateTo) OR (@StartDateTo IS NULL)))
			AND (c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%' OR @CampaignID IS NULL)
			AND (c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%' OR @LegacyCampaignID IS NULL)

			),
			paging_final AS 
			(
			SELECT 
				DISTINCT paging.idfCampaign,
				paging.DiseaseList, 
				paging.SpeciesList,
				paging.SampleTypesList,
				paging.CampaignTypeName,
				paging.CampaignStatus,
				paging.strCampaignID,
				paging.strCampaignName,
				paging.datCampaignDateStart,
				paging.idfsSite,
				paging.datCampaignDateEnd,
				paging.strCampaignAdministrator,
				paging.AuditCreateDTM,
				paging.CampaignCategoryID,
				c = COUNT(*) OVER (),
				ROW_NUMBER() OVER (ORDER BY CASE 
					WHEN @SortColumn = 'CampaignID'
						AND @SortOrder = 'ASC'
						THEN paging.strCampaignID
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignID'
						AND @SortOrder = 'DESC'
						THEN paging.strCampaignID
					END DESC
				,CASE 
					WHEN @SortColumn = 'CampaignName'
						AND @SortOrder = 'ASC'
						THEN paging.strCampaignName
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignName'
						AND @SortOrder = 'DESC'
						THEN paging.strCampaignName
					END DESC
				,CASE 
					WHEN @SortColumn = 'CampaignTypeName'
						AND @SortOrder = 'ASC'
						THEN paging.CampaignTypeName
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignTypeName'
						AND @SortOrder = 'DESC'
						THEN paging.CampaignTypeName
					END DESC
				,CASE 
					WHEN @SortColumn = 'CampaignStatusTypeName'
						AND @SortOrder = 'ASC'
						THEN paging.CampaignStatus
					END ASC
				,CASE 
					WHEN @SortColumn = 'CampaignStatusTypeName'
						AND @SortOrder = 'DESC'
						THEN paging.CampaignStatus
					END DESC
				,CASE 
					WHEN @SortColumn = '"CampaignStartDate'
						AND @SortOrder = 'ASC'
						THEN paging.datCampaignDateStart
					END ASC
				,CASE 
					WHEN @SortColumn = '"CampaignStartDate'
						AND @SortOrder = 'DESC'
						THEN paging.datCampaignDateStart
					END DESC
				,CASE 
					WHEN @SortColumn = 'DiseaseName'
						AND @SortOrder = 'ASC'
						THEN paging.DiseaseList
					END ASC
				,CASE 
					WHEN @SortColumn = 'DiseaseName'
						AND @SortOrder = 'DESC'
						THEN paging.DiseaseList
					END DESC ) AS RowNo

			FROM paging
			
			),

		SITEIDs AS
		(
		SELECT DISTINCT
			p.idfsSite AS SiteID
		FROM paging_final p
		LEFT JOIN @Results res ON p.idfCampaign = res.ID
		INNER JOIN dbo.tstSite s ON s.idfsSite = p.idfsSite
		WHERE p.CampaignCategoryID =@CampaignCategoryID
		)


		SELECT @SiteIDs = STRING_AGG(CAST(SiteID AS NVARCHAR(24)), ',') 
		FROM SITEIDs

		SELECT @SiteIDs


	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END

GO