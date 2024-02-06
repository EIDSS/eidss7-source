
-- ================================================================================================
-- Name: USSP_VAS_MONITORING_SESSION_TO_SAMPLE_TYPE_SET
--
-- Description:	Inserts or updates monitoring session to sample type for the human module 
-- monitoring session set up and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay    02/07/2022 Initial release.
-- Mike Kornegay	02/14/2022 Change RowAction from nvarchar to int.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VAS_MONITORING_SESSION_TO_SAMPLE_TYPE_SET] (
	@MonitoringSessionToSampleTypeID BIGINT,
	@MonitoringSessionID BIGINT,
	@OrderNumber INT,
	@RowStatus INT,
	@SampleTypeID BIGINT = NULL,
	@RowAction INT, 
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @RowAction = 1 --INSERT
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
		END;
		ELSE
		BEGIN
			UPDATE dbo.MonitoringSessionToSampleType
			SET idfMonitoringSession = @MonitoringSessionID,
				intOrder = @OrderNumber,
				intRowStatus = @RowStatus,
				idfsSampleType = @SampleTypeID, 
				AuditUpdateUser = @AuditUserName 
			WHERE MonitoringSessionToSampleType = @MonitoringSessionToSampleTypeID;
		END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
