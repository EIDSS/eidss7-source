--*************************************************************
-- Name 				: [[USP_GBL_ReportForm_DELETE]]
-- Description			: Delete Weekly Report Form record
--          
-- Author               : Mani
-- Revision History
--		Name       Date       Change Detail
-- Michael Brown 07/25/2022  Modified SP to Provide for intRowStatus = 1 to soft delete record.
--                           Also added AuditUpdateUser and AuditUpdateDate for tracking
--Manickandan Govindarajan 11/30/2022 Added Data Audit Functionality
-- Testing code:
/*

exec  [dbo].[[USP_GBL_ReportForm_DELETE]] 1
--*/
CREATE PROCEDURE [dbo].[USP_GBL_ReportForm_DELETE]
(    
    @ID AS BIGINT,
    @AuditUser NVARCHAR(200)
)
AS
DECLARE @returnCode        INT = 0 
DECLARE @returnMsg        NVARCHAR(MAX) = 'SUCCESS' 
declare @idfsDataAuditEventType bigint =10016002;
declare @idfsObjectType bigint =10017074;
declare @idfObject bigint; 
declare @idfObjectTable_tlbReportForm bigint =53577790000001;
declare @idfDataAuditEvent bigint;
declare @idfUserID bigint;
declare @idfSiteId bigint;

BEGIN

    BEGIN TRY
    BEGIN TRANSACTION


		--Data Audit
			select @idfUserID= a.userid, @idfSiteId= a.siteid from dbo.FN_UserSiteInformation(@AuditUser) a;
			-- insert record into tauDataAuditEvent
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@ID, @idfObjectTable_tlbReportForm, @idfDataAuditEvent OUTPUT
			-- insert into delete 
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
			values(@idfDataAuditEvent, @idfObjectTable_tlbReportForm, @ID)
		--Data Audit

        --delete from tflReportFormFiltered where idfReportForm = @ID
        UPDATE dbo.tlbReportForm 
        SET intRowStatus = 1,
            AuditUpdateUser = @AuditUser,
            AuditUpdateDTM = GETDATE()

        WHERE idfReportForm = @ID

        IF @@TRANCOUNT > 0 
          COMMIT

        SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'

    END TRY 
        BEGIN CATCH 
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;

    END CATCH
END
