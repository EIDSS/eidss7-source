
-- ============================================================================
-- Name: USP_REF_SPECIESTYPEREFERENCE_SET
-- Description:	Get the Case Classification for reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss       10/02/2018 Initial release.
-- Ricky Moss		10/04/2018	Updated the update piece of the stored procedure
-- Mark Wilson		07/08/2021 Updated for consistency
/*

exec USP_REF_SPECIESTYPEREFERENCE_SET null, 'Test2', 'Test', '', 32, 1, 'en-US'
exec USP_REF_SPECIESTYPEREFERENCE_SET 389445040002356, 'Test2', 'Test1', '', 32, 1, 'en-US'

*/
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_SPECIESTYPEREFERENCE_SET] 
	@idfsSpeciesType BIGINT = NULL,
	@strDefault VARCHAR(200),
	@strName  NVARCHAR(200),
	@strCode NVARCHAR(50),
	@intHACode INT,
	@intOrder INT,
	@LangID  NVARCHAR(50)
AS

BEGIN 
	SET NOCOUNT ON

	DECLARE @returnMsg			NVARCHAR(MAX) = N'Success';
	DECLARE @returnCode			BIGINT = 0;
	DECLARE @existingDefault	BIGINT
	DECLARE @existingName		BIGINT 
	DECLARE @DuplicateDefault	INT = 0 -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.
	DECLARE @idfsReferenceType	BIGINT = 19000086 -- Species Type
	DECLARE @SupressSelect TABLE
	( 
	retrunCode INT,
	returnMessage VARCHAR(200)
	)

	BEGIN TRY
		IF @idfsSpeciesType IS NULL
		BEGIN -- this is an insert.  check if the strDefault is a duplicate
			IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE strDefault = @strDefault AND idfsReferenceType = @idfsReferenceType AND trtBaseReference.intRowStatus = 0)
			BEGIN
				SET @DuplicateDefault = 1
			END

		END
		ELSE
		BEGIN -- this is an update.  check if the strDefault is a duplicate
			IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference <> @idfsSpeciesType AND strDefault = @strDefault AND idfsReferenceType = @idfsReferenceType AND trtBaseReference.intRowStatus = 0)
			BEGIN
				SET @DuplicateDefault = 1
			END
		END

		IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate
		BEGIN
			SELECT @returnMsg = 'DOES EXIST'
		END
		ELSE -- no duplicates, so continue

		BEGIN
			
			EXEC dbo.USP_GBL_BaseReference_SET
				@ReferenceID=@idfsSpeciesType OUTPUT, 
				@ReferenceType=@idfsReferenceType, 
				@LangID=@LangID, 
				@DefaultName=@strDefault, 
				@NationalName=@strName, 
				@HACode=@intHACode, 
				@Order=@intOrder, 
				@System=0;

			IF EXISTS (SELECT idfsSpeciesType FROM dbo.trtSpeciesType WHERE idfsSpeciesType  = @idfsSpeciesType)
			BEGIN
				UPDATE dbo.trtSpeciesType
					SET strCode = @strCode,
						intRowStatus = 0,
						SourceSystemNameID = ISNULL(SourceSystemNameID, 10519001),
						SourceSystemKeyValue = N'[{"idfsSpeciesType":' + CAST(@idfsSpeciesType AS NVARCHAR(300)) + '}]',
						AuditUpdateUser = 'System',
						AuditUpdateDTM = GETDATE()
					WHERE idfsSpeciesType = @idfsSpeciesType

			END
			ELSE
			BEGIN			
				INSERT INTO dbo.trtSpeciesType
				(
				    idfsSpeciesType,
				    strCode,
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
				(
					@idfsSpeciesType, 
					@strCode,
					0,
					NEWID(),
					'ADD',
					'EIDSS7 Species Type',
					10519001,
					N'[{"idfsSpeciesType":' + CAST(@idfsSpeciesType AS NVARCHAR(300)) + '}]',
					'System',
					GETDATE(),
					'System',
					GETDATE()
				)
			END

		END

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage' , @idfsSpeciesType 'idfsSpeciesType'

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
