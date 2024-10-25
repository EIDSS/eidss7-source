-- ================================================================================================
-- Name: USSP_VET_VACCINATION_SET
--
-- Description:	Inserts or updates vaccination info for the avian veterinary disease report use 
-- cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     04/17/2019 Updated for API.
-- Mark Wilson      10/19/2019 removed @LanguageID, added @AuditUser.
-- Stephen Long     01/19/2022 Changed row action data type.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_VACCINATION_SET]
(
    @AuditUserName NVARCHAR(200),
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
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
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
        END
        ELSE
        BEGIN
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
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
