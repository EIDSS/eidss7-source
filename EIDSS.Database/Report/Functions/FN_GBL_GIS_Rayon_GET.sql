
--*************************************************************************************************
-- Name: FN_GBL_GIS_Rayon_GET
--
-- Description: 
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 04/10/2021 Initial release.

-- Testing code:
/*
 SELECT * FROM report.FN_GBL_GIS_Rayon_GET('en',19000002) --Rayon
*/
-- ************************************************************************************************


CREATE FUNCTION [Report].[FN_GBL_GIS_Rayon_GET](@LangID  NVARCHAR(50), @type BIGINT)
RETURNS @GIS_ReferenceRepair TABLE
	(
		idfsRayon BIGINT,
        idfsRegion BIGINT,
        idfsCountry BIGINT,
        node HIERARCHYID,
        [name] NVARCHAR(255),
        idfsGISReferenceType BIGINT,
        strDefault NVARCHAR(200),
        LongName NVARCHAR(255),
        intOrder INT,
        ExtendedName NVARCHAR(200),
        intRowStatus INT
    )
AS
BEGIN
 
	INSERT INTO @GIS_ReferenceRepair
	SELECT
		rr.idfsReference as idfsRayon, 
		r.idfsReference as idfsRegion, 
		c.idfsReference as idfsCountry,
		rr.node,
		rr.[name],
		rr.idfsGISReferenceType, 
		rr.strDefault, 
		rr.LongName,
		rr.intOrder,
		rr.ExtendedName,
		rr.intRowStatus

	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*Rayon*/) rr
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*Region*/) r
	ON rr.node.GetAncestor(1) = r.node AND r.intRowStatus = 0
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON r.node.GetAncestor(1) = c.node AND c.intRowStatus = 0
                                                     
	RETURN
END


