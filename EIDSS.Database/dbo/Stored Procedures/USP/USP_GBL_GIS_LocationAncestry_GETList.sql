

-- ===========================================================================
-- Author:		Steven Verner
-- Create date: 10/27/2022
-- Description:	Returns the complete location Ancestry for the given location 
-- ===========================================================================

CREATE PROCEDURE [dbo].[USP_GBL_GIS_LocationAncestry_GETList]
	 @languageId nvarchar(10)
	,@locationId bigint
AS
	SELECT 
		 idfsLocation
		,AdminLevel1ID
		,AdminLevel2ID
		,AdminLevel3ID
		,AdminLevel4ID
		,AdminLevel5ID
		,AdminLevel6ID
		,AdminLevel7ID
		,AdminLevel1Name
		,AdminLevel2Name
		,AdminLevel3Name
		,AdminLevel4Name
		,AdminLevel5Name
		,AdminLevel6Name
		,AdminLevel7Name
		,Level
		,LevelType

	FROM FN_GBL_LocationHierarchy_Flattened(@languageId) f
	WHERE idfsLocation = @locationId 
RETURN 0
