

--*************************************************************
-- Name 				: dbo.FN_GBL_Location_Ancestry
-- Description			: The FUNCTION returns all the ancestry details of a location
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*

SELECT * FROM dbo.FN_GBL_Location_Ancestry(@idfsLocation)

*/
--*************************************************************
CREATE FUNCTION [dbo].[FN_GBL_Location_Ancestry]
(
	@idfsLocation BIGINT
)
RETURNS TABLE
AS
	RETURN
	( 

			SELECT 
				L1.idfsLocation AS AdminLevel1,
				L2.idfsLocation AS AdminLevel2,
				L3.idfsLocation AS AdminLevel3,
				L4.idfsLocation AS AdminLevel4,
				L5.idfsLocation AS AdminLevel5,
				L6.idfsLocation AS AdminLevel6,
				L7.idfsLocation AS AdminLevel7,
				L.idfsLocation

			FROM dbo.gisLocation L
			INNER JOIN dbo.gisLocation L1 ON L1.node = L.node.GetAncestor(L.node.GetLevel() - 1)
			LEFT JOIN dbo.gisLocation L2 ON L2.node.IsDescendantOf(L1.node) = 1 AND L2.node.GetLevel() = 2 AND L.node.IsDescendantOf(L2.node) = 1
			LEFT JOIN dbo.gisLocation L3 ON L3.node.IsDescendantOf(L2.node) = 1 AND L3.node.GetLevel() = 3 AND L.node.IsDescendantOf(L3.node) = 1
			LEFT JOIN dbo.gisLocation L4 ON L4.node.IsDescendantOf(L3.node) = 1 AND L4.node.GetLevel() = 4 AND L.node.IsDescendantOf(L4.node) = 1
			LEFT JOIN dbo.gisLocation L5 ON L5.node.IsDescendantOf(L4.node) = 1 AND L5.node.GetLevel() = 5 AND L.node.IsDescendantOf(L5.node) = 1
			LEFT JOIN dbo.gisLocation L6 ON L6.node.IsDescendantOf(L5.node) = 1 AND L6.node.GetLevel() = 6 AND L.node.IsDescendantOf(L6.node) = 1
			LEFT JOIN dbo.gisLocation L7 ON L7.node.IsDescendantOf(L6.node) = 1 AND L7.node.GetLevel() = 7 AND L.node.IsDescendantOf(L7.node) = 1

			WHERE L.idfsLocation = @idfsLocation 
			

	)

