-- ================================================================================================
-- Name: USP_VET_FARM_MASTER_GETList
--
-- Description:	Get farm actual list for farm search and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/05/2019 Initial release.
-- Stephen Long     04/27/2019 Correction to where clause; added row status check.
-- Stephen Long     05/22/2019 Added additional farm address fields to the select.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).
-- Stephen Long     07/18/2019 Added check for farms marked as both avian and livestock to return 
--                             when avian or livestock are sent in as criteria.
-- Ann Xiong        10/17/2019 Added one additional field and modified one field to the select, 
--                             added a parameter @EIDSSFarmOwnerID NVARCHAR(100) = NULL.
-- Mandar Kulkarni  06/18/2020 Since the data for idfsCategory in 6.1 is not populated, added code 
--                             to determine farm type based on intHACode.
-- Stephen Long     07/06/2020 Added leading wildcard character on like criteria.
-- Stephen Long     08/03/2020 Added EIDSS legacy ID to the parameters and where criteria.
-- Stephen Long     09/16/2020 Changed default sort order to descending.
-- Stephen Long     10/12/2020 Added elevation to the query.
-- Stephen Long     12/23/2020 Corrected where criteria for farm type when both avian and 
--                             livestock.
-- Stephen Long     01/25/2021 Added order by parameter to handle when a user selected a specific 
--                             column to sort by.
-- Stephen Long     01/27/2021 Fix for order by; alias will not work on order by with case.
-- Mike Kornegay	02/17/2022 Changed paging to match standard CTE paging structure and added various
--							   sorting options.
-- Mike Kornegay	02/18/2022 Improvement recommendations from Mandar Kulkarni - remove left join 
--							   to gisSettlement and replace with sub query.
-- Mike Kornegay	03/10/2022 Added subquery to get the FarmId from tlbFarm if it exists.
-- Michael Brown    03/27/2022 Added parameter @FarmTypesName to filter based on the actual FarmTypeID 
--							   of the farm (LiceStock, Avian, or All (both). The assumption is that we 
--							   we will only get the values 10040007, 10040003, or 10040001.
-- Michael Brown    03/30/2022 Had to change SP because a NULL value could be passed for the 
--							   FarmTypeID. Also the @FarmName, @FarmOwnerFirstName, and 
--							   @FarmOwnerLastName were changed to NULL as opposed to '' empty strings.
-- Stephen Long     05/11/2022 Corrected farm type ID and to use translated value.  Set farm ID 
--                             to null instead of sub-query; field no longer needed.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.  Removed farm 
--                             ID field.
-- Stephen Long     10/10/2022 Added monitoring session ID parameter and where criteria.
-- Stephen Long     05/11/2023 Added record identifier search indicator logic.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_FARM_MASTER_GETList]
(
    @LanguageID NVARCHAR(20),
    @FarmMasterID BIGINT = NULL,
    @EIDSSFarmID NVARCHAR(200) = NULL,
    @LegacyFarmID NVARCHAR(200) = NULL,
    @FarmTypeID BIGINT = NULL,
    @FarmName NVARCHAR(200) = NULL,
    @FarmOwnerFirstName NVARCHAR(200) = NULL,
    @FarmOwnerLastName NVARCHAR(200) = NULL,
    @EIDSSPersonID NVARCHAR(100) = NULL,
    @EIDSSFarmOwnerID NVARCHAR(100) = NULL,
    @FarmOwnerID BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @SettlementTypeID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @RecordIdentifierSearchIndicator BIT = 0,
    @sortColumn NVARCHAR(100) = 'EIDSSFarmID',
    @sortOrder NVARCHAR(4) = 'DESC',
    @pageNo INT = 1,
    @pageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FarmTypesName NVARCHAR(200) = NULL;
        DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
        DECLARE @ReturnCode BIGINT = 0;
        DECLARE @FarmTypes TABLE
        (
            FarmTypeID BIGINT,
            FarmTypeName NVARCHAR(200)
        );

        -- 06/18/2020 - Based on the parameter value passed farm type field, set the intHACode value to look for in v6.1 data
        DECLARE @AccessoryCode INT,
                @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_Get(@LanguageID);
        DECLARE @firstRec INT;
        DECLARE @lastRec INT;

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        SET @firstRec = (@pageNo - 1) * @pagesize;
        SET @lastRec = (@pageNo * @pageSize + 1);

        INSERT INTO @FarmTypes
        SELECT snt.idfsBaseReference,
               snt.strTextString
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE idfsReferenceType = 19000040
              AND idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        IF @FarmTypeID = 10040007 -- Livestock
        BEGIN
            SET @AccessoryCode = 32;
            SET @FarmTypesName =
            (
                SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040007
            );
        END;
        ELSE IF @FarmTypeID = 10040003 -- Avian
        BEGIN
            SET @AccessoryCode = 64;
            SET @FarmTypesName =
            (
                SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040003
            );
        END;
        ELSE IF @FarmTypeID = 10040001 -- All (both)
        BEGIN
            SET @AccessoryCode = NULL;
            --SET @FarmTypeID = NULL;	
            SET @FarmTypesName =
            (
                SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040001
            );
        END;
        ELSE
        BEGIN
            SET @AccessoryCode = NULL;
            SET @FarmTypeID = NULL;
            SET @FarmTypesName = '';
        END;

        IF @RecordIdentifierSearchIndicator = 1
        BEGIN
            ;WITH CTEIntermediate
             AS (SELECT fa.idfFarmActual AS FarmMasterID,

                        -- 06/18/2020 - Made changes to look for intHACode if idfsCategory column is not populated for v6.1 data.
                        --			fa.idfsFarmCategory AS FarmTypeID,
                        --			farmType.name AS FarmTypeName,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040007
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040003
                             ELSE
                                 10040001
                         END
                        ) AS FarmTypeID,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040007
                             )
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040003
                             )
                             ELSE
                         (
                             SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040001
                         )
                         END
                        ) AS FarmTypeName,
                        fa.idfHumanActual AS FarmOwnerID,
                        fa.idfFarmAddress AS FarmAddressID,
                        fa.strNationalName AS FarmName,
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
                        fa.intRowStatus AS RowStatus,
                        lh.AdminLevel1ID AS CountryID,
                        lh.AdminLevel2ID AS RegionID,
                        lh.AdminLevel2Name AS RegionName,
                        lh.AdminLevel3ID AS RayonID,
                        lh.AdminLevel3Name AS RayonName,
                        settlement.idfsLocation AS SettlementID,
                        settlementName.name AS SettlementName,
                        gls.strApartment AS Apartment,
                        gls.strBuilding AS Building,
                        gls.strHouse AS House,
                        gls.strPostCode AS PostalCode,
                        gls.strStreetName AS Street,
                        gls.dblLatitude AS Latitude,
                        gls.dblLongitude AS Longitude,
                        gls.dblElevation AS Elevation,
                        ha.strPersonID AS EIDSSFarmOwnerID,
                        haai.EIDSSPersonID,
                        (CASE
                             WHEN ha.strFirstName IS NULL THEN
                                 ''
                             WHEN ha.strFirstName = '' THEN
                                 ''
                             ELSE
                                 ha.strFirstName
                         END + CASE
                                   WHEN ha.strSecondName IS NULL THEN
                                       ''
                                   WHEN ha.strSecondName = '' THEN
                                       ''
                                   ELSE
                                       ' ' + ha.strSecondName
                               END + CASE
                                         WHEN ha.strLastName IS NULL THEN
                                             ''
                                         WHEN ha.strLastName = '' THEN
                                             ''
                                         ELSE
                                             ' ' + ha.strLastName
                                     END
                        ) AS FarmOwnerName,
                        ha.strFirstName AS FarmOwnerFirstName,
                        ha.strLastName AS FarmOwnerLastName,
                        ha.strSecondName AS FarmOwnerSecondName
                 FROM dbo.tlbFarmActual fa
                     LEFT JOIN dbo.tlbHumanActual ha
                         ON ha.idfHumanActual = fa.idfHumanActual
                     LEFT JOIN dbo.HumanActualAddlInfo haai
                         ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                     LEFT JOIN dbo.tlbGeoLocationShared gls
                         ON gls.idfGeoLocationShared = fa.idfFarmAddress
                            AND gls.intRowStatus = 0
                     INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                         ON lh.idfsLocation = gls.idfsLocation
                     LEFT JOIN dbo.gisLocation settlement
                         ON settlement.idfsLocation = gls.idfsLocation
                            AND settlement.idfsType IS NOT NULL
                     LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlementName
                         ON settlementName.idfsReference = settlement.idfsLocation
                 WHERE fa.intRowStatus = 0
                       AND (
                               fa.strFarmCode LIKE '%' + TRIM(@EIDSSFarmID) + '%'
                               OR @EIDSSFarmID IS NULL
                           )
                       AND (
                               (
                                   fa.strFarmCode LIKE '%' + TRIM(@LegacyFarmID) + '%'
                                   AND fa.SourceSystemNameID = 10519002
                               ) --EIDSS version 6.1 record source (migrated record)
                               OR @LegacyFarmID IS NULL
                           )
                ),
                  CTEResults
             AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmMasterID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmMasterID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmAddressID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmAddressID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'asc' THEN
                                                            Fax
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'desc' THEN
                                                            Fax
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'asc' THEN
                                                            Email
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'desc' THEN
                                                            Email
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'asc' THEN
                                                            Phone
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'desc' THEN
                                                            Phone
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'asc' THEN
                                                            RowStatus
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'desc' THEN
                                                            RowStatus
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'asc' THEN
                                                            CountryID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'desc' THEN
                                                            CountryID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RayonName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RayonName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'asc' THEN
                                                            Apartment
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'desc' THEN
                                                            Apartment
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'asc' THEN
                                                            Building
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'desc' THEN
                                                            Building
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'asc' THEN
                                                            House
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'desc' THEN
                                                            House
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'asc' THEN
                                                            PostalCode
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'desc' THEN
                                                            PostalCode
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'asc' THEN
                                                            Street
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'desc' THEN
                                                            Street
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Latitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Latitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Longitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Longitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSPersonID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSPersonID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerFirstName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerFirstName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerLastName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerLastName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerSecondName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerSecondName
                                                    END DESC
                                          ) AS ROWNUM,
                        COUNT(*) OVER () AS RecordCount,
                        FarmMasterID,
                        FarmTypeID,
                        FarmTypeName,
                        FarmOwnerID,
                        FarmAddressID,
                        FarmName,
                        EIDSSFarmID,
                        Fax,
                        Email,
                        Phone,
                        TotalLivestockAnimalQuantity,
                        TotalAvianAnimalQuantity,
                        SickLivestockAnimalQuantity,
                        SickAvianAnimalQuantity,
                        DeadLivestockAnimalQuantity,
                        DeadAvianAnimalQuantity,
                        RowStatus,
                        CountryID,
                        RegionID,
                        RegionName,
                        RayonID,
                        RayonName,
                        SettlementID,
                        SettlementName,
                        Apartment,
                        Building,
                        House,
                        PostalCode,
                        Street,
                        Latitude,
                        Longitude,
                        Elevation,
                        EIDSSPersonID,
                        EIDSSFarmOwnerID,
                        FarmOwnerName,
                        FarmOwnerFirstName,
                        FarmOwnerLastName,
                        FarmOwnerSecondName
                 FROM CTEIntermediate
                )
            SELECT RecordCount,
                   FarmMasterID,
                   FarmTypeID,
                   FarmTypeName,
                   FarmOwnerID,
                   FarmAddressID,
                   FarmName,
                   EIDSSFarmID,
                   Fax,
                   Email,
                   Phone,
                   TotalLivestockAnimalQuantity,
                   TotalAvianAnimalQuantity,
                   SickLivestockAnimalQuantity,
                   SickAvianAnimalQuantity,
                   DeadLivestockAnimalQuantity,
                   DeadAvianAnimalQuantity,
                   RowStatus,
                   CountryID,
                   RegionID,
                   RegionName,
                   RayonID,
                   RayonName,
                   SettlementID,
                   SettlementName,
                   Apartment,
                   Building,
                   House,
                   PostalCode,
                   Street,
                   Latitude,
                   Longitude,
                   Elevation,
                   EIDSSPersonID,
                   EIDSSFarmOwnerID,
                   FarmOwnerName,
                   FarmOwnerFirstName,
                   FarmOwnerLastName,
                   FarmOwnerSecondName,
                   TotalPages = (RecordCount / @pageSize) + IIF(RecordCount % @pageSize > 0, 1, 0),
                   CurrentPage = @pageNo
            FROM CTEResults
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec;
        END
        ELSE
        BEGIN
                DECLARE @LocationNode HIERARCHYID = (
                                                SELECT node FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation
                                            );

            ;WITH CTEIntermediate
             AS (SELECT fa.idfFarmActual AS FarmMasterID,

                        -- 06/18/2020 - Made changes to look for intHACode if idfsCategory column is not populated for v6.1 data.
                        --			fa.idfsFarmCategory AS FarmTypeID,
                        --			farmType.name AS FarmTypeName,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040007
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040003
                             ELSE
                                 10040001
                         END
                        ) AS FarmTypeID,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040007
                             )
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040003
                             )
                             ELSE
                         (
                             SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040001
                         )
                         END
                        ) AS FarmTypeName,
                        fa.idfHumanActual AS FarmOwnerID,
                        fa.idfFarmAddress AS FarmAddressID,
                        fa.strNationalName AS FarmName,
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
                        fa.intRowStatus AS RowStatus,
                        lh.AdminLevel1ID AS CountryID,
                        lh.AdminLevel2ID AS RegionID,
                        lh.AdminLevel2Name AS RegionName,
                        lh.AdminLevel3ID AS RayonID,
                        lh.AdminLevel3Name AS RayonName,
                        settlement.idfsLocation AS SettlementID,
                        settlementName.name AS SettlementName,
                        gls.strApartment AS Apartment,
                        gls.strBuilding AS Building,
                        gls.strHouse AS House,
                        gls.strPostCode AS PostalCode,
                        gls.strStreetName AS Street,
                        gls.dblLatitude AS Latitude,
                        gls.dblLongitude AS Longitude,
                        gls.dblElevation AS Elevation,
                        ha.strPersonID AS EIDSSFarmOwnerID,
                        haai.EIDSSPersonID,
                        (CASE
                             WHEN ha.strFirstName IS NULL THEN
                                 ''
                             WHEN ha.strFirstName = '' THEN
                                 ''
                             ELSE
                                 ha.strFirstName
                         END + CASE
                                   WHEN ha.strSecondName IS NULL THEN
                                       ''
                                   WHEN ha.strSecondName = '' THEN
                                       ''
                                   ELSE
                                       ' ' + ha.strSecondName
                               END + CASE
                                         WHEN ha.strLastName IS NULL THEN
                                             ''
                                         WHEN ha.strLastName = '' THEN
                                             ''
                                         ELSE
                                             ' ' + ha.strLastName
                                     END
                        ) AS FarmOwnerName,
                        ha.strFirstName AS FarmOwnerFirstName,
                        ha.strLastName AS FarmOwnerLastName,
                        ha.strSecondName AS FarmOwnerSecondName
                 FROM dbo.tlbFarmActual fa
                     LEFT JOIN dbo.tlbHumanActual ha
                         ON ha.idfHumanActual = fa.idfHumanActual
                     LEFT JOIN dbo.HumanActualAddlInfo haai
                         ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                     LEFT JOIN dbo.tlbGeoLocationShared gls
                         ON gls.idfGeoLocationShared = fa.idfFarmAddress
                            AND gls.intRowStatus = 0
                     INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                         ON lh.idfsLocation = gls.idfsLocation
                     LEFT JOIN dbo.gisLocation settlement
                         ON settlement.idfsLocation = gls.idfsLocation
                            AND settlement.idfsType IS NOT NULL
                     LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlementName
                         ON settlementName.idfsReference = settlement.idfsLocation
                 WHERE fa.intRowStatus = 0
                       AND (
                               (fa.idfFarmActual = @FarmMasterID)
                               OR (@FarmMasterID IS NULL)
                           )
                       AND (
                               -- 06/18/2020 - Added condition also to look for intHACode values as idfsCategory column is not populated in v6.1 data.
                               (
                                   fa.idfsFarmCategory = @FarmTypeID
                                   OR fa.idfsFarmCategory = 10040001
                               ) --10040001 = both avian and livestock
                               OR (@FarmTypeID IS NULL)
                               OR (fa.intHACode = @AccessoryCode)
                               OR (@AccessoryCode IS NULL)
                           )
                       AND (
                               (ha.idfHumanActual = @FarmOwnerID)
                               OR (@FarmOwnerID IS NULL)
                           )
                       AND (
                               lh.AdminLevel2ID = @idfsLocation
                               OR @LocationNode.IsDescendantOf(lh.Node) = 1
                               OR lh.Node.IsDescendantOf(@LocationNode) = 1
                               OR @idfsLocation IS NULL
                           )
                       AND (
                               lh.AdminLevel3ID = @idfsLocation
                               OR @LocationNode.IsDescendantOf(lh.Node) = 1
                               OR lh.Node.IsDescendantOf(@LocationNode) = 1
                               OR @idfsLocation IS NULL
                           )
                       AND (
                               lh.AdminLevel4ID = @idfsLocation
                               OR @LocationNode.IsDescendantOf(lh.Node) = 1
                               OR lh.Node.IsDescendantOf(@LocationNode) = 1
                               OR @idfsLocation IS NULL
                           )
                       AND (
                               @SettlementTypeID IS NOT NULL
                               AND EXISTS
                 (
                     SELECT idfsSettlementType
                     FROM dbo.gisSettlement
                     WHERE idfsSettlementType = @SettlementTypeID
                 )
                               OR @SettlementTypeID IS NULL
                           )
                       AND (
                               (fa.strFarmCode LIKE '%' + TRIM(@EIDSSFarmID) + '%')
                               OR (@EIDSSFarmID IS NULL)
                           )
                       AND (
                               (
                                   fa.strFarmCode LIKE '%' + TRIM(@LegacyFarmID) + '%'
                                   AND fa.SourceSystemNameID = 10519002
                               ) --EIDSS version 6.1 record source (migrated record)
                               OR (@LegacyFarmID IS NULL)
                           )
                       AND (
                               (fa.strNationalName LIKE '%' + @FarmName + '%')
                               OR (@FarmName IS NULL)
                           )
                       AND (
                               (ha.strFirstName LIKE '%' + @FarmOwnerFirstName + '%')
                               OR (@FarmOwnerFirstName IS NULL)
                           )
                       AND (
                               (ha.strLastName LIKE '%' + @FarmOwnerLastName + '%')
                               OR (@FarmOwnerLastName IS NULL)
                           )
                       AND (
                               (haai.EIDSSPersonID LIKE '%' + TRIM(@EIDSSPersonID) + '%')
                               OR (@EIDSSPersonID IS NULL)
                           )
                       AND (
                               (ha.strPersonID LIKE '%' + TRIM(@EIDSSFarmOwnerID) + '%')
                               OR (@EIDSSFarmOwnerID IS NULL)
                           )
                       AND (
                               EXISTS
                 (
                     SELECT idfFarm
                     FROM dbo.tlbFarm
                     WHERE idfFarmActual = fa.idfFarmActual
                           AND idfMonitoringSession = @MonitoringSessionID
                 )
                               OR @MonitoringSessionID IS NULL
                           )
                ),
                  CTEResults
             AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmMasterID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmMasterID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmAddressID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmAddressID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'asc' THEN
                                                            Fax
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'desc' THEN
                                                            Fax
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'asc' THEN
                                                            Email
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'desc' THEN
                                                            Email
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'asc' THEN
                                                            Phone
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'desc' THEN
                                                            Phone
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'asc' THEN
                                                            RowStatus
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'desc' THEN
                                                            RowStatus
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'asc' THEN
                                                            CountryID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'desc' THEN
                                                            CountryID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RayonName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RayonName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'asc' THEN
                                                            Apartment
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'desc' THEN
                                                            Apartment
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'asc' THEN
                                                            Building
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'desc' THEN
                                                            Building
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'asc' THEN
                                                            House
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'desc' THEN
                                                            House
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'asc' THEN
                                                            PostalCode
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'desc' THEN
                                                            PostalCode
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'asc' THEN
                                                            Street
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'desc' THEN
                                                            Street
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Latitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Latitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Longitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Longitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSPersonID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSPersonID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerFirstName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerFirstName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerLastName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerLastName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerSecondName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerSecondName
                                                    END DESC
                                          ) AS ROWNUM,
                        COUNT(*) OVER () AS RecordCount,
                        FarmMasterID,
                        FarmTypeID,
                        FarmTypeName,
                        FarmOwnerID,
                        FarmAddressID,
                        FarmName,
                        EIDSSFarmID,
                        Fax,
                        Email,
                        Phone,
                        TotalLivestockAnimalQuantity,
                        TotalAvianAnimalQuantity,
                        SickLivestockAnimalQuantity,
                        SickAvianAnimalQuantity,
                        DeadLivestockAnimalQuantity,
                        DeadAvianAnimalQuantity,
                        RowStatus,
                        CountryID,
                        RegionID,
                        RegionName,
                        RayonID,
                        RayonName,
                        SettlementID,
                        SettlementName,
                        Apartment,
                        Building,
                        House,
                        PostalCode,
                        Street,
                        Latitude,
                        Longitude,
                        Elevation,
                        EIDSSPersonID,
                        EIDSSFarmOwnerID,
                        FarmOwnerName,
                        FarmOwnerFirstName,
                        FarmOwnerLastName,
                        FarmOwnerSecondName
                 FROM CTEIntermediate
                 WHERE (@FarmTypeID IS NULL)
                       OR FarmTypeName = @FarmTypesName
                )
            SELECT RecordCount,
                   FarmMasterID,
                   FarmTypeID,
                   FarmTypeName,
                   FarmOwnerID,
                   FarmAddressID,
                   FarmName,
                   EIDSSFarmID,
                   Fax,
                   Email,
                   Phone,
                   TotalLivestockAnimalQuantity,
                   TotalAvianAnimalQuantity,
                   SickLivestockAnimalQuantity,
                   SickAvianAnimalQuantity,
                   DeadLivestockAnimalQuantity,
                   DeadAvianAnimalQuantity,
                   RowStatus,
                   CountryID,
                   RegionID,
                   RegionName,
                   RayonID,
                   RayonName,
                   SettlementID,
                   SettlementName,
                   Apartment,
                   Building,
                   House,
                   PostalCode,
                   Street,
                   Latitude,
                   Longitude,
                   Elevation,
                   EIDSSPersonID,
                   EIDSSFarmOwnerID,
                   FarmOwnerName,
                   FarmOwnerFirstName,
                   FarmOwnerLastName,
                   FarmOwnerSecondName,
                   TotalPages = (RecordCount / @pageSize) + IIF(RecordCount % @pageSize > 0, 1, 0),
                   CurrentPage = @pageNo
            FROM CTEResults
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec
            OPTION (RECOMPILE);
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
