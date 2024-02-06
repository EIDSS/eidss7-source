-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
--
-- Description:	Creates and/or removes at relationship between a role, system function, and 
-- operation.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		12/12/2019 Initial release.
-- Ricky Moss		03/25/2020 Passes in all roles, system functions, and operations at once
-- Ricky Moss		03/26/2020 Add intRowStatus to Merge Query
-- Stephen Long     05/28/2020 Changed 0 for intRowStatus on insert to use intRowStatus supplied 
--                             in the JSON.  A permission may be inserted as denied, so in this 
--                             case an intRowStatus of 1 would be used.
-- Ann Xiong		04/13/2023 Implemented Data Audit
-- Ann Xiong		04/25/2023 Added parameter @idfDataAuditEvent
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET] (
	@rolesandfunctions NVARCHAR(MAX),
    @idfDataAuditEvent BIGINT = NULL,
	@user NVARCHAR(50)
	)
AS
DECLARE @tempRSFA TABLE (
	RoleID BIGINT,
	SystemFunctionID BIGINT,
	SystemFunctionOperationID BIGINT,
	intRowStatus INT,
	intRowStatusForSystemFunction INT
	)
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
DECLARE @modifiedJSON NVARCHAR(MAX)

		--Data Audit--
		declare @idfUserId BIGINT = NULL;
		declare @idfSiteId BIGINT = NULL;
		declare @idfsDataAuditEventType bigint = NULL;
		declare @idfsObjectType bigint = 10017052;                         -- System Function
		declare @idfObject bigint = NULL;
		declare @idfObjectTable_LkupRoleSystemFunctionAccess bigint = 53577790000006;
		--declare @idfDataAuditEvent bigint= NULL;

		CREATE TABLE #Output  
 		(
			DidfEmployee BIGINT,
			DSystemFunctionID BIGINT,
			DSystemFunctionOperationID BIGINT,
			DAccessPermissionID BIGINT,
			DintRowStatus INT,
     		DAuditCreateUser nvarchar(100),  
     		DAuditCreateDTM datetime,  
     		DAuditUpdateUser nvarchar(100),  
     		DAuditUpdateDTM datetime,  
     		Drowguid uniqueidentifier,  
     		DSourceSystemNameID BIGINT,  
     		DSourceSystemKeyValue nvarchar(max),  
			DintRowStatusForSystemFunction INT,
     		ActionTaken nvarchar(10),  
			IidfEmployee BIGINT,
			ISystemFunctionID BIGINT,
			ISystemFunctionOperationID BIGINT,
			IAccessPermissionID BIGINT,
			IintRowStatus INT,
     		IAuditCreateUser nvarchar(100),  
     		IAuditCreateDTM datetime,  
     		IAuditUpdateUser nvarchar(100),  
     		IAuditUpdateDTM datetime,  
     		Irowguid uniqueidentifier,  
     		ISourceSystemNameID BIGINT,  
     		ISourceSystemKeyValue nvarchar(max),  
			IintRowStatusForSystemFunction INT     
		); 

		CREATE TABLE #Output2  
 		(
			DidfEmployee BIGINT,
			DSystemFunctionID BIGINT,
			DSystemFunctionOperationID BIGINT,
			DAccessPermissionID BIGINT,
			DintRowStatus INT,
     		DAuditCreateUser nvarchar(100),  
     		DAuditCreateDTM datetime,  
     		DAuditUpdateUser nvarchar(100),  
     		DAuditUpdateDTM datetime,  
     		Drowguid uniqueidentifier,  
     		DSourceSystemNameID BIGINT,  
     		DSourceSystemKeyValue nvarchar(max),  
			DintRowStatusForSystemFunction INT,
     		ActionTaken nvarchar(10),  
			IidfEmployee BIGINT,
			ISystemFunctionID BIGINT,
			ISystemFunctionOperationID BIGINT,
			IAccessPermissionID BIGINT,
			IintRowStatus INT,
     		IAuditCreateUser nvarchar(100),  
     		IAuditCreateDTM datetime,  
     		IAuditUpdateUser nvarchar(100),  
     		IAuditUpdateDTM datetime,  
     		Irowguid uniqueidentifier,  
     		ISourceSystemNameID BIGINT,  
     		ISourceSystemKeyValue nvarchar(max),  
			IintRowStatusForSystemFunction INT     
		) 

		CREATE TABLE #OutputI  
 		(
			DidfEmployee BIGINT,
			DSystemFunctionID BIGINT,
			DSystemFunctionOperationID BIGINT,
			DAccessPermissionID BIGINT,
			DintRowStatus INT,
     		DAuditCreateUser nvarchar(100),  
     		DAuditCreateDTM datetime,  
     		DAuditUpdateUser nvarchar(100),  
     		DAuditUpdateDTM datetime,  
     		Drowguid uniqueidentifier,  
     		DSourceSystemNameID BIGINT,  
     		DSourceSystemKeyValue nvarchar(max),  
			DintRowStatusForSystemFunction INT,
     		ActionTaken nvarchar(10),  
			IidfEmployee BIGINT,
			ISystemFunctionID BIGINT,
			ISystemFunctionOperationID BIGINT,
			IAccessPermissionID BIGINT,
			IintRowStatus INT,
     		IAuditCreateUser nvarchar(100),  
     		IAuditCreateDTM datetime,  
     		IAuditUpdateUser nvarchar(100),  
     		IAuditUpdateDTM datetime,  
     		Irowguid uniqueidentifier,  
     		ISourceSystemNameID BIGINT,  
     		ISourceSystemKeyValue nvarchar(max),  
			IintRowStatusForSystemFunction INT     
		) 

		-- Get and Set UserId and SiteId
		select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@user) userInfo

		--Data Audit--

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		INSERT INTO @tempRSFA
		SELECT *
		FROM OPENJSON(@rolesandfunctions) WITH (
				RoleID BIGINT '$.RoleId',
				SystemFunctionID BIGINT '$.SystemFunction',
				SystemFunctionOperationID BIGINT '$.Operation',
				intRowStatus BIGINT,
				intRowStatusForSystemFunction BIGINT
				)
		
		MERGE dbo.LkupRoleSystemFunctionAccess rsfa
		USING @tempRSFA t
			ON (
					t.RoleID = rsfa.idfEmployee
					AND t.SystemFunctionID = rsfa.SystemFunctionID
					AND t.SystemFunctionOperationID = rsfa.SystemFunctionOperationID
					--AND (t.intRowStatusForSystemFunction = rsfa.intRowStatusForSystemFunction OR rsfa.intRowStatusForSystemFunction is NULL)
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET rsfa.intRowStatus = t.IntRowStatus, rsfa.intRowStatusForSystemFunction= t.intRowStatusForSystemFunction
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (
					idfEmployee,
					SystemFunctionID,
					SystemFunctionOperationID,
					intRowStatus,
					intRowStatusForSystemFunction,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser
					)
				VALUES (
					t.RoleID,
					t.SystemFunctionID,
					t.SystemFunctionOperationID,
					t.intRowStatus,
					t.intRowStatusForSystemFunction,
					10519001,
					'[{"idfEmployee":' + CAST(t.RoleID AS NVARCHAR(100)) + '"SystemFunctionID":' + CAST(t.SystemFunctionID AS NVARCHAR(100)) + '"SystemFunctionOperationID":' + CAST(t.SystemFunctionOperationID AS NVARCHAR(100)) + '}]',
					@user
					)

		OUTPUT DELETED.*, $action AS [Action], INSERTED.* INTO #Output;

		--Data Audit--
		DECLARE @RoleID BIGINT 
		SELECT TOP 1 @RoleID =  RoleID From @tempRSFA;

        IF @idfDataAuditEvent IS NULL
        BEGIN 
			--  tauDataAuditEvent  Event Type- Edit 
			set @idfsDataAuditEventType =10016003;
			-- insert record into tauDataAuditEvent - 
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@RoleID, @idfObjectTable_LkupRoleSystemFunctionAccess, @idfDataAuditEvent OUTPUT
		END

		INSERT INTO #Output2
		SELECT *
		FROM #Output
		Where ActionTaken = 'UPDATE'

		DECLARE @DidfEmployee BIGINT,
			@DSystemFunctionID BIGINT,
			@DSystemFunctionOperationID BIGINT,
			@DintRowStatus INT,
			@DintRowStatusForSystemFunction INT,
			@IidfEmployee BIGINT,
			@ISystemFunctionID BIGINT,
			@ISystemFunctionOperationID BIGINT,
			@IintRowStatus INT,
			@IintRowStatusForSystemFunction INT  

        WHILE EXISTS (SELECT * FROM #Output2)
        BEGIN

            SELECT TOP 1 
                @DidfEmployee = DidfEmployee,
                @DSystemFunctionID = DSystemFunctionID,
                @DSystemFunctionOperationID = DSystemFunctionOperationID,
                @DintRowStatus = DintRowStatus,
                @DintRowStatusForSystemFunction = DintRowStatusForSystemFunction,
                @IidfEmployee = IidfEmployee,
                @ISystemFunctionID = ISystemFunctionID,
                @ISystemFunctionOperationID = ISystemFunctionOperationID,
                @IintRowStatus = IintRowStatus,
                @IintRowStatusForSystemFunction = IintRowStatusForSystemFunction
            FROM #Output2;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_LkupRoleSystemFunctionAccess, 51586990000070,
					@DSystemFunctionID,@DSystemFunctionOperationID,
					@DintRowStatus,@IintRowStatus
				--from #Output2
				where (@DintRowStatus <> @IintRowStatus) 
					or(@DintRowStatus is not null and @IintRowStatus is null)
					or(@DintRowStatus is null and @IintRowStatus is not null)

				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_LkupRoleSystemFunctionAccess, 51586990000071,
					@DSystemFunctionID,@DSystemFunctionOperationID,
					@DintRowStatusForSystemFunction,@IintRowStatusForSystemFunction
				--from #Output2
				where (@DintRowStatusForSystemFunction <> @IintRowStatusForSystemFunction) 
					or(@DintRowStatusForSystemFunction is not null and @IintRowStatusForSystemFunction is null)
					or(@DintRowStatusForSystemFunction is null and @IintRowStatusForSystemFunction is not null)

            END

            DELETE FROM #Output2
            WHERE	DidfEmployee = @DidfEmployee AND
					DSystemFunctionID = @DSystemFunctionID AND
					DSystemFunctionOperationID = @DSystemFunctionOperationID;
        END

		INSERT INTO #OutputI
		SELECT *
		FROM #Output
		Where ActionTaken = 'INSERT'

        WHILE EXISTS (SELECT * FROM #OutputI)
        BEGIN

            SELECT TOP 1 
                @DidfEmployee = DidfEmployee,
                @DSystemFunctionID = DSystemFunctionID,
                @DSystemFunctionOperationID = DSystemFunctionOperationID,
                @DintRowStatus = DintRowStatus,
                @DintRowStatusForSystemFunction = DintRowStatusForSystemFunction,
                @IidfEmployee = IidfEmployee,
                @ISystemFunctionID = ISystemFunctionID,
                @ISystemFunctionOperationID = ISystemFunctionOperationID,
                @IintRowStatus = IintRowStatus,
                @IintRowStatusForSystemFunction = IintRowStatusForSystemFunction
            FROM #OutputI;
            BEGIN

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
						values ( @idfDataAuditEvent, @idfObjectTable_LkupRoleSystemFunctionAccess, @ISystemFunctionID, @ISystemFunctionOperationID)
            END

            DELETE FROM #OutputI
            WHERE	IidfEmployee = @IidfEmployee AND
					ISystemFunctionID = @ISystemFunctionID AND
					ISystemFunctionOperationID = @ISystemFunctionOperationID;
        END
		--Data Audit--

		IF @@TRANCOUNT > 0
			COMMIT

		SELECT @returnCode 'ReturnCode',@returnMsg 'ReturnMessage'
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END

		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage;
	END CATCH
END

