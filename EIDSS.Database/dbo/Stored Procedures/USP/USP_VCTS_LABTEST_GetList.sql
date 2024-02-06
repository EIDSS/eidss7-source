--*************************************************************
-- Name 				: USP_VCTS_LABTEST_GetList
-- Description			: Get Vector Lab Tests List
--          
-- Author               : Harold Pryor
-- Revision History
--		Name       Date			Change Detail
--  Harold Pryor  08/20/2018	Creation
--	Mike Kornegay 05/08/2022	Added TotalRowCount and EIDSSLaboratorySampleID and removed selects for return code
-- Doug Albanese  10/27/2022	 Refactored to eliminate the extra content that is not needed, and to fix the problem where the joins eliminate the records we are seeking
-- Testing code:
/*
--Example of a call of procedure:
declare	@idfVector	bigint = 51
declare @idfVectorSurveillanceSession BIGINT = null
Declare @LangID AS VARCHAR(10) = 'en'

--select @idfVector = MAX(idfVector) from dbo.tlbVector

execute	USP_VCTS_LABTEST_GetList @idfVector, @idfVectorSurveillanceSession, @LangID
*/
--*************************************************************
CREATE PROCEDURE[dbo].[USP_VCTS_LABTEST_GetList]
(		
	@idfVector BIGINT,--##PARAM @idfVector - AS vector ID
	@idfVectorSurveillanceSession BIGINT,--##PARAM @idfVectorSurveillanceSession - AS session ID
	@LangID AS nvarchar(10)--##PARAM @LangID - language ID
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success'
	DECLARE @returnCode BIGINT = 0

	BEGIN TRY  	

	  SELECT
		 t.idfTesting,
		 m.strBarcode	  AS EIDSSLaboratorySampleID,
		 m.strFieldBarcode as strFieldSampleID,
		 sampleType.name AS strSampleTypeName,
		 SpeciesName.name AS strSpeciesName,
		 testName.name AS strTestName,
		 testResult.name AS strTestResultName,
		 t.datConcludedDate,
		 disease.name AS strDiseaseName,
		 TotalRowCount = COUNT(*) OVER(PARTITION BY 1)
	  FROM
		 tlbTesting T
	  INNER JOIN tlbMaterial M
	  ON M.idfMaterial = T.idfMaterial AND M.intRowStatus = 0
	  LEFT JOIN FN_GBL_ReferenceRepair(@LangID, 19000087) AS sampleType
	  ON sampleType.idfsReference = m.idfsSampleType
	  LEFT JOIN FN_GBL_REFERENCEREPAIR(@LangID,19000086) SpeciesName 
	  ON SpeciesName.idfsReference=m.idfSpecies
	  LEFT JOIN FN_GBL_ReferenceRepair(@LangID, 19000097) AS testName
	  ON testName.idfsReference = t.idfsTestName 
	  LEFT JOIN FN_GBL_ReferenceRepair(@LangID, 19000096) AS testResult
	  ON testResult.idfsReference = t.idfsTestResult
	  LEFT JOIN FN_GBL_ReferenceRepair(@LangID, 19000019) AS disease
	  ON disease.idfsReference = m.DiseaseID
	  --WHERE
		 --T.idfVector = @idfVector AND
		 --T.blnNonLaboratoryTest = 0 AND
		 --T.intRowStatus = 0
	  WHERE
		 M.idfVector = @idfVector
		AND ((M.idfVectorSurveillanceSession = @idfVectorSurveillanceSession) OR (@idfVectorSurveillanceSession IS NULL)) 
		AND T.intRowStatus = 0
		AND M.intRowStatus = 0
		AND (M.idfVectorSurveillanceSession IS NOT NULL AND T.blnNonLaboratoryTest = 0) 

	END TRY  

	BEGIN CATCH 
		THROW;
	END CATCH; 
		
END
