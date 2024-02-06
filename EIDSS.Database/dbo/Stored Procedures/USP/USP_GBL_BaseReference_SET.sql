




----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: USP_GBL_BaseReference_SET
-- Description			: Insert/Update Base Reference Data
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    10-Nov-2017   Convert EIDSS 6 to EIDSS 7 standards and 
--                              added table name to USP_GBL_NEWID_GET call
--
-- Stephen Long		05/03/2018	Added return code and try catch block.
-- Lamont Mitchell  01/02/19    Aliased Return Code and Message Added ReferenceID as and output in the Select statment , removed as output parameter 
-- Ricky Moss		01/08/2019  Comment out select return code line
-- Doug Albanese	05/14/2020	Added a Functioncall parameter to bypass supress for INSERT within INSERT Errors
-- Mark Wilson		07Jul2021	Updated for consistency
-- Mark Wilson		03Aug2021	Updated to not check for dupes for diseases (19000019)
-- Mark Wilson		09Aug2021	Removed strDefault from USSP_GBL_StringTranslation_SET call
-- Mark Wilson		04Oct2021	Added @User
-- Testing code:
/*
Example of procedure call:

DECLARE @idfsAgeGroup BIGINT = NULL,
		@ReferenceType BIGINT = 19000146,
		@LangID NVARCHAR(24) = 'ka-GE',
		@strDefault NVARCHAR(200) = 'New Age Group for MCW',
		@strName NVARCHAR(200) = 'GG Translation New Age Group for MCW',
		@HACode INT = NULL,
		@intOrder INT = 550,
		@User NVARCHAR(100) = 'TestUser'

EXEC dbo.USP_GBL_BaseReference_SET @idfsAgeGroup, 19000146, @LangID, @strDefault, @strName, @HACode, @intOrder, @User, 0;


*/
----------------------------------------------------------------------------
----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[USP_GBL_BaseReference_SET] 
(
	@ReferenceID BIGINT OUTPUT,
	@ReferenceType BIGINT,
	@LangID NVARCHAR(50),
	@DefaultName VARCHAR(200),  -- Default reference name, used if there is no reference translation
	@NationalName NVARCHAR(200),-- Reference name in the language defined by @LangID
	@HACode INT = NULL,			-- Bit mask for reference using
	@Order INT = NULL,			-- Reference record order for sorting
	@System BIT = 0,
	@User NVARCHAR(100) = '',	-- Added for Audit
	@FunctionCall BIT = 0 --DO NOT REMOVE! This is used to bypass supression for INSERT within INSERT Errors
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;
	DECLARE @DuplicateDefault	INT = 0 -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.

	BEGIN TRY

	IF (@ReferenceID IS NOT NULL) -- This is an update
	BEGIN -- start the update
		IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsReferenceType = @ReferenceType AND strDefault = @DefaultName AND idfsBaseReference <> @ReferenceID AND trtBaseReference.intRowStatus = 0 AND idfsReferenceType <> 19000019)
		BEGIN
			SET @DuplicateDefault = 1
			SET @returnMsg = 'DOES EXIST'
		END
		ELSE -- proceed with update
		BEGIN
			UPDATE dbo.trtBaseReference
			SET idfsReferenceType = @ReferenceType,
				strDefault = @DefaultName, 
				intHACode = @HACode,
				intOrder = @Order,
				blnSystem = @System,
				intRowStatus = 0,
				SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
				SourceSystemKeyValue = ISNULL(SourceSystemKeyValue, '[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + '}]'),
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE idfsBaseReference = @ReferenceID;
		END
	END

	ELSE -- this is an insert
	BEGIN 

		EXEC dbo.USP_GBL_NEXTKEYID_GET 
			@tableName = 'trtBaseReference', 
			@idfsKey = @ReferenceID OUTPUT;

		INSERT INTO dbo.trtBaseReference
		(
			idfsBaseReference,
			idfsReferenceType,
			strBaseReferenceCode,
			strDefault,
			intHACode,
			intOrder,
			blnSystem,
			intRowStatus,
			rowguid,
			strMaintenanceFlag,
			strReservedAttribute,
			SourceSystemNameID,
			SourceSystemKeyValue,
			AuditCreateUser,
			AuditCreateDTM,
			AuditUpdateUser,
			AuditUpdateDTM
		)
		VALUES
		(   @ReferenceID,
			@ReferenceType,
			NULL,
			@DefaultName,
			@HACode,
			@Order,
			@System, 
			0,
			NEWID(),
			N'ADD',
			N'EIDSS7 Reference Data',
			10519001, 
			N'[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + '}]',
			@User,
			GETDATE(), 
			@User,
			GETDATE()
			) 

		DECLARE @idfCustomizationPackage BIGINT;

		SELECT @idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET();

		IF @idfCustomizationPackage IS NOT NULL
			AND @idfCustomizationPackage <> 51577300000000 --The USA
		BEGIN
			EXEC dbo.USP_GBL_BaseReferenceToCP_SET 
				@idfsReference = @ReferenceID,
				@idfCustomizationPackage = @idfCustomizationPackage,
				@User = @User
		END

	END 

	BEGIN
		
		EXEC dbo.USSP_GBL_StringTranslation_SET 
			@ReferenceID = @ReferenceID,
			@LangID = @LangID,
			@NationalName = @NationalName,
			@User = @User

	END

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END

