
-- ================================================================================================
-- Name: USSP_VAS_MONITORING_SESSION_ACTION_SET
--
-- Description:	Inserts or updates monitoring session action for the human module monitoring 
-- session enter and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay    02/06/2022 Initial release. (Copied from USSP_HAS_MONITORING_SESSION_ACTION_SET)
-- Mike Kornegay    02/14/2022 Change RowAction from nvarchar to int.
-- Leo Tracchia		12/14/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VAS_MONITORING_SESSION_ACTION_SET] (
	@MonitoringSessionActionID BIGINT OUTPUT,
	@DataAuditEventID BIGINT = NULL,
	@MonitoringSessionID BIGINT,
	@EnteredByPersonID BIGINT,
	@MonitoringSessionActionTypeID BIGINT,
	@MonitoringSessionActionStatusTypeID BIGINT,
	@ActionDate DATETIME = NULL,
	@Comments NVARCHAR(500) = NULL,
	@RowStatus INT,
	@RowAction INT, 
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		--Data Audit--

		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017062; --select * from trtBaseReference where strDefault = 'Veterinary Active Surveillance Session'
		DECLARE @idfObject bigint = @MonitoringSessionActionID;
		DECLARE @idfObjectTable_tlbMonitoringSessionAction bigint = 708220000000; --select * from tauTable where strName = 'tlbMonitoringSessionToMaterial'				

		DECLARE @tlbMonitoringSessionAction_BeforeEdit TABLE
		(
			idfMonitoringSessionAction bigint,
			idfMonitoringSession bigint,
			idfPersonEnteredBy bigint,
			idfsMonitoringSessionActionType bigint,
			idfsMonitoringSessionActionStatus bigint,
			datActionDate datetime,
			strComments nvarchar(500)
		)		

		DECLARE @tlbMonitoringSessionAction_AfterEdit TABLE
		(
			idfMonitoringSessionAction bigint,
			idfMonitoringSession bigint,
			idfPersonEnteredBy bigint,
			idfsMonitoringSessionActionType bigint,
			idfsMonitoringSessionActionStatus bigint,
			datActionDate datetime,
			strComments nvarchar(500)
		)		

		-- Data Audit

		IF @RowAction = 1 --INSERT
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

			-- Data audit
				INSERT INTO dbo.tauDataAuditDetailCreate
				(
					idfDataAuditEvent,
					idfObjectTable,
					idfObject,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser
				)
				VALUES
				(
					@DataAuditEventID, 
					@idfObjectTable_tlbMonitoringSessionAction, 
					@MonitoringSessionActionID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionAction AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

		END
		ELSE
		BEGIN

			INSERT INTO @tlbMonitoringSessionAction_BeforeEdit (
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments
			)
			SELECT 
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments
			FROM tlbMonitoringSessionAction WHERE idfMonitoringSessionAction = @MonitoringSessionActionID;

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

			INSERT INTO @tlbMonitoringSessionAction_AfterEdit (
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments
			)
			SELECT 
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments
			FROM tlbMonitoringSessionAction WHERE idfMonitoringSessionAction = @MonitoringSessionActionID;

			--idfMonitoringSession
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708240000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfMonitoringSession,
				b.idfMonitoringSession 
			from @tlbMonitoringSessionAction_BeforeEdit a  inner join @tlbMonitoringSessionAction_AfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.idfMonitoringSession <> b.idfMonitoringSession) 
				or(a.idfMonitoringSession is not null and b.idfMonitoringSession is null)
				or(a.idfMonitoringSession is null and b.idfMonitoringSession is not null)

			--idfPersonEnteredBy
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708250000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfPersonEnteredBy,
				b.idfPersonEnteredBy 
			from @tlbMonitoringSessionAction_BeforeEdit a  inner join @tlbMonitoringSessionAction_AfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.idfPersonEnteredBy <> b.idfPersonEnteredBy) 
				or(a.idfPersonEnteredBy is not null and b.idfPersonEnteredBy is null)
				or(a.idfPersonEnteredBy is null and b.idfPersonEnteredBy is not null)

			--idfsMonitoringSessionActionType
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708260000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfsMonitoringSessionActionType,
				b.idfsMonitoringSessionActionType 
			from @tlbMonitoringSessionAction_BeforeEdit a  inner join @tlbMonitoringSessionAction_AfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.idfsMonitoringSessionActionType <> b.idfsMonitoringSessionActionType) 
				or(a.idfsMonitoringSessionActionType is not null and b.idfsMonitoringSessionActionType is null)
				or(a.idfsMonitoringSessionActionType is null and b.idfsMonitoringSessionActionType is not null)

			--idfsMonitoringSessionActionStatus
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708270000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfsMonitoringSessionActionStatus,
				b.idfsMonitoringSessionActionStatus 
			from @tlbMonitoringSessionAction_BeforeEdit a  inner join @tlbMonitoringSessionAction_AfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.idfsMonitoringSessionActionStatus <> b.idfsMonitoringSessionActionStatus) 
				or(a.idfsMonitoringSessionActionStatus is not null and b.idfsMonitoringSessionActionStatus is null)
				or(a.idfsMonitoringSessionActionStatus is null and b.idfsMonitoringSessionActionStatus is not null)

			--datActionDate
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708280000000,
				a.idfMonitoringSessionAction,
				null,
				a.datActionDate,
				b.datActionDate 
			from @tlbMonitoringSessionAction_BeforeEdit a  inner join @tlbMonitoringSessionAction_AfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.datActionDate <> b.datActionDate) 
				or(a.datActionDate is not null and b.datActionDate is null)
				or(a.datActionDate is null and b.datActionDate is not null)

			--strComments
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708290000000,
				a.idfMonitoringSessionAction,
				null,
				a.strComments,
				b.strComments 
			from @tlbMonitoringSessionAction_BeforeEdit a  inner join @tlbMonitoringSessionAction_AfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.strComments <> b.strComments) 
				or(a.strComments is not null and b.strComments is null)
				or(a.strComments is null and b.strComments is not null)
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
