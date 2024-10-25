

-- ================================================================================================
-- Name: report.USP_Rep_Lim_TestResults_GET
--
-- Description: Select data for t results report
--						
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mark Wilson    12/13/2021  Initial version, Converted to E7 standards.
--
-- Testing code:

/*
--Example of a call of procedure:

exec report.USP_Rep_Lim_TestResults_GET @LangID=N'en-US',@ObjID=36330000134
exec report.USP_Rep_Lim_TestResults_GET @LangID=N'en-US',@ObjID=1051230000817


*/

CREATE PROCEDURE [Report].[USP_Rep_Lim_TestResults_GET]
(
	@LangID AS NVARCHAR(10),
    @ObjID	AS BIGINT
)
AS

SELECT  
	btc.strBarcode AS strBatchBarcode,
	m.strFieldBarcode AS strLocalFieldSampleID,
	Category.name AS strCategory,
	TestType.name AS strTestType,
	StatusType.name AS strStatus,
	TestResult.name AS strResult,
	m.strBarcode AS strSampleID,
	ISNULL(t.datStartedDate, btc.datPerformedDate) AS datTestStartedDate,
 	t.datConcludedDate AS datResultDate,
 	SpecimenType.name AS strSampleType,
 	dbo.FN_GBL_ConcatFullName(p_TestedBy.strFamilyName, p_TestedBy.strSecondName, p_TestedBy.strFirstName) AS strTestedBy,
 	dbo.FN_GBL_ConcatFullName(p_ResEntBy.strFamilyName, p_ResEntBy.strSecondName, p_ResEntBy.strFirstName) AS strResultEnteredBy,
 	Diagnosis.name AS strDiagnosisName,
 	ISNULL(p_ValBy.strFamilyName,'') + ' ' + ISNULL(p_ValBy.strSecondName,'') + ' ' + ISNULL(p_ValBy.strFirstName,'') AS strValidatedBy,
	Laboratory.name								AS strLaboratory,
	t.strNote AS strComment

FROM dbo.tlbTesting AS t
	
INNER JOIN dbo.tlbMaterial AS m	ON m.idfMaterial = t.idfMaterial AND m.intRowStatus = 0
LEFT JOIN dbo.tlbHumanCase HC ON HC.idfHumanCase = m.idfHumanCase AND HC.intRowStatus = 0
LEFT JOIN dbo.tlbBatchTest btc ON t.idfBatchTest = btc.idfBatchTest
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000095 ) Category ON Category.idfsReference = t.idfsTestCategory
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000096 ) TestResult ON TestResult.idfsReference = t.idfsTestResult
INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000097 ) TestType ON TestType.idfsReference = t.idfsTestName
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000001 ) StatusType ON StatusType.idfsReference = t.idfsTestStatus
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) SpecimenType ON SpecimenType.idfsReference = m.idfsSampleType
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019 ) Diagnosis ON Diagnosis.idfsReference = t.idfsDiagnosis
LEFT JOIN dbo.tlbPerson p_ResEntBy ON ISNULL(t.idfResultEnteredByPerson, btc.idfPerformedByPerson) = p_ResEntBy.idfPerson					
LEFT JOIN dbo.tlbPerson p_TestedBy ON ISNULL(t.idfTestedByPerson, btc.idfPerformedByPerson) = p_TestedBy.idfPerson	
LEFT JOIN dbo.tlbPerson p_ValBy ON ISNULL(t.idfValidatedByPerson, btc.idfValidatedByPerson) = p_ValBy.idfPerson		
LEFT JOIN dbo.tlbOffice lab_off ON ISNULL(t.idfPerformedByOffice, btc.idfPerformedByOffice) = lab_off.idfOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000045) Laboratory ON Laboratory.idfsReference = lab_off.idfsOfficeAbbreviation		
				
WHERE t.idfTesting = @ObjID
AND	t.intRowStatus = 0		

