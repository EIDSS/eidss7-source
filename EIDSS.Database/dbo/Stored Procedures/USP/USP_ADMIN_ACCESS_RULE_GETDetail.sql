-- ================================================================================================
-- Name: USP_ADMIN_ACCESS_RULE_GETDetail
-- 
-- Description: Returns an access rule for configurable site filtration.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/12/2021 Initial release.
-- Stephen Long     01/09/2022 Added create permission indicator.
-- Stephen Long     06/03/2022 Changed access rule name to pull from base reference.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACCESS_RULE_GETDetail] @LanguageID NVARCHAR(50)
	,@AccessRuleID BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT a.AccessRuleID
			,accessRuleName.name AS AccessRuleName 
			,a.BorderingAreaRuleIndicator
			,a.DefaultRuleIndicator
			,a.ReciprocalRuleIndicator
			,a.GrantingActorSiteGroupID
			,a.GrantingActorSiteID
			,(
				CASE 
					WHEN grantingActorSiteGroup.strSiteGroupName IS NOT NULL
						THEN grantingActorSiteGroup.strSiteGroupName
					ELSE grantingActorSite.strSiteName
					END
				) AS GrantingActorName
			,grantingActorSiteGroup.strSiteGroupName AS GrantingActorSiteGroupName
			,grantingActorSite.strSiteName AS GrantingSiteName
			,grantingActorSite.strHASCsiteID AS GrantingSiteHASCCode
			,grantingActorSite.strSiteID AS GrantingSiteCode
			,grantingActorSiteAdminLevel1.idfsReference AS GrantingSiteAdministrativeLevel1ID
			,grantingActorSiteAdminLevel1.name AS GrantingSiteAdministrativeLevel1Name
			,grantingActorSiteAdminLevel2.idfsReference AS GrantingSiteAdministrativeLevel2ID
			,grantingActorSiteAdminLevel2.name AS GrantingSiteAdministrativeLevel2Name
			,a.AccessToGenderAndAgeDataPermissionIndicator
			,a.AccessToPersonalDataPermissionIndicator
			,a.CreatePermissionIndicator 
			,a.DeletePermissionIndicator
			,a.ReadPermissionIndicator
			,a.WritePermissionIndicator
			,a.AdministrativeLevelTypeID
			,a.intRowStatus AS RowStatus
		FROM dbo.AccessRule a
		INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000537) accessRuleName
            ON accessRuleName.idfsReference = a.AccessRuleID
		LEFT JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = a.AccessRuleID
			AND ara.intRowStatus = 0
		LEFT JOIN dbo.tstSite grantingActorSite ON grantingActorSite.idfsSite = a.GrantingActorSiteID
			AND grantingActorSite.intRowStatus = 0
		LEFT JOIN dbo.tflSiteGroup grantingActorSiteGroup ON grantingActorSiteGroup.idfSiteGroup = a.GrantingActorSiteGroupID
			AND grantingActorSiteGroup.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice grantingActorSiteOffice ON grantingActorSiteOffice.idfOffice = grantingActorSite.idfOffice
			AND grantingActorSiteOffice.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared grantingActorSiteLocation ON grantingActorSiteOffice.idfLocation = grantingActorSiteLocation.idfGeoLocationShared
			AND grantingActorSiteLocation.intRowStatus = 0
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = grantingActorSiteLocation.idfsLocation
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000003) grantingActorSiteAdminLevel1 ON grantingActorSiteAdminLevel1.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel1Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000002) grantingActorSiteAdminLevel2 ON grantingActorSiteAdminLevel2.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel2Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000046) grantingActorOrganizationName ON grantingActorOrganizationName.idfsReference = grantingActorSiteOffice.idfsOfficeName
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) grantingActorOrganizationAbbreviation ON grantingActorOrganizationAbbreviation.idfsReference = grantingActorSiteOffice.idfsOfficeAbbreviation
		WHERE a.intRowStatus = 0
			AND a.AccessRuleID = @AccessRuleID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
