


-- ================================================================================================
-- Name: USSP_HAS_MonitoringSessionToDiagnosis_SET
--
-- Description:	Inserts or updates monitoring session to disease for the human module 
-- monitoring session set up and edit use cases.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Stephen Long     07/06/2019	Initial release.
-- Mark Wilson		08/19/2021	Updated to use tlbMonitoringSessionToDiagnosis and renamed to USSP_HAS_MonitoringSessionToDiagnosis_SET
-- Doug Albanese	03/25/2022	Updated to make use of "RowAction"
-- Leo Tracchia		12/5/2022	Added logic for data auditing
-- Leo Tracchia		12/12/2022	big fix for @DataAuditEventID
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HAS_MonitoringSessionToDiagnosis_SET] (
	@LanguageID NVARCHAR(50),
	@DataAuditEventID BIGINT = NULL,
	@idfMonitoringSessionToDiagnosis BIGINT OUTPUT,
	@idfMonitoringSession BIGINT,
	@idfsDisease BIGINT, 
	@intOrder INT,
	@idfsSpeciesType INT = NULL,
	@idfsSampleType BIGINT = NULL,
	@Comments NVARCHAR(MAX) = NULL,
	@AuditUserName NVARCHAR(200),
	@RowAction	CHAR(1) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		--Data Audit--

		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;	
		DECLARE @idfObject bigint = @idfMonitoringSessionToDiagnosis;
		DECLARE @idfObjectTable_tlbMonitoringSessionToDiagnosis BIGINT = 707150000000;			

		DECLARE @MonitoringSessionToDiagnosisBeforeEdit TABLE
		(			
			idfMonitoringSessionToDiagnosis bigint,
			idfMonitoringSession bigint,
			idfsDiagnosis bigint,
			intOrder int,
			intRowStatus int,
			idfsSpeciesType bigint,
			idfsSampleType bigint,			
			Comments nvarchar(2000)			
		);

		DECLARE @MonitoringSessionToDiagnosisAfterEdit TABLE
		(
			idfMonitoringSessionToDiagnosis bigint,
			idfMonitoringSession bigint,
			idfsDiagnosis bigint,
			intOrder int,
			intRowStatus int,
			idfsSpeciesType bigint,
			idfsSampleType bigint,			
			Comments nvarchar(2000)		
		);

		--End Data Audit--

		DECLARE	@intRowStatus INT = 0

		IF NOT EXISTS (SELECT * FROM dbo.tlbMonitoringSessionToDiagnosis WHERE idfMonitoringSessionToDiagnosis = @idfMonitoringSessionToDiagnosis)
			BEGIN
				EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
					'tlbMonitoringSessionToDiagnosis',
					@idfMonitoringSessionToDiagnosis OUTPUT;

				INSERT INTO dbo.tlbMonitoringSessionToDiagnosis 
				(
					idfMonitoringSessionToDiagnosis,
					idfMonitoringSession,
					idfsDiagnosis, 
					intOrder,
					intRowStatus,
					idfsSpeciesType,
					idfsSampleType,
					SourceSystemNameID,
					SourceSystemKeyValue,
					Comments,
					AuditCreateUser,
					AuditCreateDTM,
					AuditUpdateUser,
					AuditUpdateDTM
					)
				VALUES
				(
					@idfMonitoringSessionToDiagnosis,
					@idfMonitoringSession,
					@idfsDisease,
					@intOrder,
					0,
					@idfsSpeciesType,
					@idfsSampleType,
					10519001,
					'[{"idfMonitoringSessionToDiagnosis":' + CAST(@idfMonitoringSessionToDiagnosis AS NVARCHAR(300)) + '}]',
					@Comments,
					@AuditUserName,
					GETDATE(),
					@AuditUserName,
					GETDATE()
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
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					@idfMonitoringSessionToDiagnosis, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionToDiagnosis AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
				-- End data audit

			END;
		ELSE
			BEGIN
				IF @RowAction = 'D'
					BEGIN
						SET @intRowStatus = 1
					END
				ELSE
					BEGIN
						SET @intRowStatus = 0
					END

				-- Data audit

				INSERT INTO @MonitoringSessionToDiagnosisBeforeEdit
                (
					idfMonitoringSessionToDiagnosis,
					idfMonitoringSession,
					idfsDiagnosis,
					intOrder,
					intRowStatus,
					idfsSpeciesType,
					idfsSampleType,
					Comments
                )
                SELECT 
					idfMonitoringSessionToDiagnosis,
					idfMonitoringSession,
					idfsDiagnosis,
					intOrder,
					intRowStatus,
					idfsSpeciesType,
					idfsSampleType,
					Comments                     
                FROM dbo.tlbMonitoringSessionToDiagnosis
                WHERE idfMonitoringSessionToDiagnosis = @idfMonitoringSessionToDiagnosis;

				-- End Data audit

				UPDATE dbo.tlbMonitoringSessionToDiagnosis
				SET idfMonitoringSession = @idfMonitoringSession,
					idfsDiagnosis = @idfsDisease,
					intOrder = @intOrder,
					intRowStatus = @intRowStatus,
					idfsSpeciesType = @idfsSpeciesType,
					idfsSampleType = @idfsSampleType,
					SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
					SourceSystemKeyValue = '[{"idfCampaignToDiagnosis":' + CAST(@idfMonitoringSessionToDiagnosis AS NVARCHAR(300)) + '}]',
					Comments = @Comments,
					AuditUpdateUser = @AuditUserName,
					AuditUpdateDTM = GETDATE()				
				WHERE idfMonitoringSessionToDiagnosis = @idfMonitoringSessionToDiagnosis;

				-- Data audit

				INSERT INTO @MonitoringSessionToDiagnosisAfterEdit
                (
					idfMonitoringSessionToDiagnosis,
					idfMonitoringSession,
					idfsDiagnosis,
					intOrder,
					intRowStatus,
					idfsSpeciesType,
					idfsSampleType,
					Comments
                )
                SELECT 
					idfMonitoringSessionToDiagnosis,
					idfMonitoringSession,
					idfsDiagnosis,
					intOrder,
					intRowStatus,
					idfsSpeciesType,
					idfsSampleType,
					Comments                     
                FROM dbo.tlbMonitoringSessionToDiagnosis
                WHERE idfMonitoringSessionToDiagnosis = @idfMonitoringSessionToDiagnosis;

				--idfMonitoringSessionToDiagnosis 
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
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					749060000000,
					a.idfMonitoringSessionToDiagnosis,
					null,
					a.idfMonitoringSessionToDiagnosis,
					b.idfMonitoringSessionToDiagnosis 
				from @MonitoringSessionToDiagnosisBeforeEdit a inner join @MonitoringSessionToDiagnosisAfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
				where (a.idfMonitoringSessionToDiagnosis <> b.idfMonitoringSessionToDiagnosis) 
					or(a.idfMonitoringSessionToDiagnosis is not null and b.idfMonitoringSessionToDiagnosis is null)
					or(a.idfMonitoringSessionToDiagnosis is null and b.idfMonitoringSessionToDiagnosis is not null)

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
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					707160000000,
					a.idfMonitoringSessionToDiagnosis,
					null,
					a.idfMonitoringSession,
					b.idfMonitoringSession 
				from @MonitoringSessionToDiagnosisBeforeEdit a inner join @MonitoringSessionToDiagnosisAfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
				where (a.idfMonitoringSession <> b.idfMonitoringSession) 
					or(a.idfMonitoringSession is not null and b.idfMonitoringSession is null)
					or(a.idfMonitoringSession is null and b.idfMonitoringSession is not null)
					
				--idfsDiagnosis 
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
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					707170000000,
					a.idfMonitoringSessionToDiagnosis,
					null,
					a.idfsDiagnosis,
					b.idfsDiagnosis 
				from @MonitoringSessionToDiagnosisBeforeEdit a inner join @MonitoringSessionToDiagnosisAfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
				where (a.idfsDiagnosis <> b.idfsDiagnosis) 
					or(a.idfsDiagnosis is not null and b.idfsDiagnosis is null)
					or(a.idfsDiagnosis is null and b.idfsDiagnosis is not null)

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
					@DataAuditEventID,
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					51586590000000,
					a.idfMonitoringSessionToDiagnosis,
					null,
					a.idfsSampleType,
					b.idfsSampleType 
				from @MonitoringSessionToDiagnosisBeforeEdit a inner join @MonitoringSessionToDiagnosisAfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
				where (a.idfsSampleType <> b.idfsSampleType) 
					or(a.idfsSampleType is not null and b.idfsSampleType is null)
					or(a.idfsSampleType is null and b.idfsSampleType is not null)

				--idfsSpeciesType 
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
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					4578860000000,
					a.idfMonitoringSessionToDiagnosis,
					null,
					a.idfsSpeciesType,
					b.idfsSpeciesType 
				from @MonitoringSessionToDiagnosisBeforeEdit a inner join @MonitoringSessionToDiagnosisAfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
				where (a.idfsSpeciesType <> b.idfsSpeciesType) 
					or(a.idfsSpeciesType is not null and b.idfsSpeciesType is null)
					or(a.idfsSpeciesType is null and b.idfsSpeciesType is not null)

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
					@DataAuditEventID,
					@idfObjectTable_tlbMonitoringSessionToDiagnosis, 
					707180000000,
					a.idfMonitoringSessionToDiagnosis,
					null,
					a.intOrder,
					b.intOrder 
				from @MonitoringSessionToDiagnosisBeforeEdit a inner join @MonitoringSessionToDiagnosisAfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
				where (a.intOrder <> b.intOrder) 
					or(a.intOrder is not null and b.intOrder is null)
					or(a.intOrder is null and b.intOrder is not null)

				-- End Data audit

			END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
