-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_DEL
--
-- Description:	Sets a disease report record to "inactive".
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/25/2019 Initial release.
-- Stephen Long     12/13/2019 Added comment for rollback statement.
-- Ann Xiong        03/23/2020 Added paramter @DeduplicationIndicator to skip checking 
--                             HerdFlockCount and SpeciesCount when @DeduplicationIndicator = 1
-- Ann Xiong        03/27/2020 Modified to skip checking any dependent child objects for 
--                             Deduplication.
-- Stephen Long     11/29/2021 Removed language ID parameter as it is not needed.
-- Stephen Long     12/08/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long     03/06/2023 Changed data audit call to USSP_GBL_DATA_AUDIT_EVENT_SET.
-- Ann Xiong	    03/09/2023 Added @DataAuditEventID parameter
-- Ann Xiong		03/10/2023 Added check for @DataAuditEventID IS NULL when @DeduplicationIndicator = 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_DEL]
(
    @DiseaseReportID BIGINT,
    @DeduplicationIndicator BIT = 0,
    @DataAuditEventID BIGINT = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ReturnCode INT
            = 0,
                @ReturnMessage NVARCHAR(MAX) = N'SUCCESS',
                @FarmCount AS INT = 0,
                @HerdFlockCount AS INT = 0,
                @SpeciesCount AS INT = 0,
                @AnimalCount AS INT = 0,
                @VaccinationCount AS INT = 0,
                @SampleCount AS INT = 0,
                @PensideTestCount AS INT = 0,
                @LabTestCount AS INT = 0,
                @TestInterpretationCount AS INT = 0,
                @ReportLogCount AS INT = 0,
                @OutbreakSessionCount AS INT = 0,
                @DataAuditEventTypeid BIGINT = 10016002,               -- Delete audit event type
                @ObjectTypeID BIGINT = 10017085,                       -- Veterinary disease report
                @ObjectID BIGINT = @DiseaseReportID,
                @ObjectTableID BIGINT = 75800000000,                   -- tlbVetCase
                @ObjectFarmTableID BIGINT = 75550000000,               -- tlbFarm
                @ObjectActivityParametersTableID BIGINT = 75410000000, -- tlbActivityParameters
                @ObjectObservationTableID BIGINT = 75640000000,        -- tlbObservation
                --@DataAuditEventID BIGINT,
                @AuditUserID BIGINT,
                @AuditSiteID BIGINT,
                @EIDSSObjectID NVARCHAR(200) = (
                                                   SELECT strCaseID FROM dbo.tlbVetCase WHERE idfVetCase = @DiseaseReportID
                                               ),
                @FarmID BIGINT = (
                                     SELECT idfFarm FROM dbo.tlbVetCase WHERE idfVetCase = @DiseaseReportID
                                 );
        DECLARE @ControlMeasuresObservationID BIGINT = (
                                                           SELECT idfObservation
                                                           FROM dbo.tlbVetCase
                                                           WHERE idfVetCase = @DiseaseReportID
                                                       ),
                @FarmEpiObservationID BIGINT = (
                                                   SELECT idfObservation FROM dbo.tlbFarm WHERE idfFarm = @FarmID
                                               );

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        SELECT @HerdFlockCount = COUNT(*)
        FROM dbo.tlbHerd h
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = h.idfFarm
                   AND f.intRowStatus = 0
            INNER JOIN dbo.tlbVetCase v
                ON v.idfFarm = f.idfFarm
        WHERE v.idfVetCase = @DiseaseReportID
              AND h.intRowStatus = 0;

        SELECT @SpeciesCount = COUNT(*)
        FROM dbo.tlbSpecies s
            INNER JOIN dbo.tlbHerd h
                ON h.idfHerd = s.idfHerd
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = h.idfFarm
                   AND f.intRowStatus = 0
            INNER JOIN dbo.tlbVetCase v
                ON v.idfFarm = f.idfFarm
        WHERE v.idfVetCase = @DiseaseReportID
              AND s.intRowStatus = 0;

        SELECT @AnimalCount = COUNT(*)
        FROM dbo.tlbAnimal a
            INNER JOIN dbo.tlbSpecies s
                ON s.idfSpecies = a.idfSpecies
                   AND s.intRowStatus = 0
            INNER JOIN dbo.tlbHerd h
                ON h.idfHerd = s.idfHerd
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = h.idfFarm
                   AND f.intRowStatus = 0
            INNER JOIN dbo.tlbVetCase v
                ON v.idfFarm = f.idfFarm
        WHERE v.idfVetCase = @DiseaseReportID
              AND a.intRowStatus = 0;

        SELECT @VaccinationCount = COUNT(*)
        FROM dbo.tlbVaccination
        WHERE idfVetCase = @DiseaseReportID
              AND intRowStatus = 0;

        SELECT @SampleCount = COUNT(*)
        FROM dbo.tlbMaterial
        WHERE idfVetCase = @DiseaseReportID
              AND intRowStatus = 0;

        SELECT @PensideTestCount = COUNT(*)
        FROM dbo.tlbPensideTest p
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = p.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfVetCase = @DiseaseReportID
              AND p.intRowStatus = 0;

        SELECT @LabTestCount = COUNT(*)
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfVetCase = @DiseaseReportID
              AND t.intRowStatus = 0;

        SELECT @TestInterpretationCount = COUNT(*)
        FROM dbo.tlbTestValidation tv
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = tv.idfTesting
                   AND t.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfVetCase = @DiseaseReportID
              AND tv.intRowStatus = 0;

        SELECT @ReportLogCount = COUNT(*)
        FROM dbo.tlbVetCaseLog
        WHERE idfVetCase = @DiseaseReportID
              AND intRowStatus = 0;

        SELECT @OutbreakSessionCount = COUNT(*)
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = v.idfOutbreak
                   AND o.intRowStatus = 0
        WHERE v.idfVetCase = @DiseaseReportID
              AND v.idfOutbreak IS NOT NULL

        IF @DeduplicationIndicator = 0
        BEGIN
            IF @AnimalCount = 0
               AND @VaccinationCount = 0
               AND @SampleCount = 0
               AND @PensideTestCount = 0
               AND @LabTestCount = 0
               AND @TestInterpretationCount = 0
               AND @ReportLogCount = 0
               AND @OutbreakSessionCount = 0
               AND @HerdFlockCount = 0
               AND @SpeciesCount = 0
            BEGIN
                -- Data audit
        		IF @DataAuditEventID IS NULL
        		BEGIN 
					EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @ObjectTypeID,
                                                          @DiseaseReportID,
                                                          @ObjectTableID,
                                                          @EIDSSObjectID, 
                                                          @DataAuditEventID OUTPUT;
				END
                -- End data audit

                UPDATE dbo.tlbVetCase
                SET idfParentMonitoringSession = NULL,
                    idfOutbreak = NULL
                WHERE idfVetCase = @DiseaseReportID;

                IF @ControlMeasuresObservationID IS NOT NULL
                BEGIN
                    UPDATE dbo.tlbActivityParameters
                    SET intRowStatus = 1
                    WHERE idfObservation = @ControlMeasuresObservationID
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
                    WHERE idfObservation = @ControlMeasuresObservationID
                          AND intRowStatus = 1;
                    -- End data audit

                    UPDATE dbo.tlbObservation
                    SET intRowStatus = 1
                    WHERE idfObservation = @ControlMeasuresObservationID;

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
                           @ControlMeasuresObservationID,
                           @AuditUserName,
                           @EIDSSObjectID;
                -- End data audit
                END

                UPDATE dbo.tlbVetCase
                SET intRowStatus = 1,
                    datModificationForArchiveDate = GETDATE()
                WHERE idfVetCase = @DiseaseReportID;

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
                       @ObjectTableID,
                       @DiseaseReportID,
                       @AuditUserName,
                       @EIDSSObjectID;
                -- End data audit

                IF @FarmEpiObservationID IS NOT NULL
                BEGIN
                    UPDATE dbo.tlbActivityParameters
                    SET intRowStatus = 1
                    WHERE idfObservation = @FarmEpiObservationID
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
                    WHERE idfObservation = @FarmEpiObservationID
                          AND intRowStatus = 1;
                    -- End data audit

                    UPDATE dbo.tlbObservation
                    SET intRowStatus = 1
                    WHERE idfObservation = @FarmEpiObservationID;

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
                           @FarmEpiObservationID,
                           @AuditUserName,
                           @EIDSSObjectID;
                -- End data audit
                END

                UPDATE dbo.tlbFarm
                SET intRowStatus = 1
                WHERE idfFarm =
                (
                    SELECT idfFarm FROM dbo.tlbVetCase WHERE idfVetCase = @DiseaseReportID
                );

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
                       @ObjectFarmTableID,
                       @FarmID,
                       @AuditUserName,
                       @EIDSSObjectID;
            -- End data audit
            END
            ELSE
            BEGIN
                IF @OutbreakSessionCount > 0
                BEGIN
                    SET @ReturnCode = 2;
                    SET @ReturnMessage = 'Unable to delete this record as it is dependent on another object.';
                END;
                ELSE
                BEGIN
                    SET @ReturnCode = 1;
                    SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
                END;
            END;
        END
        ELSE
        BEGIN
            -- Data audit
        	IF @DataAuditEventID IS NULL
        	BEGIN 
				EXEC dbo.USSP_GBL_DataAuditEvent_GET @AuditUserID,
                                                 @AuditSiteID,
                                                 @DataAuditEventTypeID,
                                                 @ObjectTypeID,
                                                 @ObjectID,
                                                 @ObjectTableID,
                                                 @DataAuditEventID OUTPUT;
			END

            UPDATE dbo.tlbVetCase
            SET idfParentMonitoringSession = NULL,
                idfOutbreak = NULL
            WHERE idfVetCase = @DiseaseReportID;

            IF @ControlMeasuresObservationID IS NOT NULL
            BEGIN
                UPDATE dbo.tlbActivityParameters
                SET intRowStatus = 1
                WHERE idfObservation = @ControlMeasuresObservationID
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
                WHERE idfObservation = @ControlMeasuresObservationID
                      AND intRowStatus = 1;
                -- End data audit

                UPDATE dbo.tlbObservation
                SET intRowStatus = 1
                WHERE idfObservation = @ControlMeasuresObservationID;

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
                       @ControlMeasuresObservationID,
                       @AuditUserName,
                       @EIDSSObjectID;
            -- End data audit
            END

            UPDATE dbo.tlbVetCase
            SET intRowStatus = 1,
                datModificationForArchiveDate = GETDATE()
            WHERE idfVetCase = @DiseaseReportID;

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
                   @ObjectTableID,
                   @DiseaseReportID,
                   @AuditUserName,
                   @EIDSSObjectID;
            -- End data audit

            IF @FarmEpiObservationID IS NOT NULL
            BEGIN
                UPDATE dbo.tlbActivityParameters
                SET intRowStatus = 1
                WHERE idfObservation = @FarmEpiObservationID
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
                WHERE idfObservation = @FarmEpiObservationID
                      AND intRowStatus = 0;
                -- End data audit

                UPDATE dbo.tlbObservation
                SET intRowStatus = 1
                WHERE idfObservation = @FarmEpiObservationID;

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
                       @FarmEpiObservationID,
                       @AuditUserName,
                       @EIDSSObjectID;
            -- End data audit
            END

            UPDATE dbo.tlbFarm
            SET intRowStatus = 1
            WHERE idfFarm =
            (
                SELECT idfFarm FROM dbo.tlbVetCase WHERE idfVetCase = @DiseaseReportID
            );

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
                   @ObjectFarmTableID,
                   @FarmID,
                   @AuditUserName,
                   @EIDSSObjectID;
        -- End data audit
        END

        IF @@TRANCOUNT > 0
           AND @returnCode = 0
            COMMIT;
        ELSE
            ROLLBACK;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
