-- ================================================================================================
-- Name: USSP_VET_FARM_COPY
--
-- Description:	Get farm actual detail and copies to the farm table.  This includes the associated 
-- child records for the farm address and the farm owner (human table).
--
-- This is typically called from the veterinary disease report set stored procedure.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/08/2019 Initial release.
-- Stephen Long     05/13/2019 Fix to call of USP_GBL_GEOLOCATION_COPY to use 0 on the copy 
--                             default.
-- Stephen Long     05/26/2019 Added observation ID parameter.
-- Stephen Long     06/10/2019 Added farm owner ID as output parameter.
-- Stephen Long     06/24/2019 Split out farm owner ID from new farm owner ID to better work with 
--                             POCO.
-- Stephen Long     07/23/2019 Correction on update statement with the avian/livestock counts.
-- Stephen Long     08/14/2019 Fix for defect 4836.  Copy of human actual to human was not 
--                             functioning as expected.
-- Stephen Long     12/23/2019 Added latitude and longitude parameters.
-- Mark Wilson      10/19/2021 Added @AuditUser and updated insert to tlbFarm.
-- Stephen Long     01/19/2022 Added audit user name to geolocation update statement.
-- Stephen Long     01/23/2022 Removed suppress select; SQL throwing nested insert/exec exceptions.
-- Stephen Long     01/27/2022 Changes to only update fields allowed to be updated from a disease 
--                             report.
-- Mike Kornegay	02/15/2022 Added idfMonitoringSession to update for tlbFarms for the Vet Surveillance 
--							   use cases and added COALESCE to leave dead and sick animal fields alone
--							   in the case of Vet Surveillance.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_FARM_COPY]
(
    @AuditUserName NVARCHAR(200),
    @FarmMasterID BIGINT,
    @AvianTotalAnimalQuantity INT = NULL,
    @AvianSickAnimalQuantity INT = NULL,
    @AvianDeadAnimalQuantity INT = NULL,
    @LivestockTotalAnimalQuantity INT = NULL,
    @LivestockSickAnimalQuantity INT = NULL,
    @LivestockDeadAnimalQuantity INT = NULL,
    @Latitude FLOAT = NULL,
    @Longitude FLOAT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @ObservationID BIGINT = NULL,
    @FarmOwnerID BIGINT = NULL,
    @FarmID BIGINT = NULL OUTPUT,
    @NewFarmOwnerID BIGINT = NULL OUTPUT
)
AS
DECLARE @FarmAddressID BIGINT;
DECLARE @RootFarmAddressID BIGINT;
DECLARE @HumanID BIGINT;
DECLARE @HumanMasterID BIGINT;
DECLARE @ReturnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'Vet Farm Copy Success';

BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT @RootFarmAddressID = idfFarmAddress,
               @HumanMasterID = idfHumanActual
        FROM dbo.tlbFarmActual
        WHERE idfFarmActual = @FarmMasterID;

        IF NOT EXISTS (SELECT * FROM dbo.tlbFarm WHERE idfFarm = @FarmID)
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbFarm',
                                              @idfsKey = @FarmID OUTPUT;

            SET @FarmOwnerID = NULL;
        END;

        -- Get new FarmAddressID.
        SET @FarmAddressID = NULL;

        SELECT @FarmAddressID = idfFarmAddress
        FROM dbo.tlbFarm
        WHERE idfFarm = @FarmID;

        IF @FarmAddressID IS NULL
           AND NOT @RootFarmAddressID IS NULL
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbGeoLocation',
                                              @idfsKey = @FarmAddressID OUTPUT;

            -- Copy address from root farm.
            EXECUTE dbo.USP_GBL_GEOLOCATION_COPY @RootFarmAddressID,
                                                 @FarmAddressID,
                                                 0,
                                                 @ReturnCode,
                                                 @ReturnMessage;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy farm address.'

                SELECT @ReturnCode,
                       @ReturnMessage

                RETURN
            END
        END

        IF @FarmOwnerID IS NULL
           AND NOT @HumanMasterID IS NULL
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbHuman',
                                              @idfsKey = @NewFarmOwnerID OUTPUT;

            -- Copy root human actual to human snapshot for the farm owner.
            EXECUTE dbo.USP_HUM_COPYHUMANACTUALTOHUMAN @HumanMasterID,
                                                       @NewFarmOwnerID,
                                                       @ReturnCode,
                                                       @ReturnMessage;

            SET @FarmOwnerID = @NewFarmOwnerID;

            IF @returnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy human (farm owner).';

                SELECT @ReturnCode,
                       @ReturnMessage;

                RETURN;
            END
        END

        IF EXISTS (SELECT * FROM dbo.tlbFarm WHERE idfFarm = @FarmID)
        BEGIN
            UPDATE dbo.tlbFarm
            SET intLivestockTotalAnimalQty = @LivestockTotalAnimalQuantity,
                intAvianTotalAnimalQty = @AvianTotalAnimalQuantity,
                intLivestockSickAnimalQty = COALESCE(@LivestockSickAnimalQuantity, f.intLivestockSickAnimalQty),
                intAvianSickAnimalQty = COALESCE(@AvianSickAnimalQuantity, f.intAvianSickAnimalQty),
                intLivestockDeadAnimalQty = COALESCE(@LivestockDeadAnimalQuantity, f.intLivestockDeadAnimalQty),
                intAvianDeadAnimalQty = COALESCE(@AvianDeadAnimalQuantity, f.intAvianDeadAnimalQty),
				idfMonitoringSession = @MonitoringSessionID,
                idfObservation = @ObservationID,
                datModificationDate = GETDATE(),
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            FROM dbo.tlbFarm f
                INNER JOIN dbo.tlbFarmActual fa
                    ON fa.idfFarmActual = f.idfFarmActual
            WHERE f.idfFarm = @FarmID;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.tlbFarm
            (
                idfFarm,
                idfFarmActual,
                idfMonitoringSession,
                idfsFarmCategory,
                idfsOwnershipStructure,
                idfHuman,
                idfFarmAddress,
                strNationalName,
                strFarmCode,
                strFax,
                strEmail,
                strContactPhone,
                intLivestockTotalAnimalQty,
                intAvianTotalAnimalQty,
                intLivestockSickAnimalQty,
                intAvianSickAnimalQty,
                intLivestockDeadAnimalQty,
                intAvianDeadAnimalQty,
                strNote,
                rowguid,
                intRowStatus,
                intHACode,
                idfObservation,
                datModificationDate,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            SELECT @FarmID,
                   @FarmMasterID,
                   @MonitoringSessionID,
                   idfsFarmCategory,
                   idfsOwnershipStructure,
                   @FarmOwnerID,
                   @FarmAddressID,
                   strNationalName,
                   strFarmCode,
                   strFax,
                   strEmail,
                   strContactPhone,
                   @LivestockTotalAnimalQuantity,
                   @AvianTotalAnimalQuantity,
                   @LivestockSickAnimalQuantity,
                   @AvianSickAnimalQuantity,
                   @LivestockDeadAnimalQuantity,
                   @AvianDeadAnimalQuantity,
                   strNote,
                   NEWID(),
                   0,
                   NULL,
                   @ObservationID,
                   GETDATE(),
                   NULL,
                   NULL,
                   10519001,
                   '[{"idfFarm":' + CAST(@FarmID AS NVARCHAR(300)) + '}]',
                   @AuditUserName,
                   GETDATE(),
                   @AuditUserName,
                   GETDATE()
            FROM dbo.tlbFarmActual 
            WHERE idfFarmActual = @FarmMasterID;
        END;

        IF @FarmAddressID IS NOT NULL
        BEGIN
            UPDATE dbo.tlbGeoLocation
            SET dblLatitude = @Latitude,
                dblLongitude = @Longitude,
                AuditUpdateUser = @AuditUserName
            WHERE idfGeoLocation = @FarmAddressID;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
