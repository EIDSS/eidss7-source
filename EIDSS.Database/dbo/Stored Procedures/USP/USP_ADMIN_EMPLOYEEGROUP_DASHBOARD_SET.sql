-- ===============================================================================================================
-- NAME:					USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
-- DESCRIPTION:				Creates or reactivates a relationship between role and dashboard item
-- AUTHOR:					Ricky Moss
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			12/04/2019	Initial Release
-- Ann Xiong			05/26/2021	Changed RoleID to idfEmployee to fix issue caused by table LkupRoleDashboardObject column name change
-- Ann Xiong			04/25/2023 Implemented Data Audit and added parameter @idfDataAuditEvent	
--
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET]
(
	@roleID BIGINT,
	@strDashboardObject NVARCHAR(1000),
    @idfDataAuditEvent BIGINT = NULL,
	@user NVARCHAR(50)
)
AS
DECLARE @returnCode			INT				= 0 
DECLARE	@returnMsg			NVARCHAR(MAX)	= 'SUCCESS' 
DECLARE @SupressSelect TABLE (retrunCode INT, returnMessage VARCHAR(200))
DECLARE @tempDashboardObjectID TABLE  (DashboardObjectID BIGINT)
DECLARE @DashboardObject BIGINT

		--Data Audit--
		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017058; 					-- User Group --
		DECLARE @idfObject bigint = @roleID;
		DECLARE @idfObjectTable_LkupRoleDashboardObject bigint = 53577790000012;
		--DECLARE @idfDataAuditEvent BIGINT = NULL;

		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@user) userInfo
		--Data Audit--

BEGIN
	BEGIN TRY
		INSERT INTO @tempDashboardObjectID SELECT VALUE AS DashboardObjectID FROM STRING_SPLIT(@strDashboardObject,',');
		UPDATE LkupRoleDashboardObject SET intRowStatus = 1 WHERE idfEmployee = @roleID AND intRowStatus = 0

      IF @idfDataAuditEvent IS NOT NULL
      BEGIN 
        -- data audit
		DECLARE @DashboardObjectID bigint = NULL;
		DECLARE @DashboardObjectIDsToDelete TABLE
        (
            DashboardObjectID BIGINT NOT NULL
        );

        INSERT INTO @DashboardObjectIDsToDelete
        SELECT DashboardObjectID
	    FROM dbo.LkupRoleDashboardObject
		WHERE idfEmployee = @roleID AND intRowStatus = 0

        WHILE EXISTS (SELECT * FROM @DashboardObjectIDsToDelete)
        BEGIN
            SELECT TOP 1
                @DashboardObjectID = DashboardObjectID
            FROM @DashboardObjectIDsToDelete;
            BEGIN
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
					SELECT @idfDataAuditEvent, @idfObjectTable_LkupRoleDashboardObject, @roleID, @DashboardObjectID
            END

            DELETE FROM @DashboardObjectIDsToDelete
            WHERE DashboardObjectID = @DashboardObjectID;
        END
        -- End data audit
	  END

		WHILE(SELECT COUNT(DashboardObjectID) FROM @tempDashboardObjectID) > 0
		BEGIN
			SELECT @DashboardObject = (SELECT TOP 1 (DashboardObjectID) FROM @tempDashboardObjectID)
			IF EXISTS(SELECT DashboardObjectID FROM LkupRoleDashboardObject WHERE DashboardObjectID = @DashboardObject AND idfEmployee = @roleID)
			BEGIN
				--Data Audit--
				DECLARE @intRowStatusOld INT = NULL;
 				SELECT @intRowStatusOld = intRowStatus FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @roleID AND DashboardObjectID = @DashboardObject;
 				--Data Audit--

				UPDATE LkupRoleDashboardObject SET intRowStatus = 0  WHERE idfEmployee = @roleID AND DashboardObjectID = @DashboardObject

				IF @idfDataAuditEvent IS NOT NULL
				BEGIN 
				--Data Audit--
				insert into dbo.tauDataAuditDetailUpdate(
							idfDataAuditEvent, idfObjectTable, idfColumn, 
							idfObject, idfObjectDetail, 
							strOldValue, strNewValue)
				select		@idfDataAuditEvent,@idfObjectTable_LkupRoleDashboardObject, 51586990000121,
							@roleID,@DashboardObject,
							@intRowStatusOld,0
				 WHERE (@intRowStatusOld <> 0)
				--Data Audit--
				END
			END
			ELSE
			BEGIN
				INSERT INTO LkupRoleDashboardObject (idfEmployee, DashboardObjectID, intRowStatus) VALUES (@roleID, @DashboardObject, 0)

				IF @idfDataAuditEvent IS NOT NULL
				BEGIN 
				--Data Audit--
				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
						values ( @idfDataAuditEvent, @idfObjectTable_LkupRoleDashboardObject, @roleID, @DashboardObject)
				--Data Audit--
				END
			END
			DELETE FROM @tempDashboardObjectID WHERE DashboardObjectID = @DashboardObject
		END
		SELECT @returnCode ReturnCode, @returnMsg as ReturnMessage
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

