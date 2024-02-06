-- This script creates employees of specified orginizations with specified account names and passwords on sites of their organizations.
-- It configures all applicable "Allow" permissions on default site.
--
-- NB! Account names and passwords shall contain English symbols, digits, spaces and points only.
-- NB! Account names shall be unique for different employees in the list.
-- NB! Employee shall be present in the list once.

/*****************************************************************************************************************************************/
--Change History
--Date	   BY		What
--------------------
/*****************************************************************************************************************************************/ 


use [Giraffe]
GO


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

ALTER	function [dbo].FN_GBL_TriggersWork ()

returns bit
as
begin
return 0
end
GO

set nocount on
set XACT_ABORT on
GO
BEGIN TRAN

--UPDATE dbo.trtBaseReference
--SET intRowStatus = 0
--WHERE idfsBaseReference BETWEEN -529 AND -513


UPDATE dbo.trtBaseReference
SET intRowStatus = 0
WHERE idfsBaseReference = -501

DECLARE @rowProcessed	INT, 
		@currentRowId	INT = 1,
		@strFirstName	NVARCHAR(255),
		@strLastName	NVARCHAR(255), 
		@strSiteName	NVARCHAR(255), 
		@strRole		NVARCHAR(255),
		@strAccountName	NVARCHAR(255),
		@strPassword	VARCHAR(500) = 'EIDss 2023$',
		@strsecurityStamp NVARCHAR(500) = '6SCD5I2AKVRSE4QVA6JISRSMXQREY45R', 
		@idfsSite		BIGINT,
		@strRegion		NVARCHAR(255),
		@strRayon		NVARCHAR(255),
		@strSettlement NVARCHAR(255),
		@idfCustomizationPackage BIGINT = (SELECT CONVERT(BIGINT, strValue) 
											FROM dbo.tstGlobalSiteOptions 
											WHERE strName = 'CustomizationPackage'),
		@idfOffice BIGINT,
		@id NVARCHAR(MAX),
		@strSiteID NVARCHAR(255),
		@idfsRegion BIGINT,
		@idfsRayon BIGINT, 
		@idfsSettlement BIGINT, 
		@idfGeoLocationShared  BIGINT,
		@idfsOrganizationName BIGINT,
		@idfsOrganizationAbbrName BIGINT,
		@idfEmployee BIGINT,
		@idfPerson BIGINT,
		@idfUserId BIGINT,
		@idfEmployeeGroup BIGINT


-- Georgia User
IF (dbo.FN_GBL_CurrentCountry_Get() = 780000000)
BEGIN

	SET	@strFirstName = 'EIDSS'
	SET @strLastName = 'Administrator'
	SET @strSiteName = 'MoLHSA'
	SET @strRegion = 'Tbilisi'
	SET @strRayon = 'Didube-Chughureti'
	SET @strSettlement = 'Didube'
	SET @strRole = 'Administrator'
	SET @strAccountName = 'admin'
	SET @strPassword = 'AQAAAAEAACcQAAAAEIvm12VITc96N39k6s7XDMYN3Nb63T3uPagwEE/lk+5uh3gz10qlliJV5N97SoAE3w=='
	

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
	BEGIN

		-- Get the site Id
		IF @strSiteName IS NOT NULL
		BEGIN
			SET @idfsSite = dbo.FN_SiteID_GET()
			SET @idfOffice = 709150000000
		END

		-- Create a employee record
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbEmployee', @idfEmployee OUTPUT
			INSERT 
			INTO	dbo.tlbEmployee
			(
				idfEmployee,
				idfsEmployeeType,
				idfsSite,
				intRowStatus,
				rowguid,
				AuditCreateUser,
				AuditCreateDTM,
				SourceSystemNameID,
				SourceSystemKeyValue
			)
			VALUES
			(
				@idfEmployee,
				10023002,
				@idfsSite,
				0,
				NEWID(),
				'System',
				GETDATE(),
				10519001,
				'[{"idfEmployee":' + CAST(@idfEmployee AS NVARCHAR(24)) + '}]'
			)
		END

		-- Create a person record
		BEGIN
			SET @idfPerson = @idfEmployee
			INSERT 
			INTO	dbo.tlbPerson
			(
				idfPerson,
				idfInstitution,
				strFamilyName,
				strFirstName,
				strSecondName,
				intRowStatus,
				rowguid,
				AuditCreateUser,
				AuditCreateDTM,
				SourceSystemNameID,
				SourceSystemKeyValue

			)
			VALUES
			(
				@idfPerson,
				@idfOffice,
				@strLastName,
				@strFirstName,
				NULL,
				0,
				NEWID(),
				'System',
				GETDATE(),
				10519001,
				'[{"idfPerson":' + CAST(@idfPerson AS NVARCHAR(24)) + '}]'

			)
		END

		-- Create record in tstUserTable
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tstUserTable', @idfUserId OUTPUT
			INSERT 
			INTO	dbo.tstUserTable
			(
				idfUserID,
				idfPerson,
				idfsSite,
				datPasswordSet,
				strAccountName,
				binPassword,
				blnDisabled,
				intRowStatus,
				rowguid,
				PreferredLanguageID,
				AuditCreateUser,
				AuditCreateDTM,
				SourceSystemNameID,
				SourceSystemKeyValue
			)
			VALUES	
			(
				@idfUserId,
				@idfPerson,
				@idfsSite,
				GETDATE(),
				@strAccountName,
				HASHBYTES('SHA1', cast('EIDss 2023$' as nvarchar(500))),
				0,
				0,
				NEWID(),
				10049001,
				'System',
				GETDATE(),
				10519001,
				'[{"idfPerson":' + CAST(@idfPerson AS NVARCHAR(24)) + '}]'
			)
		END

		-- Assign user to the employee group
		BEGIN

			SELECT 
				@idfEmployeeGroup = idfEmployeeGroup
			FROM dbo.tlbEmployeeGroup 
			INNER JOIN dbo.trtBaseReference a ON idfsEmployeeGroupName = a.idfsBaseReference
			WHERE strDefault = @strRole
			AND a.intRowStatus = 0
			AND idfsReferenceType = 19000022 -- Employee Group
			
				BEGIN
					INSERT 
					INTO	dbo.tlbEmployeeGroupMember 
							(
								idfEmployeeGroup, 
								idfEmployee
							)
					VALUES	(
								@idfEmployeeGroup,
								@idfEmployee
							)
				END
		END

		-- Insert the record in ASPNETUser Table
	
		BEGIN
			SET @id = NEWID()


			INSERT 
			INTO	dbo.aspNetUsers
					(
						id, 
						idfUserID,
						EmailConfirmed,
						PasswordHash,
						SecurityStamp,
						TwoFactorEnabled,
						LockoutEnabled,
						AccessFailedCount,
						UserName,
						PhoneNumberConfirmed,
						email,
						NormalizedUsername,
						NormalizedEmail,
						LockoutEnd -- Change from LockoutEndDateUTC and set to NULL below...
					)
			VALUES	(
						@id,
						@idfUserId,
						0,
						@strPassword,
						@strsecurityStamp,
						1,
						1,
						0,
						@strAccountName,
						1,
						@strAccountName+'@dummyemail.com',
						@strAccountName,
						@strAccountName+'@dummyemail.com',
						NULL
					)
		END

		-- Insert record in EmployeeToInstitution table
		BEGIN
			INSERT INTO dbo.EmployeeToInstitution
			(
				EmployeeToInstitution,
				aspNetUserId,
				idfUserId,
				idfInstitution,
				IsDefault,
				intRowStatus,
				rowguid,
				strMaintenanceFlag,
				strReservedAttribute,
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateUser,
				AuditCreateDTM,
				Active
			)
			VALUES
			(   @idfEmployee,       -- EmployeeToInstitution - bigint
				@id,     -- aspNetUserId - nvarchar(128)
				@idfUserId,       -- idfUserId - bigint
				@idfOffice,       -- idfInstitution - bigint
				1,    -- IsDefault - bit
				DEFAULT, -- intRowStatus - int
				NEWID(), -- rowguid - uniqueidentifier
				NULL,    -- strMaintenanceFlag - nvarchar(20)
				NULL,    -- strReservedAttribute - nvarchar(max)
				DEFAULT, -- SourceSystemNameID - bigint
				NULL,    -- SourceSystemKeyValue - nvarchar(max)
				'SYSTEM', -- AuditCreateUser - nvarchar(200)
				DEFAULT, -- AuditCreateDTM - datetime
				1
			)
		END

		-- Assign Menu options
		INSERT INTO dbo.LkupRoleMenuAccess 
		(
			idfEmployee, 
			EIDSSMenuID, 
			intRowStatus, 
			AuditCreateUser,
			AuditCreateDTM, 
			rowguid, 
			SourceSystemNameID, 
			SourceSystemKeyValue
			
		)
		SELECT 
			@idfEmployee, 
			EIDSSMenuID,
			intRowStatus, 
			AuditCreateUser,
			AuditCreateDTM, 
			rowguid, 
			'10519001',
			'{"idfEmployee":'+ CAST(@idfEmployee AS NVARCHAR(25)) +'EIDSSMenuID":'+ CAST(EIDSSMenuID	AS NVARCHAR(10)) +'}'

		FROM dbo.LkupRoleMenuAccess
		WHERE idfEmployee = -501 

		-- Assign System Functions
		INSERT INTO dbo.LkupRoleSystemFunctionAccess
		(
			idfEmployee,
			SystemFunctionID, 
			SystemFunctionOperationID, 
			AccessPermissionID,
			intRowStatus,
			AuditCreateUser, 
			AuditCreateDTM, 
			rowguid,
			SourceSystemNameID,
			intRowStatusForSystemFunction
			
		)
		SELECT 
			@idfEmployee, 
			SystemFunctionID,
			SystemFunctionOperationID,
			AccessPermissionID,
			intRowStatus,
			AuditCreateUser,
			AuditCreateDTM, 
			rowguid,
			SourceSystemNameID,
			intRowStatusForSystemFunction

		FROM dbo.LkupRoleSystemFunctionAccess
		WHERE idfEmployee = -501 

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
-- added by MCW to add event subscriptions to user
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.EventSubscription
		(
		    EventNameID,
		    ReceiveAlertFlag,
		    intRowStatus,
		    rowguid,
		    AuditCreateUser,
		    AuditCreateDTM,
		    SourceSystemKeyValue,
		    SourceSystemNameID,
		    idfUserID
		)

		SELECT
			idfsEventTypeID,
			1,
			0,
			NEWID(),
			'System',
			GETDATE(),
			N'[{"EventNameID":' + CAST(idfsEventTypeID AS NVARCHAR(300)) + '}]',
			10519001,
			@idfUserId

		FROM dbo.trtEventType
		WHERE intRowStatus = 0

		SET @currentRowId = @currentRowId + 1
	END
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
			PRINT CONVERT(NVARCHAR(20), @rowProcessed) + ' users created'


END


GO

set XACT_ABORT off
set nocount off
SET ANSI_NULLS on
SET QUOTED_IDENTIFIER on
GO

ALTER	function [dbo].[FN_GBL_TriggersWork] ()
returns bit
as
begin
return 1 --0
end
GO

