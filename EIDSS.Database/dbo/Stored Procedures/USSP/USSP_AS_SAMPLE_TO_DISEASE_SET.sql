-- ================================================================================================
-- Name: USSP_AS_SAMPLE_TO_DISEASE_SET
--
-- Description:	Inserts or updates disease records for a particular sample for the human and  
-- veterinary active surveillance session use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     10/17/2022 Initial release.
-- Leo Tracchia		12/5/2022	Added logic for data auditing
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_AS_SAMPLE_TO_DISEASE_SET]
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
		--DECLARE @idfsDataAuditEventType bigint = NULL;	
		DECLARE @idfObject bigint = @MonitoringSessionToMaterialID;
		DECLARE @idfObjectTable_tlbMonitoringSessionToMaterial BIGINT = 53577790000003;
		DECLARE @idfDataAuditEvent bigint = NULL;	

		DECLARE @MonitoringSessionToMaterialBeforeEdit TABLE
		(			
			idfMonitoringSessionToMaterial bigint,
			idfMaterial bigint,
            idfsSampleType bigint,
            idfMonitoringSession bigint,
            idfsDisease bigint,
			intRowStatus int
		);

		DECLARE @MonitoringSessionToMaterialAfterEdit TABLE
		(
			idfMonitoringSessionToMaterial bigint,
			idfMaterial bigint,
            idfsSampleType bigint,
            idfMonitoringSession bigint,
            idfsDisease bigint,
			intRowStatus int
		);

		--End Data Audit--

        IF @RowAction = 1 --Insert
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
				0
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

			-- Data audit
			INSERT INTO @MonitoringSessionToMaterialBeforeEdit
            (
				idfMonitoringSessionToMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
            )
            SELECT 
				idfMonitoringSessionToMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
            FROM dbo.tlbMonitoringSessionToMaterial
            WHERE idfMonitoringSessionToMaterial = @MonitoringSessionToMaterialID;
			-- End Data audit

            UPDATE dbo.tlbMonitoringSessionToMaterial
            SET idfMaterial = @SampleID,
                idfsSampleType = @SampleTypeID,
                idfMonitoringSession = @MonitoringSessionID,
                idfsDisease = @DiseaseID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE(),
				intRowStatus = @RowStatus
			WHERE idfMonitoringSessionToMaterial = @MonitoringSessionToMaterialID;

			-- Data audit
			INSERT INTO @MonitoringSessionToMaterialAfterEdit
            (
				idfMonitoringSessionToMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
            )
            SELECT 
				idfMonitoringSessionToMaterial,
				idfsSampleType,
				idfMonitoringSession,
				idfsDisease,
				intRowStatus
            FROM dbo.tlbMonitoringSessionToMaterial
            WHERE idfMonitoringSessionToMaterial = @MonitoringSessionToMaterialID;

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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000022,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfMaterial,
				b.idfMaterial 
			from @MonitoringSessionToMaterialBeforeEdit a inner join @MonitoringSessionToMaterialAfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000023,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfsSampleType,
				b.idfsSampleType 
			from @MonitoringSessionToMaterialBeforeEdit a inner join @MonitoringSessionToMaterialAfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000024,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfMonitoringSession,
				b.idfMonitoringSession 
			from @MonitoringSessionToMaterialBeforeEdit a inner join @MonitoringSessionToMaterialAfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000025,
				a.idfMonitoringSessionToMaterial,
				null,
				a.idfsDisease,
				b.idfsDisease 
			from @MonitoringSessionToMaterialBeforeEdit a inner join @MonitoringSessionToMaterialAfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
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
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSessionToMaterial, 
				51586990000026,
				a.idfMonitoringSessionToMaterial,
				null,
				a.intRowStatus,
				b.intRowStatus 
			from @MonitoringSessionToMaterialBeforeEdit a inner join @MonitoringSessionToMaterialAfterEdit b on a.idfMonitoringSessionToMaterial = b.idfMonitoringSessionToMaterial
			where (a.intRowStatus <> b.intRowStatus) 
				or(a.intRowStatus is not null and b.intRowStatus is null)
				or(a.intRowStatus is null and b.intRowStatus is not null)

			-- End Data audit


        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;