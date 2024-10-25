


--=================================================================================================
-- Name: report.USP_VET_ASSession_GET
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
exec [report].USP_VET_ASSessionActions_GET  155415660001345, 'en-US'
exec [report].USP_VET_ASSessionActions_GET  155415660001386, 'en-US'
*/

CREATE PROCEDURE [Report].[USP_VET_ASSessionActions_GET]
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS	

BEGIN

	SELECT  
		a.idfMonitoringSessionAction AS idfsKey,
		msat.[name] AS strAction,
		a.datActionDate AS datDate,
		dbo.FN_GBL_ConcatFullName(p.strFamilyName,p.strFirstName, p.strSecondName) AS strEnteredBy,
		a.strComments AS strComment,
		msas.[name] AS	strStatus
		 
	FROM dbo.tlbMonitoringSessionAction a 
	INNER JOIN dbo.tlbPerson p ON a.idfPersonEnteredBy = p.idfPerson
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000127) AS msat ON msat.idfsReference = a.idfsMonitoringSessionActionType
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000128) AS msas ON msas.idfsReference = a.idfsMonitoringSessionActionStatus
	
	WHERE a.idfMonitoringSession = @idfCase  
	AND a.intRowStatus = 0  		 
		 
END