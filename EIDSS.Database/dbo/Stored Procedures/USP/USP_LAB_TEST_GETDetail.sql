-- ================================================================================================
-- Name: USP_LAB_TEST_GETDetail
--
-- Description:	Get test details for a specific laboratory test.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     09/26/2021 Initial release.
-- Stephen Long     09/30/2022 Added results entered by and validated by person name.
-- Stephen Long     10/18/2022 Fix on external test indicator to use the field on the testing 
--                             table.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TEST_GETDetail]
		@LanguageID = N'en-US',
		@TestID = 1,
		@UserID = 161287150000872 --rykermase

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_TEST_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @TestID BIGINT,
    @UserID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
            @ReturnCode INT = 0;

    BEGIN TRY
        SELECT t.idfTesting AS TestID,
               t.idfsTestName AS TestNameTypeID,
               t.idfsTestCategory AS TestCategoryTypeID,
               t.idfsTestResult AS TestResultTypeID,
               t.idfsTestStatus AS TestStatusTypeID,
               t.PreviousTestStatusID AS PreviousTestStatusTypeID,
               t.idfsDiagnosis AS DiseaseID,
               m.idfMaterial AS SampleID,
               t.idfBatchTest AS BatchTestID,
               t.idfObservation AS ObservationID,
               t.intTestNumber AS TestNumber,
               t.strNote AS Note,
               t.datStartedDate AS StartedDate,
               t.datConcludedDate AS ResultDate,
               t.idfTestedByOffice AS TestedByOrganizationID,
               t.idfTestedByPerson AS TestedByPersonID,
               t.idfResultEnteredByOffice AS ResultEnteredByOrganizationID,
               t.idfResultEnteredByPerson AS ResultEnteredByPersonID,
               ISNULL(resultsEnteredByPerson.strFamilyName, N'')
               + ISNULL(', ' + resultsEnteredByPerson.strFirstName, N'')
               + ISNULL(' ' + resultsEnteredByPerson.strSecondName, N'') AS ResultEnteredByPersonName,
               t.idfValidatedByOffice AS ValidatedByOrganizationID,
               t.idfValidatedByPerson AS ValidatedByPersonID,
               ISNULL(validatedByPerson.strFamilyName, N'') + ISNULL(', ' + validatedByPerson.strFirstName, N'')
               + ISNULL(' ' + validatedByPerson.strSecondName, N'') AS ValidatedByPersonName,
               t.blnReadOnly AS ReadOnlyIndicator,
               t.blnNonLaboratoryTest AS NonLaboratoryTestIndicator,
               t.blnExternalTest AS ExternalTestIndicator,
               t.idfPerformedByOffice AS PerformedByOrganizationID,
               t.datReceivedDate AS ReceivedDate,
               t.strContactPerson AS ContactPersonName,
               disease.name AS DiseaseName,
               testNameType.name AS TestNameTypeName,
               testStatusType.name AS TestStatusTypeName,
               testResultType.name AS TestResultTypeName,
               testCategoryType.name AS TestCategoryTypeName,
               tro.idfTransferOut AS TransferID,
               t.intRowStatus AS RowStatus
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                ON disease.idfsReference = t.idfsDiagnosis
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000097) testNameType
                ON testNameType.idfsReference = t.idfsTestName
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000001) testStatusType
                ON testStatusType.idfsReference = t.idfsTestStatus
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) testResultType
                ON testResultType.idfsReference = t.idfsTestResult
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000095) testCategoryType
                ON testCategoryType.idfsReference = t.idfsTestCategory
            LEFT JOIN dbo.tlbPerson resultsEnteredByPerson
                ON resultsEnteredByPerson.idfPerson = t.idfResultEnteredByPerson
                   AND resultsEnteredByPerson.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson validatedByPerson
                ON validatedByPerson.idfPerson = t.idfValidatedByPerson
                   AND validatedByPerson.intRowStatus = 0
        WHERE t.idfTesting = @TestID;

        SELECT @ReturnCode,
               @ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
