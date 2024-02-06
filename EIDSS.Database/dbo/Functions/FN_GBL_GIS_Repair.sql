--*************************************************************
-- Name 				: FN_GBL_GIS_Repair
-- Description			: Returns the reference values for given reference type and language and node level.
--          
-- Author               : Stephen Long
-- Revision History
--		Name       Date       Change Detail
--
--*************************************************************
CREATE FUNCTION [dbo].[FN_GBL_GIS_Repair] (
	@LanguageID NVARCHAR(50)
	,@LocationID HIERARCHYID
	,@Level INT
	)
RETURNS NVARCHAR(1000)
AS
BEGIN
	DECLARE @LevelName NVARCHAR(1000)

	SELECT @LevelName = levelName.name
			FROM dbo.gisLocation g 
				INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, CASE @Level
			WHEN 1
				THEN 19000001
			WHEN 2
				THEN 19000003
			WHEN 3
				THEN 19000002
			WHEN 4
				THEN 19000004
			WHEN 5
				THEN 19000005
			WHEN 6
				THEN 19000006
			WHEN 7
				THEN 19000007
			END) levelName ON levelName.idfsReference = g.idfsLocation
			WHERE @LocationID.IsDescendantOf(g.node) = 1
				AND g.node.GetLevel() = @Level
			
				RETURN @LevelName

			END
