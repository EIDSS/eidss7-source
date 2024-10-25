-- ================================================================================================
-- Name: USSP_VET_HERD_SET
--
-- Description:	Inserts or updates herd "snapshot" for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/01/2018 Initial release.
-- Stephen Long     03/28/2019 Changed from V6.1 get next number call to V7.
-- Stephen Long     04/10/2019 Split out the master (actual) and snapshot sets.
-- Mark Wilson      10/19/2021 removed @LanguageID, added @AuditUser, added all fields.
-- Stephen Long     01/19/2022 Changed row action data type.
-- Leo Tracchia		12/12/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_HERD_SET]
(
    @AuditUserName NVARCHAR(200),
	@DataAuditEventID BIGINT = NULL,
    @FlockOrHerdID BIGINT = NULL OUTPUT,
    @FlockOrHerdMasterID BIGINT = NULL,
    @FarmID BIGINT = NULL,
    @EIDSSFlockOrHerdID NVARCHAR(200) = NULL,
    @SickAnimalQuantity INT = NULL,
    @TotalAnimalQuantity INT = NULL,
    @DeadAnimalQuantity INT = NULL,
    @Note NVARCHAR(2000) = NULL,
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
		DECLARE @idfObject bigint = @FlockOrHerdID;
		DECLARE @idfObjectTable_tlbHerd bigint = 75590000000;	--select * from tauTable where strName = 'tlbHerd'	 				

		DECLARE @tlbHerd_BeforeEdit TABLE
		(
			idfHerd bigint,
			idfHerdActual bigint,
            idfFarm bigint,
            strHerdCode nvarchar(200),
            intSickAnimalQty int,
            intTotalAnimalQty int,
            intDeadAnimalQty int,
            strNote nvarchar(2000),
            intRowStatus int            
		)		

		DECLARE @tlbHerd_AfterEdit TABLE
		(
			idfHerd bigint,
			idfHerdActual bigint,
            idfFarm bigint,
            strHerdCode nvarchar(200),
            intSickAnimalQty int,
            intTotalAnimalQty int,
            intDeadAnimalQty int,
            strNote nvarchar(2000),
            intRowStatus int  
		)		

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbHerd',
                                              @idfsKey = @FlockOrHerdID OUTPUT;

            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = 'Animal Group',
                                               @NextNumberValue = @EIDSSFlockOrHerdID OUTPUT,
                                               @InstallationSite = NULL;

            INSERT INTO dbo.tlbHerd
            (
                idfHerd,
                idfHerdActual,
                idfFarm,
                strHerdCode,
                intSickAnimalQty,
                intTotalAnimalQty,
                intDeadAnimalQty,
                strNote,
                rowguid,
                intRowStatus,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
				(@FlockOrHerdID,
				 @FlockOrHerdMasterID,
				 @FarmID,
				 @EIDSSFlockOrHerdID,
				 @SickAnimalQuantity,
				 @TotalAnimalQuantity,
				 @DeadAnimalQuantity,
				 @Note,
				 NEWID(),
				 @RowStatus,
				 NULL,
				 NULL,
				 10519001,
				 '[{"idfHerd":' + CAST(@FlockOrHerdID AS NVARCHAR(300)) + '}]',
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
					@idfObjectTable_tlbHerd, 
					@FlockOrHerdID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbHerd AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

        END
        ELSE
        BEGIN

			INSERT INTO @tlbHerd_BeforeEdit (
				idfHerd,
				idfHerdActual,
				idfFarm,
				strHerdCode,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote,
				intRowStatus
			)
			SELECT 
				idfHerd,
				idfHerdActual,
				idfFarm,
				strHerdCode,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote,
				intRowStatus
			FROM tlbHerd WHERE idfHerd = @FlockOrHerdID;

            UPDATE dbo.tlbHerd
            SET idfHerdActual = @FlockOrHerdMasterID,
                idfFarm = @FarmID,
                strHerdCode = @EIDSSFlockOrHerdID,
                intSickAnimalQty = @SickAnimalQuantity,
                intTotalAnimalQty = @TotalAnimalQuantity,
                intDeadAnimalQty = @DeadAnimalQuantity,
                strNote = @Note,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfHerd = @FlockOrHerdID;

			INSERT INTO @tlbHerd_AfterEdit (
				idfHerd,
				idfHerdActual,
				idfFarm,
				strHerdCode,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote,
				intRowStatus
			)
			SELECT 
				idfHerd,
				idfHerdActual,
				idfFarm,
				strHerdCode,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote,
				intRowStatus
			FROM tlbHerd WHERE idfHerd = @FlockOrHerdID;

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
				@idfObjectTable_tlbHerd, 
				79280000000,
				a.idfHerd,
				null,
				a.idfFarm,
				b.idfFarm 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.idfFarm <> b.idfFarm) 
				or(a.idfFarm is not null and b.idfFarm is null)
				or(a.idfFarm is null and b.idfFarm is not null)

			--intDeadAnimalQty
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
				@idfObjectTable_tlbHerd, 
				79300000000,
				a.idfHerd,
				null,
				a.intDeadAnimalQty,
				b.intDeadAnimalQty 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.intDeadAnimalQty <> b.intDeadAnimalQty) 
				or(a.intDeadAnimalQty is not null and b.intDeadAnimalQty is null)
				or(a.intDeadAnimalQty is null and b.intDeadAnimalQty is not null)

			--intTotalAnimalQty
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
				@idfObjectTable_tlbHerd, 
				79310000000,
				a.idfHerd,
				null,
				a.intTotalAnimalQty,
				b.intTotalAnimalQty 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.intTotalAnimalQty <> b.intTotalAnimalQty) 
				or(a.intTotalAnimalQty is not null and b.intTotalAnimalQty is null)
				or(a.intTotalAnimalQty is null and b.intTotalAnimalQty is not null)

			--strHerdCode
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
				@idfObjectTable_tlbHerd, 
				79320000000,
				a.idfHerd,
				null,
				a.strHerdCode,
				b.strHerdCode 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.strHerdCode <> b.strHerdCode) 
				or(a.strHerdCode is not null and b.strHerdCode is null)
				or(a.strHerdCode is null and b.strHerdCode is not null)

			--idfHerdActual
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
				@idfObjectTable_tlbHerd, 
				4572280000000,
				a.idfHerd,
				null,
				a.idfHerdActual,
				b.idfHerdActual 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.idfHerdActual <> b.idfHerdActual) 
				or(a.idfHerdActual is not null and b.idfHerdActual is null)
				or(a.idfHerdActual is null and b.idfHerdActual is not null)

			--intSickAnimalQty
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
				@idfObjectTable_tlbHerd, 
				4572290000000,
				a.idfHerd,
				null,
				a.intSickAnimalQty,
				b.intSickAnimalQty 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.intSickAnimalQty <> b.intSickAnimalQty) 
				or(a.intSickAnimalQty is not null and b.intSickAnimalQty is null)
				or(a.intSickAnimalQty is null and b.intSickAnimalQty is not null)

			--strNote
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
				@idfObjectTable_tlbHerd, 
				4572300000000,
				a.idfHerd,
				null,
				a.strNote,
				b.strNote 
			from @tlbHerd_BeforeEdit a  inner join @tlbHerd_AfterEdit b on a.idfHerd = b.idfHerd
			where (a.strNote <> b.strNote) 
				or(a.strNote is not null and b.strNote is null)
				or(a.strNote is null and b.strNote is not null)

        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
