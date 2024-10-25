
-- ================================================================================================
-- Name: USSP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_SET
--
-- Description:	Inserts or updates monitoring session to sample type for the human module 
-- monitoring session set up and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- Leo Tracchia		12/5/2022	Added logic for data auditing
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_SET] (
	@LanguageID NVARCHAR(50),
	@DataAuditEventID BIGINT = NULL,
	@MonitoringSessionToSampleTypeID BIGINT,
	@MonitoringSessionID BIGINT,
	@OrderNumber INT,
	@RowStatus INT,
	@SampleTypeID BIGINT = NULL,
	@RowAction CHAR(1), 
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
		DECLARE @idfObject bigint = @MonitoringSessionToSampleTypeID;
		DECLARE @idfObjectTable_MonitoringSessionToSampleType BIGINT = 53577790000002;
		DECLARE @idfDataAuditEvent bigint = NULL;	

		DECLARE @MonitoringSessionToSampleTypeBeforeEdit TABLE
		(			
			MonitoringSessionToSampleType bigint,
			idfMonitoringSession bigint,
			intOrder int,
			intRowStatus int,
			idfsSampleType bigint			
		);

		DECLARE @MonitoringSessionToSampleTypeAfterEdit TABLE
		(
			MonitoringSessionToSampleType bigint,
			idfMonitoringSession bigint,
			intOrder int,
			intRowStatus int,
			idfsSampleType bigint
		);

		--End Data Audit--

		IF @RowAction = 'I'
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'MonitoringSessionToSampleType',
				@MonitoringSessionToSampleTypeID OUTPUT;

			INSERT INTO dbo.MonitoringSessionToSampleType (
				MonitoringSessionToSampleType,
				idfMonitoringSession,
				intOrder,
				intRowStatus,
				idfsSampleType, 
				AuditCreateUser
				)
			VALUES (
				@MonitoringSessionToSampleTypeID,
				@MonitoringSessionID,
				@OrderNumber,
				@RowStatus,
				@SampleTypeID, 
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
				@idfObjectTable_MonitoringSessionToSampleType, 
				@MonitoringSessionToSampleTypeID, 
				10519001,
				'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
				+ ',"idfObjectTable":' + CAST(@idfObjectTable_MonitoringSessionToSampleType AS NVARCHAR(300)) + '}]',
				@AuditUserName
			);
			-- End data audit

		END;
		ELSE
		BEGIN

			-- Data audit

			INSERT INTO @MonitoringSessionToSampleTypeBeforeEdit
            (
				MonitoringSessionToSampleType,
				idfMonitoringSession,
				intOrder,
				intRowStatus,
				idfsSampleType
            )
            SELECT 
				MonitoringSessionToSampleType,
				idfMonitoringSession,
				intOrder,
				intRowStatus,
				idfsSampleType
            FROM dbo.MonitoringSessionToSampleType
            WHERE MonitoringSessionToSampleType = @MonitoringSessionToSampleTypeID;

			-- End Data audit

			UPDATE dbo.MonitoringSessionToSampleType
			SET idfMonitoringSession = @MonitoringSessionID,
				intOrder = @OrderNumber,
				intRowStatus = @RowStatus,
				idfsSampleType = @SampleTypeID, 
				AuditUpdateUser = @AuditUserName 
			WHERE MonitoringSessionToSampleType = @MonitoringSessionToSampleTypeID;

			-- Data audit

			INSERT INTO @MonitoringSessionToSampleTypeAfterEdit
            (
				MonitoringSessionToSampleType,
				idfMonitoringSession,
				intOrder,
				intRowStatus,
				idfsSampleType
            )
            SELECT 
				MonitoringSessionToSampleType,
				idfMonitoringSession,
				intOrder,
				intRowStatus,
				idfsSampleType
            FROM dbo.MonitoringSessionToSampleType
            WHERE MonitoringSessionToSampleType = @MonitoringSessionToSampleTypeID;

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
				@idfObjectTable_MonitoringSessionToSampleType, 
				51586990000018,
				a.MonitoringSessionToSampleType,
				null,
				a.idfMonitoringSession,
				b.idfMonitoringSession 
			from @MonitoringSessionToSampleTypeBeforeEdit a inner join @MonitoringSessionToSampleTypeAfterEdit b on a.MonitoringSessionToSampleType = b.MonitoringSessionToSampleType
			where (a.idfMonitoringSession <> b.idfMonitoringSession) 
				or(a.idfMonitoringSession is not null and b.idfMonitoringSession is null)
				or(a.idfMonitoringSession is null and b.idfMonitoringSession is not null)

			--intOrder 
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
				@idfObjectTable_MonitoringSessionToSampleType, 
				51586990000019,
				a.MonitoringSessionToSampleType,
				null,
				a.intOrder,
				b.intOrder 
			from @MonitoringSessionToSampleTypeBeforeEdit a inner join @MonitoringSessionToSampleTypeAfterEdit b on a.MonitoringSessionToSampleType = b.MonitoringSessionToSampleType
			where (a.intOrder <> b.intOrder) 
				or(a.intOrder is not null and b.intOrder is null)
				or(a.intOrder is null and b.intOrder is not null)

			--intRowStatus 
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
				@idfObjectTable_MonitoringSessionToSampleType, 
				51586990000020,
				a.MonitoringSessionToSampleType,
				null,
				a.intRowStatus,
				b.intRowStatus 
			from @MonitoringSessionToSampleTypeBeforeEdit a inner join @MonitoringSessionToSampleTypeAfterEdit b on a.MonitoringSessionToSampleType = b.MonitoringSessionToSampleType
			where (a.intRowStatus <> b.intRowStatus) 
				or(a.intRowStatus is not null and b.intRowStatus is null)
				or(a.intRowStatus is null and b.intRowStatus is not null)

			--idfsSampleType 
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
				@idfObjectTable_MonitoringSessionToSampleType, 
				51586990000021,
				a.MonitoringSessionToSampleType,
				null,
				a.idfsSampleType,
				b.idfsSampleType 
			from @MonitoringSessionToSampleTypeBeforeEdit a inner join @MonitoringSessionToSampleTypeAfterEdit b on a.MonitoringSessionToSampleType = b.MonitoringSessionToSampleType
			where (a.idfsSampleType <> b.idfsSampleType) 
				or(a.idfsSampleType is not null and b.idfsSampleType is null)
				or(a.idfsSampleType is null and b.idfsSampleType is not null)

			-- End Data audit



		END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
