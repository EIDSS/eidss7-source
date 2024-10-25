-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_TO_DISEASE_GETList
--
-- Description:	Get active surveillance monitoring session to disease list for the veterinary 
-- module active surveillance edit/set up use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/21/2019 Initial release
-- Mike Korengay	02/03/2022 Change RowAction from nvarchar to int to match other stored procs
-- Mike Kornegay    02/15/2022 Add AvianOrLivestock field for setting session report type
-- Mike Kornegay	06/22/2022 Add RecordCount
-- Mike Kornegay	12/21/2022 Add idfsUsingType for disease to return list.
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_TO_DISEASE_GETList] (
	@LanguageID NVARCHAR(50),
	@MonitoringSessionID BIGINT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SELECT msd.idfMonitoringSessionToDiagnosis AS MonitoringSessionToDiseaseID,
			msd.idfMonitoringSession AS MonitoringSessionID,
			msd.idfsDiagnosis AS DiseaseID, 
			disease.name AS DiseaseName,
			diagnosis.idfsUsingType AS DiseaseUsingType,
			msd.idfsSpeciesType AS SpeciesTypeID,
			speciesType.name AS SpeciesTypeName,
			speciesType.intHACode AS AvianOrLivestock,
			msd.idfsSampleType AS SampleTypeID,
			sampleType.name AS SampleTypeName,
			msd.intOrder AS OrderNumber,
			msd.intRowStatus AS RowStatus,
			COUNT(*) OVER (PARTITION BY 1) AS RecordCount,
			0 AS RowAction
		FROM dbo.tlbMonitoringSessionToDiagnosis msd
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) AS disease
			ON disease.idfsReference = msd.idfsDiagnosis
		INNER JOIN dbo.trtDiagnosis AS diagnosis
			ON diagnosis.idfsDiagnosis = disease.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000086) AS speciesType
			ON speciesType.idfsReference = msd.idfsSpeciesType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) AS sampleType
			ON sampleType.idfsReference = msd.idfsSampleType
		WHERE msd.idfMonitoringSession = @MonitoringSessionID
			AND msd.intRowStatus = 0;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
