


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: USSP_GBL_StringTranslation_SET
-- Description			: Insert/UPDATE Base Reference Data
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date			Change Detail
-- Mark Wilson		10-Nov-2017		Convert EIDSS 6 to EIDSS 7 standards and 
--									added table name to USP_GBL_NEWID_GET call
-- Lamont Mitchell  01-02-19		Replaced Error Details in Catch and added Throw,  Aliased ReturnCode And ReturnMessage
-- Mark Wilson		08-09-2021		removed @DefaultName from sp.  unused parameter
-- Mark Wilson		10-04-2021		added @User
-- Testing code:
/*
--Example of a call of procedure:
DECLARE @ReferenceID bigint = 389445040001658
DECLARE @LangID nvarchar(50) = 'ka-GE'
DECLARE @NationalName nvarchar(200) = 'New TEST'
DECLARE @User NVARCHAR(100) = 'TestUser'

EXECUTE USP_GBL_StringTranslation_SET
   @ReferenceID,
   @LangID,
   @NationalName,
   @User
*/

CREATE PROCEDURE [dbo].[USSP_GBL_StringTranslation_SET]
(
	@ReferenceID BIGINT, 
	@LangID  NVARCHAR(50), 
	@NationalName  NVARCHAR(200),
	@User NVARCHAR(100) = ''
)
AS

BEGIN

	BEGIN TRY

		IF EXISTS(SELECT idfsBaseReference FROM	dbo.trtStringNameTranslation WHERE idfsBaseReference = @ReferenceID AND idfsLanguage = dbo.FN_GBL_LANGUAGECODE_GET(@LangID))
		BEGIN
			UPDATE	dbo.trtStringNameTranslation
			SET strTextString = @NationalName,
				intRowStatus = 0,
				rowguid = ISNULL(rowguid, NEWID()),
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE idfsBaseReference = @ReferenceID 
			AND idfsLanguage = dbo.FN_GBL_LANGUAGECODE_GET(@LangID)
		END
		ELSE 

			BEGIN

				INSERT INTO dbo.trtStringNameTranslation
				(
					idfsBaseReference,
					idfsLanguage,
					strTextString, 
					intRowStatus,
					rowguid,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser,
					AuditUpdateDTM,
					AuditUpdateUser
				)
				VALUES
				(
					@ReferenceID,
					dbo.FN_GBL_LANGUAGECODE_GET(@LangID),
					@NationalName, 
					0,
					NEWID(),
					10519001,
					'[{"idfsBaseReference":' + CAST(@ReferenceID AS NVARCHAR(300)) + ' , "idfsLanguage":' + CAST(dbo.FN_GBL_LANGUAGECODE_GET(@LangID) AS NVARCHAR(300)) + '}]',
					GETDATE(),
					@User,
					GETDATE(),
					@User
					
				)
			END

	END TRY  
	BEGIN CATCH 

THROW
	END CATCH;
END



