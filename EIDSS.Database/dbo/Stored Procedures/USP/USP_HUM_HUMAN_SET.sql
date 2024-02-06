--*************************************************************
-- Name 				:	USP_HUM_HUMAN_SET
-- Description			:	Insert OR UPDATE human record
--          
-- Author               :	Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
-- --------------- ---------- ---------------------------------
-- Stephen Long    08/23/2018 Added output to strEIDSSPersonID
-- Stephen Long	   09/28/2018 Added employer, human alt, school 
--                            foreign address string, human alt 
--                            foreign address boolean.
-- Mark Wilson     10/06/2021 Added Elevation (NULL) to USP_GBL_ADDRESS_SET
-- Mandar Kulkarni	10/19/2021 Added @AuditUser parameter
--*************************************************************
CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_SET]
(
	 @idfHumanActual			BIGINT OUTPUT,
	 @idfsPersonIdType			BIGINT,
	 @strEIDSSPersonID			NVARCHAR(200) = '(new)' OUTPUT,
	 @strPersonId				NVARCHAR(100),
	 @strFirstName				NVARCHAR(200),
	 @strSecondName				NVARCHAR(200),
	 @strLastName				NVARCHAR(200),
	 @datDateOfBirth			DATETIME,
	 @datDateOfDeath			DATETIME, --New
	 @ReportedAge				INT,
	 @ReportAgeUOMID			BIGINT,
	 @idfsHumanGender			BIGINT,
	 @idfsOccupationType		BIGINT, --New
	 @idfsNationality			BIGINT,
	 @strPassportNbr			NVARCHAR(20),
	 @IsEmployedID				BIGINT,
	 @strEmployerName			NVARCHAR(200),
	 @EmployedDTM				DATETIME,
	 @EmployerblnForeignAdress	BIT = 0,
	 @EmployerstrForeignAddress NVARCHAR(200) = NULL, 
	 @idfEmployerGeoLocation	BIGINT,
	 @EmployeridfsCountry		BIGINT,
	 @EmployeridfsRegion		BIGINT,
	 @EmployeridfsRayon			BIGINT,
	 @EmployeridfsSettlement	BIGINT,
	 @EmployerstrStreetName		NVARCHAR(200),
	 @EmployerstrApartment		NVARCHAR(200),
	 @EmployerstrBuilding		NVARCHAR(200),
	 @EmployerstrHouse			NVARCHAR(200),
	 @EmployeridfsPostalCode	NVARCHAR(200),
	 @EmployerPhoneNbr			NVARCHAR(100),
	 @IsStudentID				BIGINT,
	 @strSchoolName				NVARCHAR(200),
	 @SchoolLastAttendedDTM		DATETIME,
	 @SchoolblnForeignAdress	BIT = 0,
	 @SchoolstrForeignAddress	NVARCHAR(200) = NULL, 
	 @idfSchoolGeoLocation		BIGINT,
	 @SchoolidfsCountry			BIGINT,
	 @SchoolidfsRegion			BIGINT,
	 @SchoolidfsRayon			BIGINT,
	 @SchoolidfsSettlement		BIGINT,
	 @SchoolstrStreetName		NVARCHAR(200),
	 @SchoolstrApartment		NVARCHAR(200),
	 @SchoolstrBuilding			NVARCHAR(200),
	 @SchoolstrHouse			NVARCHAR(200),
	 @SchoolidfsPostalCode		NVARCHAR(200),
	 @SchoolPhoneNbr			NVARCHAR(100),
	 @idfHumanGeoLocation		BIGINT,
	 @HumanidfsCountry			BIGINT,
	 @HumanidfsRegion			BIGINT,
	 @HumanidfsRayon			BIGINT,
	 @HumanidfsSettlement		BIGINT,
	 @HumanstrStreetName		NVARCHAR(200),
	 @HumanstrApartment			NVARCHAR(200),
	 @HumanstrBuilding			NVARCHAR(200),
	 @HumanstrHouse				NVARCHAR(200),
	 @HumanidfsPostalCode		NVARCHAR(200),
	 @HumanstrLatitude			FLOAT = NULL,--##PARAM dblLatitude - Latitude 
	 @HumanstrLongitude			FLOAT = NULL,--##PARAM dblLongitude  - Longitude 
	 @HumanstrElevation			FLOAT = NULL,--##PARAM dblElevation  - Elevation
	 @idfHumanAltGeoLocation	BIGINT,
	 @HumanAltblnForeignAddress	BIT = 0,
	 @HumanAltstrForeignAddress NVARCHAR(200) = NULL, 
	 @HumanAltidfsCountry		BIGINT,
	 @HumanAltidfsRegion		BIGINT,
	 @HumanAltidfsRayon			BIGINT,
	 @HumanAltidfsSettlement	BIGINT,
	 @HumanAltstrStreetName		NVARCHAR(200),
	 @HumanAltstrApartment		NVARCHAR(200),
	 @HumanAltstrBuilding		NVARCHAR(200),
	 @HumanAltstrHouse			NVARCHAR(200),
	 @HumanAltidfsPostalCode	NVARCHAR(200),
	 @HumanAltstrLatitude		FLOAT = NULL,--##PARAM dblLatitude - Latitude 
	 @HumanAltstrLongitude		FLOAT = NULL,--##PARAM dblLongitude  - Longitude 
	 @HumanAltstrElevation		FLOAT = NULL,--##PARAM dblElevation  - Elevation
	 @strRegistrationPhone		NVARCHAR(200), --New
	 @strHomePhone				NVARCHAR(200), --New
	 @strWorkPhone				NVARCHAR(200), -- New
	 @ContactPhoneCountryCode	INT, --New
	 @ContactPhoneNbr			NVARCHAR(200), -- New
	 @ContactPhoneNbrTypeID		BIGINT,--New
	 @ContactPhone2CountryCode	INT, --New
	 @ContactPhone2Nbr			NVARCHAR(200), -- New
	 @ContactPhone2NbrTypeID	BIGINT, -- New
	 @AuditUser					NVARCHAR(100) = ''
 )
AS
DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(max) = 'SUCCESS' 

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
				
		-- Set Employer Address 
		IF (@EmployeridfsCountry IS NOT NULL AND @EmployeridfsRayon IS NOT NULL AND @EmployeridfsRegion IS NOT NULL) OR @EmployerblnForeignAdress = 1
			DECLARE @EmployeridfsLocation BIGINT = COALESCE(@EmployeridfsSettlement, @EmployeridfsRayon,@EmployeridfsRegion,@EmployeridfsCountry)

			EXECUTE dbo.USSP_GBL_ADDRESS_SET
										@idfEmployerGeoLocation OUTPUT,
										NULL,
										NULL,
										NULL,
										@EmployeridfsLocation,
										@EmployerstrApartment,
										@EmployerstrBuilding,
										@EmployerstrStreetName,
										@EmployerstrHouse,
										@EmployeridfsPostalCode,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										@EmployerblnForeignAdress,
										@EmployerstrForeignAddress,
										1,
										@AuditUser,
										@returnCode OUTPUT,
										@returnMsg OUTPUT	

		-- Set School Address 
		IF (@SchoolidfsCountry IS NOT NULL AND @SchoolidfsRayon IS NOT NULL AND @SchoolidfsRegion IS NOT NULL) OR @SchoolblnForeignAdress = 1
			DECLARE @SchoolidfsLocation BIGINT = COALESCE(@SchoolidfsSettlement,@SchoolidfsRayon,@SchoolidfsRegion,@SchoolidfsCountry)
			EXECUTE dbo.USSP_GBL_ADDRESS_SET
										@idfSchoolGeoLocation OUTPUT,
										NULL,
										NULL,
										NULL,
										@SchoolidfsLocation,
										@SchoolstrApartment,
										@SchoolstrBuilding,
										@SchoolstrStreetName,
										@SchoolstrHouse,
										@SchoolidfsPostalCode,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										@SchoolblnForeignAdress,
										@SchoolstrForeignAddress,
										1,
										@AuditUser,
										@returnCode OUTPUT,
										@returnMsg OUTPUT	

		-- Set Curren Registration Address 
		IF @HumanidfsCountry IS NOT NULL AND @HumanidfsRayon IS NOT NULL AND @HumanidfsRegion IS NOT NULL
			DECLARE @HumanidfsLocation BIGINT = COALESCE(@HumanidfsSettlement,@HumanidfsRayon,@HumanidfsRegion,@HumanidfsCountry)
			EXECUTE dbo.USSP_GBL_ADDRESS_SET
										@idfHumanGeoLocation OUTPUT,
										NULL,
										NULL,
										NULL,
										@HumanidfsLocation,
										@HumanstrApartment,
										@HumanstrBuilding,
										@HumanstrStreetName,
										@HumanstrHouse,
										@HumanidfsPostalCode,
										NULL,
										NULL, 
										@HumanstrLatitude,
										@HumanstrLongitude,
										@HumanstrElevation,
										NULL,
										NULL,
										0,
										NULL,
										1,
										@AuditUser,
										@returnCode OUTPUT,
										@returnMsg OUTPUT	

		-- Set Registration Address
		IF (@HumanAltidfsCountry IS NOT NULL AND @HumanAltidfsRayon IS NOT NULL AND @HumanAltidfsRegion IS NOT NULL) OR @HumanAltblnForeignAddress = 1
			DECLARE @HumanAltidfsLocation BIGINT = COALESCE(@HumanAltidfsSettlement,@HumanAltidfsRayon,@HumanAltidfsRegion,@HumanAltidfsCountry)
			EXECUTE dbo.USSP_GBL_ADDRESS_SET
										@idfHumanAltGeoLocation OUTPUT,
										NULL,
										NULL,
										NULL,
										@HumanAltidfsLocation,
										@HumanAltstrApartment,
										@HumanAltstrBuilding,
										@HumanAltstrStreetName,
										@HumanAltstrHouse,
										@HumanAltidfsPostalCode,
										NULL,
										NULL,
										@HumanAltstrLatitude,
										@HumanAltstrLongitude,
										@HumanAltstrElevation,
										NULL,
										NULL,
										@HumanAltblnForeignAddress, 
										@HumanAltstrForeignAddress,
										1,
										@AuditUser,
										@returnCode OUTPUT,
										@returnMsg OUTPUT	

		IF NOT EXISTS (SELECT * FROM dbo.tlbHumanActual WHERE idfHumanActual = @idfHumanActual AND intRowStatus = 0)
			BEGIN
				EXECUTE USP_GBL_NEXTKEYID_GET 'tlbHumanActual', @idfHumanActual OUTPUT

				INSERT
				INTO	dbo.tlbHumanActual
					(
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
						AuditCreateUser
					)
				VALUES
					(	
						@idfHumanActual,
						@idfsNationality,
						@idfsHumanGender,
						@idfHumanGeoLocation,
						@idfsOccupationType,
						@idfEmployerGeoLocation,
						@idfHumanAltGeoLocation,
						@datDateOfBirth,
						@datDateOfDeath,
						@strFirstName,
						@strSecondName,
						@strLastName,
						@strRegistrationPhone,
						@strEmployerName,
						@strHomePhone,
						@strWorkPhone,
						@idfsPersonIdType,
						@strPersonId,
						0,
						@AuditUser
					)

				--IF @strEIDSSPersonID = '(new)'
				--BEGIN
					EXECUTE dbo.USP_GBL_NextNumber_GET 'EIDSS Person', @strEIDSSPersonID OUTPUT, NULL --N'Person'
				--END

				INSERT 
				INTO	dbo.HumanActualAddlInfo
					(
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
						intRowStatus,
						AuditCreateUser
					)
				VALUES
					(
						@idfHumanActual,
						@strEIDSSPersonID,
						@ReportedAge,
						@ReportAgeUOMID,
						@strPassportNbr,
						@IsEmployedID,
						@EmployerPhoneNbr,
						@EmployedDTM,
						@IsStudentId,
						@strSchoolName,
						@SchoolPhoneNbr,
						@idfSchoolGeoLocation,
						@SchoolLastAttendedDTM,
						@ContactPhoneCountryCode,
						@ContactPhoneNbr,
						@ContactPhoneNbrTypeID,
						@ContactPhone2CountryCode,
						@ContactPhone2Nbr,
						@ContactPhone2NbrTypeID,
						0,
						@AuditUser
					)
			END
		ELSE
			BEGIN
				UPDATE dbo.tlbHumanActual
				SET		idfsNationality = @idfsNationality,
						idfsHumanGender = @idfsHumanGender,
						idfCurrentResidenceAddress = @idfHumanGeoLocation,
						idfsOccupationType = @idfsOccupationType,
						idfEmployerAddress= @idfEmployerGeoLocation,
						idfRegistrationAddress = @idfHumanAltGeoLocation,
						datDateofBirth = @datDateOfBirth,
						datDateofDeath = @datDateOfDeath,
						strFirstName = @strFirstName,
						strSecondName = @strSecondName,
						strLastName = @strLastName,
						strRegistrationPhone = @strRegistrationPhone,
						strEmployerName = @strEmployerName,
						strHomePhone = @strHomePhone,
						strWorkPhone = @strWorkPhone,
						idfsPersonIDType =@idfsPersonIdType,
						strPersonID = @strPersonId,
						AuditUpdateUser = @AuditUser
				WHERE idfHumanActual = @idfHumanActual

				UPDATE dbo.HumanActualAddlinfo
				SET		ReportedAge = @ReportedAge,
						ReportedAgeUOMID =@ReportAgeUOMID,
						PassportNbr = @strPassportNbr,
						isEmployedId = @isEmployedId,
						EmployerPhoneNbr = @EmployerPhoneNbr,
						EmployedDTM = @EmployedDTM,
						isStudentId = @IsStudentID,
						SchoolName = @strSchoolName,
						SchoolPhoneNbr = @SchoolPhoneNbr,
						SchoolAddressId = @idfSchoolGeoLocation,
						SchoolLastAttendDTM = @SchoolLastAttendedDTM,
						ContactPhoneCountryCode = @ContactPhoneCountryCode ,
						ContactPhoneNbr = @ContactPhoneNbr,
						ContactPhoneNbrTypeID = @ContactPhoneNbrTypeID,
						ContactPhone2CountryCode = @ContactPhone2CountryCode,
						ContactPhone2Nbr = @ContactPhone2Nbr,
						ContactPhone2NbrTypeID = @ContactPhone2NbrTypeID,
						AuditUpdateUser = @AuditUser
				WHERE HumanActualAddlInfoUID = @idfHumanActual
			END

		IF @@TRANCOUNT > 0 AND @returnCode = 0
			COMMIT

		SELECT @returnCode, @returnMsg
	END TRY
	BEGIN CATCH
		IF @@Trancount = 1 
			ROLLBACK
			SET @returnCode = ERROR_NUMBER()
			SET @returnMsg = 
		   'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
		   + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
		   + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
		   + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
		   + ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
		   + ' ErrorMessage: '+ ERROR_MESSAGE()

		SELECT @returnCode, @returnMsg
	END CATCH
END
