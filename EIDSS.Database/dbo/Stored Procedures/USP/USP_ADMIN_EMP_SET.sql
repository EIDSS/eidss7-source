

--=========================================================================================================================================
-- Created by:				Joan Li
-- Description:				04/19/2017: Created based on V6 spPerson_Post: V7 USP
--                          JL:Input: 11 parameters related to person ,organization,site outPut: idfPersonNewID
--							04/26/2017: JL:change name to: USP_ADMIN_EMP_SET	
--                          06/05/2017: JL:Dev group asking add calling usp_sysGetNewID if app calling this 
--                          SP with action=4 and @idfPerson=NULL
--                          06/12/2017: JL: Dev group asking to set @idfPerson input param =NULL
--                          06/13/2017: JL:Dev group asking to return idfpersonnewid
--                          06/21/2017: JL:  add data modify date and user info
--                          09/25/2017: JL: returns status for success; returns @idfPerson for update
--						    11/03/2019: RM:	added PersonalID info
--						    09/22/2020: AX:	added @idfsEmployeeCategory to the parameters and set @idfsSite input param =NULL
--						    10/01/2020: AX:	checked if @idfsEmployeeCategory is 0, default it to 10526002 (non-user) to fix the issue after adding @idfsEmployeeCategory to this SP
--							10/15/2021: Minal: Updated Tstsite to tlboffice while selecting the person site
--							10/22/2021: Mark Wilson - added auditing fields to insert/update.  added test code that works
--
/* Test Code

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_ADMIN_EMP_SET]
		@idfPerson = NULL,
		@idfsStaffPosition = 38670000000,
		@idfInstitution = 1180000232,
		@idfDepartment = NULL,
		@strFamilyName = N'Pyle',
		@strFirstName = N'Goober',
		@strSecondName = N'H',
		@strContactPhone = N'1234567890',
		@strBarcode = N'qqww33',
		@idfsSite = 1,
		@strPersonalID = N'ABC123',
		@idfPersonalIDType = NULL,
		@idfsEmployeeCategory = 10526001,
		@User = N'rykermase'

SELECT	'Return Value' = @return_value


*/
-- =========================================================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_SET]
( 

	@idfPerson			BIGINT = NULL			--##PARAM @idfPerson person ID
	,@idfsStaffPosition BIGINT					--##PARAM @idfsStaffPosition - person position (reference to rftPosition, 19000073)
	,@idfInstitution	BIGINT					--##PARAM @idfInstitution - person organization
	,@idfDepartment		BIGINT					--##PARAM @idfDepartment - person department
	,@strFamilyName		NVARCHAR(200)			--##PARAM @strFamilyName - person last name
	,@strFirstName		NVARCHAR(200)			--##PARAM @strFirstName - person first name
	,@strSecondName		NVARCHAR(200)			--##PARAM @strSecondName - person second name
	,@strContactPhone	NVARCHAR(200)			--##PARAM @strContactPhone - person contact phone
	,@strBarcode		NVARCHAR(200) = NULL	--##PARAM @strBarcode - person uniquue barcode (doesn't use now)
	,@idfsSite			BIGINT = NULL			--##PARAM @idfsSite - site where the record was created
	,@strPersonalID		NVARCHAR(200)
	,@idfPersonalIDType	NVARCHAR(200)
	,@idfsEmployeeCategory 	BIGINT = 10526002	--defaulted it to be a ‘non-user’	
	,@User				VARCHAR(100)=NULL		--who required data change
)
AS

DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0 

Declare @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)
BEGIN
	BEGIN TRY  	
	BEGIN TRANSACTION
		----get data change date and user info: before app send final user 
		DECLARE @DataChageInfo as NVARCHAR(MAX)
		SELECT @DataChageInfo = dbo.FN_GBL_DATACHANGE_INFO (@User)

		IF @idfsEmployeeCategory = 0
		BEGIN  
			SELECT @idfsEmployeeCategory = 10526002
		END

		IF NOT EXISTS (SELECT idfEmployee FROM dbo.tlbEmployee WHERE idfEmployee = @idfPerson)

		BEGIN    
			BEGIN
			insert into @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 
					@tableName = 'tlbEmployee',
					@idfsKey = @idfPerson OUTPUT
			END

			----first inset into tlbEmployes
			INSERT INTO dbo.tlbEmployee
			(
				idfEmployee,
				idfsEmployeeType,
				idfsSite,
				intRowStatus,
				rowguid,
				strMaintenanceFlag,
				strReservedAttribute,
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateUser,
				AuditCreateDTM,
				AuditUpdateUser,
				AuditUpdateDTM,
				idfsEmployeeCategory
			)
			VALUES
			(
				@idfPerson,
				10023002, --@idfsEmployeeType, Person
				ISNULL(@idfsSite, (SELECT top 1 idfsSite FROM dbo.tstSite WHERE idfOffice = @idfInstitution AND intRowStatus = 0)),
				0,
				NEWID(),
				NULL,
				@DataChageInfo,
				10519001,
				'[{"idfEmployee":' + CAST(@idfPerson AS NVARCHAR(300)) + '}]',
				@User,
				GETDATE(),
				@User,
				GETDATE(),
				@idfsEmployeeCategory
			)

			----second insert into tlbPerson with same id input
			INSERT INTO dbo.tlbPerson
			(
				idfPerson,
				idfsStaffPosition,
				idfInstitution,
				idfDepartment,
				strFamilyName,
				strFirstName,
				strSecondName,
				strContactPhone,
				strBarcode,
				rowguid,
				intRowStatus,
				strMaintenanceFlag,
				strReservedAttribute,
				PersonalIDValue,
				PersonalIDTypeID,
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateUser,
				AuditCreateDTM,
				AuditUpdateUser,
				AuditUpdateDTM
			)
			VALUES
			(
				@idfPerson,
				@idfsStaffPosition,
				@idfInstitution,
				@idfDepartment,
				@strFamilyName,
				@strFirstName,
				@strSecondName,
				@strContactPhone,
				@strBarcode,
				NEWID(),
				0,
				NULL,
				@DataChageInfo,
				@strPersonalID,
				@idfPersonalIDType,
				10519001,
				'[{"idfPerson":' + CAST(@idfPerson AS NVARCHAR(300)) + '}]',
				@User,
				GETDATE(),
				@User,
				GETDATE()
					
			)

		END  ----end action =4

		ELSE 
		BEGIN
			BEGIN	
						
				----first updatte tlbPerson
				UPDATE dbo.tlbPerson
					SET 
						idfsStaffPosition = @idfsStaffPosition
						,idfInstitution = @idfInstitution
						,idfDepartment = @idfDepartment
						,strFamilyName = @strFamilyName
						,strFirstName = @strFirstName
						,strSecondName = @strSecondName
						,strContactPhone = @strContactPhone
						,strBarcode = @strBarcode
						,PersonalIDTypeID = @idfPersonalIDType
						,PersonalIDValue = @strPersonalID
						,strReservedAttribute=@DataChageInfo
						,AuditUpdateUser = @User
						,AuditUpdateDTM = GETDATE()
				WHERE idfPerson=@idfPerson
			END

			----second update tstUserTable
			DECLARE @idfsPersonSite BIGINT

			--SELECT	@idfsPersonSite = s.idfsSite
			--FROM	tlbPerson p 
			--INNER JOIN tstSite s ON s.idfOffice = p.idfInstitution AND s.intRowStatus = 0
			--WHERE	p.idfPerson = @idfPerson

			--SELECT	@idfsPersonSite = o.idfsSite
			--FROM	dbo.tlbPerson p 
			--INNER JOIN dbo.tlbOffice o ON o.idfOffice = p.idfInstitution AND o.intRowStatus = 0
			--WHERE	p.idfPerson = @idfPerson

			SELECT	@idfsPersonSite = s.idfsSite
			FROM	dbo.tlbPerson p 
			INNER JOIN dbo.tstsite s ON s.idfOffice = p.idfInstitution AND s.intRowStatus = 0
			WHERE	p.idfPerson = @idfPerson

			BEGIN
				UPDATE dbo.tstUserTable
				SET idfsSite = @idfsPersonSite,
					AuditUpdateUser = @User,
					AuditUpdateDTM = GETDATE()
				WHERE idfPerson = @idfPerson AND idfsSite<>@idfsPersonSite

			END 

			----update tlbEmployee 
			BEGIN
				UPDATE	dbo.tlbEmployee
				SET		idfsSite = @idfsSite,
						idfsEmployeeCategory = @idfsEmployeeCategory,
						AuditUpdateUser = @User,
						AuditUpdateDTM = GETDATE()

				WHERE	idfEmployee = @idfPerson
			END 
		END---end update 


		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode 'ReturnCode', @returnMsg 'RetunMessage',@idfPerson 'idfPerson'
	END TRY  

	BEGIN CATCH  

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK

			END;
		THROW
	END CATCH 
END







