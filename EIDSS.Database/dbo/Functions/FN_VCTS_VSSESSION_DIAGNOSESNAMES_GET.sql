
-- ================================================================================================
-- Name: FN_VCTS_VSSESSION_DIAGNOSESNAMES_GET
--
-- Description: Gets a comma delimited list of diagnosis names for a vector surveillance session
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/01/2022 Original
-- Mike Kornegay	05/26/2022 Added null reference checks to every query
-- Mike Kornegay	10/06/2022 Added where clauses to include only active records.
--
-- ================================================================================================

CREATE FUNCTION [dbo].[FN_VCTS_VSSESSION_DIAGNOSESNAMES_GET]
(
	@idfVectorSurveillanceSession AS BIGINT--##PARAM @idfVectorSurveillanceSession - AS session ID
	,@LangID AS NVARCHAR(50)--##PARAM @LangID - language ID
)
RETURNS NVARCHAR(1000)
AS
BEGIN
	DECLARE @strDiagnoses NVARCHAR(1000)
	DECLARE @idfsDiagnosises TABLE (idfsDiagnosis BIGINT NOT NULL PRIMARY KEY);
	IF @idfVectorSurveillanceSession IS NOT NULL OR @idfVectorSurveillanceSession <> ''
	BEGIN
		INSERT INTO @idfsDiagnosises
			SELECT 
				DISTINCT	Test.idfsDiagnosis
				FROM		dbo.tlbPensideTest Test
				INNER JOIN	dbo.tlbMaterial Material ON
							Material.idfMaterial = Test.idfMaterial
				AND			Material.intRowStatus = 0
				INNER JOIN	trtPensideTestTypeToTestResult tr ON
							Test.idfsPensideTestName = tr.idfsPensideTestName
				AND			Test.idfsPensideTestResult = tr.idfsPensideTestResult
				AND			tr.intRowStatus = 0
				AND			tr.blnIndicative = 1
				WHERE		test.intRowStatus = 0 
				AND Material.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND Test.idfsDiagnosis is not null

			UNION

				SELECT 
				DISTINCT	Test.idfsDiagnosis
				FROM		dbo.tlbTesting Test
				INNER JOIN	dbo.tlbMaterial Material ON
							Material.idfMaterial = Test.idfMaterial AND material.intRowStatus = 0
				WHERE		Test.intRowStatus = 0 
				AND Material.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND Test.idfsDiagnosis is not null
				
			UNION

				SELECT 
				DISTINCT	Material.DiseaseID
				FROM		dbo.tlbMaterial Material
				WHERE		Material.intRowStatus = 0 
				AND Material.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND Material.DiseaseID is not null

			UNION

				SELECT 
				DISTINCT	Vssd.[idfsDiagnosis] 
				FROM		dbo.tlbVectorSurveillanceSessionSummary Vss
				INNER JOIN	dbo.tlbVectorSurveillanceSessionSummaryDiagnosis Vssd ON
							Vss.[idfsVSSessionSummary] = Vssd.[idfsVSSessionSummary] AND Vssd.intRowStatus = 0
				WHERE		vss.intRowStatus = 0
				AND Vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND Vssd.idfsDiagnosis is not null
			
		SELECT @strDiagnoses = ISNULL(@strDiagnoses + '; ','') + ref_Diagnosis.[name]
		FROM @idfsDiagnosises VectorSession
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) ref_Diagnosis	ON 
				ref_Diagnosis.idfsReference = VectorSession.idfsDiagnosis
	END

	RETURN @strDiagnoses
END
