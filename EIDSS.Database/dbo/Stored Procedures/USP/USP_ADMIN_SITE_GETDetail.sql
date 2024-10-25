-- ================================================================================================
-- Name: USP_ADMIN_SITE_GETDetail		
-- 
-- Description: Returns information about a site based on the user and/or site ID.
--
-- Author: Lamont Mitchell
-- 
-- Revision History:
-- Name                   Date       Change Detail
-- ---------------------- ---------- -------------------------------------------------------------
-- Lamont Mitchell        11/20/2018 Initial Created
-- Lamont Mitchell        02/04/2019 Had to Fix Return results someone modified this proc.
-- Asim Karim             04/04/2019 Modified proc to return Region, Rayon & Settlement from 
--                                   OfficeID
-- Stephen Long           11/11/2019 Added language ID parameter and switched to EIDSS 7 function 
--                                   call.
-- Stephen Long           12/29/2019 Added row status to the query.
-- Stephen Long           06/24/2021 Changed over to location hierarchy instead of using the 
--                                   region and rayon fields.
-- Stephen Long           06/30/2021 Added site type name and organization name.
-- Stephen Long           07/14/2021 Added active status indicator.
-- Stephen Long           10/27/2021 Added parent site name to the query.
--
-- Sample Code
-- EXEC [dbo].[USP_ADMIN_SITE_GETDetail] @LanguageID = 'az-L', @SiteID = 5, @UserID = 29  -- Azerbaijan
-- EXEC [dbo].[USP_ADMIN_SITE_GETDetail] @LanguageID = 'ru', @SiteID = 5, @UserID = 29	-- Russian
-- EXEC [dbo].[USP_ADMIN_SITE_GETDetail] @LanguageID = 'en', @SiteID = 5, @UserID = 29	-- English
-- EXEC [dbo].[USP_ADMIN_SITE_GETDetail] @LanguageID = 'ka', @SiteID = 5, @UserID = 29	-- Georgian
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SITE_GETDetail] @LanguageID NVARCHAR(50)
	,@SiteID BIGINT
	,@UserID BIGINT = NULL
AS
BEGIN
	DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @ReturnCode BIGINT = 0;

	SET NOCOUNT ON;

	BEGIN TRY
		SELECT DISTINCT s.idfsSite AS SiteID
			,s.idfsSiteType AS SiteTypeID
			,siteType.name AS SiteTypeName
			,s.idfCustomizationPackage AS CustomizationPackageID
			,cp.strCustomizationPackageName AS CustomizationPackageName
			,s.idfOffice AS SiteOrganizationID
			,organizationAbbreviation.name AS SiteOrganizationName
			,s.strSiteName AS SiteName
			,s.strHASCsiteID AS HASCSiteID
			,s.strSiteID AS EIDSSSiteID
			,s.idfsParentSite AS ParentSiteID
			,parentSite.strSiteName AS ParentSiteName 
			,(CASE WHEN s.intRowStatus = 0 THEN 'true' ELSE 'false' END) AS ActiveStatusIndicator
			,s.intRowStatus AS RowStatus
			,lcp.idfsLanguage AS LanguageID
			,ut.idfUserID AS UserID
			,ut.idfPerson AS PersonID
			,ut.PreferredLanguageID AS PreferredLanguageID
			,br.idfsReferenceType AS PreferredLanguageReferenceTypeID
			,br.strBaseReferenceCode AS PreferredLanguageReferenceCode
			,br.strDefault AS PreferredLanguageName
			,br.intHACode AS PreferredLanguageAccessoryCode
			,adminLevel1.idfsReference AS CountryID
			,adminLevel1.name AS CountryName
			,adminLevel2.idfsReference AS AdministrativeLevel2ID
			,adminLevel2.name AS AdministrativeLevel2Name
			,adminLevel3.idfsReference AS AdministrativeLevel3ID
			,adminLevel3.name AS AdministrativeLevel3Name
		FROM dbo.tstSite s
		INNER JOIN dbo.tstCustomizationPackage cp ON cp.idfCustomizationPackage = s.idfCustomizationPackage
		LEFT JOIN dbo.trtLanguageToCP lcp ON lcp.idfCustomizationPackage = cp.idfCustomizationPackage
			AND lcp.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		LEFT JOIN dbo.tstUserTable ut ON ut.idfUserID = @UserId
		LEFT JOIN dbo.trtBaseReference br ON br.idfsBaseReference = ut.PreferredLanguageID
		LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice
		LEFT JOIN dbo.tlbGeoLocationShared gls ON o.idfLocation = gls.idfGeoLocationShared
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gls.idfsLocation
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000001) AS adminLevel1 ON adminLevel1.idfsReference = gls.idfsCountry
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000003) adminLevel2 ON adminLevel2.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel1Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000002) adminLevel3 ON adminLevel3.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel2Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement ON settlement.idfsReference = gls.idfsLocation
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000085) AS siteType ON siteType.idfsReference = s.idfsSiteType
		LEFT JOIN dbo.trtStringNameTranslation snt ON br.idfsBaseReference = snt.idfsBaseReference
			AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) AS organizationAbbreviation ON organizationAbbreviation.idfsReference = o.idfsOfficeAbbreviation
		LEFT JOIN dbo.tstSite parentSite ON parentSite.idfsSite = s.idfsParentSite 
		WHERE s.idfsSite = @SiteID
			AND (
				(ut.idfUserID = @UserID)
				OR (@UserID IS NULL)
				);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
