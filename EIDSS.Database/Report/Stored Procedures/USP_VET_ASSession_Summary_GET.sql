-- ============================================================================
-- Name: report.USP_VET_ASSession_Summary_GET
-- Description:	Get Summary information for Session.
--                      
-- Author: Mark Wilson
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Mark Wilson		07/14/2022 Initial release
-- Mike Kornegay	09/28/2022 Changed HA code for strDiagnosis from 32 (livestock) to 96 (livestock and avian)
--							   and removed blnChecked = 1 from where on diagnosis concat.
--
/*

--Example of a call of procedure:

EXEC report.USP_VET_ASSession_Summary_GET 155415660001456,'en-US'

*/
CREATE  PROCEDURE [Report].[USP_VET_ASSession_Summary_GET]
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS

BEGIN

	DECLARE 
		@intTotalSamples INT,
		@intTotalPositive INT,
		@intTotalAnimalsSampled INT

	SELECT
		@intTotalSamples = SUM(MSS.intSamplesQty),
		@intTotalPositive = SUM(MSS.intPositiveAnimalsQty),
		@intTotalAnimalsSampled = SUM(MSS.intSampledAnimalsQty)
	
	FROM dbo.tlbMonitoringSessionSummary MSS
	WHERE MSS.intRowStatus = 0
	AND MSS.idfMonitoringSession = @idfCase		

	SELECT   
		MSS.idfMonitoringSessionSummary AS idfsKey,
		F.strFarmCode AS strFarmCode,
		F.idfFarm AS idfFarm,
		dbo.FN_GBL_ConcatFullName(H.strLastName, H.strFirstName, H.strSecondName) AS strOwnerName,
		dbo.FN_GBL_GeoLocationString(@LangID,F.idfFarmAddress,NULL) AS strFarmAddress,
		spt.[name] AS strSpecies,
		G.[name] AS strSex,
		MSS.intSampledAnimalsQty AS intAnimalSampled,
		STUFF((SELECT ', ' +  st.name AS [text()]		
				FROM dbo.tlbMonitoringSessionSummarySample ss
				INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000087) st ON ss.idfsSampleType = st.idfsReference
				WHERE ss.idfMonitoringSessionSummary = MSS.idfMonitoringSessionSummary
				AND ss.blnChecked = 1
				FOR XML PATH ('')),1,2,'')	AS strSampleType,
		MSS.intSamplesQty AS intNumberOfSamples,
		MSS.datCollectionDate AS datCollectionDate,
		MSS.intPositiveAnimalsQty AS intPositiveNumber,
		STUFF((SELECT   ', ' + D.name AS [text()]
				FROM dbo.tlbMonitoringSessionSummaryDiagnosis MSD
				INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 96, 10020001) D ON MSD.idfsDiagnosis = D.idfsDiagnosis
				WHERE MSD.idfMonitoringSessionSummary = MSS.idfMonitoringSessionSummary --AND MSD.blnChecked = 1
				FOR XML PATH ('')),1,2,'') AS strDiagnosis,
		@intTotalSamples AS intTotalSamples,
		@intTotalPositive AS intTotalPositive,
		@intTotalAnimalsSampled AS intTotalAnimalsSampled
			
	FROM dbo.tlbMonitoringSessionSummary MSS
	INNER JOIN
	(	
		dbo.tlbFarm F
		LEFT JOIN dbo.tlbHuman H ON F.idfHuman = H.idfHuman  AND H.intRowStatus = 0
	) ON F.idfFarm = MSS.idfFarm AND F.intRowStatus = 0
			
	INNER JOIN	
	(	
		dbo.tlbSpecies S
		INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) AS spt ON spt.idfsReference = S.idfsSpeciesType
	) ON S.idfSpecies  = MSS.idfSpecies AND S.intRowStatus = 0			
			
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000007) AS G ON G.idfsReference = MSS.idfsAnimalSex

		
	WHERE MSS.intRowStatus = 0
	AND MSS.idfMonitoringSession = @idfCase			

END

