-- ================================================================================================
-- Name: USSP_VET_ANIMALS_SET
--
-- Description:	Inserts or updates animal for the livestock veterinary disease report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/07/2022 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_ANIMALS_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
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
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75460000000,                   -- tlbAnimal
        @ObjectActivityParametersTableID BIGINT = 75410000000, -- tlbActivityParameters
        @ObjectObservationTableID BIGINT = 75640000000;        -- tlbObservation
DECLARE @AnimalsAfterEdit TABLE
(
    AnimalID BIGINT,
    AnimalGenderTypeID BIGINT,
    AnimalConditionTypeID BIGINT,
    AnimalAgeTypeID BIGINT,
    SpeciesID BIGINT,
    ObservationID BIGINT,
    AnimalDescription NVARCHAR(200),
    EIDSSAnimalID NVARCHAR(200),
    AnimalName NVARCHAR(200),
    Color NVARCHAR(200)
);
DECLARE @AnimalsBeforeEdit TABLE
(
    AnimalID BIGINT,
    AnimalGenderTypeID BIGINT,
    AnimalConditionTypeID BIGINT,
    AnimalAgeTypeID BIGINT,
    SpeciesID BIGINT,
    ObservationID BIGINT,
    AnimalDescription NVARCHAR(200),
    EIDSSAnimalID NVARCHAR(200),
    AnimalName NVARCHAR(200),
    Color NVARCHAR(200)
);

BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

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
            (@AnimalID,
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
                AuditCreateUser,
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @AnimalID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );

            -- Update data audit event ID on tlbObservation and tlbActivityParameters
            -- for flexible forms saved outside this DB transaction.
            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @EIDSSObjectID
            WHERE idfObject = @ObservationID
                  AND idfDataAuditEvent IS NULL;
        -- End data audit
        END
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @AnimalsBeforeEdit
            (
                AnimalID,
                AnimalGenderTypeID,
                AnimalConditionTypeID,
                AnimalAgeTypeID,
                SpeciesID,
                ObservationID,
                AnimalDescription,
                EIDSSAnimalID,
                AnimalName,
                Color
            )
            SELECT idfAnimal,
                   idfsAnimalGender,
                   idfsAnimalCondition,
                   idfsAnimalAge,
                   idfSpecies,
                   idfObservation,
                   strDescription,
                   strAnimalCode,
                   strName,
                   strColor
            FROM dbo.tlbAnimal
            WHERE idfAnimal = @AnimalID;
            -- End data audit

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

            -- Data audit
            INSERT INTO @AnimalsAfterEdit
            (
                AnimalID,
                AnimalGenderTypeID,
                AnimalConditionTypeID,
                AnimalAgeTypeID,
                SpeciesID,
                ObservationID,
                AnimalDescription,
                EIDSSAnimalID,
                AnimalName,
                Color
            )
            SELECT idfAnimal,
                   idfsAnimalGender,
                   idfsAnimalCondition,
                   idfsAnimalAge,
                   idfSpecies,
                   idfObservation,
                   strDescription,
                   strAnimalCode,
                   strName,
                   strColor
            FROM dbo.tlbAnimal
            WHERE idfAnimal = @AnimalID;

            -- Update data audit event ID on tlbObservation and tlbActivityParameters
            -- for flexible forms saved outside this DB transaction.
            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @EIDSSObjectID
            WHERE idfObject = @ObservationID
                  AND idfDataAuditEvent IS NULL;

            IF @RowStatus = 0
            BEGIN
                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78310000000,
                       a.AnimalID,
                       NULL,
                       b.AnimalGenderTypeID,
                       a.AnimalGenderTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.AnimalGenderTypeID <> b.AnimalGenderTypeID)
                      OR (
                             a.AnimalGenderTypeID IS NOT NULL
                             AND b.AnimalGenderTypeID IS NULL
                         )
                      OR (
                             a.AnimalGenderTypeID IS NULL
                             AND b.AnimalGenderTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78300000000,
                       a.AnimalID,
                       NULL,
                       b.AnimalConditionTypeID,
                       a.AnimalConditionTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.AnimalConditionTypeID <> b.AnimalConditionTypeID)
                      OR (
                             a.AnimalConditionTypeID IS NOT NULL
                             AND b.AnimalConditionTypeID IS NULL
                         )
                      OR (
                             a.AnimalConditionTypeID IS NULL
                             AND b.AnimalConditionTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78290000000,
                       a.AnimalID,
                       NULL,
                       b.AnimalAgeTypeID,
                       a.AnimalAgeTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.AnimalAgeTypeID <> b.AnimalAgeTypeID)
                      OR (
                             a.AnimalAgeTypeID IS NOT NULL
                             AND b.AnimalAgeTypeID IS NULL
                         )
                      OR (
                             a.AnimalAgeTypeID IS NULL
                             AND b.AnimalAgeTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78320000000,
                       a.AnimalID,
                       NULL,
                       b.SpeciesID,
                       a.SpeciesID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.SpeciesID <> b.SpeciesID)
                      OR (
                             a.SpeciesID IS NOT NULL
                             AND b.SpeciesID IS NULL
                         )
                      OR (
                             a.SpeciesID IS NULL
                             AND b.SpeciesID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78280000000,
                       a.AnimalID,
                       NULL,
                       b.ObservationID,
                       a.ObservationID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.ObservationID <> b.ObservationID)
                      OR (
                             a.ObservationID IS NOT NULL
                             AND b.ObservationID IS NULL
                         )
                      OR (
                             a.ObservationID IS NULL
                             AND b.ObservationID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78340000000,
                       a.AnimalID,
                       NULL,
                       b.AnimalDescription,
                       a.AnimalDescription,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.AnimalDescription <> b.AnimalDescription)
                      OR (
                             a.AnimalDescription IS NOT NULL
                             AND b.AnimalDescription IS NULL
                         )
                      OR (
                             a.AnimalDescription IS NULL
                             AND b.AnimalDescription IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       78330000000,
                       a.AnimalID,
                       NULL,
                       b.EIDSSAnimalID,
                       a.EIDSSAnimalID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.EIDSSAnimalID <> b.EIDSSAnimalID)
                      OR (
                             a.EIDSSAnimalID IS NOT NULL
                             AND b.EIDSSAnimalID IS NULL
                         )
                      OR (
                             a.EIDSSAnimalID IS NULL
                             AND b.EIDSSAnimalID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       4572150000000,
                       a.AnimalID,
                       NULL,
                       b.AnimalName,
                       a.AnimalName,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.AnimalName <> b.AnimalName)
                      OR (
                             a.AnimalName IS NOT NULL
                             AND b.AnimalName IS NULL
                         )
                      OR (
                             a.AnimalName IS NULL
                             AND b.AnimalName IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       4572160000000,
                       a.AnimalID,
                       NULL,
                       b.Color,
                       a.Color,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @AnimalsAfterEdit AS a
                    FULL JOIN @AnimalsBeforeEdit AS b
                        ON a.AnimalID = b.AnimalID
                where (a.Color <> b.Color)
                      OR (
                             a.Color IS NOT NULL
                             AND b.Color IS NULL
                         )
                      OR (
                             a.Color IS NULL
                             AND b.Color IS NOT NULL
                         );
            END
            ELSE
            BEGIN
                IF @ObservationID IS NOT NULL
                BEGIN
                    UPDATE dbo.tlbActivityParameters
                    SET intRowStatus = 1
                    WHERE idfObservation = @ObservationID
                          AND intRowStatus = 0;

                    -- Data audit
                    INSERT INTO dbo.tauDataAuditDetailDelete
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectActivityParametersTableID,
                           idfActivityParameters,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM dbo.tlbActivityParameters
                    WHERE idfObservation = @ObservationID
                          AND intRowStatus = 1;
                    -- End data audit

                    UPDATE dbo.tlbObservation
                    SET intRowStatus = 1
                    WHERE idfObservation = @ObservationID;

                    -- Data audit
                    INSERT INTO dbo.tauDataAuditDetailDelete
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        AuditCreateUser,
                        strObject
                    )
                    SELECT @DataAuditEventID,
                           @ObjectObservationTableID,
                           @ObservationID,
                           @AuditUserName,
                           @EIDSSObjectID;
                --End data audit
                END

                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                VALUES
                (@DataAuditEventid, @ObjectTableID, @AnimalID, @AuditUserName, @EIDSSObjectID);
            END
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
