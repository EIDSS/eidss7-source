-- ================================================================================================
-- Name: USP_ADMIN_NEIGHBORING_SITE_GETList		
-- 
-- Description: Returns a list of neighboring sites for a specific site ID.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/04/2022 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_NEIGHBORING_SITE_GETList] @SiteID BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NeighboringSites TABLE (
		AccessRuleID BIGINT, 
		SiteID BIGINT
	);
	DECLARE @SiteAccessRuleGrantee TABLE (
		AccessRuleID BIGINT
	);

	BEGIN TRY
		-- Logged in user site ID is a grantor, then get list of grantee sites.
		INSERT INTO @NeighboringSites
		SELECT ar.AccessRuleID,
			ara.ActorSiteID
		FROM dbo.AccessRule ar
		INNER JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = ar.AccessRuleID
			AND ara.intRowStatus = 0
		WHERE ar.intRowStatus = 0
			AND ar.BorderingAreaRuleIndicator = 1		
			AND ar.GrantingActorSiteID = @SiteID
			AND ara.ActorSiteID IS NOT NULL
			AND ara.ActorSiteID <> @SiteID
		GROUP BY ara.ActorSiteID, 
			ar.AccessRuleID;

		-- Logged in user site ID access rules as a grantee.
		INSERT INTO @SiteAccessRuleGrantee
		SELECT ara.AccessRuleID
		FROM dbo.AccessRuleActor ara
		INNER JOIN dbo.AccessRule ar ON ar.AccessRuleID = ara.AccessRuleID 
			AND ar.intRowStatus = 0
		WHERE ara.ActorSiteID = @SiteID
			AND ara.intRowStatus = 0
			AND ar.BorderingAreaRuleIndicator = 1;

		-- Select all grantee sites that the site is also a grantee of.
		INSERT INTO @NeighboringSites
		SELECT sg.AccessRuleID, 
			ara.ActorSiteID 
		FROM @SiteAccessRuleGrantee sg
		INNER JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = sg.AccessRuleID
			AND ara.intRowStatus = 0
		WHERE ara.ActorSiteID <> @SiteID 
			AND ara.ActorSiteID IS NOT NULL 
		GROUP BY ara.ActorSiteID, 
			sg.AccessRuleID;

		SELECT SiteID
		FROM @NeighboringSites;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
