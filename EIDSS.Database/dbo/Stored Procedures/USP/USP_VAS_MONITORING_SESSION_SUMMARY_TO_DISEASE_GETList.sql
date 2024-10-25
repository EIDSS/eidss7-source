
-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_SUMMARY_TO_DISEASE_GETList
--
-- Description:	Get active surveillance monitoring session aggregate disease list for the veterinary 
-- module active surveillance edit/set up use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay	06/28/2022 Original
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_SUMMARY_TO_DISEASE_GETList] (
	@LanguageID NVARCHAR(50),
	@MonitoringSessionSummaryID BIGINT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SELECT msd.idfMonitoringSessionSummary AS MonitoringSessionSummaryID,
			msd.idfsDiagnosis AS DiseaseID, 
			disease.name AS DiseaseName
		FROM dbo.tlbMonitoringSessionSummaryDiagnosis msd
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS disease
			ON disease.idfsReference = msd.idfsDiagnosis
		WHERE msd.idfMonitoringSessionSummary = @MonitoringSessionSummaryID
			AND msd.intRowStatus = 0;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
