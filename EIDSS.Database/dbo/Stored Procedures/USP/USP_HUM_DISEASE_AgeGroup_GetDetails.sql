
--*************************************************************
-- Name 				: USP_HUM_DISEASE_AgeGroup_GetDetails
-- Description			: set Human Disease Report Contacts by HDID
--          
-- Author               : JWJ
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------

-- Testing code:
-- EXEC USP_HUM_DISEASE_AgeGroup_GetDetails 9842300000000 
--*************************************************************
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_AgeGroup_GetDetails] 
(
	@idfsDiagnosis BIGINT
)
AS
BEGIN
	DECLARE @returnMsg				VARCHAR(MAX) = 'Success';
	DECLARE @returnCode				BIGINT = 0;

	BEGIN TRY  
		SELECT 
			DAGD.idfsDiagnosis,
			D.strDefault AS strDiagnosis,
			DAG.idfsDiagnosisAgeGroup,
			DAGR.strDefault AS strDiagnosisAgeGroup,
			DAG.idfsAgeType,
			ATR.strDefault AS strAgeType,
			DAG.intLowerBoundary, 
			DAG.intUpperBoundary

		FROM dbo.trtDiagnosisAgeGroupToDiagnosis DAGD 
		LEFT JOIN dbo.trtBaseReference D ON D.idfsBaseReference = DAGD.idfsDiagnosis 
		LEFT JOIN dbo.trtDiagnosisAgeGroup DAG ON DAGD.idfsDiagnosisAgeGroup = DAG.idfsDiagnosisAgeGroup AND DAGD.intRowStatus = 0
		LEFT JOIN dbo.trtBaseReference DAGR ON DAGR.idfsBaseReference = DAG.idfsDiagnosisAgeGroup 
		LEFT JOIN dbo.trtBaseReference ATR ON ATR.idfsBaseReference = DAG.idfsAgeType

		WHERE DAG.intRowStatus = 0
		AND DAGD.idfsDiagnosis = @idfsDiagnosis

		ORDER BY D.strDefault, DAG.intUpperBoundary, DAG.intLowerBoundary

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
	END TRY  

	BEGIN CATCH 
	THROW
	END CATCH;
END
