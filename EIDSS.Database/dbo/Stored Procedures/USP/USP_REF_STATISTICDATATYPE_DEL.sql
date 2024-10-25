--=====================================================================================================
-- Name: USP_REF_STATISTICDATATYPE_DEL
-- Description:	Removes a statistic data type from the active list
--							
-- Author:		Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		2018/10/12 Initial Release
-- Ricky Moss		12/13/2018	Removed the return code
-- Doug Albanese	08/03/2021	Added the deletion routine to deactivate the record tied to the 
--                             base reference.
-- Stephen Long     11/01/2022 Added site alert logic.
-- Leo Tracchia     02/27/2023 Added data audit logic.
-- Leo Tracchia		03/10/2023 Corrected logic for data audit.
-- 
-- Test Code:
-- exec USP_REF_STATISTICDATATYPE_DEL 55615180000061
-- 
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_STATISTICDATATYPE_DEL]
(
    @idfsStatisticDataType BIGINT,
    @DeleteAnyway BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    BEGIN TRY

        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF NOT EXISTS
        (
            SELECT idfsStatisticDataType
            FROM dbo.tlbStatistic
            WHERE idfsStatisticDataType = @idfsStatisticDataType
                  AND intRowStatus = 0
        ) OR @DeleteAnyway = 1

			BEGIN

				--Begin: Data Audit--	

				DECLARE @idfUserId BIGINT = @UserId;
				DECLARE @idfSiteId BIGINT = @SiteId;
				DECLARE @idfsDataAuditEventType bigint = NULL;
				DECLARE @idfsObjectType bigint = 10017050; --select * from trtBaseReference where idfsReferenceType = 19000017 and strdefault like '%stat%'
				DECLARE @idfObject bigint = @idfsStatisticDataType;
				DECLARE @idfObjectTable_trtStatisticDataType bigint = 75980000000;		
				DECLARE @idfObjectTable_trtBaseReference bigint = 75820000000;
				DECLARE @idfObjectTable_trtStringNameTranslation bigint = 75990000000;
				DECLARE @idfDataAuditEvent bigint = NULL;	

				-- tauDataAuditEvent Event Type - Delete 
				set @idfsDataAuditEventType = 10016002;
			
				--End: Data Audit--	

				UPDATE dbo.trtStatisticDataType
				SET intRowStatus = 1,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @AuditUserName
				WHERE idfsStatisticDataType = @idfsStatisticDataType
					  AND intRowStatus = 0;

				--Begin: Data Audit, trtStatisticDataType--				
				
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtStatisticDataType, @idfDataAuditEvent OUTPUT

				-- insert record into tauDataAuditEvent - 
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtStatisticDataType, @idfObject)

				--End: Data Audit, trtStatisticDataType--

				UPDATE dbo.trtBaseReference
				SET intRowStatus = 1,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @AuditUserName
				WHERE idfsBaseReference = @idfsStatisticDataType
					  AND intRowStatus = 0;

				--Begin: Data Audit, trtBaseReference--				
	
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtBaseReference, @idfObject)

				--End: Data Audit, trtBaseReference--

				UPDATE dbo.trtStringNameTranslation
				SET intRowStatus = 1,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @AuditUserName
				WHERE idfsBaseReference = @idfsStatisticDataType;

				--Begin: Data Audit, trtStringNameTranslation--				
	
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtStringNameTranslation, @idfObject)

				--End: Data Audit, trtStringNameTranslation--

				UPDATE dbo.trtBaseReference
				SET intRowStatus = 1,
					AuditUpdateDTM = GETDATE(),
					AuditUpdateUser = @AuditUserName
				WHERE idfsBaseReference = @idfsStatisticDataType;

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
											   @EventTypeId,
											   @UserId,
											   @idfsStatisticDataType,
											   NULL,
											   @SiteId,
											   NULL,
											   @SiteId,
											   @LocationId,
											   @AuditUserName;
			END

        ELSE IF EXISTS
        (
            SELECT idfsStatisticDataType
            FROM dbo.tlbStatistic
            WHERE idfsStatisticDataType = @idfsStatisticDataType
                  and intRowStatus = 0
        )
			BEGIN
				SELECT @ReturnCode = -1;
				SELECT @ReturnMessage = 'IN USE';
			END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
