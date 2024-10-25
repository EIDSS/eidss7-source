--*************************************************************
-- Name 				: USP_VCTS_FIELDTEST_GetList
-- Description			: Selects list of field tests related with specific Vector
-- Author               : Harold Pryor
-- Revision History
-- Name				Date		Change Detail
-- Harold Pryor		5/5/2018	Modified to retreive data from tlbTesting table
-- Harold Pryor		5/17/2018	Updated joins to FN_GBL_Reference_List_GET to get proper Vector data
-- Harold Pryor		5/18/2018	Updated to return strFieldBarcode from tlbMaterial table
-- Harold Pryor		5/24/2018	Modified to retrieve TestedByPerson
-- Doug Albanese	1/4/2021	Added parameter to denote Field Tests
-- Doug Albanese	01/29/2021	Changed to return non lab tests
-- Mike Kornegay	05/06/2022	Changed returned column names to match common field test model
-- Mike Kornegay	05/19/2022	Added TotalRowCount for populating grids
-- Mike Kornegay	07/22/2022	Added collection date
-- Doug Albanese	 10/272022	 Added blnNonLaboratoryTest to remove any lab created tests
-- Testing code:
--USP_VCTS_FIELDTEST_GetList @idfVector,'en'
--*************************************************************
CREATE  PROCEDURE [dbo].[USP_VCTS_FIELDTEST_GetList]
(
	@idfVector	BIGINT , --##PARAM
	@LangID		AS NVARCHAR(50) --##PARAM @LangID - language ID
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success'
	DECLARE @returnCode BIGINT = 0

	BEGIN TRY  	
			SELECT		Test.idfTesting AS TestID,
			            M.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
						m.idfMaterial AS SampleID,
						m.idfsSampleType AS SampleTypeID,
						SampleType.name AS SampleTypeName,
						Test.idfsTestName AS TestNameTypeID,
						TestType.name AS TestNameTypeName,	
						Test.idfsTestCategory AS TestCategoryTypeID, 
						TestCategory.name AS TestCategoryTypeName,
						Test.idfTestedByOffice AS TestedByOrganizationID,
						Office.[Name] AS TestedByOrganizationName,
						Test.idfsTestResult AS TestResultTypeID,  
						TestResult.name AS TestResultTypeName,   
						Test.idfTestedByPerson AS TestedByPersonID, 
						ISNULL(TestedByPerson.strFamilyName, N'') + ISNULL(' ' + TestedByPerson.strFirstName, '') + ISNULL(' ' +TestedByPerson.strSecondName, '') AS TestedByPersonName,
						Test.idfsDiagnosis AS DiseaseID,
						Diagnosis.name AS DiseaseName,
						'' AS RecordAction,
						Test.datConcludedDate AS ConcludedDate,
						Test.datReceivedDate AS ReceivedDate,
						M.datFieldCollectionDate AS CollectionDate,
						Test.idfVector AS VectorID,
						Test.intRowStatus AS RowStatus,
						Test.blnNonLaboratoryTest AS NonLaboratoryTestIndicator,
						Test.blnExternalTest AS ExternalTestIndicator,
						TotalRowCount = COUNT(*) OVER(PARTITION BY 1)
		FROM			[dbo].[tlbTesting] Test
		LEFT JOIN		[dbo].[tlbMaterial] M on M.idfMaterial = Test.IdfMaterial 
		LEFT JOIN		dbo.FN_GBL_Reference_List_GET(@LangID,19000105) TestResult ON TestResult.idfsReference = Test.idfsTestResult     
		LEFT  JOIN		dbo.FN_GBL_Reference_List_GET(@LangID,19000104)  TestType ON TestType.idfsReference = Test.idfsTestName --Vector Type Test
		LEFT JOIN		dbo.FN_GBL_Reference_List_GET(@LangID,19000019) Diagnosis ON Diagnosis.idfsReference = Test.idfsDiagnosis 
		LEFT JOIN		dbo.FN_GBL_Reference_List_GET(@LangID,19000095) TestCategory ON TestCategory.idfsReference = Test.idfsTestCategory
		LEFT  JOIN		dbo.FN_GBL_Reference_List_GET(@LangID,19000087) SampleType ON m.idfsSampleType = SampleType.idfsReference
		LEFT JOIN	    FN_PERSON_SELECTLIST(@LangID) TestedByPerson ON TestedByPerson.idfEmployee = Test.idfTestedByPerson
		LEFT JOIN		dbo.FN_GBL_INSTITUTION(@LangID) Office ON Office.idfOffice = Test.idfTestedByOffice and Office.intRowStatus = 0
		LEFT JOIN		dbo.FN_GBL_Reference_List_GET(@LangID,19000045) CollectedByOffice	ON CollectedByOffice.idfsReference = Office.idfsOfficeName	

		WHERE Test.intRowStatus = 0
		--and M.idfVector = @idfVector
		and Test.idfVector = @idfVector
		--and M.idfMaterial is not null 
		--and M.intRowStatus = 0
		and Test.blnNonLaboratoryTest = 1
		
	END TRY  

	BEGIN CATCH 
	Throw;
	END CATCH
END
