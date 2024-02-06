-- ================================================================================================
-- Name: USSP_VCT_MONITORING_SESSION_ACTION_SET
--
-- Description:	Inserts or updates monitoring session action for the human and veterinary modules 
-- monitoring session enter and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/07/2018 Initial release.
-- Stephen Long     04/30/2019 Modified for new API; removed maintenance flag.
-- Stephen Long     06/24/2019 Add audit user name.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VCT_MONITORING_SESSION_ACTION_SET] (
	@LanguageID NVARCHAR(50),
	@MonitoringSessionActionID BIGINT OUTPUT,
	@MonitoringSessionID BIGINT,
	@EnteredByPersonID BIGINT,
	@MonitoringSessionActionTypeID BIGINT,
	@MonitoringSessionActionStatusTypeID BIGINT,
	@ActionDate DATETIME = NULL,
	@Comments NVARCHAR(500) = NULL,
	@RowStatus INT,
	@RowAction NCHAR, 
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @RowAction = 'I'
		BEGIN
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbMonitoringSessionAction',
				@MonitoringSessionActionID OUTPUT;

			INSERT INTO dbo.tlbMonitoringSessionAction (
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments,
				intRowStatus, 
				AuditCreateUser
				)
			VALUES (
				@MonitoringSessionActionID,
				@MonitoringSessionID,
				@EnteredByPersonID,
				@MonitoringSessionActionTypeID,
				@MonitoringSessionActionStatusTypeID,
				@ActionDate,
				@Comments,
				@RowStatus,
				@AuditUserName
				);
		END
		ELSE
		BEGIN
			UPDATE dbo.tlbMonitoringSessionAction
			SET idfMonitoringSession = @MonitoringSessionID,
				idfPersonEnteredBy = @EnteredByPersonID,
				idfsMonitoringSessionActionType = @MonitoringSessionActionTypeID,
				idfsMonitoringSessionActionStatus = @MonitoringSessionActionStatusTypeID,
				datActionDate = @ActionDate,
				strComments = @Comments,
				intRowStatus = @RowStatus, 
				AuditUpdateUser = @AuditUserName
			WHERE idfMonitoringSessionAction = @MonitoringSessionActionID;
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
