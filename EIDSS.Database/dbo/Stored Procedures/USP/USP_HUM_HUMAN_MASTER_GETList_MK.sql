

-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_GETList_MK
--
-- Description: Get human actual list for human, laboratory and veterinary modules.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/13/2018 Added additional address fields.
-- Stephen Long     08/23/2018 Added EIDSS person ID to list.
-- Stephen Long     09/26/2018 Added wildcard to the front of fields using the wildcard symbol, as 
--                             per use case.
-- Stephen Long		09/28/2018 Added order by and total records, as per use case.
-- Stephen Long     11/26/2018 Updated for the new API; removed returnCode and returnMsg. Total 
--                             records will need to be handled differently.
-- Stephen Long     12/14/2018 Added pagination set, page size and max pages per fetch parameters
--                             and fetch portion.
-- Stephen Long     12/30/2018 Renamed to master so the human get list stored procedure can query 
--                             the human table which is needed for the lab module instead of human 
--                             actual.
-- Stephen Long     01/18/2019 Changed date of birth to date of birth range, and duplicate check.
-- Stephen Long     04/08/2019 Changed full name from first name last name second name to last 
--                             name ', ' first name and then second name.
-- Stephen Long     07/07/2019 Added settlement ID and settlement name to select.
-- Ann Xiong	    10/29/2019 added PassportNumber to return
-- Ann Xiong		01/15/2020 Used humanAddress.strAddressString instead of 
--                             humanAddress.strForeignAddress for AddressString
-- Stephen Long     01/28/2021 Added order by clause to handle user selected sorting across 
--                             pagination sets.
-- Doug Albanese	06/11/2021 Refactored to conform to the new filtering requirements and return structure for our gridview.
-- ================================================================================================
CREATE   PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETList_MK] (
	@LanguageID NVARCHAR(50)
	,@EIDSSPersonID NVARCHAR(200) = NULL
	,@PersonalIDType BIGINT = NULL
	,@PersonalID NVARCHAR(100) = NULL
	,@FirstOrGivenName NVARCHAR(200) = NULL
	,@SecondName NVARCHAR(200) = NULL
	,@LastOrSurname NVARCHAR(200) = NULL
	,@ExactDateOfBirth DATETIME = NULL
	,@DateOfBirthFrom DATETIME = NULL
	,@DateOfBirthTo DATETIME = NULL
	,@GenderTypeID BIGINT = NULL
	,@RegionID BIGINT = NULL
	,@RayonID BIGINT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'EIDSSPersonID' 
	,@sortOrder NVARCHAR(4) = 'asc'
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1);

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'EIDSSPersonID' AND @SortOrder = 'asc' THEN hai.EIDSSPersonID END ASC,
			CASE WHEN @sortColumn = 'EIDSSPersonID' AND @SortOrder = 'desc' THEN hai.EIDSSPersonID END DESC,
			CASE WHEN @sortColumn = 'LastOrSurname' AND @SortOrder = 'asc' THEN ha.strLastName END ASC,	
			CASE WHEN @sortColumn = 'LastOrSurname' AND @SortOrder = 'desc' THEN ha.strLastName END DESC,
			CASE WHEN @sortColumn = 'FirstOrGivenName' AND @SortOrder = 'asc' THEN ha.strFirstName END ASC,	
			CASE WHEN @sortColumn = 'FirstOrGivenName' AND @SortOrder = 'desc' THEN ha.strFirstName END DESC,
			CASE WHEN @sortColumn = 'PersonalID' AND @SortOrder = 'asc' THEN ha.strPersonID END ASC,	
			CASE WHEN @sortColumn = 'PersonalID' AND @SortOrder = 'desc' THEN ha.strPersonID END DESC,
			CASE WHEN @sortColumn = 'PersonIDTypeName' AND @SortOrder = 'asc' THEN idType.name END ASC,	
			CASE WHEN @sortColumn = 'PersonIDTypeName' AND @SortOrder = 'desc' THEN idType.name END DESC,
			CASE WHEN @sortColumn = 'PassportNumber' AND @SortOrder = 'asc' THEN hai.PassportNbr END ASC,	
			CASE WHEN @sortColumn = 'PassportNumber' AND @SortOrder = 'desc' THEN hai.PassportNbr END DESC,
			CASE WHEN @sortColumn = 'GenderTypeName' AND @SortOrder = 'asc' THEN genderType.name END ASC,	
			CASE WHEN @sortColumn = 'GenderTypeName' AND @SortOrder = 'desc' THEN genderType.name END DESC,
			CASE WHEN @sortColumn = 'RayonName' AND @SortOrder = 'asc' THEN rayon.name END ASC,	
			CASE WHEN @sortColumn = 'RayonName' AND @SortOrder = 'desc' THEN rayon.name END DESC,
			CASE WHEN @sortColumn = 'DateOfBirth' AND @SortOrder = 'asc' THEN ha.datDateofBirth END ASC,	
			CASE WHEN @sortColumn = 'DateOfBirth' AND @SortOrder = 'desc' THEN ha.datDateofBirth END DESC
		) AS ROWNUM,
			COUNT(*) OVER () AS TotalRowCount
			,ha.idfHumanActual AS HumanMasterID
			,hai.EIDSSPersonID AS EIDSSPersonID
			,ha.strFirstName AS FirstOrGivenName
			,ha.strSecondName AS SecondName
			,ha.strLastName AS LastOrSurname
			,dbo.FN_GBL_ConcatFullName(ha.strLastName,ha.strFirstName,ha.strSecondName) AS FullName
			,ha.datDateofBirth AS DateOfBirth
			,ha.strPersonID AS PersonalID
			,idType.name AS PersonIDTypeName
			,humanAddress.strStreetName AS StreetName
			,dbo.FN_GBL_CreateAddressString	(country.name, region.name, rayon.name, humanAddress.strPostCode,'', settlement.name,humanAddress.strStreetName,humanAddress.strHouse,humanAddress.strBuilding,humanAddress.strApartment, humanAddress.blnForeignAddress, '') AS AddressString
			,(CONVERT(NVARCHAR(100), humanAddress.dblLatitude) + ', ' + CONVERT(NVARCHAR(100), humanAddress.dblLongitude)) AS LongitudeLatitude
			,hai.ContactPhoneCountryCode AS ContactPhoneCountryCode
			,hai.ContactPhoneNbr AS ContactPhoneNumber
			,hai.ReportedAge AS Age
			,hai.PassportNbr AS PassportNumber
			,ha.idfsNationality AS CitizenshipTypeID
			,citizenshipType.name AS CitizenshipTypeName
			,ha.idfsHumanGender AS GenderTypeID
			,genderType.name AS GenderTypeName
			,humanAddress.idfsCountry AS CountryID
			,country.name AS CountryName
			,humanAddress.idfsRegion AS RegionID
			,region.name AS RegionName
			,humanAddress.idfsRayon AS RayonID
			,rayon.name AS RayonName
			,humanAddress.idfsSettlement AS SettlementID
			,settlement.name AS SettlementName
			,dbo.FN_GBL_CreateAddressString(country.name, region.name, rayon.name, '','', '','','','','', humanAddress.blnForeignAddress, humanAddress.strForeignAddress) AS FormattedAddressString

		FROM dbo.tlbHumanActual AS ha 
		INNER JOIN dbo.HumanActualAddlInfo AS hai ON ha.idfHumanActual = hai.HumanActualAddlInfoUID AND hai.intRowStatus  = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000043) AS genderType ON ha.idfsHumanGender = genderType.idfsReference AND genderType.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000148) AS idType ON ha.idfsPersonIDType = idType.idfsReference  AND idType.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000054) AS citizenshipType ON ha.idfsNationality = citizenshipType.idfsReference AND citizenshipType.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared AS humanAddress ON ha.idfCurrentResidenceAddress = humanAddress.idfGeoLocationShared
			AND humanAddress.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000001) AS country ON humanAddress.idfsCountry = country.idfsReference 
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000003) AS region ON humanAddress.idfsRegion = region.idfsReference
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000002) AS rayon ON humanAddress.idfsRayon = rayon.idfsReference
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000004) AS settlement ON humanAddress.idfsSettlement = settlement.idfsReference
		WHERE (
				ha.intRowStatus = 0 AND hai.intRowStatus = 0 
				AND
					(@ExactDateOfBirth IS NOT NULL AND ha.datDateofBirth =@ExactDateOfBirth) OR @ExactDateOfBirth IS NULL
				AND (
					(@DateOfBirthFrom IS NOT NULL AND @DateOfBirthTo IS NOT NULL
					AND (
						ha.datDateofBirth >= @DateOfBirthFrom
							AND ha.datDateofBirth <= @DateOfBirthTo
						)
					)
					OR (
						@DateOfBirthFrom IS NULL
						OR @DateOfBirthTo IS NULL
						)
					)
				AND (
					(@PersonalIDType IS NOT NULL AND ha.idfsPersonIDType = @PersonalIDType )
					OR (@PersonalIDType IS NULL)
					)
				AND (
					(@GenderTypeID IS NOT NULL AND ha.idfsHumanGender = @GenderTypeID )
					OR (@GenderTypeID IS NULL)
					)
				AND (
					(@RegionID IS NOT NULL AND humanAddress.idfsRegion = @RegionID)
					OR (@RegionID IS NULL)
					)
				AND (
					(@RayonID IS NOT NULL AND humanAddress.idfsRayon = @RayonID)
					OR (@RayonID IS NULL)
					)
				AND (
					(@EIDSSPersonID IS NOT NULL AND hai.EIDSSPersonID LIKE '%' + @EIDSSPersonID + '%')
					OR (@EIDSSPersonID IS NULL)
					)
				AND (
					(@PersonalID IS NOT NULL AND ha.strPersonID LIKE '%' + @PersonalID + '%')
					OR (@PersonalID IS NULL)
					)
				AND (
					(@FirstOrGivenName  IS NOT NULL AND ha.strFirstName LIKE '%' + @FirstOrGivenName + '%')
					OR (@FirstOrGivenName IS NULL)
					)
				AND (
					(@SecondName IS NOT NULL AND ha.strSecondName LIKE '%' + @SecondName + '%')
					OR (@SecondName IS NULL)
					)
				AND (
					(@LastOrSurname  IS NOT NULL AND ha.strLastName LIKE '%' + @LastOrSurname + '%')
					OR (@LastOrSurname IS NULL)
					)
				)
			) 

			SELECT
				TotalRowCount,
				HumanMasterID,
				EIDSSPersonID,
				FirstOrGivenName,
				SecondName,
				LastOrSurname,
				FullName,
				DateOfBirth,
				PersonalID,
				PersonIDTypeName,
				StreetName,
				AddressString,
				LongitudeLatitude,
				ContactPhoneCountryCode,
				ContactPhoneNumber,
				Age,
				PassportNumber,
				CitizenshipTypeID,
				CitizenshipTypeName,
				GenderTypeID,
				GenderTypeName,
				CountryID,
				CountryName,
				RegionID,
				RegionName,
				RayonID,
				RayonName,
				SettlementID,
				SettlementName,
				FormattedAddressString,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	

--		OPTION (RECOMPILE);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
