-- ================================================================================================
-- Name: USP_VCT_MONITORING_SESSION_SPECIES_TO_SAMPLE_TYPE_GETList
--
-- Description:	Get active surveillance monitoring session to sample type list for the veterinary 
-- module active surveillance edit/set up use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/17/2018 Initial release
-- Stephen Long     05/03/2019 Updated for API; removed maintenance flag.
-- Stephen Long     04/27/2020 Added accessory code to determine avian or livestock.
-- Stephen Long     04/30/2020 Added created date to the model.
-- Stephen Long     09/24/2020 Added campaign ID parameter and where criteria and sample collected 
--                             count.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_SPECIES_TO_SAMPLE_TYPE_GETList] (
	@LanguageID NVARCHAR(50)
	,@MonitoringSessionID BIGINT = NULL
	,@CampaignID BIGINT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SELECT mst.MonitoringSessionToSampleType AS MonitoringSessionToSampleTypeID
			,mst.idfMonitoringSession AS MonitoringSessionID
			,mst.idfsSpeciesType AS SpeciesTypeID
			,speciesType.intHACode AS AvianOrLivestock
			,speciesType.name AS SpeciesTypeName
			,mst.idfsSampleType AS SampleTypeID
			,sampleType.name AS SampleTypeName
			,mst.intOrder AS OrderNumber
			,mst.AuditCreateDTM AS CreatedDate
			,(
				SELECT COUNT(m.idfMaterial)
				FROM dbo.tlbMaterial m
				INNER JOIN dbo.tlbSpecies AS s ON s.idfSpecies = m.idfSpecies
					AND s.intRowStatus = 0
				WHERE m.intRowStatus = 0
					AND m.idfMonitoringSession = mst.idfMonitoringSession
					AND m.idfsSampleType = mst.idfsSampleType
					AND s.idfsSpeciesType = mst.idfsSpeciesType
				) AS SampleCollectedCount
			,cst.CampaignToSampleTypeUID
			,mst.intRowStatus AS RowStatus
			,'R' AS RowAction
		FROM dbo.MonitoringSessionToSampleType mst
		INNER JOIN dbo.tlbMonitoringSession AS ms ON ms.idfMonitoringSession = mst.idfMonitoringSession
			AND ms.intRowStatus = 0
		LEFT JOIN dbo.CampaignToSampleType AS cst ON cst.idfCampaign = ms.idfCampaign
			AND cst.idfsSampleType = mst.idfsSampleType
			AND cst.idfsSpeciesType = mst.idfsSpeciesType
			AND cst.intRowStatus = 0
			AND @CampaignID IS NOT NULL
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) AS speciesType ON speciesType.idfsReference = mst.idfsSpeciesType
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) AS sampleType ON sampleType.idfsReference = mst.idfsSampleType
		WHERE mst.intRowStatus = 0
			AND (
				(mst.idfMonitoringSession = @MonitoringSessionID)
				OR (@MonitoringSessionID IS NULL)
				)
			AND (
				(ms.idfCampaign = @CampaignID)
				OR (@CampaignID IS NULL)
				)
		GROUP BY mst.MonitoringSessionToSampleType
			,mst.idfMonitoringSession
			,mst.idfsSpeciesType
			,speciesType.intHACode
			,speciesType.name
			,mst.idfsSampleType
			,sampleType.name
			,cst.CampaignToSampleTypeUID
			,mst.intOrder
			,mst.AuditCreateDTM
			,mst.intRowStatus;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
