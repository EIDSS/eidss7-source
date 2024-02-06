-- ================================================================================================
-- Name: USSP_VET_ANIMAL_SET
--
-- Description:	Inserts or updates animal for the livestock veterinary disease report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     03/28/2019 Changed from V6.1 get next number call to V7.
-- Stephen Long     04/17/2019 Rename params and removed strMaintenanceFlag.
-- Stephen Long     06/26/2019 Added check on EIDSS animal ID to only system assign when blank.
-- Stephen Long     04/24/2020 Added clinical signs indicator parameter.
-- Mark Wilson      10/19/2021 removed @LanguageID, added @AuditUser.
-- Stephen Long     01/19/2022 Changed row action data type.
-- Stephen Long     02/04/2022 Correction on assigning strAnimalCode.
-- Leo Tracchia		12/13/2022 added logic for data auditing 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_ANIMAL_SET]
(
    @AuditUserName NVARCHAR(200),
	@DataAuditEventID BIGINT = NULL,
    @AnimalID BIGINT OUTPUT,
    @SexTypeID BIGINT = NULL,
    @ConditionTypeID BIGINT = NULL,
    @AgeTypeID BIGINT = NULL,
    @SpeciesID BIGINT = NULL,
    @ObservationID BIGINT = NULL,
    @AnimalDescription NVARCHAR(200) = NULL,
    @EIDSSAnimalID NVARCHAR(200) = NULL,
    @AnimalName NVARCHAR(200) = NULL,
    @Color NVARCHAR(200) = NULL,
    @ClinicalSignsIndicator BIGINT = NULL,
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
		DECLARE @idfObject bigint = @AnimalID;
		DECLARE @idfObjectTable_tlbAnimal bigint = 75460000000; --select * from tauTable where strName = 'tlbAnimal'				

		DECLARE @tlbAnimal_BeforeEdit TABLE
		(
			idfAnimal bigint,
			idfObservation bigint,
			idfsAnimalAge bigint,
			idfsAnimalCondition bigint,
			idfsAnimalGender bigint,
			idfSpecies bigint,
			strAnimalCode nvarchar(200),
			strDescription nvarchar(200),
			strName nvarchar(200),
			strColor nvarchar(200)
		)		

		DECLARE @tlbAnimal_AfterEdit TABLE
		(
			idfAnimal bigint,
			idfObservation bigint,
			idfsAnimalAge bigint,
			idfsAnimalCondition bigint,
			idfsAnimalGender bigint,
			idfSpecies bigint,
			strAnimalCode nvarchar(200),
			strDescription nvarchar(200),
			strName nvarchar(200),
			strColor nvarchar(200)
		)		

		-- Data Audit

        IF @EIDSSAnimalID IS NULL 
            OR @EIDSSAnimalID = ''
        BEGIN
            EXECUTE dbo.USP_GBL_NextNumber_GET 'Animal', @EIDSSAnimalID OUTPUT, NULL;
        END;

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbAnimal',
                                              @idfsKey = @AnimalID OUTPUT;

            INSERT INTO dbo.tlbAnimal
            (
                idfAnimal,
                idfsAnimalGender,
                idfsAnimalCondition,
                idfsAnimalAge,
                idfSpecies,
                idfObservation,
                strDescription,
                strAnimalCode,
                strName,
                strColor,
                rowguid,
                intRowStatus,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM,
                idfsYNClinicalSigns
            )
            VALUES
            (
				@AnimalID,
				@SexTypeID,
				@ConditionTypeID,
				@AgeTypeID,
				@SpeciesID,
				@ObservationID,
				@AnimalDescription,
				@EIDSSAnimalID,
				@AnimalName,
				@Color,
				NEWID(),
				@RowStatus,
				NULL,
				NULL,
				10519001,
				'[{"idfAnimal":' + CAST(@AnimalID AS NVARCHAR(300)) + '}]',
				@AuditUserName,
				GETDATE(),
				@AuditUserName,
				GETDATE(),
				@ClinicalSignsIndicator
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
					@idfObjectTable_tlbAnimal, 
					@AnimalID, 
					10519001,
					'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300))
					+ ',"idfObjectTable":' + CAST(@idfObjectTable_tlbAnimal AS NVARCHAR(300)) + '}]',
					@AuditUserName
				);
			-- End data audit

        END
        ELSE
        BEGIN

			INSERT INTO @tlbAnimal_BeforeEdit (
				idfAnimal,
				idfObservation,
				idfsAnimalAge,
				idfsAnimalCondition,
				idfsAnimalGender,
				idfSpecies,
				strAnimalCode, 
				strDescription,
				strName,
				strColor
			)
			SELECT 
				idfAnimal,
				idfObservation,
				idfsAnimalAge,
				idfsAnimalCondition,
				idfsAnimalGender,
				idfSpecies,
				strAnimalCode,
				strDescription,
				strName,
				strColor
			FROM tlbAnimal WHERE idfAnimal = @AnimalID;

            UPDATE dbo.tlbAnimal
            SET idfsAnimalGender = @SexTypeID,
                idfsAnimalCondition = @ConditionTypeID,
                idfsAnimalAge = @AgeTypeID,
                idfSpecies = @SpeciesID,
                idfObservation = @ObservationID,
                strAnimalCode = @EIDSSAnimalID,
                strName = @AnimalName,
                strDescription = @AnimalDescription,
                strColor = @Color,
                idfsYNClinicalSigns = @ClinicalSignsIndicator,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfAnimal = @AnimalID;

			INSERT INTO @tlbAnimal_AfterEdit (
				idfAnimal,
				idfObservation,
				idfsAnimalAge,
				idfsAnimalCondition,
				idfsAnimalGender,
				idfSpecies,
				strAnimalCode, 
				strDescription,
				strName,
				strColor
			)
			SELECT 
				idfAnimal,
				idfObservation,
				idfsAnimalAge,
				idfsAnimalCondition,
				idfsAnimalGender,
				idfSpecies,
				strAnimalCode,
				strDescription,
				strName,
				strColor
			FROM tlbAnimal WHERE idfAnimal = @AnimalID;

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
				@idfObjectTable_tlbAnimal, 
				78280000000,
				a.idfAnimal,
				null,
				a.idfObservation,
				b.idfObservation 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.idfObservation <> b.idfObservation) 
				or(a.idfObservation is not null and b.idfObservation is null)
				or(a.idfObservation is null and b.idfObservation is not null)
				
			--idfsAnimalAge
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
				@idfObjectTable_tlbAnimal, 
				78290000000,
				a.idfAnimal,
				null,
				a.idfsAnimalAge,
				b.idfsAnimalAge 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.idfsAnimalAge <> b.idfsAnimalAge) 
				or(a.idfsAnimalAge is not null and b.idfsAnimalAge is null)
				or(a.idfsAnimalAge is null and b.idfsAnimalAge is not null)

			--idfsAnimalCondition
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
				@idfObjectTable_tlbAnimal, 
				78300000000,
				a.idfAnimal,
				null,
				a.idfsAnimalCondition,
				b.idfsAnimalCondition 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.idfsAnimalCondition <> b.idfsAnimalCondition) 
				or(a.idfsAnimalCondition is not null and b.idfsAnimalCondition is null)
				or(a.idfsAnimalCondition is null and b.idfsAnimalCondition is not null)

			--idfsAnimalGender
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
				@idfObjectTable_tlbAnimal, 
				78310000000,
				a.idfAnimal,
				null,
				a.idfsAnimalGender,
				b.idfsAnimalGender 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.idfsAnimalGender <> b.idfsAnimalGender) 
				or(a.idfsAnimalGender is not null and b.idfsAnimalGender is null)
				or(a.idfsAnimalGender is null and b.idfsAnimalGender is not null)

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
				@idfObjectTable_tlbAnimal, 
				78320000000,
				a.idfAnimal,
				null,
				a.idfSpecies,
				b.idfSpecies 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.idfSpecies <> b.idfSpecies) 
				or(a.idfSpecies is not null and b.idfSpecies is null)
				or(a.idfSpecies is null and b.idfSpecies is not null)

			--strAnimalCode
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
				@idfObjectTable_tlbAnimal, 
				78330000000,
				a.idfAnimal,
				null,
				a.strAnimalCode,
				b.strAnimalCode 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.strAnimalCode <> b.strAnimalCode) 
				or(a.strAnimalCode is not null and b.strAnimalCode is null)
				or(a.strAnimalCode is null and b.strAnimalCode is not null)

			--strDescription
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
				@idfObjectTable_tlbAnimal, 
				78340000000,
				a.idfAnimal,
				null,
				a.strDescription,
				b.strDescription 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.strDescription <> b.strDescription) 
				or(a.strDescription is not null and b.strDescription is null)
				or(a.strDescription is null and b.strDescription is not null)

			--strName
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
				@idfObjectTable_tlbAnimal, 
				4572150000000,
				a.idfAnimal,
				null,
				a.strName,
				b.strName 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.strName <> b.strName) 
				or(a.strName is not null and b.strName is null)
				or(a.strName is null and b.strName is not null)

			--strColor
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
				@idfObjectTable_tlbAnimal, 
				4572160000000,
				a.idfAnimal,
				null,
				a.strColor,
				b.strColor 
			from @tlbAnimal_BeforeEdit a  inner join @tlbAnimal_AfterEdit b on a.idfAnimal = b.idfAnimal
			where (a.strColor <> b.strColor) 
				or(a.strColor is not null and b.strColor is null)
				or(a.strColor is null and b.strColor is not null)

        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
