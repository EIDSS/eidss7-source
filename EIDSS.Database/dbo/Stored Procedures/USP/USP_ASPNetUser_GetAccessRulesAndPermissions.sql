-- ================================================================================================
-- Name: USP_ASPNetUser_GetAccessRulesAndPermissions
--
-- Description:	Get access rules and permissions for a specific user. Supports configurable site 
-- filtration.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/24/2020 Initial release.
-- Stephen Long     11/25/2020 Add intRowStatus check and correct site group join.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ASPNetUser_GetAccessRulesAndPermissions] @UserID BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.AccessRuleID
		,grantingSGS.idfsSite AS SiteID
		,a.ReadPermissionIndicator
		,a.AccessToPersonalDataPermissionIndicator
		,a.AccessToGenderAndAgeDataPermissionIndicator
		,a.WritePermissionIndicator
		,a.DeletePermissionIndicator
	FROM dbo.AccessRule a
	INNER JOIN dbo.AccessRuleActor AS ara ON ara.AccessRuleID = a.AccessRuleID
		AND ara.intRowStatus = 0
	INNER JOIN dbo.tstUserTable AS u ON u.idfUserID = @UserID
		AND u.intRowStatus = 0
	INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = u.idfPerson
		AND egm.intRowStatus = 0
	INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfSiteGroup = a.GrantingActorSiteGroupID
	LEFT JOIN dbo.tflSiteToSiteGroup AS sgs ON sgs.idfsSite = u.idfsSite
	WHERE a.intRowStatus = 0
		AND (
			ara.ActorSiteGroupID = sgs.idfSiteGroup
			OR ara.ActorSiteID = u.idfsSite
			OR ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
			OR ara.ActorUserID = @UserID
			)
	
	UNION
	
	SELECT a.AccessRuleID
		,a.GrantingActorSiteID AS SiteID
		,a.ReadPermissionIndicator
		,a.AccessToPersonalDataPermissionIndicator
		,a.AccessToGenderAndAgeDataPermissionIndicator
		,a.WritePermissionIndicator
		,a.DeletePermissionIndicator
	FROM dbo.AccessRule a
	INNER JOIN dbo.AccessRuleActor AS ara ON ara.AccessRuleID = a.AccessRuleID
		AND ara.intRowStatus = 0
	INNER JOIN dbo.tstUserTable AS u ON u.idfUserID = @UserID
		AND u.intRowStatus = 0
	INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = u.idfPerson
		AND egm.intRowStatus = 0
	LEFT JOIN dbo.tflSiteToSiteGroup AS sgs ON sgs.idfsSite = u.idfsSite
	WHERE a.intRowStatus = 0 
		AND a.GrantingActorSiteID IS NOT NULL 
		AND (
			ara.ActorSiteGroupID = sgs.idfSiteGroup
			OR ara.ActorSiteID = u.idfsSite
			OR ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
			OR ara.ActorUserID = @UserID
			)
	ORDER BY a.AccessRuleID;
END
