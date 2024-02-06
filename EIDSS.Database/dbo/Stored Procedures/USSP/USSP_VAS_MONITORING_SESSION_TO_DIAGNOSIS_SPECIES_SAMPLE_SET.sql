
-- ================================================================================================
-- Name: USSP_VAS_MONITORING_SESSION_TO_DIAGNOSIS_SPECIES_SAMPLE_SET
--
-- Description:	Inserts or updates monitoring session disease, species, and sample type matrix for the  
-- veterinary monitoring session set up and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay    02/07/2022 Initial release.
-- Mike Kornegay	02/14/2022 Corrected MonitoringSessionToDiagnosis with OUTPUT and RowAction
-- Leo Tracchia		12/12/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VAS_MONITORING_SESSION_TO_DIAGNOSIS_SPECIES_SAMPLE_SET] (
	@MonitoringSessionToDiagnosis BIGINT OUTPUT,
	@DataAuditEventID BIGINT = NULL,
	@MonitoringSessionID BIGINT,
	@DiseaseID BIGINT,
	@SpeciesTypeID BIGINT,
	@SampleTypeID BIGINT,
	@OrderNumber INT,
	@RowStatus INT,
	@RowAction INT, 
	@AuditUserName NVARCHAR(200)
)

AS

BEGIN

	SET NOCOUNT ON;

	BEGIN TRY

	    DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

		--Data Audit--

		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017062; --select * from trtBaseReference where strDefault = 'Veterinary Active Surveillance Session'
		DECLARE @idfObject bigint = @MonitoringSessionToDiagnosis;
		DECLARE @idfObjectTable_tlbMonitoringSessionToDiagnosis bigint = 707150000000;	--select * from tauTable where strName = 'tlbMonitoringSessionToDiagnosis'	 				

		DECLARE @tlbMonitoringSessionToDiagnosis_BeforeEdit TABLE
		(
			idfMonitoringSessionToDiagnosis bigint,
			idfMonitoringSession bigint,
			intOrder int,
			intRowStatus int,
			idfsSampleType bigint,
			idfsDiagnosis bigint,
			idfsSpeciesType bigint,
			AuditUpdateDTM datetime,
            AuditUpdateUser nvarchar(200)
		)		

		DECLARE @tlbMonitoringSessionToDiagnosis_AfterEdit TABLE
		(
			idfMonitoringSessionToDiagnosis bigint,
			idfMonitoringSession bigint,
			intOrder int,
			intRowStatus int,
			idfsSampleType bigint,
			idfsDiagnosis bigint,
			idfsSpeciesType bigint,
			AuditUpdateDTM datetime,
            AuditUpdateUser nvarchar(200)
		)		
		
		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo

		IF @RowAction = 1 --INSERT
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbMonitoringSessionToDiagnosis',
				@MonitoringSessionToDiagnosis OUTPUT;			

			INSERT INTO dbo.tlbMonitoringSessionToDiagnosis (
				idfMonitoringSessionToDiagnosis,
				idfMonitoringSession,
				idfsDiagnosis,
				idfsSpeciesType,
				idfsSampleType,
				intOrder,
				intRowStatus,
				AuditCreateDTM,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
				)
			VALUES (
				@MonitoringSessionToDiagnosis,
				@MonitoringSessionID,
				@DiseaseID,
				@SpeciesTypeID,
				@SampleTypeID, 
				@OrderNumber,
				@RowStatus,
				GETDATE(),
				@AuditUserName,
				10519001,
				'[{"idfMonitoringSessionToDiagnosis":' + CAST(@MonitoringSessionToDiagnosis AS NVARCHAR(300)) + '}]'
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
					@MonitoringSessionToDiagnosis, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionToDiagnosis AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

		END;
		ELSE
		BEGIN			

			INSERT INTO @tlbMonitoringSessionToDiagnosis_BeforeEdit (
				idfMonitoringSessionToDiagnosis,
				idfMonitoringSession, 
				intOrder,
				intRowStatus,
				idfsSampleType,
				idfsDiagnosis,
				idfsSpeciesType,
				AuditUpdateDTM,
				AuditUpdateUser
			)
			SELECT 
				idfMonitoringSessionToDiagnosis,
				idfMonitoringSession, 
				intOrder,
				intRowStatus,
				idfsSampleType,
				idfsDiagnosis,
				idfsSpeciesType,
				AuditUpdateDTM,
				AuditUpdateUser
			FROM tlbMonitoringSessionToDiagnosis WHERE idfMonitoringSessionToDiagnosis = @MonitoringSessionToDiagnosis;

			UPDATE dbo.tlbMonitoringSessionToDiagnosis
			SET idfMonitoringSession = @MonitoringSessionID,
				intOrder = @OrderNumber,
				intRowStatus = @RowStatus,
				idfsSampleType = @SampleTypeID, 
				idfsDiagnosis = @DiseaseID,
				idfsSpeciesType = @SpeciesTypeID,
				AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
			WHERE idfMonitoringSessionToDiagnosis = @MonitoringSessionToDiagnosis;

			INSERT INTO @tlbMonitoringSessionToDiagnosis_AfterEdit (
				idfMonitoringSessionToDiagnosis,
				idfMonitoringSession, 
				intOrder,
				intRowStatus,
				idfsSampleType,
				idfsDiagnosis,
				idfsSpeciesType,
				AuditUpdateDTM,
				AuditUpdateUser
			)
			SELECT 
				idfMonitoringSessionToDiagnosis,
				idfMonitoringSession, 
				intOrder,
				intRowStatus,
				idfsSampleType,
				idfsDiagnosis,
				idfsSpeciesType,
				AuditUpdateDTM,
				AuditUpdateUser
			FROM tlbMonitoringSessionToDiagnosis WHERE idfMonitoringSessionToDiagnosis = @MonitoringSessionToDiagnosis;

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
			from @tlbMonitoringSessionToDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionToDiagnosis_AfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
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
			from @tlbMonitoringSessionToDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionToDiagnosis_AfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
			where (a.idfsDiagnosis <> b.idfsDiagnosis) 
				or(a.idfsDiagnosis is not null and b.idfsDiagnosis is null)
				or(a.idfsDiagnosis is null and b.idfsDiagnosis is not null)

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
			from @tlbMonitoringSessionToDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionToDiagnosis_AfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
			where (a.intOrder <> b.intOrder) 
				or(a.intOrder is not null and b.intOrder is null)
				or(a.intOrder is null and b.intOrder is not null)

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
			from @tlbMonitoringSessionToDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionToDiagnosis_AfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
			where (a.idfsSpeciesType <> b.idfsSpeciesType) 
				or(a.idfsSpeciesType is not null and b.idfsSpeciesType is null)
				or(a.idfsSpeciesType is null and b.idfsSpeciesType is not null)

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
			from @tlbMonitoringSessionToDiagnosis_BeforeEdit a  inner join @tlbMonitoringSessionToDiagnosis_AfterEdit b on a.idfMonitoringSessionToDiagnosis = b.idfMonitoringSessionToDiagnosis
			where (a.idfsSampleType <> b.idfsSampleType) 
				or(a.idfsSampleType is not null and b.idfsSampleType is null)
				or(a.idfsSampleType is null and b.idfsSampleType is not null)

		END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
