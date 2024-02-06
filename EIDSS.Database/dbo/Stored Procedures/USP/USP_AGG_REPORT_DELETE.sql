-- ================================================================================================
-- Name: USP_AGG_REPORT_DELETE
--
-- Description: Deletes aggregate disease report records.
--          
-- Author: Mike Kornegay
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Mike Kornegay            04/08/2022 Original
-- Manickandan Govindarajan 12/06/2022 DataAudit SAUC30 and 31
-- Stephen Long             03/08/2023 Fix to call data audit event set to pass EIDSS ID.
--
-- Testing code: 
/*
	DECLARE @ID BIGINT = 34390000806
	EXECUTE USP_AGG_REPORT_DELETE  @ID, 'rykermase'

*/
--	@ID is AggregateCaseID
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AGG_REPORT_DELETE]
(
    @ID AS BIGINT,
    @User NVARCHAR(100) = NULL
)
AS
DECLARE @ReturnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @idfDiagnosticObservation BIGINT;
DECLARE @idfProphylacticObservation BIGINT;
DECLARE @idfSanitaryObservation BIGINT;
--dataAudit
DECLARE @idfsDataAuditEventType bigint = 10016002;
DECLARE @idfsObjectType bigint;
DECLARE @idfObject bigint = @ID;
DECLARE @idfObjectTable_tlbAggrCase bigint = 75420000000;
DECLARE @idfDataAuditEvent bigint;
DECLARE @campaignCategoryId bigint;
DECLARE @idfUserID bigint;
DECLARE @idfSiteId bigint;
DECLARE @idfObjectTable_tlbCampaignToDiagnosis bigint = 707000000000;
DECLARE @aggrTypeId bigint;
DECLARE @EIDSSAggregateDiseaseReportID NVARCHAR(200)
    =   (
            SELECT strCaseID FROM dbo.tlbAggrCase WHERE idfAggrCase = @ID
        );
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200)
);

--dataudit

BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        --Data Audit
        SELECT @aggrTypeId = idfsAggrCaseType
        FROM dbo.tlbAggrCase
        WHERE idfAggrCase = @ID;
        --Data Audit

        IF @aggrTypeId = 10102001
            SET @idfsObjectType = 10017006;
        IF @aggrTypeId = 10102002
            SET @idfsObjectType = 10017005;
        IF @aggrTypeId = 10102003
            SET @idfsObjectType = 10017004;
        --Data Audit

        SELECT @idfDiagnosticObservation = idfDiagnosticObservation
        FROM dbo.tlbAggrCase
        WHERE idfAggrCase = @ID;

        SELECT @idfProphylacticObservation = idfProphylacticObservation
        FROM dbo.tlbAggrCase
        WHERE idfAggrCase = @ID;

        SELECT @idfSanitaryObservation = idfSanitaryObservation
        FROM dbo.tlbAggrCase
        WHERE idfAggrCase = @ID;

        BEGIN
            DELETE FROM dbo.tflAggrCaseFiltered
            WHERE idfAggrCase = @ID;

            --Data Audit
            select @idfUserID = a.userid,
                   @idfSiteId = a.siteid
            from dbo.FN_UserSiteInformation(@User) a;
            -- insert record into tauDataAuditEvent
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @idfUserID,
                                                      @idfSiteId,
                                                      @idfsDataAuditEventType,
                                                      @idfsObjectType,
                                                      @idfObject,
                                                      @idfObjectTable_tlbAggrCase,
                                                      @EIDSSAggregateDiseaseReportID,
                                                      @idfDataAuditEvent OUTPUT;
            -- insert into delete 


            INSERT INTO dbo.tauDataAuditDetailDelete
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_tlbAggrCase,
                   idfAggrCase
            FROM dbo.tlbAggrCase
            WHERE idfAggrCase = @Id;
            --Data Audit

            UPDATE dbo.tlbAggrCase
            SET intRowStatus = 1,
                AuditUpdateUser = @User,
                AuditUpdateDTM = GETDATE()
            WHERE idfAggrCase = @ID;

            EXEC dbo.USP_OBSERVATION_DELETE @ID = @idfDiagnosticObservation,
                                            @User = @User,
                                            @idfDataAuditEvent = @idfDataAuditEvent;

            EXEC dbo.USP_OBSERVATION_DELETE @ID = @idfProphylacticObservation,
                                            @User = @User,
                                            @idfDataAuditEvent = @idfDataAuditEvent;

            EXEC dbo.USP_OBSERVATION_DELETE @ID = @idfSanitaryObservation,
                                            @User = @User,
                                            @idfDataAuditEvent = @idfDataAuditEvent;
        END

        IF @@TRANCOUNT > 0
           AND @ReturnCode = 0
            COMMIT;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
        THROW;
    END CATCH
END
