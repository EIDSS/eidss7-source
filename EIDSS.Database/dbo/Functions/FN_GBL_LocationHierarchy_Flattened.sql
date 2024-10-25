-- =============================================
-- Author:		Steven Verner
-- Create date: 12/1/2021
-- Description:	Returns the complete location hierarchy for the given location on a single row.
-- =============================================
CREATE FUNCTION [dbo].[FN_GBL_LocationHierarchy_Flattened] 
(
	@languageId nvarchar(20)
)
RETURNS @ResultsTable TABLE 
(
	 idfsLocation BIGINT
	,AdminLevel1ID BIGINT
	,AdminLevel2ID BIGINT
	,AdminLevel3ID BIGINT
	,AdminLevel4ID BIGINT
	,AdminLevel5ID BIGINT
	,AdminLevel6ID BIGINT
	,AdminLevel7ID BIGINT
	,AdminLevel1Name NVARCHAR(200)
	,AdminLevel2Name NVARCHAR(200)
	,AdminLevel3Name NVARCHAR(200)
	,AdminLevel4Name NVARCHAR(200)
	,AdminLevel5Name NVARCHAR(200)
	,AdminLevel6Name NVARCHAR(200)
	,AdminLevel7Name NVARCHAR(200)
	,Node HIERARCHYID
	,Level INT
	,LevelType NVARCHAR(100)
	,idfsLanguage BIGINT

)
AS
BEGIN
	DECLARE @lid BIGINT 

	SELECT @lid = dbo.FN_GBL_LanguageCode_GET(@languageId)

	INSERT INTO @ResultsTable
	SELECT 
		 ld.idfsLocation
		,ld.Level1ID
		,ld.Level2ID
		,ld.Level3ID
		,ld.Level4ID
		,ld.Level5ID
		,ld.Level6ID
		,ld.Level7ID
		,ld.Level1Name
		,ld.Level2Name
		,ld.Level3Name
		,ld.Level4Name
		,ld.Level5Name
		,ld.Level6Name
		,ld.Level7Name
		,ld.Node
		,ld.Level
		,ld.LevelType
		,ld.idfsLanguage
	FROM gisLocationDenormalized ld
	WHERE ld.idfsLanguage =@lid
	
	RETURN 
END;
