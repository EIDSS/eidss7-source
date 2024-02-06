

-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_GETList
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
-- Mark Wilson		10/05/2021 updated for changes to DOB rules, location udpates, etc...
-- Mark Wilson		10/26/2021 changed to nolock...
-- Ann Xiong		12/03/2021 Changed ha.datDateofBirth AS DateOfBirth to CONVERT(char(10), ha.datDateofBirth,126) AS DateOfBirth
-- Mike Kornegay	12/10/2021 Changed procedure to use denormailized location table function.
-- Mike Kornegay	01/12/2022 Swapped where condition referring to gisLocation for new flat location hierarchy and corrected ISNULL
--							   check on PersonalTypeID and fixed where statements on left joins.
--
/*Test Code

EXEC dbo.USP_HUM_HUMAN_MASTER_GETList
	@LangID = 'en-US',
	@FirstOrGivenName = 'a',
--	@idfsLocation = 1344330000000 -- region = Baku
	@idfsLocation = 4720500000000  -- Rayon = Pirallahi (Baku)

EXEC dbo.USP_HUM_HUMAN_MASTER_GETList
	@LangID = 'en-US',
	@FirstOrGivenName = 'a',
    @DateOfBirthFrom = '2010-12-30 00:00:00.000',
    @DateOfBirthTo = '2012-12-30 00:00:00.000',
	--@idfsLocation = 1344330000000, -- region = Baku
	@idfsLocation = 1344380000000, -- Rayon = Khatai (Baku)
	@pageSize = 50000 
---------

DECLARE @return_value int

EXEC    @return_value = [dbo].[USP_HUM_HUMAN_MASTER_GETList]
        @LangID = N'en-US',
        @EIDSSPersonID = NULL,
        @PersonalIDType = NULL,
        @PersonalID = NULL,
        @FirstOrGivenName = 'a',
        @SecondName = NULL,
        @LastOrSurname = NULL,
        @DateOfBirthFrom = '1976-02-04 00:00:00.000',
        @DateOfBirthTo = '1980-02-04 00:00:00.000',
        @GenderTypeID = NULL,
		@idfsLocation = 1344330000000, -- region = Baku
        @pageNo = 1,
        @pageSize = 10,
        @sortColumn = N'EIDSSPersonID',
        @sortOrder = N'asc'

SELECT  @return_value
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETList_MJK] 
(
	@LangID NVARCHAR(50),
	@EIDSSPersonID NVARCHAR(200) = NULL,
	@PersonalIDType BIGINT = NULL,
	@PersonalID NVARCHAR(100) = NULL,
	@FirstOrGivenName NVARCHAR(200) = NULL,
	@SecondName NVARCHAR(200) = NULL,
	@LastOrSurname NVARCHAR(200) = NULL,
	@DateOfBirthFrom DATETIME = NULL,
	@DateOfBirthTo DATETIME = NULL,
	@GenderTypeID BIGINT = NULL,
	@idfsLocation BIGINT = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10,
	@sortColumn NVARCHAR(30) = 'EIDSSPersonID',
	@sortOrder NVARCHAR(4) = 'desc'
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT

		DECLARE @LocationNode HIERARCHYID = (SELECT node FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation)

		DECLARE @DOB DATETIME = NULL

		IF (@DateOfBirthTo IS NOT NULL AND @DateOfBirthTo = @DateOfBirthFrom)
			SET @DOB = @DateOfBirthFrom

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
			CASE WHEN @sortColumn = 'RayonName' AND @SortOrder = 'asc' THEN LH.AdminLevel3Name END ASC,	
			CASE WHEN @sortColumn = 'RayonName' AND @SortOrder = 'desc' THEN LH.AdminLevel3Name END DESC,
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
			,CONVERT(char(10), ha.datDateofBirth,126) AS DateOfBirth
			,ha.strPersonID AS PersonalID
			,ISNULL(idType.[name], idType.strDefault) AS PersonIDTypeName
			,humanAddress.strStreetName AS StreetName
			,dbo.FN_GBL_CreateAddressString	(LH.AdminLevel1Name, LH.AdminLevel2Name, LH.AdminLevel3Name, humanAddress.strPostCode,'', LH.AdminLevel4Name,humanAddress.strStreetName,humanAddress.strHouse,humanAddress.strBuilding,humanAddress.strApartment, humanAddress.blnForeignAddress, '') AS AddressString
			,(CONVERT(NVARCHAR(100), humanAddress.dblLatitude) + ', ' + CONVERT(NVARCHAR(100), humanAddress.dblLongitude)) AS LongitudeLatitude
			,hai.ContactPhoneCountryCode AS ContactPhoneCountryCode
			,hai.ContactPhoneNbr AS ContactPhoneNumber
			,hai.ReportedAge AS Age
			,hai.PassportNbr AS PassportNumber
			,ha.idfsNationality AS CitizenshipTypeID
			,citizenshipType.[name] AS CitizenshipTypeName
			,ha.idfsHumanGender AS GenderTypeID
			,genderType.[name] AS GenderTypeName
			,humanAddress.idfsCountry AS CountryID
			,LH.AdminLevel1Name AS CountryName
			,LH.AdminLevel2ID AS RegionID
			,LH.AdminLevel2Name AS RegionName
			,LH.AdminLevel3ID AS RayonID
			,LH.AdminLevel3Name AS RayonName
			,humanAddress.idfsSettlement AS SettlementID
			,LH.AdminLevel4Name AS SettlementName
			,dbo.FN_GBL_CreateAddressString(LH.AdminLevel1Name, LH.AdminLevel2Name, LH.AdminLevel3Name, '','', '','','','','', humanAddress.blnForeignAddress, humanAddress.strForeignAddress) AS FormattedAddressString

			FROM dbo.tlbHumanActual AS ha WITH (NOLOCK)
			INNER JOIN dbo.HumanActualAddlInfo hai WITH (NOLOCK) ON ha.idfHumanActual = hai.HumanActualAddlInfoUID AND hai.intRowStatus  = 0
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043) AS genderType ON ha.idfsHumanGender = genderType.idfsReference AND genderType.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000148) AS idType ON ha.idfsPersonIDType = idType.idfsReference  AND idType.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000054) AS citizenshipType ON ha.idfsNationality = citizenshipType.idfsReference AND citizenshipType.intRowStatus = 0
			
			INNER JOIN dbo.tlbGeoLocationShared humanAddress WITH (NOLOCK) ON ha.idfCurrentResidenceAddress = humanAddress.idfGeoLocationShared AND humanAddress.intRowStatus = 0
			INNER JOIN dbo.gisLocation L WITH (NOLOCK) ON L.idfsLocation = humanAddress.idfsLocation
			INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LangID) LH ON LH.idfsLocation = L.idfsLocation
			--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS Admin0 ON L.node.IsDescendantOf(Admin0.node) = 1
			--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS Admin1 ON L.node.IsDescendantOf(Admin1.node) = 1
			--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS Admin2 ON L.node.IsDescendantOf(Admin2.node) = 1
			--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS Admin3 ON L.node.IsDescendantOf(Admin3.node) = 1

			WHERE
			(
				ha.intRowStatus = 0 
				AND hai.intRowStatus = 0 
				--AND ((@idfsLocation IS NOT NULL AND (L.node.IsDescendantOf(@LocationNode) = 1 OR L.idfsLocation = @idfsLocation)) OR (@idfsLocation IS NULL))
				AND ((@idfsLocation IS NOT NULL AND (LH.idfsLocation = @idfsLocation)) OR (@idfsLocation IS NULL))
				AND (@DOB = ha.datDateofBirth OR @DateOfBirthFrom IS NULL OR (ha.datDateofBirth BETWEEN @DateOfBirthFrom AND @DateOfBirthTo))
				AND ((@EIDSSPersonID IS NOT NULL AND hai.EIDSSPersonID LIKE '%' + @EIDSSPersonID + '%') OR (@EIDSSPersonID IS NULL))
				AND ((@PersonalID IS NOT NULL AND ha.strPersonID LIKE '%' + @PersonalID + '%') OR (@PersonalID IS NULL))
				AND ((@FirstOrGivenName  IS NOT NULL AND ha.strFirstName LIKE '%' + @FirstOrGivenName + '%') OR (@FirstOrGivenName IS NULL))
				AND ((@SecondName IS NOT NULL AND ha.strSecondName LIKE '%' + @SecondName + '%') OR (@SecondName IS NULL))
				AND ((@LastOrSurname  IS NOT NULL AND ha.strLastName LIKE '%' + @LastOrSurname + '%') OR (@LastOrSurname IS NULL))
				AND ((@PersonalIDType IS NOT NULL AND idType.idfsReference = @PersonalIDType) OR (@PersonalIDType IS NULL))
				AND ((@GenderTypeID IS NOT NULL AND genderType.idfsReference = @GenderTypeID ) OR (@GenderTypeID IS NULL))
				--MJK - changed to use the left joined tables instead of the main table, otherwise returns NULL records if the parameter passed is not in
				--	the base reference table or is inactive
				--AND ((@PersonalIDType IS NOT NULL AND ha.idfsPersonIDType = @PersonalIDType) OR (@PersonalIDType IS NULL))
				--AND ((@GenderTypeID IS NOT NULL AND ha.idfsHumanGender = @GenderTypeID ) OR (@GenderTypeID IS NULL))
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

	OPTION (RECOMPILE);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
