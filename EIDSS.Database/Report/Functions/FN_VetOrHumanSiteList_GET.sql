
-- ================================================================================================
-- Name: Report.FN_VetOrHumanSiteList_GET
--
-- Description:	returns sites filtered by ha code
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/* Sample Code

Example of a call of function:

Input Parameter:
2	=	HumanSites
96	=	VetSites

select 
	ts.intFlags, 
	ts.idfsSite, 
	ts.strSiteName
from report.FN_VetOrHumanSiteList_GET(2) hvl
inner join tstSite ts on ts.idfsSite = hvl.idfsSite
 

*/



CREATE FUNCTION [Report].[FN_VetOrHumanSiteList_GET]
(
	@intHACode BIGINT
)
RETURNS TABLE
AS
RETURN
(
	SELECT 
		idfsSite
	FROM dbo.tstSite
	WHERE intFlags & @intHACode > 0
)	
