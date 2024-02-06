-- ================================================================================================
-- Name: USP_GBL_SITE_GROUP_GETDetail		
-- 
-- Description: Returns information about a site group based on the site group ID.
-- 
-- Revision History:
-- Name                   Date       Change Detail
-- ---------------------- ---------- -------------------------------------------------------------
-- Stephen Long           11/29/2019 Initial release.
-- Stephen Long           12/29/2019 Added row status to the query.
-- Stephen Long           06/19/2021 Changed for location hierarchy; renamed term rayon to 
--                                   administrative level and updated join.
-- Stephen Long           06/27/2021 Changed rayon join alias.
-- Stephen Long           07/26/2021 Added administrative levels, settlement and active status 
--                                   indicator fields.
-- Stephen Long           03/15/2023 Changed over to location hierarchy flattened.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_SITE_GROUP_GETDetail]
    @LanguageID NVARCHAR(50),
    @SiteGroupID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT sg.idfSiteGroup AS SiteGroupID,
               sg.idfsSiteGroupType AS SiteGroupTypeID,
               siteGroupType.name AS SiteGroupTypeName,
               sg.idfsCentralSite AS CentralSiteID,
               s.strSiteName AS CentralSiteName,
               s.strSiteID AS CentralEIDSSSiteID,
               sg.strSiteGroupName AS SiteGroupName,
               lh.AdminLevel1ID AS CountryID,
               lh.AdminLevel2ID AS AdministrativeLevel1ID,
               lh.AdminLevel2Name AS AdministrativeLevel1Name,
               lh.AdminLevel3ID AS AdministrativeLevel2ID,
               lh.AdminLevel3Name AS AdministrativeLevel2Name,
               NULL AS AdministrativeLevel3ID,
               NULL AS AdministrativeLevel3Name,
               settlement.idfsReference AS SettlementID,
               settlement.name AS SettlementName,
               sg.strSiteGroupDescription AS SiteGroupDescription,
               (CASE
                    WHEN sg.intRowStatus = 0 THEN
                        'true'
                    ELSE
                        'false'
                END
               ) AS ActiveStatusIndicator,
               sg.intRowStatus AS RowStatus
        FROM dbo.tflSiteGroup sg
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = sg.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = g.idfsLocation
            LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlement
                ON g.node.IsDescendantOf(settlement.node) = 1
            LEFT JOIN dbo.tstSite AS s
                ON s.idfsSite = sg.idfsCentralSite
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000524) AS siteGroupType
                ON siteGroupType.idfsReference = sg.idfsSiteGroupType
        WHERE sg.idfSiteGroup = @SiteGroupID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
