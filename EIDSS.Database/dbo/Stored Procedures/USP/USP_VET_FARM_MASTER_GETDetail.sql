-- ================================================================================================
-- Name: USP_VET_FARM_MASTER_GETDetail
--
-- Description:	Get farm details for a specific farm master or farm record.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/06/2019 Initial release.
-- Stephen Long     04/29/2019 Added audit create date as entered date.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).
-- Stephen Long     08/19/2019 Change farm owner name/ID to use personal ID instead of the EIDSS 
--                             person ID.
-- Ann Xiong        09/26/2019 Change FarmOwnerID to return ha.strPersonID instead of 
--                             fa.idfHumanActual, 
--                             add script to return CountryName.
-- Ann Xiong        10/07/2019 Added script to select CountryName, SettlementTypeName, and 
--                             idfsSettlementType.
-- Stephen Long     10/11/2019 Added EIDSSFarmOwnerID for the personal ID, and farm owner ID as the 
--                             human actual ID as the farm add/update user control relies on this 
--                             value.
-- Stephen Long     11/21/2019 Added source system name ID to the model.
-- Stephen Long     06/24/2020 Since the data for farm category in 6.1 is not populated, added code 
--                             to determine farm type based on accessory code.
-- Stephen Long     01/23/2022 Updated for location hierarchy.
-- Mike Kornegay	02/20/2022 Added number of buildings, birds per building, and avian farm type.
-- Mike Kornegay	02/21/2022 Added LocationID.
-- Mike Kornegay	03/10/2022 Added subquery to get the FarmId from tlbFarm if it exists.
-- Stephen Long     05/10/2022 Added additional check for farm type ID.
-- Ann Xiong        02/28/2023 Set migrated record's EnteredDate blank since no equivalent field in v 6.1 Farm record. 
-- Mike Kornegay	04/06/2023 Modify farm owner to trim spaces and return nulls if names are blank.
-- Mike Kornegay	04/13/2023 Correct farm owner field.
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_FARM_MASTER_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @FarmMasterID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @AccessoryCode INT = NULL,
                @FarmTypeID BIGINT = NULL,
                @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_Get(@LanguageID)

        SELECT fa.idfFarmActual AS FarmMasterID,
               (CASE
                    WHEN fa.idfsFarmCategory = 10040007
                         OR (fa.intHACode = 32 AND fa.idfsFarmCategory IS NULL) THEN
                        10040007
                    WHEN fa.idfsFarmCategory = 10040003
                         OR (fa.intHACode = 64 AND fa.idfsFarmCategory IS NULL) THEN
                        10040003
                    ELSE
                        10040001
                END
               ) AS FarmTypeID,
               (CASE
                    WHEN idfsFarmCategory = 10040007
                         OR (fa.intHACode = 32 AND fa.idfsFarmCategory IS NULL) THEN
                        dbo.FN_GBL_ReferenceValue_GET(@LanguageCode, 10040007)
                    WHEN idfsFarmCategory = 10040003
                         OR (fa.intHACode = 64 AND fa.idfsFarmCategory IS NULL) THEN
                        dbo.FN_GBL_ReferenceValue_GET(@LanguageCode, 10040003)
                    ELSE
                        dbo.FN_GBL_ReferenceValue_GET(@LanguageCode, 10040001)
                END
               ) AS FarmTypeName,
			   (SELECT TOP 1 idfFarm FROM tlbFarm WHERE idfFarmActual = fa.idfFarmActual) AS FarmID,
               fa.idfsOwnershipStructure AS OwnershipStructureTypeID,
               ha.strPersonID AS EIDSSFarmOwnerID,
               fa.idfHumanActual AS FarmOwnerID,
               haai.EIDSSPersonID,
			    (
					COALESCE(ha.strLastName, '') +
					(CASE ha.strFirstName WHEN null THEN '' WHEN '' THEN '' ELSE ', ' END) +
					COALESCE(ha.strFirstName, '') + 
					COALESCE(ha.strSecondName, '') +
					(CASE ha.strPersonID WHEN null THEN '' WHEN '' THEN '' ELSE ' ' + CHAR(150) + ' ' END) +
					COALESCE(ha.strPersonID, '')
				) AS FarmOwner,
               ha.strLastName AS FarmOwnerLastName,
               ha.strFirstName AS FarmOwnerFirstName,
               ha.strSecondName AS FarmOwnerSecondName,
               (CASE
                    WHEN fa.strNationalName IS NULL THEN
                        fa.strInternationalName
                    WHEN fa.strNationalName = '' THEN
                        fa.strInternationalName
                    ELSE
                        fa.strNationalName
                END
               ) AS FarmName,
               fa.strFarmCode AS EIDSSFarmID,
               fa.strFax AS Fax,
               fa.strEmail AS Email,
               fa.strContactPhone AS Phone,
               fa.intLivestockTotalAnimalQty AS TotalLivestockAnimalQuantity,
               fa.intAvianTotalAnimalQty AS TotalAvianAnimalQuantity,
               fa.intLivestockSickAnimalQty AS SickLivestockAnimalQuantity,
               fa.intAvianSickAnimalQty AS SickAvianAnimalQuantity,
               fa.intLivestockDeadAnimalQty AS DeadLivestockAnimalQuantity,
               fa.intAvianDeadAnimalQty AS DeadAvianAnimalQuantity,
               fa.strNote AS Note,
               fa.intRowStatus AS RowStatus,
               fa.datModificationDate AS ModifiedDate,
               (CASE
                    WHEN fa.SourceSystemNameID = 10519002 THEN
                        NULL
                    ELSE
                        fa.AuditCreateDTM
                END
               ) AS EnteredDate,
               fa.idfFarmAddress AS FarmAddressID,
               fa.SourceSystemNameID,
               lh.idfsLocation AS FarmAddressLocationID,
			   lh.AdminLevel1ID AS FarmAddressAdministrativeLevel0ID,
               lh.AdminLevel1Name AS FarmAddressAdministrativeLevel0Name,
               lh.AdminLevel2ID AS FarmAddressAdministrativeLevel1ID,
               lh.AdminLevel2Name AS FarmAddressAdministrativeLevel1Name,
               lh.AdminLevel3ID AS FarmAddressAdministrativeLevel2ID,
               lh.AdminLevel3Name AS FarmAddressAdministrativeLevel2Name,
               lh.AdminLevel4ID AS FarmAddressAdministrativeLevel3ID,
               lh.AdminLevel4Name AS FarmAddressAdministrativeLevel3Name,
               settlement.idfsReference AS FarmAddressSettlementID,
               settlement.name AS FarmAddressSettlementName,
               settlementType.idfsReference AS FarmAddressSettlementTypeID,
               settlementType.name AS FarmAddressSettlementTypeName,
               pc.idfPostalCode AS FarmAddressPostalCodeID, 
               gls.strPostCode AS FarmAddressPostalCode,
               st.idfStreet AS FarmAddressStreetID, 
               gls.strStreetName AS FarmAddressStreetName,
               gls.strBuilding AS FarmAddressBuilding,
               gls.strApartment AS FarmAddressApartment,
               gls.strHouse AS FarmAddressHouse,
               gls.dblLatitude AS FarmAddressLatitude,
               gls.dblLongitude AS FarmAddressLongitude,
               (CONVERT(NVARCHAR(100), gls.dblLatitude) + ', ' + CONVERT(NVARCHAR(100), gls.dblLongitude)) AS Coordinates,
               dbo.FN_GBL_CreateAddressString(
                                                 ISNULL(lh.AdminLevel1Name, ''),
                                                 ISNULL(lh.AdminLevel2Name, ''),
                                                 ISNULL(lh.AdminLevel3Name, ''),
                                                 ISNULL(gls.strPostCode, ''),
                                                 '',
                                                 '',
                                                 ISNULL(gls.strStreetName, ''),
                                                 ISNULL(gls.strHouse, ''),
                                                 ISNULL(gls.strBuilding, ''),
                                                 ISNULL(gls.strApartment, ''),
                                                 gls.blnForeignAddress,
                                                 ISNULL(gls.strForeignAddress, '')
                                             ) AS AddressString,
			   fa.intBirdsPerBuilding as NumberOfBirdsPerBuilding,
			   fa.intBuidings as NumberOfBuildings,
			   fa.idfsAvianFarmType as AvianFarmTypeID,
			   fa.idfsAvianProductionType as AvianProductionTypeID
        FROM dbo.tlbFarmActual fa
            LEFT JOIN dbo.tlbHumanActual AS ha
                ON ha.idfHumanActual = fa.idfHumanActual
                   AND ha.intRowStatus = 0
            LEFT JOIN dbo.HumanActualAddlInfo AS haai
                ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                   AND haai.intRowStatus = 0
            LEFT OUTER JOIN dbo.tlbGeoLocationShared gls
                ON fa.idfFarmAddress = gls.idfGeoLocationShared
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = gls.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = g.idfsLocation
            LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlement
                ON g.node.IsDescendantOf(settlement.node) = 1
            LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) settlementType
                ON settlementType.idfsReference = settlement.idfsType
            LEFT JOIN dbo.tlbStreet st
                ON st.strStreetName = gls.strStreetName
            LEFT JOIN dbo.tlbPostalCode pc
                ON pc.strPostCode = gls.strPostCode
        WHERE fa.idfFarmActual = @FarmMasterID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
