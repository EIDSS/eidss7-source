




--=============================================================================================================================================+++++++++++
-- NAME: USP_GBL_LKUP_REFERENCETYPE_GETLIST
-- DESCRIPTION: Returns a list of base reference types by Ids acan pass in Multiple
-- AUTHOR: Lamont Mitchell
--
-- HISTORY OF CHANGE:
-- Name				Date				Change Description
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- Lamont Mitchell		08/17/2020		Gets Diagnosis Specific Base References
-- Mark Wilson		    01/30/2021		Updated to use FN_GBL_DiagnosisRepair
--=============================================================================================================================================+++++++++++
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_DIAGNOSIS_REFERENCETYPE_BY_IDS_GETLIST_Paged]
(
	@referenceTypeIds NVARCHAR(MAX) = 19000019,
	@languageId NVARCHAR(50),
	@ExcludedTypes NVARCHAR(MAX) = NULL,
	@intHACode INT = NULL,
	@PaginationSet INT = 1,
	@PageSize INT = 10,
	@MaxPagesPerFetch INT = 10 ,
	@Term NVARCHAR(MAX) = NULL
)
AS
BEGIN
	BEGIN TRY

		DECLARE @TotalRecords INT
		DECLARE @SearchString NVARCHAR(MAX) = @Term + '%'

		DECLARE @idfsUsingType BIGINT
		SET @idfsUsingType = CASE WHEN @ExcludedTypes = '10020002' THEN 10020001
								  WHEN @ExcludedTypes = '10020001' THEN 10020002
								  ELSE NULL END
	
		DECLARE @ReferenceType BIGINT = CAST (@referenceTypeIds AS BIGINT)
	
	
		SELECT 
			@TotalRecords = 	COUNT(*) 

		FROM dbo.FN_GBL_DiagnosisRepair(@languageId, 2, @idfsUsingType)
		WHERE intRowStatus = 0

		SELECT 
			d.idfsDiagnosis AS idfsBaseReference, 
			@ReferenceType AS idfsReferenceType, 
			d.[name] AS strDefault,
			NULL AS strName,
			d.intHACode, 
			d.intOrder,
			@TotalRecords AS 'TotalRecords' 
		FROM  dbo.FN_GBL_DiagnosisRepair(@languageId, 2, @idfsUsingType) d 
		INNER JOIN dbo.trtBaseReference dr ON dr.idfsBaseReference = d.idfsDiagnosis AND dr.intRowStatus = 0
		WHERE d.intRowStatus = 0
		AND (dr.strDefault LIKE  +''+ @Term + '%' OR (@Term IS NULL))
		ORDER BY 
			d.[name] ASC OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS

		FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
