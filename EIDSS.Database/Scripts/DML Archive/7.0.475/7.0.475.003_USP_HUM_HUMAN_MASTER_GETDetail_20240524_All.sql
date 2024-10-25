set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.475.003'

	-- Command to use in the calls of the stored procedure sp_executesql in case there are GO statements that should be avoided.
	-- Each call of sp_executesql can implement execution of the script between two GO statements
	declare @cmd nvarchar(max) = N''


  -- Verify database and script versions
  if	@Version is null
  begin
    raiserror ('Script doesn''t have version', 16, 1)
  end
  else begin
	-- Workaround to apply the script multiple times
	-- delete from tstLocalSiteOptions where strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS

    -- Check if script has already been applied by means of database version
    IF EXISTS (SELECT * FROM tstLocalSiteOptions tlso WHERE tlso.strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS)
    begin
      print	'Script with version ' + @Version + ' has already been applied to the database ' + DB_NAME() + N' on the server ' + @@servername + N'.'
    end
    else begin
		-- Common part

		set @cmd = N'
CREATE or ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETDetail] (
	@LangID NVARCHAR(20),
	@HumanMasterID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT dbo.fnConcatFullName(ha.strLastName, ha.strFirstName, ha.strSecondName) AS PatientFarmOwnerName,
			haai.EIDSSPersonID AS EIDSSPersonID,
			ha.idfsOccupationType AS OccupationTypeID,
			ha.idfsNationality AS CitizenshipTypeID,
			citizenshipType.[name] AS CitizenshipTypeName,
			ha.idfsHumanGender AS GenderTypeID,
			tb.[name] AS GenderTypeName,

			-- Current Address
			ha.idfCurrentResidenceAddress AS HumanGeoLocationID,
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
			ha.idfEmployerAddress AS EmployerGeoLocationID,
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
			ha.idfRegistrationAddress AS HumanPermGeoLocationID,
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
			SchoolSettlementType.strDefault AS SchoolAltSettlementType,
			tglSchool.strPostCode AS SchoolstrPostalCode,
			tglSchool.strStreetName AS SchoolstrStreetName,
			tglSchool.strHouse AS SchoolstrHouse,
			tglSchool.strBuilding AS SchoolstrBuilding,
			tglSchool.strApartment AS SchoolstrApartment,
			tglSchool.blnForeignAddress AS SchoolForeignAddressIndicator,
			tglSchool.strForeignAddress AS SchoolForeignAddressString,
			
			ha.datDateofBirth AS DateOfBirth,
			ha.datDateOfDeath AS DateOfDeath,
			ha.datEnteredDate AS EnteredDate,
			ha.datModificationDate AS ModificationDate,
			ha.strFirstName AS FirstOrGivenName,
			ha.strSecondName AS SecondName,
			ha.strLastName AS LastOrSurname,
			ha.strEmployerName AS EmployerName,
			ha.strHomePhone AS HomePhone,
			ha.strWorkPhone AS WorkPhone,
			ha.idfsPersonIDType AS PersonalIDType,
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
					THEN ''Yes''
				ELSE ''No''
				END AS IsAnotherPhone,
			cast(N'''' as nvarchar(200)) AS Age, 
			CASE 
				WHEN haai.IsAnotherAddressID = 10100001 /*Yes*/
					THEN ''Yes''
				ELSE ''No''
				END AS YNAnotherAddress,
			CASE 
				WHEN tglHuman.blnForeignAddress IS NOT NULL
					AND tglHuman.blnForeignAddress = 1
					THEN ''Yes''
				ELSE ''No''
				END AS YNHumanForeignAddress,
			CASE 
				WHEN tglEmployer.blnForeignAddress IS NOT NULL
					AND tglEmployer.blnForeignAddress = 1
					THEN ''Yes''
				ELSE ''No''
				END AS YNEmployerForeignAddress,
			CASE 
				WHEN tglRegistrationAddress.blnForeignAddress IS NOT NULL
					AND tglRegistrationAddress.blnForeignAddress = 1
					THEN ''Yes''
				ELSE ''No''
				END AS YNHumPermForeignAddress,
			CASE 
				WHEN tglAlt.blnForeignAddress IS NOT NULL
					AND tglAlt.blnForeignAddress = 1
					THEN ''Yes''
				ELSE ''No''
				END AS YNHumanAltForeignAddress,
			CASE 
				WHEN tglSchool.blnForeignAddress IS NOT NULL
					AND tglSchool.blnForeignAddress = 1
					THEN ''Yes''
				ELSE ''No''
				END AS YNSchoolForeignAddress,
			CASE 
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(lhHuman.AdminLevel1Name, N''''), ISNULL(lhHuman.AdminLevel2Name, N''''), ISNULL(lhHuman.AdminLevel3Name, N''''), ISNULL(tglHuman.strPostCode, N''''), ISNULL(humanSettlementType.strDefault, N''''), ISNULL(lhHuman.AdminLevel4Name, N''''), ISNULL(tglHuman.strStreetName, N''''), ISNULL(tglHuman.strHouse, N''''), ISNULL(tglHuman.strBuilding, N''''), ISNULL(tglHuman.strApartment, N''''), ISNULL(tglHuman.blnForeignAddress, N''''), ISNULL(tglHuman.strForeignAddress, N'''')) = 
						dbo.FN_GBL_CreateAddressString(ISNULL(lhEmployer.AdminLevel1Name, N''''), ISNULL(lhEmployer.AdminLevel2Name, N''''), ISNULL(lhEmployer.AdminLevel3Name, N''''), ISNULL(tglEmployer.strPostCode, N''''), ISNULL(EmpSettlementType.strDefault, N''''), ISNULL(lhEmployer.AdminLevel4Name, N''''), ISNULL(tglEmployer.strStreetName, N''''), ISNULL(tglEmployer.strHouse, N''''), ISNULL(tglEmployer.strBuilding, N''''), ISNULL(tglEmployer.strApartment, N''''), ISNULL(tglEmployer.blnForeignAddress, N''''), ISNULL(tglEmployer.strForeignAddress, N''''))
					THEN ''Yes''
				ELSE ''No''
				END AS YNWorkSameAddress,
			CASE 
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(lhHuman.AdminLevel1Name, N''''), ISNULL(lhHuman.AdminLevel2Name, N''''), ISNULL(lhHuman.AdminLevel3Name, N''''), ISNULL(tglHuman.strPostCode, N''''), ISNULL(humanSettlementType.strDefault, N''''), ISNULL(lhHuman.AdminLevel4Name, N''''), ISNULL(tglHuman.strStreetName, N''''), ISNULL(tglHuman.strHouse, N''''), ISNULL(tglHuman.strBuilding, N''''), ISNULL(tglHuman.strApartment, N''''), ISNULL(tglHuman.blnForeignAddress, N''''), ISNULL(tglHuman.strForeignAddress, N'''')) = 
						dbo.FN_GBL_CreateAddressString(ISNULL(lhPerm.AdminLevel1Name, N''''), ISNULL(lhPerm.AdminLevel2Name, N''''), ISNULL(lhPerm.AdminLevel3Name, N''''), ISNULL(tglRegistrationAddress.strPostCode, N''''), ISNULL(registrationSettlementType.strDefault, N''''), ISNULL(lhPerm.AdminLevel4Name, N''''), ISNULL(tglRegistrationAddress.strStreetName, N''''), ISNULL(tglRegistrationAddress.strHouse, N''''), ISNULL(tglRegistrationAddress.strBuilding, N''''), ISNULL(tglRegistrationAddress.strApartment, N''''), ISNULL(tglRegistrationAddress.blnForeignAddress, N''''), ISNULL(tglRegistrationAddress.strForeignAddress, N''''))
					THEN ''Yes''
				ELSE ''No''
				END AS YNPermanentSameAddress,
			haai.IsAnotherPhoneID as IsAnotherPhoneTypeID,
			haai.IsAnotherAddressID as IsAnotherAddressTypeID

		FROM dbo.tlbHumanActual ha

		LEFT JOIN dbo.HumanActualAddlinfo haai ON ha.idfHumanActual = haai.HumanActualAddlinfoUID
		LEFT JOIN dbo.tlbGeoLocationShared AS tglHuman ON ha.idfCurrentResidenceAddress = tglHuman.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglEmployer ON ha.idfEmployerAddress = tglEmployer.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglRegistrationAddress ON ha.idfRegistrationAddress = tglRegistrationAddress.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglSchool ON haai.SchoolAddressID = tglSchool.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglAlt ON haai.AltAddressID = tglAlt.idfGeoLocationShared
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043) tb ON tb.idfsReference = ha.idfsHumanGender

		-- Current Address
		LEFT JOIN dbo.gisLocation HL ON HL.idfsLocation = tglHuman.idfsLocation	
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhHuman ON lhHuman.idfsLocation = tglHuman.idfsLocation			
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS humanSettlementType ON humanSettlementType.idfsReference = HL.idfsType

		-- Employer address 
		LEFT JOIN dbo.gisLocation EA ON EA.idfsLocation = tglEmployer.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhEmployer ON lhEmployer.idfsLocation = tglEmployer.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS EmpSettlementType ON EmpSettlementType.idfsReference = EA.idfsType

		-- Permanent address 
		LEFT JOIN dbo.gisLocation registrationLocation ON registrationLocation.idfsLocation = tglRegistrationAddress.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhPerm ON lhPerm.idfsLocation = tglRegistrationAddress.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS registrationSettlementType ON registrationSettlementType.idfsReference = registrationLocation.idfsType

		-- Alternate address - new for EIDSS7
		LEFT JOIN dbo.gisLocation AltLocation ON AltLocation.idfsLocation = tglAlt.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhAlt ON lhAlt.idfsLocation = tglAlt.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS AltSettlementType ON AltSettlementType.idfsReference = AltLocation.idfsType

		LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000100) isEmployed ON IsEmployed.idfsReference = haai.IsEmployedID
		LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000100) isStudent ON isStudent.idfsReference = haai.IsStudentID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000054) AS citizenshipType ON ha.idfsNationality = citizenshipType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000500) AS contactPhoneNbrTypeID ON contactPhoneNbrTypeID.idfsReference = haai.ContactPhoneNbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000500) AS contactPhone2NbrTypeID ON contactPhone2NbrTypeID.idfsReference = haai.ContactPhone2NbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000148) AS personalIDType ON ha.idfsPersonIDType = personalIDType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000061) AS occupationType ON ha.idfsOccupationType = occupationType.idfsReference

		-- School address - E6 school address was originally stored in idfEmployerAddress with employment type = ''Student''
		LEFT JOIN dbo.gisLocation SchoolLocation ON SchoolLocation.idfsLocation = tglSchool.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhSchool ON lhSchool.idfsLocation = tglSchool.idfsLocation		
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS schoolSettlementType ON schoolSettlementType.idfsReference = SchoolLocation.idfsType

		WHERE ha.idfHumanActual = @HumanMasterID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
'
		exec sp_executesql @cmd

		-- Add version of the current script to the database
		if not exists (select * from tstLocalSiteOptions lso where strName = 'DBScript(' + @Version + ')' collate Cyrillic_General_CI_AS)
		  INSERT INTO tstLocalSiteOptions (strName, strValue, SourceSystemNameID, SourceSystemKeyValue, AuditCreateDTM, AuditCreateUser) 
		  VALUES ('DBScript(' + @Version + ')', CONVERT(NVARCHAR, GETDATE(), 121), 10519001 /*EIDSSv7*/, N'[{"strName":"DBScript(' + @Version + N')"}]', GETDATE(), N'SYSTEM')
	end
end

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

  declare	@err_number int
  declare	@err_severity int
  declare	@err_state int
  declare	@err_line int
  declare	@err_procedure	nvarchar(200)
  declare	@err_message	nvarchar(MAX)
  
  select	@err_number = ERROR_NUMBER(),
      @err_severity = ERROR_SEVERITY(),
      @err_state = ERROR_STATE(),
      @err_line = ERROR_LINE(),
      @err_procedure = ERROR_PROCEDURE(),
      @err_message = ERROR_MESSAGE()

  set	@err_message = N'An error occurred during script execution.
' + N'Msg ' + cast(isnull(@err_number, 0) as nvarchar(20)) + 
N', Level ' + cast(isnull(@err_severity, 0) as nvarchar(20)) + 
N', State ' + cast(isnull(@err_state, 0) as nvarchar(20)) + 
N', Line ' + cast(isnull(@err_line, 0) as nvarchar(20)) + N'
' + isnull(@err_message, N'Unknown error')

  raiserror	(	@err_message,
          17,
          @err_state
        ) with SETERROR

END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

set XACT_ABORT off
set nocount off
