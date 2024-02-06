-- ======================================================================================================================================
-- NAME: USP_CONF_DISEASESAMPLETYPEMATRIX_SET
-- DESCRIPTION: Creates a Disease to sample type matrix
-- AUTHOR: Ricky Moss
-- 
-- REVISION HISTORY
--
-- Name:				Date			Description of Change
-- ----------------------------------------------------------
-- Ricky Moss			04/08/2019		Initial Release
--
-- EXEC USP_CONF_DISEASESAMPLETYPEMATRIX_SET NULL, 784170000000,781420000000
-- ======================================================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASESAMPLETYPEMATRIX_SET]
(
	@idfMaterialForDisease BIGINT,
	@idfsDiagnosis BIGINT,
	@idfsSampleType BIGINT
)
AS
	DECLARE @returnCode	   INT = 0  
	DECLARE	@returnMsg	   NVARCHAR(max) = 'SUCCESS' 	
	DECLARE @SupressSelect TABLE (retrunCode INT, returnMessage VARCHAR(200))
BEGIN
	BEGIN TRY
		IF (EXISTS(SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 0) AND @idfMaterialForDisease IS NULL) AND (EXISTS(SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 0 AND idfMaterialForDisease <> @idfMaterialForDisease) AND @idfMaterialForDisease IS NOT NULL)
		BEGIN
			SELECT @idfMaterialForDisease = (SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 0)
			SELECT @returnCode = 1
			SELECT @returnMsg = 'DOES EXIST'
		END
		ELSE IF (EXISTS(SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfMaterialForDisease = @idfMaterialForDisease AND intRowStatus = 0) AND @idfMaterialForDisease IS NOT NULL)
		BEGIN
			UPDATE trtMaterialForDisease SET idfsDiagnosis = @idfsDiagnosis, idfsSampleType = @idfsSampleType WHERE idfMaterialForDisease = @idfMaterialForDisease 
		END
		ELSE IF (EXISTS(SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 1) AND @idfMaterialForDisease IS NULL)
		BEGIN 
			UPDATE trtMaterialForDisease SET intRowStatus = 0 WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 1
			SELECT @idfMaterialForDisease = (SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 1)
		END
		ELSE
		BEGIN		
			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtMaterialForDisease', @idfMaterialForDisease OUTPUT

			INSERT INTO trtMaterialForDisease (idfMaterialForDisease, idfsDiagnosis, idfsSampleType, intRowStatus) VALUES (@idfMaterialForDisease, @idfsDiagnosis, @idfsSampleType, 0)
			INSERT INTO trtMaterialForDiseaseToCP(idfMaterialForDisease, idfCustomizationPackage) VALUES (@idfMaterialForDisease, dbo.FN_GBL_CustomizationPackage_GET())
		END
		SELECT @returnCode 'returnCode', @returnMsg 'returnMessage', @idfMaterialForDisease 'idfMaterialForDisease'
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
