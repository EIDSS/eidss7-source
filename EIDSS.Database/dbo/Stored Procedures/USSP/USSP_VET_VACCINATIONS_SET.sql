-- ================================================================================================
-- Name: USSP_VET_VACCINATIONS_SET
--
-- Description:	Inserts or updates vaccination info for the veterinary disease report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/07/2022 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_VACCINATIONS_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @VaccinationID BIGINT OUTPUT,
    @VeterinaryDieaseReportID BIGINT,
    @SpeciesID BIGINT = NULL,
    @VaccinationTypeID BIGINT = NULL,
    @VaccinationRouteTypeID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @VaccinationDate DATETIME = NULL,
    @Manufacturer NVARCHAR(200) = NULL,
    @LotNumber NVARCHAR(200) = NULL,
    @NumberVaccinated INT = NULL,
    @Comments NVARCHAR(2000) = NULL,
    @RowStatus INT,
    @RowAction INT
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75790000000; -- tlbVaccination
DECLARE @VaccinationsAfterEdit TABLE
(
    VaccinationID BIGINT,
    DiseaseReportID BIGINT,
    SpeciesID BIGINT,
    VaccinationTypeID BIGINT,
    VaccinationRouteTypeID BIGINT,
    DiseaseID BIGINT,
    VaccinationDate DATETIME,
    Manufacturer NVARCHAR(200),
    LotNumber NVARCHAR(200),
    NumberVaccinated INT,
    Note NVARCHAR(2000)
);
DECLARE @VaccinationsBeforeEdit TABLE
(
    VaccinationID BIGINT,
    DiseaseReportID BIGINT,
    SpeciesID BIGINT,
    VaccinationTypeID BIGINT,
    VaccinationRouteTypeID BIGINT,
    DiseaseID BIGINT,
    VaccinationDate DATETIME,
    Manufacturer NVARCHAR(200),
    LotNumber NVARCHAR(200),
    NumberVaccinated INT,
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
            EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbVaccination',
                                           @idfsKey = @VaccinationID OUTPUT;

            INSERT INTO dbo.tlbVaccination
            (
                idfVaccination,
                idfVetCase,
                idfSpecies,
                idfsVaccinationType,
                idfsVaccinationRoute,
                idfsDiagnosis,
                datVaccinationDate,
                strManufacturer,
                strLotNumber,
                intNumberVaccinated,
                strNote,
                intRowStatus,
                rowguid,
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
            (@VaccinationID,
             @VeterinaryDieaseReportID,
             @SpeciesID,
             @VaccinationTypeID,
             @VaccinationRouteTypeID,
             @DiseaseID,
             @VaccinationDate,
             @Manufacturer,
             @LotNumber,
             @NumberVaccinated,
             @Comments,
             @RowStatus,
             NEWID(),
             NULL,
             NULL,
             10519001,
             '[{"idfVaccination":' + CAST(@VaccinationID AS NVARCHAR(300)) + '}]',
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
             @VaccinationID,
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
            INSERT INTO @VaccinationsBeforeEdit
            (
                VaccinationID,
                DiseaseReportID,
                SpeciesID,
                VaccinationTypeID,
                VaccinationRouteTypeID,
                DiseaseID,
                VaccinationDate,
                Manufacturer,
                LotNumber,
                NumberVaccinated,
                Note
            )
            SELECT idfVaccination,
                   idfVetCase,
                   idfSpecies,
                   idfsVaccinationType,
                   idfsVaccinationRoute,
                   idfsDiagnosis,
                   datVaccinationDate,
                   strManufacturer,
                   strLotNumber,
                   intNumberVaccinated,
                   strNote
            FROM dbo.tlbVaccination
            WHERE idfVaccination = @VaccinationID;
            -- End data audit

            UPDATE dbo.tlbVaccination
            SET idfVetCase = @VeterinaryDieaseReportID,
                idfSpecies = @SpeciesID,
                idfsVaccinationType = @VaccinationTypeID,
                idfsVaccinationRoute = @VaccinationRouteTypeID,
                idfsDiagnosis = @DiseaseID,
                datVaccinationDate = @VaccinationDate,
                strManufacturer = @Manufacturer,
                strLotNumber = @LotNumber,
                intNumberVaccinated = @NumberVaccinated,
                strNote = @Comments,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfVaccination = @VaccinationID;

            -- Data audit
            INSERT INTO @VaccinationsAfterEdit
            (
                VaccinationID,
                DiseaseReportID,
                SpeciesID,
                VaccinationTypeID,
                VaccinationRouteTypeID,
                DiseaseID,
                VaccinationDate,
                Manufacturer,
                LotNumber,
                NumberVaccinated,
                Note
            )
            SELECT idfVaccination,
                   idfVetCase,
                   idfSpecies,
                   idfsVaccinationType,
                   idfsVaccinationRoute,
                   idfsDiagnosis,
                   datVaccinationDate,
                   strManufacturer,
                   strLotNumber,
                   intNumberVaccinated,
                   strNote
            FROM dbo.tlbVaccination
            WHERE idfVaccination = @VaccinationID;

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
                       4577960000000,
                       a.VaccinationID,
                       NULL,
                       b.DiseaseReportID,
                       a.DiseaseReportID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.DiseaseReportID <> b.DiseaseReportID)
                      OR (
                             a.DiseaseReportID IS NOT NULL
                             AND b.DiseaseReportID IS NULL
                         )
                      OR (
                             a.DiseaseReportID IS NULL
                             AND b.DiseaseReportID IS NOT NULL
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
                       4577970000000,
                       a.VaccinationID,
                       NULL,
                       b.SpeciesID,
                       a.SpeciesID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.SpeciesID <> b.SpeciesID)
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
                       80800000000,
                       a.VaccinationID,
                       NULL,
                       b.VaccinationTypeID,
                       a.VaccinationTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.VaccinationTypeID <> b.VaccinationTypeID)
                      OR (
                             a.VaccinationTypeID IS NOT NULL
                             AND b.VaccinationTypeID IS NULL
                         )
                      OR (
                             a.VaccinationTypeID IS NULL
                             AND b.VaccinationTypeID IS NOT NULL
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
                       4577980000000,
                       a.VaccinationID,
                       NULL,
                       b.VaccinationRouteTypeID,
                       a.VaccinationRouteTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.VaccinationRouteTypeID <> b.VaccinationRouteTypeID)
                      OR (
                             a.VaccinationRouteTypeID IS NOT NULL
                             AND b.VaccinationRouteTypeID IS NULL
                         )
                      OR (
                             a.VaccinationRouteTypeID IS NULL
                             AND b.VaccinationRouteTypeID IS NOT NULL
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
                       80790000000,
                       a.VaccinationID,
                       NULL,
                       b.DiseaseID,
                       a.DiseaseID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.DiseaseID <> b.DiseaseID)
                      OR (
                             a.DiseaseID IS NOT NULL
                             AND b.DiseaseID IS NULL
                         )
                      OR (
                             a.DiseaseID IS NULL
                             AND b.DiseaseID IS NOT NULL
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
                       80780000000,
                       a.VaccinationID,
                       NULL,
                       b.VaccinationDate,
                       a.VaccinationDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.VaccinationDate <> b.VaccinationDate)
                      OR (
                             a.VaccinationDate IS NOT NULL
                             AND b.VaccinationDate IS NULL
                         )
                      OR (
                             a.VaccinationDate IS NULL
                             AND b.VaccinationDate IS NOT NULL
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
                       80840000000,
                       a.VaccinationID,
                       NULL,
                       b.Manufacturer,
                       a.Manufacturer,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.Manufacturer <> b.Manufacturer)
                      OR (
                             a.Manufacturer IS NOT NULL
                             AND b.Manufacturer IS NULL
                         )
                      OR (
                             a.Manufacturer IS NULL
                             AND b.Manufacturer IS NOT NULL
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
                       80830000000,
                       a.VaccinationID,
                       NULL,
                       b.LotNumber,
                       a.LotNumber,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.LotNumber <> b.LotNumber)
                      OR (
                             a.LotNumber IS NOT NULL
                             AND b.LotNumber IS NULL
                         )
                      OR (
                             a.LotNumber IS NULL
                             AND b.LotNumber IS NOT NULL
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
                       80820000000,
                       a.VaccinationID,
                       NULL,
                       b.NumberVaccinated,
                       a.NumberVaccinated,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
                WHERE (a.NumberVaccinated <> b.NumberVaccinated)
                      OR (
                             a.NumberVaccinated IS NOT NULL
                             AND b.NumberVaccinated IS NULL
                         )
                      OR (
                             a.NumberVaccinated IS NULL
                             AND b.NumberVaccinated IS NOT NULL
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
                       4577990000000,
                       a.VaccinationID,
                       NULL,
                       b.Note,
                       a.Note,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VaccinationsAfterEdit AS a
                    FULL JOIN @VaccinationsBeforeEdit AS b
                        ON a.VaccinationID = b.VaccinationID
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
                (@DataAuditEventid, @ObjectTableID, @VaccinationID, @AuditUserName, @EIDSSObjectID);
            END
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
