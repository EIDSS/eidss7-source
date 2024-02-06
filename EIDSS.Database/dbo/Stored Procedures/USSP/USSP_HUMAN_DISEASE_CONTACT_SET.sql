--*************************************************************
-- Name 				: USSP_HUM_DISEASE_CONTACT_SET
-- Description			: set Human Disease Report Contacts by HDID
--          
-- Author               : HAP
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
-- HAP				20190119		created 
-- HAP              20190428        Updated to properly save contact
-- HAP              20190528        Updated to include new input paramter @idfHuman
--Lamont Mitchell	20190822		Updated to add Contacts in the appropriate table (human)
--Lamont Mitchell	10072020		Removed hardcoded idfsPersonContactType
-- Testing code:
-- 
--*************************************************************
CREATE PROCEDURE [dbo].[USSP_HUMAN_DISEASE_CONTACT_SET] 
(		 
	@idfHumanCase			BIGINT = NULL,
	@idfHuman				BIGINT = NULL, 
	@ContactsParameters		NVARCHAR(MAX) = NULL,
	@outbreakCall			INT = 0,
	@AuditUser				NVARCHAR(100) = ''
)
AS
BEGIN

DECLARE @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)

   DECLARE @idfContactedCasePerson bigint = null
		   ,@idfsPersonContactType bigint = null 
		   ,@idfHumanActual bigint = null 
           ,@datDateOfLastContact datetime = null
           ,@strPlaceInfo nvarchar(200) = null
           ,@intRowStatus int = 0
           ,@rowguid uniqueIdentifier = NEWID()
           ,@strComments nvarchar(500) = null
           ,@strMaintenanceFlag nvarchar(20) = null
           ,@strReservedAttribute nvarchar(max) = null
		   ,@strFirstName nvarchar(200) = null
		   ,@strSecondName nvarchar(200) = null
           ,@strLastName nvarchar(200) = null
           ,@strContactPersonFullName nvarchar(200) = null
           ,@datDateOfBirth DateTime2 = null
           ,@idfsHumanGender bigint = null
           ,@idfCitizenship bigint = null
           ,@idfsCountry bigint = null
           ,@idfsRegion bigint = null
           ,@strContactPhone nvarchar(20) = null
           ,@idfContactPhoneType bigint = null

	DECLARE @returnMsg				VARCHAR(MAX) = 'Success';
	DECLARE @returnCode				BIGINT = 0;

	DECLARE @ContactsTemp Table(	     
			idfContactedCasePerson bigint null
		   ,idfsPersonContactType bigint null 
           ,idfHuman bigint null
		   ,idfHumanActual bigint null 
           ,idfHumanCase bigint null
           ,datDateOfLastContact datetime null
           ,strPlaceInfo nvarchar(200) null
           ,intRowStatus int 
           ,rowguid uniqueIdentifier  null
           ,strComments nvarchar(500) null
           ,strMaintenanceFlag nvarchar(20) null
           ,strReservedAttribute nvarchar(max) null
		   ,strFirstName nvarchar(200) null
		   ,strSecondName nvarchar(200) null
           ,strLastName nvarchar(200) null
           ,strContactPersonFullName nvarchar(200) null
           ,datDateOfBirth DateTime2 null
           ,idfsHumanGender bigint null
           ,idfCitizenship bigint null
           ,idfsCountry bigint null
           ,idfsRegion bigint null
           ,strContactPhone nvarchar(20) null
           ,idfContactPhoneType bigint null
		   )
	INSERT INTO @ContactsTemp 
	SELECT * FROM OPENJSON(@ContactsParameters) 
			WITH (
				idfContactedCasePerson bigint
			   ,idfsPersonContactType bigint	   
			   ,idfHuman bigint
			   ,idfHumanActual bigint
			   ,idfHumanCase bigint
			   ,datDateOfLastContact datetime
			   ,strPlaceInfo nvarchar(200)
			   ,intRowStatus int 
			   ,rowguid uniqueIdentifier
			   ,strComments nvarchar(500)
			   ,strMaintenanceFlag nvarchar(20)
			   ,strReservedAttribute nvarchar(max)
			   ,strFirstName nvarchar(200)
			   ,strSecondName nvarchar(200)
			   ,strLastName nvarchar(200)
			   ,strContactPersonFullName nvarchar(200)
			   ,datDateOfBirth DateTime2 
			   ,idfsHumanGender bigint
			   ,idfCitizenship bigint
			   ,idfsCountry bigint
			   ,idfsRegion bigint
			   ,strContactPhone nvarchar(20)
			   ,idfContactPhoneType bigint
				);
	BEGIN TRY 
			WHILE EXISTS (SELECT * FROM @ContactsTemp)
			BEGIN
				SELECT TOP 1
					@idfContactedCasePerson = idfContactedCasePerson
				   ,@idfsPersonContactType = idfsPersonContactType
				   ,@idfHuman = idfHuman 
				   ,@idfHumanActual = idfHumanActual
				   ,@datDateOfLastContact = datDateOfLastContact
				   ,@strPlaceInfo = strPlaceInfo
				   ,@intRowStatus = intRowStatus
				   ,@rowguid = rowguid
				   ,@strComments = strComments
				   ,@strMaintenanceFlag = strMaintenanceFlag
				   ,@strReservedAttribute = strReservedAttribute
				   ,@strFirstName = strFirstName
				   ,@strSecondName = strSecondName
				   ,@strLastName = strLastName
				   ,@strContactPersonFullName = strContactPersonFullName
				   ,@datDateOfBirth = datDateOfBirth
				   ,@idfsHumanGender = idfsHumanGender
				   ,@idfCitizenship = idfCitizenship
				   ,@idfsCountry = idfsCountry
				   ,@idfsRegion = idfsRegion
				   ,@strContactPhone = strContactPhone
				   ,@idfContactPhoneType = idfContactPhoneType
				FROM @ContactsTemp --WHERE idfsPersonContactType IS NOT NULL--where idfHuman is not null

		IF NOT EXISTS (SELECT idfContactedCasePerson 
							FROM dbo.tlbContactedCasePerson 
							WHERE rowguid = @rowguid and  idfHumanCase = @idfHumanCase 
								AND	intRowStatus = 0)
			BEGIN

				IF @outbreakCall = 1
					BEGIN
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbContactedCasePerson', @idfContactedCasePerson OUTPUT
					END
				ELSE
					BEGIN
						INSERT INTO @SupressSelect
						-- Get next key value
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbContactedCasePerson', @idfContactedCasePerson OUTPUT
						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbHuman', @idfHuman OUTPUT
					END

				INSERT INTO dbo.tlbHuman
				(idfHumanActual, idfHuman,strFirstName, strLastName,AuditCreateDTM)
				Values
				(@idfHumanActual,@idfHuman,@strFirstName,@strLastName,GETDATE())

				INSERT INTO [dbo].[tlbContactedCasePerson]
					   (
						   idfContactedCasePerson,
						   idfsPersonContactType
						   ,idfHuman
						   ,idfHumanCase
						   ,datDateOfLastContact
						   ,strPlaceInfo
						   ,intRowStatus
						   ,rowguid
						   ,strComments
						   ,strMaintenanceFlag
						   ,strReservedAttribute
						   ,AuditCreateUser
					   )
				 VALUES
					   (
							@idfContactedCasePerson
							,@idfsPersonContactType 
							,@idfHuman 
							,@idfHumanCase
							,@datDateOfLastContact
							,@strPlaceInfo 
							,0
							,NEWID() 
							,@strComments 
							,@strMaintenanceFlag 
							,@strReservedAttribute 
							,@AuditUser
					   )
			END
		Else
			BEGIN
				UPDATE dbo.tlbContactedCasePerson
				SET 
					    idfsPersonContactType = @idfsPersonContactType
					   ,idfHuman = @idfHuman
					   ,idfHumanCase = @idfHumanCase
					   ,datDateOfLastContact = @datDateOfLastContact
					   ,intRowStatus = isnull(@intRowStatus,0)
					   ,rowguid = @rowguid
					   ,strComments = @strComments
					   ,strMaintenanceFlag = @strMaintenanceFlag
					   ,strReservedAttribute = @strReservedAttribute,
					   strPlaceInfo = @strPlaceInfo,
					   AuditUpdateUser = @AuditUser
				WHERE rowguid = @rowguid and  idfHumanCase = @idfHumanCase 
					--AND	intRowStatus = 0
			END

			SET ROWCOUNT 1
				--	DELETE FROM @ContactsTemp
				--	SET ROWCOUNT 0
				 Delete top(1) from @ContactsTemp
				
		END		--end loop, WHILE EXISTS (SELECT * FROM @SamplesTemp)
			--SELECT @returnCode 'ReturnCode', @returnMsg 'ResturnMessage';
		END TRY  
	BEGIN CATCH 
		THROW
	END CATCH;
END
