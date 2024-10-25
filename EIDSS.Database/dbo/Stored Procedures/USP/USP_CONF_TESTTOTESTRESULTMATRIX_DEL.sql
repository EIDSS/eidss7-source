-- =========================================================================================
-- NAME: USP_CONF_TESTTOTESTRESULTMATRIX_DEL
-- DESCRIPTION: Deactivates a test to test result relationship

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		03/08/2019	Initial Release
-- Ricky Moss		03/27/2019	Added delete anyway field
-- Stephen Long     04/17/2023 Added site alert logic.
--
-- exec USP_CONF_TESTTOTESTRESULTMATRIX_DEL 19000097, 803960000000, 807830000000, 0
-- exec USP_CONF_TESTTOTESTRESULTMATRIX_DEL 19000104, 6618660000000, 808040000000, 0
-- ========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_TESTTOTESTRESULTMATRIX_DEL]
(
    @idfsTestResultRelation BIGINT,
    @idfsTestName BIGINT,
    @idfsTestResult BIGINT,
    @deleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
declare @idfUserId BIGINT = NULL;
declare @idfSiteId BIGINT = NULL;
declare @idfsDataAuditEventType bigint = 10016002;
declare @idfsObjectType bigint = 10017055;
declare @idfObject bigint = @idfsTestName;
declare @idfObjectTable_tlbTestMatrix bigint = 76020000000;
declare @idfDataAuditEvent bigint = NULL;
-- Get and Set UserId and SiteId
select @idfUserId = userInfo.UserId,
       @idfSiteId = UserInfo.SiteId
from dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

BEGIN
    BEGIN TRY
        IF @idfsTestResultRelation = 19000097
        BEGIN
            UPDATE dbo.trtTestTypeToTestResult
            SET intRowStatus = 1
            WHERE idfsTestName = @idfsTestName
                  AND idfsTestResult = @idfsTestResult
                  AND intRowStatus = 0;

            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserId,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfObject,
                                                 @idfObjectTable_tlbTestMatrix,
                                                 @idfDataAuditEvent OUTPUT;
            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            values
            (@idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, 4578170000000, @idfObject, null, 0, 1);
        END
        ELSE
        BEGIN
            UPDATE dbo.trtPensideTestTypeToTestResult
            SET intRowStatus = 1
            WHERE idfsPensideTestName = @idfsTestName
                  AND idfsPensideTestResult = @idfsTestResult
                  AND intRowStatus = 0

            set @idfObjectTable_tlbTestMatrix = 75910000000;
            EXEC dbo.USSP_GBL_DataAuditEvent_GET @idfUserId,
                                                 @idfSiteId,
                                                 @idfsDataAuditEventType,
                                                 @idfsObjectType,
                                                 @idfObject,
                                                 @idfObjectTable_tlbTestMatrix,
                                                 @idfDataAuditEvent OUTPUT;
            insert into dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            values
            (@idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, 4578170000000, @idfObject, null, 0, 1);
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                       @EventTypeId,
                                       @UserId,
                                       @idfsTestName,
                                       NULL,
                                       @SiteId,
                                       NULL,
                                       @SiteId,
                                       @LocationId,
                                       @AuditUserName;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
