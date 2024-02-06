


--*************************************************************************************************
-- Name: FN_GBL_GIS_Ancestry_GET
--
-- Description: Return all ancestry of a given location
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mark Wilson		 Initial release.
-- Stephen Long    06/24/2021 Modified to bring back countries for foreign addresses.
-- SV and MCW	   10/12/2021 Updated to pull from gisLocation and join to gisBaseReference
--				              also removed CountryNode so that foreign addresses are returned
-- Testing code:
/*
 SELECT * FROM dbo.FN_GBL_GIS_Ancestry_GET('en-US',75111070000801) 
 SELECT * FROM dbo.FN_GBL_GIS_Ancestry_GET('en-US',1344420000000)
 SELECT * FROM dbo.FN_GBL_GIS_Ancestry_GET('en-US',19000002) 
 SELECT * FROM dbo.FN_GBL_GIS_Ancestry_GET('en-US',19000004) 

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************
CREATE FUNCTION [dbo].[FN_GBL_GIS_Ancestry_GET]
(
	@LangID  NVARCHAR(50), 
	@idfsLocation BIGINT NULL
	
)
RETURNS TABLE
AS
RETURN
(

	SELECT
	
		AdminLevel1.idfsReference AS idfsAdminLevel1,
		Adminlevel1.[name] AS strAdminLevel1,
		AdminLevel2.idfsReference AS idfsAdminLevel2,
		Adminlevel2.[name] AS strAdminLevel2,
		AdminLevel3.idfsReference AS idfsAdminLevel3,
		Adminlevel3.[name] AS strAdminLevel3,
		AdminLevel4.idfsReference AS idfsAdminLevel4,
		Adminlevel4.[name] AS strAdminLevel4

	FROM dbo.gisLocation L 
	INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AdminLevel1 ON L.node.IsDescendantOf(AdminLevel1.node) = 1  
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AdminLevel2 ON L.node.IsDescendantOf(AdminLevel2.node) = 1 
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AdminLevel3 ON L.node.IsDescendantOf(AdminLevel3.node) = 1 
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AdminLevel4 ON L.node.IsDescendantOf(AdminLevel4.node) = 1 

	WHERE L.idfsLocation = @idfsLocation 
--	OR @idfsLocation IS NULL
)

