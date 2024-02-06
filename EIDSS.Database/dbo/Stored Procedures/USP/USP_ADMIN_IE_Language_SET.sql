----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: USP_ADMIN_IE_Language_SET
-- Description			: Insert a new Language Code to Base Reference Data
--          
-- Author               : Mike Kornegay - copied from USP_GBL_BaseReference_SET by Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mike Kornegay    09/08/2021  Original - copied from USP_GBL_BaseReference_SET
--
-- Testing code:
/*
Example of procedure call:

DECLARE @idfsReferenceId BIGINT = NULL,
		@ReferenceType BIGINT = 19000049,
		@LangID NVARCHAR(24) = 'en-US',
		@strDefault NVARCHAR(200) = 'German',
		@strReferenceCode NVARCHAR(200) = 'de-DE'
		@NationalName NVARCHAR(200) = 'Duetsche',
		@HACode INT = NULL,
		@intOrder INT = 0

EXEC dbo.USP_ADMIN_IE_Language_SET @idfsReferenceId, @ReferenceType, @LangID, @strDefault, @strReferenceCode, @strName, @HACode, @intOrder;


*/
----------------------------------------------------------------------------
----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[USP_ADMIN_IE_Language_SET] 
(
	@ReferenceID BIGINT = NULL,
	@ReferenceType BIGINT,		--always 19000049 for Language
	@LangID NVARCHAR(50),
	@DefaultName VARCHAR(200),  -- Country from the Culture object
	@NationalName NVARCHAR(200),-- Language name in the language being added
	@strReferenceCode NVARCHAR(200), --CultureInfoCode
	@HACode INT = NULL,			-- Bit mask for reference using
	@Order INT = NULL			-- Reference record order for sorting
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode INT = 0;
	DECLARE @idfsReferenceId BIGINT;
	DECLARE @SupressSelect TABLE (retrunCode INT, returnMessage VARCHAR(200))

	BEGIN TRY

		IF EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsReferenceType = @ReferenceType AND strDefault = @DefaultName AND idfsBaseReference <> @ReferenceID AND trtBaseReference.intRowStatus = 0 AND idfsReferenceType <> 19000019)
			BEGIN
				SET @returnCode = 1
				SET @returnMsg = 'DOES EXIST'
			END
		ELSE 
			BEGIN 

				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference',@ReferenceID OUTPUT;

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
					@strReferenceCode,
					@DefaultName,
					@HACode,
					@Order,
					0, 
					0,
					NEWID(),
					N'ADD',
					N'EIDSS7 Reference Data',
					10519001, 
					N'[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + '}]',
					N'System',
					GETDATE(), 
					N'System',
					GETDATE()
					) 
			END

		IF @@Trancount > 0 AND @returnCode = 0
			COMMIT;

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage;

	END TRY

	BEGIN CATCH
			IF @@Trancount = 1 
			ROLLBACK;

		SET		@returnCode = ERROR_NUMBER();
		SET		@returnMsg = ' ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
								+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
								+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
								+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A')
								+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), 'N/A'))
								+ ' ErrorMessage: ' + ERROR_MESSAGE() 
								+ ' State: ' + CONVERT(VARCHAR, ISNULL(XACT_STATE(), 'N/A'));

		SELECT	@returnCode AS ReturnCode, @returnMsg AS ReturnMessage;
	END CATCH;
END

