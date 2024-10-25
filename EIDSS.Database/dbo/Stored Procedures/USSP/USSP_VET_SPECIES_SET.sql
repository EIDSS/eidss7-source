-- ================================================================================================
-- Name: USSP_VET_SPECIES_SET
--
-- Description:	Inserts or updates species for the veterinary disease report and monitoring 
-- session use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/31/2018 Initial release.
-- Stephen Long     04/10/2019 Split out master (actual) from snapshot.
-- Stephen Long     02/04/2020 Added update of the species investigation observation via the 
--                             species status (TFS item 5364).
-- Stephen Long     09/24/2021 Removed language parameter as it is not needed. Added audit user 
--                             name parameter.
-- Stephen Long     01/19/2022 Changed row action data type.
-- Stephen Long     06/16/0222 Added outbreak status type ID parameter.
-- Leo Tracchia		12/13/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_SPECIES_SET]
(
    @AuditUserName NVARCHAR(200),
	@DataAuditEventID BIGINT = NULL,
    @SpeciesID BIGINT = NULL OUTPUT,
    @SpeciesMasterID BIGINT = NULL,
    @SpeciesTypeID BIGINT,
    @HerdID BIGINT = NULL,
    @ObservationID BIGINT = NULL,
    @StartOfSignsDate DATETIME = NULL,
    @AverageAge NVARCHAR(200) = NULL,
    @SickAnimalQuantity INT = NULL,
    @TotalAnimalQuantity INT = NULL,
    @DeadAnimalQuantity INT = NULL,
    @Comments NVARCHAR(2000) = NULL,
    @RowStatus INT,
    @RowAction INT,
    @OutbreakStatusTypeID BIGINT = NULL 
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
		DECLARE @idfObject bigint = @SpeciesID;
		DECLARE @idfObjectTable_tlbSpecies bigint = 75710000000; --select * from tauTable where strName = 'tlbSpecies'				

		DECLARE @tlbSpecies_BeforeEdit TABLE
		(
			idfSpecies bigint,
			idfSpeciesActual bigint,
			idfsSpeciesType bigint,
			idfHerd bigint,
			idfObservation bigint,
			datStartOfSignsDate datetime,
			strAverageAge nvarchar(200),
			intSickAnimalQty int,
			intTotalAnimalQty int,
			intDeadAnimalQty int,
			strNote nvarchar(2000)
		)		

		DECLARE @tlbSpecies_AfterEdit TABLE
		(
			idfSpecies bigint,
			idfSpeciesActual bigint,
			idfsSpeciesType bigint,
			idfHerd bigint,
			idfObservation bigint,
			datStartOfSignsDate datetime,
			strAverageAge nvarchar(200),
			intSickAnimalQty int,
			intTotalAnimalQty int,
			intDeadAnimalQty int,
			strNote nvarchar(2000)
		)		

		-- Data Audit

        IF @RowAction = 1
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbSpecies', @SpeciesID OUTPUT;

            INSERT INTO dbo.tlbSpecies
            (
                idfSpecies,
                idfSpeciesActual,
                idfsSpeciesType,
                idfHerd,
                idfObservation,
                datStartOfSignsDate,
                strAverageAge,
                intSickAnimalQty,
                intTotalAnimalQty,
                intDeadAnimalQty,
                strNote,
                intRowStatus,
                idfsOutbreakCaseStatus, 
                AuditCreateDTM,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES(
				@SpeciesID,
				 @SpeciesMasterID,
				 @SpeciesTypeID,
				 @HerdID,
				 @ObservationID,
				 @StartOfSignsDate,
				 @AverageAge,
				 @SickAnimalQuantity,
				 @TotalAnimalQuantity,
				 @DeadAnimalQuantity,
				 @Comments,
				 @RowStatus,
				 @OutbreakStatusTypeID, 
				 GETDATE(),
				 @AuditUserName,
				 10519001,
				 '[{"idfSpecies":' + CAST(@SpeciesID AS NVARCHAR(300)) + '}]'
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
					@idfObjectTable_tlbSpecies, 
					@SpeciesID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbSpecies AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

        END
        ELSE
        BEGIN

			INSERT INTO @tlbSpecies_BeforeEdit (
				idfSpecies,
				idfSpeciesActual,
				idfsSpeciesType,
				idfHerd,
				idfObservation,
				datStartOfSignsDate,
				strAverageAge,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote
			)
			SELECT 
				idfSpecies,
				idfSpeciesActual,
				idfsSpeciesType,
				idfHerd,
				idfObservation,
				datStartOfSignsDate,
				strAverageAge,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote
			FROM tlbSpecies WHERE idfHerd = @SpeciesID;

            UPDATE dbo.tlbSpecies
            SET idfSpeciesActual = @SpeciesMasterID,
                idfsSpeciesType = @SpeciesTypeID,
                idfHerd = @HerdID,
                idfObservation = @ObservationID,
                datStartOfSignsDate = @StartOfSignsDate,
                strAverageAge = @AverageAge,
                intSickAnimalQty = @SickAnimalQuantity,
                intTotalAnimalQty = @TotalAnimalQuantity,
                intDeadAnimalQty = @DeadAnimalQuantity,
                strNote = @Comments,
                intRowStatus = @RowStatus,
                idfsOutbreakCaseStatus = @OutbreakStatusTypeID, 
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfSpecies = @SpeciesID;

			INSERT INTO @tlbSpecies_AfterEdit (
				idfSpecies,
				idfSpeciesActual,
				idfsSpeciesType,
				idfHerd,
				idfObservation,
				datStartOfSignsDate,
				strAverageAge,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote
			)
			SELECT 
				idfSpecies,
				idfSpeciesActual,
				idfsSpeciesType,
				idfHerd,
				idfObservation,
				datStartOfSignsDate,
				strAverageAge,
				intSickAnimalQty,
				intTotalAnimalQty,
				intDeadAnimalQty,
				strNote
			FROM tlbSpecies WHERE idfHerd = @SpeciesID;

			--idfSpeciesActual
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
				@idfObjectTable_tlbSpecies, 
				4572330000000,
				a.idfSpecies,
				null,
				a.idfSpeciesActual,
				b.idfSpeciesActual 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.idfSpeciesActual <> b.idfSpeciesActual) 
				or(a.idfSpeciesActual is not null and b.idfSpeciesActual is null)
				or(a.idfSpeciesActual is null and b.idfSpeciesActual is not null)

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
				@idfObjectTable_tlbSpecies, 
				4572340000000,
				a.idfSpecies,
				null,
				a.idfsSpeciesType,
				b.idfsSpeciesType 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.idfsSpeciesType <> b.idfsSpeciesType) 
				or(a.idfsSpeciesType is not null and b.idfsSpeciesType is null)
				or(a.idfsSpeciesType is null and b.idfsSpeciesType is not null)

			--idfHerd
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
				@idfObjectTable_tlbSpecies, 
				4572350000000,
				a.idfSpecies,
				null,
				a.idfHerd,
				b.idfHerd 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.idfHerd <> b.idfHerd) 
				or(a.idfHerd is not null and b.idfHerd is null)
				or(a.idfHerd is null and b.idfHerd is not null)

			--idfObservation
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
				@idfObjectTable_tlbSpecies, 
				4572360000000,
				a.idfSpecies,
				null,
				a.idfObservation,
				b.idfObservation 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.idfObservation <> b.idfObservation) 
				or(a.idfObservation is not null and b.idfObservation is null)
				or(a.idfObservation is null and b.idfObservation is not null)

			--datStartOfSignsDate
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
				@idfObjectTable_tlbSpecies, 
				4572370000000,
				a.idfSpecies,
				null,
				a.datStartOfSignsDate,
				b.datStartOfSignsDate 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.datStartOfSignsDate <> b.datStartOfSignsDate) 
				or(a.datStartOfSignsDate is not null and b.datStartOfSignsDate is null)
				or(a.datStartOfSignsDate is null and b.datStartOfSignsDate is not null)

			--strAverageAge
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
				@idfObjectTable_tlbSpecies, 
				4572380000000,
				a.idfSpecies,
				null,
				a.strAverageAge,
				b.strAverageAge 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.strAverageAge <> b.strAverageAge) 
				or(a.strAverageAge is not null and b.strAverageAge is null)
				or(a.strAverageAge is null and b.strAverageAge is not null)

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
				@idfObjectTable_tlbSpecies, 
				4572390000000,
				a.idfSpecies,
				null,
				a.intSickAnimalQty,
				b.intSickAnimalQty 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.intSickAnimalQty <> b.intSickAnimalQty) 
				or(a.intSickAnimalQty is not null and b.intSickAnimalQty is null)
				or(a.intSickAnimalQty is null and b.intSickAnimalQty is not null)

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
				@idfObjectTable_tlbSpecies, 
				4572400000000,
				a.idfSpecies,
				null,
				a.intTotalAnimalQty,
				b.intTotalAnimalQty 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.intTotalAnimalQty <> b.intTotalAnimalQty) 
				or(a.intTotalAnimalQty is not null and b.intTotalAnimalQty is null)
				or(a.intTotalAnimalQty is null and b.intTotalAnimalQty is not null)

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
				@idfObjectTable_tlbSpecies, 
				4572410000000,
				a.idfSpecies,
				null,
				a.intDeadAnimalQty,
				b.intDeadAnimalQty 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.intDeadAnimalQty <> b.intDeadAnimalQty) 
				or(a.intDeadAnimalQty is not null and b.intDeadAnimalQty is null)
				or(a.intDeadAnimalQty is null and b.intDeadAnimalQty is not null)

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
				@idfObjectTable_tlbSpecies, 
				4572420000000,
				a.idfSpecies,
				null,
				a.strNote,
				b.strNote 
			from @tlbSpecies_BeforeEdit a  inner join @tlbSpecies_AfterEdit b on a.idfSpecies = b.idfSpecies
			where (a.strNote <> b.strNote) 
				or(a.strNote is not null and b.strNote is null)
				or(a.strNote is null and b.strNote is not null)

            IF @ObservationID IS NOT NULL --Species clinical investigation form
            BEGIN
                UPDATE dbo.tlbObservation
                SET intRowStatus = @RowStatus,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfObservation = @ObservationID;

                UPDATE dbo.tlbActivityParameters
                SET intRowStatus = @RowStatus,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfObservation = @ObservationID;
            END;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END