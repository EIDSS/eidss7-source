

-- ================================================================================================
-- Name: [USP_AS_CAMPAIGN_GETDetail]
--
-- Description: Gets data for active surveillance campaign for human/vet
--          
-- Revision History: copied f
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Mani				  02/23/2022 Initial release.
-- Testing code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_AS_CAMPAIGN_GETDetail]
		@LanguageID = N'en-US',
		@CampaignID = 716330001112

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AS_CAMPAIGN_GETDetail] (
	@LanguageID AS NVARCHAR(50),
	@CampaignID AS BIGINT
	)
AS
BEGIN
	DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
		@ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT tc.idfCampaign AS CampaignID,
			tc.idfsCampaignType AS CampaignTypeID,
			campaignType.name AS CampaignTypeName,
			tc.idfsCampaignStatus AS CampaignStatusTypeID,
			campaignStatus.name AS CampaignStatusTypeName,
			tc.LegacyCampaignID,
			--CD.idfsDiagnosis AS DiseaseID,
			--disease.name AS DiseaseName,
			--CD.idfsSampleType AS SampleTypeID,
			--sampleType.name AS SampleTypeName,
			--CD.idfsSpeciesType AS SpeciesTypeID,
			--speciesType.name AS speciesTypeName,
			tc.datCampaignDateStart AS CampaignStartDate,
			tc.datCampaignDateEND AS CampaignEndDate,
			tc.strCampaignID AS EIDSSCampaignID,
			tc.strCampaignName AS CampaignName,
			tc.strCampaignAdministrator AS CampaignAdministrator,
			tc.strConclusion AS Conclusion,
			tc.idfsSite SiteId
		FROM dbo.tlbCampaign tc
		--INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = tc.idfCampaign AND cd.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000115) campaignStatus ON tc.idfsCampaignStatus = campaignStatus.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType ON tc.idfsCampaignType = campaignType.idfsReference
		--LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease ON CD.idfsDiagnosis = disease.idfsReference	AND disease.intRowStatus = 0
		--LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType ON sampleType.idfsReference = CD.idfsSampleType
		--LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000086) speciesType ON speciesType.idfsReference = cd.idfsSpeciesType

		WHERE tc.idfCampaign = @CampaignID
		AND tc.intRowStatus = 0;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
