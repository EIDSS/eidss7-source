

-- ================================================================================================
-- Name: FN_GIS_Location_GetLevel0Ancestor
--
-- Description: Sets the ancestor to get for administrative level 0 based on the level of the child
--              administrative level.
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Stephen Long         06/07/2021 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GIS_Location_GetLevel0Ancestor] (@ChildNodeLevel INT)
RETURNS INT
AS
BEGIN
	RETURN CASE @ChildNodeLevel
			WHEN 6
				THEN 5
			WHEN 5
				THEN 4
			WHEN 4
				THEN 3
			WHEN 3
				THEN 2
			WHEN 2
				THEN 1
			WHEN 1
				THEN 0
			ELSE 0
			END;
END;
