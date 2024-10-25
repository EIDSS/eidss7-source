-- ================================================================================================
-- Name: USP_HUM_TESTS_GetList
--
-- Description: List human disease report tests by human disease report identifier.
--          
-- Author: JWJ
--
-- Revision History:
-- Name	            Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- JWJ				20180603   created 
-- HAP				2018110    Added strTestResult field to result set 
-- HAP              20181109   Added TestValidation fields to result set 
-- LJM				20201230   Added strTestedByPerson and strTestedByOffice as output 
--                             parameters
-- LJM				20210105   Added strTestCategory and blnNonLaboratoryTest, 
--                             idfInterpretedByPerson,idfValidatedByPerson as output parameters.
-- Leo Tracchia		10/21/2022 Fix for properly deleting tests for human disease report DevOps 
--                             defect 5006
-- Stephen Long     01/04/2023 Added check for deleted test status.  Fixed main table to be
--                             tlbTesting and not the material table.  Changed to join.
-- Doug Albanese    01/06/2023 Removed the coalescing of null values on Interpreted and Validated 
--                             dates. They have to be done on the application side.
-- Stephen Long     01/09/2023 Fix to show the validated by person from tlbTesting when the test 
--                             record was created and updated from the laboratory module.
-- Stephen Long     01/16/2023 Fix to look at test status types when a laboratory assigned test 
--                             to determine if validated or not (final and amended status types).
-- Stephen Long     02/06/2023 Fix for bug 5620; removed unneeded joins and fields.
-- Mike Kornegay	03/17/2023 Added left join on test result types 19000096 and 19000162 (basic syndromic surveillance)
--
-- Testing code:
-- EXEC USP_HUM_TESTS_GetList 'en', @idfHumanCase=19  --10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_TESTS_GetList]
    @LangID NVARCHAR(50),
    @idfHumanCase BIGINT = NULL,
    @SearchDiagnosis BIGINT = NULL
AS
BEGIN
    BEGIN TRY
        SELECT Samples.idfHumanCase,
               Samples.idfMaterial,
               Samples.strBarcode,          -- Lab sample ID
               Samples.strFieldBarcode,     -- Local Sample ID
               Samples.idfsSampleType,
               SampleType.name AS strSampleTypeName,
               Samples.datFieldCollectionDate,
               Samples.idfSendToOffice,
               Samples.idfFieldCollectedByOffice,
               Samples.datFieldSentDate,
               Samples.idfsSampleStatus,
               sampleStatus.name AS SampleStatusTypeName,
               Samples.idfFieldCollectedByPerson,
               Samples.datSampleStatusDate,
               Samples.rowGuid AS sampleGuid,
               t.idfTesting,
               t.idfsTestName,
               t.idfsTestCategory,
               testCat.name AS strTestCategory,
               t.idfsTestResult,
               t.idfsTestStatus,
               t.idfsDiagnosis,
               disease.name AS strDiagnosis,
               tstatus.name AS strTestStatus,
               tresult.name AS strTestResult,
               TestName.name,
               t.datReceivedDate,
               t.datConcludedDate,
               t.idfTestedByPerson,
               t.idfTestedByOffice,
			   tv.datInterpretationDate AS datInterpretedDate,
               tv.idfsInterpretedStatus,
               testinterpretedstatus.name AS strInterpretedStatus,
               tv.strInterpretedComment,
               ISNULL(interpretedByPerson.strFamilyName, N'') + ISNULL(', ' + interpretedByPerson.strFirstName, N'')
                   + ISNULL(' ' + interpretedByPerson.strSecondName, N'') AS strInterpretedBy,
               tv.datValidationDate AS datValidationDate,
               ISNULL(tv.blnValidateStatus, 0) AS blnValidateStatus,
               tv.strValidateComment,
               ISNULL(validatedByPerson.strFamilyName, N'') + ISNULL(', ' + validatedByPerson.strFirstName, N'')
                   + ISNULL(' ' + validatedByPerson.strSecondName, N'') AS strValidatedBy,
               t.rowGuid AS testGuid,
               t.intRowStatus,
               testedbyPerson.strFirstName + ' ' + ISNULL(testedbyPerson.strSecondName, '') + '  '
               + testedbyPerson.strFamilyName AS strTestedByPerson,
               testedByOffice.FullName AS strTestedByOffice,
               ISNULL(t.blnNonLaboratoryTest, 0) AS blnNonLaboratoryTest,
               tv.idfInterpretedByPerson,
               tv.idfValidatedByPerson AS idfValidatedByPerson,
               tv.idfTestValidation
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial Samples
                ON Samples.idfMaterial = t.idfMaterial
            INNER JOIN dbo.tlbHumanCase hc
                ON Samples.idfHumanCase = hc.idfHumanCase
            INNER JOIN dbo.FN_GBL_REFERENCEREPAIR(@LangID, 19000087) SampleType
                ON SampleType.idfsReference = Samples.idfsSampleType
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) disease
                ON disease.idfsReference = t.idfsDiagnosis
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000015) sampleStatus
                ON sampleStatus.idfsReference = Samples.idfsSampleStatus
            LEFT JOIN dbo.FN_GBL_REFERENCEREPAIR(@LangID, 19000097) TestName
                ON TestName.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000001) tstatus
                ON tstatus.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepairSplit(@LangID, '19000162, 19000096') tresult
				ON tresult.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.tlbTestValidation tv
                ON tv.idfTesting = t.idfTesting
                   AND tv.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson interpretedByPerson
                ON interpretedByPerson.idfPerson = tv.idfInterpretedByPerson
            LEFT JOIN dbo.tlbPerson testedbyPerson
                ON (testedbyPerson.idfPerson = t.idfTestedByPerson)
            LEFT JOIN dbo.FN_GBL_INSTITUTION(@LangID) testedByOffice
                ON testedByOffice.idfOffice = t.idfTestedByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000095) testCat
                ON testCat.idfsReference = t.idfsTestCategory
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000106) testinterpretedstatus
                ON testinterpretedstatus.idfsReference = tv.idfsInterpretedStatus
            LEFT JOIN dbo.tlbPerson validatedByPerson
                ON (validatedByPerson.idfPerson = tv.idfValidatedByPerson)
        WHERE Samples.idfHumanCase = @idfHumanCase
              AND Samples.intRowStatus = 0
              and t.idfHumanCase is not null
              AND t.intRowStatus = 0
              AND t.idfsTestStatus <> 10001007; -- Deleted
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
