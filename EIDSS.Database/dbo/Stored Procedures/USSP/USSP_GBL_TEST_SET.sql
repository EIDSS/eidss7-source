-- ================================================================================================
-- Name: USSP_GBL_TEST_SET
--
-- Description:	Inserts or updates laboratory and field test records for various use cases.
--
-- Revision History:
-- Name  Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/17/2019 Initial release.
-- Stephen Long     12/20/2020 Added monitoring session, vector session, human disease report and 
--                  veterinary disease report identifier parameters.
-- Stephen Long     01/19/2022 Added row action check of 1 to sync up with row action type enum.
-- Leo Tracchia		10/21/2022 fix for properly deleting tests for human disease report DevOps defect 5006
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_TEST_SET]
(
    @LanguageID NVARCHAR(50),
    @TestID BIGINT OUTPUT,
    @TestNameTypeID BIGINT = NULL,
    @TestCategoryTypeID BIGINT = NULL,
    @TestResultTypeID BIGINT = NULL,
    @TestStatusTypeID BIGINT,
    @DiseaseID BIGINT,
    @SampleID BIGINT = NULL,
    @BatchTestID BIGINT = NULL,
    @ObservationID BIGINT,
    @TestNumber INT = NULL,
    @Comments NVARCHAR(500) = NULL,
    @RowStatus INT = NULL,
    @StartedDate DATETIME = NULL,
    @ResultDate DATETIME = NULL,
    @TestedByOrganizationID BIGINT = NULL,
    @TestedByPersonID BIGINT = NULL,
    @ResultEnteredByOrganizationID BIGINT = NULL,
    @ResultEnteredByPersonID BIGINT = NULL,
    @ValidatedByOrganizationID BIGINT = NULL,
    @ValidatedByPersonID BIGINT = NULL,
    @ReadOnlyIndicator BIT,
    @NonLaboratoryTestIndicator BIT,
    @ExternalTestIndicator BIT = NULL,
    @PerformedByOrganizationID BIGINT = NULL,
    @ReceivedDate DATETIME = NULL,
    @ContactPerson NVARCHAR(200) = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @VectorSessionID BIGINT = NULL,
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @RowAction CHAR
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @RowAction = 'I'
           OR @RowAction = '1' -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTesting', @TestID OUTPUT;

            INSERT INTO dbo.tlbTesting
            (
                idfTesting,
                idfsTestName,
                idfsTestCategory,
                idfsTestResult,
                idfsTestStatus,
                idfsDiagnosis,
                idfMaterial,
                idfBatchTest,
                idfObservation,
                intTestNumber,
                strNote,
                intRowStatus,
                datStartedDate,
                datConcludedDate,
                idfTestedByOffice,
                idfTestedByPerson,
                idfResultEnteredByOffice,
                idfResultEnteredByPerson,
                idfValidatedByOffice,
                idfValidatedByPerson,
                blnReadOnly,
                blnNonLaboratoryTest,
                blnExternalTest,
                idfPerformedByOffice,
                datReceivedDate,
                strContactPerson,
                idfMonitoringSession,
                idfVector,
                idfHumanCase,
                idfVetCase,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@TestID,
             @TestNameTypeID,
             @TestCategoryTypeID,
             @TestResultTypeID,
             @TestStatusTypeID,
             @DiseaseID,
             @SampleID,
             @BatchTestID,
             @ObservationID,
             @TestNumber,
             @Comments,
             @RowStatus,
             @StartedDate,
             @ResultDate,
             @TestedByOrganizationID,
             @TestedByPersonID,
             @ResultEnteredByOrganizationID,
             @ResultEnteredByPersonID,
             @ValidatedByOrganizationID,
             @ValidatedByPersonID,
             @ReadOnlyIndicator,
             @NonLaboratoryTestIndicator,
             @ExternalTestIndicator,
             @PerformedByOrganizationID,
             @ReceivedDate,
             @ContactPerson,
             @MonitoringSessionID,
             @VectorSessionID,
             @HumanDiseaseReportID,
             @VeterinaryDiseaseReportID,
             @AuditUserName,
             10519001,
             '[{"idfTesting":' + CAST(@TestID AS NVARCHAR(300)) + '}]'
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.tlbTesting
            SET idfsTestName = @TestNameTypeID,
                idfsTestCategory = @TestCategoryTypeID,
                idfsTestResult = @TestResultTypeID,
                idfsTestStatus = @TestStatusTypeID,
                idfsDiagnosis = @DiseaseID,
                idfMaterial = @SampleID,
                idfBatchTest = @BatchTestID,
                idfObservation = @ObservationID,
                intTestNumber = @TestNumber,
                strNote = @Comments,
                intRowStatus = @RowStatus,
                datStartedDate = @StartedDate,
                datConcludedDate = @ResultDate,
                idfTestedByOffice = @TestedByOrganizationID,
                idfTestedByPerson = @TestedByPersonID,
                idfResultEnteredByOffice = @ResultEnteredByOrganizationID,
                idfResultEnteredByPerson = @ResultEnteredByPersonID,
                idfValidatedByOffice = @ValidatedByOrganizationID,
                idfValidatedByPerson = @ValidatedByPersonID,
                blnReadOnly = @ReadOnlyIndicator,
                blnNonLaboratoryTest = @NonLaboratoryTestIndicator,
                blnExternalTest = @ExternalTestIndicator,
                idfPerformedByOffice = @PerformedByOrganizationID,
                datReceivedDate = @ReceivedDate,
                strContactPerson = @ContactPerson,
                idfMonitoringSession = @MonitoringSessionID,
                idfVector = @VectorSessionID,
                idfHumanCase = @HumanDiseaseReportID,
                idfVetCase = @VeterinaryDiseaseReportID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = getdate()
            WHERE idfTesting = @TestID;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
