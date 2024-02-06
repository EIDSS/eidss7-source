-- ================================================================================================
-- Name: USSP_VET_HERD_MASTER_SET
--
-- Description:	Inserts or updates herd actual for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/10/2019 Initial release.
-- Stephen Long     04/23/2019 Added OUTPUT to the EIDSSHerdID parameter.
-- Mark Wilson      10/19/2021 Added @AuditUser, removed @LanguageID and completed all fields.
-- Stephen Long     01/19/2022 Changed row action data type.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_HERD_MASTER_SET]
(
    @AuditUserName NVARCHAR(200),
    @FlockOrHerdMasterID BIGINT = NULL OUTPUT,
    @FarmMasterID BIGINT = NULL,
    @EIDSSFlockOrHerdID NVARCHAR(200) = NULL OUTPUT,
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
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbHerdActual',
                                              @idfsKey = @FlockOrHerdMasterID OUTPUT;

            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = 'Animal Group',
                                               @NextNumberValue = @EIDSSFlockOrHerdID OUTPUT,
                                               @InstallationSite = NULL;

            INSERT INTO dbo.tlbHerdActual
            (
                idfHerdActual,
                idfFarmActual,
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
            (@FlockOrHerdMasterID,
             @FarmMasterID,
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
             '[{"idfHerdActual":' + CAST(@FlockOrHerdMasterID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
             GETDATE()
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.tlbHerdActual
            SET idfFarmActual = @FarmMasterID,
                strHerdCode = @EIDSSFlockOrHerdID,
                intSickAnimalQty = @SickAnimalQuantity,
                intTotalAnimalQty = @TotalAnimalQuantity,
                intDeadAnimalQty = @DeadAnimalQuantity,
                strNote = @Note,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfHerdActual = @FlockOrHerdMasterID;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
