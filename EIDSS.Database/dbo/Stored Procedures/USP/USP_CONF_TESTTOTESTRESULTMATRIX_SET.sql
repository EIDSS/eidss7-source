-- ================================================================================================
-- Name: USP_CONF_TESTTOTESTRESULTMATRIX_SET
--
-- Description:	Creates a test to test result matrix
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/11/2018 Initial release.
-- Stephen Long     07/13/2022 Added site alert logic.
--
-- exec USP_CONF_TESTTOTESTRESULTMATRIX_SET 803960000000, '807830000000, 807990000000, 808040000000', 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_TESTTOTESTRESULTMATRIX_SET]
(
    @idfsTestResultRelation BIGINT,
    @idfsTestName BIGINT,
    @idfsTestResult BIGINT,
    @blnIndicative BIT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @ReturnCode BIGINT = 0,
        @EventId BIGINT = -1,
        @EventSiteId BIGINT = @SiteId,
        @EventUserId BIGINT = @UserId,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = @LocationId,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = @SiteId;
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
Declare @isAvail bit

--Data Audit--
BEGIN
declare @idfUserId BIGINT =NULL;
declare @idfSiteId BIGINT = NULL;
declare @idfsDataAuditEventType bigint =NULL;
declare @idfsObjectType bigint = 10017055;
declare @idfObject bigint = NULL;
declare @idfObjectTable_tlbTestMatrix bigint = 76020000000;
declare @idfDataAuditEvent bigint= NULL; 

DECLARE @tlbTestMatrix_BeforeEdit TABLE
(
	blnIndicative BIT,
	idfsTestResult BIGINT,
	idfsTestName BIGINT,
	intRowStatus INT
)
DECLARE @tlbTestMatrix_AfterEdit TABLE
(
	blnIndicative BIT,
	idfsTestResult BIGINT,
	idfsTestName BIGINT,
	intRowStatus INT
)

-- Get and Set UserId and SiteId
select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUserName) userInfo
END

BEGIN
    BEGIN TRY 
        IF @idfsTestResultRelation = 19000097
        BEGIN 
            IF NOT EXISTS
            (
                SELECT idfsTestResult
                FROM dbo.trtTestTypeToTestResult
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName
            )
            BEGIN
                INSERT INTO dbo.trtTestTypeToTestResult
                (
                    idfsTestName,
                    idfsTestResult,
                    blnIndicative,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsTestName, @idfsTestResult, @blnIndicative, 0, GETDATE(), @AuditUserName);
				
				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfObject = @idfsTestName;
				set @idfObjectTable_tlbTestMatrix =76020000000;
				set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, @idfObject)
				--Data Audit--
            END
            ELSE IF EXISTS
            (
                SELECT idfsTestResult
                FROM dbo.trtTestTypeToTestResult
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName
            )
            BEGIN 		
                SET @isAvail = (SELECT count(*)
                FROM dbo.trtTestTypeToTestResult
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName
					  AND intRowStatus = 0
					  AND blnIndicative = @blnIndicative) 

				insert into @tlbTestMatrix_BeforeEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsTestName, idfsTestResult, blnIndicative, intRowStatus 
					from trtTestTypeToTestResult WHERE idfsTestResult = @idfsTestResult AND idfsTestName = @idfsTestName

                UPDATE dbo.trtTestTypeToTestResult
                SET intRowStatus = 0,
                    blnIndicative = @blnIndicative,
                    AuditUpdateDTM = GETDATE(), 
                    AuditUpdateUser = @AuditUserName
                WHERE idfsTestResult = @idfsTestResult
                      AND idfsTestName = @idfsTestName;
				insert into @tlbTestMatrix_AfterEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsTestName, idfsTestResult, blnIndicative, intRowStatus 
					from trtTestTypeToTestResult WHERE idfsTestResult = @idfsTestResult AND idfsTestName = @idfsTestName
					
				set @ReturnCode = 6
				set @ReturnMessage = Case When @isAvail = 0 Then 'SUCCESS' Else 'EXISTS' End

				--DataAudit-- 
				insert into @tlbTestMatrix_AfterEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsTestName, idfsTestResult, blnIndicative, intRowStatus 
					from trtTestTypeToTestResult WHERE idfsTestResult = @idfsTestResult AND idfsTestName = @idfsTestName

				IF EXISTS 
				(
					select *
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,'')) OR (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,''))
				)
				BEGIN
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType = 10016003;
					Set @idfObject = @idfsTestName
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 4578170000000,
						@idfObject,null,
						a.blnIndicative,b.blnIndicative 
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,''))  
				END

            END
        END
        ELSE
        BEGIN		
            --creates new test for disease
            IF NOT EXISTS
            (
                SELECT idfsPensideTestResult
                FROM dbo.trtPensideTestTypeToTestResult
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName
            )
            BEGIN	 
                INSERT INTO dbo.trtPensideTestTypeToTestResult
                (
                    idfsPensideTestName,
                    idfsPensideTestResult,
                    blnIndicative,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsTestName, @idfsTestResult, @blnIndicative, 0, GETDATE(), @AuditUserName);

				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfObject = @idfsTestName;
				set @idfObjectTable_tlbTestMatrix =75910000000;
				set @idfsDataAuditEventType =10016001;
						-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEvent, @idfObjectTable_tlbTestMatrix, @idfObject)
				--Data Audit--
            END
            ELSE IF EXISTS
            (
                SELECT idfsPensideTestResult
                FROM dbo.trtPensideTestTypeToTestResult
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName
            )
            BEGIN		
                SET @isAvail = (SELECT count(*)
                FROM dbo.trtPensideTestTypeToTestResult
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName
					  AND intRowStatus = 0
					  AND blnIndicative = @blnIndicative) 
			
				insert into @tlbTestMatrix_BeforeEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsPensideTestName, idfsPensideTestResult, blnIndicative, intRowStatus 
					from trtPensideTestTypeToTestResult WHERE idfsPensideTestResult = @idfsTestResult AND idfsPensideTestName = @idfsTestName
		 
                UPDATE dbo.trtPensideTestTypeToTestResult
                SET intRowStatus = 0,
                    blnIndicative = @blnIndicative, 
                    AuditUpdateDTM = GETDATE(), 
                    AuditUpdateUser = @AuditUserName 
                WHERE idfsPensideTestResult = @idfsTestResult
                      AND idfsPensideTestName = @idfsTestName;

				set @ReturnCode = 6
				set @ReturnMessage = Case When @isAvail = 0 Then 'SUCCESS' Else 'EXISTS' End
			 
				insert into @tlbTestMatrix_AfterEdit (idfsTestName, idfsTestResult, blnIndicative, intRowStatus)
				select idfsPensideTestName, idfsPensideTestResult, blnIndicative, intRowStatus 
					from trtPensideTestTypeToTestResult WHERE idfsPensideTestResult = @idfsTestResult AND idfsPensideTestName = @idfsTestName

				--DataAudit-- 
				IF EXISTS 
				(
					select *
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,'')) OR (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,''))
				)
				BEGIN
					--  tauDataAuditEvent  Event Type- Edit 
					set @idfsDataAuditEventType = 10016003;
					Set @idfObject = @idfsTestName
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, idfObjectTable, idfColumn, 
						idfObject, idfObjectDetail, 
						strOldValue, strNewValue)
					select @idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 4578170000000,
						@idfObject,null,
						a.blnIndicative,b.blnIndicative 
					from @tlbTestMatrix_BeforeEdit a  inner join @tlbTestMatrix_AfterEdit b on a.idfsTestResult = b.idfsTestResult and a.idfsTestName = b.idfsTestName 
					where (ISNULL(a.blnIndicative,'') <> ISNULL(b.blnIndicative,''))  
				END
            END
        END

        INSERT INTO @SuppressSelect 
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @idfsTestName,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUserName;

        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfsTestName AS 'idfsTestName';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
