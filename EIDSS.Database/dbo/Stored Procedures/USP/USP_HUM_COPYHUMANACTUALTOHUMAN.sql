--*************************************************************************************************
-- Name 				:	USP_HUM_COPYHUMANACTUALTOHUMAN
-- Description			:	Copies information FROM tlbHumanActual INTO tlbHuman
--							IF @idfHumanActual IS NULL or record with @idfHumaN
--							doesn't exist in tlbHuman, new record IS created in tlbHuman.
-- Author               :	Mandar Kulkarni
--
-- Revision History:
--
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Lamont Mitchell    01/11/2019 Supressed Results and Aliased Output Columns
-- Lamont Mitchell    01/11/2019 Supressed GBL_GEOLOCATION_COPY
-- Harold Pryor       02/13/2019 Supressed additional GBL_GEOLOCATION_COPY
-- Stephen Long       01/07/2022 Added dbo schema to tables and sp calls.
-- Stephen Long       01/23/2022 Removed suppress select; SQL throwing nested insert/exec 
--                               exceptions.
--
--BEGIN tran
--EXEC USP_HUM_COPYHUMANACTUALTOHUMAN @idfHumanActual, @idfHuman OUT
--*************************************************************************************************
CREATE PROCEDURE [dbo].[USP_HUM_COPYHUMANACTUALTOHUMAN]
(
    @idfHumanActual BIGINT = NULL,
    @idfHuman BIGINT = NULL OUTPUT,
    @returnCode INT = 0 OUTPUT,
    @returnMsg NVARCHAR(max) = 'SUCCESS' OUTPUT
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
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbHuman', @idfHuman OUTPUT

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
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @idfCopyCurrentResidenceAddress OUTPUT

            -- Copy current residence address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfCurrentResidenceAddress,
                                              @idfCopyCurrentResidenceAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = 'Failed to copy current residence address'
                SELECT @returnCode,
                       @returnMsg
                RETURN
            END
        END

        -- Generate id for copy of idfEmployerAddress
        IF @idfCopyEmployerAddress IS NULL
           AND NOT @idfEmployerAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @idfCopyEmployerAddress OUTPUT

            -- Copy employer address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfEmployerAddress,
                                              @idfCopyEmployerAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = 'Failed to copy employer address'
                SELECT @returnCode,
                       @returnMsg
                RETURN
            END
        END

        -- Generate id for copy of idfRegistrationAddress
        IF @idfCopyRegistrationAddress IS NULL
           AND NOT @idfRegistrationAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @idfCopyRegistrationAddress OUTPUT

            -- Copy registration address 
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfRegistrationAddress,
                                              @idfCopyRegistrationAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = 'Failed to copy registration address'
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
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @idfCopySchoolAddress OUTPUT

            -- Copy school address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfSchoolAddress,
                                              @idfCopySchoolAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = 'Failed to copy school address'
                SELECT @returnCode 'ReturnCode',
                       @returnMsg 'ReturnMessage'
                RETURN
            END
        END

        -- Generate id for copy of AltAddressID
        IF @idfCopyAltAddress IS NULL
           AND NOT @idfAltAddress IS NULL
        BEGIN
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                           @idfCopyAltAddress OUTPUT

            -- Copy alternative address
            EXEC dbo.USP_GBL_GEOLOCATION_COPY @idfAltAddress,
                                              @idfCopyAltAddress,
                                              0,
                                              @returnCode,
                                              @returnMsg

            IF @returnCode <> 0
            BEGIN
                SET @returnMsg = 'Failed to copy alternative address'
                SELECT @returnCode 'ReturnCode',
                       @returnMsg 'ReturnMessage'
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
