-- =============================================
-- Author:		Stephen Long
-- Create date: 01/26/2021
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[FN_VET_FARM_MASTER_GETList]
(	
	-- Add the parameters for the function here
	@LanguageID NVARCHAR(50) 
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT fa.idfFarmActual AS FarmMasterID
				,
				-- 06/18/2020 - Made changes to look for intHACode if idfsCategory column is not populated for v6.1 data.
				--			fa.idfsFarmCategory AS FarmTypeID,
				--			farmType.name AS FarmTypeName,
				(
					CASE 
						WHEN idfsFarmCategory = 10040007
							OR fa.intHACode = 32
							THEN 10040007
						WHEN idfsFarmCategory = 10040003
							OR fa.intHACode = 64
							THEN 10040003
						ELSE 10040001
						END
					) AS FarmTypeID
				,(
					CASE 
						WHEN idfsFarmCategory = 10040007
							OR fa.intHACode = 32
							THEN dbo.FN_GBL_ReferenceValue_GET(@LanguageID, 10040007)
						WHEN idfsFarmCategory = 10040003
							OR fa.intHACode = 64
							THEN dbo.FN_GBL_ReferenceValue_GET(@LanguageID, 10040003)
						ELSE dbo.FN_GBL_ReferenceValue_GET(@LanguageID, 10040001)
						END
					) AS FarmTypeName
				,fa.idfHumanActual AS FarmOwnerMasterID
				,fa.idfFarmAddress AS FarmAddressID
				,fa.strNationalName AS FarmName
				,fa.strFarmCode AS EIDSSFarmID
				,fa.strFax AS Fax
				,fa.strEmail AS Email
				,fa.strContactPhone AS Phone
				,fa.intLivestockTotalAnimalQty AS TotalLivestockAnimalQuantity
				,fa.intAvianTotalAnimalQty AS TotalAvianAnimalQuantity
				,fa.intLivestockSickAnimalQty AS SickLivestockAnimalQuantity
				,fa.intAvianSickAnimalQty AS SickAvianAnimalQuantity
				,fa.intLivestockDeadAnimalQty AS DeadLivestockAnimalQuantity
				,fa.intAvianDeadAnimalQty AS DeadAvianAnimalQuantity
				,fa.intRowStatus AS RowStatus
				,gl.idfsCountry AS CountryID
				,gl.idfsRegion AS RegionID
				,Region.name AS RegionName
				,gl.idfsRayon AS RayonID
				,Rayon.name AS RayonName
				,gl.idfsSettlement AS SettlementID
				,Settlement.name AS SettlementName
				,gl.strApartment AS Apartment
				,gl.strBuilding AS Building
				,gl.strHouse AS House
				,gl.strPostCode AS PostalCode
				,gl.strStreetName AS Street
				,gl.dblLatitude AS Latitude
				,gl.dblLongitude AS Longitude
				,gl.dblElevation AS Elevation
				,(
					IIF(gl.strForeignAddress IS NULL, (
							IIF(gl.strStreetName IS NULL, '', gl.strStreetName) + (
								CASE 
									WHEN gl.strBuilding IS NULL
										THEN ''
									WHEN gl.strBuilding = ''
										THEN ''
									ELSE ', ' + gl.strBuilding
									END
								) + (
								CASE 
									WHEN gl.strApartment IS NULL
										THEN ''
									WHEN gl.strApartment = ''
										THEN ''
									ELSE ', ' + gl.strApartment
									END
								) + (
								CASE 
									WHEN gl.strHouse IS NULL
										THEN ''
									WHEN gl.strHouse = ''
										THEN ''
									ELSE ', ' + gl.strHouse
									END
								) + IIF(gl.idfsSettlement IS NULL, '', ', ' + Settlement.name) + (
								CASE 
									WHEN gl.strPostCode IS NULL
										THEN ''
									WHEN gl.strPostCode = ''
										THEN ''
									ELSE ', ' + gl.strPostCode
									END
								) + IIF(gl.idfsRayon IS NULL, '', ', ' + Rayon.name) + IIF(gl.idfsRegion IS NULL, '', ', ' + Region.name) + IIF(gl.idfsCountry IS NULL, '', ', ' + Country.name)
							), gl.strForeignAddress)
					) AS FarmAddress
				,(CONVERT(NVARCHAR(100), gl.dblLatitude) + ', ' + CONVERT(NVARCHAR(100), gl.dblLongitude)) AS FarmAddressCoordinates
				,ha.strPersonID AS EIDSSFarmOwnerID
				,haai.EIDSSPersonID
				,(
					CASE 
						WHEN ha.strFirstName IS NULL
							THEN ''
						WHEN ha.strFirstName = ''
							THEN ''
						ELSE ha.strFirstName
						END + CASE 
						WHEN ha.strSecondName IS NULL
							THEN ''
						WHEN ha.strSecondName = ''
							THEN ''
						ELSE ' ' + ha.strSecondName
						END + CASE 
						WHEN ha.strLastName IS NULL
							THEN ''
						WHEN ha.strLastName = ''
							THEN ''
						ELSE ' ' + ha.strLastName
						END
					) AS FarmOwnerName
				,ha.strFirstName AS FarmOwnerFirstName
				,ha.strLastName AS FarmOwnerLastName
				,ha.strSecondName AS FarmOwnerSecondName
			FROM dbo.tlbFarmActual fa
			LEFT JOIN dbo.tlbHumanActual AS ha ON ha.idfHumanActual = fa.idfHumanActual
			LEFT JOIN dbo.HumanActualAddlInfo AS haai ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
			LEFT JOIN dbo.tlbGeoLocationShared AS gl ON gl.idfGeoLocationShared = fa.idfFarmAddress
				AND gl.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000001) AS Country ON Country.idfsReference = gl.idfsCountry
			LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000002) AS Rayon ON Rayon.idfsReference = gl.idfsRayon
			LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000003) AS Region ON Region.idfsReference = gl.idfsRegion
			LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000004) AS Settlement ON Settlement.idfsReference = gl.idfsSettlement
			LEFT JOIN dbo.gisSettlement AS gisS ON gisS.idfsSettlement = gl.idfsSettlement
)
