-- ================================================================================================
-- Name: USSP_VCT_MONITORING_SESSION_SUMMARY_DIAGNOSIS_SET
--
-- Description:	Inserts or updates monitoring session summary diagnosis for the human and veterinary module 
-- monitoring session enter and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay    03/19/2022 Initial release.
-- Leo Tracchia		12/14/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VCT_MONITORING_SESSION_SUMMARY_DIAGNOSIS_SET] (
	@MonitoringSessionSummaryID BIGINT
	,@DataAuditEventID BIGINT = NULL
	,@RowStatus INT
	,@DiseaseID BIGINT = NULL
	,@RowAction INT
	,@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN

			--Data Audit--

			DECLARE @idfUserId BIGINT = NULL;
			DECLARE @idfSiteId BIGINT = NULL;
			DECLARE @idfsDataAuditEventType bigint = NULL;
			DECLARE @idfsObjectType bigint = 10017062; --select * from trtBaseReference where strDefault = 'Veterinary Active Surveillance Session'
			DECLARE @idfObject bigint = @MonitoringSessionSummaryID;
			DECLARE @idfObjectTable_tlbMonitoringSessionSummaryDiagnosis bigint = 4579090000000; --select * from tauTable where strName = 'tlbMonitoringSessionToMaterial'				

			DECLARE @tlbMonitoringSessionSummaryDiagnosis_BeforeEdit TABLE
			(
				idfMonitoringSessionSummary bigint,
				idfsDiagnosis bigint,
				blnChecked bit
			)		

			DECLARE @tlbMonitoringSessionSummaryDiagnosis_AfterEdit TABLE
			(
				idfMonitoringSessionSummary bigint,
				idfsDiagnosis bigint,
				blnChecked bit
			)		

			-- Data Audit

			IF EXISTS (
					SELECT *
					FROM dbo.tlbMonitoringSessionSummaryDiagnosis
					WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID
					)	
				BEGIN

					INSERT INTO @tlbMonitoringSessionSummaryDiagnosis_BeforeEdit (
						idfMonitoringSessionSummary,
						idfsDiagnosis,
						blnChecked
					)
					SELECT 
						idfMonitoringSessionSummary,
						idfsDiagnosis,
						blnChecked
					FROM tlbMonitoringSessionSummaryDiagnosis WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID;

					UPDATE dbo.tlbMonitoringSessionSummaryDiagnosis
					SET intRowStatus = @RowStatus
						,AuditUpdateUser = @AuditUserName
						,idfsDiagnosis = @DiseaseID
					WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID

					INSERT INTO @tlbMonitoringSessionSummaryDiagnosis_AfterEdit (
						idfMonitoringSessionSummary,
						idfsDiagnosis,
						blnChecked
					)
					SELECT 
						idfMonitoringSessionSummary,
						idfsDiagnosis,
						blnChecked
					FROM tlbMonitoringSessionSummaryDiagnosis WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID;

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
						@idfObjectTable_tlbMonitoringSessionSummaryDiagnosis, 
						4579120000000,
						a.idfMonitoringSessionSummary,
						null,
						a.idfsDiagnosis,
						b.idfsDiagnosis 
					from @tlbMonitoringSessionSummaryDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionSummaryDiagnosis_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
					where (a.idfsDiagnosis <> b.idfsDiagnosis) 
						or(a.idfsDiagnosis is not null and b.idfsDiagnosis is null)
						or(a.idfsDiagnosis is null and b.idfsDiagnosis is not null)

					--blnChecked
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
						@idfObjectTable_tlbMonitoringSessionSummaryDiagnosis, 
						4579480000000,
						a.idfMonitoringSessionSummary,
						null,
						a.blnChecked,
						b.blnChecked 
					from @tlbMonitoringSessionSummaryDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionSummaryDiagnosis_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
					where (a.blnChecked <> b.blnChecked) 
						or(a.blnChecked is not null and b.blnChecked is null)
						or(a.blnChecked is null and b.blnChecked is not null)

				END
			ELSE
				BEGIN

					INSERT INTO dbo.tlbMonitoringSessionSummaryDiagnosis (
						idfMonitoringSessionSummary
						,idfsDiagnosis
						,intRowStatus
						,blnChecked
						,AuditCreateUser
						)
					VALUES (
						@MonitoringSessionSummaryID
						,@DiseaseID
						,@RowStatus
						,0
						,@AuditUserName
						)

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
						@idfObjectTable_tlbMonitoringSessionSummaryDiagnosis, 
						@MonitoringSessionSummaryID, 
						10519001,
						'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
						+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionSummaryDiagnosis AS NVARCHAR(300)) + '}]',
						@AuditUserName
					);
				-- End data audit
				END
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
