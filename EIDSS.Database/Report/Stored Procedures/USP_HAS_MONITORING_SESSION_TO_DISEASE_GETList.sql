




-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_TO_DISEASE_GETList
--
-- Description:	Get active surveillance monitoring session to disease list for the human 
-- module active surveillance edit/set up use cases.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Stephen Long     07/06/2019	Initial release
-- Doug Albanese	06/28/2022	Added "SampleID" to the return
-- Srini Goli		07/28/2022  updated to get distinct list of Diseases for HumanActiveSurveillanceSessionListOfSamples report

/* Testing sample:

 Exec [Report].[USP_HAS_MONITORING_SESSION_TO_DISEASE_GETList] 'en-US','155415660001434'

*/

-- ================================================================================================
CREATE PROCEDURE [Report].[USP_HAS_MONITORING_SESSION_TO_DISEASE_GETList] (
	@LanguageID NVARCHAR(50),
	@MonitoringSessionID BIGINT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SELECT DISTINCT 
			msd.idfMonitoringSessionToDiagnosis AS MonitoringSessionToDiseaseID,
			msd.idfMonitoringSession AS MonitoringSessionID,
			msd.idfsDiagnosis AS DiseaseID, 
			disease.name AS DiseaseName,
			msd.idfsSampleType AS SampleTypeID,
			sampleType.name AS SampleTypeName,
			--M.idfMaterial AS SampleID,
			msd.intOrder AS OrderNumber
		FROM dbo.tlbMonitoringSessionToDiagnosis msd
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS disease
			ON disease.idfsReference = msd.idfsDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) AS sampleType
			ON sampleType.idfsReference = msd.idfsSampleType
		LEFT JOIN tlbMaterial M
			ON M.idfMonitoringSession = msd.idfMonitoringSession
		WHERE msd.idfMonitoringSession = @MonitoringSessionID
			AND msd.intRowStatus = 0;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END