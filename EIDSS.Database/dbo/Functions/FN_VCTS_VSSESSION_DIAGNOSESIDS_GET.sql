-- ================================================================================================
-- Name: FN_VCTS_VSSESSION_DIAGNOSESIDS_GET
--
-- Description: Gets a comma delimited list of disease ids for a vector surveillance session.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/01/2022 Original
-- Mike Kornegay	05/26/2022 Added null reference checks to every query
-- Mike Kornegay	06/10/2022 Moved the semicolon separator to the end of the string
-- Stephen Long     09/29/2022 Fix to split out the diseases with a semi-colon in between.
-- Mike Kornegay	10/06/2022 Added where clauses to include only active records.
--
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_VCTS_VSSESSION_DIAGNOSESIDS_GET]
(
	@idfVectorSurveillanceSession	AS BIGINT,
	@LangID							AS NVARCHAR(50)
)
RETURNS								NVARCHAR(1000)
AS
BEGIN
	DECLARE @strDiagnosesIDs		NVARCHAR(1000);
	
	IF @idfVectorSurveillanceSession IS NOT NULL OR @idfVectorSurveillanceSession <> ''
	BEGIN
		SELECT @strDiagnosesIDs = ISNULL(@strDiagnosesIDs + ';','') + CONVERT(NVARCHAR(1000), vs.idfsDiagnosis)
		FROM (
				SELECT DISTINCT			t.idfsDiagnosis
				FROM					dbo.tlbPensideTest t
				INNER JOIN				dbo.tlbMaterial m 
				ON						m.idfMaterial = t.idfMaterial
				AND						t.intRowStatus = 0
				INNER JOIN				dbo.trtPensideTestTypeToTestResult tr 
				ON						t.idfsPensideTestName = tr.idfsPensideTestName
				AND						t.idfsPensideTestResult = tr.idfsPensideTestResult
				AND						t.intRowStatus = 0
				AND						tr.intRowStatus = 0
				AND						tr.blnIndicative = 1
				WHERE					m.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND						t.idfsDiagnosis is not null

			UNION

				SELECT DISTINCT			t.idfsDiagnosis
				FROM					dbo.tlbTesting t
				INNER JOIN				dbo.tlbMaterial m 
				ON						m.idfMaterial = t.idfMaterial
				WHERE					m.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND						t.idfsDiagnosis is not null
				AND						t.intRowStatus = 0

			UNION

				SELECT DISTINCT			m.DiseaseID
				FROM					dbo.tlbMaterial m
				WHERE					m.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND						m.DiseaseID is not null
				AND						m.intRowStatus = 0

			UNION

				SELECT DISTINCT			vssd.idfsDiagnosis
				FROM					dbo.tlbVectorSurveillanceSessionSummary vss
				INNER JOIN				dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd 
				ON						vss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
				WHERE					vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
				AND						vssd.idfsDiagnosis is not null
				AND						vssd.intRowStatus = 0

		  ) AS vs;
	END
	RETURN @strDiagnosesIDs;
END
