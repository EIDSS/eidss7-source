

-- ================================================================================================
-- Name: USP_HAS_CAMPAIGN_GETDetail
--
-- Description: Gets data for active surveillance campaign for the human module.
--          
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       07/06/2019 Initial release.
-- Mark Wilson		  08/10/2021 added join to tlbCampaignToDiagnosis
-- Mark Wilson		  08/11/2021 removed tlbCampaignToDiagnosis and added filter on 10501001 -- Human Active Surveillance Campaign
-- Mark Wilson		  08/26/2021 changed to filter on CampaignCategoryType -- Human Active Surveillance Campaign
-- Lamaont Mitchell	  09/01/2021 Removed Return Code And Message causing 2 result sets.  POCO doesnt properly return two result sets.  Retained Throw.
-- Testing code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_HAS_CAMPAIGN_GETDetail]
		@LanguageID = N'en-US',
		@CampaignID = 716330001112

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_CAMPAIGN_GETDetail] (
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
			CD.idfsDiagnosis AS DiseaseID,
			disease.name AS DiseaseName,
			CD.idfsSampleType AS SampleTypeID,
			sampleType.name AS SampleTypeName,
			tc.datCampaignDateStart AS CampaignStartDate,
			tc.datCampaignDateEND AS CampaignEndDate,
			tc.strCampaignID AS EIDSSCampaignID,
			tc.strCampaignName AS CampaignName,
			tc.strCampaignAdministrator AS CampaignAdministrator,
			tc.strConclusion AS Conclusion,
			tc.idfsSite SiteId
		FROM dbo.tlbCampaign tc
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = tc.idfCampaign AND cd.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000115) campaignStatus ON tc.idfsCampaignStatus = campaignStatus.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType ON tc.idfsCampaignType = campaignType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease ON CD.idfsDiagnosis = disease.idfsReference	AND disease.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType ON sampleType.idfsReference = CD.idfsSampleType
		WHERE tc.idfCampaign = @CampaignID
		AND tc.CampaignCategoryID = 10501001 -- Human Active Surveillance Campaign
		AND tc.intRowStatus = 0;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
