
-- =================================================================================================================
-- NAME:				USP_ADMIN_EMPLOYEEGROUP_DEL
-- DESCRIPTION:			Deactivates a role given an identifier
-- AUTHOR:				Ricky Moss
-- 
-- HISTORY OF CHANGES:	
-- NAME:			DATE:			DESCRIPTION OF CHANGE
-- -----------------------------------------------------------------------------------------------------------------
-- Ricky Moss		11/29/2019		Initial Release
-- Ann Xiong		12/03/2020		Modified to use @roleName instead of @roleID to update LkupRoleSystemFunctionAccess
-- Ann Xiong		05/26/2021		Changed RoleID to idfEmployee to fix issue caused by table LkupRoleSystemFunctionAccess column name change
-- Mark Wilson		09/14/2022 		updated to include auditupdatedtm and auditupdateuser
-- Ann Xiong		02/28/2023		Implemented Data Audit
-- Ann Xiong		03/01/2023		Added @idfsSite to parameter list and Used @roleID instead of @roleName for conditions
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DEL -500, 58218970000257, NULL
-- =================================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_DEL]
(
	@roleID BIGINT,
	@roleName BIGINT,
	@idfsSite BIGINT,
	@user NVARCHAR(50)
)
AS
	DECLARE @returnCode INT = 0
	DECLARE @returnMsg  NVARCHAR(50) = 'SUCCESS'

	--Data Audit--
	declare @idfUserId BIGINT = NULL;
	declare @idfSiteId BIGINT = NULL;
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017058;                         -- User Group
	declare @idfObject bigint = @roleID;
	declare @idfDataAuditEvent bigint= NULL;
	declare @idfObjectTable_tlbEmployeeGroup bigint = 75530000000;
	declare @idfObjectTable_trtBaseReference BIGINT = 75820000000;
	declare @idfObjectTable_tlbEmployeeGroupMember bigint = 75540000000;
	declare @idfObjectTable_trtStringNameTranslation bigint = 75990000000;

	-- Get and Set UserId and SiteId
	select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@user) userInfo

	--Data Audit--

BEGIN
	BEGIN TRY
		--Data Audit

		-- tauDataAuditEvent Event Type - Delete
		set @idfsDataAuditEventType =10016002;

		-- insert record into tauDataAuditEvent
		EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbEmployeeGroup, @idfDataAuditEvent OUTPUT
		-- End data audit

		UPDATE dbo.LkupRoleSystemFunctionAccess 
		SET intRowStatus = 1,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @user
		WHERE idfEmployee = @roleID

		UPDATE dbo.tlbEmployeeGroupMember 
		SET intRowStatus = 1,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @user
		WHERE idfEmployee = @roleID

		--Data Audit
		INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroupMember, @roleName
		-- End data audit

		UPDATE dbo.trtBaseReference 
		SET intRowStatus = 1,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @user
		WHERE idfsBaseReference = @roleID

				--Data Audit
		INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_trtBaseReference, @roleName
		-- End data audit

		UPDATE dbo.tlbEmployeeGroup 
		SET intRowStatus = 1,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @user
		WHERE idfEmployeeGroup = @roleID AND idfsSite = @idfsSite	

		--Data Audit
		INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroup, @roleID
		-- End data audit

		UPDATE dbo.trtStringNameTranslation 
		SET intRowStatus = 1,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @user
		WHERE idfsBaseReference = @roleID

		--Data Audit
		INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_trtStringNameTranslation, @roleName
		-- End data audit

		--SELECT @returnCode AS 'returnCode', @returnMsg AS 'returnMessage'
		SELECT
			 @returnCode ReturnCode, 
			 @returnMsg AS ReturnMessage
	END TRY

	BEGIN CATCH
		THROW

	END CATCH

END

