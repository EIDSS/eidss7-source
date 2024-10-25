
-- ================================================================================================
-- Name: FN_GBL_Campaign_DiseaseIDS_GET
--
-- Description: Returns the delimited list of disease identifiers for a surveillance Campaign.
--          
-- Author: Mark Wilson
--
-- Revision History:
--		Name          Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Mark Wilson        02/22/2022 Initial release

--
-- Test Code
/*

SELECT dbo.FN_GBL_Campaign_DISEASEIDS_GET(716330001112)
SELECT dbo.FN_GBL_Campaign_DISEASEIDS_GET(3106870001112)

*/
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_Campaign_DISEASEIDS_GET]
(
	@idfCampaign AS BIGINT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @identifiers VARCHAR(MAX);

    SELECT @identifiers = ISNULL(@identifiers + ',', '') + CAST(C2D.idfsDiagnosis AS VARCHAR(50))
    FROM
    (
        SELECT DISTINCT
            msd.idfsDiagnosis
        FROM dbo.tlbCampaignToDiagnosis msd
        WHERE msd.idfCampaign = @idfCampaign
        UNION
        SELECT DISTINCT
            CD.idfsDiagnosis
        FROM dbo.tlbCampaign C
        INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign
        WHERE C.idfCampaign = @idfCampaign
    ) AS C2D
    ORDER BY C2D.idfsDiagnosis;

    RETURN @identifiers;
END
