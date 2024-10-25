-- ================================================================================================
-- Name: USSP_VET_SPECIES_WITH_AUDITING_SET
--
-- Description:	Inserts or updates species for the veterinary disease report and monitoring 
-- session use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/07/2022 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_SPECIES_WITH_AUDITING_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
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
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75710000000,                   -- tlbSpecies
        @ObjectActivityParametersTableID BIGINT = 75410000000, -- tlbActivityParameters
        @ObjectObservationTableID BIGINT = 75640000000;        -- tlbObservation
DECLARE @SpeciesAfterEdit TABLE
(
    SpeciesID BIGINT,
    SpeciesActualID BIGINT,
    SpeciesTypeID BIGINT,
    HerdID BIGINT,
    ObservationID BIGINT,
    StartOfSignsDate DATETIME,
    AverageAge NVARCHAR(200),
    SickAnimalQuantity INT,
    TotalAnimalQuantity INT,
    DeadAnimalQuantity INT,
    Note NVARCHAR(2000)
);
DECLARE @SpeciesBeforeEdit TABLE
(
    SpeciesID BIGINT,
    SpeciesActualID BIGINT,
    SpeciesTypeID BIGINT,
    HerdID BIGINT,
    ObservationID BIGINT,
    StartOfSignsDate DATETIME,
    AverageAge NVARCHAR(200),
    SickAnimalQuantity INT,
    TotalAnimalQuantity INT,
    DeadAnimalQuantity INT,
    Note NVARCHAR(2000)
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
            VALUES
            (@SpeciesID,
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
                AuditCreateUser,
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @SpeciesID,
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
            INSERT INTO @SpeciesBeforeEdit
            (
                SpeciesID,
                SpeciesActualID,
                SpeciesTypeID,
                HerdID,
                ObservationID,
                StartOfSignsDate,
                AverageAge,
                SickAnimalQuantity,
                TotalAnimalQuantity,
                DeadAnimalQuantity,
                Note
            )
            SELECT idfSpecies,
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
            FROM dbo.tlbSpecies
            WHERE idfSpecies = @SpeciesID;
            -- End data audit

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

            -- Data audit
            INSERT INTO @SpeciesAfterEdit
            (
                SpeciesID,
                SpeciesActualID,
                SpeciesTypeID,
                HerdID,
                ObservationID,
                StartOfSignsDate,
                AverageAge,
                SickAnimalQuantity,
                TotalAnimalQuantity,
                DeadAnimalQuantity,
                Note
            )
            SELECT idfSpecies,
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
            FROM dbo.tlbSpecies
            WHERE idfSpecies = @SpeciesID;
            -- End data audit

            IF @ObservationID IS NOT NULL -- Species clinical investigation form
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

                -- Update data audit event ID on tlbObservation and tlbActivityParameters
                -- for flexible forms saved outside this DB transaction.
                UPDATE dbo.tauDataAuditDetailCreate
                SET idfDataAuditEvent = @DataAuditEventID,
                    strObject = @EIDSSObjectID
                WHERE idfObject = @ObservationID
                      AND idfDataAuditEvent IS NULL;
            END;

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
                       4572330000000,
                       a.SpeciesID,
                       NULL,
                       b.SpeciesActualID,
                       a.SpeciesActualID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.SpeciesActualID <> b.SpeciesActualID)
                      OR (
                             a.SpeciesActualID IS NOT NULL
                             AND b.SpeciesActualID IS NULL
                         )
                      OR (
                             a.SpeciesActualID IS NULL
                             AND b.SpeciesActualID IS NOT NULL
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
                       4572340000000,
                       a.SpeciesID,
                       NULL,
                       b.SpeciesTypeID,
                       a.SpeciesTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.SpeciesTypeID <> b.SpeciesTypeID)
                      OR (
                             a.SpeciesTypeID IS NOT NULL
                             AND b.SpeciesTypeID IS NULL
                         )
                      OR (
                             a.SpeciesTypeID IS NULL
                             AND b.SpeciesTypeID IS NOT NULL
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
                       4572350000000,
                       a.SpeciesID,
                       NULL,
                       b.HerdID,
                       a.HerdID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.HerdID <> b.HerdID)
                      OR (
                             a.HerdID IS NOT NULL
                             AND b.HerdID IS NULL
                         )
                      OR (
                             a.HerdID IS NULL
                             AND b.HerdID IS NOT NULL
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
                       4572360000000,
                       a.SpeciesID,
                       NULL,
                       b.ObservationID,
                       a.ObservationID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.ObservationID <> b.ObservationID)
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
                       4572370000000,
                       a.SpeciesID,
                       NULL,
                       b.StartOfSignsDate,
                       a.StartOfSignsDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.StartOfSignsDate <> b.StartOfSignsDate)
                      OR (
                             a.StartOfSignsDate IS NOT NULL
                             AND b.StartOfSignsDate IS NULL
                         )
                      OR (
                             a.StartOfSignsDate IS NULL
                             AND b.StartOfSignsDate IS NOT NULL
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
                       4572380000000,
                       a.SpeciesID,
                       NULL,
                       b.AverageAge,
                       a.AverageAge,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.AverageAge <> b.AverageAge)
                      OR (
                             a.AverageAge IS NOT NULL
                             AND b.AverageAge IS NULL
                         )
                      OR (
                             a.AverageAge IS NULL
                             AND b.AverageAge IS NOT NULL
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
                       4572390000000,
                       a.SpeciesID,
                       NULL,
                       b.SickAnimalQuantity,
                       a.SickAnimalQuantity,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.SickAnimalQuantity <> b.SickAnimalQuantity)
                      OR (
                             a.SickAnimalQuantity IS NOT NULL
                             AND b.SickAnimalQuantity IS NULL
                         )
                      OR (
                             a.SickAnimalQuantity IS NULL
                             AND b.SickAnimalQuantity IS NOT NULL
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
                       4572400000000,
                       a.SpeciesID,
                       NULL,
                       b.TotalAnimalQuantity,
                       a.TotalAnimalQuantity,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.TotalAnimalQuantity <> b.TotalAnimalQuantity)
                      OR (
                             a.TotalAnimalQuantity IS NOT NULL
                             AND b.TotalAnimalQuantity IS NULL
                         )
                      OR (
                             a.TotalAnimalQuantity IS NULL
                             AND b.TotalAnimalQuantity IS NOT NULL
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
                       4572410000000,
                       a.SpeciesID,
                       NULL,
                       b.DeadAnimalQuantity,
                       a.DeadAnimalQuantity,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.DeadAnimalQuantity <> b.DeadAnimalQuantity)
                      OR (
                             a.DeadAnimalQuantity IS NOT NULL
                             AND b.DeadAnimalQuantity IS NULL
                         )
                      OR (
                             a.DeadAnimalQuantity IS NULL
                             AND b.DeadAnimalQuantity IS NOT NULL
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
                       4572420000000,
                       a.SpeciesID,
                       NULL,
                       b.Note,
                       a.Note,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SpeciesAfterEdit AS a
                    FULL JOIN @SpeciesBeforeEdit AS b
                        ON a.SpeciesID = b.SpeciesID
                WHERE (a.Note <> b.Note)
                      OR (
                             a.Note IS NOT NULL
                             AND b.Note IS NULL
                         )
                      OR (
                             a.Note IS NULL
                             AND b.Note IS NOT NULL
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
                (@DataAuditEventid, @ObjectTableID, @SpeciesID, @AuditUserName, @EIDSSObjectID);
            END
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
