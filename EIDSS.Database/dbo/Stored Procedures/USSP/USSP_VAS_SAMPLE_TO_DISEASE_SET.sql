-- ================================================================================================
-- Name: USSP_VAS_SAMPLE_TO_DISEASE_SET
--
-- Description:	Inserts or updates disease records for a particular sample for the veterinary active surveillance use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay    08/18/2022 Initial release.
-- Mike Kornegay	08/22/2022 Added intRowStatus to update statement.
-- Leo Tracchia		12/14/2022 added logic for data auditing 
-- Mike Kornegay	03/07/2023 Corrected insert logic so that new records updated in app are inserted
-- 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VAS_SAMPLE_TO_DISEASE_SET]
(
    @AuditUserName NVARCHAR(100) = NULL,
	@DataAuditEventID BIGINT = NULL,
    @MonitoringSessionToMaterialID BIGINT,
	@MonitoringSessionID BIGINT,
	@SampleID BIGINT,
	@DiseaseID BIGINT,
    @SampleTypeID BIGINT,
    @RowStatus INT,
    @RowAction INT
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
		DECLARE @idfObject bigint = @MonitoringSessionToMaterialID;
		DECLARE @idfObjectTable_tlbMonitoringSessionToMaterial bigint = 53577790000003; --select * from tauTable where strName = 'tlbMonitoringSessionToMaterial'				

		DECLARE @tlbMonitoringSessionToMaterial_BeforeEdit TABLE
		(
			idfMonitoringSessionToMaterial bigint,
			idfMaterial bigint,
			idfsSampleType bigint,
			idfMonitoringSession bigint,
			idfsDisease bigint,
			intRowStatus int
		)		

		DECLARE @tlbMonitoringSessionToMaterial_AfterEdit TABLE
		(
			idfMonitoringSessionToMaterial bigint,
			idfMaterial bigint,
			idfsSampleType bigint,
			idfMonitoringSession bigint,
			idfsDisease bigint,
			intRowStatus int
		)		

		-- Data Audit

        IF @RowAction = 1 OR @MonitoringSessionToMaterialID < 0 --Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbMonitoringSessionToMaterial',
                                              @idfsKey = @MonitoringSessionToMaterialID OUTPUT;

            INSERT INTO dbo.tlbMonitoringSessionToMaterial
            (
				idfMonitoringSessionToMaterial,
                idfMaterial,
                idfsSampleType,
                idfMonitoringSession,
                idfsDisease,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM,
				intRowStatus
            )
            VALUES
            (   
				@MonitoringSessionToMaterialID,
				@SampleID,
				@SampleTypeID,
				@MonitoringSessionID,
				@DiseaseID,
				10519001,
				'[{"idfMonitoringSessionToMaterial":' + CAST(@MonitoringSessionToMaterialID AS NVARCHAR(300)) + '}]',
				@AuditUserName,
				GETDATE(),
				@AuditUserName,
				GETDATE(),
				@RowStatus
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
					@idfObjectTable_tlbMonitoringSessionToMaterial, 
					@MonitoringSessionToMaterialID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbMonitoringSessionToMaterial AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

        END;
        ELSE
        BEGIN

			INSERT INTO @tlbMonitoringSessionToMaterial_BeforeEdit (
				idfMonitoringSessionToMaterial,
				idfMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
			)
			SELECT 
				idfMonitoringSessionToMaterial,
				idfMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
			FROM tlbMonitoringSessionToMaterial WHERE idfMonitoringSessionToMaterial = @MonitoringSessionToMaterialID;

            UPDATE dbo.tlbMonitoringSessionToMaterial
            SET idfMaterial = @SampleID,
                idfsSampleType = @SampleTypeID,
                idfMonitoringSession = @MonitoringSessionID,
                idfsDisease = @DiseaseID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE(),
				intRowStatus = @RowStatus
			WHERE idfMonitoringSessionToMaterial = @MonitoringSessionToMaterialID;

			INSERT INTO @tlbMonitoringSessionToMaterial_AfterEdit (
				idfMonitoringSessionToMaterial,
				idfMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
			)
			SELECT 
				idfMonitoringSessionToMaterial,
				idfMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
			FROM tlbMonitoringSessionToMaterial WHERE idfMonitoringSessionToMaterial = @MonitoringSessionToMaterialID;

			--idfMaterial
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
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000022,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfMaterial,
				b.idfMaterial 
			from @tlbMonitoringSessionToMaterial_BeforeEdit a  inner join @tlbMonitoringSessionToMaterial_AfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
			where (a.idfMaterial <> b.idfMaterial) 
				or(a.idfMaterial is not null and b.idfMaterial is null)
				or(a.idfMaterial is null and b.idfMaterial is not null)

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
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000023,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfsSampleType,
				b.idfsSampleType 
			from @tlbMonitoringSessionToMaterial_BeforeEdit a  inner join @tlbMonitoringSessionToMaterial_AfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
			where (a.idfsSampleType <> b.idfsSampleType) 
				or(a.idfsSampleType is not null and b.idfsSampleType is null)
				or(a.idfsSampleType is null and b.idfsSampleType is not null)

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
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000024,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfMonitoringSession,
				b.idfMonitoringSession 
			from @tlbMonitoringSessionToMaterial_BeforeEdit a  inner join @tlbMonitoringSessionToMaterial_AfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
			where (a.idfMonitoringSession <> b.idfMonitoringSession) 
				or(a.idfMonitoringSession is not null and b.idfMonitoringSession is null)
				or(a.idfMonitoringSession is null and b.idfMonitoringSession is not null)

			--idfsDisease
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
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000025,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfsDisease,
				b.idfsDisease 
			from @tlbMonitoringSessionToMaterial_BeforeEdit a  inner join @tlbMonitoringSessionToMaterial_AfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
			where (a.idfsDisease <> b.idfsDisease) 
				or(a.idfsDisease is not null and b.idfsDisease is null)
				or(a.idfsDisease is null and b.idfsDisease is not null)

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
				@DataAuditEventID,
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000026,
				a.idfMonitoringSessionToMaterial,
				null,
				a.intRowStatus,
				b.intRowStatus 
			from @tlbMonitoringSessionToMaterial_BeforeEdit a  inner join @tlbMonitoringSessionToMaterial_AfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
			where (a.intRowStatus <> b.intRowStatus) 
				or(a.intRowStatus is not null and b.intRowStatus is null)
				or(a.intRowStatus is null and b.intRowStatus is not null)


        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
