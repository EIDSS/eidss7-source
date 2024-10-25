-- ================================================================================================
-- Name: FN_GIS_Location_GetLevel1Ancestor
--
-- Description: Sets the ancestor to get for administrative level 1 based on the level of the child
--              administrative level.
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Stephen Long         04/08/2021 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GIS_Location_GetLevel1Ancestor] (@ChildNodeLevel INT)
RETURNS INT
AS
BEGIN
	RETURN CASE @ChildNodeLevel
			WHEN 6
				THEN 4
			WHEN 5
				THEN 3
			WHEN 4
				THEN 2
			WHEN 3
				THEN 1
			END;
END;
