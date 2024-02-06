--*************************************************************
-- Name 				: USP_OMM_SESSION_Note_Delete
-- Description			: Deletes file objects, or the entire record for the specified note 
--          
-- Author               : Doug Albanese
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
--	Name			Date		Comments
--	Doug Albanese	10/06/2021	Removed "Catch" coding that was preventing EF from generating a model
--	Doug Albanese	10/06/2021	Added auditing information and fixed to "Soft" delete
--	Doug Albanese	10/06/2021	Missed return aliases
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_SESSION_Note_Delete]
(  
	@idfOutbreakNote			BIGINT,
	@deleteFileObjectOnly		BIT = NULL,
	@User						NVARCHAR(50)
)  

AS  
	DECLARE	@returnCode					INT = 0;
	DECLARE @returnMessage					NVARCHAR(MAX) = 'SUCCESS';

	BEGIN

		BEGIN TRY  	
			IF @deleteFileObjectOnly = 1
				BEGIN
					UPDATE			tlbOutbreakNote
					SET				UploadFileName = null, 
									UploadFileObject = NULL,
									AuditUpdateUser = @User,
									AuditUpdateDTM = GETDATE()
					WHERE			idfOutbreakNote = @idfOutbreakNote

				END
			ELSE
				BEGIN
					UPDATE			tlbOutbreakNote
					SET				intRowStatus = 1,
									AuditUpdateUser = @User,
									AuditUpdateDTM = GETDATE()
					WHERE			idfOutbreakNote = @idfOutbreakNote
				END

			SELECT @returnCode as ReturnCode, @returnMessage as returnMessage

			IF @@TRANCOUNT > 0 
				COMMIT;

		END TRY  

		BEGIN CATCH 

		END CATCH

	END


