
-- ================================================================================================
-- Name: USSP_VET_PENSIDE_TEST_SET
--
-- Description:	Inserts or updates penside test for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     04/17/2019 Updates for API.
-- Mark Wilson      10/20/2021 removed @LanguageID, added @AuditUser, completed insert and update.
-- Stephen Long     01/19/2022 Changed row action data type.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_PENSIDE_TEST_SET]
(
    @AuditUserName NVARCHAR(200),
    @PensideTestID BIGINT OUTPUT,
    @SampleID BIGINT,
    @PensideTestResultTypeID BIGINT = NULL,
    @PensideTestNameTypeID BIGINT = NULL,
    @TestedByPersonID BIGINT = NULL,
    @TestedByOrganizationID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @TestDate DATETIME = NULL,
    @PensideTestCategoryTypeID BIGINT = NULL,
    @RowStatus INT,
    @RowAction INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbPensideTest',
                                              @idfsKey = @PensideTestID OUTPUT;

            INSERT INTO dbo.tlbPensideTest
            (
                idfPensideTest,
                idfMaterial,
                idfsPensideTestResult,
                idfsPensideTestName,
                intRowStatus,
                rowguid,
                idfTestedByPerson,
                idfTestedByOffice,
                idfsDiagnosis,
                datTestDate,
                idfsPensideTestCategory,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@PensideTestID,
             @SampleID,
             @PensideTestResultTypeID,
             @PensideTestNameTypeID,
             @RowStatus,
             NEWID(),
             @TestedByPersonID,
             @TestedByOrganizationID,
             @DiseaseID,
             @TestDate,
             @PensideTestCategoryTypeID,
             NULL,
             NULL,
             10519001,
             '[{"idfPensideTest":' + CAST(@PensideTestID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
             GETDATE()
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.tlbPensideTest
            SET idfMaterial = @SampleID,
                idfsPensideTestResult = @PensideTestResultTypeID,
                idfsPensideTestName = @PensideTestNameTypeID,
                intRowStatus = @RowStatus,
                idfTestedByPerson = @TestedByPersonID,
                idfTestedByOffice = @TestedByOrganizationID,
                idfsDiagnosis = @DiseaseID,
                datTestDate = @TestDate,
                idfsPensideTestCategory = @PensideTestCategoryTypeID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfPensideTest = @PensideTestID;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
