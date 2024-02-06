-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_SAMPLE_TO_DISEASE_GETList
--
-- Description:	Gets the diseases associated with a sample record for veterinary surveillance session \
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay	08/12/2022 Initial release 
-- Mike Kornegay	08/17/2022 Modified comments
-- Mike Kornegay	08/18/2022 Corrected where condition for SampleID.
-- Mike Kornegay	08/29/2022 Remove extra parenthesis from where clause.
-- Mike Kornegay	11/01/2022 Correct where clause to return only specified session.
--
-- EXEC	@return_value = [dbo].[USP_VAS_MONITORING_SESSION_SAMPLE_TO_DISEASE_GETList]
		--@LanguageID = N'en-US',
		--@MonitoringSessionID = 155415660001435,
		--@SampleID = 155575800003466
		
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_SAMPLE_TO_DISEASE_GETList] (
	@LanguageID NVARCHAR(50),
	@MonitoringSessionID BIGINT,
	@SampleID BIGINT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			msm.idfMonitoringSessionToMaterial AS MonitoringSessionToMaterialID,
			msm.idfMonitoringSession AS MonitoringSessionID,
			msm.idfMaterial AS SampleID,
			msm.idfsSampleType AS SampleTypeID,
			msm.idfsDisease AS DiseaseID,
			disease.name AS DiseaseName
		FROM dbo.tlbMonitoringSessionToMaterial msm
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS disease
			ON disease.idfsReference = msm.idfsDisease
		WHERE msm.intRowStatus = 0
			AND msm.idfMonitoringSession = @MonitoringSessionID
			AND (msm.idfMaterial = @SampleID OR @SampleID IS NULL);
		
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
