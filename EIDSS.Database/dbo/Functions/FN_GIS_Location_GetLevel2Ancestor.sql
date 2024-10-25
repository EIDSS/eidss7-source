-- ================================================================================================
-- Name: FN_GIS_Location_GetLevel2Ancestor
--
-- Description: Sets the ancestor to get for administrative level 2 based on the level of the child
--              administrative level.
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Stephen Long         04/08/2021 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GIS_Location_GetLevel2Ancestor] (@ChildNodeLevel INT)
RETURNS INT
AS
BEGIN
	RETURN CASE @ChildNodeLevel
						WHEN 6
							THEN 3
						WHEN 5
							THEN 2
						WHEN 4
							THEN 1
						WHEN 3
							THEN 0
						END;
END;
