


-- ================================================================================================
-- Name: USP_HAS_DISEASE_AGE_GROUP_GETList

-- Description:	Gets a list of age ranges for a disease ID.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_DISEASE_AGE_GROUP_GETList]
(
	@LanguageID NVARCHAR(50) = NULL, 
	@DiseaseID BIGINT
)
AS
BEGIN
	BEGIN TRY
		SELECT 
			dag.intLowerBoundary AS LowerAge,
			dag.intUpperBoundary AS UpperAge
		FROM dbo.trtDiagnosisAgeGroupToDiagnosis d
		INNER Join dbo.trtDiagnosisAgeGroup AS dag 
			ON dag.idfsDiagnosisAgeGroup = d.idfsDiagnosisAgeGroup 
				AND dag.intRowStatus = 0
		WHERE d.idfsDiagnosis = @DiseaseID 
			AND d.intRowStatus = 0;
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
