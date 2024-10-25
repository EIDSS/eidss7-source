set nocount on
set XACT_ABORT on

BEGIN TRANSACTION;

BEGIN TRY

	-- Customization package for which specific changes should be applied
	declare	@CustomizationPackageName	nvarchar(20)
	set	@CustomizationPackageName = N'All'

	-- Script version
	declare	@Version	nvarchar(20)
	set	@Version = '7.0.475.005'

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
CREATE OR ALTER PROCEDURE [dbo].[USP_HUM_COPYHUMANACTUALTOHUMAN]
(
    @idfHumanActual BIGINT = NULL,
    @idfHuman BIGINT = NULL OUTPUT,
    @returnCode INT = 0 OUTPUT,
    @returnMsg NVARCHAR(max) = ''SUCCESS'' OUTPUT
)
AS
DECLARE @idfCurrentResidenceAddress BIGINT
DECLARE @idfEmployerAddress BIGINT
DECLARE @idfRegistrationAddress BIGINT
DECLARE @idfSchoolAddress BIGINT
DECLARE @idfAltAddress BIGINT

DECLARE @idfCopyCurrentResidenceAddress BIGINT
DECLARE @idfCopyEmployerAddress BIGINT
DECLARE @idfCopyRegistrationAddress BIGINT
DECLARE @idfCopySchoolAddress BIGINT
DECLARE @idfCopyAltAddress BIGINT

BEGIN
    BEGIN TRY
        SELECT @idfCurrentResidenceAddress = ha.idfCurrentResidenceAddress,
               @idfEmployerAddress = ha.idfEmployerAddress,
               @idfRegistrationAddress = ha.idfRegistrationAddress,
			   @idfSchoolAddress = haai.SchoolAddressID,
			   @idfAltAddress = haai.AltAddressID
        FROM dbo.tlbHumanActual ha
		left join dbo.HumanActualAddlInfo haai
		on	haai.HumanActualAddlInfoUID = ha.idfHumanActual
        WHERE ha.idfHumanActual = @idfHumanActual

        IF @idfHuman IS NULL
            EXEC dbo.USP_GBL_NEXTKEYID_GET ''tlbHuman'', @idfHuman OUTPUT

        -- Get ids for copies of idfCurrentResidenceAddress, idfEmployerAddress, idfRegistrationAddress
        SET @idfCopyCurrentResidenceAddress = NULL
        SET @idfCopyEmployerAddress = NULL
        SET @idfCopyRegistrationAddress = NULL
        SELECT @idfCopyCurrentResidenceAddress = dbo.tlbHuman.idfCurrentResidenceAddress,
               @idfCopyEmployerAddress = dbo.tlbHuman.idfEmployerAddress,
			   @idfCopyRegistrationAddress = dbo.tlbHuman.idfRegistrationAddress
        FROM dbo.tlbHuman
        WHERE dbo.tlbHuman.idfHuman = @idfHuman

        -- Generate id for copy of idfCurrentResidenceAddress
        IF @idfCopyCurrentResidenceAddress IS NULL
           AND NOT @idfCurrentResidenceAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET ''tlbGeoLocation'',
                                           @idfCopyCurrentResidenceAddress OUTPUT

            -- Copy current residence address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfCurrentResidenceAddress,
                                              @idfCopyCurrentResidenceAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = ''Failed to copy current residence address''
                SELECT @returnCode,
                       @returnMsg
                RETURN
            END
        END

        -- Generate id for copy of idfEmployerAddress
        IF @idfCopyEmployerAddress IS NULL
           AND NOT @idfEmployerAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET ''tlbGeoLocation'',
                                           @idfCopyEmployerAddress OUTPUT

            -- Copy employer address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfEmployerAddress,
                                              @idfCopyEmployerAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = ''Failed to copy employer address''
                SELECT @returnCode,
                       @returnMsg
                RETURN
            END
        END

        -- Generate id for copy of idfRegistrationAddress
        IF @idfCopyRegistrationAddress IS NULL
           AND NOT @idfRegistrationAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET ''tlbGeoLocation'',
                                           @idfCopyRegistrationAddress OUTPUT

            -- Copy registration address 
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfRegistrationAddress,
                                              @idfCopyRegistrationAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = ''Failed to copy registration address''
                SELECT @returnCode,
                       @returnMsg
                RETURN
            END
        END


        IF EXISTS (SELECT * FROM dbo.tlbHuman WHERE idfHuman = @idfHuman)
        BEGIN
            UPDATE dbo.tlbHuman
            SET idfHumanActual = @idfHumanActual,
                idfsOccupationType = ha.idfsOccupationType,
                idfsNationality = ha.idfsNationality,
                idfsHumanGender = ha.idfsHumanGender,
                idfCurrentResidenceAddress = @idfCopyCurrentResidenceAddress,
                idfEmployerAddress = @idfCopyEmployerAddress,
                idfRegistrationAddress = @idfCopyRegistrationAddress,
                datDateofBirth = ha.datDateofBirth,
                datDateOfDeath = ha.datDateOfDeath,
                strLastName = ha.strLastName,
                strSecondName = ha.strSecondName,
                strFirstName = ha.strFirstName,
                strRegistrationPhone = ha.strRegistrationPhone,
                strEmployerName = ha.strEmployerName,
                strHomePhone = ha.strHomePhone,
                strWorkPhone = ha.strWorkPhone,
                idfsPersonIDType = ha.idfsPersonIDType,
                strPersonID = ha.strPersonID,
                datModIFicationDate = ha.datModIFicationDate
            FROM dbo.tlbHuman h
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = ha.idfHumanActual
            WHERE h.idfHuman = @idfHuman
        END
        ELSE
        BEGIN
            INSERT INTO dbo.tlbHuman
            (
                idfHuman,
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
                datModIFicationDate,
                intRowStatus
            )
            SELECT @idfHuman,
                   @idfHumanActual,
                   idfsOccupationType,
                   idfsNationality,
                   idfsHumanGender,
                   @idfCopyCurrentResidenceAddress,
                   @idfCopyEmployerAddress,
                   @idfCopyRegistrationAddress,
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
                   datModIFicationDate,
                   0
            FROM dbo.tlbHumanActual
            WHERE idfHumanActual = @idfHumanActual
        END

        -- Insert/Update Additional Info

        -- Get ids for copies of SchoolAddressID and AltAddressID
        SET @idfCopySchoolAddress = NULL
		SET @idfCopyAltAddress = NULL
        SELECT @idfCopySchoolAddress = dbo.HumanAddlInfo.SchoolAddressID,
		       @idfCopyAltAddress = dbo.HumanAddlInfo.AltAddressID
        FROM dbo.HumanAddlInfo
        WHERE dbo.HumanAddlInfo.HumanAdditionalInfo = @idfHuman

        -- Generate id for copy of SchoolAddressID
        IF @idfCopySchoolAddress IS NULL
           AND NOT @idfSchoolAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET ''tlbGeoLocation'',
                                           @idfCopySchoolAddress OUTPUT

            -- Copy school address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfSchoolAddress,
                                              @idfCopySchoolAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = ''Failed to copy school address''
                SELECT @returnCode ''ReturnCode'',
                       @returnMsg ''ReturnMessage''
                RETURN
            END
        END

        -- Generate id for copy of AltAddressID
        IF @idfCopyAltAddress IS NULL
           AND NOT @idfAltAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET ''tlbGeoLocation'',
                                           @idfCopyAltAddress OUTPUT

            -- Copy alternative address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfAltAddress,
                                              @idfCopyAltAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = ''Failed to copy alternative address''
                SELECT @returnCode ''ReturnCode'',
                       @returnMsg ''ReturnMessage''
                RETURN
            END
        END

        IF EXISTS
        (
            SELECT 1
            FROM dbo.HumanAddlInfo
            WHERE HumanAdditionalInfo = @idfHuman
        )
        BEGIN
            UPDATE dbo.HumanAddlInfo
            SET PassportNbr = haai.PassportNbr,
                IsEmployedID = haai.IsEmployedID,
                EmployerPhoneNbr = haai.EmployerPhoneNbr,
                EmployedDTM = haai.EmployedDTM,
                IsStudentID = haai.IsStudentID,
                SchoolPhoneNbr = haai.SchoolPhoneNbr,
                SchoolAddressID = @idfCopySchoolAddress,
                SchoolLastAttendDTM = haai.SchoolLastAttendDTM,
                ContactPhoneCountryCode = haai.ContactPhoneCountryCode,
                ContactPhoneNbr = haai.ContactPhoneNbr,
                ContactPhoneNbrTypeID = haai.ContactPhoneNbrTypeID,
                ContactPhone2CountryCode = haai.ContactPhone2CountryCode,
                ContactPhone2Nbr = haai.ContactPhone2Nbr,
                ContactPhone2NbrTypeID = haai.ContactPhone2NbrTypeID,
                AltAddressID = @idfCopyAltAddress,
                SchoolName = haai.SchoolName,
				IsAnotherPhoneID = haai.IsAnotherPhoneID,
				IsAnotherAddressID = haai.IsAnotherAddressID
            FROM dbo.HumanAddlInfo hai
                INNER JOIN dbo.humanActualAddlInfo haai
                    ON hai.HumanAdditionalInfo = haai.HumanActualAddlInfoUID
            WHERE hai.HumanAdditionalInfo = @idfHuman
        END
        ELSE
        BEGIN
            INSERT INTO dbo.HumanAddlInfo
            (
                HumanAdditionalInfo,
                ReportedAge,
                ReportedAgeUOMID,
                ReportedAgeDTM,
                PassportNbr,
                IsEmployedID,
                EmployerPhoneNbr,
                EmployedDTM,
                IsStudentID,
                SchoolPhoneNbr,
                SchoolAddressID,
                SchoolLastAttendDTM,
                ContactPhoneCountryCode,
                ContactPhoneNbr,
                ContactPhoneNbrTypeID,
                ContactPhone2CountryCode,
                ContactPhone2Nbr,
                ContactPhone2NbrTypeID,
                SchoolName,
                intRowStatus,
				AltAddressID,
				IsAnotherPhoneID,
				IsAnotherAddressID
            )
            SELECT @idfHuman,
                   ReportedAge,
                   ReportedAgeUOMID,
                   ReportedAgeDTM,
                   PassportNbr,
                   IsEmployedID,
                   EmployerPhoneNbr,
                   EmployedDTM,
                   IsStudentID,
                   SchoolPhoneNbr,
                   @idfCopySchoolAddress,
                   SchoolLastAttendDTM,
                   ContactPhoneCountryCode,
                   ContactPhoneNbr,
                   ContactPhoneNbrTypeID,
                   ContactPhone2CountryCode,
                   ContactPhone2Nbr,
                   ContactPhone2NbrTypeID,
                   SchoolName,
                   intRowStatus,
				   @idfCopyAltAddress,
				   IsAnotherPhoneID,
				   IsAnotherAddressID
            FROM dbo.humanActualAddlInfo
            WHERE HumanActualAddlInfoUID = @idfHumanActual
        END
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
