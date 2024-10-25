

-- ================================================================================================
-- Name: USP_CONF_LKUP_DISEASE_GENDER_MATRIX

-- Description:	Gets a list of gender types for a disease ID.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/07/2019 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_LKUP_DISEASE_GENDER_MATRIX]
(
	@LanguageID NVARCHAR(50) = NULL, 
	@DiseaseID BIGINT
)
AS
BEGIN
	BEGIN TRY

		DECLARE @DiseaseGroupID AS BIGINT;
		SELECT  @DiseaseGroupID = idfsDiagnosisGroup FROM dbo.trtDiagnosisToDiagnosisGroup WHERE idfsDiagnosis = @DiseaseID;
		
		SELECT d.GenderID
		FROM dbo.DiagnosisGroupToGender d
		WHERE d.DisgnosisGroupID =ISNULL(@DiseaseGroupID , @DiseaseID)
			AND d.intRowStatus = 0;
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
