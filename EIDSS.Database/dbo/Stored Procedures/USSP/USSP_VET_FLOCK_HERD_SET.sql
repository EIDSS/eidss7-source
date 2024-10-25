-- ================================================================================================
-- Name: USSP_VET_FLOCK_HERD_SET
--
-- Description:	Inserts or updates herd "snapshot" for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/21/2022 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_FLOCK_HERD_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
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
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75590000000; -- tlbHerd
DECLARE @FlocksOrHerdsAfterEdit TABLE
(
    HerdID BIGINT,
    HerdActualID BIGINT,
    FarmID BIGINT,
    EIDSSHerdID NVARCHAR(200),
    SickAnimalQuantity INT,
    TotalAnimalQuantity INT,
    DeadAnimalQuantity INT,
    Note NVARCHAR(2000)
);
DECLARE @FlocksOrHerdsBeforeEdit TABLE
(
    HerdID BIGINT,
    HerdActualID BIGINT,
    FarmID BIGINT,
    EIDSSHerdID NVARCHAR(200),
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
                AuditCreateUser,
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @FlockOrHerdID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
        -- End data audit
        END
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @FlocksOrHerdsBeforeEdit
            (
                HerdID,
                HerdActualID,
                FarmID,
                EIDSSHerdID,
                SickAnimalQuantity,
                TotalAnimalQuantity,
                DeadAnimalQuantity,
                Note
            )
            SELECT idfHerd,
                   idfHerdActual,
                   idfFarm,
                   strHerdCode,
                   intSickAnimalQty,
                   intTotalAnimalQty,
                   intDeadAnimalQty,
                   strNote
            FROM dbo.tlbHerd
            WHERE idfHerd = @FlockOrHerdID;
            -- End data audit

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

            -- Data audit
            INSERT INTO @FlocksOrHerdsAfterEdit
            (
                HerdID,
                HerdActualID,
                FarmID,
                EIDSSHerdID,
                SickAnimalQuantity,
                TotalAnimalQuantity,
                DeadAnimalQuantity,
                Note
            )
            SELECT idfHerd,
                   idfHerdActual,
                   idfFarm,
                   strHerdCode,
                   intSickAnimalQty,
                   intTotalAnimalQty,
                   intDeadAnimalQty,
                   strNote
            FROM dbo.tlbHerd
            WHERE idfHerd = @FlockOrHerdID;

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
                       4572280000000,
                       a.HerdID,
                       NULL,
                       b.HerdActualID,
                       a.HerdActualID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
                WHERE (a.HerdActualID <> b.HerdActualID)
                      OR (
                             a.HerdActualID IS NOT NULL
                             AND b.HerdActualID IS NULL
                         )
                      OR (
                             a.HerdActualID IS NULL
                             AND b.HerdActualID IS NOT NULL
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
                       79280000000,
                       a.HerdID,
                       NULL,
                       b.FarmID,
                       a.FarmID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
                WHERE (a.FarmID <> b.FarmID)
                      OR (
                             a.FarmID IS NOT NULL
                             AND b.FarmID IS NULL
                         )
                      OR (
                             a.FarmID IS NULL
                             AND b.FarmID IS NOT NULL
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
                       79320000000,
                       a.HerdID,
                       NULL,
                       b.EIDSSHerdID,
                       a.EIDSSHerdID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
                WHERE (a.EIDSSHerdID <> b.EIDSSHerdID)
                      OR (
                             a.EIDSSHerdID IS NOT NULL
                             AND b.EIDSSHerdID IS NULL
                         )
                      OR (
                             a.EIDSSHerdID IS NULL
                             AND b.EIDSSHerdID IS NOT NULL
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
                       4572290000000,
                       a.HerdID,
                       NULL,
                       b.SickAnimalQuantity,
                       a.SickAnimalQuantity,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
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
                       79310000000,
                       a.HerdID,
                       NULL,
                       b.TotalAnimalQuantity,
                       a.TotalAnimalQuantity,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
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
                       79300000000,
                       a.HerdID,
                       NULL,
                       b.DeadAnimalQuantity,
                       a.DeadAnimalQuantity,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
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
                       4572300000000,
                       a.HerdID,
                       NULL,
                       b.Note,
                       a.Note,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @FlocksOrHerdsAfterEdit AS a
                    FULL JOIN @FlocksOrHerdsBeforeEdit AS b
                        ON a.HerdID = b.HerdID
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
                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                VALUES
                (@DataAuditEventid, @ObjectTableID, @FlockOrHerdID, @AuditUserName, @EIDSSObjectID);
            END
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
