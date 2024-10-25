-- ================================================================================================
-- Name: FN_VAS_SESSION_SAMPLE_DIAGNOSESNAMES_GET
--
-- Description: Gets a comma delimited list of diagnosis names for a veterinary surveillance session and sample id.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay	10/14/2022 Original 
--
-- ================================================================================================

CREATE FUNCTION [dbo].[FN_VAS_SESSION_SAMPLE_DIAGNOSESNAMES_GET]
(
	@MonitoringSessionID AS BIGINT,
	@LangID AS NVARCHAR(50),
	@SampleID AS BIGINT
)
RETURNS NVARCHAR(1000)
AS
BEGIN
	DECLARE @strDiagnoses NVARCHAR(1000)
	DECLARE @idfsDiagnosises TABLE (idfsDiagnosis BIGINT NOT NULL PRIMARY KEY);
	IF @MonitoringSessionID IS NOT NULL OR @MonitoringSessionID <> ''
	BEGIN
		INSERT INTO @idfsDiagnosises
			SELECT DISTINCT
				msm.idfsDisease AS DiseaseID
			FROM dbo.tlbMonitoringSessionToMaterial msm
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS disease
				ON disease.idfsReference = msm.idfsDisease
			WHERE msm.intRowStatus = 0
				AND msm.idfMonitoringSession IS NOT NULL 
				AND msm.idfMonitoringSession = @MonitoringSessionID
				AND msm.idfMaterial = @SampleID;
			
		SELECT @strDiagnoses = ISNULL(@strDiagnoses + '; ','') + ref_Diagnosis.[name]
		FROM @idfsDiagnosises SessionSampleDiseases
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) ref_Diagnosis	ON 
				ref_Diagnosis.idfsReference = SessionSampleDiseases.idfsDiagnosis
	END

	RETURN @strDiagnoses
END
