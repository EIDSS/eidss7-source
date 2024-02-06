-- ================================================================================================
-- Name: USSP_VCT_MONITORING_SESSION_SUMMARY_SET
--
-- Description:	Inserts or updates monitoring session summary for the human and veterinary module 
-- monitoring session enter and edit use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/07/2018 Initial release.
-- Stephen Long     04/30/2019 Modified for new API; removed maintenance flag.
-- Stephen Long     06/24/2019 Added audit user name parameter.
-- Stephen Long     11/09/2020 Added check for null disease ID on insert and update.
-- Mike Kornegay	03/11/2022 Changed RowAction to INT
-- Mike Kornegay	03/13/2022 Removed @LanguageID parameter as it is not necessary.
-- Leo Tracchia		12/14/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VCT_MONITORING_SESSION_SUMMARY_SET] (
	@MonitoringSessionSummaryID BIGINT OUTPUT
	,@DataAuditEventID BIGINT = NULL
	,@MonitoringSessionID BIGINT
	,@FarmID BIGINT = NULL
	,@SpeciesID BIGINT = NULL
	,@AnimalGenderTypeID BIGINT = NULL
	,@SampledAnimalsQuantity INT = NULL
	,@SamplesQuantity INT = NULL
	,@CollectionDate DATETIME = NULL
	,@PositiveAnimalsQuantity INT = NULL
	,@RowStatus INT
	,@DiseaseID BIGINT = NULL
	,@SampleTypeID BIGINT = NULL
	,@RowAction INT
	,@AuditUserName NVARCHAR(200)
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
		DECLARE @idfObject bigint = @MonitoringSessionSummaryID;
		DECLARE @idfObjectTable_tlbMonitoringSessionSummary bigint = 4578950000000; --select * from tauTable where strName = 'tlbMonitoringSessionSummary'				
		DECLARE @idfObjectTable_tlbMonitoringSessionSummaryDiagnosis bigint = 4579090000000; --select * from tauTable where strName = 'tlbMonitoringSessionSummaryDiagnosis'				
		DECLARE @idfObjectTable_tlbMonitoringSessionSummarySample bigint = 4579050000000; --select * from tauTable where strName = 'tlbMonitoringSessionSummaryDiagnosis'				

		DECLARE @tlbMonitoringSessionSummary_BeforeEdit TABLE
		(
			idfMonitoringSessionSummary bigint,
			idfMonitoringSession bigint,
			idfFarm bigint,
			idfSpecies bigint,
			idfsAnimalSex bigint,
			intSampledAnimalsQty int,
			intSamplesQty int,
			datCollectionDate datetime,
			intPositiveAnimalsQty int
		)		

		DECLARE @tlbMonitoringSessionSummary_AfterEdit TABLE
		(
			idfMonitoringSessionSummary bigint,
			idfMonitoringSession bigint,
			idfFarm bigint,
			idfSpecies bigint,
			idfsAnimalSex bigint,
			intSampledAnimalsQty int,
			intSamplesQty int,
			datCollectionDate datetime,
			intPositiveAnimalsQty int
		)		

		-- Data Audit
		

		IF @RowAction = 1
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbMonitoringSessionSummary'
				,@MonitoringSessionSummaryID OUTPUT;

			INSERT INTO dbo.tlbMonitoringSessionSummary (
				idfMonitoringSessionSummary
				,idfMonitoringSession
				,idfFarm
				,idfSpecies
				,idfsAnimalSex
				,intSampledAnimalsQty
				,intSamplesQty
				,datCollectionDate
				,intPositiveAnimalsQty
				,intRowStatus
				,AuditCreateUser
				)
			VALUES (
				@MonitoringSessionSummaryID
				,@MonitoringSessionID
				,@FarmID
				,@SpeciesID
				,@AnimalGenderTypeID
				,@SampledAnimalsQuantity
				,@SamplesQuantity
				,@CollectionDate
				,@PositiveAnimalsQuantity
				,@RowStatus
				,@AuditUserName
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
					@idfObjectTable_tlbMonitoringSessionSummary, 
					@MonitoringSessionSummaryID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionSummary AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

			IF @DiseaseID IS NOT NULL
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
					,1
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
					@DiseaseID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionSummaryDiagnosis AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

			END;

			IF @SampleTypeID IS NOT NULL
			INSERT INTO dbo.tlbMonitoringSessionSummarySample (
				idfMonitoringSessionSummary
				,idfsSampleType
				,intRowStatus
				,blnChecked
				,AuditCreateUser
				)
			VALUES (
				@MonitoringSessionSummaryID
				,@SampleTypeID
				,@RowStatus
				,1
				,@AuditUserName
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
					@idfObjectTable_tlbMonitoringSessionSummarySample, 
					@SampleTypeID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionSummarySample AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

		END
		ELSE
		BEGIN

			INSERT INTO @tlbMonitoringSessionSummary_BeforeEdit (
				idfMonitoringSessionSummary,
				idfMonitoringSession,
				idfFarm,
				idfSpecies,
				idfsAnimalSex,
				intSampledAnimalsQty,
				intSamplesQty,
				datCollectionDate,
				intPositiveAnimalsQty
			)
			SELECT 
				idfMonitoringSessionSummary,
				idfMonitoringSession,
				idfFarm,
				idfSpecies,
				idfsAnimalSex,
				intSampledAnimalsQty,
				intSamplesQty,
				datCollectionDate,
				intPositiveAnimalsQty
			FROM tlbMonitoringSessionSummary WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID;

			UPDATE dbo.tlbMonitoringSessionSummary
			SET idfMonitoringSession = @MonitoringSessionID
				,idfFarm = @FarmID
				,idfSpecies = @SpeciesID
				,idfsAnimalSex = @AnimalGenderTypeID
				,intSampledAnimalsQty = @SampledAnimalsQuantity
				,intSamplesQty = @SamplesQuantity
				,datCollectionDate = @CollectionDate
				,intPositiveAnimalsQty = @PositiveAnimalsQuantity
				,intRowStatus = @RowStatus
				,AuditUpdateUser = @AuditUserName
			WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID;

			INSERT INTO @tlbMonitoringSessionSummary_AfterEdit (
				idfMonitoringSessionSummary,
				idfMonitoringSession,
				idfFarm,
				idfSpecies,
				idfsAnimalSex,
				intSampledAnimalsQty,
				intSamplesQty,
				datCollectionDate,
				intPositiveAnimalsQty
			)
			SELECT 
				idfMonitoringSessionSummary,
				idfMonitoringSession,
				idfFarm,
				idfSpecies,
				idfsAnimalSex,
				intSampledAnimalsQty,
				intSamplesQty,
				datCollectionDate,
				intPositiveAnimalsQty
			FROM tlbMonitoringSessionSummary WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID;

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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4578970000000,
				a.idfMonitoringSessionSummary,
				null,
				a.idfMonitoringSession,
				b.idfMonitoringSession 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.idfMonitoringSession <> b.idfMonitoringSession) 
				or(a.idfMonitoringSession is not null and b.idfMonitoringSession is null)
				or(a.idfMonitoringSession is null and b.idfMonitoringSession is not null)

			--idfFarm
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4578980000000,
				a.idfMonitoringSessionSummary,
				null,
				a.idfFarm,
				b.idfFarm 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.idfFarm <> b.idfFarm) 
				or(a.idfFarm is not null and b.idfFarm is null)
				or(a.idfFarm is null and b.idfFarm is not null)

			--idfSpecies
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4578990000000,
				a.idfMonitoringSessionSummary,
				null,
				a.idfSpecies,
				b.idfSpecies 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.idfSpecies <> b.idfSpecies) 
				or(a.idfSpecies is not null and b.idfSpecies is null)
				or(a.idfSpecies is null and b.idfSpecies is not null)

			--idfsAnimalSex
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4579000000000,
				a.idfMonitoringSessionSummary,
				null,
				a.idfsAnimalSex,
				b.idfsAnimalSex 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.idfsAnimalSex <> b.idfsAnimalSex) 
				or(a.idfsAnimalSex is not null and b.idfsAnimalSex is null)
				or(a.idfsAnimalSex is null and b.idfsAnimalSex is not null)

			--intSampledAnimalsQty
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4579010000000,
				a.idfMonitoringSessionSummary,
				null,
				a.intSampledAnimalsQty,
				b.intSampledAnimalsQty 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.intSampledAnimalsQty <> b.intSampledAnimalsQty) 
				or(a.intSampledAnimalsQty is not null and b.intSampledAnimalsQty is null)
				or(a.intSampledAnimalsQty is null and b.intSampledAnimalsQty is not null)

			--intSamplesQty
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4579020000000,
				a.idfMonitoringSessionSummary,
				null,
				a.intSamplesQty,
				b.intSamplesQty 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.intSamplesQty <> b.intSamplesQty) 
				or(a.intSamplesQty is not null and b.intSamplesQty is null)
				or(a.intSamplesQty is null and b.intSamplesQty is not null)

			--datCollectionDate
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4579030000000,
				a.idfMonitoringSessionSummary,
				null,
				a.datCollectionDate,
				b.datCollectionDate 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.datCollectionDate <> b.datCollectionDate) 
				or(a.datCollectionDate is not null and b.datCollectionDate is null)
				or(a.datCollectionDate is null and b.datCollectionDate is not null)

			--intPositiveAnimalsQty
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
				@idfObjectTable_tlbMonitoringSessionSummary, 
				4579040000000,
				a.idfMonitoringSessionSummary,
				null,
				a.intPositiveAnimalsQty,
				b.intPositiveAnimalsQty 
			from @tlbMonitoringSessionSummary_BeforeEdit a  inner join @tlbMonitoringSessionSummary_AfterEdit b on a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			where (a.intPositiveAnimalsQty <> b.intPositiveAnimalsQty) 
				or(a.intPositiveAnimalsQty is not null and b.intPositiveAnimalsQty is null)
				or(a.intPositiveAnimalsQty is null and b.intPositiveAnimalsQty is not null)

			IF EXISTS (
					SELECT *
					FROM dbo.tlbMonitoringSessionSummaryDiagnosis
					WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID
					)
			BEGIN
				IF @DiseaseID IS NOT NULL
					BEGIN
						UPDATE dbo.tlbMonitoringSessionSummaryDiagnosis
						SET intRowStatus = @RowStatus
							,AuditUpdateUser = @AuditUserName
							,idfsDiagnosis = @DiseaseID
						WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID
					END
				ELSE
					BEGIN
						UPDATE dbo.tlbMonitoringSessionSummaryDiagnosis
						SET intRowStatus = 1
							,AuditUpdateUser = @AuditUserName
						WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID
					END
			END
			ELSE
				BEGIN
					IF @DiseaseID IS NOT NULL
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
								,1
								,@AuditUserName
								)
						END
			END;

			IF @SampleTypeID IS NOT NULL
				BEGIN
					UPDATE dbo.tlbMonitoringSessionSummarySample
					SET intRowStatus = @RowStatus
						,AuditUpdateUser = @AuditUserName
					WHERE idfMonitoringSessionSummary = @MonitoringSessionSummaryID
						AND idfsSampleType = @SampleTypeID;
				END
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
