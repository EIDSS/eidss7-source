set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.475.006'

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
CREATE OR ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_SET] (
	@HumanMasterID BIGINT = NULL,
	@CopyToHumanIndicator BIT = 0, 
	@PersonalIDType BIGINT = NULL,
	@EIDSSPersonID NVARCHAR(200) = NULL,
	@PersonalID NVARCHAR(100) = NULL,
	@FirstName NVARCHAR(200) = NULL,
	@SecondName NVARCHAR(200) = NULL,
	@LastName NVARCHAR(200),
	@DateOfBirth DATETIME = NULL,
	@DateOfDeath DATETIME = NULL,
	@HumanGenderTypeID BIGINT = NULL,
	@OccupationTypeID BIGINT = NULL,
	@CitizenshipTypeID BIGINT = NULL,
	@PassportNumber NVARCHAR(20) = NULL,
	@IsEmployedTypeID BIGINT = NULL,
---------------------------------------------------------------
	@EmployerName NVARCHAR(200) = NULL,
	@EmployedDateLastPresent DATETIME = NULL,
	@EmployerForeignAddressIndicator BIT = 0,
	@EmployerForeignAddressString NVARCHAR(200) = NULL,
	@EmployerGeoLocationID BIGINT = NULL,
	@EmployeridfsLocation BIGINT = NULL,
	@EmployerstrStreetName NVARCHAR(200) = NULL,
	@EmployerstrApartment NVARCHAR(200) = NULL,
	@EmployerstrBuilding NVARCHAR(200) = NULL,
	@EmployerstrHouse NVARCHAR(200) = NULL,
	@EmployeridfsPostalCode NVARCHAR(200) = NULL,
	@EmployerPhone NVARCHAR(100) = NULL,
---------------------------------------------------------------
	@IsStudentTypeID BIGINT = NULL,
	@SchoolName NVARCHAR(200) = NULL,
	@SchoolDateLastAttended DATETIME = NULL,
	@SchoolForeignAddressIndicator BIT = 0,
	@SchoolForeignAddressString NVARCHAR(200) = NULL,
	@SchoolGeoLocationID BIGINT = NULL,
	@SchoolidfsLocation BIGINT = NULL,
	@SchoolstrStreetName NVARCHAR(200) = NULL,
	@SchoolstrApartment NVARCHAR(200) = NULL,
	@SchoolstrBuilding NVARCHAR(200) = NULL,
	@SchoolstrHouse NVARCHAR(200) = NULL,
	@SchoolidfsPostalCode NVARCHAR(200) = NULL,
	@SchoolPhone NVARCHAR(100) = NULL,
---------------------------------------------------------------
	@HumanGeoLocationID BIGINT = NULL,
	@HumanidfsLocation BIGINT = NULL,
	@HumanstrStreetName NVARCHAR(200) = NULL,
	@HumanstrApartment NVARCHAR(200) = NULL,
	@HumanstrBuilding NVARCHAR(200) = NULL,
	@HumanstrHouse NVARCHAR(200) = NULL,
	@HumanidfsPostalCode NVARCHAR(200) = NULL,
	@HumanstrLatitude FLOAT = NULL,
	@HumanstrLongitude FLOAT = NULL,
	@HumanstrElevation FLOAT = NULL,
---------------------------------------------------------------
	@HumanPermGeoLocationID BIGINT = NULL,
	@HumanPermidfsLocation BIGINT = NULL,
	@HumanPermstrStreetName NVARCHAR(200) = NULL,
	@HumanPermstrApartment NVARCHAR(200) = NULL,
	@HumanPermstrBuilding NVARCHAR(200) = NULL,
	@HumanPermstrHouse NVARCHAR(200) = NULL,
	@HumanPermidfsPostalCode NVARCHAR(200) = NULL,
---------------------------------------------------------------
	@HumanAltGeoLocationID BIGINT = NULL,
	@HumanAltForeignAddressIndicator BIT = 0,
	@HumanAltForeignAddressString NVARCHAR(200) = NULL,
	@HumanAltidfsLocation BIGINT = NULL,
	@HumanAltstrStreetName NVARCHAR(200) = NULL,
	@HumanAltstrApartment NVARCHAR(200) = NULL,
	@HumanAltstrBuilding NVARCHAR(200) = NULL,
	@HumanAltstrHouse NVARCHAR(200) = NULL,
	@HumanAltidfsPostalCode NVARCHAR(200) = NULL,
---------------------------------------------------------------
	@RegistrationPhone NVARCHAR(200) = NULL,
	@HomePhone NVARCHAR(200) = NULL,
	@WorkPhone NVARCHAR(200) = NULL,
	@ContactPhoneCountryCode INT = NULL,
	@ContactPhone NVARCHAR(200) = NULL,
	@ContactPhoneTypeID BIGINT = NULL,
	@ContactPhone2CountryCode INT = NULL,
	@ContactPhone2 NVARCHAR(200) = NULL,
	@ContactPhone2TypeID BIGINT = NULL,
    @idfDataAuditEvent BIGINT = NULL,
	@AuditUser NVARCHAR(100) = '''',

	@IsAnotherPhoneTypeID BIGINT = NULL,
	@IsAnotherAddressTypeID BIGINT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@AuditUser = '''' OR @AuditUser IS NULL)
		SET @AuditUser = SUSER_NAME()

	DECLARE @ReturnCode INT = 0,
		@ReturnMessage NVARCHAR(MAX) = ''SUCCESS'', 
		@HumanID BIGINT = NULL;

	DECLARE @SupressSelect TABLE (
		ReturnCode INT,
		ReturnMessage NVARCHAR(MAX)
		);

	DECLARE @idfsLocation BIGINT
	DECLARE @AdminLevel INT

	--Data Audit--

		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017036; -- Need to review the value --
		DECLARE @idfObject bigint = @HumanMasterID;
		DECLARE @idfObjectTable_tlbHumanActual bigint = 4573200000000;
		DECLARE @idfObjectTable_HumanActualAddlInfo bigint = 52577590000000;
		--DECLARE @idfDataAuditEvent bigint = NULL;		

		DECLARE @tlbHumanActual_BeforeEdit TABLE
		(
			idfHumanActual bigint,
			idfsOccupationType bigint,
			idfsNationality bigint,
			idfsHumanGender bigint,
			idfCurrentResidenceAddress bigint,
			idfEmployerAddress bigint,
			idfRegistrationAddress bigint,
			datDateofBirth datetime,
			datDateOfDeath datetime,
			strLastName nvarchar(200),
			strSecondName nvarchar(200),
			strFirstName nvarchar(200),
			strRegistrationPhone nvarchar(200),
			strEmployerName nvarchar(200),
			strHomePhone nvarchar(200),
			strWorkPhone nvarchar(200),
			idfsPersonIDType bigint,
			strPersonID nvarchar(100),
			datEnteredDate datetime,
			datModificationDate datetime			
		)

		DECLARE @tlbHumanActual_AfterEdit TABLE
		(
			idfHumanActual bigint,
			idfsOccupationType bigint,
			idfsNationality bigint,
			idfsHumanGender bigint,
			idfCurrentResidenceAddress bigint,
			idfEmployerAddress bigint,
			idfRegistrationAddress bigint,
			datDateofBirth datetime,
			datDateOfDeath datetime,
			strLastName nvarchar(200),
			strSecondName nvarchar(200),
			strFirstName nvarchar(200),
			strRegistrationPhone nvarchar(200),
			strEmployerName nvarchar(200),
			strHomePhone nvarchar(200),
			strWorkPhone nvarchar(200),
			idfsPersonIDType bigint,
			strPersonID nvarchar(100),
			datEnteredDate datetime,
			datModificationDate datetime			
		)

		DECLARE @HumanActualAddlInfo_BeforeEdit TABLE
		(
			HumanActualAddlInfoUID bigint,
			ReportedAge int,
			ReportedAgeUOMID bigint,
			PassportNbr nvarchar(20),
			IsEmployedID bigint,
			EmployerPhoneNbr nvarchar(200),
			EmployedDTM datetime,
			IsStudentID bigint,
			SchoolName nvarchar(200),
			SchoolPhoneNbr nvarchar(200),
			SchoolAddressID bigint,
			SchoolLastAttendDTM datetime,
			ContactPhoneCountryCode int,
			ContactPhoneNbr nvarchar(200),
			ContactPhoneNbrTypeID bigint,
			ContactPhone2CountryCode int,
			ContactPhone2Nbr nvarchar(200),
			ContactPhone2NbrTypeID bigint,
			AltAddressID bigint,
			IsAnotherPhoneID bigint,
			IsAnotherAddressID bigint
		)

		DECLARE @HumanActualAddlInfo_AfterEdit TABLE
		(
			HumanActualAddlInfoUID bigint,
			ReportedAge int,
			ReportedAgeUOMID bigint,
			PassportNbr nvarchar(20),
			IsEmployedID bigint,
			EmployerPhoneNbr nvarchar(200),
			EmployedDTM datetime,
			IsStudentID bigint,
			SchoolName nvarchar(200),
			SchoolPhoneNbr nvarchar(200),
			SchoolAddressID bigint,
			SchoolLastAttendDTM datetime,
			ContactPhoneCountryCode int,
			ContactPhoneNbr nvarchar(200),
			ContactPhoneNbrTypeID bigint,
			ContactPhone2CountryCode int,
			ContactPhone2Nbr nvarchar(200),
			ContactPhone2NbrTypeID bigint,
			AltAddressID bigint,
			IsAnotherPhoneID bigint,
			IsAnotherAddressID bigint
		)

	--Data Audit--

	--Data Audit--
		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo
	--Data Audit--

	BEGIN TRY

		BEGIN TRANSACTION;		
	
		IF NOT EXISTS (
				SELECT *
				FROM dbo.tlbHumanActual
				WHERE idfHumanActual = @HumanMasterID
					AND intRowStatus = 0
				)
		BEGIN

			INSERT INTO @SupressSelect
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				@tableName = N''tlbHumanActual'',
				@idfsKey = @HumanMasterID OUTPUT;

			--Data Audit--
        	IF  @idfDataAuditEvent IS NULL
        	BEGIN 
				-- tauDataAuditEvent Event Type - Create 
				set @idfsDataAuditEventType = 10016001;
			
				-- insert record into tauDataAuditEvent - 
				INSERT INTO @SupressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @HumanMasterID, @idfObjectTable_tlbHumanActual, @idfDataAuditEvent OUTPUT
            END
			--Data Audit--

			-- Set Employer Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @EmployeridfsLocation
			
			IF (@AdminLevel > 2)
				OR @EmployerForeignAddressIndicator = 1

				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @EmployerGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @EmployeridfsLocation,
					@Apartment = @EmployerstrApartment,
					@Building = @EmployerstrBuilding,
					@StreetName = @EmployerstrStreetName,
					@House = @EmployerstrHouse,
					@PostalCodeString = @EmployeridfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = @EmployerForeignAddressIndicator,
					@ForeignAddressString = @EmployerForeignAddressString,
					@GeolocationSharedIndicator = 1,
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set School Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @SchoolidfsLocation
		
			IF (@AdminLevel > 2)
				OR @SchoolForeignAddressIndicator = 1

				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @SchoolGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @SchoolidfsLocation,
					@Apartment = @SchoolstrApartment,
					@Building = @SchoolstrBuilding,
					@StreetName = @SchoolstrStreetName,
					@House = @SchoolstrHouse,
					@PostalCodeString = @SchoolidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = @SchoolForeignAddressIndicator,
					@ForeignAddressString = @SchoolForeignAddressString,
					@GeolocationSharedIndicator = 1,
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set Current Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @HumanidfsLocation
		
			IF (@AdminLevel > 2)
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @HumanGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @HumanidfsLocation,
					@Apartment = @HumanstrApartment,
					@Building = @HumanstrBuilding,
					@StreetName = @HumanstrStreetName,
					@House = @HumanstrHouse,
					@PostalCodeString = @HumanidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = @HumanstrLatitude,
					@Longitude = @HumanstrLongitude,
					@Elevation = @HumanstrElevation,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = 0,
					@ForeignAddressString = NULL,
					@GeolocationSharedIndicator = 1, 
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set Permanent Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @HumanPermidfsLocation
		
			IF (@AdminLevel > 2)
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @HumanPermGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @HumanPermidfsLocation,
					@Apartment =@HumanPermstrApartment,
					@Building =@HumanPermstrBuilding,
					@StreetName =@HumanPermstrStreetName,
					@House =@HumanPermstrHouse,
					@PostalCodeString =@HumanPermidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = 0,
					@ForeignAddressString = NULL,
					@GeolocationSharedIndicator = 1, 
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set Alternate Address
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @HumanAltidfsLocation
		
			IF (@AdminLevel > 2) OR @HumanAltForeignAddressIndicator = 1
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING
					@GeolocationID = @HumanAltGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @HumanAltidfsLocation,
					@Apartment = @HumanAltstrApartment,
					@Building = @HumanAltstrBuilding,
					@StreetName = @HumanAltstrStreetName,
					@House = @HumanAltstrHouse,
					@PostalCodeString = @HumanAltidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = @HumanAltForeignAddressIndicator,
					@ForeignAddressString = @HumanAltForeignAddressString,
					@GeolocationSharedIndicator = 1, 
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

				INSERT INTO dbo.tlbHumanActual (
					idfHumanActual,
					idfsNationality,
					idfsHumanGender,
					idfCurrentResidenceAddress,
					idfsOccupationType,
					idfEmployerAddress,
					idfRegistrationAddress,
					datDateofBirth,
					datDateOfDeath,
					strFirstName,
					strSecondName,
					strLastName,
					strRegistrationPhone,
					strEmployerName,
					strHomePhone,
					strWorkPhone,
					idfsPersonIDType,
					strPersonID,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser,
					AuditCreateDTM,
					AuditUpdateUser,
					AuditUpdateDTM
					)
				VALUES (
					@HumanMasterID,
					@CitizenshipTypeID,
					@HumanGenderTypeID,
					@HumanGeoLocationID,
					@OccupationTypeID,
					@EmployerGeoLocationID,
					@HumanPermGeoLocationID,
					@DateOfBirth,
					@DateOfDeath,
					@FirstName,
					@SecondName,
					@LastName,
					@RegistrationPhone,
					@EmployerName,
					@HomePhone,
					@WorkPhone,
					@PersonalIDType,
					@PersonalID,
					0,
					10519001,
					''[{"idfHumanActual":'' + CAST(@HumanMasterID AS NVARCHAR(300)) + ''}]'',
					@AuditUser,
					GETDATE(),
					@AuditUser,
					GETDATE()
					);

			--Data Audit--							

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_tlbHumanActual, @HumanMasterID)
			
			--Data Audit--

			INSERT INTO @SupressSelect
			EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N''EIDSS Person'',
				@NextNumberValue = @EIDSSPersonID OUTPUT,
				@InstallationSite = NULL;

			INSERT INTO dbo.HumanActualAddlInfo (
				HumanActualAddlInfoUID,
				EIDSSPersonID,
				ReportedAge,
				ReportedAgeUOMID,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
				SchoolName,
				SchoolPhoneNbr,
				SchoolAddressID,
				SchoolLastAttendDTM,
				ContactPhoneCountryCode,
				ContactPhoneNbr,
				ContactPhoneNbrTypeID,
				ContactPhone2CountryCode,
				ContactPhone2Nbr,
				ContactPhone2NbrTypeID,
				AltAddressID,
				intRowStatus,
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateUser,
				AuditCreateDTM,
				AuditUpdateUser,
				AuditUpdateDTM,
				IsAnotherPhoneID,
				IsAnotherAddressID
				)
			VALUES (
				@HumanMasterID,
				@EIDSSPersonID,
				NULL,
				NULL,
				@PassportNumber,
				@IsEmployedTypeID,
				@EmployerPhone,
				@EmployedDateLastPresent,
				@IsStudentTypeID,
				@SchoolName,
				@SchoolPhone,
				@SchoolGeoLocationID,
				@SchoolDateLastAttended,
				@ContactPhoneCountryCode,
				@ContactPhone,
				@ContactPhoneTypeID,
				@ContactPhone2CountryCode,
				@ContactPhone2,
				@ContactPhone2TypeID,
				@HumanAltGeoLocationID,
				0,
				10519001,
				''[{"HumanActualAddlInfoUID":'' + CAST(@HumanMasterID AS NVARCHAR(300)) + ''}]'',
				@AuditUser,
				GETDATE(),
				@AuditUser,
				GETDATE(),
				@IsAnotherPhoneTypeID,
				@IsAnotherAddressTypeID
				);

			--Data Audit--			
				-- tauDataAuditEvent Event Type - Create 									
				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_HumanActualAddlInfo, @HumanMasterID)			
			--Data Audit--

			-- Create a human record from human actual for the laboratory module; register new sample.
			IF @CopyToHumanIndicator = 1
				BEGIN
					INSERT INTO @SupressSelect
					EXECUTE dbo.USP_HUM_COPYHUMANACTUALTOHUMAN @HumanMasterID, @HumanID OUTPUT, @ReturnCode OUTPUT, @ReturnMessage OUTPUT;
					IF @ReturnCode <> 0 
						BEGIN
							RETURN;
						END;
				END;
		END;
		ELSE
		BEGIN

			--DataAudit-- 
        	IF  @idfDataAuditEvent IS NULL
        	BEGIN 				
				--  tauDataAuditEvent  Event Type - Edit 
				set @idfsDataAuditEventType = 10016003;
			
				-- insert record into tauDataAuditEvent - 
				INSERT INTO @SupressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_tlbHumanActual, @idfDataAuditEvent OUTPUT
            END
			--DataAudit-- 

			-- Set Employer Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @EmployeridfsLocation
			
			IF (@AdminLevel > 2)
				OR @EmployerForeignAddressIndicator = 1

				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @EmployerGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @EmployeridfsLocation,
					@Apartment = @EmployerstrApartment,
					@Building = @EmployerstrBuilding,
					@StreetName = @EmployerstrStreetName,
					@House = @EmployerstrHouse,
					@PostalCodeString = @EmployeridfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = @EmployerForeignAddressIndicator,
					@ForeignAddressString = @EmployerForeignAddressString,
					@GeolocationSharedIndicator = 1,
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set School Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @SchoolidfsLocation
		
			IF (@AdminLevel > 2)
				OR @SchoolForeignAddressIndicator = 1

				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @SchoolGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @SchoolidfsLocation,
					@Apartment = @SchoolstrApartment,
					@Building = @SchoolstrBuilding,
					@StreetName = @SchoolstrStreetName,
					@House = @SchoolstrHouse,
					@PostalCodeString = @SchoolidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = @SchoolForeignAddressIndicator,
					@ForeignAddressString = @SchoolForeignAddressString,
					@GeolocationSharedIndicator = 1,
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set Current Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @HumanidfsLocation
		
			IF (@AdminLevel > 2)
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @HumanGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @HumanidfsLocation,
					@Apartment = @HumanstrApartment,
					@Building = @HumanstrBuilding,
					@StreetName = @HumanstrStreetName,
					@House = @HumanstrHouse,
					@PostalCodeString = @HumanidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = @HumanstrLatitude,
					@Longitude = @HumanstrLongitude,
					@Elevation = @HumanstrElevation,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = 0,
					@ForeignAddressString = NULL,
					@GeolocationSharedIndicator = 1, 
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set Permanent Address 
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @HumanPermidfsLocation
		
			IF (@AdminLevel > 2)
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING 
					@GeolocationID = @HumanPermGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @HumanPermidfsLocation,
					@Apartment =@HumanPermstrApartment,
					@Building =@HumanPermstrBuilding,
					@StreetName =@HumanPermstrStreetName,
					@House =@HumanPermstrHouse,
					@PostalCodeString =@HumanPermidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = 0,
					@ForeignAddressString = NULL,
					@GeolocationSharedIndicator = 1, 
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			-- Set Alternate Address
			SET @AdminLevel = 0
			SELECT @AdminLevel = node.GetLevel() FROM dbo.gisLocation WHERE idfsLocation = @HumanAltidfsLocation
		
			IF (@AdminLevel > 2) OR @HumanAltForeignAddressIndicator = 1
				INSERT INTO @SupressSelect
				EXECUTE dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING
					@GeolocationID = @HumanAltGeoLocationID OUTPUT,
					@DataAuditEventID = @idfDataAuditEvent,
					@ResidentTypeID = NULL,
					@GroundTypeID = NULL,
					@GeolocationTypeID = NULL,
					@LocationID = @HumanAltidfsLocation,
					@Apartment = @HumanAltstrApartment,
					@Building = @HumanAltstrBuilding,
					@StreetName = @HumanAltstrStreetName,
					@House = @HumanAltstrHouse,
					@PostalCodeString = @HumanAltidfsPostalCode,
					@DescriptionString = NULL,
					@Distance = NULL,
					@Latitude = NULL,
					@Longitude = NULL,
					@Elevation = NULL,
					@Accuracy = NULL,
					@Alignment = NULL,
					@ForeignAddressIndicator = @HumanAltForeignAddressIndicator,
					@ForeignAddressString = @HumanAltForeignAddressString,
					@GeolocationSharedIndicator = 1, 
					@AuditUserName = @AuditUser,
					@ReturnCode = @ReturnCode OUTPUT,
					@ReturnMessage = @ReturnMessage OUTPUT;

			INSERT INTO @tlbHumanActual_BeforeEdit (
				idfHumanActual, 
				idfsOccupationType, 
				idfsNationality, 
				idfsHumanGender, 
				idfCurrentResidenceAddress, 
				idfEmployerAddress, 
				idfRegistrationAddress, 
				datDateofBirth, 
				datDateOfDeath, 
				strLastName, 
				strSecondName, 
				strFirstName,
				strRegistrationPhone,
				strEmployerName,
				strHomePhone,
				strWorkPhone,
				idfsPersonIDType,
				strPersonID,
				datEnteredDate,
				datModificationDate)
			SELECT 
				idfHumanActual, 
				idfsOccupationType, 
				idfsNationality, 
				idfsHumanGender, 
				idfCurrentResidenceAddress, 
				idfEmployerAddress, 
				idfRegistrationAddress, 
				datDateofBirth, 
				datDateOfDeath, 
				strLastName, 
				strSecondName, 
				strFirstName,
				strRegistrationPhone,
				strEmployerName,
				strHomePhone,
				strWorkPhone,
				idfsPersonIDType,
				strPersonID,
				datEnteredDate,
				datModificationDate
				FROM tlbHumanActual WHERE idfHumanActual = @HumanMasterID;

			UPDATE dbo.tlbHumanActual
			SET idfsNationality = @CitizenshipTypeID,
				idfsHumanGender = @HumanGenderTypeID,
				idfCurrentResidenceAddress = @HumanGeoLocationID,
				idfsOccupationType = @OccupationTypeID,
				idfEmployerAddress = @EmployerGeoLocationID,
				idfRegistrationAddress = @HumanPermGeoLocationID,
				datDateofBirth = @DateOfBirth,
				datDateOfDeath = @DateOfDeath,
				strFirstName = @FirstName,
				strSecondName = @SecondName,
				strLastName = @LastName,
				strRegistrationPhone = @RegistrationPhone,
				strEmployerName = @EmployerName,
				strHomePhone = @HomePhone,
				strWorkPhone = @WorkPhone,
				idfsPersonIDType = @PersonalIDType,
				strPersonID = @PersonalID,
				datModificationDate = GETDATE(),
				SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
				SourceSystemKeyValue = ISNULL(SourceSystemKeyValue, ''[{"idfHumanActual":'' + CAST(@HumanMasterID AS NVARCHAR(300)) + ''}]''),
				AuditCreateUser = @AuditUser,
				AuditCreateDTM = GETDATE(),
				AuditUpdateUser = @AuditUser,
				AuditUpdateDTM = GETDATE()
			WHERE idfHumanActual = @HumanMasterID;

			INSERT INTO @tlbHumanActual_AfterEdit (
				idfHumanActual, 
				idfsOccupationType, 
				idfsNationality, 
				idfsHumanGender, 
				idfCurrentResidenceAddress, 
				idfEmployerAddress, 
				idfRegistrationAddress, 
				datDateofBirth, 
				datDateOfDeath, 
				strLastName, 
				strSecondName, 
				strFirstName,
				strRegistrationPhone,
				strEmployerName,
				strHomePhone,
				strWorkPhone,
				idfsPersonIDType,
				strPersonID,
				datEnteredDate,
				datModificationDate)
			SELECT 
				idfHumanActual, 
				idfsOccupationType, 
				idfsNationality, 
				idfsHumanGender, 
				idfCurrentResidenceAddress, 
				idfEmployerAddress, 
				idfRegistrationAddress, 
				datDateofBirth, 
				datDateOfDeath, 
				strLastName, 
				strSecondName, 
				strFirstName,
				strRegistrationPhone,
				strEmployerName,
				strHomePhone,
				strWorkPhone,
				idfsPersonIDType,
				strPersonID,
				datEnteredDate,
				datModificationDate
				FROM tlbHumanActual WHERE idfHumanActual = @HumanMasterID;
						
				--idfsOccupationType
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573220000000,
					a.idfHumanActual,
					null,
					a.idfsOccupationType,
					b.idfsOccupationType 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfsOccupationType <> b.idfsOccupationType) 
					or(a.idfsOccupationType is not null and b.idfsOccupationType is null)
					or(a.idfsOccupationType is null and b.idfsOccupationType is not null)

				--idfsNationality
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573230000000,
					a.idfHumanActual,
					null,
					a.idfsNationality,
					b.idfsNationality 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfsNationality <> b.idfsNationality) 
					or(a.idfsNationality is not null and b.idfsNationality is null)
					or(a.idfsNationality is null and b.idfsNationality is not null)

				--idfsHumanGender
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573240000000,
					a.idfHumanActual,
					null,
					a.idfsHumanGender,
					b.idfsHumanGender 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfsHumanGender <> b.idfsHumanGender) 
					or(a.idfsHumanGender is not null and b.idfsHumanGender is null)
					or(a.idfsHumanGender is null and b.idfsHumanGender is not null)

				--idfCurrentResidenceAddress
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573250000000,
					a.idfHumanActual,
					null,
					a.idfCurrentResidenceAddress,
					b.idfCurrentResidenceAddress 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfCurrentResidenceAddress <> b.idfCurrentResidenceAddress) 
					or(a.idfCurrentResidenceAddress is not null and b.idfCurrentResidenceAddress is null)
					or(a.idfCurrentResidenceAddress is null and b.idfCurrentResidenceAddress is not null)

				--idfEmployerAddress
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573260000000,
					a.idfHumanActual,
					null,
					a.idfEmployerAddress,
					b.idfEmployerAddress 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfEmployerAddress <> b.idfEmployerAddress) 
					or(a.idfEmployerAddress is not null and b.idfEmployerAddress is null)
					or(a.idfEmployerAddress is null and b.idfEmployerAddress is not null)

				--idfRegistrationAddress
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573270000000,
					a.idfHumanActual,
					null,
					a.idfRegistrationAddress,
					b.idfRegistrationAddress 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfRegistrationAddress <> b.idfRegistrationAddress) 
					or(a.idfRegistrationAddress is not null and b.idfRegistrationAddress is null)
					or(a.idfRegistrationAddress is null and b.idfRegistrationAddress is not null)

				--datDateofBirth
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573280000000,
					a.idfHumanActual,
					null,
					a.datDateofBirth,
					b.datDateofBirth 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.datDateofBirth <> b.datDateofBirth) 
					or(a.datDateofBirth is not null and b.datDateofBirth is null)
					or(a.datDateofBirth is null and b.datDateofBirth is not null)

				--datDateOfDeath
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573290000000,
					a.idfHumanActual,
					null,
					a.datDateOfDeath,
					b.datDateOfDeath 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.datDateOfDeath <> b.datDateOfDeath) 
					or(a.datDateOfDeath is not null and b.datDateOfDeath is null)
					or(a.datDateOfDeath is null and b.datDateOfDeath is not null)

				--strLastName
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573300000000,
					a.idfHumanActual,
					null,
					a.strLastName,
					b.strLastName 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strLastName <> b.strLastName) 
					or(a.strLastName is not null and b.strLastName is null)
					or(a.strLastName is null and b.strLastName is not null)

				--strSecondName
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573310000000,
					a.idfHumanActual,
					null,
					a.strSecondName,
					b.strSecondName 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strSecondName <> b.strSecondName) 
					or(a.strSecondName is not null and b.strSecondName is null)
					or(a.strSecondName is null and b.strSecondName is not null)

				--strFirstName
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573320000000,
					a.idfHumanActual,
					null,
					a.strFirstName,
					b.strFirstName 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strFirstName <> b.strFirstName) 
					or(a.strFirstName is not null and b.strFirstName is null)
					or(a.strFirstName is null and b.strFirstName is not null)

				--strRegistrationPhone
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573330000000,
					a.idfHumanActual,
					null,
					a.strRegistrationPhone,
					b.strRegistrationPhone 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strRegistrationPhone <> b.strRegistrationPhone) 
					or(a.strRegistrationPhone is not null and b.strRegistrationPhone is null)
					or(a.strRegistrationPhone is null and b.strRegistrationPhone is not null)

				--strEmployerName
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573340000000,
					a.idfHumanActual,
					null,
					a.strEmployerName,
					b.strEmployerName 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strEmployerName <> b.strEmployerName) 
					or(a.strEmployerName is not null and b.strEmployerName is null)
					or(a.strEmployerName is null and b.strEmployerName is not null)

				--strHomePhone
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573350000000,
					a.idfHumanActual,
					null,
					a.strHomePhone,
					b.strHomePhone 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strHomePhone <> b.strHomePhone) 
					or(a.strHomePhone is not null and b.strHomePhone is null)
					or(a.strHomePhone is null and b.strHomePhone is not null)

				--strWorkPhone
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					4573360000000,
					a.idfHumanActual,
					null,
					a.strWorkPhone,
					b.strWorkPhone 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strWorkPhone <> b.strWorkPhone) 
					or(a.strWorkPhone is not null and b.strWorkPhone is null)
					or(a.strWorkPhone is null and b.strWorkPhone is not null)

				--idfsPersonIDType
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					12527780000000,
					a.idfHumanActual,
					null,
					a.idfsPersonIDType,
					b.idfsPersonIDType 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.idfsPersonIDType <> b.idfsPersonIDType) 
					or(a.idfsPersonIDType is not null and b.idfsPersonIDType is null)
					or(a.idfsPersonIDType is null and b.idfsPersonIDType is not null)

				--strPersonID
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					12527790000000,
					a.idfHumanActual,
					null,
					a.strPersonID,
					b.strPersonID 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.strPersonID <> b.strPersonID) 
					or(a.strPersonID is not null and b.strPersonID is null)
					or(a.strPersonID is null and b.strPersonID is not null)

				--datEnteredDate
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					51389550000000,
					a.idfHumanActual,
					null,
					a.datEnteredDate,
					b.datEnteredDate 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.datEnteredDate <> b.datEnteredDate) 
					or(a.datEnteredDate is not null and b.datEnteredDate is null)
					or(a.datEnteredDate is null and b.datEnteredDate is not null)

				--datModificationDate
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, 
					idfObjectTable, 
					idfColumn, 
					idfObject, 
					idfObjectDetail, 
					strOldValue, 
					strNewValue)
				select 
					@idfDataAuditEvent,
					@idfObjectTable_tlbHumanActual, 
					51389560000000,
					a.idfHumanActual,
					null,
					a.datModificationDate,
					b.datModificationDate 
				from @tlbHumanActual_BeforeEdit a  inner join @tlbHumanActual_AfterEdit b on a.idfHumanActual = b.idfHumanActual
				where (a.datModificationDate <> b.datModificationDate) 
					or(a.datModificationDate is not null and b.datModificationDate is null)
					or(a.datModificationDate is null and b.datModificationDate is not null)

			--DataAudit-- 

			INSERT INTO @HumanActualAddlInfo_BeforeEdit (
				HumanActualAddlInfoUID,
				ReportedAge, 
				ReportedAgeUOMID,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
				SchoolName,
				SchoolPhoneNbr,
				SchoolAddressID,
				SchoolLastAttendDTM,
				ContactPhoneCountryCode,
				ContactPhoneNbr,
				ContactPhoneNbrTypeID,
				ContactPhone2CountryCode,
				ContactPhone2Nbr,
				ContactPhone2NbrTypeID,
				AltAddressID,
				IsAnotherPhoneID,
				IsAnotherAddressID)			
			SELECT 
				HumanActualAddlInfoUID,
				ReportedAge, 
				ReportedAgeUOMID,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
				SchoolName,
				SchoolPhoneNbr,
				SchoolAddressID,
				SchoolLastAttendDTM,
				ContactPhoneCountryCode,
				ContactPhoneNbr,
				ContactPhoneNbrTypeID,
				ContactPhone2CountryCode,
				ContactPhone2Nbr,
				ContactPhone2NbrTypeID,
				AltAddressID,
				IsAnotherPhoneID,
				IsAnotherAddressID
				FROM HumanActualAddlInfo WHERE HumanActualAddlInfoUID = @HumanMasterID;

			UPDATE dbo.HumanActualAddlInfo
			SET PassportNbr = @PassportNumber,
				IsEmployedID = @IsEmployedTypeID,
				EmployerPhoneNbr = @EmployerPhone,
				EmployedDTM = @EmployedDateLastPresent,
				IsStudentID = @IsStudentTypeID,
				SchoolName = @SchoolName,
				SchoolPhoneNbr = @SchoolPhone,
				SchoolAddressID = @SchoolGeoLocationID,
				SchoolLastAttendDTM = @SchoolDateLastAttended,
				ContactPhoneCountryCode = @ContactPhoneCountryCode,
				ContactPhoneNbr = @ContactPhone,
				ContactPhoneNbrTypeID = @ContactPhoneTypeID,
				ContactPhone2CountryCode = @ContactPhone2CountryCode,
				ContactPhone2Nbr = @ContactPhone2,
				ContactPhone2NbrTypeID = @ContactPhone2TypeID,
				AltAddressID = @HumanAltGeoLocationID,
				SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
				SourceSystemKeyValue = ISNULL(SourceSystemKeyValue, ''[{"HumanActualAddlInfoUID":'' + CAST(@HumanMasterID AS NVARCHAR(300)) + ''}]''),
				AuditCreateUser = @AuditUser,
				AuditCreateDTM = GETDATE(),
				AuditUpdateUser = @AuditUser,
				AuditUpdateDTM = GETDATE(),
				IsAnotherPhoneID = @IsAnotherPhoneTypeID,
				IsAnotherAddressID = @IsAnotherAddressTypeID
			WHERE HumanActualAddlInfoUID = @HumanMasterID;

			INSERT INTO @HumanActualAddlInfo_AfterEdit (
				HumanActualAddlInfoUID,
				ReportedAge, 
				ReportedAgeUOMID,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
				SchoolName,
				SchoolPhoneNbr,
				SchoolAddressID,
				SchoolLastAttendDTM,
				ContactPhoneCountryCode,
				ContactPhoneNbr,
				ContactPhoneNbrTypeID,
				ContactPhone2CountryCode,
				ContactPhone2Nbr,
				ContactPhone2NbrTypeID,
				AltAddressID,
				IsAnotherPhoneID,
				IsAnotherAddressID)
			SELECT 
				HumanActualAddlInfoUID,
				NULL, 
				NULL,
				PassportNbr,
				IsEmployedID,
				EmployerPhoneNbr,
				EmployedDTM,
				IsStudentID,
				SchoolName,
				SchoolPhoneNbr,
				SchoolAddressID,
				SchoolLastAttendDTM,
				ContactPhoneCountryCode,
				ContactPhoneNbr,
				ContactPhoneNbrTypeID,
				ContactPhone2CountryCode,
				ContactPhone2Nbr,
				ContactPhone2NbrTypeID,
				AltAddressID,
				IsAnotherPhoneID,
				IsAnotherAddressID
				FROM HumanActualAddlInfo WHERE HumanActualAddlInfoUID = @HumanMasterID;

			--DataAudit-- 
			--  tauDataAuditEvent  Event Type- Edit 
			--set @idfsDataAuditEventType = 10016003;
			
			-- insert record into tauDataAuditEvent - 
			--INSERT INTO @SupressSelect
			--EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_HumanActualAddlInfo, @idfDataAuditEvent OUTPUT

			--PassportNbr
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000003,
				a.HumanActualAddlInfoUID,
				null,
				a.PassportNbr,
				b.PassportNbr 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.PassportNbr <> b.PassportNbr) 
				or(a.PassportNbr is not null and b.PassportNbr is null)
				or(a.PassportNbr is null and b.PassportNbr is not null)

			--IsEmployedID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000004,
				a.HumanActualAddlInfoUID,
				null,
				a.IsEmployedID,
				b.IsEmployedID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.IsEmployedID <> b.IsEmployedID) 
				or(a.IsEmployedID is not null and b.IsEmployedID is null)
				or(a.IsEmployedID is null and b.IsEmployedID is not null)

			--EmployerPhoneNbr
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000005,
				a.HumanActualAddlInfoUID,
				null,
				a.EmployerPhoneNbr,
				b.EmployerPhoneNbr 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.EmployerPhoneNbr <> b.EmployerPhoneNbr) 
				or(a.EmployerPhoneNbr is not null and b.EmployerPhoneNbr is null)
				or(a.EmployerPhoneNbr is null and b.EmployerPhoneNbr is not null)

			--EmployedDTM
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000006,
				a.HumanActualAddlInfoUID,
				null,
				a.EmployedDTM,
				b.EmployedDTM 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.EmployedDTM <> b.EmployedDTM) 
				or(a.EmployedDTM is not null and b.EmployedDTM is null)
				or(a.EmployedDTM is null and b.EmployedDTM is not null)

			--IsStudentID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000007,
				a.HumanActualAddlInfoUID,
				null,
				a.IsStudentID,
				b.IsStudentID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.IsStudentID <> b.IsStudentID) 
				or(a.IsStudentID is not null and b.IsStudentID is null)
				or(a.IsStudentID is null and b.IsStudentID is not null)

			--SchoolName
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000008,
				a.HumanActualAddlInfoUID,
				null,
				a.SchoolName,
				b.SchoolName 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.SchoolName <> b.SchoolName) 
				or(a.SchoolName is not null and b.SchoolName is null)
				or(a.SchoolName is null and b.SchoolName is not null)
				
			--SchoolPhoneNbr
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000009,
				a.HumanActualAddlInfoUID,
				null,
				a.SchoolPhoneNbr,
				b.SchoolPhoneNbr 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.SchoolPhoneNbr <> b.SchoolPhoneNbr) 
				or(a.SchoolPhoneNbr is not null and b.SchoolPhoneNbr is null)
				or(a.SchoolPhoneNbr is null and b.SchoolPhoneNbr is not null)
								
			--SchoolAddressID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000010,
				a.HumanActualAddlInfoUID,
				null,
				a.SchoolAddressID,
				b.SchoolAddressID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.SchoolAddressID <> b.SchoolAddressID) 
				or(a.SchoolAddressID is not null and b.SchoolAddressID is null)
				or(a.SchoolAddressID is null and b.SchoolAddressID is not null)
												
			--SchoolLastAttendDTM
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000011,
				a.HumanActualAddlInfoUID,
				null,
				a.SchoolLastAttendDTM,
				b.SchoolLastAttendDTM 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.SchoolLastAttendDTM <> b.SchoolLastAttendDTM) 
				or(a.SchoolLastAttendDTM is not null and b.SchoolLastAttendDTM is null)
				or(a.SchoolLastAttendDTM is null and b.SchoolLastAttendDTM is not null)
																
			--ContactPhoneCountryCode
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000012,
				a.HumanActualAddlInfoUID,
				null,
				a.ContactPhoneCountryCode,
				b.ContactPhoneCountryCode 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.ContactPhoneCountryCode <> b.ContactPhoneCountryCode) 
				or(a.ContactPhoneCountryCode is not null and b.ContactPhoneCountryCode is null)
				or(a.ContactPhoneCountryCode is null and b.ContactPhoneCountryCode is not null)

			--ContactPhoneNbr
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000013,
				a.HumanActualAddlInfoUID,
				null,
				a.ContactPhoneNbr,
				b.ContactPhoneNbr 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.ContactPhoneNbr <> b.ContactPhoneNbr) 
				or(a.ContactPhoneNbr is not null and b.ContactPhoneNbr is null)
				or(a.ContactPhoneNbr is null and b.ContactPhoneNbr is not null)

			--ContactPhoneNbrTypeID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000014,
				a.HumanActualAddlInfoUID,
				null,
				a.ContactPhoneNbrTypeID,
				b.ContactPhoneNbrTypeID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.ContactPhoneNbrTypeID <> b.ContactPhoneNbrTypeID) 
				or(a.ContactPhoneNbrTypeID is not null and b.ContactPhoneNbrTypeID is null)
				or(a.ContactPhoneNbrTypeID is null and b.ContactPhoneNbrTypeID is not null)

			--ContactPhone2CountryCode
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000015,
				a.HumanActualAddlInfoUID,
				null,
				a.ContactPhone2CountryCode,
				b.ContactPhone2CountryCode 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.ContactPhone2CountryCode <> b.ContactPhone2CountryCode) 
				or(a.ContactPhone2CountryCode is not null and b.ContactPhone2CountryCode is null)
				or(a.ContactPhone2CountryCode is null and b.ContactPhone2CountryCode is not null)
				
			--ContactPhone2Nbr
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000016,
				a.HumanActualAddlInfoUID,
				null,
				a.ContactPhone2Nbr,
				b.ContactPhone2Nbr 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.ContactPhone2Nbr <> b.ContactPhone2Nbr) 
				or(a.ContactPhone2Nbr is not null and b.ContactPhone2Nbr is null)
				or(a.ContactPhone2Nbr is null and b.ContactPhone2Nbr is not null)

			--ContactPhone2NbrTypeID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000017,
				a.HumanActualAddlInfoUID,
				null,
				a.ContactPhone2NbrTypeID,
				b.ContactPhone2NbrTypeID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.ContactPhone2NbrTypeID <> b.ContactPhone2NbrTypeID) 
				or(a.ContactPhone2NbrTypeID is not null and b.ContactPhone2NbrTypeID is null)
				or(a.ContactPhone2NbrTypeID is null and b.ContactPhone2NbrTypeID is not null)

			--AltAddressID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586590000018,
				a.HumanActualAddlInfoUID,
				null,
				a.AltAddressID,
				b.AltAddressID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.AltAddressID <> b.AltAddressID) 
				or(a.AltAddressID is not null and b.AltAddressID is null)
				or(a.AltAddressID is null and b.AltAddressID is not null)

			--IsAnotherPhoneID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586990000124,
				a.HumanActualAddlInfoUID,
				null,
				a.IsAnotherPhoneID,
				b.IsAnotherPhoneID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.IsAnotherPhoneID <> b.IsAnotherPhoneID) 
				or(a.IsAnotherPhoneID is not null and b.IsAnotherPhoneID is null)
				or(a.IsAnotherPhoneID is null and b.IsAnotherPhoneID is not null)

			--IsAnotherAddressID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_HumanActualAddlInfo, 
				51586990000125,
				a.HumanActualAddlInfoUID,
				null,
				a.IsAnotherAddressID,
				b.IsAnotherAddressID 
			from @HumanActualAddlInfo_BeforeEdit a inner join @HumanActualAddlInfo_AfterEdit b on a.HumanActualAddlInfoUID = b.HumanActualAddlInfoUID
			where (a.IsAnotherAddressID <> b.IsAnotherAddressID) 
				or(a.IsAnotherAddressID is not null and b.IsAnotherAddressID is null)
				or(a.IsAnotherAddressID is null and b.IsAnotherAddressID is not null)

		END;		

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@HumanMasterID HumanMasterID,
			@EIDSSPersonID EIDSSPersonID, 
			@HumanID HumanID;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();
		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@HumanMasterID HumanMasterID,
			@EIDSSPersonID EIDSSPersonID, 
			@HumanID HumanID;

		THROW;
	END CATCH;
END;
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
