
--*************************************************************************************************
-- Name: FN_GBL_GIS_Region_GET
--
-- Description: 
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 04/10/2021 Initial release.

-- Testing code:
/*
 SELECT * FROM report.FN_GBL_GIS_Region_GET('en',19000003)	--Region
*/
-- ************************************************************************************************


CREATE FUNCTION [Report].[FN_GBL_GIS_Region_GET](@LangID  NVARCHAR(50), @type BIGINT)
RETURNS @GIS_ReferenceRepair TABLE
	(
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
		r.idfsReference as idfsRegion, 
		c.idfsReference as idfsCountry,
		r.node,
		r.[name],
		r.idfsGISReferenceType, 
		r.strDefault, 
		r.LongName,
		r.intOrder,
		r.ExtendedName,
		r.intRowStatus

	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*Region*/) r
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON r.node.GetAncestor(1) = c.node AND c.intRowStatus = 0
                                                     
	RETURN
END


