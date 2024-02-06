--=====================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_GETList
-- Description:	Returns a diagnosis/disease reference given an id and language
--							
-- Author:		Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		2020/03/31  Initial Release
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_GETDetail 9842300000000, 'en'
--=====================================================================================================

CREATE PROCEDURE [dbo].[USP_REF_DIAGNOSISREFERENCE_GETDetail] 
	@idfsDiagnosis BIGINT,
	@LangID	NVARCHAR(50)
AS
BEGIN
DECLARE
@returnMsg			NVARCHAR(MAX) = 'SUCCESS',
@returnCode			BIGINT = 0;

BEGIN TRY
SELECT
		d.[idfsDiagnosis],
		dbr.strDefault,
		dbr.[name] AS strName, 
		d.[strIDC10],
		d.[strOIECode], 
		dbo.FN_REF_SAMPLETYPETODISEASE_GET(@LangID, d.[idfsDiagnosis]) AS strSampleType,
		dbo.FN_REF_SAMPLETYPENAMETODISEASE_GET(@LangID, d.[idfsDiagnosis]) AS strSampleTypeNames,
		dbo.FN_REF_LABTESTTODISEASE_GET(@LangID, d.[idfsDiagnosis]) AS strLabTest,
		dbo.FN_REF_LABTESTNAMETODISEASE_GET(@LangID, d.[idfsDiagnosis]) AS strLabTestNames,
		dbo.FN_REF_PENSIDETESTTODISEASE_GET(@LangID, d.[idfsDiagnosis]) AS strPensideTest,
		dbo.FN_REF_PENSIDETESTNAMETODISEASE_GET(@LangID, d.[idfsDiagnosis]) AS strPensideTestNames,
		dbo.FN_GBL_HACode_ToCSV(@LangID, dbr.[intHACode]) AS [strHACode],
		dbo.FN_GBL_HACodeNames_ToCSV(@LangID, dbr.[intHACode]) AS [strHACodeNames],
		d.idfsUsingType,
		ut.[name] AS strUsingType,
		dbr.[intHACode],
		dbr.[intRowStatus],
		[blnZoonotic],
		d.blnSyndrome,
		dbr.intOrder
	FROM dbo.fnReferenceRepair(@LangID, 19000019) AS dbr	
	INNER JOIN trtDiagnosis d ON d.[idfsDiagnosis] = dbr.[idfsReference]
	LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000020) AS ut ON d.idfsUsingType = ut.idfsReference
	OUTER APPLY 
	( 
		SELECT TOP 1 
			d_to_dg.[idfsDiagnosisGroup], 
			dg.[name] AS [strDiagnosesGroupName]		
		FROM dbo.[trtDiagnosisToDiagnosisGroup] AS d_to_dg
		INNER JOIN dbo.fnReferenceRepair(@LangID, 19000156) AS dg
			ON d_to_dg.[idfsDiagnosisGroup] = dg.[idfsReference]		
		WHERE 
			d_to_dg.intRowStatus = 0
			AND d_to_dg.[idfsDiagnosis] = d.[idfsDiagnosis]		
		ORDER BY
			d_to_dg.idfDiagnosisToDiagnosisGroup ASC 
	) AS diagnosesGroup	
	WHERE (dbr.intHACode IS NULL  OR dbr.intHACode > 0)
		AND d.intRowStatus = 0 AND dbr.intRowStatus = 0	
		AND d.idfsDiagnosis = @idfsDiagnosis
	ORDER BY dbr.[intOrder], dbr.[name];  
END TRY
BEGIN CATCH
	THROW;
END CATCH

END
