

--=================================================================================================
-- Author:					Joan Li
--
-- Description:				06/20/2017: Created based on V6 spDiagnosis_SelectLookup :  V7 USP68
--							Get lookup data from tables: trtDiagnosis;trtDiagnosisToDiagnosisGroup.
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Joan Li			06/20/2017	Initial release.
-- Stephen Long     05/22/2018	Renamed and re-factored to standard.
-- Stephen Long     12/26/2019	Replaced 'en' with @LangID on reference call.
-- Doug Albanese	11/25/2020	Added a parameter to pull zoonotic diseases only
--
-- Test Code:
-- exec USP_REP_DIAGNOSIS_GetList 'en', 32, 10020001 -- 'dutStandardCase' (10020001, 10020002)
-- Related Fact Data From:
-- select distinct idfsusingtype  from trtDiagnosis  
-- select * from trtDiagnosisToDiagnosisGroup
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REP_DIAGNOSIS_GetList] (
	@LangID					NVARCHAR(50),
	@HACode					INT = NULL, --Bit mask that defines area where diagnosis are used (human, livestock or avian)
	@DiagnosisUsingType		BIGINT = NULL, --standard or aggregate
	@showZoonoticOnly		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;

	BEGIN TRY
		SELECT dbo.trtDiagnosis.idfsDiagnosis,
			d.name,
			trtDiagnosis.strIDC10,
			trtDiagnosis.strOIECode,
			d.intHACode,
			d.intRowStatus,
			blnZoonotic,
			CASE 
				WHEN blnZoonotic = 1
					THEN stYes.name
				ELSE stNo.name
				END AS strZoonotic,
			diagnosesGroup.idfsDiagnosisGroup,
			diagnosesGroup.strDiagnosesGroupName
		FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) d
		INNER JOIN dbo.trtDiagnosis
			ON dbo.trtDiagnosis.idfsDiagnosis = d.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) stYes
			ON stYes.idfsReference = 10100001
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) stNo
			ON stNo.idfsReference = 10100002
		OUTER APPLY (
			SELECT TOP 1 d_to_dg.idfsDiagnosisGroup,
				dg.[name] AS strDiagnosesGroupName
			FROM dbo.trtDiagnosisToDiagnosisGroup d_to_dg
			INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000156) dg
				ON dg.idfsReference = d_to_dg.idfsDiagnosisGroup
			WHERE d_to_dg.intRowStatus = 0
				AND d_to_dg.idfsDiagnosis = trtDiagnosis.idfsDiagnosis
			ORDER BY d_to_dg.idfDiagnosisToDiagnosisGroup ASC
			) AS diagnosesGroup
		WHERE (
				@HACode = 0
				OR @HACode IS NULL
				OR d.intHACode IS NULL
				OR (d.intHACode & @HACode) > 0
				)
			AND (
				@DiagnosisUsingType IS NULL
				OR trtDiagnosis.idfsDiagnosis IS NULL
				OR trtDiagnosis.idfsUsingType = @DiagnosisUsingType
				)
			AND
				(
					(@showZoonoticOnly = 0 and blnZoonotic in (0,1))
					OR
					(@showZoonoticOnly = 1 and blnZoonotic = 1 and trtDiagnosis.intRowStatus = 0)
				)
		ORDER BY d.intOrder,
			d.name;

		SELECT @returnCode,
			@returnMsg;
	END TRY

	BEGIN CATCH
		BEGIN
			SET @returnCode = ERROR_NUMBER();
			SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode,
				@returnMsg;
		END
	END CATCH;
END

