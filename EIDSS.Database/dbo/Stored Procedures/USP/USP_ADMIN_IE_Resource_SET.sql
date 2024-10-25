----------------------------------------------------------------------------
-- Name 				: USP_ADMIN_IE_Resource_SET
-- Description			: Insert/Update Resource Data
--          
-- Author               : Mike Kornegay
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mike Kornegay	6/23/2021	Original
-- Mike Kornegay	7/20/2021	Update so that all languages update translation table
-- Mike Kornegay	7/23/2021	Correct missing fields on update to translation table
--
-- Testing code:
--*/
----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[USP_ADMIN_IE_Resource_SET]
(
	@idfsResource			BIGINT
	,@idfsResourceSet		BIGINT
	,@DefaultName			NVARCHAR(400)	
	,@NationalName			NVARCHAR(600)	
	,@isRequired			BIT
	,@isHidden				BIT
	,@LangID				NVARCHAR(50)
	,@User			NVARCHAR(200)

)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- Interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @returnCode							INT = 0;
	DECLARE	@returnMsg							NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @idfsLanguage						BIGINT;

	BEGIN TRY
		BEGIN
			
				SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId);

				IF EXISTS (
					SELECT		idfsResource 
					FROM		dbo.[trtResourceTranslation] 
					WHERE		idfsResource = @idfsResource 
					AND			idfsLanguage = @idfsLanguage
				)
					BEGIN
						--update translation table
						UPDATE		dbo.[trtResourceTranslation]
						SET			strResourceString = @NationalName,
									AuditUpdateUser = @User,
									AuditUpdateDTM = GETDATE()
						WHERE		idfsResource = @idfsResource
						AND			idfsLanguage = @idfsLanguage
					END
				ELSE
					BEGIN
						--insert to translation table
						INSERT INTO	dbo.[trtResourceTranslation] 
									(	idfsResource, 
										strResourceString, 
										idfsLanguage, 
										strMaintenanceFlag, 
										strReservedAttribute, 
										SourceSystemNameID, 
										SourceSystemKeyValue, 
										AuditCreateUser,
										AuditCreateDTM,
										AuditUpdateUser,
										AuditUpdateDTM
									) 
						VALUES		(
										@idfsResource, 
										@NationalName, 
										@idfsLanguage, 
										'ADD', 
										'EIDSS7 Resource Translations', 
										10519001, 
										'[{"idfsResource:"' + CONVERT(nvarchar, @idfsResource) + ', "idfsLanguage":' + CONVERT(nvarchar, @idfsLanguage) + ')}',
										@User,
										GETDATE(),
										@User,
										GETDATE()
									) 
					END

				--update the resource set to resource table
				UPDATE dbo.[trtResourceSetToResource]
				SET 
					isHidden = @isHidden,
					isRequired = @isRequired
				WHERE idfsResource = @idfsResource
				AND idfsResourceSet = @idfsResourceSet
		END

		IF @@TRANCOUNT > 0 AND @returnCode = 0
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

