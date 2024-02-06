
-- ================================================================================================
-- Name: FN_GBL_Campaign_Disease_Names_GET
--
-- Description: Returns the delimited list of disease names for a surveillance Campaign.
--          
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Mark Wilson       02/22/2022 Initial release

--
-- Test Code
/*

SELECT dbo.FN_GBL_Campaign_Disease_Names_GET(716330001112, 'ka-GE')
SELECT dbo.FN_GBL_Campaign_Disease_Names_GET(3106870001112, 'en-US')
SELECT dbo.FN_GBL_Campaign_Disease_Names_GET(154582820001294, 'en-US')

*/
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_Campaign_Disease_Names_GET] 
(
	@CampaignID AS BIGINT, 
	@LanguageID NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @names NVARCHAR(MAX);

    SELECT @names = ISNULL(@names + ';', '') + CAST(C2D.name AS NVARCHAR(200))
    FROM
    (
        SELECT DISTINCT
            CD.idfsDiagnosis,
            D.name

        FROM dbo.tlbCampaignToDiagnosis CD
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) D ON  D.idfsReference = CD.idfsDiagnosis
        WHERE CD.idfCampaign = @CampaignID
        UNION
        SELECT 
		DISTINCT CD.idfsDiagnosis,
        diseaseName.name
        FROM dbo.tlbCampaign C
        INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign
						INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName ON 
				diseaseName.idfsReference = CD.idfsDiagnosis
        WHERE C.idfCampaign = @CampaignID
    ) AS C2D

    RETURN @names;
END
