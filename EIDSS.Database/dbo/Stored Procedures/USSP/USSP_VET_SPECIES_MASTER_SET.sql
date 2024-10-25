-- ================================================================================================
-- Name: USSP_VET_SPECIES_MASTER_SET
--
-- Description:	Inserts or updates species actual for the avian veterinary disease report use 
-- cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/10/2019 Initial release.
-- Stephen Long     04/23/2019 Changed specied master ID parameter to include OUTPUT.
-- Mark Wilson      10/19/2021 Added @AuditUser, Removed @languageID, @ObservationID.
-- Stephen Long     01/19/2022 Changed row action data type.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_SPECIES_MASTER_SET]
(
    @AuditUserName NVARCHAR(200),
    @SpeciesMasterID BIGINT = NULL OUTPUT,
    @SpeciesTypeID BIGINT,
    @HerdMasterID BIGINT = NULL,
    @StartOfSignsDate DATETIME = NULL,
    @AverageAge NVARCHAR(200) = NULL,
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
        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbSpeciesActual',
                                              @idfsKey = @SpeciesMasterID OUTPUT;

            INSERT INTO dbo.tlbSpeciesActual
            (
                idfSpeciesActual,
                idfsSpeciesType,
                idfHerdActual,
                datStartOfSignsDate,
                strAverageAge,
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
            (@SpeciesMasterID,
             @SpeciesTypeID,
             @HerdMasterID,
             @StartOfSignsDate,
             @AverageAge,
             @SickAnimalQuantity,
             @TotalAnimalQuantity,
             @DeadAnimalQuantity,
             @Note,
             NEWID(),
             @RowStatus,
             NULL,
             NULL,
             10519001,
             '[{"idfSpeciesActual":' + CAST(@SpeciesMasterID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
             GETDATE()
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.tlbSpeciesActual
            SET idfsSpeciesType = @SpeciesTypeID,
                idfHerdActual = @HerdMasterID,
                datStartOfSignsDate = @StartOfSignsDate,
                strAverageAge = @AverageAge,
                intSickAnimalQty = @SickAnimalQuantity,
                intTotalAnimalQty = @TotalAnimalQuantity,
                intDeadAnimalQty = @DeadAnimalQuantity,
                strNote = @Note,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfSpeciesActual = @SpeciesMasterID;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
