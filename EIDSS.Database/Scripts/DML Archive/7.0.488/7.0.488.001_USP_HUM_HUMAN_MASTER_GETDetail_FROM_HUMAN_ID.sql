﻿-- ================================================================================================
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
CREATE OR ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETDetail_FROM_HUMAN_ID] (
	@LanguageID NVARCHAR(20),
	@HumanID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT dbo.fnConcatFullName(hm.strLastName, hm.strFirstName, hm.strSecondName) AS PatientFarmOwnerName,
			ha.idfHumanActual AS HumanActualId,
			hm.idfHuman AS HumanId,
            humanActualAddlInfo.EIDSSPersonID AS EIDSSPersonID,
			hm.idfsOccupationType AS OccupationTypeID,
			hm.idfsNationality AS CitizenshipTypeID,
			citizenshipType.[name] AS CitizenshipTypeName,
			hm.idfsHumanGender AS GenderTypeID,
			tb.[name] AS GenderTypeName,

			-- Current Address
			hm.idfCurrentResidenceAddress AS HumanGeoLocationID,
			lhHuman.AdminLevel1ID AS HumanidfsCountry,
			lhHuman.AdminLevel1Name AS HumanCountry,
			lhHuman.AdminLevel2ID AS HumanidfsRegion,
			lhHuman.AdminLevel2Name AS HumanRegion,
			lhHuman.AdminLevel3ID AS HumanidfsRayon,
			lhHuman.AdminLevel3Name AS HumanRayon,
			lhHuman.AdminLevel4ID AS HumanidfsSettlement,
			lhHuman.AdminLevel4Name AS HumanSettlement,
			HL.idfsType AS HumanidfsSettlementType,
			humanSettlementType.[name] AS HumanSettlementType,
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
			
			-- Employer Address
			hm.idfEmployerAddress AS EmployerGeoLocationID,
			lhEmployer.AdminLevel1ID AS EmployeridfsCountry,
			lhEmployer.AdminLevel1Name AS EmployerCountry,
			lhEmployer.AdminLevel2ID AS EmployeridfsRegion,
			lhEmployer.AdminLevel2Name AS EmployerRegion,
			lhEmployer.AdminLevel3ID AS EmployeridfsRayon,
			lhEmployer.AdminLevel3Name AS EmployerRayon,
			lhEmployer.AdminLevel4ID AS EmployeridfsSettlement,
			lhEmployer.AdminLevel4Name AS EmployerSettlement,
			EA.idfsType AS EmployeridfsSettlementType,
			EmpSettlementType.[name] AS EmployerSettlementType,
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
			
			-- Permanent Address
			hm.idfRegistrationAddress AS HumanPermGeoLocationID,
			lhPerm.AdminLevel1ID AS HumanPermidfsCountry,
			lhPerm.AdminLevel1Name AS HumanPermCountry,
			lhPerm.AdminLevel2ID AS HumanPermidfsRegion,
			lhPerm.AdminLevel2Name AS HumanPermRegion,
			lhPerm.AdminLevel3ID AS HumanPermidfsRayon,
			lhPerm.AdminLevel3Name AS HumanPermRayon,
			lhPerm.AdminLevel4ID HumanPermidfsSettlement,
			lhPerm.AdminLevel4Name AS HumanPermSettlement,
			registrationLocation.idfsType AS HumanPermidfsSettlementType,
			registrationSettlementType.[name] AS HumanPermSettlementType,
			tglRegistrationAddress.strPostCode AS HumanPermstrPostalCode,
			tglRegistrationAddress.strStreetName AS HumanPermstrStreetName,
			tglRegistrationAddress.strHouse AS HumanPermstrHouse,
			tglRegistrationAddress.strBuilding AS HumanPermstrBuilding,
			tglRegistrationAddress.strApartment AS HumanPermstrApartment,
			tglRegistrationAddress.strDescription AS HumanPermDescription,
			tglRegistrationAddress.dblLatitude AS HumanPermstrLatitude,
			tglRegistrationAddress.dblLongitude AS HumanPermstrLongitude,
			tglRegistrationAddress.blnForeignAddress AS HumanPermForeignAddressIndicator,
			tglRegistrationAddress.strForeignAddress AS HumanPermForeignAddressString,

			-- Alternate Address
			haai.AltAddressID AS HumanAltGeoLocationID,
			lhAlt.AdminLevel1ID AS HumanAltidfsCountry,
			lhAlt.AdminLevel1Name AS HumanAltCountry,
			lhAlt.AdminLevel2ID AS HumanAltidfsRegion,
			lhAlt.AdminLevel2Name AS HumanAltRegion,
			lhAlt.AdminLevel3ID AS HumanAltidfsRayon,
			lhAlt.AdminLevel3Name AS HumanAltRayon,
			lhAlt.AdminLevel4ID HumanAltidfsSettlement,
			lhAlt.AdminLevel4Name AS HumanAltSettlement,
			AltLocation.idfsType AS HumanAltidfsSettlementType,
			AltSettlementType.[name] AS HumanAltSettlementType,
			tglAlt.strPostCode AS HumanAltstrPostalCode,
			tglAlt.strStreetName AS HumanAltstrStreetName,
			tglAlt.strHouse AS HumanAltstrHouse,
			tglAlt.strBuilding AS HumanAltstrBuilding,
			tglAlt.strApartment AS HumanAltstrApartment,
			tglAlt.strDescription AS HumanAltDescription,
			tglAlt.dblLatitude AS HumanAltstrLatitude,
			tglAlt.dblLongitude AS HumanAltstrLongitude,
			tglAlt.blnForeignAddress AS HumanAltForeignAddressIndicator,
			tglAlt.strForeignAddress AS HumanAltForeignAddressString,
			
			-- School Address
			haai.SchoolAddressID AS SchoolGeoLocationID,
			lhSchool.AdminLevel1ID AS SchoolidfsCountry,
			lhSchool.AdminLevel1Name AS SchoolCountry,
			lhSchool.AdminLevel2ID AS SchoolidfsRegion,
			lhSchool.AdminLevel2Name AS SchoolRegion,
			lhSchool.AdminLevel3ID AS SchoolidfsRayon,
			lhSchool.AdminLevel3Name AS SchoolRayon,
			lhSchool.AdminLevel4ID AS SchoolidfsSettlement,
			lhSchool.AdminLevel4Name AS SchoolSettlement,
			SchoolLocation.idfsType AS SchoolAltidfsSettlementType,
			SchoolSettlementType.[name] AS SchoolAltSettlementType,
			tglSchool.strPostCode AS SchoolstrPostalCode,
			tglSchool.strStreetName AS SchoolstrStreetName,
			tglSchool.strHouse AS SchoolstrHouse,
			tglSchool.strBuilding AS SchoolstrBuilding,
			tglSchool.strApartment AS SchoolstrApartment,
			tglSchool.blnForeignAddress AS SchoolForeignAddressIndicator,
			tglSchool.strForeignAddress AS SchoolForeignAddressString,
			
			hm.datDateofBirth AS DateOfBirth,
			hm.datDateOfDeath AS DateOfDeath,
			hm.datEnteredDate AS EnteredDate,
			hm.datModificationDate AS ModificationDate,
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
			isEmployed.[name] AS IsEmployedTypeName,
			haai.EmployerPhoneNbr AS EmployerPhone,
			haai.EmployedDTM AS EmployedDateLastPresent,
			haai.IsStudentID AS IsStudentTypeID,
			isStudent.[name] AS IsStudentTypeName,
			haai.SchoolName AS SchoolName,
			haai.SchoolLastAttendDTM AS SchoolDateLastAttended,
			haai.SchoolPhoneNbr AS SchoolPhone,
			haai.ContactPhoneCountryCode,
			haai.ContactPhoneNbr AS ContactPhone,
			haai.ContactPhoneNbrTypeID AS ContactPhoneTypeID,
			ContactPhoneNbrTypeID.[name] AS ContactPhoneTypeName,
			haai.ContactPhone2CountryCode,
			haai.ContactPhone2Nbr AS ContactPhone2,
			haai.ContactPhone2NbrTypeID AS ContactPhone2TypeID,
			ContactPhone2NbrTypeID.[name] AS ContactPhone2TypeName,
			personalIDType.[name] AS PersonalIDTypeName,
			occupationType.[name] AS OccupationTypeName,
						
			--TODO: Remove IsAnotherPhone and YNAnotherAddress
			CASE 
				WHEN haai.IsAnotherPhoneID = 10100001 /*Yes*/
					THEN 'Yes'
				ELSE 'No'
				END AS IsAnotherPhone,
			ISNULL(CAST(haai.ReportedAge AS NVARCHAR(20)) + N' ' + ISNULL(HumanAgeType.[name], N'') collate Cyrillic_General_CI_AS, N'') AS Age,
			CASE 
				WHEN haai.IsAnotherAddressID = 10100001 /*Yes*/
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
				END AS YNHumPermForeignAddress,
			CASE 
				WHEN tglAlt.blnForeignAddress IS NOT NULL
					AND tglAlt.blnForeignAddress = 1
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
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(lhHuman.AdminLevel1Name, N''), ISNULL(lhHuman.AdminLevel2Name, N''), ISNULL(lhHuman.AdminLevel3Name, N''), ISNULL(tglHuman.strPostCode, N''), ISNULL(humanSettlementType.strDefault, N''), ISNULL(lhHuman.AdminLevel4Name, N''), ISNULL(tglHuman.strStreetName, N''), ISNULL(tglHuman.strHouse, N''), ISNULL(tglHuman.strBuilding, N''), ISNULL(tglHuman.strApartment, N''), ISNULL(tglHuman.blnForeignAddress, N''), ISNULL(tglHuman.strForeignAddress, N'')) = 
						dbo.FN_GBL_CreateAddressString(ISNULL(lhEmployer.AdminLevel1Name, N''), ISNULL(lhEmployer.AdminLevel2Name, N''), ISNULL(lhEmployer.AdminLevel3Name, N''), ISNULL(tglEmployer.strPostCode, N''), ISNULL(EmpSettlementType.strDefault, N''), ISNULL(lhEmployer.AdminLevel4Name, N''), ISNULL(tglEmployer.strStreetName, N''), ISNULL(tglEmployer.strHouse, N''), ISNULL(tglEmployer.strBuilding, N''), ISNULL(tglEmployer.strApartment, N''), ISNULL(tglEmployer.blnForeignAddress, N''), ISNULL(tglEmployer.strForeignAddress, N''))
					THEN 'Yes'
				ELSE 'No'
				END AS YNWorkSameAddress,
			CASE 
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(lhHuman.AdminLevel1Name, N''), ISNULL(lhHuman.AdminLevel2Name, N''), ISNULL(lhHuman.AdminLevel3Name, N''), ISNULL(tglHuman.strPostCode, N''), ISNULL(humanSettlementType.strDefault, N''), ISNULL(lhHuman.AdminLevel4Name, N''), ISNULL(tglHuman.strStreetName, N''), ISNULL(tglHuman.strHouse, N''), ISNULL(tglHuman.strBuilding, N''), ISNULL(tglHuman.strApartment, N''), ISNULL(tglHuman.blnForeignAddress, N''), ISNULL(tglHuman.strForeignAddress, N'')) = 
						dbo.FN_GBL_CreateAddressString(ISNULL(lhPerm.AdminLevel1Name, N''), ISNULL(lhPerm.AdminLevel2Name, N''), ISNULL(lhPerm.AdminLevel3Name, N''), ISNULL(tglRegistrationAddress.strPostCode, N''), ISNULL(registrationSettlementType.strDefault, N''), ISNULL(lhPerm.AdminLevel4Name, N''), ISNULL(tglRegistrationAddress.strStreetName, N''), ISNULL(tglRegistrationAddress.strHouse, N''), ISNULL(tglRegistrationAddress.strBuilding, N''), ISNULL(tglRegistrationAddress.strApartment, N''), ISNULL(tglRegistrationAddress.blnForeignAddress, N''), ISNULL(tglRegistrationAddress.strForeignAddress, N''))
					THEN 'Yes'
				ELSE 'No'
				END AS YNPermanentSameAddress,
			haai.IsAnotherPhoneID as IsAnotherPhoneTypeID,
			haai.IsAnotherAddressID as IsAnotherAddressTypeID

		FROM dbo.tlbHuman hm
		JOIN dbo.tlbHumanActual ha ON ha.idfHumanActual = hm.idfHumanActual
		LEFT JOIN dbo.HumanAddlinfo haai ON hm.idfHuman = haai.HumanAdditionalInfo
		LEFT JOIN dbo.HumanActualAddlInfo humanActualAddlInfo ON ha.idfHumanActual = humanActualAddlInfo.HumanActualAddlInfoUID
		LEFT JOIN dbo.tlbGeoLocation AS tglHuman ON hm.idfCurrentResidenceAddress = tglHuman.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglEmployer ON hm.idfEmployerAddress = tglEmployer.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglRegistrationAddress ON hm.idfRegistrationAddress = tglRegistrationAddress.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglSchool ON haai.SchoolAddressID = tglSchool.idfGeoLocation
		LEFT JOIN dbo.tlbGeoLocation AS tglAlt ON haai.AltAddressID = tglAlt.idfGeoLocation
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000043) tb ON tb.idfsReference = ha.idfsHumanGender

		-- joined to get human location
		LEFT JOIN dbo.gisLocation HL ON HL.idfsLocation = tglHuman.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lhHuman ON lhHuman.idfsLocation = tglHuman.idfsLocation			
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS humanSettlementType ON humanSettlementType.idfsReference = HL.idfsType

		-- Employer location information
		LEFT JOIN dbo.gisLocation EA ON EA.idfsLocation = tglEmployer.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lhEmployer ON lhEmployer.idfsLocation = tglEmployer.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS EmpSettlementType ON EmpSettlementType.idfsReference = EA.idfsType

		-- Registration information
		-- Employer location information
		LEFT JOIN dbo.gisLocation registrationLocation ON registrationLocation.idfsLocation = tglRegistrationAddress.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lhPerm ON lhPerm.idfsLocation = tglRegistrationAddress.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS registrationSettlementType ON registrationSettlementType.idfsReference = registrationLocation.idfsType


		-- Alternate address - new for EIDSS7
		LEFT JOIN dbo.gisLocation AltLocation ON AltLocation.idfsLocation = tglAlt.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lhAlt ON lhAlt.idfsLocation = tglAlt.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS AltSettlementType ON AltSettlementType.idfsReference = AltLocation.idfsType

		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000100) isEmployed ON IsEmployed.idfsReference = haai.IsEmployedID
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000100) isStudent ON isStudent.idfsReference = haai.IsStudentID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000054) AS citizenshipType ON ha.idfsNationality = citizenshipType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000500) AS contactPhoneNbrTypeID ON contactPhoneNbrTypeID.idfsReference = haai.ContactPhoneNbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000500) AS contactPhone2NbrTypeID ON contactPhone2NbrTypeID.idfsReference = haai.ContactPhone2NbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000148) AS personalIDType ON ha.idfsPersonIDType = personalIDType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000061) AS occupationType ON ha.idfsOccupationType = occupationType.idfsReference

		-- school information
		LEFT JOIN dbo.gisLocation SchoolLocation ON SchoolLocation.idfsLocation = tglSchool.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lhSchool ON lhSchool.idfsLocation = tglSchool.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) AS schoolSettlementType ON schoolSettlementType.idfsReference = SchoolLocation.idfsType

		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000042) AS HumanAgeType ON haai.ReportedAgeUOMID = HumanAgeType.idfsReference
		
		WHERE hm.idfHuman = @HumanID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END