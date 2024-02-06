--*************************************************************
-- Name: [USP_OMM_SESSION_Note_Set]
-- Description: Insert/Update for Outbreak Case
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	LAMONT MITCHELL	1/25/19		Removed @T temp table, Aliased Return Columns, Added throw to Try Catch
--	Doug Albanese	10/9/2020	Added Auditing information
--  Doug Albanese	04/19/2023	 Converted VARCHAR to NVARCHAR for a number of fields
--
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_SESSION_Note_Set]
(    
	@LangID								NVARCHAR(50), 
	@idfOutbreakNote					BIGINT = -1,
	@idfOutbreak						BIGINT,
	@strNote							NVARCHAR(2000) = NULL,
	@idfPerson							BIGINT,
	@intRowStatus						INT = 0,
	@strMaintenanceFlag					NVARCHAR(20) = NULL,
	@strReservedAttribute				NVARCHAR(MAX) = NULL,
	@UpdatePriorityID					BIGINT = NULL,
	@UpdateRecordTitle					NVARCHAR(200) = NULL,
	@UploadFileName						NVARCHAR(200) = NULL,
	@UploadFileDescription				NVARCHAR(200) = NULL,
	@UploadFileObject					VARBINARY(MAX) = NULL,
	@DeleteAttachment					VARCHAR(1) = '0',
	@User								NVARCHAR(200) = ''
)
AS

BEGIN    

	DECLARE	@returnCode					INT = 0;
	DECLARE @returnMsg					NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @outbreakLocation			BIGINT = NULL

	Declare @SupressSelect table
	( 
		retrunCode int,
		returnMessage varchar(200)
	)
	BEGIN TRY
		
		IF @DeleteAttachment = '1'
			BEGIN
				UPDATE	tlbOutbreakNote
				SET		UploadFileName = NULL,
						UploadFileObject = NULL,
						AuditUpdateDTM = GETDATE(),
						AuditUpdateUser = @User
				WHERE
						idfOutbreakNote=@idfOutbreakNote			
			END
		ELSE
			BEGIN
				IF EXISTS (SELECT * FROM tlbOutbreakNote WHERE idfOutbreakNote = @idfOutbreakNote)
					BEGIN
						UPDATE		tlbOutbreakNote
						SET 
									strNote = @strNote,
									datNoteDate = GETDATE(),
									intRowStatus = @intRowStatus,
									strMaintenanceFlag = @strMaintenanceFlag,
									strReservedAttribute = @strReservedAttribute,
									UpdatePriorityID = @UpdatePriorityID,
									UpdateRecordTitle = @UpdateRecordTitle,
									UploadFileDescription = @UploadFileDescription,
									AuditUpdateDTM = GETDATE(),
									AuditUpdateUser = @User

						WHERE
									idfOutbreakNote=@idfOutbreakNote

						IF @UploadFileName <> ''
							UPDATE	tlbOutbreakNote
							SET		UploadFileName = @UploadFileName,
									UploadFileObject = @UploadFileObject,
									AuditUpdateDTM = GETDATE(),
									AuditUpdateUser = @User
							WHERE
									idfOutbreakNote=@idfOutbreakNote
						

					END
				ELSE
					BEGIN

						INSERT INTO @SupressSelect
						EXEC	dbo.USP_GBL_NEXTKEYID_GET 'tlbOutbreakNote', @idfOutbreakNote OUTPUT;
						INSERT INTO	dbo.tlbOutbreakNote
						(

								idfOutbreakNote,
								idfOutbreak,
								strNote,
								datNoteDate,
								idfPerson,
								intRowStatus,
								strMaintenanceFlag,
								strReservedAttribute,
								UpdatePriorityID,
								UpdateRecordTitle,
								UploadFileName,
								UploadFileDescription,
								UploadFileObject,
								AuditCreateDTM,
								AuditCreateUser
						)
						VALUES
						(

								@idfOutbreakNote,
								@idfOutbreak,
								@strNote,
								GETDATE(),
								@idfPerson,
								@intRowStatus,
								@strMaintenanceFlag,
								@strReservedAttribute,
								@UpdatePriorityID,
								@UpdateRecordTitle,
								@UploadFileName,
								@UploadFileDescription,
								@UploadFileObject,
								GETDATE(),
								@User
						)

					END
							
			END

	END TRY
	BEGIN CATCH
		--IF @@TRANCOUNT = 1 
		--	ROLLBACK;
		
		--SET		@returnCode = ERROR_NUMBER();
		--SET		@returnMsg = 
		--			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
		--			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
		--			+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
		--			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
		--			+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
		--			+ ' ErrorMessage: '+ ERROR_MESSAGE();

		--		INSERT INTO @T
		--		SELECT @returnCode as returnCode, @returnMsg as returnMsg, @idfOutbreakNote as idfOutbreakNote
		Throw;
	END CATCH

	SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @idfOutbreakNote 'idfOutbreakNote'

END
