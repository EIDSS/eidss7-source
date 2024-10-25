

-- ================================================================================================
-- Name: Report.FN_VetOrHumanSiteList_GET
--
-- Description:	returns facilities for the report Laboratory Research Result
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/*
--Example of a call of function:

select 
	ts.idfsSite, 
	ts.strSiteName, 
	ts.strSiteID

from Report.FN_SiteListForLMAReport_GET() hvl
inner join dbo.tstSite ts on ts.idfsSite = hvl.idfsSite
 

*/


CREATE FUNCTION [Report].[FN_SiteListForLMAReport_GET]()
RETURNS TABLE
AS
RETURN
(
	
	SELECT 
		ts.idfsSite 
	FROM dbo.trtBaseReferenceAttribute tbra
	INNER JOIN dbo.trtAttributeType tat ON tat.idfAttributeType = tbra.idfAttributeType AND tat.strAttributeTypeName = 'attr_part_in_report'
	INNER JOIN dbo.tlbOffice oabr ON oabr.idfsOfficeAbbreviation = tbra.idfsBaseReference AND oabr.intRowStatus = 0
	INNER JOIN dbo.tstSite ts ON ts.idfOffice = oabr.idfOffice AND ts.intRowStatus = 0 
	
	WHERE tbra.varValue = 10290030
		
) 
