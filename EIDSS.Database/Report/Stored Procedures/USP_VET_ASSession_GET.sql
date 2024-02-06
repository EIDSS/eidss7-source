

--=================================================================================================
-- Name: USP_VET_ASSession_GET
--
-- Description: Returns dataset for monitoring session details report
--
-- Author: Mark Wilson
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		07/12/2022 initial release
--=================================================================================================

/*
--Example of a call of procedure:
exec [report].USP_VET_ASSession_GET  155415660001459, 'en-US'
exec [report].USP_VET_ASSession_GET  155415660001406, 'en-US'
*/


CREATE  PROCEDURE [report].USP_VET_ASSession_GET
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS	

BEGIN

	SELECT   
		ms.idfMonitoringSession,
		ms.strMonitoringSessionID		AS strSessionID,
		sstatus.[name]					AS strSessionStatus,
		ms.datEnteredDate				AS datEnteredDate,
		tc.strCampaignID				AS strCampaignID,
		tc.strCampaignName				AS strCampaignName,
		ts.strSiteName					AS strSite,
		dbo.FN_GBL_ConcatFullName(tp.strFamilyName, tp.strFirstName, tp.strSecondName) AS strOfficer,
		ms.datStartDate				AS datStartDate,
		ms.datEndDate					AS datEndDate,
		L.AdminLevel2Name			AS strRegion,
		L.AdminLevel2ID					AS idfsRegion,
		L.AdminLevel3Name				AS strRayon,
		L.AdminLevel3ID					AS idfsRayon,
		L.AdminLevel4Name				AS strSettlement,
		L.AdminLevel4ID					AS idfsSettlement
			
	
	FROM dbo.tlbMonitoringSession ms

	LEFT JOIN dbo.tlbCampaign tc
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000116) ctype ON ctype.idfsReference = tc.idfsCampaignType
				ON tc.idfCampaign = ms.idfCampaign AND tc.intRowStatus = 0

	LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) L ON L.idfsLocation = ms.idfsLocation
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000117) sstatus ON sstatus.idfsReference = ms.idfsMonitoringSessionStatus
	LEFT JOIN dbo.tstSite ts ON ts.idfsSite = ms.idfsSite
	LEFT JOIN dbo.tlbPerson tp ON tp.idfPerson = ms.idfPersonEnteredBy
	
	WHERE ms.idfMonitoringSession = @idfCase
	AND ms.SessionCategoryID IN (10502002, 10502009)  -- Avian or Livestock sessions only
	AND ms.intRowStatus = 0
END