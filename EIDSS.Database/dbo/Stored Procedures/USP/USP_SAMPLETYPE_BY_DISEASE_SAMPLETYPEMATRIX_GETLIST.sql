
-- ===========================================================================================================================================
-- NAME: USP_SAMPLETYPE_BY_DISEASE_SAMPLETYPEMATRIX_GETLIST
-- DESCRIPTION: Returns a list of disease to sample type by Disease
-- AUTHOR: Lamont Mitchell Modified from SP used in Diseas Sample Type Matrix by Ricky Moss
--
-- REVISION HISTORY
--
-- Name:				Date			Description of Change
-- ----------------------------------------------------------
-- Lamont Mitchell			12/14/2020		Initial Release
--/
-- EXEC USP_CONF_DISEASESAMPLETYPEMATRIX_GETLIST 'en'
-- ===========================================================================================================================================
CREATE PROCEDURE [dbo].[USP_SAMPLETYPE_BY_DISEASE_SAMPLETYPEMATRIX_GETLIST]
(
	@langId NVARCHAR(50),
	@idfsDiagnosis BIGINT =NULL
)
AS
BEGIN
	BEGIN TRY
		SELECT 
			idfMaterialForDisease, 
			idfsDiagnosis, 
			dbr.name AS strDisease, 
			idfsSampleType, 
			stbr.name AS strSampleType 
		FROM trtMaterialForDisease md
		JOIN dbo.FN_GBL_ReferenceRepair(@langId, 19000019) dbr ON md.idfsDiagnosis = dbr.idfsReference
		JOIN dbo.FN_GBL_ReferenceRepair(@langId, 19000087) stbr ON md.idfsSampleType = stbr.idfsReference
		WHERE md.intRowStatus = 0
		AND (idfsDiagnosis = @idfsDiagnosis) OR (@idfsDiagnosis IS NULL) OR (@idfsDiagnosis = 0)


	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
