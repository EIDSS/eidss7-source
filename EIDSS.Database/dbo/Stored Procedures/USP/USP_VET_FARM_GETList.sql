-- ================================================================================================
-- Name: USP_VET_FARM_GETList
--
-- Description:	Get farm list for farm search and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/05/2019 Initial release.
-- Stephen Long     05/13/2019 Correction to use tlbGeoLocation instead of tlbGeoLocationShared.
-- Stephen Long     05/22/2019 Added additional farm address fields to the select.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).  Added monitoring session ID parameter.
-- Stephen Long     07/18/2019 Added farm master ID to select.
-- Stephen Long     10/13/2019 Added active record status check, and changed EIDSSFarmOwnerID to 
--                             the personal ID (eg passport) instead of the EIDSS person ID.
-- Stephen Long     12/23/2020 Corrected where criteria for farm type when both avian and 
--                             livestock.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/06/2021 Moved like where criteria to the end of the where portion.
-- Steven Verner    10/20/2021 Added EIDSS7RW paging logic
-- Mike Kornegay    12/21/2021 Corrected field names for TotalCount and RecordCount to match
--                             other stored procs. 
-- Mike Kornegay    12/22/2021 Changed size of email, fax, and phone in temp results table to prevent
--                             truncation errors.  Also swapped to denormalized location hierarchy.
-- Mike Kornegay	01/07/2022 Removed intermediate order by on insert to temp table because it was 
--							   costing the execution plan 30% of the total time.
-- Mike Kornegay	09/04/2022 Changed EIDSSFarmOwnerID variable from bigint to nvarchar and 
--							   corrected default sort
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
--
-- Testing Code:
-- exec USP_VET_FARM_GETList 'en-us';
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_FARM_GETList] (
	@LanguageID NVARCHAR(20),
	@FarmID BIGINT = NULL,
	@EIDSSFarmID NVARCHAR(200) = NULL,
	@FarmTypeID BIGINT = NULL,
	@FarmName NVARCHAR(200) = NULL,
	@FarmOwnerFirstName NVARCHAR(200) = NULL,
	@FarmOwnerLastName NVARCHAR(200) = NULL,
	@EIDSSPersonID NVARCHAR(100) = NULL,
	@FarmOwnerID BIGINT = NULL,
	@RegionID BIGINT = NULL,
	@RayonID BIGINT = NULL,
	@SettlementID BIGINT = NULL,
	@SettlementTypeID BIGINT = NULL,
	@MonitoringSessionID BIGINT = NULL, 
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(100) = 'EIDSSFarmID',
    @sortOrder NVARCHAR(4) = 'desc'
	)
AS
BEGIN
	SET NOCOUNT ON;

    	DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			FarmID bigint,
            FarmMasterID bigint,
            FarmTypeID bigint,
            FarmTypeName nvarchar(2000),
            FarmOwnerID bigint,
            FarmAddressID bigint,
            FarmName nvarchar(2000),
            EIDSSFarmID nvarchar(200),
            Fax nvarchar(200),
            Email nvarchar(512),
            Phone nvarchar(200),
            TotalLivestockAnimalQuantity int,
			TotalAvianAnimalQuantity int,
			SickLivestockAnimalQuantity int,
			SickAvianAnimalQuantity int,
			DeadLivestockAnimalQuantity int,
			DeadAvianAnimalQuantity int,
            RowStatus int,
            CountryID bigint,
            RegionID bigint,
            RegionName nvarchar(2000),
            RayonID bigint,
            RayonName nvarchar(2000),
            SettlementID bigint,
            SettlementName nvarchar(2000),
            Apartment nvarchar(2000),
            Building nvarchar(2000),
            House nvarchar(2000),
            PostalCode nvarchar(2000),
            Street nvarchar(2000),
            Latitude float,
            Longitude float,
            FarmAddress nvarchar(max),
            FarmAddressCoordinates nvarchar(2000),
            EIDSSPersonID nvarchar(200),
            EIDSSFarmOwnerID nvarchar(200),
            FarmOwnerName nvarchar(2000), 
			FarmOwnerFirstName nvarchar(2000), 
			FarmOwnerLastName nvarchar(2000), 
			FarmOwnerSecondName nvarchar(2000))

		DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
		DECLARE @ReturnCode BIGINT = 0;

		IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

        insert into @t
		SELECT 
            f.idfFarm AS FarmID,
			f.idfFarmActual AS FarmMasterID, 
			f.idfsFarmCategory AS FarmTypeID,
			farmType.name AS FarmTypeName,
			f.idfHuman AS FarmOwnerID,
			f.idfFarmAddress AS FarmAddressID,
			f.strNationalName AS FarmName,
			f.strFarmCode AS EIDSSFarmID,
			f.strFax AS Fax,
			f.strEmail AS Email,
			f.strContactPhone AS Phone,
			f.intLivestockTotalAnimalQty AS TotalLivestockAnimalQuantity,
			f.intAvianTotalAnimalQty AS TotalAvianAnimalQuantity,
			f.intLivestockSickAnimalQty AS SickLivestockAnimalQuantity,
			f.intAvianSickAnimalQty AS SickAvianAnimalQuantity,
			f.intLivestockDeadAnimalQty AS DeadLivestockAnimalQuantity,
			f.intAvianDeadAnimalQty AS DeadAvianAnimalQuantity,
			f.intRowStatus AS RowStatus,
			lh.AdminLevel1ID AS CountryID,
			lh.AdminLevel2ID AS RegionID,
			lh.AdminLevel2Name AS RegionName,
			lh.AdminLevel3ID AS RayonID,
			lh.AdminLevel3Name AS RayonName,
			lh.AdminLevel4ID AS SettlementID,
			lh.AdminLevel4Name AS SettlementName,
			gl.strApartment AS Apartment, 
			gl.strBuilding AS Building, 
			gl.strHouse AS House, 
			gl.strPostCode AS PostalCode, 
			gl.strStreetName AS Street,
			gl.dblLatitude AS Latitude, 
			gl.dblLongitude AS Longitude, 
			dbo.FN_GBL_CreateAddressString	(lh.AdminLevel1Name, lh.AdminLevel2Name, lh.AdminLevel3Name, lh.AdminLevel4Name, gl.strPostCode,'', gl.strStreetName,gl.strHouse,gl.strBuilding,gl.strApartment, gl.blnForeignAddress, gl.strForeignAddress) AS FarmAddress,
			(CONVERT(NVARCHAR(100), gl.dblLatitude) + ', ' + CONVERT(NVARCHAR(100), gl.dblLongitude)) AS FarmAddressCoordinates,
			haai.EIDSSPersonID,
			h.strPersonID AS EIDSSFarmOwnerID,
			dbo.FN_GBL_ConcatFullName(h.strLastName,h.strFirstName,h.strSecondName) AS FarmOwnerName, 
			h.strFirstName AS FarmOwnerFirstName, 
			h.strLastName AS FarmOwnerLastName, 
			h.strSecondName AS FarmOwnerSecondName 
		FROM dbo.tlbFarm f with (nolock)
		LEFT JOIN dbo.tlbHuman AS h 
			ON h.idfHuman = f.idfHuman 
		LEFT JOIN dbo.HumanActualAddlInfo AS haai
			ON haai.HumanActualAddlInfoUID = h.idfHumanActual
				AND haai.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocation AS gl
			ON gl.idfGeoLocation = f.idfFarmAddress
				AND gl.intRowStatus = 0
        INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh 
            ON LH.idfsLocation = gl.idfsLocation
		LEFT JOIN dbo.gisSettlement AS gisS
			ON gisS.idfsSettlement = gl.idfsSettlement
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000040) AS farmType
			ON farmType.idfsReference = f.idfsFarmCategory
		WHERE f.intRowStatus = 0 
			AND (
				(@FarmID IS NOT NULL AND f.idfFarm = @FarmID)
				OR (@FarmID IS NULL)
				)
			AND	(
				(@MonitoringSessionID IS NOT NULL AND f.idfMonitoringSession = @MonitoringSessionID)
				OR (@MonitoringSessionID IS NULL)
				)
			AND (
				(@FarmTypeID IS NOT NULL AND f.idfsFarmCategory = @FarmTypeID OR f.idfsFarmCategory = 10040001) --10040001 = both avian and livestock
				OR (@FarmTypeID IS NULL)
				)
			AND (
				(@FarmOwnerID IS NOT NULL AND h.idfHumanActual = @FarmOwnerID)
				OR (@FarmOwnerID IS NULL)
				)
			AND (
				(@RegionID IS NOT NULL AND LH.AdminLevel2ID = @RegionID)
				OR (@RegionID IS NULL)
				)
			AND (
				(@RayonID IS NOT NULL AND LH.AdminLevel3ID = @RayonID)
				OR (@RayonID IS NULL)
				)
			AND (
				(@SettlementTypeID IS NOT NULL AND gisS.idfsSettlementType = @SettlementTypeID)
				OR (@SettlementTypeID IS NULL)
				)
			AND (
				(@SettlementID IS NOT NULL AND gisS.idfsSettlement = @SettlementID)
				OR (@SettlementID IS NULL)
				)
			AND (
				(@EIDSSFarmID IS NOT NULL AND f.strFarmCode LIKE @EIDSSFarmID + '%')
				OR (@EIDSSFarmID IS NULL)
				)
			AND (
				(@FarmName IS NOT NULL AND f.strNationalName LIKE @FarmName + '%')
				OR (@FarmName IS NULL)
				)
			AND (
				(@FarmOwnerFirstName IS NOT NULL AND h.strFirstName LIKE @FarmOwnerFirstName + '%')
				OR (@FarmOwnerFirstName IS NULL)
				)
			AND (
				(@FarmOwnerLastName IS NOT NULL AND h.strLastName LIKE @FarmOwnerLastName + '%')
				OR (@FarmOwnerLastName IS NULL)
				)
			AND (
				(@EIDSSPersonID IS NOT NULL AND h.strPersonID LIKE @EIDSSPersonID + '%')
				OR (@EIDSSPersonID IS NULL)
				);
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'FarmID' AND @SortOrder = 'asc' THEN FarmID END ASC,
            CASE WHEN @sortColumn = 'FarmMasterID' AND @SortOrder = 'asc' THEN FarmMasterID END ASC,
            CASE WHEN @sortColumn = 'FarmMasterID' AND @SortOrder = 'desc' THEN FarmMasterID END DESC,
            CASE WHEN @sortColumn = 'FarmTypeID' AND @SortOrder = 'asc' THEN FarmTypeID END ASC,
            CASE WHEN @sortColumn = 'FarmTypeID' AND @SortOrder = 'desc' THEN FarmTypeID END DESC,
            CASE WHEN @sortColumn = 'FarmTypeName' AND @SortOrder = 'asc' THEN FarmTypeName END ASC,
            CASE WHEN @sortColumn = 'FarmTypeName' AND @SortOrder = 'desc' THEN FarmTypeName END DESC,
            CASE WHEN @sortColumn = 'FarmOwnerID' AND @SortOrder = 'asc' THEN FarmOwnerID END ASC,
            CASE WHEN @sortColumn = 'FarmOwnerID' AND @SortOrder = 'desc' THEN FarmOwnerID END DESC,
            CASE WHEN @sortColumn = 'FarmAddressID' AND @SortOrder = 'asc' THEN FarmAddressID END ASC,
            CASE WHEN @sortColumn = 'FarmAddressID' AND @SortOrder = 'desc' THEN FarmAddressID END DESC,
            CASE WHEN @sortColumn = 'FarmName' AND @SortOrder = 'asc' THEN FarmName END ASC,
            CASE WHEN @sortColumn = 'FarmName' AND @SortOrder = 'desc' THEN FarmName END DESC,
            CASE WHEN @sortColumn = 'EIDSSFarmID' AND @SortOrder = 'asc' THEN EIDSSFarmID END ASC,
            CASE WHEN @sortColumn = 'EIDSSFarmID' AND @SortOrder = 'desc' THEN EIDSSFarmID END DESC,
            CASE WHEN @sortColumn = 'Fax' AND @SortOrder = 'asc' THEN Fax  END ASC,
            CASE WHEN @sortColumn = 'Fax' AND @SortOrder = 'desc' THEN Fax  END DESC,
            CASE WHEN @sortColumn = 'Email' AND @SortOrder = 'asc' THEN Email END ASC,
            CASE WHEN @sortColumn = 'Email' AND @SortOrder = 'desc' THEN Email END DESC,
            CASE WHEN @sortColumn = 'Phone' AND @SortOrder = 'asc' THEN Phone END ASC,
            CASE WHEN @sortColumn = 'Phone' AND @SortOrder = 'desc' THEN Phone END DESC,
            CASE WHEN @sortColumn = 'TotalLivestockAnimalQuantity' AND @SortOrder = 'asc' THEN TotalLivestockAnimalQuantity END ASC,
            CASE WHEN @sortColumn = 'TotalLivestockAnimalQuantity' AND @SortOrder = 'desc' THEN TotalLivestockAnimalQuantity END DESC,
			CASE WHEN @sortColumn = 'TotalAvianAnimalQuantity' AND @SortOrder = 'asc' THEN TotalAvianAnimalQuantity END ASC,
			CASE WHEN @sortColumn = 'TotalAvianAnimalQuantity' AND @SortOrder = 'desc' THEN TotalAvianAnimalQuantity END DESC,
			CASE WHEN @sortColumn = 'SickLivestockAnimalQuantity' AND @SortOrder = 'asc' THEN SickLivestockAnimalQuantity END ASC,
			CASE WHEN @sortColumn = 'SickLivestockAnimalQuantity' AND @SortOrder = 'desc' THEN SickLivestockAnimalQuantity END DESC,
			CASE WHEN @sortColumn = 'SickAvianAnimalQuantity' AND @SortOrder = 'asc' THEN SickAvianAnimalQuantity END ASC,
			CASE WHEN @sortColumn = 'SickAvianAnimalQuantity' AND @SortOrder = 'desc' THEN SickAvianAnimalQuantity END DESC,
			CASE WHEN @sortColumn = 'DeadLivestockAnimalQuantity' AND @SortOrder = 'asc' THEN DeadLivestockAnimalQuantity END ASC,
			CASE WHEN @sortColumn = 'DeadLivestockAnimalQuantity' AND @SortOrder = 'desc' THEN DeadLivestockAnimalQuantity END DESC,
			CASE WHEN @sortColumn = 'DeadAvianAnimalQuantity' AND @SortOrder = 'asc' THEN DeadAvianAnimalQuantity END ASC,
			CASE WHEN @sortColumn = 'DeadAvianAnimalQuantity' AND @SortOrder = 'desc' THEN DeadAvianAnimalQuantity END DESC,
            CASE WHEN @sortColumn = 'RowStatus' AND @SortOrder = 'asc' THEN RowStatus END ASC,
            CASE WHEN @sortColumn = 'RowStatus' AND @SortOrder = 'desc' THEN RowStatus END DESC,
            CASE WHEN @sortColumn = 'CountryID' AND @SortOrder = 'asc' THEN CountryID END ASC,
            CASE WHEN @sortColumn = 'CountryID' AND @SortOrder = 'desc' THEN CountryID END DESC,
            CASE WHEN @sortColumn = 'RegionID' AND @SortOrder = 'asc' THEN RegionID END ASC,
            CASE WHEN @sortColumn = 'RegionID' AND @SortOrder = 'desc' THEN RegionID END DESC,
            CASE WHEN @sortColumn = 'RegionName' AND @SortOrder = 'asc' THEN RegionName END ASC,
            CASE WHEN @sortColumn = 'RegionName' AND @SortOrder = 'desc' THEN RegionName END DESC,
            CASE WHEN @sortColumn = 'RayonName' AND @SortOrder = 'asc' THEN RayonName END ASC,
            CASE WHEN @sortColumn = 'RayonName' AND @SortOrder = 'desc' THEN RayonName END DESC,
            CASE WHEN @sortColumn = 'SettlementID' AND @SortOrder = 'asc' THEN SettlementID END ASC,
            CASE WHEN @sortColumn = 'SettlementID' AND @SortOrder = 'desc' THEN SettlementID END DESC,
            CASE WHEN @sortColumn = 'SettlementName' AND @SortOrder = 'asc' THEN SettlementName END ASC,
            CASE WHEN @sortColumn = 'SettlementName' AND @SortOrder = 'desc' THEN SettlementName END DESC,
            CASE WHEN @sortColumn = 'Apartment' AND @SortOrder = 'asc' THEN Apartment END ASC,
            CASE WHEN @sortColumn = 'Apartment' AND @SortOrder = 'desc' THEN Apartment END DESC,
            CASE WHEN @sortColumn = 'Building' AND @SortOrder = 'asc' THEN Building END ASC,
            CASE WHEN @sortColumn = 'Building' AND @SortOrder = 'desc' THEN Building END DESC,
            CASE WHEN @sortColumn = 'House' AND @SortOrder = 'asc' THEN  House END ASC,
            CASE WHEN @sortColumn = 'House' AND @SortOrder = 'desc' THEN  House END DESC,
            CASE WHEN @sortColumn = 'PostalCode' AND @SortOrder = 'asc' THEN PostalCode END ASC,
            CASE WHEN @sortColumn = 'PostalCode' AND @SortOrder = 'desc' THEN PostalCode END DESC,
            CASE WHEN @sortColumn = 'Street' AND @SortOrder = 'asc' THEN Street END ASC,
            CASE WHEN @sortColumn = 'Street' AND @SortOrder = 'desc' THEN Street END DESC,
            CASE WHEN @sortColumn = 'Latitude' AND @SortOrder = 'asc' THEN Latitude END ASC,
            CASE WHEN @sortColumn = 'Latitude' AND @SortOrder = 'desc' THEN Latitude END DESC,
            CASE WHEN @sortColumn = 'Longitude' AND @SortOrder = 'asc' THEN  Longitude END ASC,
            CASE WHEN @sortColumn = 'Longitude' AND @SortOrder = 'desc' THEN  Longitude END DESC,
            CASE WHEN @sortColumn = 'FarmAddress' AND @SortOrder = 'asc' THEN FarmAddress END ASC,
            CASE WHEN @sortColumn = 'FarmAddress' AND @SortOrder = 'desc' THEN FarmAddress END DESC,
            CASE WHEN @sortColumn = 'FarmAddressCoordinates' AND @SortOrder = 'asc' THEN FarmAddressCoordinates END ASC,
            CASE WHEN @sortColumn = 'FarmAddressCoordinates' AND @SortOrder = 'desc' THEN FarmAddressCoordinates END DESC,
            CASE WHEN @sortColumn = 'EIDSSPersonID' AND @SortOrder = 'asc' THEN EIDSSPersonID END ASC,
            CASE WHEN @sortColumn = 'EIDSSPersonID' AND @SortOrder = 'desc' THEN EIDSSPersonID END DESC,
            CASE WHEN @sortColumn = 'EIDSSFarmOwnerID' AND @SortOrder = 'asc' THEN EIDSSFarmOwnerID END ASC,
            CASE WHEN @sortColumn = 'EIDSSFarmOwnerID' AND @SortOrder = 'desc' THEN EIDSSFarmOwnerID END DESC,
            CASE WHEN @sortColumn = 'FarmOwnerName' AND @SortOrder = 'asc' THEN FarmOwnerID END ASC,
            CASE WHEN @sortColumn = 'FarmOwnerName' AND @SortOrder = 'desc' THEN FarmOwnerID END DESC,
			CASE WHEN @sortColumn = 'FarmOwnerFirstName' AND @SortOrder = 'asc' THEN FarmOwnerFirstName END ASC,
			CASE WHEN @sortColumn = 'FarmOwnerFirstName' AND @SortOrder = 'desc' THEN FarmOwnerFirstName END DESC,
			CASE WHEN @sortColumn = 'FarmOwnerLastName' AND @SortOrder = 'asc' THEN FarmOwnerLastName END ASC,
			CASE WHEN @sortColumn = 'FarmOwnerLastName' AND @SortOrder = 'desc' THEN FarmOwnerLastName END DESC,
			CASE WHEN @sortColumn = 'FarmOwnerSecondName' AND @SortOrder = 'asc' THEN FarmOwnerSecondName END ASC,
			CASE WHEN @sortColumn = 'FarmOwnerSecondName' AND @SortOrder = 'desc' THEN FarmOwnerSecondName END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
			RecordCount, 
			FarmID,
            FarmMasterID ,
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
            FarmAddress,
            FarmAddressCoordinates,
            EIDSSPersonID,
            EIDSSFarmOwnerID,
            FarmOwnerName, 
			FarmOwnerFirstName, 
			FarmOwnerLastName, 
			FarmOwnerSecondName
			FROM @T
		)
			SELECT
                RecordCount, 
                FarmID,
                FarmMasterID ,
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
                FarmAddress,
                FarmAddressCoordinates,
                EIDSSPersonID,
                EIDSSFarmOwnerID,
                FarmOwnerName, 
                FarmOwnerFirstName, 
                FarmOwnerLastName, 
                FarmOwnerSecondName,
                (
				SELECT COUNT(*)
				FROM dbo.tlbFarm f
				WHERE f.intRowStatus = 0
				) AS TotalCount,
				TotalPages = (RecordCount / @pageSize) + IIF(RecordCount % @pageSize > 0, 1, 0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec;
END;
