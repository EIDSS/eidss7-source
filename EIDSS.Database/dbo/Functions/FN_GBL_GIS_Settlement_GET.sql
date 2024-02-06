
--*************************************************************************************************
-- Name: FN_GBL_GIS_Settlement_GET
--
-- Description: 
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 04/10/2021 Initial release.

-- Testing code:
/*
 SELECT * FROM dbo.FN_GBL_GIS_Settlement_GET('en',19000004) --Settlement
*/
-- ************************************************************************************************


CREATE FUNCTION [dbo].[FN_GBL_GIS_Settlement_GET](@LangID  NVARCHAR(50), @type BIGINT)
RETURNS @GIS_ReferenceRepair TABLE
	(
		idfsSettlement BIGINT,
		idfsRayon BIGINT,
        idfsRegion BIGINT,
        idfsCountry BIGINT,
        node HIERARCHYID,
        [name] NVARCHAR(255),
        idfsGISReferenceType BIGINT,
        strDefault NVARCHAR(200),
        LongName NVARCHAR(255),
        intOrder INT,
        idfsType BIGINT,
        ExtendedName NVARCHAR(200),
        intRowStatus INT
    )
AS
BEGIN
 
	INSERT INTO @GIS_ReferenceRepair
	SELECT
		s.idfsReference as idfsSettlement, 
		rr.idfsReference as idfsRayon, 
		r.idfsReference as idfsRegion, 
		c.idfsReference as idfsCountry,
		s.node,
		s.[name],
		s.idfsGISReferenceType, 
		s.strDefault, 
		s.LongName,
		s.intOrder,
		s.idfsType,
		s.ExtendedName,
		s.intRowStatus

	FROM dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004 /*Settlement*/) s
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*Rayon*/) rr
	ON s.node.GetAncestor(1) = rr.node AND rr.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*Region*/) r
	ON rr.node.GetAncestor(1) = r.node AND r.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON r.node.GetAncestor(1) = c.node AND c.intRowStatus = 0
                                                     
	RETURN
END


