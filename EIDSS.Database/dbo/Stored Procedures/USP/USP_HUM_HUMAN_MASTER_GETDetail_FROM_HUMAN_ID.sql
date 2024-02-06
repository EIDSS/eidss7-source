-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_GETDetail_FROM_HUMAN_ID 
--
-- Description:	Get a human  record details from Human ID
--          
-- Revision History:
-- Name            Date			Change Detail
-- --------------- ----------	--------------------------------------------------------------------
-- Mandar Kulkarni				Initial release.
-- Vilma Thomas		05/25/2018	Update the ReferenceType key from 19000167 to 19000500 for 'Contact 
--								Phone Type'
-- Stephen Long		11/26/2018	Update for the new API; remove returnCode and returnMsg.
-- Ann Xiong		08/30/2019	Added script to select PersonalIDTypeName, OccupationTypeName, 
--								SchoolCountry, 
--								SchoolRegion, SchoolRayon, SchoolSettlement for Person Deduplication.
-- Ann Xiong		09/09/2019	return haai.SchoolAddressID instead of haai.AltAddressID as 
--								SchoolGeoLocationID
-- Mark Wilson		10/29/2019	added Settlement Type to return
-- Ann Xiong		02/17/2020	Added IsAnotherPhone and Age to select
-- Ann Xiong		05/08/2020	Added YNAnotherAddress, YNHumanForeignAddress, 
--								YNEmployerForeignAddress, YNHumanAltForeignAddress, 
--								YNSchoolForeignAddress, YNWorkSameAddress to select
-- Stephen Long		07/07/2020	Changed v6.1 function call for create address string to v7 version.
-- Lamont Mitchell	10/18/2020	Modified to use Human ID instead of HumanActual ID fto get letest Human Records
-- Mark Wilson		09/21/2021	reworked the locations to use gisLocation and hierarchy
-- Mike Kornegay	01/31/2023	Corrected contact information to point to HumanAddlInfo instead of HumanActualAddlInfo
-- Olga Mirnaya     10/10/2023  Replace join conditions to FN_GBL_GIS_ReferenceRepair_GET with FN_GBL_GIS_ReferenceRepairNL_GET for improving indexing
--
-- Sample code:
/*
EXEC dbo.USP_HUM_HUMAN_MASTER_GETDetail_FROM_HUMAN_ID
	'en-US',
	203840000126



*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETDetail_FROM_HUMAN_ID] (
	@LanguageID NVARCHAR(20),
	@HumanID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT ISNULL(ha.strFirstName, '') + ' ' + ISNULL(ha.strLastName, '') AS PatientFarmOwnerName,
			ha.idfHumanActual AS HumanActualId,
			hm.idfHuman AS HumanId,
			ha.strPersonID AS EIDSSPersonID,
			hm.idfsOccupationType AS OccupationTypeID,
			hm.idfsNationality AS CitizenshipTypeID,
			citizenshipType.name AS CitizenshipTypeName,
			hm.idfsHumanGender AS GenderTypeID,
			tb.name AS GenderTypeName,
			hm.idfCurrentResidenceAddress AS HumanGeoLocationID,
			tglHuman.idfsCountry AS HumanidfsCountry,
			humanCountry.name AS HumanCountry,
			tglHuman.idfsRegion AS HumanidfsRegion,
			humanRegion.name AS HumanRegion,
			tglHuman.idfsRayon AS HumanidfsRayon,
			humanRayon.name AS HumanRayon,
			tglHuman.idfsSettlement AS HumanidfsSettlement,
			humanSettlement.name AS HumanSettlement,
			humanSettlement.idfsType AS HumanidfsSettlementType,
			humanSettlementType.strDefault AS HumanSettlementType,
			tglHuman.strPostCode AS HumanstrPostalCode,
			tglHuman.strStreetName AS HumanstrStreetName,
			tglHuman.strHouse AS HumanstrHouse,
			tglHuman.strBuilding AS HumanstrBuilding,
			tglHuman.strApartment AS HumanstrApartment,
			tglHuman.strDescription AS HumanDescription,
			tglHuman.dblLatitude AS HumanstrLatitude,
			tglHuman.dblLongitude AS HumanstrLongitude,
			tglHuman.blnForeignAddress AS HumanForeignAddressIndicator,
			tglHuman.strForeignAddress AS HumanForeignAddressString,
			hm.idfEmployerAddress AS EmployerGeoLocationID,
			ECountry.idfsReference AS EmployeridfsCountry,
			ECountry.[name] AS EmployerCountry,
			ERegion.idfsReference AS EmployeridfsRegion,
			ERegion.[name] AS EmployerRegion,
			ERayon.idfsReference AS EmployeridfsRayon,
			ERayon.[name] AS EmployerRayon,
			ESettlement.idfsReference AS EmployeridfsSettlement,
			ESettlement.[name] AS EmployerSettlement,
			ESettlement.idfsType AS EmployeridfsSettlementType,
			EmpSettlementType.strDefault AS EmployerSettlementType,
			tglEmployer.strPostCode AS EmployerstrPostalCode,
			tglEmployer.strStreetName AS EmployerstrStreetName,
			tglEmployer.strHouse AS EmployerstrHouse,
			tglEmployer.strBuilding AS EmployerstrBuilding,
			tglEmployer.strApartment AS EmployerstrApartment,
			tglEmployer.strDescription AS EmployerDescription,
			tglEmployer.dblLatitude AS EmployerstrLatitude,
			tglEmployer.dblLongitude AS EmployerstrLongitude,
			tglEmployer.blnForeignAddress AS EmployerForeignAddressIndicator,
			tglEmployer.strForeignAddress AS EmployerForeignAddressString,
			hm.idfRegistrationAddress AS HumanAltGeoLocationID,
			registrationCountry.idfsReference AS HumanAltidfsCountry,
			registrationCountry.[name] AS HumanAltCountry,
			registrationRegion.idfsReference AS HumanAltidfsRegion,
			registrationRegion.[name] AS HumanAltRegion,
			registrationRayon.idfsReference AS HumanAltidfsRayon,
			registrationRayon.[name] AS HumanAltRayon,
			registrationSettlement.idfsReference HumanAltidfsSettlement,
			registrationSettlement.[name] AS HumanAltSettlement,
			registrationSettlement.idfsType AS HumanAltidfsSettlementType,
			registrationSettlementType.[name] AS HumanAltSettlementType,
			tglRegistrationAddress.strPostCode AS HumanAltstrPostalCode,
			tglRegistrationAddress.strStreetName AS HumanAltstrStreetName,
			tglRegistrationAddress.strHouse AS HumanAltstrHouse,
			tglRegistrationAddress.strBuilding AS HumanAltstrBuilding,
			tglRegistrationAddress.strApartment AS HumanAltstrApartment,
			tglRegistrationAddress.strDescription AS HumanAltDescription,
			tglRegistrationAddress.dblLatitude AS HumanAltstrLatitude,
			tglRegistrationAddress.dblLongitude AS HumanAltstrLongitude,
			tglRegistrationAddress.blnForeignAddress AS HumanAltForeignAddressIndicator,
			tglRegistrationAddress.strForeignAddress AS HumanAltForeignAddressString,
			haai.SchoolAddressID AS SchoolGeoLocationID,
			schoolCountry.idfsReference AS SchoolidfsCountry,
			schoolRegion.idfsReference AS SchoolidfsRegion,
			schoolRayon.idfsReference AS SchoolidfsRayon,
			schoolSettlement.idfsReference AS SchoolidfsSettlement,
			schoolSettlement.idfsType AS SchoolAltidfsSettlementType,
			SchoolSettlementType.strDefault AS SchoolAltSettlementType,
			tglSchool.strPostCode AS SchoolstrPostalCode,
			tglSchool.strStreetName AS SchoolstrStreetName,
			tglSchool.strHouse AS SchoolstrHouse,
			tglSchool.strBuilding AS SchoolstrBuilding,
			tglSchool.strApartment AS SchoolstrApartment,
			tglSchool.blnForeignAddress AS SchoolForeignAddressIndicator,
			tglSchool.strForeignAddress AS SchoolForeignAddressString,
			dbo.FN_GBL_FormatDate(ha.datDateofBirth, 'mm/dd/yyyy') AS DateOfBirth,
			dbo.FN_GBL_FormatDate(ha.datDateOfDeath, 'mm/dd/yyyy') AS DateOfDeath,
			dbo.FN_GBL_FormatDate(ha.datEnteredDate, 'mm/dd/yyyy') AS EnteredDate,
			dbo.FN_GBL_FormatDate(ha.datModificationDate, 'mm/dd/yyyy') AS ModificationDate,
			hm.strFirstName AS FirstOrGivenName,
			hm.strSecondName AS SecondName,
			hm.strLastName AS LastOrSurname,
			hm.strEmployerName AS EmployerName,
			hm.strHomePhone AS HomePhone,
			hm.strWorkPhone AS WorkPhone,
			hm.idfsPersonIDType AS PersonalIDType,
			ha.strPersonID AS PersonalID,
			haai.ReportedAge,
			haai.ReportedAgeUOMID,
			haai.PassportNbr AS PassportNumber,
			haai.IsEmployedID AS IsEmployedTypeID,
			isEmployed.name AS IsEmployedTypeName,
			haai.EmployerPhoneNbr AS EmployerPhone,
			haai.EmployedDTM AS EmployedDateLastPresent,
			haai.IsStudentID AS IsStudentTypeID,
			isStudent.name AS IsStudentTypeName,
			haai.SchoolName AS SchoolName,
			haai.SchoolLastAttendDTM AS SchoolDateLastAttended,
			haai.SchoolPhoneNbr AS SchoolPhone,
			haai.ContactPhoneCountryCode,
			haai.ContactPhoneNbr AS ContactPhone,
			haai.ContactPhoneNbrTypeID AS ContactPhoneTypeID,
			ContactPhoneNbrTypeID.name AS ContactPhoneTypeName,
			haai.ContactPhone2CountryCode,
			haai.ContactPhone2Nbr AS ContactPhone2,
			haai.ContactPhone2NbrTypeID AS ContactPhone2TypeID,
			ContactPhone2NbrTypeID.name AS ContactPhone2TypeName,
			personalIDType.name AS PersonalIDTypeName,
			occupationType.name AS OccupationTypeName,
			schoolCountry.name AS SchoolCountry,
			schoolRegion.name AS SchoolRegion,
			schoolRayon.name AS SchoolRayon,
			schoolSettlement.name AS SchoolSettlement,
			CASE 
				WHEN haai.ContactPhone2Nbr IS NULL
					AND haai.ContactPhone2NbrTypeID IS NULL
					THEN 'No'
				ELSE 'Yes'
				END AS IsAnotherPhone,
			--CAST(ISNULL(haai.ReportedAge, '') AS VARCHAR(3)) + ' ' + ISNULL(HumanAgeType.name, '') AS Age,
			CASE 
				WHEN ha.datDateofBirth IS NULL OR ha.datDateofBirth = '' THEN ''
				ELSE CASE
					WHEN HumanAgeType.idfsReference = 10042001 THEN CAST(DATEDIFF(DAY,ha.datDateofBirth,ha.datEnteredDate) AS VARCHAR(3))  
					WHEN HumanAgeType.idfsReference = 10042002 THEN CAST(DATEDIFF(MONTH,ha.datDateofBirth,ha.datEnteredDate) AS VARCHAR(3))  
					WHEN HumanAgeType.idfsReference = 10042004 THEN CAST(DATEDIFF(WEEK,ha.datDateofBirth,ha.datEnteredDate) AS VARCHAR(3)) 
					ELSE CAST(DATEDIFF(YEAR,ha.datDateofBirth,ha.datEnteredDate) AS VARCHAR(3)) 
				END + ' ' + ISNULL(HumanAgeType.name, '') 			
			END AS Age,
			CASE 
				WHEN hm.idfRegistrationAddress IS NOT NULL
					AND hm.idfRegistrationAddress > 0
					THEN 'Yes'
				ELSE 'No'
				END AS YNAnotherAddress,
			CASE 
				WHEN tglHuman.blnForeignAddress IS NOT NULL
					AND tglHuman.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNHumanForeignAddress,
			CASE 
				WHEN tglEmployer.blnForeignAddress IS NOT NULL
					AND tglEmployer.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNEmployerForeignAddress,
			CASE 
				WHEN tglRegistrationAddress.blnForeignAddress IS NOT NULL
					AND tglRegistrationAddress.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNHumanAltForeignAddress,
			CASE 
				WHEN tglSchool.blnForeignAddress IS NOT NULL
					AND tglSchool.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNSchoolForeignAddress,
			CASE 
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(humanCountry.name, N''), ISNULL(humanRegion.name, N''), ISNULL(humanRayon.name, N''), ISNULL(tglHuman.strPostCode, N''), ISNULL(humanSettlementType.strDefault, N''), ISNULL(humanSettlement.name, N''), ISNULL(tglHuman.strStreetName, N''), ISNULL(tglHuman.strHouse, N''), ISNULL(tglHuman.strBuilding, N''), ISNULL(tglHuman.strApartment, N''), ISNULL(tglHuman.blnForeignAddress, N''), ISNULL(tglHuman.strForeignAddress, N'')) = dbo.FN_GBL_CreateAddressString(ISNULL(ECountry.name, N''), ISNULL(ERegion.name, N''), ISNULL(ERayon.name, N''), ISNULL(tglEmployer.strPostCode, N''), ISNULL(EmpSettlementType.strDefault, N''), ISNULL(ESettlement.name, N''), ISNULL(tglEmployer.strStreetName, N''), ISNULL(tglEmployer.strHouse, N''), ISNULL(tglEmployer.strBuilding, N''), ISNULL(tglEmployer.strApartment, N''), ISNULL(tglEmployer.blnForeignAddress, N''), ISNULL(tglEmployer.strForeignAddress, N''))
					THEN 'Yes'
				ELSE 'No'
				END AS YNWorkSameAddress
		FROM dbo.tlbHuman hm
		JOIN dbo.tlbHumanActual ha ON ha.idfHumanActual = hm.idfHumanActual
		LEFT JOIN dbo.HumanAddlinfo haai ON hm.idfHuman = haai.HumanAdditionalInfo
		LEFT JOIN dbo.tlbGeoLocation AS tglHuman ON hm.idfCurrentResidenceAddress = tglHuman.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglEmployer ON hm.idfEmployerAddress = tglEmployer.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglRegistrationAddress ON hm.idfRegistrationAddress = tglRegistrationAddress.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglSchool ON haai.SchoolAddressID = tglSchool.idfGeoLocation
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000043) tb ON tb.idfsReference = ha.idfsHumanGender

		-- joined to get human location
		LEFT JOIN dbo.gisLocation HL ON HL.idfsLocation = tglHuman.idfsLocation
		-- changed to FN_GBL_GIS_ReferenceRepairNL_GET from FN_GBL_GIS_Reference_GET
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000001) AS humanCountry ON HL.node.IsDescendantOf(humanCountry.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000003) AS humanRegion ON HL.node.IsDescendantOf(humanRegion.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000002) AS humanRayon ON HL.node.IsDescendantOf(humanRayon.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000004) AS humanSettlement ON HL.node.IsDescendantOf(humanSettlement.node) = 1
		-- MCW added to get Human settlement type
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS humanSettlementType ON humanSettlementType.idfsReference = humanSettlement.idfsType

		-- Employer location information
		LEFT JOIN dbo.gisLocation EA ON EA.idfsLocation = tglEmployer.idfsLocation
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000001) AS ECountry ON EA.node.IsDescendantOf(Ecountry.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000003) AS ERegion ON EA.node.IsDescendantOf(ERegion.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000002) AS ERayon ON EA.node.IsDescendantOf(ERayon.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000004) AS ESettlement ON EA.node.IsDescendantOf(ESettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS EmpSettlementType ON EmpSettlementType.idfsReference = ESettlement.idfsType

		-- Registration information
		-- Employer location information
		LEFT JOIN dbo.gisLocation registrationLocation ON registrationLocation.idfsLocation = tglRegistrationAddress.idfsLocation
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000001) AS registrationCountry ON registrationLocation.node.IsDescendantOf(registrationCountry.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000003) AS registrationRegion ON registrationLocation.node.IsDescendantOf(registrationRegion.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000002) AS registrationRayon ON registrationLocation.node.IsDescendantOf(registrationRayon.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000004) AS registrationSettlement ON registrationLocation.node.IsDescendantOf(registrationSettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS registrationSettlementType ON registrationSettlementType.idfsReference = registrationSettlement.idfsType

		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000100) isEmployed ON IsEmployed.idfsReference = haai.IsEmployedID
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000100) isStudent ON isStudent.idfsReference = haai.IsStudentID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000054) AS citizenshipType ON ha.idfsNationality = citizenshipType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000500) AS contactPhoneNbrTypeID ON contactPhoneNbrTypeID.idfsReference = haai.ContactPhoneNbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000500) AS contactPhone2NbrTypeID ON contactPhone2NbrTypeID.idfsReference = haai.ContactPhone2NbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000148) AS personalIDType ON ha.idfsPersonIDType = personalIDType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000061) AS occupationType ON ha.idfsOccupationType = occupationType.idfsReference

		-- school information
		LEFT JOIN dbo.gisLocation SchoolLocation ON SchoolLocation.idfsLocation = tglSchool.idfsLocation
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000001) AS schoolCountry ON SchoolLocation.node.IsDescendantOf(schoolCountry.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000003) AS schoolRegion ON SchoolLocation.node.IsDescendantOf(schoolRegion.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000002) AS schoolRayon ON SchoolLocation.node.IsDescendantOf(schoolRayon.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepairNL_GET(@LanguageID, 19000004) AS schoolSettlement ON SchoolLocation.node.IsDescendantOf(schoolSettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS schoolSettlementType ON schoolSettlementType.idfsReference = schoolSettlement.idfsType

		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000042) AS HumanAgeType ON haai.ReportedAgeUOMID = HumanAgeType.idfsReference
		
		WHERE hm.idfHuman = @HumanID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
