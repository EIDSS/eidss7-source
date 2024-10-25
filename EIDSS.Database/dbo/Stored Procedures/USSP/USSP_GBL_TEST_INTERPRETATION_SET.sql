-- ================================================================================================
-- Name: USSP_GBL_TEST_INTERPRETATION_SET
--
-- Description:	Inserts or updates test interpretation records for various use cases.
--
-- Revision History:
-- Name  Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/27/2018 Initial release.
-- Stephen Long     04/17/2019 Removed strMaintenanceFlag.
-- Stephen Long     01/19/2022 Changed row action data type and removed language ID.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_TEST_INTERPRETATION_SET]
(
    @AuditUserName NVARCHAR(200),
    @TestInterpretationID BIGINT OUTPUT,
    @DiseaseID BIGINT,
    @InterpretedStatusTypeID BIGINT = NULL,
    @ValidatedByOrganizationID BIGINT = NULL,
    @ValidatedByPersonID BIGINT = NULL,
    @InterpretedByOrganizationID BIGINT = NULL,
    @InterpretedByPersonID BIGINT = NULL,
    @TestID BIGINT,
    @ValidateStatusIndicator BIT = NULL,
    @ReportSessionCreatedIndicator BIT = NULL,
    @ValidationComment NVARCHAR(200) = NULL,
    @InterpretationComment NVARCHAR(200) = NULL,
    @ValidationDate DATETIME = NULL,
    @InterpretationDate DATETIME = NULL,
    @RowStatus INT,
    @ReadOnlyIndicator BIT,
    @RowAction INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTestValidation',
                                              @TestInterpretationID OUTPUT;
			print @TestInterpretationID;
            INSERT INTO dbo.tlbTestValidation
            (
                idfTestValidation,
                idfsDiagnosis,
                idfsInterpretedStatus,
                idfValidatedByOffice,
                idfValidatedByPerson,
                idfInterpretedByOffice,
                idfInterpretedByPerson,
                idfTesting,
                blnValidateStatus,
                blnCaseCreated,
                strValidateComment,
                strInterpretedComment,
                datValidationDate,
                datInterpretationDate,
                intRowStatus,
                blnReadOnly,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@TestInterpretationID,
             @DiseaseID,
             @InterpretedStatusTypeID,
             @ValidatedByOrganizationID,
             @ValidatedByPersonID,
             @InterpretedByOrganizationID,
             @InterpretedByPersonID,
             @TestID,
             @ValidateStatusIndicator,
             @ReportSessionCreatedIndicator,
             @ValidationComment,
             @InterpretationComment,
             @ValidationDate,
             @InterpretationDate,
             @RowStatus,
             @ReadOnlyIndicator,
             @AuditUserName,
             10519001,
             '[{"idfTestValidation":' + CAST(@TestInterpretationID AS NVARCHAR(300)) + '}]'
            );
        END
        ELSE
        BEGIN
		print 'else';
            UPDATE dbo.tlbTestValidation
            SET idfsDiagnosis = @DiseaseID,
                idfsInterpretedStatus = @InterpretedStatusTypeID,
                idfValidatedByOffice = @ValidatedByOrganizationID,
                idfValidatedByPerson = @ValidatedByPersonID,
                idfInterpretedByOffice = @InterpretedByOrganizationID,
                idfInterpretedByPerson = @InterpretedByPersonID,
                idfTesting = @TestID,
                blnValidateStatus = @ValidateStatusIndicator,
                blnCaseCreated = @ReportSessionCreatedIndicator,
                strValidateComment = @ValidationComment,
                strInterpretedComment = @InterpretationComment,
                datValidationDate = @ValidationDate,
                datInterpretationDate = @InterpretationDate,
                intRowStatus = @RowStatus,
                blnReadOnly = @ReadOnlyIndicator,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfTestValidation = @TestInterpretationID;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
