
-- ================================================================================================
-- Name: USSP_HAS_MONITORING_SESSION_ACTION_SET
--
-- Description:	Inserts or updates monitoring session action for the human module monitoring 
-- session enter and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- Leo Tracchia		12/5/2022	Added logic for data auditing
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HAS_MONITORING_SESSION_ACTION_SET] (
	@LanguageID NVARCHAR(50),
	@DataAuditEventID BIGINT = NULL,
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

		--Data Audit--

		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		--DECLARE @idfsDataAuditEventType bigint = NULL;	
		DECLARE @idfObject bigint = @MonitoringSessionActionID;
		DECLARE @idfObjectTable_tlbMonitoringSessionAction BIGINT = 708220000000;
		DECLARE @idfDataAuditEvent bigint = NULL;	

		DECLARE @MonitoringSessionActionBeforeEdit TABLE
		(			
			idfMonitoringSessionAction bigint,
			idfMonitoringSession bigint,
			idfPersonEnteredBy bigint,
			idfsMonitoringSessionActionType bigint,
			idfsMonitoringSessionActionStatus bigint,
			datActionDate datetime,
			strComments nvarchar(500),
			intRowStatus int			
		);

		DECLARE @MonitoringSessionActionAfterEdit TABLE
		(
			idfMonitoringSessionAction bigint,
			idfMonitoringSession bigint,
			idfPersonEnteredBy bigint,
			idfsMonitoringSessionActionType bigint,
			idfsMonitoringSessionActionStatus bigint,
			datActionDate datetime,
			strComments nvarchar(500),
			intRowStatus int
		);

		--End Data Audit--

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

			-- Data audit
			INSERT INTO @MonitoringSessionActionBeforeEdit
            (
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments,
				intRowStatus
            )
            SELECT 
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments,
				intRowStatus
            FROM dbo.tlbMonitoringSessionAction
            WHERE idfMonitoringSessionAction = @MonitoringSessionActionID;
			-- End Data audit

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

			-- Data audit
			INSERT INTO @MonitoringSessionActionAfterEdit
            (
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments,
				intRowStatus
            )
            SELECT 
				idfMonitoringSessionAction,
				idfMonitoringSession,
				idfPersonEnteredBy,
				idfsMonitoringSessionActionType,
				idfsMonitoringSessionActionStatus,
				datActionDate,
				strComments,
				intRowStatus
            FROM dbo.tlbMonitoringSessionAction
            WHERE idfMonitoringSessionAction = @MonitoringSessionActionID;
			-- End Data audit

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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708240000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfMonitoringSession,
				b.idfMonitoringSession 
			from @MonitoringSessionActionBeforeEdit a inner join @MonitoringSessionActionAfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708250000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfPersonEnteredBy,
				b.idfPersonEnteredBy 
			from @MonitoringSessionActionBeforeEdit a inner join @MonitoringSessionActionAfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708260000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfsMonitoringSessionActionType,
				b.idfsMonitoringSessionActionType 
			from @MonitoringSessionActionBeforeEdit a inner join @MonitoringSessionActionAfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708270000000,
				a.idfMonitoringSessionAction,
				null,
				a.idfsMonitoringSessionActionStatus,
				b.idfsMonitoringSessionActionStatus 
			from @MonitoringSessionActionBeforeEdit a inner join @MonitoringSessionActionAfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708280000000,
				a.idfMonitoringSessionAction,
				null,
				a.datActionDate,
				b.datActionDate 
			from @MonitoringSessionActionBeforeEdit a inner join @MonitoringSessionActionAfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionAction, 
				708290000000,
				a.idfMonitoringSessionAction,
				null,
				a.strComments,
				b.strComments 
			from @MonitoringSessionActionBeforeEdit a inner join @MonitoringSessionActionAfterEdit b on a.idfMonitoringSessionAction = b.idfMonitoringSessionAction
			where (a.strComments <> b.strComments) 
				or(a.strComments is not null and b.strComments is null)
				or(a.strComments is null and b.strComments is not null)


		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
