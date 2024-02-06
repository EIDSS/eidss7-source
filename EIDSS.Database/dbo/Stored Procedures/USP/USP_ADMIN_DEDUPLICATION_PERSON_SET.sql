

-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_PERSON_SET
--
-- Description:	Deduplication for Person Master record.
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		04/14/2022  initial version
-- Ann Xiong		03/15/2023	Implemented Data Audit and fixed a few issues
-- Ann Xiong		03/17/2023	Fixed an issue for Data Audit After UPDATE dbo.tlbHuman

-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_PERSON_SET]
(
	@HumanMasterID BIGINT = NULL,
	@SupersededHumanMasterID BIGINT,
	@CopyToHumanIndicator BIT = 0, 
	@PersonalIDType BIGINT = NULL,
	@EIDSSPersonID NVARCHAR(200) = NULL,
	@PersonalID NVARCHAR(100) = NULL,
	@FirstName NVARCHAR(200) = NULL,
	@SecondName NVARCHAR(200) = NULL,
	@LastName NVARCHAR(200),
	@DateOfBirth DATETIME = NULL,
	@DateOfDeath DATETIME = NULL,
	@ReportedAge INT = NULL,
	@ReportAgeUOMID BIGINT = NULL,
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
	@AuditUser NVARCHAR(100) = ''
)
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @ReturnCode INT = 0;
		DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
		DECLARE @HumanID BIGINT = NULL;

		--Data Audit--
		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017082; 					-- Person Deduplication --
		DECLARE @idfObject bigint = @HumanMasterID;
		DECLARE @idfObjectTable_tlbHumanActual bigint = 4573200000000;
		DECLARE @idfObjectTable_tlbHuman bigint = 75600000000;
		DECLARE @idfDataAuditEvent bigint = NULL;	

		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo

		--  tauDataAuditEvent  Event Type- Edit 
		set @idfsDataAuditEventType =10016003;
		-- insert record into tauDataAuditEvent - 
		EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@HumanMasterID, @idfObjectTable_tlbHumanActual, @idfDataAuditEvent OUTPUT
		--Data Audit--

		EXEC dbo.USP_HUM_HUMAN_MASTER_SET 
			@HumanMasterID = @HumanMasterID,
		    @CopyToHumanIndicator = @CopyToHumanIndicator,
		    @PersonalIDType = @PersonalIDType,
		    @EIDSSPersonID = @EIDSSPersonID,
		    @PersonalID = @PersonalID,
		    @FirstName = @FirstName,
		    @SecondName = @SecondName,
		    @LastName = @LastName,
		    @DateOfBirth = @DateOfBirth,
		    @DateOfDeath = @DateOfDeath,
		    @ReportedAge = @ReportedAge,
		    @ReportAgeUOMID = @ReportAgeUOMID,
		    @HumanGenderTypeID = @HumanGenderTypeID,
		    @OccupationTypeID = @OccupationTypeID,
		    @CitizenshipTypeID = @CitizenshipTypeID,
		    @PassportNumber = @PassportNumber,
		    @IsEmployedTypeID = @IsEmployedTypeID,
		    @EmployerName = @EmployerName,
		    @EmployedDateLastPresent = @EmployedDateLastPresent,
		    @EmployerForeignAddressIndicator = @EmployerForeignAddressIndicator,
		    @EmployerForeignAddressString = @EmployerForeignAddressString,
		    @EmployerGeoLocationID = @EmployerGeoLocationID,
		    @EmployeridfsLocation = @EmployeridfsLocation,
		    @EmployerstrStreetName = @EmployerstrStreetName,
		    @EmployerstrApartment = @EmployerstrApartment,
		    @EmployerstrBuilding = @EmployerstrBuilding,
		    @EmployerstrHouse = @EmployerstrHouse,
		    @EmployeridfsPostalCode = @EmployeridfsPostalCode,
		    @EmployerPhone = @EmployerPhone,
		    @IsStudentTypeID = @IsStudentTypeID,
		    @SchoolName = @SchoolName,
		    @SchoolDateLastAttended = @SchoolDateLastAttended,
		    @SchoolForeignAddressIndicator = @SchoolForeignAddressIndicator,
		    @SchoolForeignAddressString = @SchoolForeignAddressString,
		    @SchoolGeoLocationID = @SchoolGeoLocationID,
		    @SchoolidfsLocation = @SchoolidfsLocation,
		    @SchoolstrStreetName = @SchoolstrStreetName,
		    @SchoolstrApartment = @SchoolstrApartment,
		    @SchoolstrBuilding = @SchoolstrBuilding,
		    @SchoolstrHouse = @SchoolstrHouse,
		    @SchoolidfsPostalCode = @SchoolidfsPostalCode,
		    @SchoolPhone = @SchoolPhone,
		    @HumanGeoLocationID = @HumanGeoLocationID,
		    @HumanidfsLocation = @HumanidfsLocation,
		    @HumanstrStreetName = @HumanstrStreetName,
		    @HumanstrApartment = @HumanstrApartment,
		    @HumanstrBuilding = @HumanstrBuilding,
		    @HumanstrHouse = @HumanstrHouse,
		    @HumanidfsPostalCode = @HumanidfsPostalCode,
		    @HumanstrLatitude = @HumanstrLatitude,
		    @HumanstrLongitude = @HumanstrLongitude,
		    @HumanstrElevation = @HumanstrElevation,
		    @HumanPermGeoLocationID = @HumanPermGeoLocationID,
		    @HumanPermidfsLocation = @HumanPermidfsLocation,
		    @HumanPermstrStreetName = @HumanPermstrStreetName,
		    @HumanPermstrApartment = @HumanPermstrApartment,
		    @HumanPermstrBuilding = @HumanPermstrBuilding,
		    @HumanPermstrHouse = @HumanPermstrHouse,
		    @HumanPermidfsPostalCode = @HumanPermidfsPostalCode,
		    @HumanAltGeoLocationID = @HumanAltGeoLocationID,
		    @HumanAltForeignAddressIndicator = @HumanAltForeignAddressIndicator,
		    @HumanAltForeignAddressString = @HumanAltForeignAddressString,
		    @HumanAltidfsLocation = @HumanAltidfsLocation,
		    @HumanAltstrStreetName = @HumanAltstrStreetName,
		    @HumanAltstrApartment = @HumanAltstrApartment,
		    @HumanAltstrBuilding = @HumanAltstrBuilding,
		    @HumanAltstrHouse = @HumanAltstrHouse,
		    @HumanAltidfsPostalCode = @HumanAltidfsPostalCode,
		    @RegistrationPhone = @RegistrationPhone,
		    @HomePhone = @HomePhone,
		    @WorkPhone =@WorkPhone,
		    @ContactPhoneCountryCode = @ContactPhoneCountryCode,
		    @ContactPhone = @ContactPhone,
		    @ContactPhoneTypeID = @ContactPhoneTypeID,
		    @ContactPhone2CountryCode = @ContactPhone2CountryCode,
		    @ContactPhone2 = @ContactPhone2,
		    @ContactPhone2TypeID = @ContactPhone2TypeID,
			@idfDataAuditEvent = @idfDataAuditEvent,
		    @AuditUser = @AuditUser
		
--------------------------------------------------------------------------------------------------
-- replace Superseded Human ID with surviving Human ID
--------------------------------------------------------------------------------------------------
		--Data Audit--
		DECLARE @HumanIDsTemp TABLE
        (
            HumanID BIGINT NOT NULL
        );
        INSERT INTO @HumanIDsTemp
        SELECT idfHuman
        FROM dbo.tlbHuman
		WHERE idfHumanActual = @SupersededHumanMasterID
		--Data Audit--

		UPDATE dbo.tlbHuman
		SET idfHumanActual = @HumanMasterID
		WHERE idfHumanActual = @SupersededHumanMasterID


		--Data Audit--
        WHILE EXISTS (SELECT * FROM @HumanIDsTemp)
        BEGIN

            SELECT TOP 1
                @HumanID = HumanID
            FROM @HumanIDsTemp;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tlbHuman, 4572310000000,
					@HumanID,null,
					@SupersededHumanMasterID,@HumanMasterID

            END

            DELETE FROM @HumanIDsTemp
            WHERE HumanID = @HumanID;
        END
		--Data Audit--
		
--------------------------------------------------------------------------------------------------
-- soft delete the old Farm Master relate records
--------------------------------------------------------------------------------------------------
		EXEC dbo.USP_HUM_HUMAN_MASTER_DEL
			@HumanMasterID = @SupersededHumanMasterID,
			@idfDataAuditEvent = @idfDataAuditEvent,
		    @AuditUserName = @AuditUser
		 		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@HumanMasterID HumanMasterID,
			@EIDSSPersonID EIDSSPersonID, 
			@HumanID HumanID;
		--SELECT @ReturnCode ReturnCode,
		--	@ReturnMessage ReturnMessage,
		--	@HumanMasterID SessionKey

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END
